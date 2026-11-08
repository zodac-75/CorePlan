-- @ADDON@: out-of-combat alert. Low mana and not drinking: a big "Drink!" with an icon,
-- a short flash and the alert sound (if sounds are on for all reminders). Other modules
-- add lines with ns.AddRestAlert (mage: low on conjured water). Moves with the combat
-- helper ("Move" switch), mouse wheel for size.
local _, ns = ...

local f, big, small
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

local function Check()
  if not f then return end
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
ns.RefreshRestAlert = function() pcall(Check) end

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
    ns.Debounce("drink", 0.2, Check)
  end)
  -- The "Move" switch shows a preview; check now and then so it follows.
  local acc = 0
  ev:SetScript("OnUpdate", function(_, e)
    acc = acc + e
    if acc < 1 then return end
    acc = 0
    pcall(Check)
  end)
end)

ns.RegisterCommand("drink", not ns.NO_MANA, function()
  ns.db.drinkOff = not ns.db.drinkOff
  ns.Print(ns.db.drinkOff and ns.T("DRINK_OFF") or ns.T("DRINK_ON"))
  pcall(Check)
end)

ns.RegisterCommand("drinkat", not ns.NO_MANA, function(rest)
  local n = tonumber((rest or ""):match("(%d+)"))
  if n and n > 0 and n < 100 then
    ns.db.drinkPct = n
    ns.Print(ns.T("DRINK_SET", n))
    pcall(Check)
  end
end)
