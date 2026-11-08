-- @ADDON@: out-of-combat alert. Low mana and not drinking: a big "Drink!" with an icon,
-- a short flash and the alert sound (if sounds are on for all reminders). Other modules
-- add lines with ns.AddRestAlert (mage: low on conjured water). Moves with the combat
-- helper ("Move" switch), mouse wheel for size.
local _, ns = ...

local f, big, small
local sf, sbig -- the drink line when the game hides your mana (see SecretDrink)
local DRINK_BUFFS = { ["Drink"] = true, ["Food & Drink"] = true, ["Refreshment"] = true }

-- Mana in percent, or nil when the game hides the value from addons ("secret" values).
local function Readable(v)
  return type(v) == "number" and not (issecretvalue and issecretvalue(v))
end

-- False for classes without mana (warriors), so nothing nags them to drink.
function ns.HasMana()
  if ns.NO_MANA then return false end
  local ok, max = pcall(UnitPowerMax, "player", 0)
  if ok and Readable(max) then return max > 0 end
  return true
end

function ns.ManaPct()
  if not ns.HasMana() then return nil end
  local ok, pct = pcall(function()
    local cur, max = UnitPower("player", 0), UnitPowerMax("player", 0)
    if Readable(cur) and Readable(max) and max > 0 then return cur / max * 100 end
  end)
  if ok and pct then return pct end
  if UnitPowerPercent then
    local scale = CurveConstants and CurveConstants.ScaleTo100
    local ok2, p = pcall(UnitPowerPercent, "player", 0, false, scale)
    if ok2 and Readable(p) then
      if not scale and p <= 1 then p = p * 100 end
      return p
    end
  end
  return nil
end

-- Other out-of-combat reminders can join the same alert (mage: low on water).
-- fn() returns text, icon or nil.
local extra = {}
function ns.AddRestAlert(fn) table.insert(extra, fn) end

local shownKey, flash

local function DrinkLine()
  if ns.db.drinkOff then return nil end
  local pct = ns.ManaPct()
  if not pct then return nil end
  local drinking = ns.ForEachAura("player", "HELPFUL", function(n) return DRINK_BUFFS[n] end)
  if pct < (ns.db.drinkPct or 40) and not drinking then
    return ns.T("DRINK", math.floor(pct)), "Interface\\Icons\\INV_Drink_07"
  end
end

local function Line(text, icon, big)
  local size = big and 30 or 20
  local tag = icon and ("|T" .. icon .. ":" .. size .. ":" .. size .. ":0:0:64:64:5:59:5:59|t ") or ""
  return tag .. text
end

---------------------------------------------------------------------------
-- When the game hides your current mana from addons ("secret"), the addon can't compare
-- it with your drink %. Instead it hands the game a rule, a curve that is 1 below your
-- drink % and 0 above it, and lets the game set the alert's transparency from it: the
-- alert shows when you're low without the addon ever seeing the number.
---------------------------------------------------------------------------
local curve, curveAt

local function LowCurve()
  local at = ns.db.drinkPct or 40
  if curve and curveAt == at then return curve end
  if not (C_CurveUtil and C_CurveUtil.CreateCurve) then return nil end
  local ok, c = pcall(C_CurveUtil.CreateCurve)
  if not ok or not c then return nil end
  if Enum and Enum.LuaCurveType and Enum.LuaCurveType.Step and c.SetType then
    pcall(c.SetType, c, Enum.LuaCurveType.Step)
  end
  local x = at / 100
  -- Also right if the curve is linear: 1 up to just under the line, then 0.
  for _, pt in ipairs({ { 0, 1 }, { math.max(0, x - 0.001), 1 }, { x, 0 }, { 1, 0 } }) do
    local okP = pcall(c.AddPoint, c, pt[1], pt[2])
    if not okP then return nil end
  end
  curve, curveAt = c, at
  return c
end

local function SecretDrink()
  if not (sf and UnitPowerPercent) then return false end
  local c = LowCurve()
  if not c then return false end
  local ok, v = pcall(UnitPowerPercent, "player", 0, false, c)
  if not ok or v == nil then return false end
  if not pcall(sf.SetAlpha, sf, v) then return false end
  local tag = "|TInterface\\Icons\\INV_Drink_07:30:30:0:0:64:64:5:59:5:59|t |cff66ccff"
  local okP, pct = pcall(UnitPowerPercent, "player", 0, false, CurveConstants and CurveConstants.ScaleTo100)
  local shown = okP and pct ~= nil and pcall(sbig.SetFormattedText, sbig, tag .. ns.T("DRINK") .. "|r", pct)
  if not shown then sbig:SetText(tag .. ns.T("DRINK_LOW") .. "|r") end
  sf:Show()
  return true
end

local function Check()
  if not f then return end
  -- Hidden mana: the game decides when the drink line shows (out of combat, not drinking).
  local secretShown = false
  if not ns.db.drinkOff and ns.HasMana() and not ns.ManaPct()
    and not (UnitAffectingCombat("player") or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))
      or (UnitOnTaxi and UnitOnTaxi("player"))) then
    local drinking = ns.ForEachAura("player", "HELPFUL", function(n) return DRINK_BUFFS[n] end)
    if not drinking then secretShown = SecretDrink() end
  end
  if not secretShown and sf then sf:Hide() end
  local busy = UnitAffectingCombat("player") or (UnitIsDeadOrGhost and UnitIsDeadOrGhost("player"))
    or (UnitOnTaxi and UnitOnTaxi("player"))
  local lines = {}
  if not busy then
    local t, icon = DrinkLine()
    if t then table.insert(lines, { t, icon, "|cff66ccff" }) end
    for _, fn in ipairs(extra) do
      local ok, et, eicon = pcall(fn)
      if ok and et then table.insert(lines, { et, eicon, "|cffffd100" }) end
    end
  end
  if #lines == 0 then
    if ns.db.shatterUnlocked and (ns.HasMana() or #extra > 0) then
      -- So you can find it and move it with the combat helper.
      big:SetText("|cff888888" .. Line(ns.T("DRINK_DRAG"), "Interface\\Icons\\INV_Drink_07", true) .. "|r")
      small:SetText("")
      f:SetAlpha(0.7)
      f:Show()
    else
      f:Hide()
    end
    shownKey = nil
    return
  end
  f:SetAlpha(1)
  big:SetText(lines[1][3] .. Line(lines[1][1], lines[1][2], true) .. "|r")
  local rest = {}
  for k = 2, #lines do table.insert(rest, lines[k][3] .. Line(lines[k][1], lines[k][2]) .. "|r") end
  small:SetText(table.concat(rest, "\n"))
  f:Show()
  -- Flash and the alert sound when it first shows up (not on every mana tick).
  local key = #lines .. lines[1][2]
  if shownKey ~= key then
    if flash then flash:Play() end
    if (ns.db.alertSound or "off") == "all" and ns.PlayAlertSound then ns.PlayAlertSound() end
  end
  shownKey = key
end
-- Runs Check and reports the first error in chat instead of failing silently.
local errShown
local function SafeCheck()
  local ok, err = pcall(Check)
  if not ok and not errShown then
    errShown = true
    ns.Print(ns.T("ERROR", tostring(err)))
  end
end
ns.RefreshRestAlert = SafeCheck

ns.RegisterModule(function()
  f = CreateFrame("Frame", "@ADDON@DrinkFrame", UIParent)
  f:SetSize(380, 60)
  local p = ns.db.drinkPos
  if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, -40) end
  f:SetScale(ns.db.drinkScale or 1)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) if ns.db.shatterUnlocked then self:StartMoving() end end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.drinkPos = { point, relPoint, x, y }
  end)
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked then return end
    local sc = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(sc)
    ns.db.drinkScale = sc
  end)
  big = f:CreateFontString(nil, "OVERLAY")
  big:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
  big:SetPoint("TOP", f, "TOP", 0, 0)
  small = f:CreateFontString(nil, "OVERLAY")
  small:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
  small:SetPoint("TOP", big, "BOTTOM", 0, -4)
  sf = CreateFrame("Frame", "@ADDON@DrinkFrame2", UIParent)
  sf:SetSize(380, 32)
  sf:SetPoint("BOTTOM", f, "TOP", 0, 2)
  sbig = sf:CreateFontString(nil, "OVERLAY")
  sbig:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
  sbig:SetPoint("CENTER")
  sf:Hide()
  flash = f:CreateAnimationGroup()
  local a = flash:CreateAnimation("Alpha")
  a:SetFromAlpha(0.2)
  a:SetToAlpha(1)
  a:SetDuration(0.3)
  f:Hide()

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("PLAYER_REGEN_ENABLED")
  ev:RegisterEvent("PLAYER_REGEN_DISABLED")
  ev:RegisterEvent("UNIT_POWER_UPDATE")
  ev:RegisterEvent("UNIT_AURA")
  ev:RegisterEvent("PLAYER_ENTERING_WORLD")
  ev:RegisterEvent("BAG_UPDATE")
  ev:SetScript("OnEvent", function(_, event, unit)
    if (event == "UNIT_POWER_UPDATE" or event == "UNIT_AURA") and unit ~= "player" then return end
    ns.Debounce("drink", 0.2, SafeCheck)
  end)
  -- The "Move" switch shows a preview; check now and then so it follows.
  local acc = 0
  ev:SetScript("OnUpdate", function(_, e)
    acc = acc + e
    if acc < 1 then return end
    acc = 0
    SafeCheck()
  end)
end)

ns.RegisterCommand("drink", not ns.NO_MANA, function()
  ns.db.drinkOff = not ns.db.drinkOff
  ns.Print(ns.db.drinkOff and ns.T("DRINK_OFF") or ns.T("DRINK_ON"))
  SafeCheck()
end)

ns.RegisterCommand("drinkat", not ns.NO_MANA, function(rest)
  local n = tonumber((rest or ""):match("(%d+)"))
  if n and n > 0 and n < 100 then
    ns.db.drinkPct = n
    ns.Print(ns.T("DRINK_SET", n))
    SafeCheck()
  end
end)

-- /@SLASH@ drinktest: what the drink alert sees right now (for bug reports).
ns.RegisterCommand("drinktest", false, function()
  local okP, pct = pcall(ns.ManaPct)
  local raw = {}
  for _, fn in ipairs({ "UnitPower", "UnitPowerMax", "UnitPowerPercent" }) do
    local g = _G[fn]
    if g then
      local ok, v = pcall(g, "player", 0)
      raw[#raw + 1] = fn .. "=" .. ((issecretvalue and ok and issecretvalue(v)) and "secret" or tostring(ok and v or "error"))
    else
      raw[#raw + 1] = fn .. "=missing"
    end
  end
  ns.Print(string.format("drink: off=%s mana%%=%s (at %s%%) combat=%s shown=%s",
    tostring(ns.db.drinkOff), okP and tostring(pct) or ("error " .. tostring(pct)),
    tostring(ns.db.drinkPct or 40), tostring(UnitAffectingCombat("player")), tostring(f and f:IsShown())))
  ns.Print("  " .. table.concat(raw, "  "))
  ns.Print(string.format("  InCombatLockdown=%s C_CurveUtil=%s CurveConstants=%s SetAlphaFromBoolean=%s",
    tostring(InCombatLockdown and InCombatLockdown()), tostring(C_CurveUtil ~= nil), tostring(CurveConstants ~= nil),
    tostring(f and f.SetAlphaFromBoolean ~= nil)))
  local ok, err = pcall(Check)
  if not ok then ns.Print("  error: " .. tostring(err)) end
end)
