-- @ADDON@: Walk on Air timer (Skyborne racial). Walk on Air lets you glide for 10 seconds;
-- when it runs out you fall like a rock. This shows a big countdown with a bar while it's
-- up, turns red for the last 3 seconds and plays the alert sound then (if sounds are on).
-- Moves with the combat helper ("Move" switch), Ctrl + mouse wheel for size.
local _, ns = ...

local SPELL = "Walk on Air"
local DURATION = 10
local WARN = 3

local f, bar, txt
local castAt          -- when we saw the cast (fallback when the buff can't be read)
local warned = false

-- Seconds left on the buff: number, 0 = not on, nil = can't tell.
local function BuffLeft()
  local now = GetTime()
  for i = 1, 40 do
    local name, expires
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
      if not ok then return nil end
      if not a then break end
      name, expires = a.name, a.expirationTime
    elseif UnitAura then
      local ok, n, _, _, _, _, exp = pcall(UnitAura, "player", i, "HELPFUL")
      if not ok then return nil end
      if not n then break end
      name, expires = n, exp
    else
      return nil
    end
    if issecretvalue and (issecretvalue(name) or issecretvalue(expires)) then return nil end
    if name == SPELL then
      if type(expires) == "number" and expires > 0 then return math.max(0.01, expires - now) end
      return nil -- on, but no end time given: use the cast time
    end
  end
  return 0
end

local function Left()
  local left = BuffLeft()
  if left and left > 0 then return left end
  if castAt then
    local l = DURATION - (GetTime() - castAt)
    -- The buff is readable and gone: you landed or cancelled it.
    if left == 0 and GetTime() - castAt > 0.5 then castAt = nil; return 0 end
    if l > 0 then return l end
    castAt = nil
  end
  return 0
end

local function Show(left, preview)
  local frac = math.max(0, math.min(1, left / DURATION))
  bar:SetWidth(math.max(1, 240 * frac))
  local r, g = 0.3, 1
  if left <= WARN then r, g = 1, 0.25 elseif left <= 6 then r, g = 1, 0.8 end
  bar:SetColorTexture(r, g, 0.3, 0.9)
  local word = left <= WARN and ns.T("GL_LAND") or ns.T("GL_GLIDE")
  txt:SetText(string.format("|cff%02x%02x4c%s %.1f|r", math.floor(r * 255), math.floor(g * 255), word, left))
  f:SetAlpha(preview and 0.6 or 1)
  f:Show()
end

local function Update()
  if not f then return end
  if ns.db.glideOff then f:Hide(); return end
  local left = Left()
  if left > 0 then
    if left <= WARN and not warned then
      warned = true
      if (ns.db.alertSound or "off") ~= "off" and ns.PlayAlertSound then ns.PlayAlertSound() end
    end
    Show(left, false)
  elseif ns.db.shatterUnlocked then
    warned = false
    Show(DURATION, true) -- so you can find and move it
  else
    warned = false
    f:Hide()
  end
end

ns.RegisterModule(function()
  f = CreateFrame("Frame", "@ADDON@GlideFrame", UIParent)
  f:SetSize(260, 52)
  local p = ns.db.glidePos
  if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, 160) end
  f:SetScale(ns.db.glideScale or 1)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) if ns.db.shatterUnlocked then self:StartMoving() end end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.glidePos = { point, relPoint, x, y }
  end)
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked or not IsControlKeyDown() then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.glideScale = s
  end)

  local icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetSize(32, 32)
  icon:SetPoint("LEFT", f, "LEFT", 0, 4)
  icon:SetTexture(ns.SpellIcon(SPELL) or "Interface\\Icons\\INV_Elemental_Primal_Air")
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  txt = f:CreateFontString(nil, "OVERLAY")
  txt:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
  txt:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 2)
  local track = f:CreateTexture(nil, "BACKGROUND")
  track:SetColorTexture(0, 0, 0, 0.5)
  track:SetSize(240, 8)
  track:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -4)
  bar = f:CreateTexture(nil, "ARTWORK")
  bar:SetHeight(8)
  bar:SetPoint("TOPLEFT", track, "TOPLEFT")
  f:Hide()

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
  ev:SetScript("OnEvent", function(_, _, unit, _, spellID)
    if unit ~= "player" then return end
    local name = spellID and ns.SpellInfo(spellID)
    if name == SPELL then castAt = GetTime(); warned = false end
  end)
  local acc = 0
  ev:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 0.05 then return end
    acc = 0
    pcall(Update)
  end)
end)

ns.RegisterCommand("glide", true, function()
  ns.db.glideOff = not ns.db.glideOff
  ns.Print(ns.db.glideOff and ns.T("GL_OFF") or ns.T("GL_ON"))
  pcall(Update)
end)
