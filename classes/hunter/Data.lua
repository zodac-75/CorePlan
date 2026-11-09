-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Leatherworking", "Skinning" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "bm", "mm", "sv" }
ns.PLAN_STEPS = {
  -- Beast Mastery: 30/21/0. A strong pet first (Deadly Aspects with Aspect of the Hawk,
  -- Unleashed Fury, Ferocity, Frenzy), then Marksmanship for crit and mana.
  bm = {
    { "Deadly Aspects", 5 }, { "Focused Fire", 2 }, { "Endurance Training", 5, 3 },
    { "Unleashed Fury", 5 }, { "Ferocity", 5 }, { "Spirit Bond", 2 },
    { "Endurance Training", 5, 2 }, { "Bestial Swiftness", 1 },
    { "Frenzy", 5 },
    { "Lethal Attacks", 5 }, { "Careful Aim", 5 }, { "Efficiency", 5 },
    { "Improved Arcane Shot", 5 }, { "Hawk Eye", 3, 1 },
  },
  -- Marksmanship: 14/37/0. Crit and Mortal Shots, Trueshot Aura, Sniper Shot at 40,
  -- then Beast Mastery for pet damage.
  mm = {
    { "Lethal Attacks", 5 }, { "Careful Aim", 5 }, { "Improved Arcane Shot", 5 },
    { "Trueshot Aura", 1 }, { "Mortal Shots", 5 }, { "Barrage", 3 },
    { "Rapid Killing", 2 }, { "Ranged Weapon Specialization", 5 },
    { "Sniper Shot", 1 }, { "Rapid Recuperation", 2 }, { "Efficiency", 5, 3 },
    { "Deadly Aspects", 5 }, { "Endurance Training", 5, 3 }, { "Focused Fire", 2 },
    { "Unleashed Fury", 5, 4 },
  },
  -- Survival: 0/20/31. Melee and agility: Survivalist, Predator's Edge, Lightning Reflexes
  -- and Lacerating Strikes, then Marksmanship for crit and attack power.
  sv = {
    { "Improved Tracking", 5 }, { "Survivalist", 5 }, { "Savage Strikes", 2 }, { "Surefooted", 3 },
    { "Predator's Edge", 5 }, { "Expose Prey", 2 }, { "Resourcefulness", 2 }, { "Deterrence", 1 },
    { "Lightning Reflexes", 5 }, { "Lacerating Strikes", 1 },
    { "Lethal Attacks", 5 }, { "Careful Aim", 5 }, { "Efficiency", 5 }, { "Improved Arcane Shot", 5 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [1]  = { { "Keep at least two stacks of arrows or bullets in your ammo bag", "Ha alltid minst två stackar pilar eller kulor i ammo-väskan" } },
  [10] = { { "Tame your first pet: the quest is at your hunter trainer", "Tämj ditt första djur: questen finns hos din hunter-tränare" },
           { "Better ammo: Sharp Arrow / Heavy Shot", "Bättre ammo: Sharp Arrow / Heavy Shot" },
           { "Embossed Leather Vest, Gloves and Boots (Leatherworking)", "Embossed Leather Vest, Gloves och Boots (Leatherworking)" } },
  [20] = { { "Dark Leather Tunic, Boots and Cloak (Leatherworking 100)", "Dark Leather Tunic, Boots och Cloak (Leatherworking 100)" } },
  [25] = { { "Better ammo: Razor Arrow / Solid Shot", "Bättre ammo: Razor Arrow / Solid Shot" } },
  [30] = { { "Barbaric Shoulders and Gloves (Leatherworking 175)", "Barbaric Shoulders och Gloves (Leatherworking 175)" } },
  [40] = { { "You can wear mail now: mail with Agility is a big step up", "Nu kan du bära mail: mail med Agility är ett stort lyft" },
           { "Better ammo: Jagged Arrow / Accurate Slugs", "Bättre ammo: Jagged Arrow / Accurate Slugs" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Aspect of the Monkey", "Serpent Sting" },
  [6]  = { "Arcane Shot", "Hunter's Mark" },
  [8]  = { "Concussive Shot" },
  [10] = { "Aspect of the Hawk", "Revive Pet", "Track Humanoids" },
  [12] = { "Distracting Shot", "Mend Pet", "Wing Clip" },
  [14] = { "Eyes of the Beast" },
  [16] = { "Immolation Trap", "Mongoose Bite" },
  [18] = { "Multi-Shot", "Track Undead" },
  [20] = { "Aspect of the Cheetah", "Disengage", "Freezing Trap" },
  [22] = { "Scorpid Sting" },
  [24] = { "Track Hidden" },
  [26] = { "Rapid Fire", "Track Elementals" },
  [28] = { "Frost Trap" },
  [30] = { "Feign Death" },
  [32] = { "Flare", "Track Demons" },
  [34] = { "Explosive Trap" },
  [36] = { "Viper Sting" },
  [40] = { "Aspect of the Pack", "Track Giants", "Volley" },
  [46] = { "Aspect of the Wild" },
  [50] = { "Track Dragonkin" },
  [60] = { "Tranquilizing Shot" },
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
ns.TALENT_TREES = { "Beast Mastery", "Marksmanship", "Survival" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Arcane Shot", "Serpent Sting", "Hunter's Mark", "Raptor Strike", "Mongoose Bite", "Wing Clip",
  "Aspect of the Hawk", "Mend Pet", "Multi-Shot", "Immolation Trap", "Explosive Trap",
  "Freezing Trap", "Distracting Shot", "Viper Sting", "Volley", "Disengage", "Counterattack",
  "Aspect of the Wild",
}

-- Upgrade check: stat weights (in attack power), tooltip patterns and what hunters can use.
-- Careful Aim (in every plan) turns Intellect into attack power.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  bm = { wdps = 12, rap = 1.0, ap = 0.5, agi = 1.8, int = 0.9, sta = 0.5, crit = 22, hit = 18, str = 0.1, mp5 = 1.0 },
  mm = { wdps = 14, rap = 1.0, ap = 0.5, agi = 2.0, int = 0.9, sta = 0.4, crit = 26, hit = 20, str = 0.1, mp5 = 1.0 },
  sv = { wdps = 14, ap = 1.0, rap = 0.5, agi = 2.2, str = 1.0, int = 0.9, sta = 0.6, crit = 24, hit = 20, mp5 = 0.8 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.bm
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
  { "(%d+) mana per 5 sec", "mp5" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
  { "^%+(%d+) Stamina", "sta" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true, [3] = true }
ns.STATS.armorFrom = { [3] = 40 } -- mail from level 40
ns.STATS.weapon = { [0] = true, [1] = true, [2] = true, [3] = true, [6] = true, [7] = true, [8] = true,
  [10] = true, [13] = true, [15] = true, [16] = true, [18] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
-- Any aspect counts (Cheetah while you travel), but the icon casts Hawk, or Monkey before 10.
ns.BUFF_WATCH = {
  { spells = { "Aspect of the Hawk", "Aspect of the Monkey" },
    buffs = { "Aspect of the Hawk", "Aspect of the Monkey", "Aspect of the Cheetah", "Aspect of the Pack",
              "Aspect of the Wild", "Aspect of the Viper", "Aspect of the Dragonhawk", "Aspect of the Beast" } },
  { spells = { "Trueshot Aura" }, buffs = { "Trueshot Aura" } },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {}

-- Settings window: the combat helper's command and the class theme colors.
ns.COMBAT_CMD = "combat"
ns.THEME_BG = { 0.05, 0.08, 0.04, 0.92 }
ns.THEME_BORDER = { 0.67, 0.83, 0.45, 0.9 }

-- Class tick box: the ammo alert (Items group).
ns.EXTRA_FEATURES = {
  { group = "CAT_ITEMS", key = "MM_AMMO", on = function() return not ns.db.ammoOff end, cmd = "ammo" },
}
