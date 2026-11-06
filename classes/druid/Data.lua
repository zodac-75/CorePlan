-- @ADDON@ data: the leveling plan, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Alchemy", "Herbalism" }

-- Talent point per level: Feral (cat) leveling, 0/41/10 at 60.
-- Checked against the live tree (build 1.60.1.70790): every talent is taken only once
-- its row has 5 points per row spent in that tree, and Blood Frenzy (Sharpened Claws 2/2),
-- Rend and Tear (Predatory Strikes 3/3), Shifting Power (Predatory Discipline) and
-- Primal Bite (Leader of the Pack) come after what they need.
ns.talents = {
  [10] = "Ferocity 1/5", [11] = "Ferocity 2/5", [12] = "Ferocity 3/5",
  [13] = "Ferocity 4/5", [14] = "Ferocity 5/5",
  [15] = "Feral Swiftness 1/2", [16] = "Feral Swiftness 2/2",
  [17] = "Thick Hide 1/3", [18] = "Thick Hide 2/3", [19] = "Thick Hide 3/3",
  [20] = "Feral Charge 1/1",
  [21] = "Sharpened Claws 1/2", [22] = "Sharpened Claws 2/2",
  [23] = "Savage Fury 1/2", [24] = "Savage Fury 2/2",
  [25] = "Predatory Discipline 1/1",
  [26] = "Predatory Strikes 1/3", [27] = "Predatory Strikes 2/3", [28] = "Predatory Strikes 3/3",
  [29] = "Blood Frenzy 1/2",
  [30] = "Leader of the Pack 1/1",
  [31] = "Blood Frenzy 2/2",
  [32] = "Natural Instinct 1/2", [33] = "Natural Instinct 2/2",
  [34] = "Furor 1/5",
  [35] = "Rend and Tear 1/5", [36] = "Rend and Tear 2/5", [37] = "Rend and Tear 3/5",
  [38] = "Rend and Tear 4/5", [39] = "Rend and Tear 5/5",
  [40] = "Shifting Power 1/1",
  [41] = "Furor 2/5", [42] = "Furor 3/5", [43] = "Furor 4/5", [44] = "Furor 5/5",
  -- 45-54: Restoration for Strength in Cat Form (Heart of the Wild) and +10% damage (Naturalist).
  [45] = "Heart of the Wild 1/5", [46] = "Heart of the Wild 2/5", [47] = "Heart of the Wild 3/5",
  [48] = "Heart of the Wild 4/5", [49] = "Heart of the Wild 5/5",
  [50] = "Naturalist 1/5", [51] = "Naturalist 2/5", [52] = "Naturalist 3/5",
  [53] = "Naturalist 4/5", [54] = "Naturalist 5/5",
  [55] = "Shredding Attacks 1/3", [56] = "Shredding Attacks 2/3", [57] = "Shredding Attacks 3/3",
  [58] = "Primal Bite 1/1",
  [59] = "Feral Instinct 1/3", [60] = "Feral Instinct 2/3",
}

-- Quests, gear and consumables worth knowing about at the level.
ns.gear = {
  [10] = { { "Bear Form: class quest The Great Ursera Spirit (Zephras Isle)", "Bear Form: klassquesten The Great Ursera Spirit (Zephras Isle)" },
           { "Elixir of Minor Agility (Alchemy)", "Elixir of Minor Agility (Alchemy)" } },
  [20] = { { "Cat Form: class quest from your druid trainer", "Cat Form: klassquest hos din druid-trainer" },
           { "Polearms can be trained now (Woo Ping, Stormwind)", "Polearms kan tränas nu (Woo Ping, Stormwind)" },
           { "Elixir of Ogre Strength (Alchemy)", "Elixir of Ogre Strength (Alchemy)" } },
  [30] = { { "Travel Form: about mount speed outdoors", "Travel Form: ungefär mount-fart utomhus" } },
  [35] = { { "Elixir of Agility (Alchemy)", "Elixir of Agility (Alchemy)" } },
  [40] = { { "Elixir of Greater Agility (Alchemy)", "Elixir of Greater Agility (Alchemy)" } },
  [50] = { { "Elixir of the Mongoose (Alchemy 290+)", "Elixir of the Mongoose (Alchemy 290+)" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Moonfire", "Rejuvenation" },
  [6]  = { "Thorns" },
  [8]  = { "Entangling Roots" },
  [10] = { "Nature's Grasp", "Teleport: Moonglade" },
  [12] = { "Regrowth", "Revive" },
  [14] = { "Cure Poison" },
  [18] = { "Faerie Fire", "Hibernate" },
  [20] = { "Rebirth", "Starfire" },
  [24] = { "Ferocious Bite", "Rake", "Remove Curse" },
  [26] = { "Abolish Poison" },
  [28] = { "Cower" },
  [30] = { "Travel Form", "Tranquility" },
  [32] = { "Ravage" },
  [36] = { "Pounce", "Frenzied Regeneration" },
  [40] = { "Dire Bear Form", "Hurricane" },
  [44] = { "Barkskin" },
  [50] = { "Gift of the Wild" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (Sylvanna Forestmoon, Darnassus)", "Träna Journeyman (Sylvanna Forestmoon, Darnassus)" } },
  { level = 20, skill = 125, note = { "Train Expert (Ainethil, Darnassus)", "Träna Expert (Ainethil, Darnassus)" } },
  { level = 35, skill = 200, note = { "Train Artisan (Kylanna Windwhisper, Feathermoon, Feralas)", "Träna Artisan (Kylanna Windwhisper, Feathermoon, Feralas)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
  { level = 58, skill = 300, note = { "300 for Elixir of the Mongoose", "300 för Elixir of the Mongoose" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Balance", "Feral Combat", "Restoration" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Claw", "Shred", "Rake", "Rip", "Ferocious Bite", "Ravage", "Pounce", "Prowl", "Cower",
  "Maul", "Swipe", "Demoralizing Roar", "Bash", "Lacerate", "Primal Bite",
  "Mark of the Wild", "Thorns", "Rejuvenation", "Regrowth", "Moonfire", "Wrath", "Starfire",
  "Entangling Roots", "Faerie Fire", "Insect Swarm", "Nature's Grasp", "Hibernate",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
ns.STATS = {}
ns.STATS.weights = {
  wdps = 8, ap = 1.0, str = 2.0, agi = 1.6, int = 0.3, spi = 0.2, sta = 0.4,
  crit = 20, hit = 15, sp = 0.1, mp5 = 0.5,
}
ns.STATS.patterns = {
  { "%((%d+%.?%d*) damage per second%)", "wdps" },
  { "[Aa]ttack [Pp]ower by (%d+) in Cat", "ap" },
  { "[Aa]ttack [Pp]ower by (%d+)", "ap" },
  { "^%+(%d+) Attack Power", "ap" },
  { "critical strike with spells by (%d+)%%", "scrit" },
  { "chance to hit with spells by (%d+)%%", "shit" },
  { "critical strike by (%d+)%%", "crit" },
  { "chance to hit by (%d+)%%", "hit" },
  { "healing done by spells and effects by up to (%d+)", "heal" },
  { "^%+(%d+) Healing Spells", "heal" },
  { "magical spells and effects by up to (%d+)", "sp" },
  { "[Ss]pell [Pp]ower by (%d+)", "sp" },
  { "^%+(%d+) Spell Damage", "sp" },
  { "^%+(%d+) Damage and Healing Spells", "sp" },
  { "(%d+) mana per 5 sec", "mp5" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
  { "^%+(%d+) Stamina", "sta" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true }
ns.STATS.weapon = { [4] = true, [5] = true, [6] = true, [10] = true, [13] = true, [15] = true }

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {
  { zone = "Moonglade",
    text = { "Moonglade: druid trainers for every faction, and Teleport: Moonglade brings you back any time.", "Moonglade: druid-trainers för alla fraktioner, och Teleport: Moonglade tar dig hit när som helst." } },
  { zone = "Three Corners",
    text = { "Merchant's Favor vendors are here: Mivin Shadowweave (Tailoring patterns) and Alynsia (Enchanting).", "Här finns Merchant's Favor-försäljarna: Mivin Shadowweave (Tailoring-mönster) och Alynsia (Enchanting)." } },
}

ns.PLAN_ORDER = { "feral", "balance", "resto" }
ns.PLAN_STEPS = {
  -- Balance, Moonkin: 38/0/13. Moonkin Form at 40.
  balance = {
    { "Improved Wrath", 5 }, { "Genesis", 5 },
    { "Moonglow", 3 }, { "Improved Moonfire", 2 },
    { "Vengeance", 5 },
    { "Nature's Grace", 1 }, { "Eclipse", 3 }, { "Insect Swarm", 1 },
    { "Moonfury", 5 },
    { "Moonkin Form", 1 },
    { "Improved Starfire", 5 }, { "Nature's Reach", 2 },
    { "Heart of the Wild", 5 }, { "Reflection", 3 }, { "Naturalist", 5 },
  },
  -- Restoration, healer for dungeons: 8/0/43. Wild Growth at 40.
  resto = {
    { "Heart of the Wild", 5 },
    { "Naturalist", 5 },
    { "Reflection", 3 }, { "Gift of Nature", 5, 2 },
    { "Improved Rejuvenation", 3 }, { "Swiftmend", 1 }, { "Gift of Nature", 5, 1 },
    { "Nature's Swiftness", 1 }, { "Living Spirit", 3 }, { "Bloom", 1 },
    { "Improved Regrowth", 5 },
    { "Wild Growth", 1 },
    { "Gift of Nature", 5, 2 }, { "Tranquil Spirit", 5 }, { "Nature's Focus", 5 },
    { "Genesis", 5 }, { "Moonglow", 3 },
  },
}
-- Stat weights per spec: attack power for Feral, spell power for Balance, healing for Restoration.
ns.PLAN_WEIGHTS = {
  balance = { sp = 1.0, int = 0.5, scrit = 9, shit = 9, mp5 = 1.2, spi = 0.3, sta = 0.25 },
  resto = { heal = 1.0, sp = 1.0, int = 0.8, mp5 = 2.0, spi = 0.6, scrit = 6, sta = 0.25 },
}
ns.COMBAT_CMD = "combat"
