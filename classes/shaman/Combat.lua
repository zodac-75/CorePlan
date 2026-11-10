-- @ADDON@: combat helper. Calls out Maelstrom Weapon at 5 stacks (instant Lightning
-- Bolt) and Stormstrike when it is ready (Enhancement: dodges and parries reset it), and reminds you of a missing Lightning Shield, weapon imbue or Flame Shock.
-- (The frame and settings keep their old "shatter" names so profiles stay compatible.)
local _, ns = ...

local MAELSTROM = "Maelstrom Weapon"

local f, big, small, flash
local acc = 0
local lastState

local function Readable(v)
  return type(v) == "number" and not (issecretvalue and issecretvalue(v))
end

local function PlayerHas(buff)
  return ns.ForEachAura("player", "HELPFUL", function(n) return n == buff end)
end

-- Stacks of a buff on you, or nil when the game hides the number.
local function Stacks(buff)
  for i = 1, 40 do
    local name, count
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
      if not ok or not a then return 0 end
      name, count = a.name, a.applications
    elseif UnitAura then
      local ok, n, _, c = pcall(UnitAura, "player", i, "HELPFUL")
      if not ok or not n then return 0 end
      name, count = n, c
    else
      return 0
    end
    if name == buff then
      if Readable(count) then return count end
      return nil
    end
  end
  return 0
end

local function MyDebuffOnTarget(debuff)
  return ns.ForEachAura("target", "HARMFUL|PLAYER", function(n) return n == debuff end)
end

local function HasWeaponImbue()
  if not GetWeaponEnchantInfo then return true end
  local ok, has = pcall(GetWeaponEnchantInfo)
  if not ok or has == nil then return true end
  if issecretvalue and issecretvalue(has) then return true end
  return has and true or false
end

local function Update()
  if ns.db.shatterOff then f:Hide(); return end

  local hasTarget = UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
  local inCombat = UnitAffectingCombat("player")
  local main, state, sub

  -- Maelstrom Weapon: at 5 stacks Lightning Bolt is instant.
  if ns.SpellInfo(MAELSTROM) or PlayerHas(MAELSTROM) then
    local n = Stacks(MAELSTROM)
    if n and n >= 5 then
      state = "go"
      main = ns.AlertMain("|cff@COLOR@", "MAELSTROM 5!", ns.T("SH_GO"), "Lightning Bolt")
    elseif n and n >= 3 and hasTarget then
      main = ns.Alert("|cff88bbff", ns.T("SH_STACKS", n), "Lightning Bolt")
    end
  end

  -- Stormstrike: with Improved Stormstrike every dodge or parry resets its cooldown, so
  -- call it out the moment it's ready again.
  if not main and inCombat and hasTarget and not ns.db.stormstrikeOff and ns.PlanKey() == "enhancement"
    and ns.SpellUsable("Stormstrike") then
    state = "go"
    main = ns.AlertMain("|cff@COLOR@", "STORMSTRIKE!", ns.T("SH_STORMSTRIKE"), "Stormstrike")
  end

  -- Reminders, most important first.
  if (inCombat or hasTarget) and ns.SpellInfo("Lightning Shield")
    and ns.AuraMissing("player", "HELPFUL", "Lightning Shield", "Water Shield", "Earth Shield") then
    sub = ns.Alert("|cffffd100", ns.T("SH_SHIELD"), { "Lightning Shield", "Water Shield" })
  elseif (inCombat or hasTarget) and not HasWeaponImbue() then
    sub = ns.Alert("|cffffd100", ns.T("SH_IMBUE"), { "Windfury Weapon", "Flametongue Weapon", "Rockbiter Weapon" })
  elseif inCombat and hasTarget and ns.PlanKey() ~= "resto" and ns.SpellInfo("Flame Shock") and ns.CooldownLeft("Flame Shock") <= 0
    and ns.AuraMissing("target", "HARMFUL|PLAYER", "Flame Shock") then
    sub = ns.Alert("|cffff9966", ns.T("SH_FLAMESHOCK"), "Flame Shock")
  end

  ns.HelperAlert(main, sub, state)

  local unlocked = ns.db.shatterUnlocked
  if not main and not sub and not unlocked then
    f:Hide()
    lastState = nil
    return
  end

  big:SetText(main or (unlocked and ("|cff888888" .. ns.T("SH_DRAG") .. "|r")) or "")
  small:SetText(sub or "")
  f:Show()

  if state == "go" and lastState ~= "go" then flash:Play() end
  lastState = state
end

local function CreateIndicator()
  f = CreateFrame("Frame", "@ADDON@ShatterFrame", UIParent)
  f:SetSize(360, 56)
  local p = ns.db.shatterPos
  if p then
    f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
  else
    f:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
  end
  f:SetMovable(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.shatterPos = { point, relPoint, x, y }
  end)
  f:EnableMouse(ns.db.shatterUnlocked and true or false)
  f:SetScale(ns.db.shatterScale or 1)
  f:EnableMouseWheel(ns.db.shatterUnlocked and true or false)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.shatterScale = s
  end)

  big = f:CreateFontString(nil, "OVERLAY")
  big:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
  big:SetPoint("TOP", f, "TOP", 0, 0)

  small = f:CreateFontString(nil, "OVERLAY")
  small:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
  small:SetPoint("TOP", big, "BOTTOM", 0, -4)

  flash = f:CreateAnimationGroup()
  local a = flash:CreateAnimation("Alpha")
  a:SetFromAlpha(0.2)
  a:SetToAlpha(1)
  a:SetDuration(0.25)

  f:Hide()

  -- Kör uppdateringen 10 gånger per sekund från en separat frame, så den
  -- fortsätter även när indikatorn är dold.
  local ticker = CreateFrame("Frame")
  ticker:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 0.1 then return end
    acc = 0
    local ok, err = pcall(Update)
    if not ok and not ns.shatterErrorShown then
      ns.shatterErrorShown = true
      ns.Print(ns.T("SH_ERR", tostring(err)))
    end
  end)
end

ns.RegisterModule(function()
  CreateIndicator()
end)

ns.RegisterCommand("combat", true, function()
  ns.db.shatterOff = not ns.db.shatterOff
  ns.Print(ns.db.shatterOff and ns.T("SH_OFF") or ns.T("SH_ON"))
end)

ns.RegisterCommand("move", true, function()
  ns.db.shatterUnlocked = not ns.db.shatterUnlocked
  f:EnableMouse(ns.db.shatterUnlocked and true or false)
  f:EnableMouseWheel(ns.db.shatterUnlocked and true or false)
  if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
  ns.Print(ns.db.shatterUnlocked and ns.T("SH_UNLOCKED") or ns.T("SH_LOCKED"))
end)

ns.RegisterCommand("stormstrike", true, function()
  ns.db.stormstrikeOff = not ns.db.stormstrikeOff
  ns.Print(ns.db.stormstrikeOff and ns.T("SH_SS_OFF") or ns.T("SH_SS_ON"))
end)
