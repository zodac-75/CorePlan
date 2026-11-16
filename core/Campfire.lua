-- @ADDON@: campfire talk. While you have the campfire buff ("Campfire Nearby" in WoW Forever,
-- "Cozy Fire" from a cooking fire) a small button shows up. A click /says a random line
-- from CampfireLines.lua: greetings, jokes, the weather in your zone, your class, the fire.
-- The game only lets addons /say outdoors from a real click or key press, so it never talks
-- on its own. Shift-click: greet your target. Right-click: a joke. Drag it with "Move" on.
local _, ns = ...

local BUFFS = {}
BUFFS[1] = "Campfire Nearby" -- WoW Forever
BUFFS[2] = "Cozy Fire"       -- a cooking fire
local COOLDOWN = 6

local btn
local lastSay = 0
local bags = {}      -- category -> shuffled list of lines not used yet
local lastLine

local function Readable(v) return v ~= nil and not (issecretvalue and issecretvalue(v)) end

-- Is one of the campfire buffs on you? nil when the aura list can't be read.
function ns.NearCampfire()
  if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
    for _, n in ipairs(BUFFS) do
      local ok, a = pcall(C_UnitAuras.GetAuraDataBySpellName, "player", ns.Loc(n), "HELPFUL")
      if ok and a then return true end
    end
  end
  for i = 1, 40 do
    local name
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
      if not ok or not a then break end
      name = a.name
    elseif UnitAura then
      local ok, n = pcall(UnitAura, "player", i, "HELPFUL")
      if not ok or not n then break end
      name = n
    else
      break
    end
    if Readable(name) then
      for _, n in ipairs(BUFFS) do if name == n then return true end end
    end
  end
  return false
end

local function TargetName()
  local unit = "target"
  local ok, isP = pcall(UnitIsPlayer, unit)
  if not (ok and isP == true) then return nil end
  local okS, me = pcall(UnitIsUnit, unit, "player")
  if okS and me == true then return nil end
  local okN, n = pcall(UnitName, unit)
  if okN and type(n) == "string" and Readable(n) and n ~= "" then return n end
end

local function ZoneName()
  local ok, z = pcall(GetZoneText)
  if ok and type(z) == "string" and Readable(z) and z ~= "" then return z end
  return "these lands"
end

local function ZoneGroup()
  local ok, map = pcall(function() return C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player") end)
  return ok and map and ns.CAMPFIRE_ZONES and ns.CAMPFIRE_ZONES[map] or nil
end

local function TimeGroup()
  local ok, h = pcall(GetGameTime)
  if not ok or type(h) ~= "number" then return nil end
  if h >= 22 or h < 5 then return "night" end
  if h < 10 then return "morning" end
  if h >= 18 then return "evening" end
end

local function ClassLines()
  local _, class = UnitClass("player")
  local t = ns.CAMPFIRE_LINES and ns.CAMPFIRE_LINES.class
  return t and class and t[class], class
end

local function Lines(cat)
  local L = ns.CAMPFIRE_LINES
  if cat == "class" then return (ClassLines()) end
  return L and L[cat]
end

-- Next line from a category: shuffled, no repeats until all of it has been used.
local function Draw(cat)
  local src = Lines(cat)
  if not src or #src == 0 then return nil end
  local bag = bags[cat]
  if not bag or #bag == 0 then
    bag = {}
    for i = 1, #src do bag[i] = src[i] end
    for i = #bag, 2, -1 do local j = math.random(i); bag[i], bag[j] = bag[j], bag[i] end
    if #bag > 1 and bag[#bag] == lastLine then bag[1], bag[#bag] = bag[#bag], bag[1] end
    bags[cat] = bag
  end
  local line = table.remove(bag)
  lastLine = line
  return line
end

-- Pick a category: weighted, the zone and time groups only when they apply.
local function PickCategory(target)
  local opts = {
    { "joke", 30 }, { "fire", 18 }, { "food", 10 }, { "greet", 8 }, { "class", 12 }, { "rare", 3 },
  }
  if target then table.insert(opts, { "greetTarget", 14 }) end
  local zg = ZoneGroup()
  if zg then table.insert(opts, { zg, 12 }) end
  local tg = TimeGroup()
  if tg then table.insert(opts, { tg, 8 }) end
  local sum = 0
  for _, o in ipairs(opts) do sum = sum + o[2] end
  local r = math.random() * sum
  for _, o in ipairs(opts) do
    r = r - o[2]
    if r <= 0 then return o[1] end
  end
  return "joke"
end

-- The text for one /say (placeholders filled in), or nil.
function ns.CampfireLine(cat)
  local target = TargetName()
  if cat == "greetTarget" and not target then cat = "greet" end
  cat = cat or PickCategory(target)
  local line
  for _ = 1, 5 do
    line = Draw(cat)
    if not line then cat = "joke"; line = Draw(cat) end
    if line and (target or not line:find("%target%", 1, true)) then break end
    line = nil
  end
  if not line then return nil end
  local me = UnitName("player")
  local _, classFile = UnitClass("player")
  local className = UnitClass("player")
  local subs = {
    ["%name%"] = Readable(me) and me or "me",
    ["%target%"] = target or "friend",
    ["%zone%"] = ZoneName(),
    ["%class%"] = (Readable(className) and className or classFile or "adventurer"):lower(),
  }
  line = line:gsub("%%%a+%%", function(k) return subs[k] or k end)
  return line
end

local function Send(text)
  if C_ChatInfo and C_ChatInfo.SendChatMessage then
    return pcall(C_ChatInfo.SendChatMessage, text, "SAY")
  end
  return pcall(SendChatMessage, text, "SAY")
end

-- Say one line (from a click, key or macro). cat = nil for a random one.
function ns.CampfireSay(cat)
  local now = GetTime()
  if now - lastSay < COOLDOWN then return false end
  local text = ns.CampfireLine(cat)
  if not text then return false end
  lastSay = now
  Send(text)
  return true
end

local function Update()
  if not btn then return end
  local show = not ns.db.campfireOff and not InCombatLockdown()
    and (ns.db.shatterUnlocked or ns.NearCampfire() == true)
  if show then btn:Show() else btn:Hide() end
end

ns.RegisterModule(function()
  btn = CreateFrame("Button", "@ADDON@CampfireButton", UIParent)
  btn:SetSize(40, 40)
  local p = ns.db.campfirePos
  if p then btn:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else btn:SetPoint("CENTER", UIParent, "CENTER", 0, -120) end
  btn:SetScale(ns.db.campfireScale or 1)
  btn:SetClampedToScreen(true)
  btn:SetMovable(true)
  btn:RegisterForClicks("AnyUp")
  btn:RegisterForDrag("LeftButton")
  btn:SetScript("OnDragStart", function(self) if ns.db.shatterUnlocked then self:StartMoving() end end)
  btn:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.campfirePos = { point, relPoint, x, y }
  end)
  btn:EnableMouseWheel(true)
  btn:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked or not IsControlKeyDown() then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.campfireScale = s
  end)
  local icon = btn:CreateTexture(nil, "ARTWORK")
  icon:SetAllPoints()
  icon:SetTexture("Interface\\Icons\\Spell_Fire_Fire")
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  btn:SetScript("OnClick", function(_, button)
    if button == "RightButton" then ns.CampfireSay("joke")
    elseif IsShiftKeyDown and IsShiftKeyDown() then ns.CampfireSay("greetTarget")
    else ns.CampfireSay() end
  end)
  btn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(ns.T("CF_TITLE"))
    GameTooltip:AddLine(ns.T("CF_TIP"), 1, 1, 1, true)
    GameTooltip:Show()
  end)
  btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
  btn:Hide()

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("UNIT_AURA")
  ev:RegisterEvent("PLAYER_REGEN_DISABLED")
  ev:RegisterEvent("PLAYER_REGEN_ENABLED")
  ev:RegisterEvent("PLAYER_ENTERING_WORLD")
  ev:SetScript("OnEvent", function(_, event, unit)
    if event == "UNIT_AURA" and unit ~= "player" then return end
    if event == "PLAYER_REGEN_DISABLED" then btn:Hide() return end
    ns.Debounce("campfire", 0.3, function() pcall(Update) end)
  end)
  local acc = 0
  ev:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 1 then return end
    acc = 0
    pcall(Update)
  end)
  C_Timer.After(2, function() pcall(Update) end)
end)

function ns.RefreshCampfire() pcall(Update) end

-- /@SLASH@ campfire: say a line now (works from a macro or key bind anywhere);
-- /@SLASH@ campfire off|on: the button.
ns.RegisterCommand("campfire", true, function(arg)
  arg = (arg or ""):lower()
  if arg == "off" or arg == "on" or arg == "toggle" then
    if arg == "toggle" then ns.db.campfireOff = not ns.db.campfireOff else ns.db.campfireOff = (arg == "off") end
    ns.Print(ns.db.campfireOff and ns.T("CF_OFF") or ns.T("CF_ON"))
    pcall(Update)
    return
  end
  ns.CampfireSay(arg ~= "" and arg or nil)
end)
