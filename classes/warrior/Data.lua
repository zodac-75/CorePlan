-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Blacksmithing", "Mining" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "arms", "fury", "prot" }
ns.PLAN_STEPS = {
  -- Arms, two-hander: 31/20/0. Mortal Strike at 40, then Fury for crit and rage.
  arms = {
    { "Improved Rend", 3 }, { "Improved Heroic Strike", 3, 2 },
    { "Improved Charge", 2 }, { "Improved Tactical Mastery", 3 },
    { "Anger Management", 1 }, { "Deep Wounds", 3 }, { "Improved Heroic Strike", 3, 1 },
    { "Two-Handed Weapon Specialization", 3 }, { "Impale", 2 },
    { "Sweeping Strikes", 1 }, { "Weaponmaster", 5 },
    { "Improved Overpower", 2 }, { "Bloodthrill", 2 },
    { "Mortal Strike", 1 },
    { "Cruelty", 5 }, { "Unbridled Wrath", 5 }, { "Enrage", 5 }, { "Improved Execute", 2 },
    { "Blood Craze", 3 },
  },
  -- Fury, two one-handers: 17/34/0. Bloodthirst at 41.
  fury = {
    { "Cruelty", 5 }, { "Unbridled Wrath", 5 },
    { "Furious Precision", 3 }, { "Enrage", 5, 2 },
    { "Dual Wield Specialization", 5 },
    { "Death Wish", 1 }, { "Improved Berserker Rage", 2 }, { "Enrage", 5, 3 },
    { "Flurry", 3 }, { "Improved Whirlwind", 2 },
    { "Bloodthirst", 1 },
    { "Improved Heroic Strike", 3 }, { "Improved Rend", 3, 2 },
    { "Improved Charge", 2 }, { "Improved Tactical Mastery", 3 },
    { "Anger Management", 1 }, { "Improved Rend", 3, 1 }, { "Deep Wounds", 3 }, { "Impale", 2 },
    { "Improved Execute", 2 },
  },
  -- Protection, sword and board: 20/0/31. Shield Slam at 40.
  prot = {
    { "Shield Specialization", 5 },
    { "Improved Revenge", 3 }, { "Improved Thunder Clap", 3, 2 },
    { "Defiance", 3 }, { "Master of Defense", 2 },
    { "Improved Sunder Armor", 3 }, { "Vanguard", 1 }, { "Last Stand", 1 },
    { "Concussion Blow", 1 }, { "Focused Rage", 3 }, { "Improved Thunder Clap", 3, 1 },
    { "Bastion", 5 },
    { "Shield Slam", 1 },
    { "Improved Heroic Strike", 3 }, { "Deflection", 5, 2 },
    { "Improved Tactical Mastery", 3 }, { "Improved Charge", 2 },
    { "Anger Management", 1 }, { "Improved Rend", 3 }, { "Deep Wounds", 3 }, { "Impale", 2 },
    { "Deflection", 5, 1 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [10] = { { "Rough Sharpening Stone / Rough Weightstone (Blacksmithing)", "Rough Sharpening Stone / Rough Weightstone (Blacksmithing)" },
           { "Elixir of Lion's Strength (Alchemy)", "Elixir of Lion's Strength (Alchemy)" } },
  [20] = { { "Coarse Sharpening Stone (Blacksmithing)", "Coarse Sharpening Stone (Blacksmithing)" },
           { "Elixir of Minor Agility / Ogre's Strength (Alchemy)", "Elixir of Minor Agility / Ogre's Strength (Alchemy)" },
           { "Your weapon is most of your damage: check for a weapon upgrade every few levels", "Vapnet är det mesta av din skada: kolla efter ett bättre vapen med några levels mellanrum" } },
  [25] = { { "Heavy Sharpening Stone (Blacksmithing)", "Heavy Sharpening Stone (Blacksmithing)" } },
  [30] = { { "Berserker Stance: Intercept and Berserker Rage (fear immunity)", "Berserker Stance: Intercept och Berserker Rage (immun mot fear)" } },
  [35] = { { "Solid Sharpening Stone (Blacksmithing)", "Solid Sharpening Stone (Blacksmithing)" },
           { "Elixir of Agility (Alchemy)", "Elixir of Agility (Alchemy)" } },
  [40] = { { "Plate armor from now on", "Plåt från och med nu" },
           { "Elixir of Greater Agility (Alchemy)", "Elixir of Greater Agility (Alchemy)" } },
  [45] = { { "Dense Sharpening Stone (Blacksmithing)", "Dense Sharpening Stone (Blacksmithing)" } },
  [50] = { { "Elixir of the Mongoose / Elixir of Giants (Alchemy)", "Elixir of the Mongoose / Elixir of Giants (Alchemy)" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Charge", "Rend" },
  [6]  = { "Thunder Clap" },
  [8]  = { "Hamstring" },
  [10] = { "Bloodrage", "Defensive Stance", "Sunder Armor", "Taunt" },
  [12] = { "Overpower", "Shield Bash" },
  [14] = { "Demoralizing Shout", "Revenge" },
  [16] = { "Mocking Blow", "Shield Block" },
  [18] = { "Disarm" },
  [20] = { "Cleave", "Retaliation", "Slam", "Victory Rush" },
  [22] = { "Intimidating Shout" },
  [24] = { "Execute" },
  [26] = { "Challenging Shout" },
  [28] = { "Shield Wall" },
  [30] = { "Berserker Rage", "Berserker Stance", "Intercept" },
  [36] = { "Whirlwind" },
  [38] = { "Pummel" },
  [50] = { "Recklessness" },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Arms", "Fury", "Protection" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Heroic Strike", "Rend", "Charge", "Thunder Clap", "Hamstring", "Battle Shout", "Sunder Armor",
  "Overpower", "Shield Bash", "Demoralizing Shout", "Revenge", "Mocking Blow", "Cleave", "Slam",
  "Execute", "Intercept", "Pummel", "Mortal Strike", "Bloodthirst", "Shield Slam",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
-- Weights are "attack power" per point for Arms/Fury and tank points for Protection.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  arms = { wdps = 14, ap = 1.0, str = 2.0, agi = 1.0, sta = 0.5, crit = 22, hit = 18,
           dodge = 2, parry = 2, def = 0.3 },
  fury = { wdps = 12, ap = 1.0, str = 2.0, agi = 1.1, sta = 0.5, crit = 24, hit = 22,
           dodge = 2, parry = 2, def = 0.3 },
  prot = { wdps = 5, ap = 0.4, str = 1.0, agi = 1.0, sta = 1.6, crit = 8, hit = 10,
           def = 2.0, dodge = 14, parry = 12, block = 8, blockv = 0.6, armor = 0.06 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.arms
ns.STATS.patterns = {
  { "%((%d+%.?%d*) damage per second%)", "wdps" },
  { "[Aa]ttack [Pp]ower by (%d+)", "ap" },
  { "^%+(%d+) Attack Power", "ap" },
  { "critical strike with spells by (%d+)%%", "scrit" },
  { "chance to hit with spells by (%d+)%%", "shit" },
  { "critical strike by (%d+)%%", "crit" },
  { "chance to hit by (%d+)%%", "hit" },
  { "chance to dodge an attack by (%d+)%%", "dodge" },
  { "chance to parry an attack by (%d+)%%", "parry" },
  { "chance to block attacks with a shield by (%d+)%%", "block" },
  { "block value of your shield by (%d+)", "blockv" },
  { "^(%d+) Block$", "blockv" },
  { "Increased Defense %+(%d+)", "def" },
  { "^%+(%d+) Defense", "def" },
  { "^(%d+) Armor$", "armor" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Stamina", "sta" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [6] = true }
ns.STATS.armorFrom = { [4] = 40 } -- plate from level 40
ns.STATS.weapon = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [5] = true,
  [6] = true, [7] = true, [8] = true, [10] = true, [13] = true, [15] = true, [16] = true, [18] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = { "Battle Shout" }, buffs = { "Battle Shout" }, warn = 20,
    -- Shouting needs rage: only when you have an enemy targeted (set before the pull).
    only = function() return ns.HasHostileTarget() end },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {}

-- Settings window: the combat helper's command and the class theme colors.
-- Warriors use rage: no drink reminder.
ns.NO_MANA = true
ns.COMBAT_CMD = "combat"
ns.THEME_BG = { 0.10, 0.04, 0.03, 0.92 }
ns.THEME_BORDER = { 0.80, 0.30, 0.20, 0.9 }
