-- @ADDON@: eating and drinking bar. While you eat or drink it shows how long is left with a
-- bar that runs down (like the Walk on Air timer), and your health and mana filling up under
-- it. It says "Full!" when both are full (when the game lets us read them), so you can stand
-- up and go. Moves with the combat helper ("Move" switch), Ctrl + mouse wheel for size.
local _, ns = ...

local KINDS = { ["Food"] = "eat", ["Drink"] = "drink", ["Food & Drink"] = "both", ["Refreshment"] = "both" }
local ICON = {
  eat = "Interface\\Icons\\INV_Misc_Food_15",
  drink = "Interface\\Icons\\INV_Drink_07",
  both = "Interface\\Icons\\INV_Misc_Food_73CinnamonRoll",
}
local DEFAULT = 30 -- seconds, when the game doesn't say how long the buff lasts
local W = 240

local f, bar, txt, icon, hp, mp
local started = {} -- kind -> when we first saw it (for buffs without an end time)

local function Secret(v) return issecretvalue and issecretvalue(v) or false end

-- What you're doing ("eat", "drink", "both" or nil), seconds left and the buff's full length.
local function Eating()
  local kinds, left, total = {}, nil, nil
  local now = GetTime()
  for i = 1, 40 do
    local name, expires, dur
    if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
      local ok, a = pcall(C_UnitAuras.GetAuraDataByIndex, "player", i, "HELPFUL")
      if not ok or not a then break end
      name, expires, dur = a.name, a.expirationTime, a.duration
    elseif UnitAura then
      local ok, n, _, _, _, d, e = pcall(UnitAura, "player", i, "HELPFUL")
      if not ok or not n then break end
      name, expires, dur = n, e, d
    else
      break
    end
    if not Secret(name) then
      local k = KINDS[ns.Eng and ns.Eng(name) or name] or KINDS[name]
      if k then
        kinds[k] = true
        if not Secret(expires) and type(expires) == "number" and expires > 0 then
          local l = expires - now
          if not left or l > left then
            left = l
            total = (not Secret(dur) and type(dur) == "number" and dur > 0) and dur or DEFAULT
          end
        end
      end
    end
  end
  local kind = (kinds.both or (kinds.eat and kinds.drink)) and "both" or kinds.eat and "eat" or kinds.drink and "drink" or nil
  -- No end time from the game: count from when we first saw it.
  for k in pairs(started) do if k ~= kind then started[k] = nil end end
  if kind and not left then
    started[kind] = started[kind] or now
    left, total = math.max(0, DEFAULT - (now - started[kind])), DEFAULT
  end
  return kind, left, total
end
ns.EatingNow = Eating

-- A unit value, or nil when the game won't answer.
local function Get(fn, ...)
  if type(fn) ~= "function" then return nil end
  local ok, v = pcall(fn, ...)
  if ok then return v end
end
local function Health() return Get(rawget(_G, "UnitHealth"), "player"), Get(rawget(_G, "UnitHealthMax"), "player") end
local function Mana() return Get(rawget(_G, "UnitPower"), "player", 0), Get(rawget(_G, "UnitPowerMax"), "player", 0) end

-- Fill a status bar with a unit value; the game takes secret values here itself.
local function Fill(sb, cur, max)
  if cur == nil or max == nil then return false end
  local ok = pcall(sb.SetMinMaxValues, sb, 0, max)
  if ok then ok = pcall(sb.SetValue, sb, cur) end
  return ok
end

-- True when health and mana are both full, nil when we can't tell.
local function Full()
  local h, hm = Health()
  if h == nil or hm == nil or Secret(h) or Secret(hm) then return nil end
  local full = h >= hm
  if ns.HasMana and ns.HasMana() then
    local m, mm = Mana()
    if m == nil or mm == nil or Secret(m) or Secret(mm) then return nil end
    full = full and m >= mm
  end
  return full
end

local WORD = { eat = "EAT_EATING", drink = "EAT_DRINKING", both = "EAT_BOTH" }

local function Show(kind, left, total, preview)
  icon:SetTexture(ICON[kind])
  bar:SetWidth(math.max(1, W * math.max(0, math.min(1, left / total))))
  bar:SetColorTexture(0.35, 0.75, 1, 0.9)
  Fill(hp, Health())
  local mana = ns.HasMana and ns.HasMana()
  if mana then Fill(mp, Mana()); mp:Show() else mp:Hide() end
  local full = not preview and Full()
  if full then
    txt:SetText("|cff60ff60" .. ns.T("EAT_FULL") .. "|r")
  else
    txt:SetText(string.format("|cff66ccff%s %.0f|r", ns.T(WORD[kind]), math.max(0, left)))
  end
  f:SetAlpha(preview and 0.6 or 1)
  f:Show()
end

local function Update()
  if not f then return end
  if ns.db.eatBarOff then f:Hide(); return end
  local kind, left, total = Eating()
  if kind then
    Show(kind, left, total, false)
  elseif ns.db.shatterUnlocked then
    Show("both", DEFAULT, DEFAULT, true) -- so you can find and move it
  else
    f:Hide()
  end
end

local function StatusBar(parent, r, g, b)
  local sb = CreateFrame("StatusBar", nil, parent)
  sb:SetSize(W, 5)
  sb:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  sb:SetStatusBarColor(r, g, b, 0.9)
  sb:SetMinMaxValues(0, 1)
  sb:SetValue(0)
  local bg = sb:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints()
  bg:SetColorTexture(0, 0, 0, 0.5)
  return sb
end

ns.RegisterModule(function()
  f = CreateFrame("Frame", "@ADDON@EatFrame", UIParent)
  f:SetSize(W + 20, 62)
  local p = ns.db.eatPos
  if p then f:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else f:SetPoint("CENTER", UIParent, "CENTER", 0, 100) end
  f:SetScale(ns.db.eatScale or 1)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", function(self) if ns.db.shatterUnlocked then self:StartMoving() end end)
  f:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    ns.db.eatPos = { point, relPoint, x, y }
  end)
  f:EnableMouseWheel(true)
  f:SetScript("OnMouseWheel", function(self, delta)
    if not ns.db.shatterUnlocked or not IsControlKeyDown() then return end
    local s = math.max(0.5, math.min(2.5, self:GetScale() + delta * 0.1))
    self:SetScale(s)
    ns.db.eatScale = s
  end)

  icon = f:CreateTexture(nil, "ARTWORK")
  icon:SetSize(32, 32)
  icon:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  txt = f:CreateFontString(nil, "OVERLAY")
  txt:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
  txt:SetPoint("TOPLEFT", icon, "TOPRIGHT", 8, 2)
  local track = f:CreateTexture(nil, "BACKGROUND")
  track:SetColorTexture(0, 0, 0, 0.5)
  track:SetSize(W, 8)
  track:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -4)
  bar = f:CreateTexture(nil, "ARTWORK")
  bar:SetHeight(8)
  bar:SetPoint("TOPLEFT", track, "TOPLEFT")
  hp = StatusBar(f, 0.2, 0.85, 0.2)
  hp:SetPoint("TOPLEFT", track, "BOTTOMLEFT", 0, -3)
  mp = StatusBar(f, 0.25, 0.45, 1)
  mp:SetPoint("TOPLEFT", hp, "BOTTOMLEFT", 0, -2)
  f:Hide()

  local ev = CreateFrame("Frame")
  local acc = 0
  ev:SetScript("OnUpdate", function(_, elapsed)
    acc = acc + elapsed
    if acc < 0.1 then return end
    acc = 0
    local ok, err = pcall(Update)
    if not ok then ns.eatLastError = err end
    if not ok and not ns.eatErrorShown then
      ns.eatErrorShown = true
      ns.Print("eat bar: " .. tostring(err))
    end
  end)
end)

ns.RegisterCommand("eatbar", true, function()
  ns.db.eatBarOff = not ns.db.eatBarOff
  ns.Print(ns.db.eatBarOff and ns.T("EAT_OFF") or ns.T("EAT_ON"))
  pcall(Update)
end)
