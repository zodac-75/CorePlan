-- @ADDON@: combat helper. In Cat Form it calls out Clearcasting (free attack) and
-- 5 combo points (Rip / Ferocious Bite); it also reminds you of a missing Mark of the
-- Wild or Thorns, and Rake on your target.
-- (The frame and settings keep their old "shatter" names so profiles stay compatible.)
local _, ns = ...

local f, big, small, flash
local acc = 0
local lastState

local function Readable(v)
  return type(v) == "number" and not (issecretvalue and issecretvalue(v))
end

local function PlayerHas(buff)
  return ns.ForEachAura("player", "HELPFUL", function(n) return n == buff end)
end

local function MyDebuffOnTarget(debuff)
  return ns.ForEachAura("target", "HARMFUL|PLAYER", function(n) return n == debuff end)
end

local function InCatForm()
  return PlayerHas("Cat Form")
end

-- Combo points on the target, or nil when the game hides the number.
local function ComboPoints()
  local ok, n
  if GetComboPoints then
    ok, n = pcall(GetComboPoints, "player", "target")
  elseif UnitPower and Enum and Enum.PowerType and Enum.PowerType.ComboPoints then
    ok, n = pcall(UnitPower, "player", Enum.PowerType.ComboPoints)
  end
  if ok and Readable(n) then return n end
  return nil
end

local function Update()
  if ns.db.shatterOff then f:Hide(); return end

  local hasTarget = UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
  local inCombat = UnitAffectingCombat("player")
  local cat = InCatForm()
  local main, state, sub

  if cat and hasTarget then
    local cp = ComboPoints()
    if PlayerHas("Clearcasting") then
      state = "go"
      main = "|cff@COLOR@CLEARCASTING!|r " .. ns.T("SH_GO")
    elseif cp and cp >= 5 then
      state = "go"
      main = "|cff@COLOR@" .. ns.T("SH_CP5") .. "|r " .. (MyDebuffOnTarget("Rip") and ns.T("SH_BITE") or ns.T("SH_RIP"))
    elseif cp and cp >= 3 then
      main = "|cffffcc88" .. ns.T("SH_STACKS", cp) .. "|r"
    end
  end

  -- Reminders, most important first.
  if (inCombat or hasTarget) and ns.SpellInfo("Mark of the Wild") and not PlayerHas("Mark of the Wild")
    and not PlayerHas("Gift of the Wild") then
    sub = "|cffffd100" .. ns.T("SH_SHIELD") .. "|r"
  elseif (inCombat or hasTarget) and ns.SpellInfo("Thorns") and not PlayerHas("Thorns") then
    sub = "|cffffd100" .. ns.T("SH_IMBUE") .. "|r"
  elseif cat and inCombat and hasTarget and ns.SpellInfo("Rake") and not MyDebuffOnTarget("Rake") then
    sub = "|cffff9966" .. ns.T("SH_FLAMESHOCK") .. "|r"
  end

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
  ns.Print(ns.db.shatterUnlocked and ns.T("SH_UNLOCKED") or ns.T("SH_LOCKED"))
end)
