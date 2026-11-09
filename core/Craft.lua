-- @ADDON@: crafting assistant for your two main professions (chosen in the settings
-- window, or detected from what you've learned). Crafting professions show the next
-- step of the route with what you have and miss in bags and bank; gathering
-- professions show what you can gather now, what comes next and where to go.
local _, ns = ...

local win

---------------------------------------------------------------------------
-- Which professions
---------------------------------------------------------------------------
local function IsProf(name)
  for _, p in ipairs(ns.PROFS) do if p == name then return true end end
  return false
end

-- The two main professions: the ones picked in the settings, otherwise the ones you've
-- learned, otherwise the addon's defaults.
function ns.SelectedProfs()
  local picked = ns.db and ns.db.profs or {}
  local out, used = {}, {}
  for i = 1, 2 do
    local p = picked[i]
    if p and IsProf(p) and not used[p] then out[i] = p; used[p] = true end
  end
  for i = 1, 2 do
    if not out[i] then
      for _, p in ipairs(ns.PROFS) do
        if not used[p] and ns.GetProfSkill(p) then out[i] = p; used[p] = true; break end
      end
    end
  end
  for i = 1, 2 do
    if not out[i] then
      for _, p in ipairs(ns.DEFAULT_PROFS or {}) do
        if not used[p] then out[i] = p; used[p] = true; break end
      end
    end
  end
  return out
end

function ns.HasProf(name)
  for _, p in ipairs(ns.SelectedProfs()) do if p == name then return true end end
  return false
end

-- Plan entries that name a profession ("... (Tailoring)") only show when it's one of yours.
function ns.GearVisible(item)
  local text = type(item) == "table" and item[1] or item
  if type(text) ~= "string" then return true end
  for _, p in ipairs(ns.PROFS) do
    if text:find(p, 1, true) and not ns.HasProf(p) then return false end
  end
  return true
end

-- Steps through "auto" + all professions for the settings window.
function ns.StepProf(slot, dir)
  ns.db.profs = ns.db.profs or {}
  local list = { false }
  for _, p in ipairs(ns.PROFS) do table.insert(list, p) end
  local cur = 1
  for i, p in ipairs(list) do if p == (ns.db.profs[slot] or false) then cur = i end end
  ns.db.profs[slot] = list[((cur - 1 + dir) % #list) + 1] or nil
  ns.RefreshMain()
  if ns.RefreshCraft then ns.RefreshCraft() end
end

-- Secondary skills (Cooking, First Aid, Fishing): one tick box each in the settings.
-- ns.db.secShow[name]: true = show, false = hide, nil = show once you've learned it.
local function SecSettings()
  ns.db.secShow = ns.db.secShow or {}
  -- Earlier versions had one on/off switch.
  if ns.db.secondaryOff then
    for _, p in ipairs(ns.SECONDARY or {}) do ns.db.secShow[p] = false end
    ns.db.secondaryOff = nil
  end
  -- The version before had one "Secondary" choice: keep what was picked.
  local old = { off = {}, all = { "Cooking", "First Aid", "Fishing" }, c = { "Cooking" }, f = { "First Aid" },
    s = { "Fishing" }, cf = { "Cooking", "First Aid" }, cs = { "Cooking", "Fishing" }, fs = { "First Aid", "Fishing" } }
  local list = ns.db.secondary and old[ns.db.secondary]
  if list then
    for _, p in ipairs(ns.SECONDARY or {}) do ns.db.secShow[p] = false end
    for _, p in ipairs(list) do ns.db.secShow[p] = true end
  end
  ns.db.secondary = nil
  return ns.db.secShow
end

function ns.SecondaryShown(p)
  local v = SecSettings()[p]
  if v == nil then return ns.GetProfSkill(p) ~= nil end
  return v
end

-- The secondary skills to show, and whether any of them is still on "auto".
function ns.ShownSecondary()
  local out, auto = {}, false
  for _, p in ipairs(ns.SECONDARY or {}) do
    if SecSettings()[p] == nil then auto = true end
    if ns.SecondaryShown(p) then table.insert(out, p) end
  end
  return out, auto
end

function ns.ToggleSecondary(p)
  SecSettings()[p] = not ns.SecondaryShown(p)
  ns.Print(ns.T(ns.db.secShow[p] and "SEC_SHOW" or "SEC_HIDE", p))
  if ns.RefreshCraft then ns.RefreshCraft() end
end

function ns.ProfLabel(slot)
  local p = ns.db.profs and ns.db.profs[slot]
  if p then return p end
  return ns.T("PROF_AUTO", ns.SelectedProfs()[slot] or "?")
end

---------------------------------------------------------------------------
-- Crafting routes
---------------------------------------------------------------------------
local function StepFor(route, skill)
  for i, s in ipairs(route) do
    if skill < s.to then return s, route[i + 1] end
  end
end

local function Remaining(s, skill)
  if s.batch then return s.crafts end
  local span = s.to - s.from
  if span <= 0 then return s.crafts end
  local frac = (s.to - math.max(skill, s.from)) / span
  return math.max(1, math.ceil(s.crafts * frac))
end

-- Does the current or next Enchanting step need this item?
function ns.EnchantNeedsMat(itemID)
  local skill = ns.GetProfSkill("Enchanting")
  if not skill or skill >= 300 or not ns.ROUTES.Enchanting then return false end
  local s, nxt = StepFor(ns.ROUTES.Enchanting, skill)
  for _, step in ipairs({ s, nxt }) do
    if step then
      for _, m in ipairs(step.mats) do
        if m[1] == itemID then return true end
      end
    end
  end
  return false
end

local PROF_ICON = {
  Alchemy = "Interface\\Icons\\Trade_Alchemy", Blacksmithing = "Interface\\Icons\\Trade_BlackSmithing",
  Enchanting = "Interface\\Icons\\Trade_Engraving", Engineering = "Interface\\Icons\\Trade_Engineering",
  Herbalism = "Interface\\Icons\\Spell_Nature_NatureTouchGrow", Leatherworking = "Interface\\Icons\\INV_Misc_ArmorKit_17",
  Mining = "Interface\\Icons\\Trade_Mining", Skinning = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
  Tailoring = "Interface\\Icons\\Trade_Tailoring",
  Cooking = "Interface\\Icons\\INV_Misc_Food_15", ["First Aid"] = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
  Fishing = "Interface\\Icons\\Trade_Fishing",
}

-- The window is a list of rows (see Rows.lua): { text, icon, items, bar, indent }.
local function Header(prof, out)
  local skill, maxRank = ns.GetProfSkill(prof)
  local row = { icon = PROF_ICON[prof], text = "|cffffffff" .. prof .. "|r" }
  table.insert(out, row)
  if not skill then
    row.text = row.text .. "  |cff888888" .. ns.T("CR_NOT_LEARNED") .. "|r"
    return nil
  end
  if skill >= 300 then
    row.text = row.text .. "  |cff60ff60" .. ns.T("CR_DONE") .. "|r"
    return nil
  end
  row.text = row.text .. "  |cffaaaaaa" ..
    (maxRank and maxRank > 0 and ns.T("CR_SKILL", skill, maxRank) or ns.T("CR_SKILL_ONLY", skill)) .. "|r"
  local cap = (maxRank and maxRank > 0) and maxRank or 300
  local warn = maxRank and maxRank < 300 and skill >= maxRank - 25
  local rankNote = warn and ns.RANK_NOTES and ns.RANK_NOTES[prof] and ns.RANK_NOTES[prof][maxRank]
  local trainer
  if warn and not rankNote then
    local lvl = ns.RANK_LEVEL[maxRank]
    row.text = row.text .. "  |cffff9900" .. (lvl and ns.T("CR_TRAIN_LVL", lvl) or ns.T("CR_TRAIN")) .. "|r"
    -- Who teaches the next rank, for your faction (Journeyman at 50, Expert 125, Artisan 200).
    local who = ns.PROF_TRAINERS and ns.PROF_TRAINERS[prof] and ns.PROF_TRAINERS[prof][maxRank - 25]
    if who then trainer = ns.T("CR_TRAIN_AT", ns.Tx(who)) end
  end
  -- Orange when you're close to the cap and need to train, blue otherwise.
  row.bar = { value = skill, max = cap, color = warn and { 1, 0.6, 0.1 } or { 0.35, 0.75, 1 } }
  -- Secondary skills say exactly where the next rank is (a book or a quest).
  if rankNote then table.insert(out, { indent = 22, text = "|cffff9900" .. ns.Tx(rankNote) .. "|r" }) end
  if trainer then table.insert(out, { indent = 22, text = "|cffff9900" .. trainer .. "|r" }) end
  return skill
end

local function RouteSection(prof, out)
  local skill = Header(prof, out)
  if not skill then return end
  local s, nxt = StepFor(ns.ROUTES[prof], skill)
  if not s then return end
  local crafts = Remaining(s, skill)
  local what = s.batch and ns.T("CR_BATCH", crafts) or ns.T("CR_LEFT", crafts)
  local items, extra = {}, {}
  for _, m in ipairs(s.mats) do
    local id, per, fallback = m[1], m[2], m[3]
    local need = math.ceil(per * crafts)
    local have = ns.ItemCount(id)
    table.insert(items, { id = id, have = have, need = need, extra = ns.ItemName(id, fallback) })
    local bolt = ns.BOLTS and ns.BOLTS[id]
    if bolt and have < need then
      local rawNeed = (need - have) * bolt.ratio
      local rawHave = ns.ItemCount(bolt.raw)
      local c = rawHave >= rawNeed and "|cff60ff60" or "|cffaaaaaa"
      table.insert(extra, c .. ns.ItemName(id, fallback) .. " " .. ns.T("CR_EQUALS", rawNeed, bolt.name, rawHave) .. "|r")
    end
  end
  table.insert(out, { indent = 22, items = items,
    text = string.format("|cffffd100%d-%d:|r %s, %s", s.from, s.to, s.craft, what) })
  for _, e in ipairs(extra) do table.insert(out, { indent = 22, text = e }) end
  if s.note then table.insert(out, { indent = 22, text = "|cffaaaaaa" .. ns.Tx(s.note) .. "|r" }) end
  if s.untested then table.insert(out, { indent = 22, text = "|cff888888" .. ns.T("CR_UNTESTED") .. "|r" }) end
  if nxt then
    table.insert(out, { indent = 22, text = "|cff888888" .. ns.T("CR_THEN", nxt.from, nxt.to, nxt.craft) .. "|r" })
  end
end

---------------------------------------------------------------------------
-- Gathering
---------------------------------------------------------------------------
local function NodeSection(prof, out, nodes, zones)
  local skill = Header(prof, out)
  if not skill then return end
  local can, nextNode = {}, nil
  for _, n in ipairs(nodes) do
    if skill >= n[3] then table.insert(can, n)
    elseif not nextNode then nextNode = n end
  end
  local items, names = {}, {}
  for i = math.max(1, #can - 2), #can do
    table.insert(items, { id = can[i][1], extra = can[i][2] })
    table.insert(names, can[i][2])
  end
  table.insert(out, { indent = 22, items = items, text = "|cffaaaaaa" .. ns.T("HB_CAN", table.concat(names, ", ")) .. "|r" })
  if nextNode then
    table.insert(out, { indent = 22, text = "|cff888888" .. ns.T("HB_NEXT", nextNode[2], nextNode[3]) .. "|r" })
  end
  for _, z in ipairs(zones) do
    if skill < z.to then
      table.insert(out, { indent = 22, text = "|cffffd100" .. ns.T("GA_ZONES") .. "|r " .. ns.Tx(z.zones) })
      break
    end
  end
end

local function SkinSection(out)
  local skill = Header("Skinning", out)
  if not skill then return end
  table.insert(out, { indent = 22, text = "|cffaaaaaa" .. ns.T("SK_LEVEL", ns.SkinLevel(skill)) .. "|r" })
  local best
  for _, l in ipairs(ns.LEATHER) do if skill >= l[3] then best = l end end
  if best then
    table.insert(out, { indent = 22, items = { { id = best[1], extra = best[2] } },
      text = "|cff888888" .. ns.T("SK_LEATHER", best[2]) .. "|r" })
  end
  for _, z in ipairs(ns.SKIN_ZONES or {}) do
    if skill < z.to then
      table.insert(out, { indent = 22, text = "|cffffd100" .. ns.T("GA_ZONES") .. "|r " .. ns.Tx(z.zones) })
      break
    end
  end
end

local function FishSection(out)
  local skill = Header("Fishing", out)
  if not skill then return end
  for _, z in ipairs(ns.FISH_ZONES) do
    if skill < z.to then
      table.insert(out, { indent = 22, text = "|cffffd100" .. ns.T("GA_ZONES") .. "|r " .. ns.Tx(z.zones) })
      break
    end
  end
  for _, g in ipairs(ns.FISH_GEAR) do
    if skill < g.to then
      table.insert(out, { indent = 22, text = "|cffaaaaaa" .. ns.Tx(g.text) .. "|r" })
      break
    end
  end
end

local function Section(prof, out)
  if prof == "Fishing" then FishSection(out)
  elseif prof == "Herbalism" then NodeSection(prof, out, ns.HERBS, ns.HERB_ZONES)
  elseif prof == "Mining" then NodeSection(prof, out, ns.ORES, ns.MINING_ZONES)
  elseif prof == "Skinning" then SkinSection(out)
  elseif ns.ROUTES[prof] then RouteSection(prof, out) end
end

-- Materials in bags and bank that matter for your professions, as icons with counts.
local function MatsSummary(out)
  local groups = {}
  if ns.HasProf("Tailoring") then table.insert(groups, { ns.T("CR_CLOTH"), ns.CLOTH, 1, 2 }) end
  if ns.HasProf("Herbalism") or ns.HasProf("Alchemy") then table.insert(groups, { ns.T("CR_HERBS"), ns.HERBS, 1, 2 }) end
  if ns.HasProf("Mining") or ns.HasProf("Blacksmithing") or ns.HasProf("Engineering") then
    table.insert(groups, { ns.T("CR_ORES"), ns.ORES, 1, 2 })
  end
  if ns.HasProf("Skinning") or ns.HasProf("Leatherworking") then table.insert(groups, { ns.T("CR_LEATHER"), ns.LEATHER, 1, 2 }) end
  if #groups > 0 then table.insert(out, { gap = 4 }) end
  for _, g in ipairs(groups) do
    local items, names = {}, {}
    for _, e in ipairs(g[2]) do
      local n = ns.ItemCount(e[g[3]])
      if n > 0 then
        table.insert(items, { id = e[g[3]], count = n, extra = e[g[4]] })
        table.insert(names, e[g[4]] .. " " .. n)
      end
    end
    table.insert(out, { items = items, text = "|cffffffff" .. g[1] .. "|r" ..
      (#items == 0 and (" " .. ns.T("CR_NONE")) or "") , plain = table.concat(names, ", ") })
  end
  if #groups > 0 then table.insert(out, { text = "|cff888888" .. ns.T("CR_BANK") .. "|r" }) end
end

local function Build()
  local out = { { head = "|cff@COLOR@" .. ns.T("CR_TITLE") .. "|r" } }
  for i, prof in ipairs(ns.SelectedProfs()) do
    if i > 1 then table.insert(out, { gap = 6 }) end
    Section(prof, out)
  end
  -- Cooking, First Aid and Fishing: the ones you've learned (no profession slot).
  local shown, auto = ns.ShownSecondary()
  -- Nothing learned and nothing ticked: a hint, unless you've unticked them all.
  if ns.SECONDARY and (#shown > 0 or auto) then
    table.insert(out, { gap = 6 })
    table.insert(out, { head = "|cff@COLOR@" .. ns.T("CR_SECONDARY") .. "|r" })
    if #shown == 0 then
      table.insert(out, { text = "|cff888888" .. ns.T("CR_SECONDARY_NONE") .. "|r" })
    end
    for i, p in ipairs(shown) do
      if i > 1 then table.insert(out, { gap = 4 }) end
      Section(p, out)
      if not ns.GetProfSkill(p) then
        table.insert(out, { indent = 22, text = "|cffaaaaaa" .. ns.T("CR_SEC_LEARN", p) .. "|r" })
      end
    end
  end
  MatsSummary(out)
  return out
end

-- Plain text of the rows, for the tests.
local function PlainText(out)
  local lines = {}
  for _, e in ipairs(out) do
    if e.head then table.insert(lines, e.head)
    elseif e.text then
      local t = string.rep(" ", math.floor((e.indent or 0) / 10)) .. e.text
      local its = {}
      for _, it in ipairs(e.items or {}) do
        if it.need then table.insert(its, (it.extra or it.id) .. " " .. (it.have or 0) .. "/" .. it.need) end
      end
      if #its > 0 then t = t .. " [" .. table.concat(its, ", ") .. "]" end
      if e.plain and e.plain ~= "" then t = t .. " " .. e.plain end
      table.insert(lines, t)
    end
  end
  return table.concat(lines, "\n")
end

function ns.RefreshCraft()
  if not (win and win:IsShown()) then return end
  local out = Build()
  win.text:SetText(PlainText(out)) -- hidden; used by the tests
  win.render(out)
end

ns.RegisterModule(function()
  win = ns.MakeWindow("@ADDON@CraftFrame", 380, "craftPos", { "RIGHT", "RIGHT", -400, 120 })
  ns.UseRows(win, function() ns.RefreshCraft() end)
  win.closeButton:SetScript("OnClick", function()
    win:Hide()
    ns.db.craftShown = false
  end)
  ns.craftWindow = win
  ns.windows = ns.windows or {}
  table.insert(ns.windows, win)
  if ns.db.craftShown then win:Show() else win:Hide() end

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("BAG_UPDATE")
  ev:RegisterEvent("BANKFRAME_OPENED")
  ev:RegisterEvent("SKILL_LINES_CHANGED")
  ev:RegisterEvent("GET_ITEM_INFO_RECEIVED")
  ev:SetScript("OnEvent", function()
    ns.Debounce("craft", 1, ns.RefreshCraft)
  end)
  ns.RefreshCraft()
end)

ns.RegisterCommand("craft", true, function()
  if win:IsShown() then
    win:Hide(); ns.db.craftShown = false
  else
    win:Show(); ns.db.craftShown = true; ns.RefreshCraft()
  end
end)

ns.RegisterCommand("cooking", false, function() ns.ToggleSecondary("Cooking") end)
ns.RegisterCommand("firstaid", false, function() ns.ToggleSecondary("First Aid") end)
ns.RegisterCommand("fishing", false, function() ns.ToggleSecondary("Fishing") end)
