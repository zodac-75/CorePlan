-- @ADDON@: emote easter eggs. When you do one of these emotes on a player who also runs
-- a Plan addon (MagePlan, ShamanPlan, DruidPlan, ...), both of you get a little show:
--   /kiss    a big pulsing heart          /dance   a spinning disco ball with lights
--   /cheer   confetti                     /hug     hearts floating up
--   /wave    a rainbow                    /drink   two mugs clinking (or /toast)
--   /chicken an easter egg that drops in and wobbles
--   /train   a little train chugs across  /sleep   Z z z floats up
--   /laugh   bouncing HA HA HA             /salute  fireworks (also /applaud, /clap)
--   /cry     a rain cloud drizzles         /flex    a strong arm and gold stars
--   /fart    a green cloud drifts by       /sing    music notes float up
--   /gasp    a huge "!!" (or /surprised)   /moo     bouncing MOO (bigger for Tauren)
--   /thank   hearts and gold stars         /charge  "LEEEROY!" across the screen
--   /violin  the world's smallest violin   /bow     a crown drops in
--   /slap    a big fish swings past        /eat     a cake with candles (or /hungry)
-- Dance party: /dance at each other within 30 seconds for a much bigger disco.
-- Group hug: /hug at each other within 30 seconds. Kiss back within 10 for two hearts.
-- A round of drinks: three or more Plan users in a party who /drink within 30 seconds.
-- Wipe: the whole party dead gets a rain cloud. Level 60 gets a grand finale.
-- Seasonal: snow with /wave in December, a pumpkin from /chicken around Halloween.
-- Ding party: when a Plan user in your group or guild levels up, everyone with a Plan
-- addon gets fireworks. Your own ding and finishing the talent plan get one too.
-- Bags full: try to loot with full bags and your bag bursts, junk flies everywhere (just for
-- you, at most every two minutes).
-- The whole party: an emote with no player targeted, in a party or raid, goes to everyone
-- there with a Plan addon ("P:<EMOTE>"). They see the effect and answer ("PB:<EMOTE>"), and
-- you see it once, with who saw it.
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

-- "Name-Realm", and on WoW Forever also "Name Realm": just the name.
local function Short(name)
  return (name or ""):match("^([^%-%s]+)") or name or "?"
end

-- Is this sender you? Addon messages to the party come back to yourself, with the realm added.
local function IsMe(sender)
  local me = UnitName("player")
  if type(sender) ~= "string" or type(me) ~= "string" then return false end
  if sender == me then return true end
  return sender:sub(1, #me) == me and not sender:sub(#me + 1, #me + 1):match("%a")
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
  ns.lastEggLine = text
  label:SetText("|cffffccee" .. text .. "|r")
  label:SetAlpha(1)
  label:Show()
  label.hideAt = GetTime() + 4
end

---------------------------------------------------------------------------
-- The effects
---------------------------------------------------------------------------
local EFFECTS = {}

-- Month and day from the computer's clock (for the seasonal ones).
local function Today()
  if type(date) ~= "function" then return 0, 0 end
  local ok, t = pcall(date, "*t")
  if ok and type(t) == "table" then return t.month or 0, t.day or 0 end
  return 0, 0
end
local function IsDecember() return (Today()) == 12 end
local function IsHalloween()
  local m, d = Today()
  return (m == 10 and d >= 24) or (m == 11 and d <= 1)
end

-- Things that fall from the top of the screen: count pieces made by make(i).
local function Rain(count, make, spreadX, duration)
  for i = 1, count do
    local p = make(i)
    p:SetPoint("CENTER", math.random(-spreadX, spreadX), 420)
    p:SetAlpha(0)
    Fade(p, 0, 1, 1, 0.1, math.random() * 2.5)
    Move(p, math.random(-80, 80), -math.random(620, 820), 2, duration + math.random())
    Spin(p, math.random(-360, 360), 2, duration)
    Fade(p, 1, 0, 3, 0.3)
    Play(p)
  end
end

-- Big text that pops in, pulses and fades.
local function BigText(text, size, r, g, b, y, hold)
  local t = TextPiece(text, size, r, g, b)
  t:SetPoint("CENTER", 0, y or 0)
  t:SetAlpha(0)
  Fade(t, 0, 1, 1, 0.2)
  Grow(t, 1.15, 1.15, 2, 0.25); Grow(t, 1 / 1.15, 1 / 1.15, 3, 0.25)
  Grow(t, 1.15, 1.15, 4, 0.25); Grow(t, 1 / 1.15, 1 / 1.15, 5, 0.25)
  Fade(t, 1, 0, 6, 0.8, hold or 1.5)
  Play(t)
  return t
end

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
  if IsDecember() then
    -- December: it snows.
    Rain(50, function()
      local n = math.random(6, 12)
      return Piece(WHITE, n, n)
    end, 520, 3)
  end
  Say(ns.T("EM_WAVE", Short(from)))
  Sound("UI_QUEST_LOG_QUEST_ABANDONED")
end

EFFECTS.TOAST = function(from)
  for side = -1, 1, 2 do
    local m = Piece(ns.MEDIA .. "Mug", 170, 170)
    m:SetPoint("CENTER", side * 260, 60)
    -- The picture has the handle on the right: mirror the left mug, so both handles point
    -- outwards and the glass sides are what clink.
    if side < 0 then m.tex:SetTexCoord(1, 0, 0, 1) else m.tex:SetTexCoord(0, 1, 0, 1) end
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
  -- Around Halloween the chicken lays a pumpkin.
  local e = Piece(ns.MEDIA .. (IsHalloween() and "Pumpkin" or "Egg"), 180, 180)
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

EFFECTS.FART = function(from)
  local w = UIParent:GetWidth()
  local cloud = Piece(ns.MEDIA .. "Cloud", 300, 188)
  cloud.tex:SetVertexColor(0.55, 0.85, 0.3, 1)
  cloud:SetPoint("CENTER", -(w / 2 + 200), -120)
  Move(cloud, w + 400, 60, 1, 4)
  Play(cloud)
  for i = 1, 14 do
    local p = Piece(WHITE, 20, 20)
    p.tex:SetVertexColor(0.6, 0.85, 0.35, 0.7)
    p:SetPoint("CENTER", -(w / 2) + w * (i / 15), -150)
    p:SetAlpha(0)
    Fade(p, 0, 0.7, 1, 0.1, i * 0.27)
    Move(p, math.random(-30, 30), 90, 2, 1.1)
    Grow(p, 2, 2, 2, 1.1)
    Fade(p, 0.7, 0, 2, 1.1)
    Play(p)
  end
  BigText("Pffft...", 48, 0.6, 0.9, 0.35, 60, 1.2)
  Say(ns.T("EM_FART", Short(from)))
end

EFFECTS.SING = function(from)
  for i = 1, 14 do
    local c = COLORS[(i % #COLORS) + 1]
    local size = math.random(46, 84)
    local n = Piece(ns.MEDIA .. "Note", size, size)
    n.tex:SetVertexColor(c[1], c[2], c[3], 1)
    n:SetPoint("CENTER", math.random(-300, 300), -140)
    n:SetAlpha(0)
    local delay = (i - 1) * 0.16
    Fade(n, 0, 1, 1, 0.2, delay)
    Move(n, 50, 110, 2, 0.8); Move(n, -70, 110, 3, 0.8); Move(n, 50, 110, 4, 0.8)
    Spin(n, 12, 2, 0.8); Spin(n, -24, 3, 0.8)
    Fade(n, 1, 0, 4, 0.8)
    Play(n)
  end
  Say(ns.T("EM_SING", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

EFFECTS.GASP = function(from)
  local t = TextPiece("!!", 150, 1, 0.85, 0.2)
  t:SetPoint("CENTER", 0, 90)
  Grow(t, 1.4, 1.4, 1, 0.12); Grow(t, 1 / 1.4, 1 / 1.4, 2, 0.12)
  for k = 1, 5 do
    Move(t, 18, 0, k * 2 + 1, 0.05); Move(t, -18, 0, k * 2 + 2, 0.05)
  end
  Fade(t, 1, 0, 13, 0.6, 0.8)
  Play(t)
  Say(ns.T("EM_GASP", Short(from)))
end

-- Is either of you a Tauren? (The other player only when they're your target.)
local function AnyTauren(from)
  local function tauren(unit)
    local ok, _, race = pcall(UnitRace, unit)
    return ok and race == "Tauren"
  end
  if tauren("player") then return true end
  local ok, name = pcall(UnitName, "target")
  return ok and name == Short(from) and tauren("target")
end

EFFECTS.MOO = function(from)
  local big = AnyTauren(from)
  for i = 1, big and 7 or 4 do
    local c = COLORS[math.random(#COLORS)]
    local m = TextPiece("MOO", big and math.random(70, 110) or math.random(44, 64), c[1], c[2], c[3])
    m:SetPoint("CENTER", math.random(-300, 300), math.random(-40, 180))
    m:SetAlpha(0)
    Fade(m, 0, 1, 1, 0.1, (i - 1) * 0.25)
    for k = 1, 3 do
      Move(m, 0, 40, k * 2, 0.18); Move(m, 0, -40, k * 2 + 1, 0.18)
    end
    Fade(m, 1, 0, 8, 0.5)
    Play(m)
  end
  Say(ns.T("EM_MOO", Short(from)))
end

EFFECTS.THANK = function(from)
  Rain(36, function(i)
    if i % 2 == 0 then
      local n = math.random(30, 60)
      return Piece(ns.MEDIA .. "Heart", n, n)
    end
    local n = math.random(24, 44)
    local st = Piece(ns.MEDIA .. "Star", n, n)
    st.tex:SetVertexColor(1, 0.85, 0.2, 1)
    return st
  end, 480, 2.2)
  Say(ns.T("EM_THANK", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

EFFECTS.CHARGE = function(from)
  local w = UIParent:GetWidth()
  local t = TextPiece("LEEEROY!", 96, 1, 0.3, 0.2)
  t:SetPoint("CENTER", -(w / 2 + 500), 60)
  Move(t, w / 2 + 500, 0, 1, 0.35)
  for k = 1, 4 do
    Move(t, 14, 0, k * 2, 0.05); Move(t, -14, 0, k * 2 + 1, 0.05)
  end
  Move(t, w / 2 + 600, 0, 10, 0.4, 0.9)
  Play(t)
  Say(ns.T("EM_CHARGE", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.VIOLIN = function(from)
  -- The world's smallest violin: really small.
  local v = Piece(ns.MEDIA .. "Violin", 70, 70)
  v:SetPoint("CENTER", 0, 70)
  Fade(v, 0, 1, 1, 0.3)
  for k = 1, 4 do
    Spin(v, 10, k * 2, 0.25); Spin(v, -10, k * 2 + 1, 0.25)
  end
  Fade(v, 1, 0, 10, 0.6, 0.4)
  Play(v)
  for i = 1, 4 do
    local n = Piece(ns.MEDIA .. "Note", 26, 26)
    n.tex:SetVertexColor(0.8, 0.85, 1, 1)
    n:SetPoint("CENTER", 20, 90)
    n:SetAlpha(0)
    Fade(n, 0, 1, 1, 0.15, 0.3 + (i - 1) * 0.45)
    Move(n, 30 + i * 8, 70, 2, 1)
    Fade(n, 1, 0, 2, 1)
    Play(n)
  end
  Say(ns.T("EM_VIOLIN", Short(from)))
end

EFFECTS.BOW = function(from)
  local c = Piece(ns.MEDIA .. "Crown", 200, 200)
  c:SetPoint("CENTER", 0, 400)
  Move(c, 0, -320, 1, 0.45)
  Move(c, 0, 50, 2, 0.14); Move(c, 0, -50, 3, 0.14)
  Move(c, 0, 20, 4, 0.1); Move(c, 0, -20, 5, 0.1)
  Fade(c, 1, 0, 6, 0.8, 1.4)
  Play(c)
  for i = 1, 10 do
    local st = Piece(ns.MEDIA .. "Star", 30, 30)
    st.tex:SetVertexColor(1, 0.85, 0.2, 1)
    st:SetPoint("CENTER", 0, 80)
    st:SetAlpha(0)
    local a = i / 10 * 2 * math.pi
    Fade(st, 0, 1, 1, 0.1, 0.5)
    Move(st, math.cos(a) * 180, math.sin(a) * 120, 2, 0.8)
    Spin(st, 270, 2, 0.8)
    Fade(st, 1, 0, 3, 0.5)
    Play(st)
  end
  Say(ns.T("EM_BOW", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

EFFECTS.SLAP = function(from)
  local w = UIParent:GetWidth()
  local f = Piece(ns.MEDIA .. "Fish", 240, 240)
  f:SetPoint("CENTER", w / 2 + 200, 160)
  Move(f, -(w / 2 + 200), -100, 1, 0.3)
  Spin(f, 50, 1, 0.3)
  Spin(f, -70, 2, 0.12)
  Move(f, -(w / 2 + 300), 120, 3, 0.45, 0.25)
  Spin(f, 60, 3, 0.45, 0.25)
  Play(f)
  local t = TextPiece("SLAP!", 80, 1, 0.9, 0.3)
  t:SetPoint("CENTER", 0, -40)
  t:SetAlpha(0)
  Fade(t, 0, 1, 1, 0.05, 0.3)
  Grow(t, 1.3, 1.3, 2, 0.1); Grow(t, 1 / 1.3, 1 / 1.3, 3, 0.1)
  Fade(t, 1, 0, 4, 0.6, 0.6)
  Play(t)
  Say(ns.T("EM_SLAP", Short(from)))
end

EFFECTS.EAT = function(from)
  local c = Piece(ns.MEDIA .. "Cake", 200, 200)
  c:SetPoint("CENTER", 0, -260)
  Move(c, 0, 330, 1, 0.5)
  Move(c, 0, -30, 2, 0.15); Move(c, 0, 30, 3, 0.15)
  Grow(c, 1.1, 1.1, 4, 0.2); Grow(c, 1 / 1.1, 1 / 1.1, 5, 0.2)
  Fade(c, 1, 0, 6, 0.8, 1.4)
  Play(c)
  Say(ns.T("EM_EAT", Short(from)))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

-- Bags full: the bag shakes, bursts, and junk flies out in every direction.
local JUNK = {
  "Interface\\Icons\\INV_Misc_Bone_01", "Interface\\Icons\\INV_Misc_Food_19", "Interface\\Icons\\INV_Misc_Pelt_Wolf_Ruin_02",
  "Interface\\Icons\\INV_Misc_Coin_01", "Interface\\Icons\\INV_Misc_Bone_HumanSkull_01", "Interface\\Icons\\INV_Boots_01",
  "Interface\\Icons\\INV_Misc_Fish_02", "Interface\\Icons\\INV_Misc_Gem_Variety_01", "Interface\\Icons\\INV_Fabric_Linen_01",
  "Interface\\Icons\\INV_Misc_Food_15", "Interface\\Icons\\INV_Misc_Ear_NightElf_01", "Interface\\Icons\\INV_Shirt_05",
}
local function BagsBurst()
  local bag = Piece("Interface\\Icons\\INV_Misc_Bag_08", 110, 110)
  bag:SetPoint("CENTER", 0, 40)
  for k = 1, 6 do
    Spin(bag, (k % 2 == 0) and 14 or -14, k, 0.07)
  end
  Grow(bag, 1.35, 1.35, 7, 0.15)
  Fade(bag, 1, 0, 8, 0.25)
  Play(bag)
  for i = 1, 24 do
    local p = Piece(JUNK[(i % #JUNK) + 1], 34, 34)
    p:SetPoint("CENTER", 0, 40)
    p:SetAlpha(0)
    local dx, up = math.random(-420, 420), math.random(120, 300)
    Fade(p, 0, 1, 1, 0.05, 0.45)
    Move(p, dx * 0.45, up, 2, 0.35)
    Move(p, dx * 0.55, -up - math.random(300, 500), 3, 1.3)
    Spin(p, math.random(-900, 900), 3, 1.3)
    Fade(p, 1, 0, 4, 0.3)
    Play(p)
  end
  BigText(ns.T("EM_BAGSFULL_BIG"), 40, 1, 0.5, 0.2, 150, 1.6)
  Say(ns.T("EM_BAGSFULL"))
  Sound("UI_BATTLEGROUND_COUNTDOWN_FINISHED")
end

-- The bag eats too much: it swells, burps, and a little junk rains down.
local function BagsBurp()
  local bag = Piece("Interface\\Icons\\INV_Misc_Bag_08", 90, 90)
  bag:SetPoint("CENTER", 0, 40)
  for k = 1, 4 do
    Grow(bag, 1.3, 1.3, k, 0.35)
    Spin(bag, (k % 2 == 0) and 8 or -8, k, 0.35)
  end
  Grow(bag, 0.55, 0.55, 5, 0.12)
  Fade(bag, 1, 0, 6, 0.4)
  Play(bag)
  for i = 1, 10 do
    local p = Piece(JUNK[(i % #JUNK) + 1], 30, 30)
    p:SetPoint("CENTER", math.random(-160, 160), 340)
    p:SetAlpha(0)
    Fade(p, 0, 1, 1, 0.05, 1.6 + math.random() * 0.8)
    Move(p, math.random(-40, 40), -420, 2, 1.1)
    Spin(p, math.random(-400, 400), 2, 1.1)
    Fade(p, 1, 0, 3, 0.3)
    Play(p)
  end
  BigText(ns.T("EM_BAGSFULL2_BIG"), 60, 0.6, 1, 0.3, 150, 1.4)
  Say(ns.T("EM_BAGSFULL2"))
  Sound("UI_BATTLEGROUND_COUNTDOWN_FINISHED")
end

-- The bag refuses more loot and hops off across the screen.
local function BagsRun()
  local bag = Piece("Interface\\Icons\\INV_Misc_Bag_08", 100, 100)
  bag:SetPoint("CENTER", -520, -20)
  for k = 1, 6 do
    Move(bag, 170, (k % 2 == 1) and 70 or -70, k, 0.25)
  end
  Fade(bag, 1, 0, 7, 0.3)
  Play(bag)
  BigText(ns.T("EM_BAGSFULL3_BIG"), 50, 1, 0.8, 0.3, 150, 1.6)
  Say(ns.T("EM_BAGSFULL3"))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

EFFECTS.BAGSFULL = function()
  local pick = math.random(3)
  if pick == 1 then BagsBurst() elseif pick == 2 then BagsBurp() else BagsRun() end
end

-- Somebody needs on a roll: a die tumbles in and lands, with a line about the greedy one.
EFFECTS.NEED = function(from)
  local die = Piece("Interface\\Icons\\INV_Misc_Dice_02", 120, 120)
  die:SetPoint("CENTER", 0, 380)
  Move(die, 0, -380, 1, 0.45)
  Spin(die, 540, 1, 0.45)
  Move(die, 0, 90, 2, 0.18); Move(die, 0, -90, 3, 0.18)
  Spin(die, 90, 2, 0.18); Spin(die, -90, 3, 0.18)
  Move(die, 0, 40, 4, 0.12); Move(die, 0, -40, 5, 0.12)
  Grow(die, 1.3, 1.3, 6, 0.15); Grow(die, 1 / 1.3, 1 / 1.3, 7, 0.15)
  Fade(die, 1, 0, 8, 0.5, 0.6)
  Play(die)
  BigText(ns.T("EM_NEED_BIG"), 56, 1, 0.82, 0.1, 150, 1.8)
  Say(ns.T("EM_NEED_" .. math.random(3), Short(from)))
  Sound("UI_BATTLEGROUND_COUNTDOWN_FINISHED")
end

-- Somebody rolls a 100: a golden die lands, stars ring out and a couple of fireworks go off.
EFFECTS.ROLL100 = function(from)
  local die = Piece("Interface\\Icons\\INV_Misc_Dice_02", 110, 110)
  die:SetPoint("CENTER", 0, 380)
  Move(die, 0, -380, 1, 0.4)
  Spin(die, 720, 1, 0.4)
  Move(die, 0, 70, 2, 0.15); Move(die, 0, -70, 3, 0.15)
  Grow(die, 1.5, 1.5, 4, 0.2); Grow(die, 1 / 1.5, 1 / 1.5, 5, 0.2)
  Fade(die, 1, 0, 6, 0.5, 0.9)
  Play(die)
  for i = 1, 12 do
    local a = i / 12 * 2 * math.pi
    local st = Piece(ns.MEDIA .. "Star", 34, 34)
    st.tex:SetVertexColor(1, 0.85, 0.2, 1)
    st:SetPoint("CENTER", 0, 0)
    st:SetAlpha(0)
    Fade(st, 0, 1, 1, 0.05, 0.4)
    Move(st, math.cos(a) * 200, math.sin(a) * 140, 2, 0.8)
    Spin(st, 270, 2, 0.8)
    Fade(st, 1, 0, 3, 0.5)
    Play(st)
  end
  Fireworks(2, 260)
  BigText(ns.T("EM_R100_BIG"), 64, 1, 0.85, 0.2, 130, 1.4)
  Say(ns.T("EM_R100_" .. math.random(2), Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

-- Somebody rolls a 67: a big 6 and a big 7 bob up and down out of step, like the meme.
EFFECTS.SIXSEVEN = function(from)
  local digits = { { "6", -110, 1, 0.85, 0.2 }, { "7", 110, 0.3, 0.8, 1 } }
  for n, d in ipairs(digits) do
    local t = TextPiece(d[1], 64, d[3], d[4], d[5])
    t:SetPoint("CENTER", d[2], 60)
    t:SetAlpha(0)
    Fade(t, 0, 1, 1, 0.15)
    Grow(t, 2.2, 2.2, 1, 0.15)
    local up = (n == 1) and 1 or -1
    for k = 1, 8 do
      Move(t, 0, ((k % 2 == 1) and 70 or -70) * up, k + 1, 0.22)
      Spin(t, ((k % 2 == 1) and 10 or -10) * up, k + 1, 0.22)
    end
    Fade(t, 1, 0, 10, 0.5, 0.2)
    Play(t)
  end
  Say(ns.T("EM_67", Short(from)))
  Sound("UI_GARRISON_MISSION_COMPLETE_ENCOUNTER_CHANCE")
end

-- Somebody rolls NEED 100: the big one. Two dice, a rain of gold, a wall of fireworks.
EFFECTS.NEED100 = function(from)
  for side = -1, 1, 2 do
    local die = Piece("Interface\\Icons\\INV_Misc_Dice_02", 130, 130)
    die:SetPoint("CENTER", side * 170, 400)
    Move(die, 0, -400, 1, 0.45)
    Spin(die, side * 900, 1, 0.45)
    Move(die, 0, 90, 2, 0.15); Move(die, 0, -90, 3, 0.15)
    Grow(die, 1.7, 1.7, 4, 0.2); Grow(die, 1 / 1.7, 1 / 1.7, 5, 0.2)
    Spin(die, side * 360, 6, 0.6)
    Fade(die, 1, 0, 7, 0.6, 1.2)
    Play(die)
  end
  for ring = 1, 2 do
    for i = 1, 16 do
      local a = i / 16 * 2 * math.pi
      local st = Piece(ns.MEDIA .. "Star", 40, 40)
      local c = COLORS[(i + ring) % #COLORS + 1]
      st.tex:SetVertexColor(c[1], c[2], c[3], 1)
      st:SetPoint("CENTER", 0, 20)
      st:SetAlpha(0)
      Fade(st, 0, 1, 1, 0.05, 0.45 + ring * 0.25)
      Move(st, math.cos(a) * (180 + ring * 120), math.sin(a) * (120 + ring * 80), 2, 0.9)
      Spin(st, 360, 2, 0.9)
      Fade(st, 1, 0, 3, 0.5)
      Play(st)
    end
  end
  for i = 1, 30 do
    local coin = Piece("Interface\\Icons\\INV_Misc_Coin_01", 30, 30)
    coin:SetPoint("CENTER", math.random(-420, 420), 340)
    coin:SetAlpha(0)
    Fade(coin, 0, 1, 1, 0.05, 0.6 + math.random() * 1.4)
    Move(coin, math.random(-30, 30), -520, 2, 1.1 + math.random() * 0.4)
    Spin(coin, math.random(-720, 720), 2, 1.3)
    Fade(coin, 1, 0, 3, 0.3)
    Play(coin)
  end
  Fireworks(7, 420)
  BigText(ns.T("EM_N100_BIG"), 64, 1, 0.3, 0.15, 140, 2.2)
  Say(ns.T("EM_N100_" .. math.random(2), Short(from)))
  Sound("UI_EPICLOOT_TOAST")
  Sound("UI_BATTLEGROUND_COUNTDOWN_FINISHED")
end

local lastNeed = -1000
local needPatterns
local function Pat(g)
  if type(g) ~= "string" then return nil end
  local p = g:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
  p = p:gsub("%%%d%%%$s", "(.-)")
  p = p:gsub("%%s", "(.-)")
  return "^" .. p .. "$"
end
-- A roll result of 100 or 67 (need or greed, or a plain /roll): works in any language, because the
-- number is whichever piece of the line is a number and the player is the piece that isn't an item.
local lastR100 = -1000
local rollPatterns
local function RollPatterns()
  if rollPatterns then return rollPatterns end
  local function P(g) -- like Pat, but %d is a number piece too
    if type(g) ~= "string" then return nil end
    local q = g:gsub("([%^%$%(%)%.%[%]%*%+%-%?])", "%%%1")
    q = q:gsub("%%%d%%%$[sd]", "(.-)")
    q = q:gsub("%%[sd]", "(.-)")
    return "^" .. q .. "$"
  end
  rollPatterns = {
    need = { P(LOOT_ROLL_ROLLED_NEED or "Need Roll - %d for %s by %s") },
    greed = { P(LOOT_ROLL_ROLLED_GREED or "Greed Roll - %d for %s by %s"), P(LOOT_ROLL_ROLLED_DE) },
    plain = { P(RANDOM_ROLL_RESULT or "%s rolls %d (%d-%d)") },
  }
  return rollPatterns
end
local function OnRoll100(msg)
  if GetTime() - lastR100 < 6 then return false end
  local rp = RollPatterns()
  for kind, list in pairs(rp) do
    for _, pat in ipairs(list) do
      local c = { msg:match(pat) }
      if #c >= 3 then
        local roll, who, lo, hi
        for _, v in ipairs(c) do
          local n = tonumber(v)
          if n and v:match("^%d+$") then
            if not roll then roll = n elseif not lo then lo = n else hi = n end
          elseif not who and not v:find("|H", 1, true) and not v:find("[", 1, true) then who = v end
        end
        if (roll == 100 or roll == 67) and who and (kind ~= "plain" or (lo == 1 and hi == 100)) then
          if who == YOU or who == "" then who = UnitName("player") end
          lastR100 = GetTime()
          local egg = roll == 67 and "SIXSEVEN" or (kind == "need" and "NEED100" or "ROLL100")
          lastShown[egg] = nil
          ns.ShowEmoteEgg(egg, who)
          return true
        end
      end
    end
  end
  return false
end

local function OnLootMsg(msg)
  if ns.db.eggsOff or type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return end
  if OnRoll100(msg) then return end
  if GetTime() - lastNeed < 15 then return end
  needPatterns = needPatterns or { selfP = Pat(LOOT_ROLL_NEED_SELF), otherP = Pat(LOOT_ROLL_NEED) }
  local who
  if needPatterns.otherP then who = msg:match(needPatterns.otherP) end
  if not who and needPatterns.selfP and msg:match(needPatterns.selfP) then who = UnitName("player") end
  if not who or who == "" then return end
  lastNeed = GetTime()
  lastShown.NEED = nil
  ns.ShowEmoteEgg("NEED", who)
end

local lastBagsFull = -1000
local function OnUIError(_, msg)
  if ns.db.eggsOff or type(msg) ~= "string" or (issecretvalue and issecretvalue(msg)) then return end
  if not (ERR_INV_FULL and msg == ERR_INV_FULL) then return end
  if GetTime() - lastBagsFull < 120 then return end
  lastBagsFull = GetTime()
  lastShown.BAGSFULL = nil
  ns.ShowEmoteEgg("BAGSFULL", UnitName("player"))
end

-- Both hugged each other: hearts everywhere.
EFFECTS.GROUPHUG = function(from)
  for i = 1, 40 do
    local size = math.random(40, 110)
    local h = Piece(ns.MEDIA .. "Heart", size, size)
    h:SetPoint("CENTER", math.random(-560, 560), math.random(-320, -120))
    h:SetAlpha(0)
    Fade(h, 0, 1, 1, 0.3, math.random() * 1.8)
    Move(h, math.random(-80, 80), math.random(360, 620), 2, 2.6)
    Grow(h, 1.3, 1.3, 2, 2.6)
    Fade(h, 1, 0, 3, 0.5)
    Play(h)
  end
  BigText("GROUP HUG!", 54, 1, 0.5, 0.7, -20, 2)
  Say(ns.T("EM_GROUPHUG", Short(from)))
  Sound("UI_EPICLOOT_TOAST")
end

-- A kiss answered with a kiss: two hearts.
EFFECTS.KISSKISS = function(from)
  for side = -1, 1, 2 do
    local h = Piece(ns.MEDIA .. "Heart", 220, 220)
    h:SetPoint("CENTER", side * 260, 80)
    Fade(h, 0, 1, 1, 0.3)
    Move(h, -side * 160, 0, 2, 0.5)
    for k = 1, 3 do
      Grow(h, 1.12, 1.12, k * 2 + 1, 0.18); Grow(h, 1 / 1.12, 1 / 1.12, k * 2 + 2, 0.18)
    end
    Fade(h, 1, 0, 9, 0.8, 0.6)
    Play(h)
  end
  Say(ns.T("EM_KISSKISS", Short(from)))
  Sound("UI_GARRISON_FOLLOWER_LEARN_TRAIT")
end

-- Three or more in the party drank: a row of mugs.
EFFECTS.ROUND = function()
  for i = 1, 5 do
    local m = Piece(ns.MEDIA .. "Mug", 130, 130)
    m:SetPoint("CENTER", (i - 3) * 150, -260)
    local delay = (i - 1) * 0.12
    Move(m, 0, 300, 1, 0.4, delay)
    for k = 1, 3 do
      Move(m, 0, 30, k * 2, 0.15); Move(m, 0, -30, k * 2 + 1, 0.15)
    end
    Fade(m, 1, 0, 8, 0.7, 1.2)
    Play(m)
  end
  BigText("Skål!", 90, 1, 0.85, 0.3, 190, 2)
  Say(ns.T("EM_ROUND"))
  Sound("UI_EPICLOOT_TOAST")
end

-- The whole party is dead.
EFFECTS.WIPE = function()
  local cloud = Piece(ns.MEDIA .. "Cloud", 300, 188)
  cloud.tex:SetVertexColor(0.6, 0.6, 0.65, 1)
  cloud:SetPoint("CENTER", 0, 200)
  Fade(cloud, 0, 1, 1, 0.4)
  for k = 1, 3 do
    Move(cloud, 0, -8, k * 2, 0.6); Move(cloud, 0, 8, k * 2 + 1, 0.6)
  end
  Fade(cloud, 1, 0, 8, 0.6)
  Play(cloud)
  for i = 1, 30 do
    local d = Piece(WHITE, 4, 16)
    d.tex:SetVertexColor(0.45, 0.65, 1, 0.9)
    d:SetPoint("CENTER", math.random(-110, 110), 140)
    d:SetAlpha(0)
    Fade(d, 0, 1, 1, 0.05, 0.3 + math.random() * 3)
    Move(d, 0, -math.random(180, 260), 2, 0.7)
    Fade(d, 1, 0, 2, 0.7)
    Play(d)
  end
  local t = TextPiece(ns.T("EM_WIPE_BIG"), 40, 0.8, 0.8, 0.9)
  t:SetPoint("CENTER", 0, 40)
  t:SetAlpha(0)
  Fade(t, 0, 1, 1, 0.6, 0.6)
  Fade(t, 1, 0, 2, 0.8, 3)
  Play(t)
  Say(ns.T("EM_WIPE"))
end

-- Level 60: the grand finale.
EFFECTS.SIXTY = function(from)
  Fireworks(14, 520)
  Rain(70, function(i)
    local c = COLORS[(i % #COLORS) + 1]
    local p = Piece(WHITE, math.random(8, 14), math.random(14, 22))
    p.tex:SetVertexColor(c[1], c[2], c[3], 1)
    return p
  end, 560, 2.4)
  local c = Piece(ns.MEDIA .. "Crown", 180, 180)
  c:SetPoint("CENTER", 0, 420)
  Move(c, 0, -230, 1, 0.5)
  Move(c, 0, 30, 2, 0.14); Move(c, 0, -30, 3, 0.14)
  Fade(c, 1, 0, 4, 1, 4)
  Play(c)
  BigText(ns.T("EM_LEVEL", 60), 84, 1, 0.85, 0.3, 40, 4)
  Sound("UI_EPICLOOT_TOAST")
end

-- Ding! from = who, level = the new level (from a message or your own level-up).
local function Ding(from, level, own)
  if level and level >= 60 then
    EFFECTS.SIXTY(from)
    Say(own and ns.T("EM_SIXTY_ME") or ns.T("EM_SIXTY", Short(from)))
    return
  end
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

-- answer = true: the other player's addon answered an emote *you* did, so the line under the
-- effect says that they saw it ("Faithlezz has a Plan addon too ...") instead of "Faithlezz gasps!".
local function Show(emote, from, answer)
  if ns.db.eggsOff then return end
  local fn = EFFECTS[emote]
  if not fn then return end
  if lastShown[emote] and GetTime() - lastShown[emote] < 2 then return end
  lastShown[emote] = GetTime()
  local ok, err = pcall(fn, from)
  if not ok and ns.debug then ns.Print(tostring(err)) end
  if type(answer) == "string" and label then Say(answer)
  elseif answer and label then Say(ns.T("EM_SEEN", Short(from), "/" .. emote:lower())) end
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
local ALIAS = { ROLL = "NEED", ["67"] = "SIXSEVEN", SIX = "SIXSEVEN", ["100"] = "ROLL100", FULL = "BAGSFULL", BAGS = "BAGSFULL", DRINK = "TOAST", CHEERS = "TOAST", APPLAUD = "SALUTE", CLAP = "SALUTE",
  LOL = "LAUGH", ROFL = "LAUGH", CHUCKLE = "LAUGH", GIGGLE = "LAUGH", WEEP = "CRY", SOB = "CRY",
  CHOO = "TRAIN", STRONG = "FLEX", YAWN = "SLEEP", TIRED = "SLEEP",
  SURPRISED = "GASP", SHOCK = "GASP", HUNGRY = "EAT", FEAST = "EAT", CHEW = "EAT",
  THANKS = "THANK", TY = "THANK", CURTSEY = "BOW", KNEEL = "BOW" }

-- Doing the same emote back at each other turns it into something bigger.
local COMBO = { DANCE = "PARTY", HUG = "GROUPHUG", KISS = "KISSKISS" }
local COMBO_WINDOW = { KISS = 10 }

-- Effects that aren't an emote to send to someone (they start in other ways).
local LOCAL_ONLY = { PARTY = true, GROUPHUG = true, KISSKISS = true, ROUND = true, WIPE = true, SIXTY = true, BAGSFULL = true, NEED = true, ROLL100 = true, NEED100 = true, SIXSEVEN = true }

-- A round of drinks: who in the party drank lately (short name -> when).
local drinkers = {}
local ROUND_WINDOW, ROUND_NEEDS = 30, 3
local function Drank(who)
  local now, n = GetTime(), 0
  drinkers[who] = now
  for name, t in pairs(drinkers) do
    if now - t > ROUND_WINDOW then drinkers[name] = nil else n = n + 1 end
  end
  if n >= ROUND_NEEDS then
    drinkers = {}
    lastShown.ROUND = nil
    Show("ROUND", who)
  end
end

-- When you last did an emote at someone, and when someone last danced at you (short
-- names), for the dance party.
local didAt, gotAt = {}, {}
local partySeen = {} -- emote -> names who answered your party emote
local partyShownAt = {} -- emote -> when its "who saw it" was shown (late answers are ignored)
local PARTY_WINDOW = 30

local function OnEmote(token, unit)
  if type(token) ~= "string" then return end
  token = token:upper()
  token = ALIAS[token] or token
  if not EFFECTS[token] or LOCAL_ONLY[token] or ns.db.eggsOff then return end
  -- A drink in a party counts towards a round, whoever you drink to.
  if token == "TOAST" and IsInGroup and IsInGroup() and not (IsInRaid and IsInRaid()) then
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    if send then pcall(send, PREFIX, "R:TOAST", "PARTY") end
    Drank(UnitName("player"))
  end
  unit = (type(unit) == "string" and unit ~= "" and unit) or "target"
  if not (UnitExists(unit) and UnitIsPlayer(unit)) or UnitIsUnit(unit, "player") then
    -- Nobody targeted: the whole party (or raid) sees it.
    if IsInGroup and IsInGroup() then
      local key = "P:" .. token
      if lastSent[key] and GetTime() - lastSent[key] < 5 then return end
      lastSent[key] = GetTime()
      local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
      if send then pcall(send, PREFIX, "P:" .. token, (IsInRaid and IsInRaid()) and "RAID" or "PARTY") end
    end
    return
  end
  local name, realm = UnitName(unit)
  if not name then return end
  local full = (realm and realm ~= "") and (name .. "-" .. realm) or name
  local key = token .. full
  if lastSent[key] and GetTime() - lastSent[key] < 5 then return end
  lastSent[key] = GetTime()
  didAt[token .. Short(full)] = GetTime()
  -- Doing it back at someone who just did it at you: the bigger one starts for both.
  local combo = COMBO[token]
  local got = combo and gotAt[token .. Short(full)]
  if got and GetTime() - got < (COMBO_WINDOW[token] or PARTY_WINDOW) then
    gotAt[token .. Short(full)] = nil
    didAt[token .. Short(full)] = nil
    lastShown[combo] = nil
    Show(combo, full)
    Send("EB:" .. combo, full)
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
  if msg == "R:TOAST" then
    if Short(sender) ~= UnitName("player") then Drank(Short(sender)) end
    return
  end
  -- An emote to the whole party: show it, and tell them you saw it.
  local pe = msg:match("^P:(%u+)$")
  if pe then
    if IsMe(sender) or not EFFECTS[pe] or LOCAL_ONLY[pe] then return end
    Show(pe, sender)
    Send("PB:" .. pe, sender)
    return
  end
  -- Answers to your party emote: collect them for a moment, then show it once.
  pe = msg:match("^PB:(%u+)$")
  if pe then
    if IsMe(sender) or not EFFECTS[pe] or LOCAL_ONLY[pe] then return end
    if partyShownAt[pe] and GetTime() - partyShownAt[pe] < 6 then return end
    partySeen[pe] = partySeen[pe] or {}
    local name = Short(sender)
    for _, n in ipairs(partySeen[pe]) do if n == name then return end end
    table.insert(partySeen[pe], name)
    ns.Debounce("partyseen" .. pe, 1, function()
      local who = partySeen[pe] or {}
      partySeen[pe] = nil
      if #who == 0 then return end
      partyShownAt[pe] = GetTime()
      local line = #who == 1 and ns.T("EM_SEEN", who[1], "/" .. pe:lower())
        or ns.T("EM_SEEN_MANY", ns.T("EM_AND_MORE", who[1], #who - 1), "/" .. pe:lower())
      lastShown[pe] = nil
      Show(pe, who[1], line)
    end)
    return
  end
  -- "KISS"/"KISSBACK" are the old spelling of "E:KISS"/"EB:KISS" (still sent for kisses).
  local back, emote
  if msg == "KISS" then back, emote = "E", "KISS"
  elseif msg == "KISSBACK" then back, emote = "EB", "KISS"
  else back, emote = msg:match("^(EB?):(%u+)$") end
  if not emote or not EFFECTS[emote] then return end
  -- The bigger ones only come as an answer ("EB:"); the rest of the local ones never by message.
  if LOCAL_ONLY[emote] and not (back == "EB" and (emote == "PARTY" or emote == "GROUPHUG" or emote == "KISSKISS")) then return end
  -- They did it at you soon after you did it at them: the bigger one, for both.
  local combo = COMBO[emote]
  local mine = combo and didAt[emote .. Short(sender)]
  if back == "E" and mine and GetTime() - mine < (COMBO_WINDOW[emote] or PARTY_WINDOW) then
    didAt[emote .. Short(sender)] = nil
    gotAt[emote .. Short(sender)] = nil
    lastShown[combo] = nil
    Show(combo, sender)
    Send("EB:" .. combo, sender)
    return
  end
  if combo and back == "E" then gotAt[emote .. Short(sender)] = GetTime() end
  -- An answer to your own emote (not the shared combos, whose lines fit both of you).
  Show(emote, sender, back == "EB" and not LOCAL_ONLY[emote])
  if back == "E" then Send(emote == "KISS" and "KISSBACK" or ("EB:" .. emote), sender) end
end

-- Wipe: you died in a party; look for a while whether everyone else is dead too.
local lastWipe = 0
local function WholePartyDead()
  if not (IsInGroup and IsInGroup()) or (IsInRaid and IsInRaid()) then return false end
  if not UnitIsDeadOrGhost("player") then return false end
  local others = 0
  for i = 1, 4 do
    local u = "party" .. i
    if UnitExists(u) then
      others = others + 1
      if not UnitIsDeadOrGhost(u) then return false end
    end
  end
  return others >= 1
end
local function WatchForWipe(tries)
  if ns.db.eggsOff or GetTime() - lastWipe < 60 then return end
  local ok, wiped = pcall(WholePartyDead)
  if ok and wiped then
    lastWipe = GetTime()
    lastShown.WIPE = nil
    Show("WIPE")
  elseif tries > 0 and C_Timer and C_Timer.After then
    C_Timer.After(1, function() WatchForWipe(tries - 1) end)
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
  pcall(ev.RegisterEvent, ev, "UI_ERROR_MESSAGE")
  pcall(ev.RegisterEvent, ev, "CHAT_MSG_LOOT")
  pcall(ev.RegisterEvent, ev, "CHAT_MSG_SYSTEM")
  pcall(ev.RegisterEvent, ev, "PLAYER_DEAD")
  ev:SetScript("OnEvent", function(_, event, a1, a2, _, a4)
    if event == "UI_ERROR_MESSAGE" then
      pcall(OnUIError, a1, a2)
      return
    end
    if event == "CHAT_MSG_LOOT" then
      pcall(OnLootMsg, a1)
      return
    end
    if event == "CHAT_MSG_SYSTEM" then
      if not ns.db.eggsOff and type(a1) == "string" and not (issecretvalue and issecretvalue(a1)) then pcall(OnRoll100, a1) end
      return
    end
    if event == "PLAYER_DEAD" then
      pcall(WatchForWipe, 20)
      return
    end
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
  local e = (rest or ""):upper():match("(%w+)") or "KISS"
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
