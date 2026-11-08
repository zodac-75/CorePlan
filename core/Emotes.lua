-- @ADDON@: emote easter eggs. When you do one of these emotes on a player who also runs
-- a Plan addon (MagePlan, ShamanPlan, DruidPlan, ...), both of you get a little show:
--   /kiss    a big pulsing heart          /dance   a spinning disco ball with lights
--   /cheer   confetti                     /hug     hearts floating up
--   /wave    a rainbow                    /drink   two mugs clinking (or /toast)
--   /chicken an easter egg that drops in and wobbles
--   /train   a little train chugs across  /sleep   Z z z floats up
--   /laugh   bouncing HA HA HA             /salute  fireworks (also /applaud, /clap)
--   /cry     a rain cloud drizzles         /flex    a strong arm and gold stars
-- Dance party: /dance at each other within 30 seconds for a much bigger disco.
-- Ding party: when a Plan user in your group or guild levels up, everyone with a Plan
-- addon gets fireworks. Your own ding and finishing the talent plan get one too.
-- All of it can be turned off with /@SLASH@ eggs (or the box in the settings).
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

-- A piece of big outlined text (letters for Z z z, HA HA, LEVEL 30).
local textPool = {}
local function TextPiece(text, size, r, g, b)
  local f = table.remove(textPool)
  if not f then
    f = CreateFrame("Frame", nil, stage)
    f.fs = f:CreateFontString(nil, "OVERLAY")
    f.fs:SetAllPoints()
  end
  if f.ag then f.ag:Stop() end
  f.ag = f:CreateAnimationGroup()
  f.ag:SetScript("OnFinished", function()
    f:Hide()
    table.insert(textPool, f)
  end)
  f:SetParent(stage)
  f.fs:SetFont(STANDARD_TEXT_FONT, size, "THICKOUTLINE")
  f.fs:SetText(text)
  f.fs:SetTextColor(r or 1, g or 1, b or 1, 1)
  f:SetSize(size * (#text + 1), size * 1.4)
  f:ClearAllPoints()
  f:SetAlpha(1)
  f:Show()
  return f
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

-- Fireworks: rockets that shoot up and burst into colored stars.
local function Fireworks(count, spread)
  for i = 1, count do
    local delay = (i - 1) * 0.35 + math.random() * 0.2
    local x, y = math.random(-spread, spread), math.random(60, 260)
    local c = COLORS[math.random(#COLORS)]
    local rocket = Piece(WHITE, 4, 18)
    rocket.tex:SetVertexColor(1, 0.95, 0.7, 1)
    rocket:SetPoint("CENTER", x, -260)
    rocket:SetAlpha(0)
    Fade(rocket, 0, 1, 1, 0.05, delay)
    Move(rocket, 0, y + 260, 2, 0.6)
    Fade(rocket, 1, 0, 3, 0.1)
    Play(rocket)
    for k = 1, 14 do
      local a = k / 14 * 2 * math.pi
      local s = Piece(ns.MEDIA .. "Star", 22, 22)
      s.tex:SetVertexColor(c[1], c[2], c[3], 1)
      s:SetPoint("CENTER", x, y)
      s:SetAlpha(0)
      Fade(s, 0, 1, 1, 0.05, delay + 0.65)
      local dist = math.random(90, 150)
      Move(s, math.cos(a) * dist, math.sin(a) * dist, 2, 0.7)
      Spin(s, 180, 2, 0.7)
      Move(s, 0, -40, 3, 0.6)
      Fade(s, 1, 0, 3, 0.6)
      Play(s)
    end
  end
end

EFFECTS.TRAIN = function(from)
  local t = Piece(ns.MEDIA .. "Train", 512, 160)
  t:SetPoint("CENTER", -(UIParent:GetWidth() / 2 + 300), -40)
  Move(t, UIParent:GetWidth() + 600, 0, 1, 4.2)
  Play(t)
  -- Puffs of smoke from the chimney as it goes.
  for i = 1, 12 do
    local p = Piece(WHITE, 26, 26)
    p.tex:SetVertexColor(0.9, 0.9, 0.95, 0.8)
    local x = -(UIParent:GetWidth() / 2 + 300) + (UIParent:GetWidth() + 600) * (i / 13) + 180
    p:SetPoint("CENTER", x, 40)
    p:SetAlpha(0)
    Fade(p, 0, 0.8, 1, 0.1, i * 0.33)
    Move(p, -30, 120, 2, 1.2)
    Grow(p, 1.8, 1.8, 2, 1.2)
    Fade(p, 0.8, 0, 2, 1.2)
    Play(p)
  end
  Say(ns.T("EM_TRAIN", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.SLEEP = function(from)
  for i = 1, 6 do
    local big = i % 2 == 1
    local z = TextPiece(big and "Z" or "z", big and 64 or 44, 0.7, 0.8, 1)
    z:SetPoint("CENTER", -60 + i * 22, 40)
    z:SetAlpha(0)
    local delay = (i - 1) * 0.45
    Fade(z, 0, 1, 1, 0.3, delay)
    Move(z, 40 + i * 12, 220, 2, 2.2)
    Spin(z, i % 2 == 1 and 15 or -15, 2, 2.2)
    Fade(z, 1, 0, 3, 0.4)
    Play(z)
  end
  Say(ns.T("EM_SLEEP", Short(from)))
end

EFFECTS.LAUGH = function(from)
  for i = 1, 10 do
    local c = COLORS[math.random(#COLORS)]
    local h = TextPiece("HA", math.random(36, 60), c[1], c[2], c[3])
    h:SetPoint("CENTER", math.random(-320, 320), math.random(-40, 200))
    h:SetAlpha(0)
    local delay = (i - 1) * 0.15
    Fade(h, 0, 1, 1, 0.1, delay)
    for k = 1, 3 do
      Move(h, 0, 30, k * 2, 0.15); Move(h, 0, -30, k * 2 + 1, 0.15)
    end
    Fade(h, 1, 0, 8, 0.4)
    Play(h)
  end
  Say(ns.T("EM_LAUGH", Short(from)))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

EFFECTS.SALUTE = function(from)
  Fireworks(6, 360)
  Say(ns.T("EM_SALUTE", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.CRY = function(from)
  local cloud = Piece(ns.MEDIA .. "Cloud", 300, 188)
  cloud:SetPoint("CENTER", 0, 200)
  Fade(cloud, 0, 1, 1, 0.4)
  Move(cloud, 0, -8, 2, 0.6); Move(cloud, 0, 8, 3, 0.6); Move(cloud, 0, -8, 4, 0.6); Move(cloud, 0, 8, 5, 0.6)
  Fade(cloud, 1, 0, 6, 0.6)
  Play(cloud)
  for i = 1, 30 do
    local d = Piece(WHITE, 4, 16)
    d.tex:SetVertexColor(0.45, 0.65, 1, 0.9)
    d:SetPoint("CENTER", math.random(-110, 110), 140)
    d:SetAlpha(0)
    local delay = 0.3 + math.random() * 2
    Fade(d, 0, 1, 1, 0.05, delay)
    Move(d, 0, -math.random(180, 260), 2, 0.7)
    Fade(d, 1, 0, 2, 0.7)
    Play(d)
  end
  Say(ns.T("EM_CRY", Short(from)))
end

EFFECTS.FLEX = function(from)
  local arm = Piece("Interface\\Icons\\Spell_Nature_Strength", 150, 150)
  arm.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  arm:SetPoint("CENTER", 0, 80)
  Fade(arm, 0, 1, 1, 0.2)
  Grow(arm, 1.25, 1.25, 2, 0.2); Grow(arm, 0.8, 0.8, 3, 0.2)
  Grow(arm, 1.25, 1.25, 4, 0.2); Grow(arm, 0.8, 0.8, 5, 0.2)
  Fade(arm, 1, 0, 6, 0.6, 0.8)
  Play(arm)
  for i = 1, 12 do
    local s = Piece(ns.MEDIA .. "Star", 36, 36)
    s.tex:SetVertexColor(1, 0.85, 0.2, 1)
    s:SetPoint("CENTER", 0, 80)
    s:SetAlpha(0)
    local a = i / 12 * 2 * math.pi
    Fade(s, 0, 1, 1, 0.1, 0.2)
    Move(s, math.cos(a) * 170, math.sin(a) * 130, 2, 0.8)
    Spin(s, 270, 2, 0.8)
    Fade(s, 1, 0, 3, 0.5, 0.3)
    Play(s)
  end
  Say(ns.T("EM_FLEX", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

-- Both danced at each other: a bigger disco with confetti everywhere.
EFFECTS.PARTY = function(from)
  local ball = Piece(ns.MEDIA .. "Disco", 300, 300)
  ball:SetPoint("CENTER", 0, 170)
  Move(ball, 0, -60, 1, 0.5)
  Fade(ball, 0, 1, 1, 0.5)
  for k = 2, 6 do Spin(ball, -360, k, 1.2) end
  Fade(ball, 1, 0, 7, 0.6)
  Play(ball)
  for i = 1, 30 do
    local c = COLORS[(i % #COLORS) + 1]
    local dot = Piece(WHITE, 18, 18)
    dot.tex:SetVertexColor(c[1], c[2], c[3], 1)
    local angle = i / 30 * 2 * math.pi
    dot:SetPoint("CENTER", math.cos(angle) * 380, 60 + math.sin(angle) * 230)
    dot:SetAlpha(0)
    local delay = 0.3 + (i % 5) * 0.1
    for k = 1, 9 do
      Fade(dot, 0, 1, k * 2 - 1, 0.2, k == 1 and delay or 0)
      Fade(dot, 1, 0, k * 2, 0.25)
    end
    Play(dot)
  end
  for i = 1, 60 do
    local c = COLORS[(i % #COLORS) + 1]
    local p = Piece(WHITE, math.random(8, 14), math.random(14, 22))
    p.tex:SetVertexColor(c[1], c[2], c[3], 1)
    p:SetPoint("CENTER", math.random(-500, 500), 420)
    p:SetAlpha(0)
    local delay = math.random() * 3
    Fade(p, 0, 1, 1, 0.1, delay)
    Move(p, math.random(-120, 120), -math.random(600, 800), 2, 2.4)
    Spin(p, math.random(-720, 720), 2, 2.4)
    Fade(p, 1, 0, 3, 0.3)
    Play(p)
  end
  local t = TextPiece("DANCE PARTY!", 54, 1, 0.5, 0.9)
  t:SetPoint("CENTER", 0, -20)
  Grow(t, 1.15, 1.15, 1, 0.3); Grow(t, 1 / 1.15, 1 / 1.15, 2, 0.3)
  Grow(t, 1.15, 1.15, 3, 0.3); Grow(t, 1 / 1.15, 1 / 1.15, 4, 0.3)
  Fade(t, 1, 0, 5, 0.8, 2)
  Play(t)
  Say(ns.T("EM_PARTY", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

-- Ding! from = who, level = the new level (from a message or your own level-up).
local function Ding(from, level, own)
  Fireworks(5, 380)
  local t = TextPiece(ns.T("EM_LEVEL", level), 64, 1, 0.85, 0.3)
  t:SetPoint("CENTER", 0, 80)
  t:SetAlpha(0)
  Fade(t, 0, 1, 1, 0.3)
  Grow(t, 1.2, 1.2, 2, 0.25); Grow(t, 1 / 1.2, 1 / 1.2, 3, 0.25)
  Fade(t, 1, 0, 4, 0.8, 2.2)
  Play(t)
  Say(own and ns.T("EM_DING_ME", level) or ns.T("EM_DING", Short(from), level))
  Sound("UI_EPICLOOT_TOAST")
end

-- The last talent of the plan is in.
local function PlanDone()
  Fireworks(4, 300)
  for i = 1, 16 do
    local s = Piece(ns.MEDIA .. "Star", 40, 40)
    s.tex:SetVertexColor(0.4, 1, 0.5, 1)
    s:SetPoint("CENTER", 0, 60)
    s:SetAlpha(0)
    local a = i / 16 * 2 * math.pi
    Fade(s, 0, 1, 1, 0.1, 0.2)
    Move(s, math.cos(a) * 240, math.sin(a) * 160, 2, 1)
    Spin(s, 360, 2, 1)
    Fade(s, 1, 0, 3, 0.6, 0.6)
    Play(s)
  end
  local t = TextPiece(ns.T("EM_PLANDONE_BIG"), 52, 0.4, 1, 0.5)
  t:SetPoint("CENTER", 0, 60)
  Fade(t, 0, 1, 1, 0.3)
  Fade(t, 1, 0, 2, 0.8, 3)
  Play(t)
  Say(ns.T("EM_PLANDONE"))
  Sound("UI_EPICLOOT_TOAST")
end

local function Show(emote, from)
  if ns.db.eggsOff then return end
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

-- Emotes that trigger another effect. Forever has no /toast like later expansions,
-- so the mugs come with /drink (and /cheers where the game has it).
local ALIAS = { DRINK = "TOAST", CHEERS = "TOAST", APPLAUD = "SALUTE", CLAP = "SALUTE",
  LOL = "LAUGH", ROFL = "LAUGH", CHUCKLE = "LAUGH", GIGGLE = "LAUGH", WEEP = "CRY", SOB = "CRY",
  CHOO = "TRAIN", STRONG = "FLEX", YAWN = "SLEEP", TIRED = "SLEEP" }

-- When you last did an emote at someone, and when someone last danced at you (short
-- names), for the dance party.
local didAt, gotAt = {}, {}
local PARTY_WINDOW = 30

local function OnEmote(token, unit)
  if type(token) ~= "string" then return end
  token = token:upper()
  token = ALIAS[token] or token
  if not EFFECTS[token] or ns.db.eggsOff then return end
  unit = (type(unit) == "string" and unit ~= "" and unit) or "target"
  if not (UnitExists(unit) and UnitIsPlayer(unit)) or UnitIsUnit(unit, "player") then return end
  local name, realm = UnitName(unit)
  if not name then return end
  local full = (realm and realm ~= "") and (name .. "-" .. realm) or name
  local key = token .. full
  if lastSent[key] and GetTime() - lastSent[key] < 5 then return end
  lastSent[key] = GetTime()
  didAt[token .. Short(full)] = GetTime()
  -- Dancing back at someone who just danced at you: the party starts for both of you.
  local got = gotAt[Short(full)]
  if token == "DANCE" and got and GetTime() - got < PARTY_WINDOW then
    gotAt[Short(full)] = nil
    didAt["DANCE" .. Short(full)] = nil
    lastShown.PARTY = nil
    Show("PARTY", full)
    Send("EB:PARTY", full)
    return
  end
  Send(token == "KISS" and "KISS" or ("E:" .. token), full)
end

local function OnMessage(msg, sender)
  if ns.db.eggsOff then return end
  local lvl = msg:match("^D:(%d+)$")
  if lvl then
    -- Someone else dinged (our own ding shows from PLAYER_LEVEL_UP).
    if Short(sender) ~= UnitName("player") then Ding(sender, tonumber(lvl)) end
    return
  end
  if msg == "KISS" then
    Show("KISS", sender); Send("KISSBACK", sender)
  elseif msg == "KISSBACK" then
    Show("KISS", sender)
  else
    local back, emote = msg:match("^(EB?):(%u+)$")
    if not emote or not EFFECTS[emote] then return end
    -- Dance party: they danced at you within 10 seconds of you dancing at them.
    local mine = didAt["DANCE" .. Short(sender)]
    if emote == "DANCE" and back == "E" and mine and GetTime() - mine < PARTY_WINDOW then
      didAt["DANCE" .. Short(sender)] = nil
      gotAt[Short(sender)] = nil
      lastShown.PARTY = nil
      Show("PARTY", sender)
      Send("EB:PARTY", sender)
      return
    end
    if emote == "DANCE" and back == "E" then gotAt[Short(sender)] = GetTime() end
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
  ev:RegisterEvent("PLAYER_LEVEL_UP")
  ev:SetScript("OnEvent", function(_, event, a1, a2, _, a4)
    if event == "PLAYER_LEVEL_UP" then
      if ns.db.eggsOff then return end
      local level = tonumber(a1)
      if not level then return end
      pcall(Ding, UnitName("player"), level, true)
      -- Tell your group and guild, so their Plan addons can celebrate with you.
      local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
      if send then
        if IsInRaid and IsInRaid() then pcall(send, PREFIX, "D:" .. level, "RAID")
        elseif IsInGroup and IsInGroup() then pcall(send, PREFIX, "D:" .. level, "PARTY") end
        if IsInGuild and IsInGuild() then pcall(send, PREFIX, "D:" .. level, "GUILD") end
      end
      return
    end
    if a1 == PREFIX and type(a2) == "string" then pcall(OnMessage, a2, a4) end
  end)
end)

-- Hidden preview: /@SLASH@ egg dance (or any other effect, party, ding, plan).
ns.RegisterCommand("egg", false, function(rest)
  local e = (rest or ""):upper():match("(%u+)") or "KISS"
  e = ALIAS[e] or e
  if e == "DING" then Ding(UnitName("player"), UnitLevel("player") or 1, true) return end
  if e == "PLAN" then PlanDone() return end
  lastShown[e] = nil
  local off = ns.db.eggsOff
  ns.db.eggsOff = nil
  Show(e, UnitName("player"))
  ns.db.eggsOff = off
end)
ns.RegisterCommand("heart", false, function() lastShown.KISS = nil; Show("KISS", UnitName("player")) end)

-- The talent plan calls this when its last talent is in (once per plan).
function ns.CelebratePlanDone()
  if ns.db.eggsOff then return end
  ns.db.planCelebrated = ns.db.planCelebrated or {}
  local key = ns.PlanKey and ns.PlanKey() or "plan"
  if ns.db.planCelebrated[key] then return end
  ns.db.planCelebrated[key] = true
  pcall(PlanDone)
end

ns.RegisterCommand("eggs", true, function()
  ns.db.eggsOff = not ns.db.eggsOff
  ns.Print(ns.db.eggsOff and ns.T("EM_OFF") or ns.T("EM_ON"))
end)
