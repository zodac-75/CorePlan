-- @ADDON@: shatter-indikator. Säger till när målet är fryst eller Fingers of Frost
-- har procat och Ice Lance är redo, samt när Ice Barrier saknas.
local _, ns = ...

local FROZEN = { ["Frost Nova"] = true, ["Frostbite"] = true, ["Freeze"] = true, ["Frozen"] = true }
local FOF = "Fingers of Frost"

local f, big, small, flash
local acc = 0
local lastState

local function PlayerHas(buff)
  return ns.ForEachAura("player", "HELPFUL", function(n) return n == buff end)
end

local function TargetFrozen()
  return ns.ForEachAura("target", "HARMFUL", function(n) return FROZEN[n] end)
end

local function Update()
  if ns.db.shatterOff then f:Hide(); return end

  local hasTarget = UnitExists("target") and UnitCanAttack("player", "target") and not UnitIsDead("target")
  local main, state, sub

  if hasTarget and ns.SpellInfo("Ice Lance") then
    local fof = PlayerHas(FOF)
    local frozen = TargetFrozen()
    if fof or frozen then
      local cd = ns.CooldownLeft("Ice Lance")
      if cd <= 0 then
        state = "go"
        main = "|cff66ccffSHATTER!|r " .. ns.T("SH_GO") .. " |cffaaaaaa" .. (fof and ns.T("SH_FOF") or ns.T("SH_FROZEN")) .. "|r"
      else
        state = "cd"
        main = "|cffaaaaaa" .. ns.T("SH_CD", cd) .. "|r"
      end
    end
  end

  if ns.SpellInfo("Ice Barrier") and (UnitAffectingCombat("player") or hasTarget)
    and ns.AuraMissing("player", "HELPFUL", "Ice Barrier") and ns.CooldownLeft("Ice Barrier") <= 0 then
    sub = "|cffffd100" .. ns.T("SH_BARRIER") .. "|r"
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

ns.RegisterCommand("shatter", true, function()
  ns.db.shatterOff = not ns.db.shatterOff
  ns.Print(ns.db.shatterOff and ns.T("SH_OFF") or ns.T("SH_ON"))
end)

ns.RegisterCommand("move", true, function()
  ns.db.shatterUnlocked = not ns.db.shatterUnlocked
  f:EnableMouse(ns.db.shatterUnlocked and true or false)
  f:EnableMouseWheel(ns.db.shatterUnlocked and true or false)
  ns.Print(ns.db.shatterUnlocked and ns.T("SH_UNLOCKED") or ns.T("SH_LOCKED"))
end)
