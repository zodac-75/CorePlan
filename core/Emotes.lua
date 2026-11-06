-- @ADDON@: emote easter eggs. When you do one of these emotes on a player who also runs
-- a Plan addon (MagePlan, ShamanPlan, DruidPlan, ...), both of you get a little show:
--   /kiss    a big pulsing heart          /dance   a spinning disco ball with lights
--   /cheer   confetti                     /hug     hearts floating up
--   /wave    a rainbow                    /toast   two mugs clinking
--   /chicken an easter egg that drops in and wobbles
-- The addons talk over a hidden addon-message channel: "E:<EMOTE>" to the target, who
-- answers "EB:<EMOTE>". ("KISS"/"KISSBACK" from older versions still work.)
local _, ns = ...

local PREFIX = "ZodacPlan"
local WHITE = "Interface\\Buttons\\WHITE8X8"
local lastSent, lastShown = {}, {}
local stage, label

local COLORS = {
  { 1, 0.3, 0.3 }, { 1, 0.6, 0.2 }, { 1, 0.9, 0.3 }, { 0.4, 0.9, 0.4 },
  { 0.3, 0.6, 1 }, { 0.7, 0.4, 1 }, { 1, 0.4, 0.8 },
}

local function Short(name)
  return (name or ""):match("^([^%-]+)") or name or "?"
end

local function Sound(kit)
  if PlaySound and SOUNDKIT and SOUNDKIT[kit] then pcall(PlaySound, SOUNDKIT[kit]) end
end

---------------------------------------------------------------------------
-- Building blocks: a texture with its own animation group
---------------------------------------------------------------------------
local pool = {}

local function Piece(texture, w, h)
  local f = table.remove(pool)
  if not f then
    f = CreateFrame("Frame", nil, stage)
    f.tex = f:CreateTexture(nil, "ARTWORK")
    f.tex:SetAllPoints()
  end
  -- A fresh animation group each time, so nothing from an earlier effect lingers.
  if f.ag then f.ag:Stop() end
  f.ag = f:CreateAnimationGroup()
  f.ag:SetScript("OnFinished", function()
    f:Hide()
    table.insert(pool, f)
  end)
  f:SetParent(stage)
  f:SetSize(w, h)
  f:ClearAllPoints()
  f:SetAlpha(1)
  f.tex:SetTexture(texture)
  f.tex:SetTexCoord(0, 1, 0, 1)
  f.tex:SetVertexColor(1, 1, 1, 1)
  f:Show()
  return f
end

-- kind = "Alpha", "Scale", "Translation" or "Rotation".
local function Anim(f, kind, order, duration, delay)
  local a = f.ag:CreateAnimation(kind)
  a:SetOrder(order)
  a:SetDuration(duration)
  a:SetStartDelay(delay or 0)
  if a.SetSmoothing then a:SetSmoothing("NONE") end
  return a
end

local function Fade(f, from, to, order, duration, delay)
  local a = Anim(f, "Alpha", order, duration, delay)
  a:SetFromAlpha(from); a:SetToAlpha(to)
  return a
end

local function Move(f, x, y, order, duration, delay)
  local a = Anim(f, "Translation", order, duration, delay)
  a:SetOffset(x, y)
  return a
end

local function Spin(f, degrees, order, duration, delay)
  local a = Anim(f, "Rotation", order, duration, delay)
  a:SetDegrees(degrees)
  return a
end

local function Grow(f, x, y, order, duration, delay)
  local a = Anim(f, "Scale", order, duration, delay)
  a:SetScale(x, y)
  return a
end

local function Play(f)
  f.ag:Play()
end

local function Say(text)
  label:SetText("|cffffccee" .. text .. "|r")
  label:SetAlpha(1)
  label:Show()
  label.hideAt = GetTime() + 4
end

---------------------------------------------------------------------------
-- The effects
---------------------------------------------------------------------------
local EFFECTS = {}

EFFECTS.KISS = function(from)
  local h = Piece(ns.MEDIA .. "Heart", 256, 256)
  h:SetPoint("CENTER", 0, 80)
  Fade(h, 0, 1, 1, 0.3)
  Grow(h, 1.12, 1.12, 2, 0.18); Grow(h, 1 / 1.12, 1 / 1.12, 3, 0.18)
  Grow(h, 1.12, 1.12, 4, 0.18); Grow(h, 1 / 1.12, 1 / 1.12, 5, 0.18)
  Grow(h, 1.12, 1.12, 6, 0.18); Grow(h, 1 / 1.12, 1 / 1.12, 7, 0.18)
  Fade(h, 1, 0, 8, 0.8, 0.6)
  Play(h)
  Say(ns.T("EM_KISS", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

EFFECTS.DANCE = function(from)
  local ball = Piece(ns.MEDIA .. "Disco", 200, 200)
  ball:SetPoint("CENTER", 0, 140)
  Move(ball, 0, -60, 1, 0.5)
  Fade(ball, 0, 1, 1, 0.5)
  Spin(ball, -360, 2, 1.5); Spin(ball, -360, 3, 1.5); Spin(ball, -360, 4, 1.5)
  Fade(ball, 1, 0, 5, 0.6)
  Play(ball)
  for i = 1, 16 do
    local c = COLORS[(i % #COLORS) + 1]
    local dot = Piece(WHITE, 14, 14)
    dot.tex:SetVertexColor(c[1], c[2], c[3], 1)
    local angle = i / 16 * 2 * math.pi
    dot:SetPoint("CENTER", math.cos(angle) * 230, 80 + math.sin(angle) * 150)
    dot:SetAlpha(0)
    local delay = 0.4 + (i % 4) * 0.12
    for k = 1, 6 do
      Fade(dot, 0, 1, k * 2 - 1, 0.25, k == 1 and delay or 0)
      Fade(dot, 1, 0, k * 2, 0.3)
    end
    Play(dot)
  end
  Say(ns.T("EM_DANCE", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.CHEER = function(from)
  for i = 1, 40 do
    local c = COLORS[(i % #COLORS) + 1]
    local p = Piece(WHITE, math.random(8, 14), math.random(14, 22))
    p.tex:SetVertexColor(c[1], c[2], c[3], 1)
    p:SetPoint("CENTER", math.random(-40, 40), 120)
    local dx, up = math.random(-380, 380), math.random(80, 220)
    Move(p, dx * 0.4, up, 1, 0.35, math.random() * 0.2)
    Move(p, dx * 0.6, -up - math.random(250, 420), 2, 1.6 + math.random() * 0.6)
    Spin(p, math.random(-720, 720), 2, 1.8)
    Fade(p, 1, 0, 3, 0.4)
    Play(p)
  end
  Say(ns.T("EM_CHEER", Short(from)))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

EFFECTS.HUG = function(from)
  for i = 1, 12 do
    local size = math.random(40, 90)
    local h = Piece(ns.MEDIA .. "Heart", size, size)
    h:SetPoint("CENTER", math.random(-260, 260), -120)
    h:SetAlpha(0)
    local delay = (i - 1) * 0.18
    Fade(h, 0, 1, 1, 0.3, delay)
    Move(h, math.random(-60, 60), math.random(260, 380), 2, 2.4)
    Grow(h, 1.3, 1.3, 2, 2.4)
    Fade(h, 1, 0, 3, 0.5)
    Play(h)
  end
  Say(ns.T("EM_HUG", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

EFFECTS.WAVE = function(from)
  local r = Piece(ns.MEDIA .. "Rainbow", 420, 420)
  r:SetPoint("CENTER", 0, 40)
  Fade(r, 0, 1, 1, 0.8)
  Grow(r, 1.05, 1.05, 2, 1.5)
  Fade(r, 1, 0, 3, 1.0, 0.5)
  Play(r)
  Say(ns.T("EM_WAVE", Short(from)))
  Sound("UI_QUEST_LOG_QUEST_ABANDONED")
end

EFFECTS.TOAST = function(from)
  for side = -1, 1, 2 do
    local m = Piece(ns.MEDIA .. "Mug", 170, 170)
    m:SetPoint("CENTER", side * 260, 60)
    if side > 0 then m.tex:SetTexCoord(1, 0, 0, 1) else m.tex:SetTexCoord(0, 1, 0, 1) end
    Fade(m, 0, 1, 1, 0.3)
    Move(m, -side * 170, 0, 2, 0.5)
    Spin(m, side * 15, 3, 0.12); Spin(m, -side * 15, 4, 0.12)
    Move(m, side * 30, 0, 5, 0.25)
    Fade(m, 1, 0, 6, 0.7, 1.2)
    Play(m)
  end
  for i = 1, 10 do
    local c = COLORS[3]
    local s = Piece(WHITE, 8, 8)
    s.tex:SetVertexColor(c[1], c[2], c[3], 1)
    s:SetPoint("CENTER", 0, 110)
    s:SetAlpha(0)
    local a = i / 10 * 2 * math.pi
    Fade(s, 0, 1, 1, 0.05, 0.75)
    Move(s, math.cos(a) * 90, math.sin(a) * 90, 2, 0.5)
    Fade(s, 1, 0, 3, 0.3)
    Play(s)
  end
  Say(ns.T("EM_TOAST", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.CHICKEN = function(from)
  local e = Piece(ns.MEDIA .. "Egg", 180, 180)
  e:SetPoint("CENTER", 0, 380)
  Move(e, 0, -320, 1, 0.45)
  Move(e, 0, 40, 2, 0.15); Move(e, 0, -40, 3, 0.15)
  Spin(e, 14, 4, 0.18); Spin(e, -28, 5, 0.3); Spin(e, 24, 6, 0.28); Spin(e, -16, 7, 0.24); Spin(e, 6, 8, 0.2)
  Fade(e, 1, 0, 9, 0.8, 1.2)
  Play(e)
  Say(ns.T("EM_CHICKEN", Short(from)))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

local function Show(emote, from)
  local fn = EFFECTS[emote]
  if not fn then return end
  if lastShown[emote] and GetTime() - lastShown[emote] < 2 then return end
  lastShown[emote] = GetTime()
  local ok, err = pcall(fn, from)
  if not ok and ns.debug then ns.Print(tostring(err)) end
end
ns.ShowEmoteEgg = Show

---------------------------------------------------------------------------
-- Talking to the other player's addon
---------------------------------------------------------------------------
local function Send(msg, target)
  local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
  if send and target then pcall(send, PREFIX, msg, "WHISPER", target) end
end

local function OnEmote(token, unit)
  if type(token) ~= "string" then return end
  token = token:upper()
  if not EFFECTS[token] then return end
  unit = (type(unit) == "string" and unit ~= "" and unit) or "target"
  if not (UnitExists(unit) and UnitIsPlayer(unit)) or UnitIsUnit(unit, "player") then return end
  local name, realm = UnitName(unit)
  if not name then return end
  local full = (realm and realm ~= "") and (name .. "-" .. realm) or name
  local key = token .. full
  if lastSent[key] and GetTime() - lastSent[key] < 5 then return end
  lastSent[key] = GetTime()
  Send(token == "KISS" and "KISS" or ("E:" .. token), full)
end

local function OnMessage(msg, sender)
  if msg == "KISS" then
    Show("KISS", sender); Send("KISSBACK", sender)
  elseif msg == "KISSBACK" then
    Show("KISS", sender)
  else
    local back, emote = msg:match("^(EB?):(%u+)$")
    if not emote or not EFFECTS[emote] then return end
    Show(emote, sender)
    if back == "E" then Send("EB:" .. emote, sender) end
  end
end

ns.RegisterModule(function()
  stage = CreateFrame("Frame", "@ADDON@Emotes", UIParent)
  stage:SetAllPoints(UIParent)
  stage:SetFrameStrata("FULLSCREEN_DIALOG")
  stage:EnableMouse(false)
  label = stage:CreateFontString(nil, "OVERLAY")
  label:SetFont(STANDARD_TEXT_FONT, 24, "OUTLINE")
  label:SetPoint("CENTER", 0, -80)
  label:Hide()
  stage:SetScript("OnUpdate", function()
    if label:IsShown() and label.hideAt then
      local left = label.hideAt - GetTime()
      if left <= 0 then label:Hide() elseif left < 1 then label:SetAlpha(left) end
    end
  end)

  if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    pcall(C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
  elseif RegisterAddonMessagePrefix then
    pcall(RegisterAddonMessagePrefix, PREFIX)
  end
  if DoEmote then hooksecurefunc("DoEmote", function(token, unit) pcall(OnEmote, token, unit) end) end
  if C_ChatInfo and C_ChatInfo.PerformEmote then
    hooksecurefunc(C_ChatInfo, "PerformEmote", function(token, unit) pcall(OnEmote, token, unit) end)
  end

  local ev = CreateFrame("Frame")
  ev:RegisterEvent("CHAT_MSG_ADDON")
  ev:SetScript("OnEvent", function(_, _, prefix, msg, _, sender)
    if prefix == PREFIX and type(msg) == "string" then pcall(OnMessage, msg, sender) end
  end)
end)

-- Hidden preview: /@SLASH@ egg dance (or kiss, cheer, hug, wave, toast, chicken).
ns.RegisterCommand("egg", false, function(rest)
  local e = (rest or ""):upper():match("(%u+)") or "KISS"
  lastShown[e] = nil
  Show(e, UnitName("player"))
end)
ns.RegisterCommand("heart", false, function() lastShown.KISS = nil; Show("KISS", UnitName("player")) end)
