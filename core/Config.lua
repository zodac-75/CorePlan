-- @ADDON@: settings window with the logo.
-- Opens with right-click on the minimap icon, /@SLASH@ config, or from the game's
-- AddOns settings. Features on the left, plan and look on the right, tools below.
local _, ns = ...

local LOGO_FILE = ns.MEDIA .. "Logo"
-- Logo layout: ns.LOGO in the class Data.lua (round logos fill the whole texture).
local LOGO = ns.LOGO or { h = 1, size = 200, y = 62, panel = 260 }
local LOGO_H = LOGO.h

local win
local checks, selectors, labels = {}, {}, {}

local function Run(cmd, arg)
  local fn = ns.commands[cmd]
  if not fn then return end
  local ok, err = pcall(fn, arg or "")
  if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
end

local function Val(s) return "|cff@COLOR@" .. s .. "|r" end

-- Steps through a list of {key=...} by dir (+1 / -1) and returns the new key.
local function Step(list, current, dir)
  local i = 1
  for n, item in ipairs(list) do
    local k = type(item) == "table" and item.key or item
    if k == current then i = n end
  end
  i = ((i - 1 + dir) % #list) + 1
  local item = list[i]
  return type(item) == "table" and item.key or item
end

---------------------------------------------------------------------------
-- What the window controls
---------------------------------------------------------------------------
-- Tick boxes, each in a group (the headings in the settings window and the quick menu).
local FEATURES = {
  { group = "CAT_COMBAT", key = "MM_SHATTER", on = function() return not ns.db.shatterOff end, cmd = ns.COMBAT_CMD or "combat" },
  { group = "CAT_COMBAT", key = "MM_MOVE", on = function() return ns.db.shatterUnlocked end, cmd = "move" },
  { group = "CAT_BUFFS", key = "MM_BUFFS", on = function() return not ns.db.buffsOff end, cmd = "buffs" },
  { group = "CAT_BUFFS", key = "MM_PARTYBUFF", on = function() return not ns.db.partyBuffsOff end, cmd = "partybuffs", party = true },
  { group = "CAT_BUFFS", key = "MM_DRINK", on = function() return not ns.db.drinkOff end, cmd = "drink" },
  { group = "CAT_COMBAT", key = "MM_GLIDE", on = function() return not ns.db.glideOff end, cmd = "glide" },
  { group = "CAT_ITEMS", key = "MM_UPGRADE", on = function() return not ns.db.upgradeOff end, cmd = "upgrade" },
  { group = "CAT_ITEMS", key = "MM_QUEST", on = function() return not ns.db.questOff end, cmd = "quest" },
  { group = "CAT_ITEMS", key = "MM_TT", on = function() return not ns.db.tooltipOff end, cmd = "tooltip" },
  { group = "CAT_ITEMS", key = "MM_BAGAUTO", on = function() return not ns.db.bagAutoOff end, cmd = "bagauto" },
  { group = "CAT_LEVEL", key = "MM_XP", on = function() return not ns.db.xpOff end, cmd = "xp" },
  { group = "CAT_LEVEL", key = "MM_ZONE", on = function() return not ns.db.zoneTipsOff end, cmd = "zonetips" },
  { group = "CAT_LEVEL", key = "CFG_DGAUTO", on = function() return ns.db.dungeonAutoOpen end, cmd = "dungeonauto" },
  { group = "CAT_WINDOWS", key = "MM_LOCK", on = function() return ns.db.locked end, cmd = "lock" },
  { group = "CAT_WINDOWS", key = "CFG_MINIMAP", on = function() return not ns.db.minimapHidden end, cmd = "minimap" },
  { group = "CAT_FUN", key = "MM_EGGS", on = function() return not ns.db.eggsOff end, cmd = "eggs" },
  -- Secondary skills in the crafting assistant (ticked = shown).
  { group = "CAT_PROFS", key = "MM_SEC_COOK", on = function() return ns.SecondaryShown("Cooking") end, cmd = "cooking" },
  { group = "CAT_PROFS", key = "MM_SEC_FA", on = function() return ns.SecondaryShown("First Aid") end, cmd = "firstaid" },
  { group = "CAT_PROFS", key = "MM_SEC_FISH", on = function() return ns.SecondaryShown("Fishing") end, cmd = "fishing" },
}

-- Only classes with a group buff get the party buff box.
if not ns.PARTY_BUFFS then
  for i = #FEATURES, 1, -1 do
    if FEATURES[i].party then table.remove(FEATURES, i) end
  end
end

-- Classes without mana get no drink settings.
if ns.NO_MANA then
  for i = #FEATURES, 1, -1 do
    if FEATURES[i].key == "MM_DRINK" then table.remove(FEATURES, i) end
  end
end

-- Class-specific tick boxes (ns.EXTRA_FEATURES, with a group; combat by default) go
-- last in their group.
for _, extra in ipairs(ns.EXTRA_FEATURES or {}) do
  extra.group = extra.group or "CAT_COMBAT"
  local at = #FEATURES + 1
  for pos, f in ipairs(FEATURES) do if f.group == extra.group then at = pos + 1 end end
  table.insert(FEATURES, at, extra)
end

-- Buffs and reminders: the buff watcher, one box per watched buff (indented), the party
-- buff and its buffs, then the drink reminder. Kept together at the end of the list.
do
  local byKey, keep = {}, {}
  for _, f in ipairs(FEATURES) do
    if f.group == "CAT_BUFFS" then byKey[f.key] = f else table.insert(keep, f) end
  end
  local toggles = ns.BuffWatchToggles and ns.BuffWatchToggles() or {}
  local own, party = {}, {}
  for _, t in ipairs(toggles) do
    t.group, t.indent = "CAT_BUFFS", 16
    local ok, label = pcall(t.text)
    if ok and type(label) == "string" and label:find(ns.T("BW_PARTY_LABEL", ""), 1, true) == 1 then
      table.insert(party, t)
    else
      table.insert(own, t)
    end
  end
  FEATURES = keep
  local function push(f) if f then table.insert(FEATURES, f) end end
  push(byKey.MM_BUFFS)
  for _, t in ipairs(own) do push(t) end
  push(byKey.MM_PARTYBUFF)
  if byKey.MM_PARTYBUFF then for _, t in ipairs(party) do push(t) end end
  push(byKey.MM_DRINK)
end

local function Group(list, group)
  local out = {}
  for _, f in ipairs(list) do if f.group == group then table.insert(out, f) end end
  return out
end

-- Arrow selectors, by group.
local PLAN_SELECTORS = {}
if #ns.PLAN_ORDER > 1 then
  table.insert(PLAN_SELECTORS, { key = "MM_PLANSEL",
    value = function() return ns.T("PLAN_" .. ns.PlanKey()) end,
    step = function(dir)
      ns.db.plan = Step(ns.PLAN_ORDER, ns.PlanKey(), dir)
      ns.ApplyPlan()
      ns.RefreshMain()
      if ns.RefreshTalentGlow then ns.RefreshTalentGlow() end
    end })
end
-- Class settings (ns.EXTRA_SELECTORS in the class Data.lua) go right after the spec.
-- Each is { key = locale key, value = function() -> text, step = function(dir) }.
for _, e in ipairs(ns.EXTRA_SELECTORS or {}) do table.insert(PLAN_SELECTORS, e) end

local PROF_SELECTORS = {
  { key = "CFG_PROF1",
    value = function() return ns.ProfLabel(1) end,
    step = function(dir) ns.StepProf(1, dir) end },
  { key = "CFG_PROF2",
    value = function() return ns.ProfLabel(2) end,
    step = function(dir) ns.StepProf(2, dir) end },
}

local LOOK_SELECTORS = {
  { key = "MM_THEME",
    value = function() return ns.T("THEME_" .. ns.CurrentTheme().key) end,
    step = function(dir)
      ns.db.theme = Step(ns.THEMES, ns.CurrentTheme().key, dir)
      ns.ApplyThemeAll()
    end },
  { key = "MM_FONT",
    value = function() return ns.T("FONT_" .. ns.CurrentFont().key) end,
    step = function(dir)
      ns.db.fontSize = Step(ns.FONTS, ns.CurrentFont().key, dir)
      ns.ApplyFontAll()
    end },
  { key = "MM_LANG",
    value = function() return ns.Lang() == "svSE" and "Svenska" or "English" end,
    step = function() ns.CycleLang() end },
}

local ALERT_SELECTORS = {
  { key = "CFG_HELPERSIZE",
    value = function() return math.floor((ns.db.shatterScale or 1) * 100 + 0.5) .. "%" end,
    step = function(dir)
      local cur, i = ns.db.shatterScale or 1, 2
      for n, v in ipairs(ns.HELPER_SIZES) do if math.abs(v - cur) < 0.01 then i = n end end
      i = math.max(1, math.min(#ns.HELPER_SIZES, i + dir))
      ns.SetHelperScale(ns.HELPER_SIZES[i])
    end },
  { key = "CFG_ALERTSTYLE",
    value = function() return ns.T("ASTYLE_" .. (ns.db.alertStyle or "both")) end,
    step = function(dir) ns.db.alertStyle = Step(ns.ALERT_STYLES, ns.db.alertStyle or "both", dir) end },
  { key = "CFG_SOUND",
    value = function() return ns.T("SOUND_" .. (ns.db.alertSound or "off")) end,
    step = function(dir)
      ns.db.alertSound = Step(ns.ALERT_MODES, ns.db.alertSound or "off", dir)
      if ns.db.alertSound ~= "off" then ns.PlayAlertSound() end
    end },
  { key = "CFG_SOUNDKIT",
    value = function() return ns.T("SNDKIT_" .. (ns.db.alertSoundKit or "RAID_WARNING")) end,
    step = function(dir)
      local keys = {}
      for _, s in ipairs(ns.ALERT_SOUNDS) do table.insert(keys, s.key) end
      ns.db.alertSoundKit = Step(keys, ns.db.alertSoundKit or "RAID_WARNING", dir)
      ns.PlayAlertSound() -- let you hear it
    end },
  { key = "CFG_REBUFF",
    value = function()
      local m = ns.db.rebuffMin or 3
      return m == 0 and ns.T("REBUFF_OFF") or ns.T("REBUFF_MIN", m)
    end,
    step = function(dir)
      ns.db.rebuffMin = Step(ns.REBUFF_TIMES, ns.db.rebuffMin or 3, dir)
      if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
    end },
}
if not ns.NO_MANA then
  table.insert(ALERT_SELECTORS, { key = "CFG_DRINKAT",
    value = function() return (ns.db.drinkPct or 40) .. "%" end,
    step = function(dir)
      local n = math.max(10, math.min(90, (ns.db.drinkPct or 40) + dir * 5))
      Run("drinkat", tostring(n))
    end })
end

local PROFILE_SELECTORS = {
  { key = "CFG_PROFILE",
    value = function() return ns.ActiveProfile() end,
    step = function(dir) ns.StepProfile(dir) end },
  { key = "CFG_DGPROFILE",
    value = function() return ns.DungeonProfile() or ns.T("CFG_OFF") end,
    step = function(dir) ns.StepDungeonProfile(dir) end },
}

local TOOLS = {
  { key = "MM_PLAN", func = function() ns.ToggleMain() end },
  { key = "MM_DUNGEONS", func = function() ns.ToggleDungeons() end },
  { key = "MM_CRAFT", func = function() Run("craft") end },
  { key = "MM_RANKS", func = function() Run("ranks") end },
  { key = "MM_DE", func = function() ns.ToggleBags() end },
  { key = "MM_ALL", func = function() Run("all") end },
  { key = "MM_RESET", func = function() Run("reset") end },
  { key = "CFG_HELP", func = function() Run("help") end },
}
-- Class-specific tool buttons go after the rank check.
for i = #(ns.EXTRA_TOOLS or {}), 1, -1 do
  local t = ns.EXTRA_TOOLS[i]
  table.insert(TOOLS, 5, { key = t.key, func = function() Run(t.cmd) end })
end

---------------------------------------------------------------------------
-- Refresh: texts follow the language, checkboxes follow the saved settings.
---------------------------------------------------------------------------
local function Refresh()
  if not win then return end
  for _, fs in ipairs(labels) do fs:SetText(ns.T(fs.key)) end
  for _, cb in ipairs(checks) do
    local ok, on = pcall(cb.item.on)
    cb:SetChecked(ok and on and true or false)
    cb.label:SetText(cb.item.text and cb.item.text() or ns.T(cb.item.key))
  end
  for _, s in ipairs(selectors) do
    s.label:SetText((ns.T(s.item.key):gsub(":$", "")))
    local ok, v = pcall(s.item.value)
    s.value:SetText(Val(ok and v or "?"))
  end
  for _, b in ipairs(win.tools) do b:SetText(ns.T(b.key)) end
end
ns.RefreshMenu = function() if win and win:IsShown() then Refresh() end end

---------------------------------------------------------------------------
-- Building blocks
---------------------------------------------------------------------------
local function Header(parent, key, x, y)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  fs:SetPoint("TOPLEFT", x, y)
  fs:SetTextColor(0.41, 0.8, 0.94)
  fs.key = key
  table.insert(labels, fs)
  local line = parent:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(0.41, 0.8, 0.94, 0.35)
  line:SetPoint("TOPLEFT", x, y - 16)
  line:SetSize(236, 1)
  return fs
end

local function CheckRow(parent, item, x, y)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(22, 22)
  cb:SetPoint("TOPLEFT", x, y)
  local label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  label:SetWidth(205)
  label:SetJustifyH("LEFT")
  cb.label = label
  cb.item = item
  cb:SetScript("OnClick", function()
    if item.toggle then pcall(item.toggle) else Run(item.cmd) end
    Refresh()
  end)
  table.insert(checks, cb)
end

local function ArrowButton(parent, dir)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(22, 22)
  local base = dir < 0 and "Interface\\Buttons\\UI-SpellbookIcon-PrevPage-" or "Interface\\Buttons\\UI-SpellbookIcon-NextPage-"
  b:SetNormalTexture(base .. "Up")
  b:SetPushedTexture(base .. "Down")
  b:SetDisabledTexture(base .. "Disabled")
  b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  return b
end

local function SelectorRow(parent, item, x, y)
  local s = {}
  s.item = item
  s.label = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  s.label:SetPoint("TOPLEFT", x, y - 5)
  s.label:SetWidth(92)
  s.label:SetJustifyH("LEFT")

  local prev = ArrowButton(parent, -1)
  prev:SetPoint("TOPLEFT", x + 94, y)
  local nextB = ArrowButton(parent, 1)
  nextB:SetPoint("TOPLEFT", x + 214, y)

  s.value = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  s.value:SetPoint("LEFT", prev, "RIGHT", 0, 0)
  s.value:SetPoint("RIGHT", nextB, "LEFT", 0, 0)
  s.value:SetJustifyH("CENTER")

  local function Go(dir)
    local ok, err = pcall(item.step, dir)
    if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
    Refresh()
  end
  prev:SetScript("OnClick", function() Go(-1) end)
  nextB:SetScript("OnClick", function() Go(1) end)
  table.insert(selectors, s)
end

local function Version()
  local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
  local v = get and get("@ADDON@", "Version")
  if v and not v:find("@") then return "v" .. v end
  return ""
end

---------------------------------------------------------------------------
-- The window
---------------------------------------------------------------------------
local function CreateConfig()
  win = CreateFrame("Frame", "@ADDON@Config", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  win:SetSize(800, 500)
  win:SetFrameStrata("DIALOG")
  win:SetToplevel(true)
  win:SetClampedToScreen(true)
  win:SetClampRectInsets(0, 0, 70, 0) -- keep the logo on screen too
  win:EnableMouse(true)
  win:SetMovable(true)
  win:RegisterForDrag("LeftButton")
  win:SetScript("OnDragStart", win.StartMoving)
  win:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint()
    ns.db.configPos = { p, rp, x, y }
  end)
  local p = ns.db.configPos
  if p then
    win:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else
    win:SetPoint("CENTER", 0, -30)
  end
  table.insert(ns.themedFrames, win)
  ns.ApplyTheme(win)
  table.insert(UISpecialFrames, "@ADDON@Config") -- Esc closes it

  -- The logo sits on the top edge and sticks out above the window.
  local logo = win:CreateTexture(nil, "OVERLAY")
  logo:SetTexture(LOGO_FILE)
  logo:SetTexCoord(0, 1, 0, LOGO_H)
  logo:SetSize(LOGO.size, LOGO.size * LOGO_H)
  logo:SetPoint("TOP", 0, LOGO.y)

  local close = CreateFrame("Button", nil, win, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -2, -2)

  local version = win:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  version:SetPoint("TOPLEFT", 12, -10)
  version:SetText(Version())

  -- Three columns of groups, then the tool buttons across the bottom.
  local top = -142
  local COL = { 16, 280, 544 }
  local CHECK_H, SEL_H, HEAD_H = 21, 25, 24
  local bottom = top
  local function Column(x, blocks)
    local y = top
    for _, b in ipairs(blocks) do
      local checks = b.checks or {}
      local sels = b.sels or {}
      if #checks > 0 or #sels > 0 or b.after then
        Header(win, b.head, x, y)
        y = y - HEAD_H
        for _, item in ipairs(sels) do SelectorRow(win, item, x, y); y = y - SEL_H end
        for _, item in ipairs(checks) do CheckRow(win, item, x - 2 + (item.indent or 0), y); y = y - CHECK_H end
        if b.after then y = b.after(x, y) end
        y = y - 8
      end
    end
    bottom = math.min(bottom, y)
  end

  win.tools = {}
  local function SmallButton(key, x, y, fn)
    local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
    b:SetSize(115, 22)
    b:SetPoint("TOPLEFT", x, y)
    b.key = key
    b:SetScript("OnClick", function()
      local ok, err = pcall(fn)
      if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
      Refresh()
    end)
    table.insert(win.tools, b)
  end

  Column(COL[1], {
    { head = "CAT_COMBAT", checks = Group(FEATURES, "CAT_COMBAT") },
    { head = "CAT_ITEMS", checks = Group(FEATURES, "CAT_ITEMS") },
    { head = "CAT_LEVEL", checks = Group(FEATURES, "CAT_LEVEL") },
    { head = "CAT_WINDOWS", checks = Group(FEATURES, "CAT_WINDOWS") },
    { head = "CAT_FUN", checks = Group(FEATURES, "CAT_FUN") },
  })
  Column(COL[2], {
    { head = "CAT_PLAN", sels = PLAN_SELECTORS },
    { head = "CAT_PROFS", sels = PROF_SELECTORS, checks = Group(FEATURES, "CAT_PROFS") },
    { head = "CAT_LOOK", sels = LOOK_SELECTORS, after = function(x, y)
      local hint = win:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
      hint:SetPoint("TOPLEFT", x, y - 2)
      hint:SetWidth(236)
      hint:SetJustifyH("LEFT")
      hint.key = "MM_HINT"
      table.insert(labels, hint)
      return y - 26
    end },
    -- Profiles are shared by all characters.
    { head = "CFG_PROFILES", sels = PROFILE_SELECTORS, after = function(x, y)
      SmallButton("CFG_NEW", x, y, function() ns.AskNewProfile() end)
      SmallButton("CFG_DELETE", x + 121, y, function() ns.AskDeleteProfile() end)
      return y - 26
    end },
  })
  Column(COL[3], {
    { head = "CAT_ALERTS", sels = ALERT_SELECTORS },
    { head = "CAT_BUFFS", checks = Group(FEATURES, "CAT_BUFFS") },
  })

  -- Bottom: tools, four columns of buttons
  local toolsTop = bottom - 6
  Header(win, "CFG_TOOLS", 16, toolsTop)
  local line = win:CreateTexture(nil, "ARTWORK")
  line:SetColorTexture(0.41, 0.8, 0.94, 0.35)
  line:SetPoint("TOPLEFT", 252, toolsTop - 16)
  line:SetSize(532, 1)
  for i, t in ipairs(TOOLS) do
    local b = CreateFrame("Button", nil, win, "UIPanelButtonTemplate")
    b:SetSize(184, 22)
    local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
    b:SetPoint("TOPLEFT", 16 + col * 192, toolsTop - 24 - row * 26)
    b.key = t.key
    b:SetScript("OnClick", function()
      local ok, err = pcall(t.func)
      if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
      Refresh()
    end)
    table.insert(win.tools, b)
  end
  local rows = math.ceil(#TOOLS / 4)
  win:SetHeight(-(toolsTop - 24 - rows * 26) + 12)

  win:SetScript("OnShow", Refresh)
  win:Hide()
end

---------------------------------------------------------------------------
-- Quick menu: left-click on the minimap icon. Spec, the windows and on/off switches
-- in a small list next to the icon; the big settings window is on right-click.
---------------------------------------------------------------------------
local quick
local QROW_H, QWIDTH = 18, 236

local QUICK_TOOLS = {
  { key = "MM_PLAN", func = function() ns.ToggleMain() end },
  { key = "MM_DUNGEONS", func = function() ns.ToggleDungeons() end },
  { key = "MM_CRAFT", func = function() Run("craft") end },
  { key = "QM_TRAIN", func = function() Run("train") end },
}

local function QuickRow(parent, y)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(QWIDTH - 16, QROW_H)
  b:SetPoint("TOPLEFT", 8, y)
  b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  local hl = b:CreateTexture(nil, "HIGHLIGHT")
  hl:SetAllPoints()
  hl:SetColorTexture(1, 1, 1, 0.12)
  b.check = b:CreateTexture(nil, "ARTWORK")
  b.check:SetSize(16, 16)
  b.check:SetPoint("LEFT", 2, 0)
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.text:SetPoint("LEFT", 22, 0)
  b.text:SetPoint("RIGHT", -4, 0)
  b.text:SetJustifyH("LEFT")
  return b
end

local function QuickHeader(parent, y, key)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  fs:SetPoint("TOPLEFT", 10, y - 3)
  fs.key = key
  return fs
end

local function RefreshQuick()
  if not quick then return end
  if quick.spec then
    quick.spec.text:SetText(ns.T("MM_PLANSEL"):gsub(":$", "") .. ": " .. Val(ns.T("PLAN_" .. ns.PlanKey())))
  end
  for _, r in ipairs(quick.extras) do
    local ok, v = pcall(r.item.value)
    r.text:SetText(ns.T(r.item.key):gsub(":$", "") .. ": " .. Val(ok and v or "?"))
  end
  for _, h in ipairs(quick.headers) do h:SetText(ns.T(h.key)) end
  for _, r in ipairs(quick.tools) do r.text:SetText(ns.T(r.item.key)) end
  for _, r in ipairs(quick.toggles) do
    local ok, on = pcall(r.item.on)
    r.check:SetTexture(ok and on and "Interface\\Buttons\\UI-CheckBox-Check" or "Interface\\Buttons\\UI-CheckBox-Up")
    r.text:SetText(r.item.text and r.item.text() or ns.T(r.item.key))
  end
  quick.more.text:SetText(ns.T("QM_SETTINGS"))
end

local function BuildQuick()
  quick = CreateFrame("Frame", "@ADDON@QuickMenu", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
  quick:SetFrameStrata("DIALOG")
  quick:SetClampedToScreen(true)
  quick:EnableMouse(true)
  quick.headers, quick.tools, quick.toggles = {}, {}, {}
  ns.ApplyTheme(quick)
  table.insert(ns.themedFrames, quick)
  table.insert(UISpecialFrames, "@ADDON@QuickMenu") -- Esc closes it

  local title = quick:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 10, -9)
  title:SetText("|cff@COLOR@@ADDON@|r")
  local y = -28

  if #ns.PLAN_ORDER > 1 then
    -- Spec: left-click for the next one, right-click for the previous one.
    local r = QuickRow(quick, y)
    r.check:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    r:SetScript("OnClick", function(_, mouse)
      local dir = mouse == "RightButton" and -1 or 1
      ns.db.plan = Step(ns.PLAN_ORDER, ns.PlanKey(), dir)
      ns.ApplyPlan()
      ns.RefreshMain()
      if ns.RefreshTalentGlow then ns.RefreshTalentGlow() end
      ns.Print(ns.T("PLAN_SET", ns.T("PLAN_" .. ns.PlanKey())))
      Refresh()
      RefreshQuick()
    end)
    quick.spec = r
    y = y - QROW_H
  end
  quick.extras = {}
  for _, item in ipairs(ns.EXTRA_SELECTORS or {}) do
    local r = QuickRow(quick, y)
    r.item = item
    r.check:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    r:SetScript("OnClick", function(_, mouse)
      local ok, err = pcall(item.step, mouse == "RightButton" and -1 or 1)
      if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
      Refresh()
      RefreshQuick()
    end)
    table.insert(quick.extras, r)
    y = y - QROW_H
  end
  if quick.spec or #quick.extras > 0 then y = y - 4 end

  table.insert(quick.headers, QuickHeader(quick, y, "QM_OPEN"))
  y = y - 16
  for _, item in ipairs(QUICK_TOOLS) do
    local r = QuickRow(quick, y)
    r.item = item
    r.check:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")
    r:SetScript("OnClick", function()
      quick:Hide()
      local ok, err = pcall(item.func)
      if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
    end)
    table.insert(quick.tools, r)
    y = y - QROW_H
  end

  local lastGroup
  for _, item in ipairs(FEATURES) do
    if item.group ~= lastGroup then
      lastGroup = item.group
      y = y - 4
      table.insert(quick.headers, QuickHeader(quick, y, item.group))
      y = y - 16
    end
    local r = QuickRow(quick, y)
    r.item = item
    r:SetScript("OnClick", function()
      if item.toggle then pcall(item.toggle) else Run(item.cmd) end
      Refresh()
      RefreshQuick()
    end)
    table.insert(quick.toggles, r)
    y = y - QROW_H
  end

  y = y - 6
  local more = QuickRow(quick, y)
  more.check:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
  more:SetScript("OnClick", function()
    quick:Hide()
    if win and not win:IsShown() then win:Show() end
  end)
  quick.more = more
  y = y - QROW_H

  quick:SetSize(QWIDTH, -y + 10)
  quick:Hide()

  -- A click anywhere else closes the menu.
  quick:RegisterEvent("GLOBAL_MOUSE_DOWN")
  quick:SetScript("OnEvent", function(self)
    if self:IsShown() and not self:IsMouseOver() and not (self.anchor and self.anchor:IsMouseOver()) then
      self:Hide()
    end
  end)
end

function ns.ToggleQuickMenu(anchor)
  if not quick then
    local ok, err = pcall(BuildQuick)
    if not ok then ns.Print(ns.T("ERROR", tostring(err))); return end
  end
  if quick:IsShown() then quick:Hide(); return end
  quick.anchor = anchor
  quick:ClearAllPoints()
  if anchor then
    -- Open towards the middle of the screen.
    local x, y = anchor:GetCenter()
    local w, h = UIParent:GetWidth(), UIParent:GetHeight()
    local right, top = x and x > w / 2, y and y > h / 2
    local point = (top and "TOP" or "BOTTOM") .. (right and "RIGHT" or "LEFT")
    local rel = (top and "BOTTOM" or "TOP") .. (right and "LEFT" or "RIGHT")
    quick:SetPoint(point, anchor, rel, 0, 0)
  else
    quick:SetPoint("CENTER")
  end
  RefreshQuick()
  quick:Show()
end

function ns.ToggleConfig()
  if not win then return end
  if win:IsShown() then win:Hide() else win:Show() end
end

---------------------------------------------------------------------------
-- Entry in the game's own AddOns settings
---------------------------------------------------------------------------
local function RegisterBlizzardPanel()
  local panel = CreateFrame("Frame")
  panel.name = "@ADDON@"

  local logo = panel:CreateTexture(nil, "ARTWORK")
  logo:SetTexture(LOGO_FILE)
  logo:SetTexCoord(0, 1, 0, LOGO_H)
  logo:SetSize(LOGO.panel, LOGO.panel * LOGO_H)
  logo:SetPoint("TOP", 0, -16)

  local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  b:SetSize(240, 26)
  b:SetPoint("TOP", logo, "BOTTOM", 0, -12)
  b:SetText(ns.T("CFG_OPEN"))
  b:SetScript("OnClick", function()
    -- We don't close Blizzard's settings window from here (that taints its layout code);
    -- our window opens on top of it instead.
    if win then
      win:SetFrameStrata("FULLSCREEN_DIALOG")
      win:Show()
      win:Raise()
    end
  end)
  panel:SetScript("OnShow", function() b:SetText(ns.T("CFG_OPEN")) end)

  if Settings and Settings.RegisterCanvasLayoutCategory and Settings.RegisterAddOnCategory then
    local cat = Settings.RegisterCanvasLayoutCategory(panel, "@ADDON@")
    Settings.RegisterAddOnCategory(cat)
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
end

ns.RegisterModule(function()
  CreateConfig()
  local ok, err = pcall(RegisterBlizzardPanel)
  if not ok then ns.Print(ns.T("ERROR", tostring(err))) end
end)

ns.RegisterCommand("config", true, function() ns.ToggleConfig() end)
