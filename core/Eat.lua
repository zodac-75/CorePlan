-- @ADDON@: eating and drinking bars. Food and drink each get their own timer (they can
-- run out at different times): a bar that runs down like the Walk on Air timer, with your
-- health filling up under the food bar and your mana under the drink bar, with the % at the
-- end of each row. A row says
-- "Full!" when that one is full (when the game lets us read it), so you can stop. Moves with the combat helper ("Move" switch), Ctrl + mouse wheel for size.
local _, ns = ...

-- Buff name -> which timers it counts for. "Food & Drink" (and Refreshment) fill both.
local KINDS = { ["Food"] = { eat = true }, ["Drink"] = { drink = true },
  ["Food & Drink"] = { eat = true, drink = true }, ["Refreshment"] = { eat = true, drink = true } }
local ICON = { eat = "Interface\\Icons\\INV_Misc_Food_15", drink = "Interface\\Icons\\INV_Drink_07" }
local WORD = { eat = "EAT_EATING", drink = "EAT_DRINKING" }
local DEFAULT = 30 -- seconds, when the game doesn't say how long the buff lasts
local W = 240
local ROW = 46

local f
local rows = {}   -- eat / drink: { frame, icon, txt, bar, res }
local started = {} -- kind -> when we first saw it (for buffs without an end time)

local function Secret(v) return issecretvalue and issecretvalue(v) or false end

-- Each timer on now: { eat = { left, total }, drink = { left, total } } (missing = not on).
local function Eating()
  local out = {}
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
      local kinds = KINDS[ns.Eng and ns.Eng(name) or name] or KINDS[name]
      for k in pairs(kinds or {}) do
        local left, total
        if not Secret(expires) and type(expires) == "number" and expires > 0 then
          left = expires - now
          total = (not Secret(dur) and type(dur) == "number" and dur > 0) and dur or DEFAULT
        end
        local cur = out[k]
        if not cur or (left and (not cur[1] or left > cur[1])) then out[k] = { left, total } end
      end
    end
  end
  -- No end time from the game: count from when we first saw it.
  for _, k in ipairs({ "eat", "drink" }) do
    local t = out[k]
    if not t then
      started[k] = nil
    elseif not t[1] then
      started[k] = started[k] or now
      t[1], t[2] = math.max(0, DEFAULT - (now - started[k])), DEFAULT
    end
  end
  return out
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

-- True when the value is full, nil when we can't tell.
local function IsFull(cur, max)
  if cur == nil or max == nil or Secret(cur) or Secret(max) then return nil end
  return cur >= max
end

-- The percentage at the end of a row. Readable values are counted here; when the game hides
-- them (mana in WoW Forever) the game writes the number into the text itself.
local function SetPct(fs, k, cur, max)
  if cur ~= nil and max ~= nil and not Secret(cur) and not Secret(max) and max > 0 then
    fs:SetText(math.floor(cur / max * 100 + 0.5) .. "%")
    return
  end
  local fn = rawget(_G, k == "eat" and "UnitHealthPercent" or "UnitPowerPercent")
  if type(fn) == "function" then
    local scale = CurveConstants and CurveConstants.ScaleTo100
    local ok, v
    if k == "eat" then ok, v = pcall(fn, "player", false, scale) else ok, v = pcall(fn, "player", 0, false, scale) end
    if ok and v ~= nil and pcall(fs.SetFormattedText, fs, "%.0f%%", v) then return end
  end
  fs:SetText("")
end

-- One row: what it counts, the time left, and under it the health (food) or mana (drink).
local function ShowRow(k, t, y, preview)
  local r = rows[k]
  r.frame:ClearAllPoints()
  r.frame:SetPoint("TOPLEFT", f, "TOPLEFT", 0, y)
  r.bar:SetWidth(math.max(1, W * math.max(0, math.min(1, t[1] / t[2]))))
  local cur, max
  if k == "eat" then cur, max = Health() else cur, max = Mana() end
  Fill(r.res, cur, max)
  SetPct(r.pct, k, cur, max)
  if not preview and IsFull(cur, max) then
    r.txt:SetText("|cff60ff60" .. ns.T("EAT_FULL") .. "|r")
  else
    r.txt:SetText(string.format("|cff66ccff%s %.0f|r", ns.T(WORD[k]), math.max(0, t[1])))
  end
  r.frame:Show()
end

local function Update()
  if not f then return end
  if ns.db.eatBarOff then f:Hide(); return end
  local now = Eating()
  local preview = false
  if not (now.eat or now.drink) and ns.db.shatterUnlocked then
    -- so you can find and move it
    preview = true
    now = { eat = { DEFAULT, DEFAULT }, drink = { DEFAULT * 0.6, DEFAULT } }
  end
  -- Drinking only matters with mana (no drink row for warriors and rogues).
  if now.drink and ns.HasMana and not ns.HasMana() then now.drink = nil end
  local y = 0
  for _, k in ipairs({ "eat", "drink" }) do
    if now[k] then ShowRow(k, now[k], y, preview); y = y - ROW else rows[k].frame:Hide() end
  end
  if y == 0 then f:Hide(); return end
  f:SetHeight(-y)
  f:SetAlpha(preview and 0.6 or 1)
  f:Show()
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

local function MakeRow(k)
  local r = {}
  r.frame = CreateFrame("Frame", nil, f)
  r.frame:SetSize(W + 20, ROW)
  r.icon = r.frame:CreateTexture(nil, "ARTWORK")
  r.icon:SetSize(28, 28)
  r.icon:SetPoint("TOPLEFT", r.frame, "TOPLEFT", 0, 0)
  r.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  r.icon:SetTexture(ICON[k])
  r.txt = r.frame:CreateFontString(nil, "OVERLAY")
  r.txt:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
  r.txt:SetPoint("LEFT", r.icon, "RIGHT", 8, 0)
  r.pct = r.frame:CreateFontString(nil, "OVERLAY")
  r.pct:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
  r.pct:SetPoint("RIGHT", r.frame, "TOPLEFT", W, -14)
  r.pct:SetJustifyH("RIGHT")
  if k == "eat" then r.pct:SetTextColor(0.4, 1, 0.4) else r.pct:SetTextColor(0.5, 0.7, 1) end
  local track = r.frame:CreateTexture(nil, "BACKGROUND")
  track:SetColorTexture(0, 0, 0, 0.5)
  track:SetSize(W, 7)
  track:SetPoint("TOPLEFT", r.icon, "BOTTOMLEFT", 0, -3)
  r.bar = r.frame:CreateTexture(nil, "ARTWORK")
  r.bar:SetHeight(7)
  r.bar:SetPoint("TOPLEFT", track, "TOPLEFT")
  r.bar:SetColorTexture(k == "eat" and 1 or 0.35, k == "eat" and 0.7 or 0.75, k == "eat" and 0.3 or 1, 0.9)
  if k == "eat" then r.res = StatusBar(r.frame, 0.2, 0.85, 0.2) else r.res = StatusBar(r.frame, 0.25, 0.45, 1) end
  r.res:SetPoint("TOPLEFT", track, "BOTTOMLEFT", 0, -2)
  r.frame:Hide()
  rows[k] = r
end

ns.RegisterModule(function()
  f = CreateFrame("Frame", "@ADDON@EatFrame", UIParent)
  f:SetSize(W + 20, ROW * 2)
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
  MakeRow("eat")
  MakeRow("drink")
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
