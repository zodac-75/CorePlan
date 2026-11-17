-- @ADDON@: gear upgrade check. Adds a tooltip line comparing an item with what you
-- have equipped, scored with the class's leveling stat weights (ns.STATS in Data.lua).
local _, ns = ...

-- First matching pattern wins per tooltip line, so specific ones come first.
local PATTERNS = ns.STATS.patterns

local SLOTS = {
  INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 }, INVTYPE_CLOAK = { 15 },
  INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 }, INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 },
  INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 },
  INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 },
  INVTYPE_WEAPON = { 16 }, INVTYPE_WEAPONMAINHAND = { 16 }, INVTYPE_2HWEAPON = { 16 },
  INVTYPE_HOLDABLE = { 17 }, INVTYPE_WEAPONOFFHAND = { 17 }, INVTYPE_SHIELD = { 17 },
  INVTYPE_RANGED = { 18 }, INVTYPE_RANGEDRIGHT = { 18 }, INVTYPE_THROWN = { 18 },
}

local USABLE_ARMOR = ns.STATS.armor
local USABLE_WEAPON = ns.STATS.weapon

-- Armor types learned later (ns.STATS.armorFrom = { [subclass] = level }), e.g. plate at 40.
-- If the skill list shows the armor skill you know it; otherwise we go by your level
-- (a collapsed header in the skill list hides its lines, so "not listed" proves nothing).
local ARMOR_SKILL = { [3] = "Mail", [4] = "Plate Mail" }

local function KnowsSkill(name)
  if type(GetNumSkillLines) ~= "function" or type(GetSkillLineInfo) ~= "function" then return false end
  local ok, n = pcall(GetNumSkillLines)
  if not ok or type(n) ~= "number" then return false end
  for i = 1, n do
    local okLine, skillName, isHeader = pcall(GetSkillLineInfo, i)
    if okLine and not isHeader and (skillName == name or (ns.Loc and skillName == ns.Loc(name))) then return true end
  end
  return false
end

-- Level you can wear this armor type from, or nil when you already can.
local function WearLevel(classID, subclassID)
  local from = classID == 4 and ns.STATS.armorFrom and ns.STATS.armorFrom[subclassID]
  if not from or (UnitLevel("player") or 1) >= from then return nil end
  if ARMOR_SKILL[subclassID] and KnowsSkill(ARMOR_SKILL[subclassID]) then return nil end
  return from
end

local function IsWeapon(link)
  if not link then return false end
  local ok, _, _, _, _, _, _, _, _, _, _, _, classID = pcall(ns.ItemInfo, link)
  return ok and classID == 2
end

local scanTip
local cache = {}

local function TooltipLines(link)
  local out = {}
  if C_TooltipInfo and C_TooltipInfo.GetHyperlink then
    local ok, data = pcall(C_TooltipInfo.GetHyperlink, link)
    if ok and type(data) == "table" and data.lines then
      for _, l in ipairs(data.lines) do
        if type(l.leftText) == "string" then table.insert(out, l.leftText) end
      end
      return out
    end
  end
  if not scanTip then
    scanTip = CreateFrame("GameTooltip", "@ADDON@ScanTooltip", UIParent, "GameTooltipTemplate")
  end
  scanTip:SetOwner(UIParent, "ANCHOR_NONE")
  scanTip:ClearLines()
  scanTip:SetHyperlink(link)
  for i = 1, (scanTip:NumLines() or 0) do
    local fs = _G["@ADDON@ScanTooltipTextLeft" .. i]
    local t = fs and fs:GetText()
    if type(t) == "string" then table.insert(out, t) end
  end
  scanTip:Hide()
  return out
end

-- Other client languages: the game's own stat list (C_Item.GetItemStats), whose keys don't depend
-- on the language. It has the Equip: effects too ("healing 9 and damage 3" comes as two keys) and
-- leaves out Use:, procs and set bonuses. Keys we don't know are left out.
local STAT_KEYS = {
  ITEM_MOD_STRENGTH_SHORT = "str", ITEM_MOD_AGILITY_SHORT = "agi", ITEM_MOD_STAMINA_SHORT = "sta",
  ITEM_MOD_INTELLECT_SHORT = "int", ITEM_MOD_SPIRIT_SHORT = "spi",
  ITEM_MOD_ATTACK_POWER_SHORT = "ap", ITEM_MOD_RANGED_ATTACK_POWER_SHORT = "rap",
  ITEM_MOD_SPELL_DAMAGE_DONE_SHORT = "dmgsp", ITEM_MOD_SPELL_HEALING_DONE_SHORT = "heal",
  ITEM_MOD_SPELL_POWER_SHORT = "sp",
  ITEM_MOD_MANA_REGENERATION_SHORT = "mp5", ITEM_MOD_POWER_REGEN0_SHORT = "mp5",
  ITEM_MOD_HIT_RATING_SHORT = "hit", ITEM_MOD_CRIT_RATING_SHORT = "crit",
  ITEM_MOD_HIT_MELEE_RATING_SHORT = "hit", ITEM_MOD_CRIT_MELEE_RATING_SHORT = "crit",
  ITEM_MOD_HIT_SPELL_RATING_SHORT = "shit", ITEM_MOD_CRIT_SPELL_RATING_SHORT = "scrit",
  ITEM_MOD_DEFENSE_SKILL_RATING_SHORT = "def", ITEM_MOD_DODGE_RATING_SHORT = "dodge",
  ITEM_MOD_PARRY_RATING_SHORT = "parry", ITEM_MOD_BLOCK_RATING_SHORT = "block",
  ITEM_MOD_BLOCK_VALUE_SHORT = "blockv", ITEM_MOD_DAMAGE_PER_SECOND_SHORT = "wdps",
  RESISTANCE0_NAME = "armor",
}
ns.STAT_KEYS = STAT_KEYS

local function GameStats(link)
  local get = C_Item and C_Item.GetItemStats or GetItemStats
  if not get then return nil end
  local ok, t = pcall(get, link)
  if not ok or type(t) ~= "table" then return nil end
  local s = {}
  for key, v in pairs(t) do
    local k = STAT_KEYS[key]
    if k and type(v) == "number" then s[k] = (s[k] or 0) + v end
  end
  return s
end

local function Stats(link)
  if cache[link] then return cache[link] end
  if not ns.IsEnglishClient() then
    local s = GameStats(link)
    if s then cache[link] = s; return s end
    return {}
  end
  local lines = TooltipLines(link)
  if #lines == 0 then return {} end
  local s = {}
  for _, line in ipairs(lines) do
    local heal, dmg = line:match("healing done by up to (%d+) and damage done by up to (%d+) for all magical spells")
    if heal then
      -- "Increases healing done by up to 9 and damage done by up to 3 for all magical spells and
      -- effects": two separate numbers on one line. A healer cares about the first, the rest of
      -- the casters about the second.
      s.heal = (s.heal or 0) + tonumber(heal)
      s.dmgsp = (s.dmgsp or 0) + tonumber(dmg)
    elseif line:find("Set:") or line:find("^Use:") or line:find("^Chance on hit:")
        or line:find("when fighting") or line:find("done to ") then
      -- set bonuses only count with the full set; Use:/proc lines are temporary; "when fighting
      -- Undead" and "damage done to Undead" only apply against some mobs: none of them are stats
    else
      for _, p in ipairs(PATTERNS) do
        local v = line:match(p[1])
        if v then
          s[p[2]] = (s[p[2]] or 0) + (tonumber(v) or 0)
          break
        end
      end
    end
  end
  cache[link] = s
  return s
end

function ns.ItemScore(link)
  if not link then return 0 end
  local total, weights = 0, ns.STATS.weights -- follows the chosen talent plan
  for k, v in pairs(Stats(link)) do
    local w = weights[k]
    if k == "dmgsp" then w = weights.heal and 0 or weights.sp end -- damage side of a healing + damage line
    total = total + v * (w or 0)
  end
  return total
end

local function Equipped(slot)
  if not GetInventoryItemLink then return nil end
  local ok, link = pcall(GetInventoryItemLink, "player", slot)
  return ok and link or nil
end

local function IsTwoHander(link)
  if not link then return false end
  local ok, _, _, _, _, _, _, _, _, equipLoc = pcall(ns.ItemInfo, link)
  return ok and equipLoc == "INVTYPE_2HWEAPON"
end

-- Can your class wear or wield this? Uses only item IDs and types, so it works on every
-- client language (the stat comparison below needs English tooltips).
function ns.CanWear(link)
  local ok, name, _, _, _, _, _, _, _, equipLoc, _, _, classID, subclassID = pcall(ns.ItemInfo, link)
  if not ok or not name or not equipLoc or not SLOTS[equipLoc] then return false end
  if classID == 4 then return USABLE_ARMOR[subclassID] and true or false end
  if classID == 2 then return USABLE_WEAPON[subclassID] and true or false end
  return false
end

-- Returns diff (or nil if not comparable) and the required level.
function ns.CompareToEquipped(link)
  local ok, name, _, _, _, minLevel, _, _, _, equipLoc, _, _, classID, subclassID = pcall(ns.ItemInfo, link)
  if not ok or not name or not equipLoc then return nil end
  local slots = SLOTS[equipLoc]
  if not slots then return nil end
  if classID == 4 and not USABLE_ARMOR[subclassID] then return nil end
  if classID == 2 and not USABLE_WEAPON[subclassID] then return nil end
  if classID ~= 2 and classID ~= 4 then return nil end

  local wear = WearLevel(classID, subclassID)
  if wear and (minLevel or 0) < wear then minLevel = wear end

  local newScore = ns.ItemScore(link)
  local oldScore
  if equipLoc == "INVTYPE_2HWEAPON" then
    oldScore = ns.ItemScore(Equipped(16)) + ns.ItemScore(Equipped(17))
  elseif (equipLoc == "INVTYPE_HOLDABLE" or equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD")
    and IsTwoHander(Equipped(16)) then
    return nil -- would need to swap out the two-hander as well
  elseif equipLoc == "INVTYPE_WEAPON" and IsWeapon(Equipped(17)) then
    -- Dual wielding: a one-hander can replace the weaker of the two weapons.
    local a, b = Equipped(16), Equipped(17)
    if link == a or link == b then return nil end
    oldScore = math.min(ns.ItemScore(a), ns.ItemScore(b))
  elseif #slots == 2 then
    local a, b = Equipped(slots[1]), Equipped(slots[2])
    if link == a or link == b then return nil end
    oldScore = math.min(ns.ItemScore(a), ns.ItemScore(b))
  else
    local cur = Equipped(slots[1])
    if link == cur then return nil end
    oldScore = ns.ItemScore(cur)
  end
  return newScore - oldScore, minLevel
end

-- White gear has no stats, so the score above can't tell if it's worth wearing. Worth
-- keeping when you can use it and the slot is empty, or it has more armor (or weapon
-- damage per second) than what you wear there.
local function ArmorAndDps(link)
  local armor, dps = 0, 0
  if not ns.IsEnglishClient() then
    local s = Stats(link)
    return s.armor or 0, s.wdps or 0
  end
  for _, line in ipairs(TooltipLines(link)) do
    local a = line:match("^(%d+) Armor$")
    if a then armor = tonumber(a) or armor end
    local d = line:match("%((%d+%.?%d*) damage per second%)")
    if d then dps = tonumber(d) or dps end
  end
  return armor, dps
end

function ns.PlainGearBetter(link)
  local ok, name, _, _, _, _, _, _, _, equipLoc, _, _, classID, subclassID = pcall(ns.ItemInfo, link)
  if not ok or not name or not equipLoc then return false end
  local slots = SLOTS[equipLoc]
  if not slots then return false end
  if classID == 4 and not USABLE_ARMOR[subclassID] then return false end
  if classID == 2 and not USABLE_WEAPON[subclassID] then return false end
  if classID ~= 2 and classID ~= 4 then return false end
  -- An off-hand item is no use next to a two-hander.
  if slots[1] == 17 and IsTwoHander(Equipped(16)) then return false end
  local armor, dps = ArmorAndDps(link)
  for _, slot in ipairs(slots) do
    local cur = Equipped(slot)
    if not cur then return true end
    if cur ~= link then
      local curArmor, curDps = ArmorAndDps(cur)
      if classID == 4 and armor > curArmor then return true end
      if classID == 2 and dps > curDps then return true end
    end
  end
  return false
end

local function OnTooltip(tt)
  if ns.db and ns.db.upgradeOff then return end
  if not tt or tt == scanTip or not tt.GetItem then return end
  local ok, _, link = pcall(tt.GetItem, tt)
  if not ok or not link then return end
  local diff, minLevel = ns.CompareToEquipped(link)
  if not diff then return end
  local line
  if diff >= 0.5 then
    line = "|cff60ff60" .. ns.T("UP_UP", math.floor(diff + 0.5)) .. "|r"
  elseif diff <= -0.5 then
    line = "|cffff6060" .. ns.T("UP_DOWN", math.floor(diff - 0.5)) .. "|r"
  else
    line = "|cffaaaaaa" .. ns.T("UP_SAME") .. "|r"
  end
  local level = UnitLevel("player") or 1
  if minLevel and minLevel > level then
    line = line .. " |cffaaaaaa" .. ns.T("UP_LEVEL", minLevel) .. "|r"
  end
  tt:AddLine("|cff@COLOR@@ADDON@:|r " .. line)
end

ns.RegisterModule(function()
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt) pcall(OnTooltip, tt) end)
  elseif GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end)
    if ItemRefTooltip then ItemRefTooltip:HookScript("OnTooltipSetItem", function(tt) pcall(OnTooltip, tt) end) end
  end
  -- Gear changes don't change item stats, but a fresh cache keeps memory small.
  local ev = CreateFrame("Frame")
  ev:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
  ev:SetScript("OnEvent", function()
    local n = 0
    for _ in pairs(cache) do n = n + 1 end
    if n > 500 then cache = {} end
  end)
end)

ns.RegisterCommand("upgrade", true, function()
  ns.db.upgradeOff = not ns.db.upgradeOff
  ns.Print(ns.db.upgradeOff and ns.T("UP_OFF") or ns.T("UP_ON"))
end)
