-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Leatherworking", "Skinning" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "combat", "assa", "sub" }
ns.PLAN_STEPS = {
  -- Combat: 20/31/0. Swords or fist weapons and Sinister Strike: Precision, Aggression,
  -- Blade Flurry, Adrenaline Rush at 40, then Assassination for crit and poisons.
  combat = {
    { "Coup de Grace", 3 }, { "Efficient Strikes", 2 }, { "Precision", 3 }, { "Deflection", 3 },
    { "Riposte", 1 }, { "Endurance", 2 }, { "Improved Sprint", 2, 1 }, { "Aggression", 3 },
    { "Weapon Expertise", 2 }, { "Dual Wield Specialization", 2 }, { "Blade Flurry", 1 },
    { "Hack and Slash", 5 }, { "Flash of Steel", 5, 2 }, { "Adrenaline Rush", 1 },
    { "Malice", 5 }, { "Ruthlessness", 3 }, { "Improved Slice and Dice", 3 }, { "Lethality", 2 },
    { "Vigor", 2 }, { "Vile Poisons", 5 },
  },
  -- Assassination: 33/18/0. Daggers and poisons: Malice, Cold Blood, Seal Fate and
  -- Mutilate at 40, then Combat for hit and Backstab crits.
  assa = {
    { "Malice", 5 }, { "Remorseless Attacks", 2 }, { "Ruthlessness", 3 }, { "Improved Slice and Dice", 3 },
    { "Lethality", 2 }, { "Vigor", 2 }, { "Cold Blood", 1 }, { "Improved Poisons", 5 },
    { "Relentless Strikes", 5 }, { "Venom", 1 }, { "Seal Fate", 3 }, { "Mutilate", 1 },
    { "Coup de Grace", 3 }, { "Efficient Strikes", 2 }, { "Precision", 3 }, { "Puncturing Wounds", 3 },
    { "Lightning Reflexes", 5 }, { "Improved Sprint", 2 },
  },
  -- Subtlety: 0/20/31. Openers from Stealth and Hemorrhage: Opportunity, Ghostly Strike,
  -- Preparation and Death Mark, then Combat for hit and crit.
  sub = {
    { "Opportunity", 5 }, { "Improved Ambush", 3 }, { "Dirty Deeds", 2 }, { "Serrated Blades", 3 },
    { "Initiative", 3, 2 }, { "Ghostly Strike", 1 }, { "Elusiveness", 2 }, { "Premeditation", 1 },
    { "Initiative", 3, 1 }, { "Hemorrhage", 1 }, { "Preparation", 1 }, { "Setup", 3 },
    { "Boot Knife", 5 }, { "Death Mark", 1 },
    { "Coup de Grace", 3 }, { "Efficient Strikes", 2 }, { "Precision", 3 }, { "Puncturing Wounds", 3 },
    { "Lightning Reflexes", 5, 4 }, { "Aggression", 3 }, { "Endurance", 2 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [10] = { { "Embossed Leather Vest, Gloves and Boots (Leatherworking)", "Embossed Leather Vest, Gloves och Boots (Leatherworking)" },
           { "Keep a thrown weapon on you for pulling", "Ha ett kastvapen till hands för att dra fiender" } },
  [20] = { { "Poisons: do the level 20 poison quest from your rogue trainer, then buy poisons at the poison vendor", "Gifter: gör level 20-questen om gifter hos din rogue-tränare och köp sedan gifter hos giftförsäljaren" },
           { "Dark Leather Tunic, Boots and Cloak (Leatherworking 100)", "Dark Leather Tunic, Boots och Cloak (Leatherworking 100)" } },
  [30] = { { "Barbaric Shoulders and Gloves (Leatherworking 175)", "Barbaric Shoulders och Gloves (Leatherworking 175)" } },
  [40] = { { "Assassination: Mutilate wants a dagger in each hand", "Assassination: Mutilate vill ha en dagger i varje hand" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Backstab", "Pick Pocket" },
  [6]  = { "Gouge" },
  [8]  = { "Evasion" },
  [10] = { "Sap", "Slice and Dice", "Sprint" },
  [12] = { "Kick" },
  [14] = { "Expose Armor", "Garrote" },
  [16] = { "Feint" },
  [18] = { "Ambush" },
  [20] = { "Rupture" },
  [22] = { "Distract", "Vanish" },
  [26] = { "Cheap Shot" },
  [30] = { "Disarm Trap", "Kidney Shot" },
  [34] = { "Blind" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (from level 10)", "Träna Journeyman (från level 10)" } },
  { level = 20, skill = 125, note = { "Train Expert (from level 20)", "Träna Expert (från level 20)" } },
  { level = 35, skill = 200, note = { "Train Artisan (from level 35)", "Träna Artisan (från level 35)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Assassination", "Combat", "Subtlety" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Sinister Strike", "Eviscerate", "Backstab", "Gouge", "Slice and Dice", "Sprint", "Kick",
  "Expose Armor", "Garrote", "Feint", "Ambush", "Rupture", "Vanish", "Kidney Shot", "Sap",
  "Stealth", "Mutilate",
}

-- Upgrade check: stat weights (in attack power), tooltip patterns and what rogues can use.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  combat = { wdps = 14, ap = 1.0, str = 1.0, agi = 1.8, sta = 0.4, crit = 22, hit = 22, rap = 0.1, dodge = 2 },
  assa = { wdps = 12, ap = 1.0, str = 1.0, agi = 1.8, sta = 0.4, crit = 26, hit = 20, rap = 0.1, dodge = 2 },
  sub = { wdps = 14, ap = 1.0, str = 1.0, agi = 1.9, sta = 0.4, crit = 22, hit = 20, rap = 0.1, dodge = 2 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.combat
ns.STATS.patterns = {
  { "%((%d+%.?%d*) damage per second%)", "wdps" },
  { "[Rr]anged [Aa]ttack [Pp]ower by (%d+)", "rap" },
  { "^%+(%d+) Ranged Attack Power", "rap" },
  { "[Aa]ttack [Pp]ower by (%d+)", "ap" },
  { "^%+(%d+) Attack Power", "ap" },
  { "critical strike with spells by (%d+)%%", "scrit" },
  { "chance to hit with spells by (%d+)%%", "shit" },
  { "critical strike by (%d+)%%", "crit" },
  { "chance to hit by (%d+)%%", "hit" },
  { "chance to dodge an attack by (%d+)%%", "dodge" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Stamina", "sta" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true }
ns.STATS.weapon = { [2] = true, [3] = true, [4] = true, [7] = true, [13] = true, [15] = true,
  [16] = true, [18] = true }

-- Poisons: the best one in your bags for a hand. Instant first on the main hand, Deadly
-- first on the off-hand; the highest item level wins within a kind.
local POISON_ORDER = {
  [16] = { "Instant Poison", "Deadly Poison", "Wound Poison", "Crippling Poison", "Mind-numbing Poison" },
  [17] = { "Deadly Poison", "Instant Poison", "Wound Poison", "Crippling Poison", "Mind-numbing Poison" },
}

local function HasWeapon(slot)
  local ok, link = pcall(GetInventoryItemLink, "player", slot)
  if not ok or not link then return false end
  local okI, name, _, _, _, _, _, _, _, _, _, _, classID = pcall(ns.ItemInfo, link)
  return okI and name and classID == 2
end

function ns.PoisonFor(slot)
  if not HasWeapon(slot) then return nil end
  local found = {}
  local num = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
  local linkOf = C_Container and C_Container.GetContainerItemLink or GetContainerItemLink
  if not num or not linkOf then return nil end
  for bag = 0, 4 do
    for s = 1, num(bag) or 0 do
      local link = linkOf(bag, s)
      if link then
        local ok, name, _, _, ilvl, _, _, _, _, _, tex = pcall(ns.ItemInfo, link)
        if ok and name and name:find("Poison", 1, true) then
          for rank, kind in ipairs(POISON_ORDER[slot]) do
            if name:sub(1, #kind) == kind then
              local f = found[rank]
              if not f or (ilvl or 0) > f.ilvl then found[rank] = { name = name, ilvl = ilvl or 0, icon = tex } end
            end
          end
        end
      end
    end
  end
  for rank = 1, #POISON_ORDER[slot] do
    local f = found[rank]
    if f then return { name = f.name, icon = f.icon, macro = "/use " .. f.name .. "\n/use " .. slot } end
  end
end

-- Buff watcher: poisons on both weapons (click to put the best one in your bags on).
ns.BUFF_WATCH = {
  { spells = { "Main-hand poison" }, imbue = true, warn = 300, use = function() return ns.PoisonFor(16) end },
  { spells = { "Off-hand poison" }, imbue = "off", warn = 300, use = function() return ns.PoisonFor(17) end },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {}

-- Settings window: the combat helper's command and the class theme colors.
ns.COMBAT_CMD = "combat"
ns.THEME_BG = { 0.08, 0.07, 0.04, 0.92 }
ns.THEME_BORDER = { 1, 0.96, 0.41, 0.9 }

-- Settings window logo (a wide emblem at the top of the texture).
ns.LOGO = { h = 454 / 512, size = 210, y = 62, panel = 260 }

-- Icy Veins link characters, one per talent in TalentIds order (tree, row, column), read
-- from the data-talenturlid of their talent calculator (2026-11-11). "-" = not on Icy Veins.
ns.ICY_IDS = "0123754c89abRgefdhijklmpno6qrvwStusxBzALyEDFJKCGOIMNPQ"
