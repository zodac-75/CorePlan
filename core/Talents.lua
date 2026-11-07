-- @ADDON@: shows the next talent in the plan and marks it in the talent window.
local _, ns = ...

local TREES = ns.TALENT_TREES
local glow, hint

-- WoW Forever uses Blizzard's modern talent system (C_Traits, the PlayerSpellsFrame
-- window) with the three classic trees drawn side by side. Each talent is a node with a
-- position; we split the nodes into trees by their x position (biggest gaps) and into
-- rows by their y position.
local function ActiveConfig()
  if not (C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_Traits and C_Traits.GetConfigInfo) then return nil end
  local ok, configID = pcall(C_ClassTalents.GetActiveConfigID)
  if not ok or not configID then return nil end
  local okI, info = pcall(C_Traits.GetConfigInfo, configID)
  local treeIDs = okI and info and info.treeIDs
  if not treeIDs or not treeIDs[1] then return nil end
  return configID, treeIDs[1], treeIDs
end

local function TraitName(configID, nodeInfo)
  local entryID = (nodeInfo.activeEntry and nodeInfo.activeEntry.entryID) or (nodeInfo.entryIDs and nodeInfo.entryIDs[1])
  if not entryID then return nil end
  local okE, entry = pcall(C_Traits.GetEntryInfo, configID, entryID)
  if not okE or not entry or not entry.definitionID then return nil end
  local okD, def = pcall(C_Traits.GetDefinitionInfo, entry.definitionID)
  if not okD or not def then return nil end
  local spellID = def.spellID
  local name = def.overrideName
  if (not name or name == "") and spellID then
    if C_Spell and C_Spell.GetSpellName then
      local okN, n = pcall(C_Spell.GetSpellName, spellID); if okN then name = n end
    elseif GetSpellInfo then
      local okN, n = pcall(GetSpellInfo, spellID); if okN then name = n end
    end
  end
  local icon = def.overrideIcon
  if not icon and spellID then
    if C_Spell and C_Spell.GetSpellTexture then
      local okT, t = pcall(C_Spell.GetSpellTexture, spellID); if okT then icon = t end
    elseif GetSpellTexture then
      local okT, t = pcall(GetSpellTexture, spellID); if okT then icon = t end
    end
  end
  return name, icon
end

-- Splits sorted numbers into n groups at the n-1 biggest gaps; returns value -> group.
local function Cluster(values, n)
  table.sort(values)
  local gaps = {}
  for i = 2, #values do table.insert(gaps, { gap = values[i] - values[i - 1], at = i }) end
  table.sort(gaps, function(a, b) return a.gap > b.gap end)
  local cuts = {}
  for i = 1, math.min(n - 1, #gaps) do cuts[gaps[i].at] = true end
  local group, out = 1, {}
  for i, v in ipairs(values) do
    if cuts[i] then group = group + 1 end
    out[v] = group
  end
  return out
end

local function TraitMap()
  local configID, _, treeIDs = ActiveConfig()
  if not configID then return nil end
  -- One tree with all three side by side, or one tree each: both happen.
  local separate = #treeIDs > 1
  local list, xs, seenX = {}, {}, {}
  for treeIndex, treeID in ipairs(treeIDs) do
    local okN, nodes = pcall(C_Traits.GetTreeNodes, treeID)
    if okN and type(nodes) == "table" then
      for _, nodeID in ipairs(nodes) do
        local ok, info = pcall(C_Traits.GetNodeInfo, configID, nodeID)
        if ok and info and info.isVisible ~= false and info.posX and (info.maxRanks or 0) > 0 then
          local name, icon = TraitName(configID, info)
          if name then
            table.insert(list, { nodeID = nodeID, name = name, icon = icon, x = info.posX, y = info.posY or 0,
              rank = info.currentRank or info.ranksPurchased or 0, max = info.maxRanks,
              treeIndex = separate and treeIndex or nil })
            if not seenX[info.posX] then seenX[info.posX] = true; table.insert(xs, info.posX) end
          end
        end
      end
    end
  end
  if #list == 0 then return nil end
  local tabOf = Cluster(xs, math.max(1, #(TREES or {})))
  local ysByTab = {}
  for _, n in ipairs(list) do
    n.tab = n.treeIndex or tabOf[n.x] or 1
    ysByTab[n.tab] = ysByTab[n.tab] or {}
    ysByTab[n.tab][n.y] = true
  end
  local rowOf = {}
  for tab, set in pairs(ysByTab) do
    local ys = {}
    for y in pairs(set) do table.insert(ys, y) end
    table.sort(ys)
    rowOf[tab] = {}
    for i, y in ipairs(ys) do rowOf[tab][y] = i end
  end
  local map = {}
  for _, n in ipairs(list) do
    map[n.name] = { tab = n.tab, index = n.nodeID, nodeID = n.nodeID, tier = rowOf[n.tab][n.y], rank = n.rank,
      max = n.max, icon = n.icon }
  end
  return map
end

-- All talents: name -> {tab, index, tier, rank, max, icon, nodeID}
local cachedMap, cachedAt = nil, -10
local function TalentMap()
  if cachedMap and GetTime() - cachedAt < 0.5 then return cachedMap end
  local map = TraitMap()
  if map then cachedMap, cachedAt = map, GetTime(); return map end
  map = {}
  cachedMap, cachedAt = map, GetTime()
  if not (GetNumTalentTabs and GetNumTalents and GetTalentInfo) then return map end
  local okT, tabs = pcall(GetNumTalentTabs)
  if not okT or not tabs then return map end
  for tab = 1, tabs do
    local okN, n = pcall(GetNumTalents, tab)
    if okN and n then
      for i = 1, n do
        local ok, name, icon, tier, column, rank, maxRank = pcall(GetTalentInfo, tab, i)
        if ok and name then
          map[name] = { tab = tab, index = i, tier = tier, column = column, rank = rank or 0, max = maxRank,
            icon = icon ~= "" and icon ~= 0 and icon or nil }
        end
      end
    end
  end
  return map
end

-- Returns name, talent info, wanted rank; "done" when the plan is complete.
function ns.NextTalent()
  local map = TalentMap()
  if not next(map) then return nil end
  for lvl = 10, 60 do
    local entry = ns.talents[lvl]
    if entry then
      local name, want = entry:match("^(.-)%s+(%d+)/%d+$")
      want = tonumber(want)
      local t = name and map[name]
      if t and want and t.rank < want then
        return name, t, want
      end
    end
  end
  return "done"
end

-- Talent by name from the live tree (for its icon), or nil.
function ns.TalentInfo(name)
  return TalentMap()[name]
end

local function OpenTalents()
  if InCombatLockdown and InCombatLockdown() then return end
  if PlayerSpellsUtil and PlayerSpellsUtil.ToggleClassTalentFrame then pcall(PlayerSpellsUtil.ToggleClassTalentFrame)
  elseif ToggleTalentFrame then pcall(ToggleTalentFrame)
  elseif TalentFrame_LoadUI then pcall(TalentFrame_LoadUI); if PlayerTalentFrame then PlayerTalentFrame:Show() end end
end

local function Unspent()
  local configID, treeID = ActiveConfig()
  if configID and C_Traits.GetTreeCurrencyInfo then
    local ok, cur = pcall(C_Traits.GetTreeCurrencyInfo, configID, treeID, false)
    if ok and type(cur) == "table" and cur[1] and type(cur[1].quantity) == "number" then return cur[1].quantity end
  end
  if UnitCharacterPoints then
    local ok, p = pcall(UnitCharacterPoints, "player")
    if ok and type(p) == "number" then return p end
  end
  return nil
end

local function NextText()
  local name, t, want = ns.NextTalent()
  if not name then return nil end
  if name == "done" then
    local extra = ns.PlanDoneExtra and ns.PlanDoneExtra()
    return "|cffffd100" .. ns.T("PLAN_DONE") .. "|r" .. (extra and (" " .. extra) or "")
  end
  local tree = TREES[t.tab] or ns.T("TREE_N", t.tab)
  return "|cffffd100" .. ns.T("NEXT_TALENT") .. "|r " .. ns.T("NEXT_FMT", name, want, t.max or want, tree, t.tier or 0)
end

-- The talent window. WoW Forever has its own window with all three trees side by side,
-- so besides Blizzard's PlayerTalentFrame we look for any shown top-level frame with
-- "Talent" in its name, and find the talent's button by its icon.
local roots = {}

local function FindRoots()
  local found = {}
  if PlayerTalentFrame then found[PlayerTalentFrame] = true end
  if PlayerSpellsFrame then found[PlayerSpellsFrame] = true end
  if EnumerateFrames then
    local f = EnumerateFrames()
    while f do
      local ok, name = pcall(f.GetName, f)
      if ok and type(name) == "string" and name:find("Talent") and not name:find("^@ADDON@") then
        local okP, parent = pcall(f.GetParent, f)
        local okW, w = pcall(f.GetWidth, f)
        -- Only windows: skips micro buttons, alerts and other small frames.
        if okP and (parent == UIParent or parent == nil) and okW and type(w) == "number" and w >= 300
          and not name:find("Button") and not name:find("Dialog") then
          found[f] = true
        end
      end
      f = EnumerateFrames(f)
    end
  end
  return found
end

local function ShownRoot()
  for f in pairs(roots) do
    local ok, shown = pcall(f.IsShown, f)
    if ok and shown then return f end
  end
end

local function SameIcon(a, b)
  if a == nil or b == nil then return false end
  if a == b then return true end
  return tostring(a):lower():gsub("\\", "/") == tostring(b):lower():gsub("\\", "/")
end

-- The talent's icon both as the game gave it and as a file ID: a path and a number
-- mean the same picture, and a window may use either.
local probe
local function IconForms(icon)
  local forms = { icon }
  if icon and type(icon) == "string" then
    probe = probe or UIParent:CreateTexture(nil, "BACKGROUND")
    local ok = pcall(probe.SetTexture, probe, icon)
    if ok and probe.GetTextureFileID then
      local okF, id = pcall(probe.GetTextureFileID, probe)
      if okF and id then table.insert(forms, id) end
    end
  end
  return forms
end

local function TexMatches(tex, forms)
  for _, f in ipairs(forms) do if SameIcon(tex, f) then return true end end
  return false
end

-- A button some talent windows tag with the talent's place in the tree.
local function FieldsMatch(btn, t)
  if t.nodeID then
    local nodeID = rawget(btn, "nodeID")
    if nodeID then return nodeID == t.nodeID end
  end
  local tier = rawget(btn, "tier") or rawget(btn, "row")
  local col = rawget(btn, "column") or rawget(btn, "col")
  if tier and col and t.tier and t.column and tier == t.tier and col == t.column then
    local tab = rawget(btn, "tab") or rawget(btn, "talentTab") or rawget(btn, "tabIndex") or rawget(btn, "tree")
    return tab == nil or tab == t.tab
  end
  local idx = rawget(btn, "talentIndex")
  local tab = rawget(btn, "talentTab") or rawget(btn, "tabIndex")
  return idx ~= nil and idx == t.index and (tab == nil or tab == t.tab)
end

local function ButtonHasIcon(btn, forms)
  if btn.icon and type(btn.icon) == "table" and btn.icon.GetTexture and TexMatches(btn.icon:GetTexture(), forms) then
    return true
  end
  local regions = { btn:GetRegions() }
  for _, r in ipairs(regions) do
    if r.GetTexture and r:IsObjectType("Texture") then
      local ok, tex = pcall(r.GetTexture, r)
      if ok and TexMatches(tex, forms) then return true end
      if r.GetTextureFileID then
        local okF, id = pcall(r.GetTextureFileID, r)
        if okF and TexMatches(id, forms) then return true end
      end
    end
  end
  return false
end

-- Walks the window looking for the shown button that shows the talent's icon.
local function FindButton(root, t)
  local old = (root == PlayerTalentFrame) and _G["PlayerTalentFrameTalent" .. t.index]
  if old and old:IsShown() then return old end
  -- The modern window can give us the button for a node directly.
  local tf = rawget(root, "TalentsFrame") or root
  if t.nodeID and tf.GetTalentButtonByNodeID then
    local ok, btn = pcall(tf.GetTalentButtonByNodeID, tf, t.nodeID)
    if ok and btn then return btn end
  end
  local forms = IconForms(t.icon)
  local function walk(f, depth)
    if depth > 10 then return nil end
    for _, c in ipairs({ f:GetChildren() }) do
      local okS, shown = pcall(c.IsShown, c)
      if okS and shown then
        -- One odd frame must not stop the search.
        local okF, byFields = pcall(FieldsMatch, c, t)
        if okF and byFields then return c end
        if t.icon then
          local okI, isIt = pcall(ButtonHasIcon, c, forms)
          if okI and isIt then return c end
        end
        local hit = walk(c, depth + 1)
        if hit then return hit end
      end
    end
  end
  local ok, btn = pcall(walk, root, 0)
  return ok and btn or nil
end

local function HideGlow()
  if glow then glow:Hide(); glow.btn = nil end
end

local function UpdateGlow()
  if not glow then return end
  local root = ShownRoot()
  if not root then
    HideGlow()
    if hint then hint:Hide() end
    return
  end

  local line = NextText()
  if hint and line then
    hint:SetParent(root)
    hint:ClearAllPoints()
    -- Inside the window at the bottom, so it can't end up above the top of the screen.
    hint:SetPoint("BOTTOMLEFT", root, "BOTTOMLEFT", 24, 14)
    hint:SetDrawLayer("OVERLAY", 7)
    hint:SetText("@ADDON@: " .. line:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
    hint:Show()
  end

  local name, t = ns.NextTalent()
  if not t or name == "done" then HideGlow(); return end
  if root == PlayerTalentFrame then
    local sel
    if PanelTemplates_GetSelectedTab then
      local ok, s = pcall(PanelTemplates_GetSelectedTab, PlayerTalentFrame)
      if ok then sel = s end
    end
    sel = sel or PlayerTalentFrame.selectedTab
    if sel and sel ~= t.tab then HideGlow(); return end
  end

  local btn = FindButton(root, t)
  if not btn or not btn:IsVisible() then HideGlow(); return end
  if glow.btn == btn and glow:IsShown() then return end -- already there: don't restart the animation
  glow.btn = btn
  glow:SetParent(btn)
  glow:ClearAllPoints()
  glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -5, 5)
  glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 5, -5)
  glow:SetFrameStrata("DIALOG")
  glow:SetFrameLevel(btn:GetFrameLevel() + 5)
  glow:Show()
end

local function HookRoot(f)
  if roots[f] then return end
  roots[f] = true
  pcall(f.HookScript, f, "OnShow", function() C_Timer.After(0.1, function() pcall(UpdateGlow) end) end)
  pcall(f.HookScript, f, "OnHide", function() HideGlow() if hint then hint:Hide() end end)
end

local function ScanRoots()
  for f in pairs(FindRoots()) do HookRoot(f) end
  pcall(UpdateGlow) -- the window may already be open
end

local function SetupTalentUI()
  if glow then return end
  -- The marker: a thick green frame around the talent that pulses, and a big green
  -- arrow above it that bobs up and down.
  glow = CreateFrame("Frame", nil, UIParent)
  local G = { 0.25, 1, 0.35 }
  local border = CreateFrame("Frame", nil, glow)
  border:SetAllPoints()
  local function Edge(p1, p2, w, h)
    local e = border:CreateTexture(nil, "OVERLAY")
    e:SetColorTexture(G[1], G[2], G[3], 1)
    e:SetPoint(p1); e:SetPoint(p2)
    if w then e:SetWidth(w) end
    if h then e:SetHeight(h) end
  end
  Edge("TOPLEFT", "TOPRIGHT", nil, 3)
  Edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 3)
  Edge("TOPLEFT", "BOTTOMLEFT", 3, nil)
  Edge("TOPRIGHT", "BOTTOMRIGHT", 3, nil)
  local shine = border:CreateTexture(nil, "ARTWORK")
  shine:SetAllPoints()
  shine:SetColorTexture(G[1], G[2], G[3], 0.18)
  local pulse = border:CreateAnimationGroup()
  local a = pulse:CreateAnimation("Alpha")
  a:SetFromAlpha(1)
  a:SetToAlpha(0.45)
  a:SetDuration(0.7)
  pulse:SetLooping("BOUNCE")
  pulse:Play()

  -- The waypoint arrow from Media, turned to point down at the talent.
  local plus = glow:CreateTexture(nil, "OVERLAY")
  plus:SetTexture(ns.MEDIA .. "Arrow")
  plus:SetSize(34, 34)
  plus:SetRotation(math.pi)
  plus:SetVertexColor(G[1], G[2], G[3])
  plus:SetPoint("BOTTOM", glow, "TOP", 0, 0)
  local bob = plus:CreateAnimationGroup() -- only the plus moves
  local m = bob:CreateAnimation("Translation")
  m:SetOffset(0, 7)
  m:SetDuration(0.5)
  m:SetSmoothing("IN_OUT")
  bob:SetLooping("BOUNCE")
  glow:SetScript("OnShow", function() bob:Play(); pulse:Play() end)
  glow:Hide()

  hint = UIParent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  hint:Hide()

  if PlayerTalentFrame_Update then hooksecurefunc("PlayerTalentFrame_Update", function() pcall(UpdateGlow) end) end
  if PanelTemplates_SetTab then
    hooksecurefunc("PanelTemplates_SetTab", function(f)
      if roots[f] then C_Timer.After(0.05, function() pcall(UpdateGlow) end) end
    end)
  end
  pcall(ScanRoots)

  -- While a talent window is open, keep the glow on the right button: the modern
  -- window rebuilds its buttons when you click, search or switch loadouts.
  local acc = 0
  local ticker = CreateFrame("Frame")
  ticker:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 1 then return end
    acc = 0
    if ShownRoot() then pcall(UpdateGlow) end
  end)
end

-- /@SLASH@ talentui: what the addon found, for when the glow doesn't show.
local function DebugTalentUI()
  pcall(ScanRoots)
  local names = {}
  for f in pairs(roots) do
    local ok, n = pcall(f.GetName, f)
    local okS, shown = pcall(f.IsShown, f)
    table.insert(names, tostring(ok and n or "?") .. (okS and shown and " (open)" or ""))
  end
  ns.Print("talent windows: " .. (#names > 0 and table.concat(names, ", ") or "none"))
  local name, t = ns.NextTalent()
  ns.Print("next talent: " .. tostring(name) .. (t and (" tab " .. t.tab .. " #" .. t.index .. " icon " .. tostring(t.icon)) or ""))
  if t then ns.Print("  tier " .. tostring(t.tier) .. " column " .. tostring(t.column)) end
  local root = ShownRoot()
  ns.Print("open window: " .. tostring(root and (root:GetName() or "no name") or "none") ..
    "  PlayerSpellsFrame: " .. tostring(PlayerSpellsFrame ~= nil) ..
    (PlayerSpellsFrame and ("/" .. tostring(PlayerSpellsFrame:IsShown())) or ""))
  if root and t then
    local tf = rawget(root, "TalentsFrame")
    ns.Print("  TalentsFrame: " .. tostring(tf ~= nil) .. "  by node: " ..
      tostring(tf and tf.GetTalentButtonByNodeID ~= nil) .. "  nodeID: " .. tostring(t.nodeID))
    local btn = FindButton(root, t)
    ns.Print("button: " .. (btn and tostring(btn:GetName() or "found (no name)") or "not found"))
  else
    ns.Print("open the talent window and run this again.")
  end
  local ok, err = pcall(UpdateGlow)
  ns.Print("glow: " .. (ok and "ok" or ("error " .. tostring(err))) .. "  shown: " ..
    tostring(glow and glow:IsShown()) .. "  hint: " .. tostring(hint and hint:IsShown()))
  -- What's under the mouse: hover a talent in the window while you type the command.
  local focus
  if GetMouseFoci then
    local ok, list = pcall(GetMouseFoci)
    focus = ok and type(list) == "table" and list[1]
  elseif GetMouseFocus then
    local ok, f = pcall(GetMouseFocus)
    focus = ok and f
  end
  if focus and focus ~= WorldFrame then
    local chain, f = {}, focus
    for _ = 1, 6 do
      if not f then break end
      local ok, n = pcall(f.GetName, f)
      table.insert(chain, tostring(ok and n or "?"))
      local okP, p = pcall(f.GetParent, f)
      f = okP and p or nil
    end
    ns.Print("under mouse: " .. table.concat(chain, " < "))
    local fields = {}
    for k, v in pairs(focus) do
      if type(k) == "string" and (type(v) == "number" or type(v) == "string" or type(v) == "boolean") then
        table.insert(fields, k .. "=" .. tostring(v))
      end
    end
    table.sort(fields)
    ns.Print("  fields: " .. (#fields > 0 and table.concat(fields, ", ", 1, math.min(#fields, 25)) or "none"))
    local texs = {}
    for _, r in ipairs({ focus:GetRegions() }) do
      if r.IsObjectType and r:IsObjectType("Texture") then
        local ok, tex = pcall(r.GetTexture, r)
        if ok and tex then table.insert(texs, tostring(tex)) end
      end
    end
    ns.Print("  textures: " .. (#texs > 0 and table.concat(texs, ", ", 1, math.min(#texs, 6)) or "none"))
  end
end
ns.RegisterCommand("talentui", false, DebugTalentUI)

function ns.RefreshTalentGlow() pcall(UpdateGlow) end

local function OnPointsChanged()
  cachedMap = nil
  ns.RefreshMain()
  pcall(UpdateGlow)
end

ns.RegisterModule(function()
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("ADDON_LOADED")
  ev:RegisterEvent("CHARACTER_POINTS_CHANGED")
  -- The modern talent system: points spent, staged or applied.
  for _, e in ipairs({ "TRAIT_CONFIG_UPDATED", "TRAIT_NODE_CHANGED", "TRAIT_TREE_CURRENCY_INFO_UPDATED" }) do
    pcall(ev.RegisterEvent, ev, e)
  end
  ev:RegisterEvent("PLAYER_LEVEL_UP")
  ev:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
      if type(arg1) == "string" and (arg1:find("Talent") or arg1:find("PlayerSpells")) then
        pcall(SetupTalentUI)
        C_Timer.After(0.5, function() pcall(ScanRoots) end)
      end
    else
      ns.Debounce("talents", 0.3, OnPointsChanged)
    end
  end)
  pcall(SetupTalentUI)
  -- Windows made after login (Forever's talent window can be one) are found a bit later,
  -- and again whenever the talent key may have created a new window.
  C_Timer.After(3, function() pcall(ScanRoots) end)
  if ToggleTalentFrame then
    hooksecurefunc("ToggleTalentFrame", function()
      C_Timer.After(0.1, function() pcall(ScanRoots); pcall(UpdateGlow) end)
    end)
  end

  ns.AddStatusProvider(function()
    local line = NextText()
    if not line then return nil end
    local name, t = ns.NextTalent()
    local icon = (t and t.icon) or "Interface\\Icons\\Ability_Marksmanship"
    local u = Unspent()
    if u and u > 0 and name ~= "done" then
      -- A point to spend goes under "Do this now"; clicking opens the talent window.
      return { action = true, icon = icon, click = OpenTalents, tip = ns.T("PW_CLICK_TALENT"),
        text = line .. " |cff60ff60" .. ns.T("POINTS_TO_SPEND", u) .. "|r" }
    end
    return { icon = icon, text = line, click = OpenTalents, tip = ns.T("PW_CLICK_TALENT") }
  end)

  C_Timer.After(5, function()
    local u = Unspent()
    local line = NextText()
    if u and u > 0 and line then
      ns.Print(ns.T("LOGIN_POINTS", u, line))
    end
  end)
end)
