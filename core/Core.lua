-- @ADDON@: core. Main window, helpers, commands and modules.
local ADDON, ns = ...

local LOOKAHEAD = 3 -- hur många levels framåt som visas

ns.modules = {}
ns.commands = {}
ns.helpLines = {}
ns.MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\Media\\"

local frame, text
local db

---------------------------------------------------------------------------
-- Hjälpfunktioner (med fallback mellan gamla och nya API:er)
---------------------------------------------------------------------------
function ns.Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff@COLOR@@ADDON@:|r " .. tostring(msg))
end
local Print = ns.Print

function ns.RegisterModule(fn) table.insert(ns.modules, fn) end

function ns.RegisterCommand(cmd, help, fn)
  ns.commands[cmd] = fn
  if help then table.insert(ns.helpLines, cmd) end
end

-- Returnerar namn och spellID för en spell (namn eller ID), eller nil om okänd.
function ns.SpellInfo(spell)
  if spell == nil then return nil end
  if C_Spell and C_Spell.GetSpellInfo then
    local ok, info = pcall(C_Spell.GetSpellInfo, spell)
    if ok and type(info) == "table" and info.name then return info.name, info.spellID end
  end
  if GetSpellInfo then
    local ok, name, _, _, _, _, _, id = pcall(GetSpellInfo, spell)
    if ok and name then return name, id end
  end
  return nil
end

function ns.SpellCooldown(spell)
  if C_Spell and C_Spell.GetSpellCooldown then
    local ok, info = pcall(C_Spell.GetSpellCooldown, spell)
    if ok and type(info) == "table" then return info.startTime or 0, info.duration or 0 end
  end
  if GetSpellCooldown then
    local ok, s, d = pcall(GetSpellCooldown, spell)
    if ok and s then return s, d end
  end
  return 0, 0
end

-- Sekunder kvar på cooldown (GCD räknas som redo). 0 om redo eller okänt.
function ns.CooldownLeft(spell)
  local ok, left = pcall(function()
    local s, d = ns.SpellCooldown(spell)
    if s == 0 or d <= 1.6 then return 0 end
    return math.max(0, s + d - GetTime())
  end)
  return (ok and left) or 0
end

function ns.ItemInfo(item)
  local f = (C_Item and C_Item.GetItemInfo) or GetItemInfo
  if not f then return nil end
  return f(item)
end

function ns.ItemName(id, fallback)
  local ok, name = pcall(ns.ItemInfo, id)
  if ok and name then return name end
  return fallback or ("item " .. tostring(id))
end

function ns.ItemCount(id)
  local f = (C_Item and C_Item.GetItemCount) or GetItemCount
  if not f then return 0 end
  local ok, n = pcall(f, id, true) -- true = räkna med banken
  return (ok and n) or 0
end

-- Går igenom auras; fn(name, spellId) returnerar true för att stoppa.
-- Returnerar true om fn någon gång returnerade true.
-- Calls fn(name, spellId) for each aura until it returns true. Returns found, unsure:
-- unsure is true when some aura couldn't be read (the game can hide aura names from
-- addons in combat), so "not found" doesn't prove it's missing.
function ns.ForEachAura(unit, filter, fn)
  local unsure = false
  for i = 1, 40 do
    local name, spellId
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, unit, i, filter)
      if not ok then return false, true end
      if not a then return false, unsure end
      name, spellId = a.name, a.spellId
    elseif UnitAura then
      local ok, n, _, _, _, _, _, _, _, _, id = pcall(UnitAura, unit, i, filter)
      if not ok then return false, true end
      if not n then return false, unsure end
      name, spellId = n, id
    else
      return false, true
    end
    if issecretvalue and issecretvalue(name) then
      unsure = true
    else
      local ok2, stop = pcall(fn, name, spellId)
      if not ok2 then unsure = true elseif stop then return true end
    end
  end
  return false, unsure
end

-- Has the unit this aura? true, false, or nil when we can't tell.
function ns.AuraByName(unit, filter, name)
  if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
    local ok, a = pcall(C_UnitAuras.GetAuraDataBySpellName, unit, name, filter)
    if ok and a then return true end
  end
  local found, unsure = ns.ForEachAura(unit, filter, function(n) return n == name end)
  if found then return true end
  if unsure then return nil end
  return false
end

-- True only when none of the auras is there for sure. Reminders use this, so they
-- stay quiet instead of nagging when the game hides the aura list.
function ns.AuraMissing(unit, filter, ...)
  for i = 1, select("#", ...) do
    if ns.AuraByName(unit, filter, (select(i, ...))) ~= false then return false end
  end
  return true
end

-- Same, for auras whose name starts with one of the prefixes ("Seal of ").
function ns.AuraMissingLike(unit, filter, ...)
  local prefixes = { ... }
  local found, unsure = ns.ForEachAura(unit, filter, function(n)
    for _, p in ipairs(prefixes) do
      if n:find(p, 1, true) == 1 then return true end
    end
  end)
  return not found and not unsure
end

-- Yrkesskill: returnerar rank, maxRank (eller nil om yrket saknas).
-- Profession skill: returns rank, maxRank (or nil if unknown).
-- Tries several sources, because clients differ:
--   1. GetProfessions/GetProfessionInfo (newer clients)
--   2. GetSkillLineInfo (classic skill list; misses skills under a collapsed header)
--   3. The last value seen in the profession window or a "skill increased" message
local function FromProfessionsAPI(profName)
  if type(GetProfessions) ~= "function" or type(GetProfessionInfo) ~= "function" then return nil end
  local ok, a, b, c, d, e = pcall(GetProfessions)
  if not ok then return nil end
  for _, idx in ipairs({ a or false, b or false, c or false, d or false, e or false }) do
    if idx then
      local okI, name, _, rank, maxRank = pcall(GetProfessionInfo, idx)
      if okI and name == profName and type(rank) == "number" then return rank, maxRank end
    end
  end
  return nil
end

local function FromSkillLines(profName)
  if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then return nil end
  local ok, n = pcall(GetNumSkillLines)
  if not ok or not n then return nil end
  for i = 1, n do
    local okLine, skillName, isHeader, _, rank, _, _, maxRank = pcall(GetSkillLineInfo, i)
    if okLine and not isHeader and skillName == profName and type(rank) == "number" then
      return rank, maxRank
    end
  end
  return nil
end

function ns.RememberProf(profName, rank, maxRank)
  if not (ns.db and profName and type(rank) == "number") then return end
  ns.db.profCache = ns.db.profCache or {}
  local old = ns.db.profCache[profName] or {}
  ns.db.profCache[profName] = { rank = rank, max = maxRank or old.max }
end

function ns.GetProfSkill(profName)
  local rank, maxRank = FromProfessionsAPI(profName)
  if not rank then rank, maxRank = FromSkillLines(profName) end
  if rank then
    ns.RememberProf(profName, rank, maxRank)
    return rank, maxRank
  end
  local c = ns.db and ns.db.profCache and ns.db.profCache[profName]
  if c then return c.rank, c.max end
  return nil
end

-- Reads "name, rank, max" from whatever the open profession window reports.
local function ReadOpenProfession()
  local function take(...)
    local name, nums = nil, {}
    for i = 1, select("#", ...) do
      local v = select(i, ...)
      if type(v) == "string" and not name then name = v
      elseif type(v) == "number" and name then table.insert(nums, v) end
    end
    if name and nums[1] and nums[1] > 0 then ns.RememberProf(name, nums[1], nums[2]) end
  end
  if C_TradeSkillUI and C_TradeSkillUI.GetTradeSkillLine then pcall(function() take(C_TradeSkillUI.GetTradeSkillLine()) end) end
  if GetTradeSkillLine then pcall(function() take(GetTradeSkillLine()) end) end
  if GetCraftDisplaySkillLine then pcall(function() take(GetCraftDisplaySkillLine()) end) end
end

local profEvents = CreateFrame("Frame")
for _, e in ipairs({ "TRADE_SKILL_SHOW", "TRADE_SKILL_UPDATE", "CRAFT_SHOW", "CRAFT_UPDATE", "CHAT_MSG_SKILL" }) do
  pcall(profEvents.RegisterEvent, profEvents, e)
end
profEvents:SetScript("OnEvent", function(_, event, msg)
  if not ns.db then return end
  if event == "CHAT_MSG_SKILL" then
    local name, rank = (msg or ""):match("Your skill in (.+) has increased to (%d+)")
    if name then ns.RememberProf(name, tonumber(rank)) end
    local learned = (msg or ""):match("You have gained the (.+) skill")
    if learned and not (ns.db.profCache and ns.db.profCache[learned]) then ns.RememberProf(learned, 1) end
  else
    ReadOpenProfession()
  end
  ns.Debounce("main", 0.5, ns.RefreshMain)
  if ns.RefreshCraft then ns.Debounce("craft", 0.5, ns.RefreshCraft) end
end)

local pending = {}
function ns.Debounce(key, delay, fn)
  if pending[key] then return end
  pending[key] = true
  C_Timer.After(delay, function()
    pending[key] = nil
    local ok, err = pcall(fn)
    if not ok then Print(ns.T("ERROR_IN", key, tostring(err))) end
  end)
end

function ns.Money(c)
  if not c then return "?" end
  c = math.floor(c + 0.5)
  local g, s, cc = math.floor(c / 10000), math.floor((c % 10000) / 100), c % 100
  if g > 0 then return string.format("%dg %ds", g, s) end
  if s > 0 then return string.format("%ds %dc", s, cc) end
  return cc .. "c"
end

---------------------------------------------------------------------------
-- Teman och textstorlek
---------------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8X8"
ns.THEMES = {
  { key = "dark",    name = "Dark",         bg = WHITE, edge = WHITE, edgeSize = 1, inset = 1,
    bgColor = { 0.05, 0.05, 0.06, 0.94 }, border = { 0.25, 0.25, 0.28, 1 } },
  { key = "frost",   name = "Frost",        bg = WHITE, edge = WHITE, edgeSize = 1, inset = 1,
    -- The class theme: colors from ns.THEME_BG / ns.THEME_BORDER in the class Data.lua.
    bgColor = ns.THEME_BG or { 0.03, 0.07, 0.12, 0.92 }, border = ns.THEME_BORDER or { 0.35, 0.65, 0.95, 0.9 } },
  { key = "classic", name = "Classic",      bg = "Interface\\Tooltips\\UI-Tooltip-Background",
    edge = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14, inset = 3, tile = true,
    bgColor = { 0, 0, 0, 0.75 }, border = { 1, 1, 1, 1 } },
  { key = "glass",   name = "Transparent",  bg = WHITE, edgeSize = 0, inset = 0,
    bgColor = { 0, 0, 0, 0.45 } },
}
ns.FONTS = {
  { key = "small",  name = "Liten",  font = "GameFontHighlightSmall" },
  { key = "normal", name = "Normal", font = "GameFontHighlight" },
  { key = "large",  name = "Stor",   font = "GameFontHighlightLarge" },
}
ns.themedFrames = {}
ns.textWindows = {}

local function FindByKey(list, key)
  for i, t in ipairs(list) do if t.key == key then return t, i end end
  return list[1], 1
end

function ns.CurrentTheme() return FindByKey(ns.THEMES, ns.db.theme or "dark") end
function ns.CurrentFont() return FindByKey(ns.FONTS, ns.db.fontSize or "small") end

function ns.ApplyTheme(f)
  if not f.SetBackdrop then return end
  local t = ns.CurrentTheme()
  f:SetBackdrop({
    bgFile = t.bg,
    edgeFile = t.edge,
    tile = t.tile or false, tileSize = 16, edgeSize = t.edgeSize,
    insets = { left = t.inset, right = t.inset, top = t.inset, bottom = t.inset },
  })
  f:SetBackdropColor(unpack(t.bgColor))
  if t.border and t.edge then f:SetBackdropBorderColor(unpack(t.border)) end
end

function ns.ApplyThemeAll()
  for _, f in ipairs(ns.themedFrames) do ns.ApplyTheme(f) end
end

function ns.ApplyFontAll()
  local font = ns.CurrentFont().font
  for _, f in ipairs(ns.textWindows) do
    if _G[font] then f.text:SetFontObject(_G[font]) end
    f:SetContent(f.text:GetText() or "")
  end
end

function ns.CycleTheme()
  local _, i = ns.CurrentTheme()
  ns.db.theme = ns.THEMES[(i % #ns.THEMES) + 1].key
  ns.ApplyThemeAll()
  ns.Print(ns.T("THEME_SET", ns.T("THEME_" .. ns.CurrentTheme().key)))
end

function ns.CycleFontSize()
  local _, i = ns.CurrentFont()
  ns.db.fontSize = ns.FONTS[(i % #ns.FONTS) + 1].key
  ns.ApplyFontAll()
  ns.Print(ns.T("FONT_SET", ns.T("FONT_" .. ns.CurrentFont().key)))
end

-- Gemensam stil för fönster: tema, flyttbart, ändringsbar bredd och skala.
function ns.MakeWindow(name, width, posKey, defaultPoint)
  local f = CreateFrame("Frame", name, UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  f:SetWidth(ns.db[posKey .. "W"] or width)
  f:SetHeight(60)
  f:SetScale(ns.db[posKey .. "S"] or 1)
  f:SetFrameStrata("MEDIUM")
  f:SetClampedToScreen(true)
  table.insert(ns.themedFrames, f)
  table.insert(ns.textWindows, f)
  ns.ApplyTheme(f)
  local p = ns.db[posKey]
  if p then
    f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else
    f:SetPoint(defaultPoint[1], UIParent, defaultPoint[2], defaultPoint[3], defaultPoint[4])
  end
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self)
    if not ns.db.locked then self:StartMoving() end
  end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db[posKey] = { point, relPoint, x, y }
  end)
  f.defaultPoint = defaultPoint
  f.posKey = posKey

  local t = f:CreateFontString(nil, "OVERLAY", ns.CurrentFont().font)
  t:SetPoint("TOPLEFT", 10, -10)
  t:SetWidth(f:GetWidth() - 20)
  t:SetJustifyH("LEFT")
  t:SetJustifyV("TOP")
  f.text = t

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", 2, 2)
  close:SetScale(0.7)
  f.closeButton = close

  function f:SetContent(str)
    self.text:SetWidth(self:GetWidth() - 20)
    self.text:SetText(str)
    self:SetHeight(self.text:GetStringHeight() + 22)
  end

  -- Bredd: dra i hörnet nere till höger. Höjden följer innehållet.
  f:SetResizable(true)
  if f.SetResizeBounds then
    f:SetResizeBounds(220, 40, 900, 2000)
  elseif f.SetMinResize then
    f:SetMinResize(220, 40)
    f:SetMaxResize(900, 2000)
  end
  local grip = CreateFrame("Button", nil, f)
  grip:SetSize(14, 14)
  grip:SetPoint("BOTTOMRIGHT", -2, 2)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function()
    if not ns.db.locked then f:StartSizing("RIGHT") end
  end)
  grip:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing()
    ns.db[posKey .. "W"] = f:GetWidth()
    local point, _, relPoint, x, y = f:GetPoint()
    ns.db[posKey] = { point, relPoint, x, y }
    f:SetContent(f.text:GetText() or "")
  end)
  f.grip = grip
  f:SetScript("OnSizeChanged", function(self, w)
    if self.inSize then return end
    self.inSize = true
    self.text:SetWidth((w or self:GetWidth()) - 20)
    self:SetHeight(self.text:GetStringHeight() + 22)
    self.inSize = false
  end)

  -- Skala: Ctrl + mushjul över fönstret.
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not IsControlKeyDown() or ns.db.locked then return end
    local s = math.max(0.6, math.min(1.8, self:GetScale() + delta * 0.05))
    self:SetScale(s)
    ns.db[posKey .. "S"] = s
  end)
  return f
end

function ns.ResetWindow(f)
  ns.db[f.posKey] = nil
  ns.db[f.posKey .. "W"] = nil
  ns.db[f.posKey .. "S"] = nil
  f:SetScale(1)
  f:ClearAllPoints()
  local d = f.defaultPoint
  f:SetPoint(d[1], UIParent, d[2], d[3], d[4])
end

---------------------------------------------------------------------------
-- Huvudfönstret
---------------------------------------------------------------------------
-- Spells in the list that you haven't learned yet.
function ns.Unlearned(list)
  local out = {}
  for _, name in ipairs(list or {}) do
    if not ns.SpellInfo(name) then table.insert(out, name) end
  end
  return out
end

-- Plan entries for a level, without the ones for professions you don't have.
function ns.VisibleGear(level)
  local g = ns.gear[level]
  if not g then return nil end
  local out = {}
  for _, item in ipairs(g) do
    if not ns.GearVisible or ns.GearVisible(item) then table.insert(out, item) end
  end
  return #out > 0 and out or nil
end

-- Skill you want in your professions at a character level, and what to do about it.
local PROF_GOALS = {
  { level = 10, skill = 50, train = 50, rank = "Journeyman" },
  { level = 20, skill = 125, train = 125, rank = "Expert" },
  { level = 35, skill = 200, train = 200, rank = "Artisan" },
  { level = 50, skill = 260 },
  { level = 58, skill = 300 },
}

-- Your skill against the goal for your level: text, and true when you're behind.
function ns.ProfGoalLine(prof, level)
  local target
  for _, t in ipairs(PROF_GOALS) do
    if level >= t.level then target = t end
  end
  if not target then return nil end
  local rank, maxRank = ns.GetProfSkill(prof)
  if not rank then return nil end
  if rank < target.skill then
    local note
    if target.train and (not maxRank or maxRank <= target.train + 25) then
      local who = ns.PROF_TRAINERS and ns.PROF_TRAINERS[prof] and ns.PROF_TRAINERS[prof][target.train]
      note = ns.T("GOAL_TRAIN", target.rank, who or "?")
    else
      note = ns.T("GOAL_PACE")
    end
    return "|cffff6060" .. ns.T("GOAL_BEHIND", prof, rank, target.skill) .. "|r - " .. note, true
  end
  return string.format("|cff60ff60%s %d|r ", prof, rank) .. ns.T("GOAL_DONE", target.skill), false
end

---------------------------------------------------------------------------
-- The plan window: "Do this now" with clickable rows, then short info lines, this
-- level's notes and a "Coming up" section you can open and close.
-- Status providers (ns.AddStatusProvider) return either a text line (info) or a row:
--   { text = "...", icon = texture, spells = { "Name", ... }, click = fn, tip = "...",
--     action = true }  -- action rows go under "Do this now"
---------------------------------------------------------------------------
local ICON = {
  train = "Interface\\Icons\\INV_Misc_Book_09",
  gear = "Interface\\Icons\\INV_Misc_Bag_08",
  talent = "Interface\\Icons\\Ability_Marksmanship",
  done = "Interface\\RaidFrame\\ReadyCheck-Ready",
}
local PROF_ICON = {
  Alchemy = "Interface\\Icons\\Trade_Alchemy", Blacksmithing = "Interface\\Icons\\Trade_BlackSmithing",
  Enchanting = "Interface\\Icons\\Trade_Engraving", Engineering = "Interface\\Icons\\Trade_Engineering",
  Herbalism = "Interface\\Icons\\Spell_Nature_NatureTouchGrow", Leatherworking = "Interface\\Icons\\INV_Misc_ArmorKit_17",
  Mining = "Interface\\Icons\\Trade_Mining", Skinning = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
  Tailoring = "Interface\\Icons\\Trade_Tailoring",
}

function ns.RunCommand(cmd, rest)
  local fn = ns.commands[cmd]
  if not fn then return end
  local ok, err = pcall(fn, rest)
  if not ok then Print(ns.T("ERROR", tostring(err))) end
end

-- Icon for a spell you know (nil for spells you haven't learned).
function ns.SpellIcon(name)
  local tex
  if C_Spell and C_Spell.GetSpellTexture then
    local ok, t = pcall(C_Spell.GetSpellTexture, name)
    if ok then tex = t end
  end
  if not tex and GetSpellTexture then
    local ok, t = pcall(GetSpellTexture, name)
    if ok then tex = t end
  end
  if issecretvalue and issecretvalue(tex) then return nil end
  return tex
end

local function Untrained(level)
  local out = {}
  for lvl = 1, level do
    for _, name in ipairs(ns.Unlearned(ns.spells[lvl])) do table.insert(out, name) end
  end
  return out
end

local function TalentRow(level)
  local t = ns.talents[level]
  if not t then return nil end
  local name = t:match("^(.-) %d+/%d+$") or t
  local info = ns.TalentInfo and ns.TalentInfo(name)
  return { icon = (info and info.icon) or ICON.talent, text = "|cffffd100" .. ns.T("L_TALENT") .. "|r " .. t }
end

local function ComingUp(level)
  local levels = {}
  for i = 1, LOOKAHEAD do
    local l = level + i
    if l <= 60 then
      local rows = {}
      local tr = TalentRow(l)
      if tr then table.insert(rows, tr) end
      if ns.spells[l] then
        table.insert(rows, { icon = ICON.train, spells = ns.spells[l],
          text = "|cff9d9dff" .. ns.T("L_TRAIN") .. "|r " .. table.concat(ns.spells[l], ", ") })
      end
      for _, item in ipairs(ns.VisibleGear(l) or {}) do
        table.insert(rows, { icon = ICON.gear, text = "|cff1eff00" .. ns.T("L_CRAFT") .. "|r " .. ns.Tx(item) })
      end
      if #rows > 0 then table.insert(levels, { level = l, rows = rows }) end
    end
  end
  return levels
end

local function BuildModel()
  local level = UnitLevel("player") or 1
  local m = { actions = {}, info = {}, now = {}, coming = ComingUp(level), level = level }

  if ns.statusProviders then
    for _, p in ipairs(ns.statusProviders) do
      local ok, r = pcall(p.fn)
      if ok and r then
        if type(r) == "string" then r = { text = r, icon = p.icon } end
        r.icon = r.icon or p.icon
        table.insert(r.action and m.actions or m.info, r)
      end
    end
  end

  local untrained = Untrained(level)
  if #untrained > 0 then
    table.insert(m.actions, { icon = ICON.train, spells = untrained, action = true,
      text = "|cffff9900" .. ns.T("UNTRAINED") .. "|r " .. table.concat(untrained, ", "),
      click = function() ns.RunCommand("train") end, tip = ns.T("PW_CLICK_TRAIN") })
  end

  for _, prof in ipairs(ns.SelectedProfs and ns.SelectedProfs() or {}) do
    local line, behind = ns.ProfGoalLine(prof, level)
    if line then
      table.insert(behind and m.actions or m.info, { icon = PROF_ICON[prof], text = line, action = behind,
        click = function() ns.RunCommand("craft") end, tip = ns.T("PW_CLICK_CRAFT") })
    end
  end

  for _, item in ipairs(ns.VisibleGear(level) or {}) do
    table.insert(m.now, { icon = ICON.gear, text = ns.Tx(item) })
  end
  return m
end

-- Plain text of the window, for /@SLASH@ dump and the tests.
local function ModelText(m)
  local lines = { "@ADDON@ - " .. ns.T("LEVEL", m.level), ns.T("PW_DO") }
  if #m.actions == 0 then table.insert(lines, "  " .. ns.T("PW_DONE")) end
  for _, r in ipairs(m.actions) do table.insert(lines, "  > " .. r.text) end
  for _, r in ipairs(m.info) do table.insert(lines, "  " .. r.text) end
  if #m.now > 0 then
    table.insert(lines, ns.T("PW_NOW"))
    for _, r in ipairs(m.now) do table.insert(lines, "  " .. r.text) end
  end
  if #m.coming > 0 then
    table.insert(lines, ns.T("PW_COMING") .. (ns.db.comingOpen and " (open)" or " (closed)"))
    for _, lv in ipairs(m.coming) do
      table.insert(lines, "  " .. ns.T("LEVEL_N", lv.level))
      for _, r in ipairs(lv.rows) do table.insert(lines, "    " .. r.text) end
    end
  end
  return table.concat(lines, "\n")
end

-- Drawing ----------------------------------------------------------------
local rowPool, iconPool, headPool = {}, {}, {}
local ROW_ICON, SPELL_ICON = 16, 18

local function ShowTip(owner, fill)
  if not GameTooltip then return end
  GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
  pcall(fill, GameTooltip)
  GameTooltip:Show()
end

local function GetRow(i)
  local r = rowPool[i]
  if r then return r end
  r = CreateFrame("Button", nil, frame)
  r:RegisterForClicks("LeftButtonUp")
  r.hl = r:CreateTexture(nil, "HIGHLIGHT")
  r.hl:SetAllPoints()
  r.hl:SetColorTexture(1, 1, 1, 0.08)
  r.icon = r:CreateTexture(nil, "ARTWORK")
  r.icon:SetSize(ROW_ICON, ROW_ICON)
  r.icon:SetPoint("TOPLEFT", 0, -1)
  r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  r.text = r:CreateFontString(nil, "OVERLAY")
  r.text:SetPoint("TOPLEFT", ROW_ICON + 6, -2)
  r.text:SetJustifyH("LEFT")
  r.text:SetJustifyV("TOP")
  r:SetScript("OnClick", function(self) if self.item and self.item.click then self.item.click() end end)
  r:SetScript("OnEnter", function(self)
    local tip, list = self.item and self.item.tip, self.fullList
    if tip or list then
      ShowTip(self, function(tt)
        tt:SetText(list or tip, 1, 1, 1, 1, true)
        if list and tip then tt:AddLine(tip, 0.6, 0.8, 1, true) end
      end)
    end
  end)
  r:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  rowPool[i] = r
  return r
end

local function GetIcon(i)
  local b = iconPool[i]
  if b then return b end
  b = CreateFrame("Button", nil, frame)
  b:SetSize(SPELL_ICON, SPELL_ICON)
  b.tex = b:CreateTexture(nil, "ARTWORK")
  b.tex:SetAllPoints()
  b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  b:SetScript("OnEnter", function(self)
    ShowTip(self, function(tt)
      local _, id = ns.SpellInfo(self.spell)
      if id and tt.SetSpellByID then tt:SetSpellByID(id) else tt:SetText(self.spell) end
    end)
  end)
  b:SetScript("OnLeave", function() if GameTooltip then GameTooltip:Hide() end end)
  b:SetScript("OnClick", function(self) if self.click then self.click() end end)
  iconPool[i] = b
  return b
end

local function GetHead(i)
  local h = headPool[i]
  if h then return h end
  h = CreateFrame("Button", nil, frame)
  h.text = h:CreateFontString(nil, "OVERLAY")
  h.text:SetPoint("LEFT", 0, 0)
  h.text:SetJustifyH("LEFT")
  h:SetScript("OnClick", function(self) if self.click then self.click() end end)
  headPool[i] = h
  return h
end

local function Render(m)
  if not frame then return end
  local fontObj = _G[ns.CurrentFont().font] or GameFontHighlightSmall
  local width = frame:GetWidth() - 20
  local y = -8
  local nRow, nIcon, nHead = 0, 0, 0

  local function Head(text, click)
    nHead = nHead + 1
    local h = GetHead(nHead)
    h.text:SetFontObject(fontObj)
    h.text:SetText(text)
    h.click = click
    h:EnableMouse(click ~= nil)
    h:ClearAllPoints()
    h:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, y)
    h:SetSize(width, h.text:GetStringHeight() + 2)
    h:Show()
    y = y - h.text:GetStringHeight() - 4
  end

  local function Row(item, indent)
    nRow = nRow + 1
    local r = GetRow(nRow)
    r.item = item
    indent = indent or 0
    r.icon:SetTexture(item.icon)
    r.icon:SetShown(item.icon ~= nil)
    r.text:SetFontObject(fontObj)
    r.text:SetWidth(width - indent - ROW_ICON - 6)
    -- Spells with icons are drawn as icons; the rest stay in the text.
    local withIcon, noIcon = {}, {}
    for _, s in ipairs(item.spells or {}) do
      local name = s:gsub(" %d+$", "")
      local tex = ns.SpellIcon(name)
      if tex then table.insert(withIcon, { name = name, tex = tex }) else table.insert(noIcon, s) end
    end
    local text = item.text
    r.fullList = nil
    if item.spells then
      -- Long lists: the first few names here, all of them in the tooltip.
      local shown = noIcon
      if #noIcon > 5 then
        shown = { unpack(noIcon, 1, 5) }
        table.insert(shown, ns.T("PW_MORE", #noIcon - 5))
        r.fullList = table.concat(noIcon, "\n")
      end
      if #withIcon > 0 or #noIcon > 5 then
        text = (item.text:match("^(|c%x+.-|r)") or "") .. (#shown > 0 and (" " .. table.concat(shown, ", ")) or "")
      end
    end
    r.text:SetText(text)
    local h = math.max(ROW_ICON + 2, r.text:GetStringHeight() + 4)
    local iconsY = h
    if #withIcon > 0 then h = h + SPELL_ICON + 4 end
    r:ClearAllPoints()
    r:SetPoint("TOPLEFT", frame, "TOPLEFT", 10 + indent, y)
    r:SetSize(width - indent, h)
    r:EnableMouse(item.click ~= nil or item.tip ~= nil)
    r.hl:SetShown(item.click ~= nil)
    r:Show()
    for k, s in ipairs(withIcon) do
      nIcon = nIcon + 1
      local b = GetIcon(nIcon)
      b.spell, b.click = s.name, item.click
      b.tex:SetTexture(s.tex)
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", r, "TOPLEFT", ROW_ICON + 6 + (k - 1) * (SPELL_ICON + 3), -iconsY)
      b:SetFrameLevel(r:GetFrameLevel() + 2)
      b:Show()
    end
    y = y - h - 2
  end

  Head("|cff@COLOR@@ADDON@|r  |cffaaaaaa" .. ns.T("LEVEL", m.level) ..
    ((#ns.PLAN_ORDER > 1) and (" · " .. ns.T("PLAN_" .. ns.PlanKey())) or "") .. "|r")
  y = y - 2
  Head("|cffffffff" .. ns.T("PW_DO") .. "|r")
  if #m.actions == 0 then
    Row({ icon = ICON.done, text = "|cff60ff60" .. ns.T("PW_DONE") .. "|r" })
  end
  for _, r in ipairs(m.actions) do Row(r) end
  if #m.info > 0 then
    y = y - 4
    for _, r in ipairs(m.info) do Row(r) end
  end
  if #m.now > 0 then
    y = y - 4
    Head("|cffffffff" .. ns.T("PW_NOW") .. "|r")
    for _, r in ipairs(m.now) do Row(r) end
  end
  if #m.coming > 0 then
    y = y - 4
    local nums = {}
    for _, lv in ipairs(m.coming) do table.insert(nums, tostring(lv.level)) end
    local open = ns.db.comingOpen
    Head((open and "|cffffffff- " or "|cffffffff+ ") .. ns.T("PW_COMING") .. "|r  |cffaaaaaa" .. table.concat(nums, " · ") .. "|r",
      function() ns.db.comingOpen = not ns.db.comingOpen; ns.RefreshMain() end)
    if open then
      for _, lv in ipairs(m.coming) do
        Head("  |cffaaaaaa" .. ns.T("LEVEL_N", lv.level) .. "|r")
        for _, r in ipairs(lv.rows) do Row(r, 10) end
      end
    end
  end

  for i = nRow + 1, #rowPool do rowPool[i]:Hide() end
  for i = nIcon + 1, #iconPool do iconPool[i]:Hide() end
  for i = nHead + 1, #headPool do headPool[i]:Hide() end
  frame.rendering = true
  frame:SetHeight(-y + 8)
  frame.rendering = false
end

ns.statusProviders = {}
-- fn returns a text line, a row table or nil; icon is used for text lines.
function ns.AddStatusProvider(fn, icon) table.insert(ns.statusProviders, { fn = fn, icon = icon }) end

function ns.RefreshMain()
  if not frame then return end
  local m = BuildModel()
  frame.text:SetText(ModelText(m)) -- hidden; used by /@SLASH@ dump and the tests
  Render(m)
end

function ns.ToggleMain()
  if not frame then return end
  if frame:IsShown() then
    frame:Hide(); db.hidden = true
  else
    frame:Show(); db.hidden = false; ns.RefreshMain()
  end
end

local function CreateUI()
  frame = ns.MakeWindow("@ADDON@Frame", 340, "pos", { "RIGHT", "RIGHT", -40, 120 })
  -- The plan window draws rows instead of one text: the text is kept hidden for /dump.
  frame.text:Hide()
  function frame:SetContent() ns.RefreshMain() end
  frame:SetScript("OnSizeChanged", function(self)
    if self.rendering then return end
    ns.Debounce("mainsize", 0.05, ns.RefreshMain)
  end)
  frame.closeButton:SetScript("OnClick", function()
    frame:Hide()
    db.hidden = true
    Print(ns.T("HIDDEN"))
  end)
  if db.hidden then frame:Hide() end
  ns.mainFrame = frame
end

local function OnLevelUp(newLevel)
  local t, g = ns.talents[newLevel], ns.VisibleGear(newLevel)
  local left = ns.Unlearned(ns.spells[newLevel])
  local s = #left > 0 and table.concat(left, ", ") or nil
  if t then Print("|cffffd100" .. ns.T("LVLUP_TALENT", newLevel) .. "|r " .. t) end
  if s then Print("|cff9d9dff" .. ns.T("LVLUP_TRAIN") .. "|r " .. s) end
  if g then
    for _, item in ipairs(g) do Print("|cff1eff00" .. ns.T("LVLUP_CRAFT") .. "|r " .. ns.Tx(item)) end
  end
  if t or s or g then
    PlaySound(SOUNDKIT and SOUNDKIT.RAID_WARNING or 8959)
  end
end

---------------------------------------------------------------------------
-- Kommandon
---------------------------------------------------------------------------
ns.RegisterCommand("lock", true, function()
  db.locked = not db.locked
  Print(db.locked and ns.T("LOCKED") or ns.T("UNLOCKED"))
end)

ns.RegisterCommand("reset", true, function()
  ns.ResetWindow(frame)
  if ns.windows then for _, w in ipairs(ns.windows) do ns.ResetWindow(w) end end
  Print(ns.T("RESET_DONE"))
end)

ns.RegisterCommand("theme", true, function() ns.CycleTheme() end)
ns.RegisterCommand("font", true, function() ns.CycleFontSize() end)

function ns.CycleLang()
  @ADDON@Global = @ADDON@Global or {}
  @ADDON@Global.lang = (ns.Lang() == "enUS") and "svSE" or "enUS"
  ns.Print(ns.T("LANG_SET"))
  ns.RefreshMain()
  if ns.RefreshCraft then ns.RefreshCraft() end
  if ns.RefreshMenu then ns.RefreshMenu() end
end
ns.RegisterCommand("lang", true, function() ns.CycleLang() end)

ns.RegisterCommand("all", true, function()
  Print(ns.T("FULL_PLAN"))
  for lvl = 10, 60 do
    if ns.talents[lvl] then Print(lvl .. ": " .. ns.talents[lvl]) end
  end
end)

ns.RegisterCommand("help", nil, function()
  Print(ns.T("HELP_TOGGLE"))
  for _, c in ipairs(ns.helpLines) do Print("/@SLASH@ " .. c .. " - " .. ns.T("CMD_" .. c)) end
end)

SLASH_@ADDONUP@1 = "/@ADDONLOW@"
SLASH_@ADDONUP@2 = "/@SLASH@"
SlashCmdList.@ADDONUP@ = function(msg)
  msg = (msg or ""):match("^%s*(.-)%s*$")
  if not frame then
    Print(ns.T("CLASS_ONLY"))
    return
  end
  local cmd, rest = msg:match("^(%S*)%s*(.-)$")
  cmd = (cmd or ""):lower()
  if cmd == "" then
    ns.ToggleMain()
  elseif ns.commands[cmd] then
    local ok, err = pcall(ns.commands[cmd], rest)
    if not ok then Print(ns.T("ERROR", tostring(err))) end
  else
    Print(ns.T("UNKNOWN_CMD"))
  end
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("SKILL_LINES_CHANGED")
events:RegisterEvent("SPELLS_CHANGED")
events:SetScript("OnEvent", function(_, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    @ADDON@Global = @ADDON@Global or {}
    @ADDON@DB = @ADDON@DB or {}
    db = @ADDON@DB
    ns.db = db
  elseif event == "PLAYER_LOGIN" then
    local _, class = UnitClass("player")
    if class ~= "@CLASS@" then
      return -- another class: stay quiet (the other Plan addons may be installed too)
    end
    CreateUI()
    for _, init in ipairs(ns.modules) do
      local ok, err = pcall(init)
      if not ok then Print(ns.T("MODULE_FAIL", tostring(err))) end
    end
    ns.RefreshMain()
    Print(ns.T("LOADED"))
  elseif event == "PLAYER_LEVEL_UP" and frame then
    OnLevelUp(arg1)
    -- UnitLevel uppdateras ibland först efter eventet.
    C_Timer.After(1, ns.RefreshMain)
  elseif (event == "SKILL_LINES_CHANGED" or event == "SPELLS_CHANGED") and frame then
    ns.Debounce("main", 0.5, ns.RefreshMain)
  end
end)
