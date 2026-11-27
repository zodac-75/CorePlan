-- @ADDON@: Fingers of Frost icon. While the proc is up, its icon sits on your screen (with the
-- charges left and the seconds left when the game tells us), and a short ping plays when it
-- lands. Works without a target. Moves and resizes with "Unlock UI" like the range icon.
local _, ns = ...

local FOF = "Fingers of Frost"
local FALLBACK_ICON = "Interface\\Icons\\Ability_Mage_WintersGrasp"
local f, icon, count, timer, glow
local acc, had = 0, false
local lastUnlocked

local function Secret(v) return issecretvalue and issecretvalue(v) or false end

-- The proc as aura data, or nil. Three ways, as the game hides more in combat:
-- 1. by name (often refused in combat), 2. by spell ID (the ID the addon saw out of combat,
-- or the known Fingers of Frost proc IDs), 3. the aura list (names hidden in combat).
local KNOWN_IDS = { 44544, 74396, 400670, 400647, 83074 }
local function ByName()
  if C_UnitAuras and C_UnitAuras.GetAuraDataBySpellName then
    local ok, a = pcall(C_UnitAuras.GetAuraDataBySpellName, "player", ns.Loc(FOF), "HELPFUL")
    if ok and a then return a end
  end
end
local function ByID()
  local fn = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID
  if not fn then return nil end
  local ids = {}
  if ns.db.fofSpellId then ids[1] = ns.db.fofSpellId end
  for _, id in ipairs(KNOWN_IDS) do if id ~= ns.db.fofSpellId then ids[#ids + 1] = id end end
  for _, id in ipairs(ids) do
    local ok, a = pcall(fn, id)
    if ok and a then return a, id end
  end
end
local function ByList()
  local found
  ns.ForEachAura("player", "HELPFUL", function(n, id)
    if n == FOF then
      found = {}
      if type(id) == "number" and not Secret(id) and id > 0 then ns.db.fofSpellId = id end
      return true
    end
  end)
  return found
end
local function Aura()
  local a = ByName()
  if a then
    local id = a.spellId
    if type(id) == "number" and not Secret(id) and id > 0 then ns.db.fofSpellId = id end
    return a
  end
  return ByID() or ByList()
end
ns.FoFAura = Aura

local function Ping()
  if ns.db.fofSoundOff then return end
  local kit = rawget(_G, "SOUNDKIT")
  pcall(PlaySound, (kit and kit.ALARM_CLOCK_WARNING_3) or 12867)
end

local function Show(a, preview)
  local tex = a and not Secret(a.icon) and a.icon or FALLBACK_ICON
  icon:SetTexture(tex)
  local n = a and a.applications
  if n and not Secret(n) and n > 1 then count:SetText(tostring(n)) else count:SetText(preview and "2" or "") end
  local exp = a and a.expirationTime
  if exp and not Secret(exp) and exp > 0 then
    local left = exp - GetTime()
    timer:SetText(left > 0 and string.format("%d", math.ceil(left)) or "")
  else
    timer:SetText("")
  end
  f:Show()
end

local function Update()
  local unlocked = ns.db.shatterUnlocked and true or false
  if unlocked ~= lastUnlocked then
    lastUnlocked = unlocked
    f:EnableMouse(unlocked); f:EnableMouseWheel(unlocked)
  end
  if ns.db.fofOff then f:Hide(); had = false; return end
  local a = Aura()
  if a then
    if not had then Ping(); glow.t = 0 end
    had = true
    Show(a)
  else
    had = false
    if unlocked then Show(nil, true) else f:Hide() end
  end
end
ns.FoFUpdate = function() if f then Update() end end

local function Create()
  f = CreateFrame("Frame", "@ADDON@FoFFrame", UIParent)
  f:SetSize(52, 52)
  local p = ns.db.fofPos
  if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, 140) end
  f:SetMovable(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.fofPos = { point, relPoint, x, y }
  end)
  f:SetScale(ns.db.fofScale or 1)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.fofScale = s
  end)
  f:EnableMouse(false); f:EnableMouseWheel(false)

  local border = f:CreateTexture(nil, "BACKGROUND")
  border:SetPoint("TOPLEFT", -3, 3); border:SetPoint("BOTTOMRIGHT", 3, -3)
  border:SetColorTexture(0.35, 0.8, 1, 1)
  icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetAllPoints()
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalLarge")
  count:SetPoint("BOTTOMRIGHT", -2, 2)
  timer = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  timer:SetPoint("TOP", f, "BOTTOM", 0, -3)
  timer:SetTextColor(0.7, 0.9, 1)
  -- A quick bright flash when the proc lands.
  glow = f:CreateTexture(nil, "OVERLAY")
  glow:SetPoint("TOPLEFT", -10, 10); glow:SetPoint("BOTTOMRIGHT", 10, -10)
  glow:SetColorTexture(0.6, 0.9, 1, 0)
  glow.t = 1
  f:Hide()

  local ticker = CreateFrame("Frame")
  ticker:SetScript("OnUpdate", function(_, elapsed)
    if glow.t < 0.6 then
      glow.t = glow.t + elapsed
      glow:SetColorTexture(0.6, 0.9, 1, math.max(0, 0.6 - glow.t))
    end
    acc = acc + elapsed
    if acc < 0.1 then return end
    acc = 0
    local ok, err = pcall(Update)
    if not ok and not ns.fofErrorShown then
      ns.fofErrorShown = true
      ns.Print("fof: " .. tostring(err))
    end
  end)
end

ns.RegisterModule(Create)

ns.RegisterCommand("fof", true, function()
  ns.db.fofOff = not ns.db.fofOff
  ns.Print(ns.db.fofOff and ns.T("FOF_OFF") or ns.T("FOF_ON"))
end)
ns.RegisterCommand("fofsound", false, function()
  ns.db.fofSoundOff = not ns.db.fofSoundOff
  ns.Print(ns.db.fofSoundOff and ns.T("FOF_SOUND_OFF") or ns.T("FOF_SOUND_ON"))
end)

-- What the game tells us, for working out why the icon doesn't show (run it with the proc up).
ns.RegisterCommand("fofdebug", false, function()
  local function Desc(a)
    if not a then return "nil" end
    local function v(x) if x == nil then return "nil" end if Secret(x) then return "secret" end return tostring(x) end
    return "name " .. v(a.name) .. " id " .. v(a.spellId) .. " stacks " .. v(a.applications)
  end
  local inCombat = UnitAffectingCombat and UnitAffectingCombat("player")
  local a2, id2 = ByID()
  ns.Print("fofdebug: combat " .. tostring(inCombat) .. ", saved id " .. tostring(ns.db.fofSpellId))
  ns.Print("  by name: " .. Desc(ByName()))
  ns.Print("  by id: " .. Desc(a2) .. (id2 and (" (asked " .. id2 .. ")") or "") ..
    ", function " .. tostring(C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID ~= nil))
  local names = {}
  for i = 1, 40 do
    local ok, a = pcall(C_UnitAuras and C_UnitAuras.GetAuraDataByIndex or function() end, "player", i, "HELPFUL")
    if not ok or not a then break end
    local n = a.name
    names[#names + 1] = (Secret(n) and "secret" or tostring(n)) .. ":" .. (Secret(a.spellId) and "secret" or tostring(a.spellId))
  end
  ns.Print("  list: " .. (#names > 0 and table.concat(names, ", ") or "empty"))
end)
