SIM_BUFFS = { "Cat Form" }
SIM_CP = 5
function GetComboPoints() return SIM_CP end
-- Minimal WoW API-simulering för att köra DruidPlan utanför spelet.
local ADDON_DIR = arg[1]
local MODE = arg[2] or "classic"
if arg[3] then DruidPlanGlobal = { lang = arg[3] } end   -- "classic" = gamla API:er, "modern" = C_* API:er

local chat = {}
local errors = {}
local missingGlobals = {}

-------------------------------------------------------------------------------
-- Generiskt widget-objekt
-------------------------------------------------------------------------------
local Widget = {}
local allFrames = {}
local function newWidget(kind, name)
  local w = { __kind = kind, __shown = true, __scripts = {}, __events = {}, __text = "", __name = name }
  setmetatable(w, Widget)
  table.insert(allFrames, w)
  if name then _G[name] = w end
  return w
end
local methods = {}
Widget.__index = function(t, k)
  if methods[k] then return methods[k] end
  if type(k) == "string" and k:match("^%u") and not k:match("^DruidPlan") then return function() return nil end end -- okända metoder gör inget
  return nil
end
function methods:Show() self.__shown = true; if self.__scripts.OnShow then self.__scripts.OnShow(self) end end
function methods:Hide() self.__shown = false end
function methods:SetShown(v) if v then self:Show() else self:Hide() end end
function methods:IsShown() return self.__shown end
function methods:IsVisible() return self.__shown end
function methods:SetScript(k, fn) self.__scripts[k] = fn end
function methods:GetScript(k) return self.__scripts[k] end
function methods:HookScript(k, fn)
  local old = self.__scripts[k]
  self.__scripts[k] = function(...) if old then old(...) end fn(...) end
end
function methods:RegisterEvent(e) self.__events[e] = true end
function methods:SetTexture(t)
  -- WoW shows nothing for a texture that isn't a path or file ID.
  if t ~= nil and type(t) ~= "string" and type(t) ~= "number" then
    table.insert(errors, "SetTexture fick " .. type(t) .. " i stället för en sökväg")
  end
  rawset(self, "__tex", t)
end
function methods:GetTexture() return rawget(self, "__tex") end
function methods:UnregisterEvent(e) self.__events[e] = nil end
function methods:SetText(t) self.__text = t or "" end
function methods:GetText() return self.__text end
function methods:GetStringHeight() local _, n = (self.__text or ""):gsub("\n", ""); return (n + 1) * 12 end
function methods:GetWidth() return self.__w or 31 end
function methods:GetHeight() return self.__h or 31 end
function methods:SetWidth(w) self.__w = w end
function methods:SetHeight(h) self.__h = h end
function methods:SetSize(w, h) self.__w, self.__h = w, h end
function methods:GetPoint() return "CENTER", nil, "CENTER", 10, 20 end
function methods:GetCenter() return 500, 500 end
function methods:GetEffectiveScale() return 1 end
function methods:GetFrameLevel() return 5 end
function methods:IsMouseOver() return false end
function methods:CreateTexture() return newWidget("Texture") end
function methods:CreateFontString() local fs = newWidget("FontString"); rawset(fs, "__parent", self); return fs end
function methods:CreateAnimationGroup() return newWidget("AnimationGroup") end
function methods:CreateAnimation() return newWidget("Animation") end
function methods:GetItem() return self.__itemName, self.__itemLink end
function methods:AddLine(t) self.__lines = self.__lines or {}; table.insert(self.__lines, t) end
function methods:GetName() return self.__name end
function methods:SetScale(v) self.__scale = v end
function methods:GetScale() return self.__scale or 1 end
function methods:SetFontObject(o) if o == nil then error("SetFontObject(nil)") end self.__font = o end
function methods:SetWidth(w) self.__w = w; if self.__scripts.OnSizeChanged then self.__scripts.OnSizeChanged(self, w, self.__h) end end

function CreateFrame(kind, name, parent, template)
  local w = newWidget(kind, name); rawset(w, "__parent", parent); return w
end

UIParent = newWidget("Frame", "UIParent")
Minimap = newWidget("Frame", "Minimap"); Minimap.__w = 140
GameTooltip = newWidget("GameTooltip", "GameTooltip")
rawset(GameTooltip, "SetQuestItem", function() end)
ItemRefTooltip = newWidget("GameTooltip", "ItemRefTooltip")
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) table.insert(chat, m) end }
UISpecialFrames = {}
STANDARD_TEXT_FONT = "Fonts\\FRIZQT__.TTF"
SOUNDKIT = { RAID_WARNING = 8959 }
SlashCmdList = {}
unpack = table.unpack
GameFontHighlightSmall, GameFontHighlight, GameFontHighlightLarge, GameFontDisableSmall = {}, {}, {}, {}
function IsControlKeyDown() return true end

-------------------------------------------------------------------------------
-- Spel-state
-------------------------------------------------------------------------------
local now = 1000
function GetTime() return now end
local timers = {}
C_Timer = { After = function(d, fn) table.insert(timers, { t = now + d, fn = fn }) end }
local function runTimers(upTo)
  local again = true
  while again do
    again = false
    for i, t in ipairs(timers) do
      if t.t <= upTo then
        table.remove(timers, i)
        local ok, err = pcall(t.fn)
        if not ok then table.insert(errors, "timer: " .. tostring(err)) end
        again = true
        break
      end
    end
  end
end

function UnitClass() return "Druid", "DRUID" end
local playerLevel = 25
function UnitLevel() return playerLevel end
function UnitExists(u) return u == "target" or u == "player" end
function UnitCanAttack() return true end
function UnitIsDead() return false end
function UnitAffectingCombat() return true end
function InCombatLockdown() return false end
function UnitCharacterPoints() return 2 end
function PlaySound() end
function hooksecurefunc(name, fn, fn2)
  if type(name) == "string" then
    local old = _G[name]
    _G[name] = function(...) local r = { old and old(...) } fn(...) return table.unpack(r) end
  elseif type(name) == "table" and type(fn) == "string" then
    local t, m, hook = name, fn, fn2
    local old = t[m]
    rawset(t, m, function(...) local r = { old and old(...) } hook(...) return table.unpack(r) end)
  end
end
function GetCursorPosition() return 600, 450 end
function DoEmote() end
function GetItemIcon(id) return 134400 + (id or 0) end
function GetSpellTexture(n) if type(n) == "string" and (n:find("^Holy Light") or n == "Frostbolt" or n == "Fire Blast" or n == "Devotion Aura" or n == "Righteous Fury" or n == "Battle Shout" or n == "Lightning Shield") then return 135920 end end
function UnitIsPlayer(u) return u == "target" or u == "player" end
function UnitIsUnit(a, b) return a == b end
UnitName = UnitName or function(u) if u == "target" then return "Kissy", nil end return "Me", nil end
SIM_ADDONMSG = {}
C_ChatInfo = { RegisterAddonMessagePrefix = function() return true end,
  SendAddonMessage = function(p, m, c, t) table.insert(SIM_ADDONMSG, p .. ":" .. m .. ">" .. tostring(t)) end }

-- Spells: namn -> {id, rank}
local spells = {
  ["Wrath"] = { 5177, 3 }, ["Moonfire"] = { 8924, 3 }, ["Mark of the Wild"] = { 5232, 2 },
  ["Thorns"] = { 782, 2 }, ["Rejuvenation"] = { 1430, 3 }, ["Claw"] = { 1082, 1 }, ["Rake"] = { 1822, 1 },
  ["Entangling Roots"] = { 339, 1 }, ["Faerie Fire"] = { 770, 1 }, ["Rip"] = { 1079, 1 },
}
local byId = {}
for n, d in pairs(spells) do byId[d[1]] = n end
byId[5176] = "Wrath" -- rank 1, ligger på knapp 1
local spellRank = { [5176] = 1 }
for n, d in pairs(spells) do spellRank[d[1]] = d[2] end

local function spellLookup(s)
  if type(s) == "number" then
    local n = byId[s]
    if n then return n, s end
    return nil
  end
  local d = spells[s]
  if d then return s, d[1] end
end

if MODE == "modern" then
  C_Spell = {
    GetSpellInfo = function(s) local n, id = spellLookup(s); if n then return { name = n, spellID = id } end end,
    GetSpellCooldown = function(s) if s == "Faerie Fire" then return { startTime = now - 2, duration = 8 } end return { startTime = 0, duration = 0 } end,
  }
  C_Item = {
    GetItemInfo = function(i) return GetItemInfoMock(i) end,
    GetItemCount = function(id) return GetItemCountMock(id) end,
  }
  C_UnitAuras = {
    GetAuraDataByIndex = function(u, i, f)
      local list = (u == "player" and f == "HELPFUL") and SIM_BUFFS or {}
      if list[i] then return { name = list[i], spellId = 1, applications = 0 } end
    end,
  }
  BackdropTemplateMixin = {}
  TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) TooltipPostCall = fn end }
  Enum = { TooltipDataType = { Item = 0 } }
else
  function GetSpellInfo(s) local n, id = spellLookup(s); if n then return n, nil, 0, 0, 0, 0, id end end
  function GetSpellCooldown(s)  return 0, 0 end
  function UnitAura(u, i, f)
    local list = (u == "player" and f == "HELPFUL") and SIM_BUFFS or {}
    if list[i] then return list[i], 0, 0, nil, 10, now + 5, "player", false, false, 1 end
  end
end
function GetSpellSubtext(id) local r = spellRank[id]; return r and ("Rank " .. r) or "" end

-- Action bars: knapp 1 = Frostbolt rank 1, knapp 2 = Frost Nova, knapp 3 = Blizzard
local actions = { [1] = 5176, [2] = 8924, [3] = 1082, [4] = 1822 }
function GetActionInfo(slot) local id = actions[slot]; if id then return "spell", id end end

-- Talents
local talents = {
  [2] = {
    { "Ferocity", 1, 5, 5 }, { "Feral Swiftness", 2, 2, 2 }, { "Thick Hide", 2, 3, 3 },
    { "Feral Charge", 3, 1, 1 }, { "Sharpened Claws", 3, 1, 2 }, { "Predatory Strikes", 4, 0, 3 },
  },
  [1] = { { "Genesis", 1, 0, 5 } }, [3] = { { "Heart of the Wild", 1, 0, 5 } },
}
function GetNumTalentTabs() return 3 end
function GetNumTalents(tab) return #talents[tab] end
function GetTalentInfo(tab, i) local t = talents[tab][i]; return t[1], "icon", t[2], 1, t[3], t[4] end

-- Yrken
local skills = { { "Professions", true }, { "Alchemy", false, 87, 150 }, { "Herbalism", false, 140, 150 } }
function GetNumSkillLines() return #skills end
function GetSkillLineInfo(i) local s = skills[i]; return s[1], s[2], false, s[3] or 0, 0, 0, s[4] or 0 end

-- Items
local items = {
  [2997] = { "Bolt of Woolen Cloth", 1, 15, "", 25, 2, 7, 0 },
  [2592] = { "Wool Cloth", 1, 15, "", 33, 7, 5, 0 },
  [2321] = { "Fine Thread", 1, 10, "", 25, 7, 5, 0 },
  [4340] = { "Gray Dye", 1, 10, "", 6, 7, 5, 0 },
  [10940] = { "Strange Dust", 1, 10, "", 0, 7, 12, 0 },
  [10938] = { "Lesser Magic Essence", 1, 10, "", 0, 7, 12, 0 },
  [11083] = { "Soul Dust", 1, 30, "", 0, 7, 12, 0 },
  [5000] = { "Feral Leggings", 2, 24, "INVTYPE_LEGS", 820, 4, 2, 2 },        -- grön, ilvl 24
  [5001] = { "Soulbound Robe", 3, 28, "INVTYPE_CHEST", 1500, 4, 1, 1 },     -- blå, BoP, ilvl 28
  [5002] = { "Gray Junk", 0, 10, "INVTYPE_HEAD", 50, 4, 1, 0 },
  [6000] = { "Silky Robe", 2, 22, "INVTYPE_CHEST", 400, 4, 1, 2, 1, 20 },
  [6001] = { "Old Robe", 1, 12, "INVTYPE_CHEST", 50, 4, 1, 0, 1, 10 },
  [6002] = { "Leather Vest", 2, 22, "INVTYPE_CHEST", 400, 4, 1, 2, 2, 20 },
  [6003] = { "Future Gloves", 2, 30, "INVTYPE_HAND", 400, 4, 1, 2, 1, 30 },
}
function GetItemInfoMock(item)
  local id = type(item) == "number" and item or tonumber(tostring(item):match("item:(%d+)"))
  local d = id and items[id]
  if not d then return nil end
  -- name, link, quality, ilvl, minLevel, type, subType, stack, equipLoc, tex, sellPrice, classID, subclassID, bindType
  return d[1], "|Hitem:" .. id .. "|h[" .. d[1] .. "]|h", d[2], d[3], d[10] or 1, "x", "y", 1, d[4], 0, d[5], d[6], d[9] or 1, d[8]
end
local counts = { [8077] = 6, [2997] = 3, [2592] = 20, [2321] = 4, [10940] = 12, [2589] = 0, [4306] = 40 }
function GetItemCountMock(id) return counts[id] or 0 end
if MODE ~= "modern" then
  GetItemInfo = GetItemInfoMock
  GetItemCount = GetItemCountMock
end

TOOLTIP_TEXT = {
  [6000] = { "Silky Robe", "+5 Intellect", "+2 Spirit", "Equip: Increases damage done by Frost spells and effects by up to 9.", "(2) Set: Increases damage and healing done by magical spells and effects by up to 20." },
  [6001] = { "Old Robe", "+3 Intellect" },
  [6003] = { "Future Gloves", "Equip: Increases spell power by 12." },
}
local function ttLines(link) local id = tonumber(tostring(link):match("item:(%d+)")); return TOOLTIP_TEXT[id] or { "x" } end
function methods:SetHyperlink(link)
  local lines = ttLines(link); self.__n = #lines
  for i, t in ipairs(lines) do local fs = newWidget("FontString", (self.__name or "") .. "TextLeft" .. i); fs.__text = t end
end
function methods:NumLines() return self.__n or 0 end
function methods:ClearLines() self.__n = 0 end
if MODE == "modern" then
  C_TooltipInfo = { GetHyperlink = function(link) local out = {} for _, t in ipairs(ttLines(link)) do table.insert(out, { leftText = t }) end return { lines = out } end }
end
function GetInventoryItemLink(_, slot) if slot == 5 then return "|Hitem:6001|h[Old Robe]|h" end end
UIErrorsFrame = newWidget("Frame", "UIErrorsFrame")
function UnitGUID(u) return u == "player" and "Player-1" or "Creature-9" end
local xp, xpmax = 1000, 10000
function UnitXP() return xp end
function UnitXPMax() return xpmax end
function GetXPExhaustion() return 500 end
function GetMoney() return 345000 end
function GetZoneText() return "Silverpine Forest" end
function GetSubZoneText() return "" end
function GetInstanceInfo() return "Shadowfang Keep" end
local cleu = {}
function CombatLogGetCurrentEventInfo() return table.unpack(cleu) end
-- QUESTSIM
function GetNumQuestChoices() return 3 end
local qlinks = { "|Hitem:6002|h[Leather Vest]|h", "|Hitem:6000|h[Silky Robe]|h", "|Hitem:5000|h[Feral Leggings]|h" }
function GetQuestItemLink(kind, i) return qlinks[i] end
function GetQuestItemInfo(kind, i) return "x", 0, 1, 2, true end
QuestInfoRewardsFrame = newWidget("Frame", "QuestInfoRewardsFrame")
QuestInfoRewardsFrame.RewardButtons = { newWidget("Button"), newWidget("Button"), newWidget("Button") }
local mana = 300
function UnitPower() return mana end
function UnitPowerMax() return 1000 end
function UnitIsDeadOrGhost() return false end
function GetNumTradeSkills() return 2 end
function GetTradeSkillLine() return "Alchemy", 87, 150 end
function GetTradeSkillInfo(i) if i == 1 then return "Cloth", "header" end return "Silky Robe", "optimal" end
function GetTradeSkillItemLink(i) return "|Hitem:6000|h[Silky Robe]|h" end
SIM = { setMana = function(v) mana = v end, setXP = function(v) xp = v end, setCLEU = function(t) cleu = t end }

-- Väskor
local bag = { [1] = 5000, [2] = 5001, [3] = 5002 }
function GetContainerNumSlots(b) return b == 0 and 16 or 0 end
function GetContainerItemLink(b, s) local id = b == 0 and bag[s]; if id then return "|Hitem:" .. id .. "|h[x]|h" end end

-- Auctionator
Auctionator = { API = { v1 = {
  GetAuctionPriceByItemID = function(_, id) local p = { [10940] = 1500, [10998] = 6000, [10978] = 9000, [11083] = 4000, [11082] = 15000, [11084] = 20000 }; return p[id] end,
  GetAuctionPriceByItemLink = function(_, link) if link:find("5000") then return 2500 end end,
} } }

PanelTemplates_GetSelectedTab = function() return 3 end
function PlayerTalentFrame_Update() end

-- Dungeon guide / arrow mocks
function wipe(t) for k in pairs(t) do t[k] = nil end return t end
function UnitRace() return "Skyborne", "Skyborne", 30 end
function UnitFactionGroup() return "Alliance", "Alliance" end
SIM_INST = { "Westfall", "none", 0 }
function GetInstanceInfo() return SIM_INST[1], SIM_INST[2], 0, "", 5, 0, false, SIM_INST[3] end
SIM_FACING, SIM_PMAP, SIM_PX, SIM_PY = 0, 1436, 0.5, 0.5
function GetPlayerFacing() return SIM_FACING end
function CreateVector2D(x, y) return { x = x, y = y, GetXY = function(v) return v.x, v.y end } end
C_Map = {
  GetBestMapForUnit = function() return SIM_PMAP end,
  GetPlayerMapPosition = function() return CreateVector2D(SIM_PX, SIM_PY) end,
  -- every map is 1000 yards; north = -y, west = -x
  GetWorldPosFromMapPos = function(m, v) return (m == 1453 and 1 or 0), CreateVector2D(-v.y * 1000, -v.x * 1000) end,
  GetMapInfo = function(m) return { name = "Map" .. m } end,
}
SIM_DONE = { [155] = true }
SIM_LOG = { 168, 2040 }
if MODE == "modern" then
  C_QuestLog = {
    IsQuestFlaggedCompleted = function(id) return SIM_DONE[id] or false end,
    GetNumQuestLogEntries = function() return #SIM_LOG + 1 end,
    GetInfo = function(i) if i == 1 then return { isHeader = true } end return { questID = SIM_LOG[i - 1] } end,
    GetTitleForQuestID = function() return nil end,
  }
else
  function IsQuestFlaggedCompleted(id) return SIM_DONE[id] or false end
  function GetNumQuestLogEntries() return #SIM_LOG + 1 end
  function GetQuestLogTitle(i) if i == 1 then return "Westfall", 0, 0, true end return "q", 20, 0, false, false, false, 0, SIM_LOG[i - 1] end
end
WorldMapFrame = newWidget("Frame", "WorldMapFrame")
for _, f in ipairs({"GameFontNormal","GameFontNormalLarge","GameFontHighlight","GameFontHighlightSmall","GameFontHighlightLarge","GameFontDisableSmall"}) do _G[f] = _G[f] or { name = f } end
function methods:SetScrollChild(c) self.__child = c end
function methods:SetVerticalScroll() end

-------------------------------------------------------------------------------
-- Logga läsningar av okända globaler (för att hitta stavfel)
-------------------------------------------------------------------------------
setmetatable(_G, { __index = function(_, k) missingGlobals[k] = true; return nil end })

-------------------------------------------------------------------------------
-- Ladda addonet
-------------------------------------------------------------------------------
local ns = {}
local toc = io.open(ADDON_DIR .. "/DruidPlan.toc"):read("a")
for line in toc:gmatch("[^\r\n]+") do
  if line:match("%.lua$") then
    local f, err = loadfile(ADDON_DIR .. "/" .. line)
    if not f then table.insert(errors, "load " .. line .. ": " .. err)
    else
      local ok, e = pcall(f, "DruidPlan", ns)
      if not ok then table.insert(errors, "run " .. line .. ": " .. tostring(e)) end
    end
  end
end

local function fire(event, ...)
  for _, w in ipairs(allFrames) do
    if w.__events[event] and w.__scripts.OnEvent then
      local ok, err = pcall(w.__scripts.OnEvent, w, event, ...)
      if not ok then table.insert(errors, event .. ": " .. tostring(err)) end
    end
  end
end

local function slash(msg)
  local ok, err = pcall(SlashCmdList.DRUIDPLAN, msg)
  if not ok then table.insert(errors, "/mp " .. msg .. ": " .. tostring(err)) end
end

fire("ADDON_LOADED", "DruidPlan")
fire("PLAYER_LOGIN")
now = now + 10; runTimers(now)

-- Simulera spel: OnUpdate-tick, events, kommandon
for _, w in ipairs(allFrames) do
  if w.__scripts.OnUpdate then
    local ok, err = pcall(w.__scripts.OnUpdate, w, 0.2)
    if not ok then table.insert(errors, "OnUpdate: " .. tostring(err)) end
  end
end
fire("BAG_UPDATE"); fire("SKILL_LINES_CHANGED"); fire("CHARACTER_POINTS_CHANGED")
playerLevel = 26; fire("PLAYER_LEVEL_UP", 26)
now = now + 5; runTimers(now)

for _, cmd in ipairs({ "help", "craft", "ranks", "all", "lock", "lock", "combat", "combat", "move", "move", "minimap", "minimap", "theme", "theme", "theme", "theme", "lang", "lang", "font", "font", "font", "reset", "" , "", "nonsense" }) do
  slash(cmd)
end
now = now + 5; runTimers(now)

-- Fönster: dra hörnet, Ctrl+mushjul
for _, wn in ipairs({ "DruidPlanFrame", "DruidPlanCraftFrame", "DruidPlanShatterFrame" }) do
  local w = rawget(_G, wn)
  if w then
    local g = rawget(w, "grip")
    if g then
      local ok, err = pcall(g.__scripts.OnMouseDown, g); if not ok then table.insert(errors, wn .. " grip down: " .. err) end
      w:SetWidth(450)
      ok, err = pcall(g.__scripts.OnMouseUp, g); if not ok then table.insert(errors, wn .. " grip up: " .. err) end
    end
    if w.__scripts.OnMouseWheel then
      local ok, err = pcall(w.__scripts.OnMouseWheel, w, 1); if not ok then table.insert(errors, wn .. " wheel: " .. err) end
    end
  end
end
table.insert(chat, "[sim] planfönster bredd " .. tostring(ns.db.posW) .. ", skala " .. tostring(ns.db.posS) .. ", tema " .. tostring(ns.db.theme) .. ", text " .. tostring(ns.db.fontSize))

-- Talentfönstret laddas
PlayerTalentFrame = newWidget("Frame", "PlayerTalentFrame")
for i = 1, 6 do newWidget("Button", "PlayerTalentFrameTalent" .. i) end
fire("ADDON_LOADED", "Blizzard_TalentUI")
PlayerTalentFrame:Show()
now = now + 1; runTimers(now)

-- Minimap-knapp: klick, meny, menyval
local btn = rawget(_G, "DruidPlanMinimapButton")
if btn then
  pcall(btn.__scripts.OnEnter, btn)
  local ok, err = pcall(btn.__scripts.OnClick, btn, "LeftButton"); if not ok then table.insert(errors, "minimap left: " .. err) end
  local qm = rawget(_G, "DruidPlanQuickMenu")
  if not qm or not qm.__shown then table.insert(errors, "vänsterklick öppnade inte snabbmenyn") end
  if qm then
    local rows = 0
    for _, w in ipairs(allFrames) do if w.__parent == qm and w.__kind == "Button" then rows = rows + 1 end end
    print("--- Snabbmeny: " .. rows .. " rader ---")
  end
  ok, err = pcall(btn.__scripts.OnClick, btn, "RightButton"); if not ok then table.insert(errors, "minimap right: " .. err) end
  pcall(btn.__scripts.OnDragStart, btn)
  if btn.__scripts.OnUpdate then ok, err = pcall(btn.__scripts.OnUpdate, btn, 0.1); if not ok then table.insert(errors, "minimap drag: " .. err) end end
  pcall(btn.__scripts.OnDragStop, btn)
  local cfg = rawget(_G, "DruidPlanConfig")
  if not cfg then table.insert(errors, "inställningsfönstret skapades inte") end
  if cfg and not cfg.__shown then table.insert(errors, "högerklick öppnade inte inställningarna") end
  local before = { lang = DruidPlanGlobal.lang, plan = ns.db.plan, theme = ns.db.theme, font = ns.db.fontSize, drink = ns.db.drinkOff }
  local clicked = 0
  for round = 1, 2 do
    for _, w in ipairs(allFrames) do
      if (w.__kind == "Button" or w.__kind == "CheckButton") and w ~= btn and w.__scripts.OnClick and not (w.__name or ""):match("^PlayerTalent") then
        local okc, errc = pcall(w.__scripts.OnClick, w, "LeftButton")
        if not okc then table.insert(errors, "klick " .. tostring(w.key or (w.item and w.item.key)) .. ": " .. errc) end
        clicked = clicked + 1
      end
    end
  end
  if DruidPlanGlobal.lang ~= before.lang then table.insert(errors, "språket ändrades netto av klicken") end
  if (not ns.db.drinkOff) ~= (not before.drink) then table.insert(errors, "drink-toggle ändrades netto") end
  table.insert(chat, "[sim] klickade " .. clicked .. " knappar i inställningarna")
  ns.db.plan, ns.db.theme, ns.db.fontSize = before.plan, before.theme, before.font
  ns.ApplyPlan()
  ok, err = pcall(SlashCmdList.DRUIDPLAN, "config"); if not ok then table.insert(errors, "/mp config: " .. err) end
else
  table.insert(errors, "minimap-knappen skapades inte")
end
now = now + 5; runTimers(now)


-- Dungeon guide
do
  local ok, err = pcall(SlashCmdList.DRUIDPLAN, "dungeons dead")
  if not ok then table.insert(errors, "/mp dungeons: " .. err) end
  local dw = rawget(_G, "DruidPlanDungeons")
  if not (dw and dw.__shown) then table.insert(errors, "dungeon-fönstret öppnades inte") end
  now = now + 1; runTimers(now)
  print("--- Dungeon: rader ---")
  for _, w in ipairs(allFrames) do
    if w.__kind == "Button" and w.__shown and w.text and w.sub and w.right then
      local function clean(t) return ((t or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")) end
      print("  " .. clean(w.text.__text) .. "  [" .. clean(w.right.__text) .. "]  " .. clean(w.sub.__text))
    end
  end
  -- Click every dungeon in the list and every row in it.
  local listed = {}
  for _, w in ipairs(allFrames) do if w.dungeon then listed[#listed + 1] = w end end
  for _, b in ipairs(listed) do
    local okc, errc = pcall(b.__scripts.OnClick, b); if not okc then table.insert(errors, "dungeon " .. b.dungeon.name .. ": " .. errc) end
    now = now + 1; runTimers(now)
    for _, w in ipairs(allFrames) do
      if w.__kind == "Button" and w.__shown and w.sub and w.__scripts.OnClick then
        local okr, errr = pcall(w.__scripts.OnClick, w); if not okr then table.insert(errors, "rad i " .. b.dungeon.name .. ": " .. errr) end
        if w.__scripts.OnEnter then local oke, erre = pcall(w.__scripts.OnEnter, w); if not oke then table.insert(errors, "tooltip i " .. b.dungeon.name .. ": " .. erre) end end
      end
    end
  end
  table.insert(chat, "[sim] dungeons i listan: " .. #listed)
  -- Arrow: point, turn, arrive, disappear
  ns.SetWaypoint(1436, 56.33, 47.52, "Gryan Stoutmantle")
  local ar = rawget(_G, "DruidPlanArrow")
  if not (ar and ar.__shown) then table.insert(errors, "pilen visades inte") else
    SIM_PX, SIM_PY = 0.5, 0.5
    local okA, errA = pcall(ar.__scripts.OnUpdate, ar, 0.1)
    if not okA then table.insert(errors, "pil: " .. errA) end
    table.insert(chat, "[sim] pil avstånd: " .. tostring(ar.dist.__text))
    SIM_PMAP = 1453; pcall(ar.__scripts.OnUpdate, ar, 0.1)
    table.insert(chat, "[sim] annan kontinent: " .. tostring(ar.dist.__text))
    SIM_PMAP, SIM_PX, SIM_PY = 1436, 0.5633, 0.4752
    pcall(ar.__scripts.OnUpdate, ar, 0.1)
    table.insert(chat, "[sim] framme: " .. tostring(ar.dist.__text))
    now = now + 5; pcall(ar.__scripts.OnUpdate, ar, 0.1)
    if ar.__shown then table.insert(errors, "pilen försvann inte efter ankomst") end
  end
  -- Zoning into the Deadmines prints a summary.
  SIM_INST = { "The Deadmines", "party", 36 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
  SIM_INST = { "Westfall", "none", 0 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
end

-- Profiles
do
  local function chk(cond, msg) if not cond then table.insert(errors, "profil: " .. msg) end end
  chk(ns.ActiveProfile() == "Default", "aktiv borde vara Default, är " .. tostring(ns.ActiveProfile()))
  ns.db.pos = { "CENTER", "CENTER", 11, 22 }; ns.db.theme = "dark"
  ns.NewProfile("Dungeon")
  chk(ns.ActiveProfile() == "Dungeon", "ny profil blev inte aktiv")
  ns.db.pos = { "TOP", "TOP", 99, 99 }; ns.db.theme = "frost"; ns.db.zoneTipsOff = true
  ns.SwitchProfile("Default")
  chk(ns.db.pos and ns.db.pos[3] == 11, "Default fick inte tillbaka sin position")
  chk(ns.db.theme == "dark", "Default fick inte tillbaka sitt tema")
  chk(not ns.db.zoneTipsOff, "Default fick inte tillbaka zon-tips")
  ns.SwitchProfile("Dungeon")
  chk(ns.db.pos and ns.db.pos[3] == 99 and ns.db.theme == "frost", "Dungeon sparade inte sina ändringar")
  ns.SwitchProfile("Default")
  -- Auto-switch and auto-open in dungeons
  DruidPlanGlobal.dungeonProfile = "Dungeon"
  ns.db.dungeonAutoOpen = true
  local dw = rawget(_G, "DruidPlanDungeons"); if dw then dw:Hide() end
  SIM_INST = { "The Deadmines", "party", 36 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
  chk(ns.ActiveProfile() == "Dungeon", "byttes inte till Dungeon i dungeon")
  chk(dw and dw.__shown, "dungeonguiden öppnades inte automatiskt")
  SIM_INST = { "Westfall", "none", 0 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
  chk(ns.ActiveProfile() == "Default", "byttes inte tillbaka efter dungeon, är " .. tostring(ns.ActiveProfile()))
  ns.DeleteProfile("Dungeon")
  chk(#ns.ProfileNames() == 1 and DruidPlanGlobal.dungeonProfile == nil, "radera fungerade inte")
  ns.DeleteProfile("Default")
  chk(#ns.ProfileNames() == 1, "sista profilen gick att radera")
  local ok, err = pcall(SlashCmdList.DRUIDPLAN, "profile"); chk(ok, tostring(err))
  table.insert(chat, "[sim] profiler: " .. table.concat(ns.ProfileNames(), ","))
end

-- Secret mana value (Forever hides it sometimes)
do
  local secret = setmetatable({}, { __div = function() error("attempt to perform arithmetic on a secret number value") end,
    __lt = function() error("secret compare") end, __le = function() error("secret compare") end })
  local oldP, oldM = UnitPower, UnitPowerMax
  issecretvalue = function(v) return v == secret end
  UnitPower = function() return secret end
  local ok, err = pcall(ns.ManaPct)
  if not ok then table.insert(errors, "ManaPct med secret: " .. tostring(err)) end
  if ok and err ~= nil then table.insert(errors, "ManaPct borde ge nil med secret") end
  fire("UNIT_POWER_UPDATE", "player"); now = now + 1; runTimers(now)
  UnitPower, UnitPowerMax, issecretvalue = oldP, oldM, nil
end

-- Emote easter eggs
do
  DoEmote("KISS", "target")
  DoEmote("KISS", "target") -- throttled
  DoEmote("DANCE", "target")
  DoEmote("DRINK", "target") -- /drink gives the mugs
  DoEmote("SIT", "target")   -- not an easter egg
  table.insert(chat, "[sim] addon msgs after emotes: " .. table.concat(SIM_ADDONMSG, ", "))
  fire("CHAT_MSG_ADDON", "ZodacPlan", "KISS", "WHISPER", "Lover-Realm")
  fire("CHAT_MSG_ADDON", "ZodacPlan", "E:CHEER", "WHISPER", "Pal-Realm")
  fire("CHAT_MSG_ADDON", "ZodacPlan", "EB:HUG", "WHISPER", "Pal-Realm")
  fire("CHAT_MSG_ADDON", "ZodacPlan", "E:NOPE", "WHISPER", "Pal-Realm")
  table.insert(chat, "[sim] addon msgs after receive: " .. table.concat(SIM_ADDONMSG, ", "))
  for _, e in ipairs({ "KISS", "DANCE", "CHEER", "HUG", "WAVE", "TOAST", "CHICKEN" }) do
    local ok, err = pcall(ns.ShowEmoteEgg, e, "Tester")
    if not ok then table.insert(errors, "emote " .. e .. ": " .. tostring(err)) end
  end
  local okc, errc = pcall(SlashCmdList[next(SlashCmdList)], "egg chicken")
  if not okc then table.insert(errors, "/egg: " .. tostring(errc)) end
  local want = "ZodacPlan:KISS>Kissy, ZodacPlan:E:DANCE>Kissy, ZodacPlan:E:TOAST>Kissy, ZodacPlan:KISSBACK>Lover-Realm, ZodacPlan:EB:CHEER>Pal-Realm"
  if table.concat(SIM_ADDONMSG, ", ") ~= want then table.insert(errors, "emote-meddelanden: " .. table.concat(SIM_ADDONMSG, ", ")) end
end
-- Nya moduler: polymorph, XP, zon, guld
ns.db.polyOff, ns.db.xpOff, ns.db.zoneTipsOff, ns.db.upgradeOff, ns.db.tooltipOff = false, false, false, false, false
SIM.setCLEU({ 0, "SPELL_AURA_APPLIED", false, "Player-1", "Me", 0, 0, "Creature-9", "Kobold", 0, 0, 0, "Polymorph" })
fire("COMBAT_LOG_EVENT_UNFILTERED")
now = now + 16; runTimers(now)
SIM.setCLEU({ 0, "SPELL_AURA_BROKEN_SPELL", false, "Player-1", "Me", 0, 0, "Creature-9", "Kobold", 0, 0, 0, "Polymorph" })
fire("COMBAT_LOG_EVENT_UNFILTERED")
SIM.setCLEU({ 0, "SPELL_AURA_APPLIED", false, "Player-1", "Me", 0, 0, "Creature-8", "Gnoll", 0, 0, 0, "Polymorph" })
fire("COMBAT_LOG_EVENT_UNFILTERED")
now = now + 31; runTimers(now)
SIM.setCLEU({ 0, "SPELL_AURA_REMOVED", false, "Player-1", "Me", 0, 0, "Creature-8", "Gnoll", 0, 0, 0, "Polymorph" })
fire("COMBAT_LOG_EVENT_UNFILTERED")
fire("CHAT_MSG_COMBAT_XP_GAIN", "Kobold dies, you gain 120 experience.")
now = now + 300; SIM.setXP(4000); fire("PLAYER_XP_UPDATE")
fire("ZONE_CHANGED_NEW_AREA"); now = now + 2; runTimers(now)
slash("goal 100 mount"); slash("goal"); 
now = now + 2; runTimers(now)

-- QUESTSIM: quest, drink, recipes, plans
ns.db.questOff, ns.db.drinkOff = false, false
fire("QUEST_COMPLETE"); now = now + 1; runTimers(now)
local btn2 = QuestInfoRewardsFrame.RewardButtons[2]
do
  local b = {}
  for i, rb in ipairs(QuestInfoRewardsFrame.RewardButtons) do
    local badges = rawget(rb, "DruidPlanBadges") or {}
    for k, m in pairs(badges) do if m.__shown then table.insert(b, i .. k) end end
  end
  table.sort(b)
  table.insert(chat, "[sim] quest badges: " .. table.concat(b, ", "))
  if #b == 0 then table.insert(errors, "inga quest-märken") end
  for i = 1, 3 do
    GameTooltip.__lines = nil
    GameTooltip:SetQuestItem("choice", i)
    for _, l in ipairs(rawget(GameTooltip, "__lines") or {}) do
      table.insert(chat, "[sim] quest tooltip " .. i .. ": " .. (l:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
    end
  end
  GameTooltip.__lines = nil
end
UnitAffectingCombat = function() return false end
fire("PLAYER_REGEN_ENABLED"); now = now + 1; runTimers(now)
local df = rawget(_G, "DruidPlanDrinkFrame")
table.insert(chat, "[sim] drink shown at 30%: " .. tostring(df and df.__shown))
SIM.setMana(900); fire("UNIT_POWER_UPDATE", "player"); now = now + 1; runTimers(now)
table.insert(chat, "[sim] drink shown at 90%: " .. tostring(df and df.__shown))
fire("TRADE_SKILL_SHOW"); now = now + 1; runTimers(now)
-- recipes removed in 1.7.2
slash("plan"); table.insert(chat, "[sim] talent 10 = " .. tostring(ns.talents[10]) .. ", 60 = " .. tostring(ns.talents[60]))
slash("plan"); table.insert(chat, "[sim] talent 10 = " .. tostring(ns.talents[10]) .. ", 42 = " .. tostring(ns.talents[42]) .. ", 60 = " .. tostring(ns.talents[60]))
slash("plan"); table.insert(chat, "[sim] talent 25 = " .. tostring(ns.talents[25]))
now = now + 1; runTimers(now)

-- Tooltip
ns.db.tooltipOff = false
GameTooltip.__lines = nil
GameTooltip.__itemName, GameTooltip.__itemLink = "Silky Robe", "|Hitem:6000|h[Silky Robe]|h"
if TooltipPostCall then pcall(TooltipPostCall, GameTooltip)
elseif GameTooltip.__scripts.OnTooltipSetItem then
  local ok, err = pcall(GameTooltip.__scripts.OnTooltipSetItem, GameTooltip); if not ok then table.insert(errors, "tooltip: " .. err) end
end

-------------------------------------------------------------------------------
-- Rapport
-------------------------------------------------------------------------------
print("=== LÄGE: " .. MODE .. " ===")
print("--- Chatt ---")
for _, m in ipairs(chat) do print((m:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))) end
local function tipFor(id, nm)
  GameTooltip.__lines = nil
  GameTooltip.__itemName, GameTooltip.__itemLink = nm, "|Hitem:" .. id .. "|h[" .. nm .. "]|h"
  if TooltipPostCall then pcall(TooltipPostCall, GameTooltip) elseif GameTooltip.__scripts.OnTooltipSetItem then
    local ok, err = pcall(GameTooltip.__scripts.OnTooltipSetItem, GameTooltip); if not ok then table.insert(errors, "tooltip: " .. err) end end
  print("  [" .. nm .. "]")
  for _, l in ipairs(rawget(GameTooltip, "__lines") or {}) do print("    " .. (l:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))) end
end
print("--- Tooltip-test (uppgradering) ---") -- DEBUGUP
for _, id in ipairs({6000, 6003, 6002}) do
  local ok, d, lvl = pcall(ns.CompareToEquipped, "|Hitem:" .. id .. "|h[x]|h")
  print("  compare", id, ok, d, lvl, "score", pcall(ns.ItemScore, "|Hitem:" .. id .. "|h[x]|h"))
end
tipFor(6003, "Future Gloves"); tipFor(6002, "Leather Vest"); tipFor(6001, "Old Robe")
GameTooltip.__lines = nil
GameTooltip.__itemName, GameTooltip.__itemLink = "Silky Robe", "|Hitem:6000|h[Silky Robe]|h"
if TooltipPostCall then pcall(TooltipPostCall, GameTooltip) elseif GameTooltip.__scripts.OnTooltipSetItem then pcall(GameTooltip.__scripts.OnTooltipSetItem, GameTooltip) end
print("--- Tooltip-rader ---")
for _, l in ipairs(GameTooltip.__lines or {}) do print((l:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))) end
local function show(name)
  local f = rawget(_G, name)
  if f and f.text then
    print("--- " .. name .. (f.__shown and " (synlig)" or " (dold)") .. " ---")
    print((f.text.__text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
  end
end
if arg[4] == "trainer" then fire("TRAINER_SHOW"); now = now + 1; runTimers(now) end
ns.RefreshMain(); ns.mainFrame:Show(); ns.RefreshMain()
-- Plan window rows: click each one, open "Coming up" and check rows were drawn.
do
  local mf, rows, clicked = ns.mainFrame, 0, 0
  for _, w in ipairs(allFrames) do
    if w.__parent == mf and w.__kind == "Button" and w.__shown then
      rows = rows + 1
      if w.__scripts.OnClick then
        local ok, err = pcall(w.__scripts.OnClick, w, "LeftButton")
        if not ok then table.insert(errors, "planrad: " .. tostring(err)) end
        clicked = clicked + 1
      end
      if w.__scripts.OnEnter then
        local ok, err = pcall(w.__scripts.OnEnter, w)
        if not ok then table.insert(errors, "planrad tooltip: " .. tostring(err)) end
      end
    end
  end
  if rows < 3 then table.insert(errors, "planfönstret ritade bara " .. rows .. " rader") end
  print("--- Planfönster: " .. rows .. " rader, " .. clicked .. " klickade, kommande " .. (ns.db.comingOpen and "öppen" or "stängd") .. " ---")
  ns.db.comingOpen = true; ns.RefreshMain()
end
show("DruidPlanFrame")
ns.craftWindow:Show(); ns.RefreshCraft()
show("DruidPlanCraftFrame")
print("--- Stridshjälp ---")
do
  local cf = rawget(_G, "DruidPlanShatterFrame")
  local function dump(label)
    now = now + 1
    for _, w in ipairs(allFrames) do if w.__scripts.OnUpdate and w ~= cf then pcall(w.__scripts.OnUpdate, w, 0.2) end end
    local texts = {}
    for _, w in ipairs(allFrames) do
      if w.__kind == "FontString" and w.__parent == cf and w.__text and w.__text ~= "" then
        table.insert(texts, (w.__text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
      end
    end
    print("  " .. label .. ": shown=" .. tostring(cf and cf.__shown) .. " | " .. table.concat(texts, " / "))
  end
  UnitAffectingCombat = function() return true end
  ns.db.shatterOff = false
  SIM_BUFFS = { "Cat Form" }; SIM_CP = 5; dump("cat 5cp, no mark")
  SIM_BUFFS = { "Cat Form", "Clearcasting", "Mark of the Wild" }; dump("clearcasting, no thorns")
  SIM_BUFFS = { "Cat Form", "Mark of the Wild", "Thorns" }; SIM_CP = 3; dump("3cp, no rake")
  issecretvalue = function(v) return v == SIM_SECRET end
  SIM_SECRET = 99; SIM_CP = SIM_SECRET; dump("secret cp")
  issecretvalue = nil; SIM_CP = 0; SIM_BUFFS = {}; dump("caster form")
  UnitAffectingCombat = function() return false end
end
print("--- Yrkestest (PROFTEST) ---")
GetNumSkillLines, GetSkillLineInfo = nil, nil
ns.db.profCache = nil
print("  utan källor:", ns.GetProfSkill("Alchemy"))
for _, w in ipairs(allFrames) do
  if w.__events["CHAT_MSG_SKILL"] and w.__scripts.OnEvent then
    w.__scripts.OnEvent(w, "CHAT_MSG_SKILL", "You have gained the Herbalism skill.")
    w.__scripts.OnEvent(w, "CHAT_MSG_SKILL", "Your skill in Alchemy has increased to 52.")
  end
end
print("  efter chatt: Tailoring", ns.GetProfSkill("Alchemy"), " Enchanting", ns.GetProfSkill("Herbalism"))
function GetProfessions() return 3, 7 end
function GetProfessionInfo(i) if i == 3 then return "Alchemy", "icon", 61, 75 elseif i == 7 then return "Herbalism", "icon", 12, 75 end end
print("  med GetProfessions: Tailoring", ns.GetProfSkill("Alchemy"), " Enchanting", ns.GetProfSkill("Herbalism"))
GetProfessions = nil
function GetTradeSkillLine() return "Alchemy", 64, 75 end
for _, w in ipairs(allFrames) do
  if w.__events["TRADE_SKILL_SHOW"] and w.__scripts.OnEvent then w.__scripts.OnEvent(w, "TRADE_SKILL_SHOW") end
end
print("  efter yrkesfönster: Tailoring", ns.GetProfSkill("Alchemy"))
print("--- Buff-vakt ---")
do
  ns.db.buffsOff = false
  if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
  local shown = {}
  for i = 1, 6 do
    local b = rawget(_G, "DruidPlanBuff" .. i)
    if b and b.__shown then table.insert(shown, tostring(rawget(b, "spell"))) end
  end
  print("visas: " .. table.concat(shown, ", "))
end
print("--- Väskgenomgång ---")
do
  methods.SetAttribute = methods.SetAttribute or function(self, k, v) rawset(self, "__attr_" .. k, v) end
  methods.GetAttribute = methods.GetAttribute or function(self, k) return rawget(self, "__attr_" .. k) end
  items[9990] = { "Broken Fang", 0, 5, "", 25, 15 }
  items[9991] = { "Worn Tunic", 1, 5, "INVTYPE_CHEST", 12, 4, nil, nil, 1 }
  items[6256] = { "Fishing Pole", 1, 5, "INVTYPE_2HWEAPON", 5, 2, nil, nil, 20 }
  items[2901] = { "Mining Pick", 1, 5, "INVTYPE_WEAPON", 20, 2, nil, nil, 0 }
  bag[4] = 9990
  bag[5], bag[6], bag[7] = 9991, 6256, 2901
  local ok, err = pcall(function()
    ns.db.bagAutoOff = nil
    fire("MERCHANT_SHOW")
    local w = rawget(_G, "DruidPlanBags")
    if not (w and w.__shown) then table.insert(errors, "väskgenomgången öppnades inte hos försäljaren") return end
    local junk, sell
    for i = 1, 40 do
      local b = rawget(_G, "DruidPlanBagLine" .. i)
      if b and b.__shown and b.entry and b.entry.key == "junk" then junk = b end
    end
    if not junk then table.insert(errors, "skräpet syntes inte i väskgenomgången")
    elseif junk:GetAttribute("macrotext1") ~= "/use 0 4" then table.insert(errors, "skräpraden säljer inte: " .. tostring(junk:GetAttribute("macrotext1"))) end
    local sa = rawget(_G, "DruidPlanBagSellAll")
    if not (sa and sa.__shown and tostring(sa:GetAttribute("macrotext1")):find("/use 0 4", 1, true)) then table.insert(errors, "sälj-allt-knappen saknas") end
    -- Vit utrustning säljs (men inte fiskespö eller gruvhacka).
    local white, pole, pick
    for i = 1, 40 do
      local b = rawget(_G, "DruidPlanBagLine" .. i)
      if b and b.__shown and b.entry then
        if b.entry.id == 9991 then white = b.entry end
        if b.entry.id == 6256 then pole = true end
        if b.entry.id == 2901 then pick = true end
      end
    end
    if not (white and white.key == "vendor") then table.insert(errors, "vit utrustning hamnade inte bland det som säljs") end
    if pole then table.insert(errors, "fiskespöet erbjöds till försäljning") end
    if pick then table.insert(errors, "gruvhackan erbjöds till försäljning") end
    if junk and junk.__scripts.OnEnter then junk.__scripts.OnEnter(junk) end
    -- Högerklick sparar föremålet: då säljs det inte.
    if junk then junk.__scripts.OnMouseUp(junk, "RightButton") end
    if not (ns.db.bagKeep and ns.db.bagKeep[9990]) then table.insert(errors, "högerklick sparade inte föremålet") end
    if junk and junk:GetAttribute("macrotext1") then table.insert(errors, "sparat föremål kan fortfarande säljas") end
    ns.db.bagKeep = nil
    fire("MERCHANT_CLOSED")
    if w.__shown then table.insert(errors, "väskgenomgången stängdes inte med försäljaren") end
    slash("de")
    if not w.__shown then table.insert(errors, "/de öppnade inte väskgenomgången") end
    for i = 1, 40 do
      local b = rawget(_G, "DruidPlanBagLine" .. i)
      if b and b.__shown and b.entry and (b.entry.key == "junk" or b.entry.key == "vendor") and b:GetAttribute("macrotext1") then
        table.insert(errors, "utan försäljare får en rad inte sälja (då tas den på i stället)")
      end
    end
    fire("PLAYER_REGEN_DISABLED")
    if w.__shown then table.insert(errors, "väskgenomgången stängdes inte inför strid") end
    fire("PLAYER_REGEN_ENABLED")
    slash("de")
    print("  rader: " .. (function() local n = 0; for i = 1, 40 do local b = rawget(_G, "DruidPlanBagLine" .. i); if b and b.__shown then n = n + 1 end end; return n end)())
  end)
  if not ok then table.insert(errors, "väskgenomgång: " .. tostring(err)) end
  bag[4] = nil
  bag[5], bag[6], bag[7] = nil, nil, nil
end
print("--- Buffar med dold auralista ---")
if MODE == "modern" then
  local oldSecret, oldBuffs = issecretvalue, SIM_BUFFS
  local oldByName = C_UnitAuras.GetAuraDataBySpellName
  issecretvalue = function(v) return v == "Secret Aura" end
  SIM_BUFFS = { "Secret Aura", "Thorns" }
  C_UnitAuras.GetAuraDataBySpellName = function(u, n) if n == "Thorns" then return { name = n, expirationTime = 0 } end end
  ns.db.buffsOff = false; ns.db.shatterUnlocked = false; ns.db.buffHide = nil
  ns.RefreshBuffWatch()
  local shown = {}
  for i = 1, 6 do
    local b = rawget(_G, "DruidPlanBuff" .. i)
    if b and b.__shown then table.insert(shown, tostring(rawget(b, "spell"))) end
  end
  print("  visas: " .. table.concat(shown, ", "))
  if not table.concat(shown, ","):find("Mark of the Wild", 1, true) then table.insert(errors, "Mark of the Wild syns inte när auralistan är dold") end
  if table.concat(shown, ","):find("Thorns", 1, true) then table.insert(errors, "Thorns visas fast den finns") end
  slash("buffdebug")
  issecretvalue, SIM_BUFFS, C_UnitAuras.GetAuraDataBySpellName = oldSecret, oldBuffs, oldByName
end
print("--- Högre rank från någon annan ---")
do
  -- Bengan (högre level) har lagt Mark of the Wild rank 6 på mig; jag kan bara rank 2.
  -- Min svagare kan inte ersätta den, så ingen ikon ens när den håller på att ta slut.
  spellRank[9884] = 6
  local oldC, oldU = C_UnitAuras, UnitAura
  local auraId = 9884
  if C_UnitAuras then
    C_UnitAuras = { GetAuraDataByIndex = function(u, i, f)
      if u == "player" and i == 1 then return { name = "Mark of the Wild", spellId = auraId, expirationTime = now + 30, duration = 1800 } end
      if u == "player" and i == 2 then return { name = "Thorns", spellId = 782, expirationTime = 0 } end
    end }
  else
    UnitAura = function(u, i) if u == "player" then
      if i == 1 then return "Mark of the Wild", 0, 0, nil, 1800, now + 30, "party1", false, false, auraId end
      if i == 2 then return "Thorns", 0, 0, nil, 0, 0, "player", false, false, 782 end
    end end
  end
  ns.db.buffsOff = false; ns.db.shatterUnlocked = false; ns.db.buffHide = nil
  local function motwShown()
    ns.RefreshBuffWatch()
    for i = 1, 6 do
      local b = rawget(_G, "DruidPlanBuff" .. i)
      if b and b.__shown and rawget(b, "spell") == "Mark of the Wild" then return true end
    end
    return false
  end
  if motwShown() then table.insert(errors, "högre rank från någon annan: Mark of the Wild visas ändå") end
  slash("buffdebug")
  auraId = 5232 -- min egen rank 2 som tar slut: då ska den visas
  if not motwShown() then table.insert(errors, "egen Mark of the Wild som tar slut visas inte") end
  C_UnitAuras, UnitAura = oldC, oldU
  ns.RefreshBuffWatch()
end
print("--- Okända globaler som lästes ---")
local names = {}
for k in pairs(missingGlobals) do table.insert(names, k) end
table.sort(names); print(table.concat(names, ", "))
print("--- FEL (" .. #errors .. ") ---")
for _, e in ipairs(errors) do print(e) end
