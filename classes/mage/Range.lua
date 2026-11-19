-- @ADDON@: range icon. Shows your main nuke (Frostbolt, or Fireball with the Fire plan or
-- before you know Frostbolt) while you have an enemy target: red when the target is out of
-- range, full colour when you can cast on it. Moves with "Unlock UI" like the shatter helper.
local _, ns = ...

local FROSTBOLT, FIREBALL = 116, 133
local f, icon, border
local acc = 0
local lastUnlocked

local function Known(id)
  for _, fn in ipairs({ rawget(_G, "IsPlayerSpell"), rawget(_G, "IsSpellKnown") }) do
    local ok, r = pcall(fn, id)
    if ok and r then return true end
  end
  return false
end

local function Nuke()
  if ns.PlanKey and ns.PlanKey() == "fire" then return FIREBALL end
  if Known(FROSTBOLT) then return FROSTBOLT end
  return FIREBALL
end
ns.RangeSpell = Nuke

local function Texture(id)
  if C_Spell and C_Spell.GetSpellTexture then
    local ok, t = pcall(C_Spell.GetSpellTexture, id)
    if ok and t then return t end
  end
  if GetSpellTexture then
    local ok, t = pcall(GetSpellTexture, id)
    if ok and t then return t end
  end
  return id == FIREBALL and "Interface\\Icons\\Spell_Fire_FlameBolt" or "Interface\\Icons\\Spell_Frost_FrostBolt02"
end

local function Secret(v) return issecretvalue and issecretvalue(v) or false end

-- true / false, the game's secret answer, or nil when it can't tell.
local function InRange(id)
  local fn = C_Spell and C_Spell.IsSpellInRange
  local ok, r
  if fn then ok, r = pcall(fn, id, "target") end
  if not (ok and r ~= nil) and IsSpellInRange then
    ok, r = pcall(IsSpellInRange, ns.SpellInfo(id) or ns.Loc(id == FIREBALL and "Fireball" or "Frostbolt"), "target")
  end
  if not ok or r == nil then return nil end
  if Secret(r) then return r, true end
  return r == true or r == 1
end
ns.RangeCheck = InRange

local RED, CLEAR = { 1, 0.25, 0.25 }, { 1, 1, 1 }

local function Paint(state)
  if state == true then
    icon:SetVertexColor(1, 1, 1); icon:SetDesaturated(false); f:SetAlpha(1)
    border:SetVertexColor(0.3, 0.75, 1)
  elseif state == false then
    icon:SetVertexColor(RED[1], RED[2], RED[3]); icon:SetDesaturated(false); f:SetAlpha(0.9)
    border:SetVertexColor(1, 0.15, 0.15)
  else -- can't tell
    icon:SetVertexColor(0.8, 0.8, 0.8); icon:SetDesaturated(true); f:SetAlpha(0.8)
    border:SetVertexColor(0.5, 0.5, 0.5)
  end
end

local function Enemy()
  if not UnitExists("target") then return false end
  local ok, can = pcall(UnitCanAttack, "player", "target")
  if not ok or Secret(can) or not can then return false end
  local ok2, dead = pcall(UnitIsDeadOrGhost, "target")
  if ok2 and not Secret(dead) and dead then return false end
  return true
end

local function Update()
  local unlocked = ns.db.shatterUnlocked and true or false
  if unlocked ~= lastUnlocked then
    lastUnlocked = unlocked
    f:EnableMouse(unlocked); f:EnableMouseWheel(unlocked)
  end
  if ns.db.rangeOff then f:Hide(); return end
  local id = Nuke()
  icon:SetTexture(Texture(id))
  if not Enemy() then
    if unlocked then Paint(true); f:Show() else f:Hide() end
    return
  end
  local r, secret = InRange(id)
  if secret then
    -- The game hides the answer from addons: let it colour the icon itself if it can.
    if icon.SetVertexColorFromBoolean and CreateColor then
      icon:SetDesaturated(false); f:SetAlpha(1)
      icon:SetVertexColorFromBoolean(r, CreateColor(1, 1, 1, 1), CreateColor(RED[1], RED[2], RED[3], 1))
      border:SetVertexColor(0.5, 0.5, 0.5)
    elseif f.SetAlphaFromBoolean then
      Paint(true); f:SetAlphaFromBoolean(r, 1, 0.35)
    else
      Paint(nil)
    end
  else
    Paint(r)
  end
  f:Show()
end

local function Create()
  f = CreateFrame("Frame", "@ADDON@RangeFrame", UIParent)
  f:SetSize(40, 40)
  local p = ns.db.rangePos
  if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, -215) end
  f:SetMovable(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) self:StartMoving() end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.rangePos = { point, relPoint, x, y }
  end)
  f:SetScale(ns.db.rangeScale or 1)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.rangeScale = s
  end)
  f:EnableMouse(false); f:EnableMouseWheel(false)

  border = f:CreateTexture(nil, "BACKGROUND")
  border:SetPoint("TOPLEFT", -2, 2); border:SetPoint("BOTTOMRIGHT", 2, -2)
  border:SetColorTexture(1, 1, 1, 1)
  icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetAllPoints()
  icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  f:Hide()

  local ticker = CreateFrame("Frame")
  ticker:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 0.1 then return end
    acc = 0
    local ok, err = pcall(Update)
    if not ok and not ns.rangeErrorShown then
      ns.rangeErrorShown = true
      ns.Print("range: " .. tostring(err))
    end
  end)
end

ns.RegisterModule(Create)

ns.RegisterCommand("range", true, function()
  ns.db.rangeOff = not ns.db.rangeOff
  ns.Print(ns.db.rangeOff and ns.T("RANGE_OFF") or ns.T("RANGE_ON"))
end)

-- What the game answers, for player reports.
ns.RegisterCommand("rangedebug", false, function()
  local id = Nuke()
  local r, secret = InRange(id)
  ns.Print("rangedebug: spell " .. id .. ", enemy target " .. tostring(Enemy()) .. ", in range "
    .. (secret and "secret" or tostring(r)) .. ", colour by game "
    .. tostring(icon and icon.SetVertexColorFromBoolean ~= nil) .. "/" .. tostring(f and f.SetAlphaFromBoolean ~= nil))
end)
