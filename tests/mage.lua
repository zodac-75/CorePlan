-- Minimal WoW API-simulering för att köra MagePlan utanför spelet.
local ADDON_DIR = arg[1]
local MODE = arg[2] or "classic"
if arg[3] then MagePlanGlobal = { lang = arg[3] } end   -- "classic" = gamla API:er, "modern" = C_* API:er

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
  if type(k) == "string" and k:match("^%u") and not k:match("^MagePlan") then return function() return nil end end -- okända metoder gör inget
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
function methods:SetAlpha(a) self.__alpha = a end
function methods:SetAttribute(k, v) self.__attrs = self.__attrs or {}; self.__attrs[k] = v end
function methods:GetAttribute(k) return self.__attrs and self.__attrs[k] end
function methods:GetAlpha() return self.__alpha or 1 end
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
function methods:CreateFontString() return newWidget("FontString") end
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

function UnitClass() return "Mage", "MAGE" end
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
  Frostbolt = { 7322, 4 }, ["Frost Nova"] = { 865, 2 }, Blizzard = { 10, 1 }, ["Ice Lance"] = { 99001, 1 },
  ["Arcane Intellect"] = { 1460, 2 }, ["Frost Armor"] = { 7300, 2 }, ["Conjure Water"] = { 5505, 3 },
  ["Arcane Explosion"] = { 8437, 2 }, ["Fire Blast"] = { 2138, 3 }, Blink = { 1953, 1 },
  Polymorph = { 12824, 2 }, Counterspell = { 2139, 1 },
}
local byId = {}
for n, d in pairs(spells) do byId[d[1]] = n end
byId[116] = "Frostbolt" -- rank 1, ligger på knapp 1
local spellRank = { [116] = 1 }
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
    GetSpellCooldown = function(s) if s == "Ice Lance" then return { startTime = now - 2, duration = 8 } end return { startTime = 0, duration = 0 } end,
  }
  C_Item = {
    GetItemInfo = function(i) return GetItemInfoMock(i) end,
    GetItemCount = function(id) return GetItemCountMock(id) end,
  }
  C_UnitAuras = {
    GetAuraDataByIndex = function(u, i, f)
      local list = (u == "target" and f == "HARMFUL") and { "Frost Nova" } or (u == "player" and f == "HELPFUL") and { "Arcane Intellect" } or {}
      if list[i] then return { name = list[i], spellId = 1 } end
    end,
  }
  BackdropTemplateMixin = {}
  TooltipDataProcessor = { AddTooltipPostCall = function(_, fn) TooltipPostCall = fn end }
  Enum = { TooltipDataType = { Item = 0 } }
else
  function GetSpellInfo(s) local n, id = spellLookup(s); if n then return n, nil, 0, 0, 0, 0, id end end
  function GetSpellCooldown(s) if s == "Ice Lance" then return 0, 0 end return 0, 0 end
  function UnitAura(u, i, f)
    local list = (u == "target" and f == "HARMFUL") and { "Frostbite" } or (u == "player" and f == "HELPFUL") and { "Fingers of Frost" } or {}
    if list[i] then return list[i], 0, 1, nil, 10, now + 5, "player", false, false, 1 end
  end
end
function GetSpellSubtext(id) local r = spellRank[id]; return r and ("Rank " .. r) or "" end

-- Action bars: knapp 1 = Frostbolt rank 1, knapp 2 = Frost Nova, knapp 3 = Blizzard
local actions = { [1] = 116, [2] = 865, [3] = 10, [4] = 1460 }
-- Macros on buttons 5-7: one with an old rank, one without rank, one with conditions.
local macroSlots = { [5] = 1, [6] = 2, [7] = 3 }
local macros = {
  [1] = { "Bolt1", "#showtooltip\n/cast Arcane Explosion(Rank 1)" },
  [2] = { "Blast", "/cast Fire Blast" },
  [3] = { "Sheep", "/cast [@focus,exists,harm] Polymorph; [harm] !Polymorph" },
}
function GetActionInfo(slot)
  local id = actions[slot]; if id then return "spell", id end
  if macroSlots[slot] then return "macro", macroSlots[slot] end
end
function GetMacroInfo(i) local m = macros[i]; if m then return m[1], 134400, m[2] end end

-- Talents
local talents = {
  [3] = {
    { "Improved Frostbolt", 1, 5, 5 }, { "Frostbite", 2, 2, 3 }, { "Ice Shards", 2, 3, 5 },
    { "Ice Lance", 3, 1, 1 }, { "Frost Channeling", 3, 0, 3 }, { "Shatter", 5, 0, 3 },
  },
  [1] = { { "Missile Barrage", 1, 0, 2 } }, [2] = { { "Improved Fire Blast", 1, 0, 3 } },
}
function GetNumTalentTabs() return 3 end
function GetNumTalents(tab) return #talents[tab] end
function GetTalentInfo(tab, i) local t = talents[tab][i]; return t[1], "icon", t[2], 1, t[3], t[4] end

-- Yrken
local skills = { { "Professions", true }, { "Tailoring", false, 87, 150 }, { "Enchanting", false, 140, 150 } }
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
function GetTradeSkillLine() return "Tailoring", 87, 150 end
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
C_EncounterJournal = { GetDungeonEntrancesForMap = function(map)
  if map == 1434 then return { { name = "Zul'Gurub", position = { x = 0.5, y = 0.2 } }, { name = "The Drowned City", position = { x = 0.2, y = 0.3 } } } end
  return {}
end }
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
local toc = io.open(ADDON_DIR .. "/MagePlan.toc"):read("a")
for line in toc:gmatch("[^\r\n]+") do
  if line:match("%.lua$") then
    local f, err = loadfile(ADDON_DIR .. "/" .. line)
    if not f then table.insert(errors, "load " .. line .. ": " .. err)
    else
      local ok, e = pcall(f, "MagePlan", ns)
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
  local ok, err = pcall(SlashCmdList.MAGEPLAN, msg)
  if not ok then table.insert(errors, "/mp " .. msg .. ": " .. tostring(err)) end
end

fire("ADDON_LOADED", "MagePlan")
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

for _, cmd in ipairs({ "help", "craft", "ranks", "de", "all", "lock", "lock", "shatter", "shatter", "move", "move", "tooltip", "tooltip", "minimap", "minimap", "theme", "theme", "theme", "theme", "lang", "lang", "font", "font", "font", "reset", "" , "", "nonsense" }) do
  slash(cmd)
end
now = now + 5; runTimers(now)

-- Fönster: dra hörnet, Ctrl+mushjul
for _, wn in ipairs({ "MagePlanFrame", "MagePlanCraftFrame", "MagePlanShatterFrame" }) do
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
local btn = rawget(_G, "MagePlanMinimapButton")
if btn then
  pcall(btn.__scripts.OnEnter, btn)
  local ok, err = pcall(btn.__scripts.OnClick, btn, "LeftButton"); if not ok then table.insert(errors, "minimap left: " .. err) end
  local qm = rawget(_G, "MagePlanQuickMenu")
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
  local cfg = rawget(_G, "MagePlanConfig")
  if not cfg then table.insert(errors, "inställningsfönstret skapades inte") end
  if cfg and not cfg.__shown then table.insert(errors, "högerklick öppnade inte inställningarna") end
  local before = { lang = MagePlanGlobal.lang, plan = ns.db.plan, theme = ns.db.theme, font = ns.db.fontSize, drink = ns.db.drinkOff }
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
  if MagePlanGlobal.lang ~= before.lang then table.insert(errors, "språket ändrades netto av klicken") end
  if (not ns.db.drinkOff) ~= (not before.drink) then table.insert(errors, "drink-toggle ändrades netto") end
  table.insert(chat, "[sim] klickade " .. clicked .. " knappar i inställningarna")
  ns.db.plan, ns.db.theme, ns.db.fontSize = before.plan, before.theme, before.font
  ns.ApplyPlan()
  ok, err = pcall(SlashCmdList.MAGEPLAN, "config"); if not ok then table.insert(errors, "/mp config: " .. err) end
else
  table.insert(errors, "minimap-knappen skapades inte")
end
now = now + 5; runTimers(now)


-- Dungeon guide
do
  local ok, err = pcall(SlashCmdList.MAGEPLAN, "dungeons dead")
  if not ok then table.insert(errors, "/mp dungeons: " .. err) end
  local dw = rawget(_G, "MagePlanDungeons")
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
  -- Ctrl + wheel resizes the window, also over the scroll areas; a plain wheel doesn't.
  do
    local w = rawget(_G, "MagePlanDungeons")
    local sf = rawget(_G, "MagePlanDungeonScroll")
    local oldCtrl = IsControlKeyDown
    local s0 = w:GetScale()
    IsControlKeyDown = function() return true end
    w.__scripts.OnMouseWheel(w, 1)
    if sf and sf.__scripts.OnMouseWheel then sf.__scripts.OnMouseWheel(sf, 1) end
    local s1 = w:GetScale()
    IsControlKeyDown = function() return false end
    if sf and sf.__scripts.OnMouseWheel then sf.__scripts.OnMouseWheel(sf, 1) end
    print("  dungeonfönster skala: " .. s0 .. " -> " .. s1 .. " -> " .. w:GetScale())
    if math.abs(s1 - (s0 + 0.1)) > 0.001 then table.insert(errors, "Ctrl+scroll ändrar inte dungeonfönstrets storlek") end
    if math.abs(w:GetScale() - s1) > 0.001 then table.insert(errors, "scroll utan Ctrl ändrade storleken") end
    w:SetScale(s0); ns.db.dungeonScale = nil
    IsControlKeyDown = oldCtrl
    -- Quests that start from an item point at the mob that drops it.
    local q = ns.DQUESTS[96391]
    if not (q and q.g and q.g.from == "Dark Iron Spy" and q.g[2] == 1426) then
      table.insert(errors, "Dark Iron Map saknar var den droppar")
    end
    -- Open at logout/reload is remembered, with the dungeon shown.
    w:Show()
    fire("PLAYER_LEAVING_WORLD")
    w:Hide() -- the loading screen may hide it
    fire("PLAYER_ENTERING_WORLD")
    if not w:IsShown() then table.insert(errors, "dungeonfönstret kommer inte tillbaka efter laddningsskärmen") end
    print("  sparat vid reload: open=" .. tostring(ns.db.dungeonOpen) .. " " .. tostring(ns.db.dungeonSel))
    if not ns.db.dungeonOpen or not ns.db.dungeonSel then table.insert(errors, "dungeonfönstret sparas inte som öppet") end
    ns.db.dungeonOpen, ns.db.dungeonSel = nil, nil
  end
  local names = {}
  for _, b in ipairs(listed) do names[b.dungeon.name] = true end
  if names["Ragefire Chasm"] then table.insert(errors, "Alliance ser Ragefire Chasm") end
  if not (names["Hall of Thanes"] and names["City of Dalaran"] and names["Shaper's Terrace"]) then table.insert(errors, "nya dungeons saknas i listan") end
  for _, d in ipairs(ns.DUNGEONS) do
    if d.name == "The Drowned City" and not (d.ent[1] and d.ent[1][1] == 1434 and math.abs(d.ent[1][2] - 20) < 0.01) then
      table.insert(errors, "Drowned City fick ingen ingång från dungeon journal") end
    if d.name == "Alcaz Prison" and #d.ent > 0 then table.insert(errors, "Alcaz Prison fick en påhittad ingång") end
  end
  local hq = 0
  for _, q in pairs(ns.DQUESTS) do if q.races and q.races:find("O", 1, true) then hq = hq + 1 end end
  if hq < 50 then table.insert(errors, "för få Horde-quests: " .. hq) end
  -- Arrow: point, turn, arrive, disappear
  ns.SetWaypoint(1436, 56.33, 47.52, "Gryan Stoutmantle")
  local ar = rawget(_G, "MagePlanArrow")
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
  MagePlanGlobal.dungeonProfile = "Dungeon"
  ns.db.dungeonAutoOpen = true
  local dw = rawget(_G, "MagePlanDungeons"); if dw then dw:Hide() end
  SIM_INST = { "The Deadmines", "party", 36 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
  chk(ns.ActiveProfile() == "Dungeon", "byttes inte till Dungeon i dungeon")
  chk(dw and dw.__shown, "dungeonguiden öppnades inte automatiskt")
  SIM_INST = { "Westfall", "none", 0 }
  fire("ZONE_CHANGED_NEW_AREA"); now = now + 3; runTimers(now)
  chk(ns.ActiveProfile() == "Default", "byttes inte tillbaka efter dungeon, är " .. tostring(ns.ActiveProfile()))
  ns.DeleteProfile("Dungeon")
  chk(#ns.ProfileNames() == 1 and MagePlanGlobal.dungeonProfile == nil, "radera fungerade inte")
  ns.DeleteProfile("Default")
  chk(#ns.ProfileNames() == 1, "sista profilen gick att radera")
  local ok, err = pcall(SlashCmdList.MAGEPLAN, "profile"); chk(ok, tostring(err))
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

-- New emotes, dance party, ding party, talent plan done, and the off switch.
do
  local printed = {}
  local oldPrint = ns.Print
  ns.Print = function(m) table.insert(printed, tostring(m)) end
  ns.debug = true
  for _, e in ipairs({ "TRAIN", "SLEEP", "LAUGH", "SALUTE", "CRY", "FLEX", "PARTY" }) do
    printed = {}
    ns.ShowEmoteEgg(e, "Tester")
    if #printed > 0 then table.insert(errors, "emote " .. e .. ": " .. printed[1]) end
  end
  ns.RunCommand("egg", "ding"); ns.RunCommand("egg", "plan")
  if #printed > 0 then table.insert(errors, "ding/plan: " .. printed[1]) end
  -- Dance party: I danced at Kissy above; Kissy dances back within 10 s.
  local before = #SIM_ADDONMSG
  fire("CHAT_MSG_ADDON", "ZodacPlan", "E:DANCE", "WHISPER", "Kissy")
  local sent = SIM_ADDONMSG[before + 1] or ""
  print("  dansfest skickade: " .. sent)
  if not sent:find("EB:PARTY", 1, true) then table.insert(errors, "dance party: " .. sent) end
  -- The other way round: Kissy dances first, I dance back 20 s later -> my addon starts the party.
  now = now + 6
  fire("CHAT_MSG_ADDON", "ZodacPlan", "E:DANCE", "WHISPER", "Kissy-Realm")
  now = now + 20
  before = #SIM_ADDONMSG
  DoEmote("DANCE", "target")
  sent = table.concat(SIM_ADDONMSG, ", ", before + 1)
  print("  dansfest (dansade tillbaka) skickade: " .. sent)
  if sent ~= "ZodacPlan:EB:PARTY>Kissy" then table.insert(errors, "dansa tillbaka gav ingen fest: " .. sent) end
  -- A friend dings.
  fire("CHAT_MSG_ADDON", "ZodacPlan", "D:30", "PARTY", "Jennie")
  fire("PLAYER_LEVEL_UP", 31)
  -- Off: no effects and no replies.
  ns.RunCommand("eggs")
  before = #SIM_ADDONMSG
  fire("CHAT_MSG_ADDON", "ZodacPlan", "E:HUG", "WHISPER", "Pal-Realm")
  if #SIM_ADDONMSG ~= before then table.insert(errors, "eggs off but still answered") end
  ns.RunCommand("eggs")
  ns.debug = nil
  ns.Print = oldPrint
end

-- PROFSELECT: pick professions in the settings
do
  local saved = ns.db.profs
  ns.db.profCache = ns.db.profCache or {}
  ns.db.profCache.Mining = { rank = 180, max = 225 }
  ns.db.profCache.Skinning = { rank = 140, max = 150 }
  ns.db.profCache.Blacksmithing = { rank = 120, max = 150 }
  ns.db.profs = { "Mining", "Skinning" }
  ns.db.craftShown = true; ns.craftWindow:Show(); ns.RefreshCraft()
  print("--- Yrken: Mining + Skinning ---"); print(ns.craftWindow.text.__text)
  ns.db.profs = { "Blacksmithing", "Leatherworking" }; ns.RefreshCraft()
  print("--- Yrken: Blacksmithing + Leatherworking ---"); print(ns.craftWindow.text.__text)
  local seen = {}
  for i = 1, 11 do ns.StepProf(1, 1); seen[#seen + 1] = ns.ProfLabel(1) end
  print("--- Steg yrke 1: " .. table.concat(seen, " | "))
  ns.db.profs = saved
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
slash("goal 100 mount"); slash("water 8"); slash("goal"); 
now = now + 2; runTimers(now)

-- QUESTSIM: quest, drink, recipes, plans
ns.db.questOff, ns.db.drinkOff = false, false
fire("QUEST_COMPLETE"); now = now + 1; runTimers(now)
local btn2 = QuestInfoRewardsFrame.RewardButtons[2]
do
  local b = {}
  for i, rb in ipairs(QuestInfoRewardsFrame.RewardButtons) do
    local badges = rawget(rb, "MagePlanBadges") or {}
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
local df = rawget(_G, "MagePlanDrinkFrame")
table.insert(chat, "[sim] drink shown at 30%: " .. tostring(df and df.__shown))
do
  local txt = ""
  for _, w in ipairs(allFrames) do
    if w.__kind == "FontString" and type(w.__text) == "string" and (w.__text:find("Drink!", 1, true) or w.__text:find("Drick!", 1, true)) then txt = w.__text end
  end
  table.insert(chat, "[sim] drink alert: " .. txt)
  if not (df and df.__shown and txt:find("INV_Drink", 1, true)) then table.insert(errors, "drink alert not shown with icon: " .. txt) end
end
-- Hidden (secret) mana, as on WoW Forever: the game sets the alert's transparency.
do
  local oldP, oldPP, oldCU, oldCC, oldIS = UnitPower, UnitPowerPercent, C_CurveUtil, CurveConstants, issecretvalue
  local SECRET = {}
  issecretvalue = function(v) return v == SECRET end
  UnitPower = function() return SECRET end
  local made
  C_CurveUtil = { CreateCurve = function()
    made = { pts = {} }
    function made:SetType() end
    function made:AddPoint(x, y) table.insert(self.pts, { x, y }) end
    function made:Eval(x) local y = 0; for _, p in ipairs(self.pts) do if x >= p[1] then y = p[2] end end; return y end
    return made
  end }
  CurveConstants = { ScaleTo100 = { Eval = function(_, x) return x * 100 end } }
  local manaFrac = 0.2
  -- The step curve gives 1/0 (which the game would also keep secret); the % itself is secret.
  UnitPowerPercent = function(_, _, _, c) if c and c.pts then return c:Eval(manaFrac) end return SECRET end
  ns.RefreshRestAlert()
  local s2 = rawget(_G, "MagePlanDrinkFrame2")
  table.insert(chat, "[sim] secret mana 20%: shown=" .. tostring(s2 and s2.__shown) .. " alpha=" .. tostring(s2 and s2.__alpha))
  if not (s2 and s2.__shown) then table.insert(errors, "secret-mana drink alert not shown") end
  manaFrac = 0.9; ns.RefreshRestAlert()
  table.insert(chat, "[sim] secret mana 90%: alpha=" .. tostring(s2 and s2.__alpha))
  UnitPower, UnitPowerPercent, C_CurveUtil, CurveConstants, issecretvalue = oldP, oldPP, oldCU, oldCC, oldIS
  ns.RefreshRestAlert()
end
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
show("MagePlanFrame")
ns.craftWindow:Show(); ns.RefreshCraft()
show("MagePlanCraftFrame")
do
  -- Secondary skills: Cooking 60/75, First Aid 140/150 (rank note), Fishing 200/225.
  ns.db.secShow = nil -- the settings test clicked the tick boxes; back to "auto"
  ns.db.profCache = ns.db.profCache or {}
  ns.db.profCache["Cooking"] = { rank = 60, max = 75 }
  ns.db.profCache["First Aid"] = { rank = 140, max = 150 }
  ns.db.profCache["Fishing"] = { rank = 200, max = 225 }
  ns.RefreshCraft()
  local t = (ns.craftWindow.text.__text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  local sec = t:match("Secondary skills.*") or t:match("Sekundära yrken.*") or ""
  print("--- Sekundära yrken ---\n" .. sec)
  for _, want in ipairs({ "Boiled Clams", "Heavy Wool Bandage", "Deneb Walker", "Dustwallow Marsh" }) do
    if not sec:find(want, 1, true) then table.insert(errors, "secondary skills: missing " .. want) end
  end
  ns.db.profCache["Cooking"], ns.db.profCache["First Aid"], ns.db.profCache["Fishing"] = nil, nil, nil
  -- Ticked Fishing only, not learned: it still shows, with where to learn it.
  ns.db.secShow = { Cooking = false, ["First Aid"] = false, Fishing = true }; ns.RefreshCraft()
  t = (ns.craftWindow.text.__text or ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  if not (t:find("Fishing", 1, true) and (t:find("Learn Fishing", 1, true) or t:find("Lär dig Fishing", 1, true))) or t:find("Cooking", 1, true) then
    table.insert(errors, "secondary pick: " .. t)
  end
  ns.RunCommand("fishing") -- untick
  t = (ns.craftWindow.text.__text or "")
  if t:find("Secondary skills", 1, true) or t:find("Sekundära yrken", 1, true) then table.insert(errors, "all unticked still shows") end
  print("  fishing: " .. tostring(ns.SecondaryShown("Fishing")))
  ns.db.secShow = nil
end
print("--- Shatter-indikator ---")
for _, w in ipairs(allFrames) do
  if w.__kind == "FontString" and w.__text and (w.__text:find("SHATTER") or w.__text:find("Fryst") or w.__text:find("Ice Barrier")) then
    print((w.__text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")))
  end
end
print("--- Yrkestest (PROFTEST) ---")
GetNumSkillLines, GetSkillLineInfo = nil, nil
ns.db.profCache = nil
print("  utan källor:", ns.GetProfSkill("Tailoring"))
for _, w in ipairs(allFrames) do
  if w.__events["CHAT_MSG_SKILL"] and w.__scripts.OnEvent then
    w.__scripts.OnEvent(w, "CHAT_MSG_SKILL", "You have gained the Enchanting skill.")
    w.__scripts.OnEvent(w, "CHAT_MSG_SKILL", "Your skill in Tailoring has increased to 52.")
  end
end
print("  efter chatt: Tailoring", ns.GetProfSkill("Tailoring"), " Enchanting", ns.GetProfSkill("Enchanting"))
function GetProfessions() return 3, 7 end
function GetProfessionInfo(i) if i == 3 then return "Tailoring", "icon", 61, 75 elseif i == 7 then return "Enchanting", "icon", 12, 75 end end
print("  med GetProfessions: Tailoring", ns.GetProfSkill("Tailoring"), " Enchanting", ns.GetProfSkill("Enchanting"))
GetProfessions = nil
function GetTradeSkillLine() return "Tailoring", 64, 75 end
for _, w in ipairs(allFrames) do
  if w.__events["TRADE_SKILL_SHOW"] and w.__scripts.OnEvent then w.__scripts.OnEvent(w, "TRADE_SKILL_SHOW") end
end
print("  efter yrkesfönster: Tailoring", ns.GetProfSkill("Tailoring"))
print("--- Buff-vakt ---")
do
  ns.db.buffsOff = false
  if ns.RefreshBuffWatch then ns.RefreshBuffWatch() end
  local shown = {}
  for i = 1, 6 do
    local b = rawget(_G, "MagePlanBuff" .. i)
    if b and b.__shown then table.insert(shown, tostring(rawget(b, "spell"))) end
  end
  print("visas: " .. table.concat(shown, ", "))
end
do
  -- Out of combat: Frost Armor with 2.5 minutes left gets the rebuff heads-up.
  local oldC = C_UnitAuras
  local t0 = GetTime()
  C_UnitAuras = { GetAuraDataByIndex = function(_, i)
    if i == 1 then return { name = "Arcane Intellect", expirationTime = t0 + 1500, duration = 1800 } end
    if i == 2 then return { name = "Frost Armor", expirationTime = t0 + 150, duration = 1800 } end
  end }
  ns.db.rebuffMin = 3
  ns.RefreshBuffWatch()
  local h = rawget(_G, "MagePlanBuffWatch")
  local msg = h and h.msg and h.msg:GetText() or "nil"
  print("rebuff-text: " .. tostring(msg))
  if not tostring(msg):find("Frost Armor") then table.insert(errors, "rebuff reminder missing: " .. tostring(msg)) end
  ns.db.rebuffMin = 0
  ns.RefreshBuffWatch()
  msg = h and h.msg and h.msg:GetText() or "nil"
  print("rebuff av: [" .. tostring(msg) .. "]")
  if tostring(msg):find("Frost Armor") then table.insert(errors, "rebuff reminder shown while off") end
  C_UnitAuras = oldC
end
print("--- Välj buffar ---")
do
  local t = ns.BuffWatchToggles()
  local labels = {}
  for _, x in ipairs(t) do table.insert(labels, x.text()) end
  print("  rutor: " .. table.concat(labels, ", "))
  -- Hide Arcane Intellect: with no buffs on, only the armor icon shows.
  local oldC, oldU = C_UnitAuras, UnitAura
  if C_UnitAuras then C_UnitAuras = { GetAuraDataByIndex = function() end } else UnitAura = function() end end
  ns.db.buffsOff = false; ns.db.shatterUnlocked = false
  t[1].toggle(); ns.RefreshBuffWatch()
  local shown = {}
  for i = 1, 8 do local b = rawget(_G, "MagePlanBuff" .. i); if b and b.__shown then table.insert(shown, tostring(rawget(b, "spell"))) end end
  print("  visas med AI avbockad: " .. table.concat(shown, ", "))
  if table.concat(shown, ","):find("Arcane Intellect", 1, true) then table.insert(errors, "hidden buff still shown") end
  t[1].toggle(); ns.RefreshBuffWatch()
  C_UnitAuras, UnitAura = oldC, oldU
end
print("--- Gruppbuffar ---")
do
  local oldIG, oldUE, oldC, oldU = IsInGroup, UnitExists, C_UnitAuras, UnitAura
  IsInGroup = function() return true end
  UnitExists = function(u) return u == "target" or u == "player" or u == "party1" or u == "party2" end
  UnitIsConnected = function() return true end
  UnitPowerType = function(u) if u == "party2" then return 1 end return 0 end -- party2 = warrior (rage)
  UnitName = function(u) if u == "party1" then return "Jennie" elseif u == "party2" then return "Tank" end return "Me" end
  UnitInRange = function() return true, true end
  -- I have my buffs, Jennie and the warrior have nothing.
  if C_UnitAuras then
    C_UnitAuras = { GetAuraDataByIndex = function(u, i)
      if u == "player" and i == 1 then return { name = "Arcane Intellect", expirationTime = 0 } end
      if u == "player" and i == 2 then return { name = "Frost Armor", expirationTime = 0 } end
    end }
  else
    UnitAura = function(u, i) if u == "player" then
      if i == 1 then return "Arcane Intellect", 0, 0, nil, 0, 0 end
      if i == 2 then return "Frost Armor", 0, 0, nil, 0, 0 end
    end end
  end
  ns.db.buffsOff = false; ns.db.shatterUnlocked = false
  ns.RefreshBuffWatch()
  local shown = {}
  for i = 1, 8 do
    local b = rawget(_G, "MagePlanBuff" .. i)
    if b and b.__shown then table.insert(shown, tostring(rawget(b, "spell")) .. ">" .. tostring(rawget(b, "whoName"))) end
  end
  print("  visas: " .. table.concat(shown, ", "))
  local all = table.concat(shown, ",")
  if not all:find("Jennie", 1, true) then table.insert(errors, "party buff: Jennie missing: " .. all) end
  if all:find("Tank", 1, true) then table.insert(errors, "party buff: Arcane Intellect offered to a rage user") end
  -- Jennie's button: an explicit-target /cast, never a plain spell on "party1".
  local jb
  for i = 1, 8 do local b = rawget(_G, "MagePlanBuff" .. i); if b and b.__shown and rawget(b, "whoName") == "Jennie" then jb = b end end
  local attrs = jb and jb.__attrs or {}
  print("  Jennie: type1=" .. tostring(attrs.type1) .. " macro=" .. tostring(attrs.macrotext1))
  if attrs.type1 ~= "macro" or not tostring(attrs.macrotext1):find("@party1", 1, true) then table.insert(errors, "party buff should cast with an explicit target") end
  -- Out of spell range or in another zone: no icon for them at all.
  local function jennieShown()
    for i = 1, 8 do local b = rawget(_G, "MagePlanBuff" .. i); if b and b.__shown and rawget(b, "whoName") == "Jennie" then return true end end
    return false
  end
  -- Out of range and back: no second alert sound.
  local sounds, oldPlay, oldSound = 0, ns.PlayAlertSound, ns.db.alertSound
  ns.PlayAlertSound = function() sounds = sounds + 1 end
  ns.db.alertSound = "test"
  ns.RefreshBuffWatch()
  local before = sounds
  IsSpellInRange = function() return 0 end
  ns.RefreshBuffWatch()
  IsSpellInRange = nil
  ns.RefreshBuffWatch()
  print("  ljud vid tillbaka i räckhåll: " .. (sounds - before))
  if sounds ~= before then table.insert(errors, "varningsljudet spelades igen när spelaren kom tillbaka i räckhåll") end
  ns.PlayAlertSound, ns.db.alertSound = oldPlay, oldSound
  IsSpellInRange = function() return 0 end
  ns.RefreshBuffWatch()
  print("  utom räckhåll: visas=" .. tostring(jennieShown()))
  if jennieShown() then table.insert(errors, "out of range but still shown") end
  IsSpellInRange = nil
  ns.RefreshBuffWatch()
  if not jennieShown() then table.insert(errors, "back in range but not shown") end
  UnitIsVisible = function(u) return u ~= "party1" end
  ns.RefreshBuffWatch()
  if jennieShown() then table.insert(errors, "in another zone but still shown") end
  UnitIsVisible = nil
  ns.RefreshBuffWatch()
  -- Boss fight: the game hides their buffs (empty list). That's "can't tell", not "missing".
  IsEncounterInProgress = function() return true end
  ns.RefreshBuffWatch()
  if jennieShown() then table.insert(errors, "boss fight: hidden party buffs counted as missing") end
  IsEncounterInProgress = nil
  ns.RefreshBuffWatch()
  if not jennieShown() then table.insert(errors, "after the boss: Jennie's missing buff not shown again") end
  -- Same without IsEncounterInProgress: the ENCOUNTER_START/END events.
  fire("ENCOUNTER_START", 1, "Boss", 1, 5)
  ns.RefreshBuffWatch()
  if jennieShown() then table.insert(errors, "ENCOUNTER_START: hidden party buffs counted as missing") end
  slash("buffdebug")
  fire("ENCOUNTER_END", 1, "Boss", 1, 5, 1)
  ns.RefreshBuffWatch()
  if not jennieShown() then table.insert(errors, "ENCOUNTER_END: Jennie's missing buff not shown again") end
  ns.RunCommand("partybuffs"); ns.RefreshBuffWatch()
  local after = 0
  for i = 1, 8 do local b = rawget(_G, "MagePlanBuff" .. i); if b and b.__shown then after = after + 1 end end
  print("  avstängt: " .. after .. " ikoner")
  if after ~= 0 then table.insert(errors, "party buffs still shown when off") end
  ns.RunCommand("partybuffs")
  IsInGroup, UnitExists, C_UnitAuras, UnitAura = oldIG, oldUE, oldC, oldU
  ns.RefreshBuffWatch()
end
print("--- Gruppmarkeringar ---")
do
  local oldIG, oldUE = IsInGroup, UnitExists
  IsInGroup = function() return true end
  IsInRaid = function() return false end
  UnitExists = function(u) return u == "player" or u == "party1" or u == "party2" end
  UnitName = function(u) if u == "party1" then return "Jennie" elseif u == "party2" then return "Tank" end return "Me" end
  local marks, calls = {}, {}
  GetRaidTargetIndex = function(u) return marks[u] end
  SetRaidTarget = function(u, i)
    table.insert(calls, u .. "=" .. i)
    if marks[u] == i then marks[u] = nil else marks[u] = (i ~= 0) and i or nil end
  end
  ns.db.marks = {}
  local sel = ns.MARK_SELECTORS
  if not sel or #sel ~= 5 then table.insert(errors, "fem markeringar saknas i menyn") else
    sel[1].step(1)                 -- Star: Off -> Me
    sel[2].step(1)                 -- Circle: Off -> party slot 2 (Me has Star)
    sel[5].step(-1); sel[5].step(-1); sel[5].step(-1) -- Moon: Off -> slot 5 -> 4 -> 3
    print("  " .. sel[1].value() .. " / " .. sel[2].value() .. " / " .. sel[5].value())
    if sel[2].value() ~= ns.T("MK_SLOT", 2) or sel[5].value() ~= ns.T("MK_SLOT", 3) then
      table.insert(errors, "markeringar ska följa gruppplatser: " .. sel[2].value() .. " / " .. sel[5].value())
    end
    -- The addon may never set marks itself (protected): only the macro on a click.
    if #calls > 0 then table.insert(errors, "addon anropade SetRaidTarget: " .. table.concat(calls, " ")) end
    local m = ns.PartyMarkMacro()
    print("  makro: " .. m:gsub("\n", " | "))
    if m ~= "/tm [@player] 1\n/tm [@party1] 2\n/tm [@party2] 5" then table.insert(errors, "fel markeringsmakro") end
    -- Its own button, shown in a party, with the macro on a click; nothing in the buff row.
    local mb = rawget(_G, "MagePlanMarkButton")
    ns.UpdateMarkButton()
    if not mb or not mb.__shown then table.insert(errors, "markeringsknappen syns inte i grupp")
    elseif mb.__attrs.type1 ~= "macro" or mb.__attrs.macrotext1 ~= m then table.insert(errors, "markeringsknappen har fel makro: " .. tostring(mb.__attrs.macrotext1)) end
    if mb then pcall(mb.__scripts.OnEnter, mb) end
    ns.RefreshBuffWatch()
    for k = 1, 8 do
      local b = rawget(_G, "MagePlanBuff" .. k)
      if b and b.__shown and b.__attrs and tostring(b.__attrs.macrotext1):find("/tm", 1, true) then table.insert(errors, "markeringar ligger kvar i buffraden") end
    end
    -- The toggle hides the button.
    ns.db.marksOff = true
    ns.UpdateMarkButton()
    if mb and mb.__shown then table.insert(errors, "markeringsknappen syns trots att den är avslagen") end
    ns.db.marksOff = nil
    -- Marks already on: the button stays, with only the missing one in its macro.
    marks.player, marks.party1, marks.party2 = 1, 2, 5
    if ns.PartyMarkMacro() ~= "" then table.insert(errors, "makro trots att alla har sin markering") end
    marks.party1 = nil
    if ns.PartyMarkMacro() ~= "/tm [@party1] 2" then table.insert(errors, "bara den saknade markeringen ska med: " .. ns.PartyMarkMacro()) end
    ns.UpdateMarkButton()
    if not (mb and mb.__shown) then table.insert(errors, "markeringsknappen försvann") end
    -- Going into combat loads "clear and set all", so one click brings every mark back.
    fire("PLAYER_REGEN_DISABLED")
    local cm = mb and mb.__attrs.macrotext1 or ""
    print("  i strid: " .. cm:gsub("\n", " | "))
    if cm ~= "/tm [@player] 0\n/tm [@player] 1\n/tm [@party1] 0\n/tm [@party1] 2\n/tm [@party2] 0\n/tm [@party2] 5" then table.insert(errors, "fel stridsmakro") end
    if #cm > 255 then table.insert(errors, "stridsmakrot är för långt") end
    -- In combat nothing on the button changes.
    InCombatLockdown = function() return true end
    ns.db.marksOff = true; ns.UpdateMarkButton(); ns.db.marksOff = nil
    if not mb.__shown or mb.__attrs.macrotext1 ~= cm then table.insert(errors, "knappen ändrades i strid") end
    InCombatLockdown = function() return false end
    fire("PLAYER_REGEN_ENABLED")
    if #calls > 0 then table.insert(errors, "addon anropade SetRaidTarget: " .. table.concat(calls, " ")) end
    sel[3].step(1)                  -- Diamond: skips taken ones (me, slot 2, slot 3) -> slot 4
    if sel[3].value() ~= ns.T("MK_SLOT", 4) then table.insert(errors, "en spelare fick två markeringar: " .. sel[3].value()) end
    for k = 1, 5 do while sel[k].value() ~= ns.T("CFG_OFF") do sel[k].step(1) end end
    if mb and mb.__shown then table.insert(errors, "knappen syns utan valda markeringar") end
    -- The icons in the settings window: click, right-click, scroll, tooltip.
    local cells = {}
    for _, w in ipairs(allFrames) do if w.item and w.name and tostring(w.item.key):find("^MK_") then cells[#cells + 1] = w end end
    if #cells ~= 5 then table.insert(errors, "settings: " .. #cells .. " markeringsikoner, inte 5") else
      local c = cells[2]
      for _, f in ipairs({ function() c.__scripts.OnClick(c, "LeftButton") end, function() c.__scripts.OnClick(c, "RightButton") end,
        function() c.__scripts.OnMouseWheel(c, -1) end, function() c.__scripts.OnEnter(c) end }) do
        local ok, err = pcall(f); if not ok then table.insert(errors, "markeringsikon: " .. err) end
      end
      print("  ikon Circle: " .. tostring(c.name.__text))
      -- Off -> click: me -> right-click: off -> scroll down: me
      if not tostring(c.name.__text):find(ns.T("MK_ME"), 1, true) then table.insert(errors, "scroll gav fel spelare: " .. tostring(c.name.__text)) end
      c.__scripts.OnClick(c, "RightButton")
    end
  end
  IsInGroup, UnitExists, IsInRaid, SetRaidTarget, GetRaidTargetIndex = oldIG, oldUE, nil, nil, nil
  ns.db.marks = nil
end
print("--- Importera Wowhead-länk ---")
do
  local link = "https://www.wowhead.com/forever/talent-calc/mage/vkndmh05002322302-25500001-0530300031211_t0/2BCEJknM1aaB0BEfffJHMG1Ch2p"
  local ok = ns.ImportTalents(link)
  local n = 0
  for _ in pairs(ns.talents) do n = n + 1 end
  print("  import: " .. tostring(ok) .. ", " .. n .. " poäng, som " .. ns.PlanKey() .. ", 10 = " .. tostring(ns.talents[10]) .. ", 60 = " .. tostring(ns.talents[60]))
  if not ok or n ~= 51 then table.insert(errors, "Wowhead-importen gav " .. n .. " poäng, inte 51") end
  local want = { ["Improved Channeling"] = "5/5", ["Shatter"] = "1/3", ["Pyroblast"] = "1/1", ["Arcane Concentration"] = "3/5" }
  local final = {}
  for _, e in pairs(ns.talents) do local name, r = e:match("^(.-)%s+(%d+/%d+)$"); final[name] = r end
  for name, r in pairs(want) do
    -- final rank is the highest seen
    local best = 0
    for _, e in pairs(ns.talents) do local nm, k = e:match("^(.-)%s+(%d+)/%d+$"); if nm == name and tonumber(k) > best then best = tonumber(k) end end
    if tostring(best) .. "/" .. r:match("/(%d+)") ~= r then table.insert(errors, "Wowhead: " .. name .. " blev " .. best .. ", inte " .. r) end
  end
  if ns.talents[10] ~= "Improved Channeling 1/5" then table.insert(errors, "Wowhead: huvudträdet (Arcane) ska komma först: " .. tostring(ns.talents[10])) end
  if ns.ImportTalents("https://www.wowhead.com/forever/talent-calc/priest/0550-55") then table.insert(errors, "tog emot en priest-länk") end
  ns.ClearImport()
end
print("--- Walk on Air ---")
do
  local oldC, oldU = C_UnitAuras, UnitAura
  local t0 = GetTime()
  if C_UnitAuras then
    C_UnitAuras = { GetAuraDataByIndex = function(_, i)
      if i == 1 then return { name = "Walk on Air", expirationTime = t0 + 2, duration = 10 } end
    end }
  else
    UnitAura = function(_, i) if i == 1 then return "Walk on Air", 0, 0, nil, 10, t0 + 2 end end
  end
  local gf = rawget(_G, "MagePlanGlideFrame")
  for _, w in ipairs(allFrames) do
    if w.__scripts and w.__scripts.OnUpdate and w.__events and w.__events["UNIT_SPELLCAST_SUCCEEDED"] then w.__scripts.OnUpdate(w, 1) end
  end
  local text = ""
  for _, w in ipairs(allFrames) do
    if w.__kind == "FontString" and type(w.__text) == "string" and w.__text:find("LAND") then text = w.__text end
  end
  print("  glide: shown=" .. tostring(gf and gf.__shown) .. " " .. text)
  if not (gf and gf.__shown and text:find("LAND")) then table.insert(errors, "Walk on Air timer: " .. text) end
  C_UnitAuras, UnitAura = oldC, oldU
  for _, w in ipairs(allFrames) do
    if w.__scripts and w.__scripts.OnUpdate and w.__events and w.__events["UNIT_SPELLCAST_SUCCEEDED"] then w.__scripts.OnUpdate(w, 1) end
  end
  print("  efter: shown=" .. tostring(gf and gf.__shown))
end
print("--- Rank-koll utan rank-text (Forever) ---")
do
  local oldSub = GetSpellSubtext
  GetSpellSubtext = function() return "" end
  local levels = { [116] = 4, [7322] = 26 }
  GetSpellLevelLearned = function(id) return levels[id] or 0 end
  local printed = {}
  local oldPrint = ns.Print
  ns.Print = function(m) table.insert(printed, m) end
  ns.RunCommand("ranks", "")
  ns.Print = oldPrint
  local all = table.concat(printed, " | ")
  print("  " .. all)
  if not all:find("Frostbolt") or not all:find("older rank") and not all:find("äldre rank") then
    table.insert(errors, "old rank not found without rank text: " .. all)
  end
  GetSpellSubtext, GetSpellLevelLearned = oldSub, nil
end
print("--- Rank-koll med handkontroll (spells bundna direkt) ---")
do
  local printed = {}
  local oldPrint = ns.Print
  ns.Print = function(m) table.insert(printed, tostring(m)) end
  GetBindingKey = function(cmd) if cmd:find("^SPELL ") then return "PADRSHOULDER" end end
  ns.RunCommand("ranks", "")
  local all = table.concat(printed, " | ")
  print("  " .. all)
  if all:find("isn't on any button", 1, true) or all:find("inte ligger på någon knapp", 1, true) then
    table.insert(errors, "bundna spells räknas som saknade: " .. all)
  end
  GetBindingKey = nil
  -- WoW Forever's controller sets: spells the game finds on a button outside slots 1-180,
  -- or that only C_ActionBar knows about, are not missing either.
  local oldAB = rawget(_G, "C_ActionBar")
  C_ActionBar = {
    FindSpellActionButtons = function(id) return { 250 } end,
    IsOnBarOrSpecialBar = function() return true end,
  }
  printed = {}
  ns.RunCommand("ranks", "")
  all = table.concat(printed, " | ")
  print("  kontroller (C_ActionBar): " .. all)
  if all:find("isn't on any button", 1, true) or all:find("inte ligger på någon knapp", 1, true) then
    table.insert(errors, "spells på kontrollerns knappar räknas som saknade: " .. all)
  end
  C_ActionBar = { FindSpellActionButtons = function() return {} end, IsOnBarOrSpecialBar = function() return true end }
  printed = {}
  ns.RunCommand("ranks", "")
  all = table.concat(printed, " | ")
  if all:find("isn't on any button", 1, true) or all:find("inte ligger på någon knapp", 1, true) then
    table.insert(errors, "IsOnBarOrSpecialBar räknas inte: " .. all)
  end
  printed = {}
  ns.RunCommand("ranks", "debug")
  print("  debug: " .. table.concat(printed, " | "):sub(1, 200))
  C_ActionBar = oldAB
  printed = {}
  ns.RunCommand("rankchat", "")
  if not ns.db.rankChatOff then table.insert(errors, "rankchat stängde inte av") end
  fire("ACTIONBAR_SLOT_CHANGED")
  ns.RunCommand("rankchat", "")
  ns.Print = oldPrint
  print("  " .. table.concat(printed, " | "))
end
print("--- Väskgenomgång ---")
do
  methods.SetAttribute = methods.SetAttribute or function(self, k, v) rawset(self, "__attr_" .. k, v) end
  methods.GetAttribute = methods.GetAttribute or function(self, k) return rawget(self, "__attr_" .. k) end
  items[9990] = { "Broken Fang", 0, 5, "", 25, 15 }
  bag[4] = 9990
  local ok, err = pcall(function()
    ns.db.bagAutoOff = nil
    fire("MERCHANT_SHOW")
    local w = rawget(_G, "MagePlanBags")
    if not (w and w.__shown) then table.insert(errors, "väskgenomgången öppnades inte hos försäljaren") return end
    local junk, sell
    for i = 1, 40 do
      local b = rawget(_G, "MagePlanBagLine" .. i)
      if b and b.__shown and b.entry and b.entry.key == "junk" then junk = b end
    end
    if not junk then table.insert(errors, "skräpet syntes inte i väskgenomgången")
    elseif junk:GetAttribute("macrotext1") ~= "/use 0 4" then table.insert(errors, "skräpraden säljer inte: " .. tostring(junk:GetAttribute("macrotext1"))) end
    local sa = rawget(_G, "MagePlanBagSellAll")
    if not (sa and sa.__shown and tostring(sa:GetAttribute("macrotext1")):find("/use 0 4", 1, true)) then table.insert(errors, "sälj-allt-knappen saknas") end
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
      local b = rawget(_G, "MagePlanBagLine" .. i)
      if b and b.__shown and b.entry and (b.entry.key == "junk" or b.entry.key == "vendor") and b:GetAttribute("macrotext1") then
        table.insert(errors, "utan försäljare får en rad inte sälja (då tas den på i stället)")
      end
    end
    fire("PLAYER_REGEN_DISABLED")
    if w.__shown then table.insert(errors, "väskgenomgången stängdes inte inför strid") end
    fire("PLAYER_REGEN_ENABLED")
    slash("de")
    print("  rader: " .. (function() local n = 0; for i = 1, 40 do local b = rawget(_G, "MagePlanBagLine" .. i); if b and b.__shown then n = n + 1 end end; return n end)())
  end)
  if not ok then table.insert(errors, "väskgenomgång: " .. tostring(err)) end
  bag[4] = nil
end
do
  if not ns.HasGlide() then table.insert(errors, "Skyborne borde ha Walk on Air") end
  local oldRace = UnitRace
  UnitRace = function() return "Human", "Human", 1 end
  if ns.HasGlide() then table.insert(errors, "Human ska inte ha Walk on Air") end
  UnitRace = function() return "Windshaper", "SkyborneHorde", 31 end
  if not ns.HasGlide() then table.insert(errors, "Windshaper borde ha Walk on Air") end
  UnitRace = oldRace
end
do
  local mm
  for _, w in ipairs(allFrames) do if w.__scripts.OnClick and rawget(w, "__name") and tostring(w.__name):find("Minimap") then mm = w end end
  local bw = rawget(_G, "MagePlanBags")
  if bw then bw:Hide() end
  if mm then
    mm.__scripts.OnClick(mm, "MiddleButton")
    if not (bw and bw.__shown) then table.insert(errors, "mittenklick öppnade inte väskgenomgången") end
  else table.insert(errors, "hittade inte minimapknappen") end
  slash("bagbutton"); slash("bagbutton")
end
do
  local t = ns.PROF_TRAINERS.Tailoring[125]
  if ns.Tx(t) ~= "Georgio Bolero (Stormwind)" then table.insert(errors, "Alliance fick fel tränare: " .. tostring(ns.Tx(t))) end
  local old = UnitFactionGroup
  UnitFactionGroup = function() return "Horde", "Horde" end
  if ns.Tx(t) ~= "Josef Gregorian (Undercity)" then table.insert(errors, "Horde fick fel tränare: " .. tostring(ns.Tx(t))) end
  if ns.Tx(ns.HERB_ZONES[1].zones):find("Elwynn", 1, true) then table.insert(errors, "Horde fick Alliance-zoner") end
  if ns.Tx(ns.ROUTES.Enchanting[7].note):find("Kithas", 1, true) == nil then table.insert(errors, "Horde fick fel formel-försäljare") end
  UnitFactionGroup = old
  for prof, r in pairs(ns.ROUTES) do
    for _, st in ipairs(r) do
      for _, m in ipairs(st.mats) do if not m[1] or m[1] == 0 then table.insert(errors, "saknat item-ID: " .. prof .. " " .. tostring(m[3])) end end
    end
  end
  print("  tränare A/H och item-ID:n kollade")
end
print("--- Enchanter: disenchanta allt ---")
do
  -- Gröna stövlar som säljer för mer än de ger i material: en enchanter ska ändå få DE.
  items[9992] = { "Green Boots", 2, 10, "INVTYPE_FEET", 50000, 4, nil, 0, 2 }
  local oldSkill = ns.GetProfSkill
  ns.GetProfSkill = function(p) if p == "Enchanting" then return 150 end return oldSkill(p) end
  local r = ns.Evaluate("|Hitem:9992|h[Green Boots]|h", false)
  print("  enchanter: " .. tostring(r and r.best.key))
  if not (r and r.best.key == "de") then table.insert(errors, "enchanter fick inte DE på grön utrustning: " .. tostring(r and r.best.key)) end
  ns.GetProfSkill = function(p) if p == "Enchanting" then return nil end return oldSkill(p) end
  r = ns.Evaluate("|Hitem:9992|h[Green Boots]|h", false)
  print("  utan enchanting: " .. tostring(r and r.best.key))
  if r and r.best.key == "de" then table.insert(errors, "DE föreslogs utan Enchanting") end
  ns.GetProfSkill = oldSkill
end
print("--- Okända globaler som lästes ---")
local names = {}
for k in pairs(missingGlobals) do table.insert(names, k) end
table.sort(names); print(table.concat(names, ", "))
print("--- FEL (" .. #errors .. ") ---")
for _, e in ipairs(errors) do print(e) end
