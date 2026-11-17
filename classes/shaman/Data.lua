-- @ADDON@ data: the leveling plan, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Alchemy", "Herbalism" }

-- Talent point per level: Enhancement leveling (12/31/8 at 60).
-- Checked against the live tree (build 1.60.1.70938): every talent is taken only once
-- its row has 5 points per row spent in that tree, and Flurry (Mental Dexterity 3/3),
-- Improved Stormstrike (Stormstrike) and Rage of the Farseer (Mental Quickness 2/2)
-- come after what they need.
-- 2026-11-17, player feedback: gear went from Intellect to Strength, so only 2/5 Ancestral
-- Knowledge; Maelstrom Weapon was nerfed, so only 2/5; Tidal Focus (hit) and Mindfulness (mana)
-- from Restoration; the rest goes into Elemental.
ns.talents = {
  [10] = "Thundering Strikes 1/5", [11] = "Thundering Strikes 2/5",
  [12] = "Thundering Strikes 3/5", [13] = "Thundering Strikes 4/5",
  [14] = "Thundering Strikes 5/5",
  [15] = "Mental Dexterity 1/3", [16] = "Mental Dexterity 2/3", [17] = "Mental Dexterity 3/3",
  [18] = "Ancestral Knowledge 1/5", [19] = "Ancestral Knowledge 2/5",
  [20] = "Shamanistic Focus 1/1",
  [21] = "Elemental Weapons 1/3", [22] = "Elemental Weapons 2/3", [23] = "Elemental Weapons 3/3",
  [24] = "Anticipation 1/3",
  [25] = "Stormstrike 1/1",
  [26] = "Flurry 1/5", [27] = "Flurry 2/5", [28] = "Flurry 3/5", [29] = "Flurry 4/5",
  [30] = "Flurry 5/5",
  [31] = "Improved Stormstrike 1/2", [32] = "Improved Stormstrike 2/2",
  [33] = "Improved Ghost Wolf 1/2", [34] = "Improved Ghost Wolf 2/2",
  [35] = "Mental Quickness 1/2", [36] = "Mental Quickness 2/2",
  [37] = "Maelstrom Weapon 1/5", [38] = "Maelstrom Weapon 2/5",
  [39] = "Toughness 1/5",
  [40] = "Rage of the Farseer 1/1",
  -- 41-48: Restoration for hit (Tidal Focus) and mana while casting (Mindfulness).
  [41] = "Tidal Focus 1/5", [42] = "Tidal Focus 2/5", [43] = "Tidal Focus 3/5",
  [44] = "Tidal Focus 4/5", [45] = "Tidal Focus 5/5",
  [46] = "Mindfulness 1/3", [47] = "Mindfulness 2/3", [48] = "Mindfulness 3/3",
  -- 49-60: Elemental for more Earth Shock / Lightning Bolt damage and melee crit after spell crits.
  [49] = "Concussion 1/5", [50] = "Concussion 2/5", [51] = "Concussion 3/5",
  [52] = "Concussion 4/5", [53] = "Concussion 5/5",
  [54] = "Elemental Devastation 1/3", [55] = "Elemental Devastation 2/3",
  [56] = "Elemental Devastation 3/3",
  [57] = "Call of Flame 1/3", [58] = "Call of Flame 2/3", [59] = "Call of Flame 3/3",
  [60] = "Reverberation 1/5",
}

-- Gear, quests and consumables worth knowing about at the level.
ns.gear = {
  [4]  = { { "Earth totem: class quest from your shaman trainer", "Jordtotem: klassquest hos din shaman-trainer" } },
  [10] = { { "Fire totem: class quest (Searing Totem)", "Eldtotem: klassquest (Searing Totem)" },
           { "Elixir of Minor Agility (Alchemy)", "Elixir of Minor Agility (Alchemy)" } },
  [20] = { { "Water totem: class quest (Healing Stream Totem)", "Vattentotem: klassquest (Healing Stream Totem)" },
           { "Elixir of Ogre Strength (Alchemy)", "Elixir of Ogre Strength (Alchemy)" } },
  [30] = { { "Air totem: Call of Air quest - pick Rage of the Storm (Enhancement weapon)", "Lufttotem: Call of Air-questen - välj Rage of the Storm (Enhancement-vapen)" },
           { "Windfury Weapon: put it on your two-hander instead of Rockbiter", "Windfury Weapon: lägg den på tvåhandaren i stället för Rockbiter" } },
  [35] = { { "Elixir of Agility (Alchemy)", "Elixir of Agility (Alchemy)" } },
  [40] = { { "Elixir of Greater Agility / Greater Strength (Alchemy)", "Elixir of Greater Agility / Greater Strength (Alchemy)" } },
  [50] = { { "Elixir of the Mongoose / Brute Force (Alchemy 290+)", "Elixir of the Mongoose / Brute Force (Alchemy 290+)" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Earth Shock", "Stoneskin Totem" },
  [6]  = { "Earthbind Totem" },
  [8]  = { "Lightning Shield" },
  [10] = { "Flame Shock", "Searing Totem", "Strength of Earth Totem" },
  [12] = { "Fire Nova", "Purge", "Ancestral Spirit" },
  [16] = { "Cure Poison" },
  [18] = { "Tremor Totem" },
  [20] = { "Ghost Wolf", "Frost Shock", "Call of the Elements", "Healing Stream Totem", "Lesser Healing Wave", "Totemic Recall" },
  [22] = { "Cure Disease" },
  [26] = { "Magma Totem", "Mana Spring Totem" },
  [28] = { "Flametongue Totem" },
  [30] = { "Windfury Weapon", "Grounding Totem", "Reincarnation" },
  [32] = { "Windfury Totem", "Chain Lightning" },
  [40] = { "Chain Heal" },
  [42] = { "Grace of Air Totem" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (from level 10)", "Träna Journeyman (från level 10)" } },
  { level = 20, skill = 125, note = { "Train Expert (from level 20)", "Träna Expert (från level 20)" } },
  { level = 35, skill = 200, note = { "Train Artisan (from level 35)", "Träna Artisan (från level 35)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
  { level = 58, skill = 300, note = { "300 for Elixir of the Mongoose", "300 för Elixir of the Mongoose" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Elemental", "Enhancement", "Restoration" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Lightning Bolt", "Chain Lightning", "Earth Shock", "Flame Shock", "Frost Shock",
  "Lightning Shield", "Rockbiter Weapon", "Flametongue Weapon", "Frostbrand Weapon", "Windfury Weapon",
  "Searing Totem", "Magma Totem", "Fire Nova", "Flametongue Totem", "Strength of Earth Totem",
  "Stoneskin Totem", "Stoneclaw Totem", "Healing Stream Totem", "Mana Spring Totem", "Windfury Totem",
  "Grace of Air Totem", "Lesser Healing Wave", "Chain Heal", "Purge", "Ancestral Spirit",
  "Earthbind Totem", "Ghost Wolf", "Stormstrike",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
ns.STATS = {}
ns.STATS.weights = {
  wdps = 14, ap = 1.0, str = 2.0, agi = 1.2, int = 1.4, spi = 0.3, sta = 0.3,
  crit = 20, hit = 15, sp = 0.4, school = 0.2, mp5 = 1.5,
}
ns.STATS.patterns = {
  { "%((%d+%.?%d*) damage per second%)", "wdps" },
  { "[Rr]anged [Aa]ttack [Pp]ower by (%d+)", "rap" }, -- no weight: not a stat for this class
  { "^%+(%d+) Ranged Attack Power", "rap" },
  { "[Aa]ttack [Pp]ower by (%d+)", "ap" },
  { "^%+(%d+) Attack Power", "ap" },
  { "critical strike with spells by (%d+)%%", "scrit" },
  { "chance to hit with spells by (%d+)%%", "shit" },
  { "critical strike by (%d+)%%", "crit" },
  { "chance to hit by (%d+)%%", "hit" },
  { "Nature spells and effects by up to (%d+)", "school" },
  { "Fire spells and effects by up to (%d+)", "school" },
  { "Frost spells and effects by up to (%d+)", "school" },
  { "^%+(%d+) %a+ Spell Damage", "school" },
  { "healing done by spells and effects by up to (%d+)", "heal" },
  { "^%+(%d+) Healing Spells", "heal" },
  { "magical spells and effects by up to (%d+)", "sp" },
  { "[Ss]pell [Pp]ower by (%d+)", "sp" },
  { "^%+(%d+) Spell Damage", "sp" },
  { "^%+(%d+) Damage and Healing Spells", "sp" },
  { "(%d+) [Mm]ana per 5 sec", "mp5" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
  { "^%+(%d+) Stamina", "sta" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true, [3] = true, [6] = true }
ns.STATS.armorFrom = { [3] = 40 } -- plate from level 40
ns.STATS.weapon = { [0] = true, [1] = true, [4] = true, [5] = true, [10] = true, [13] = true, [15] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = function(plan)
      if plan == "resto" then return { "Water Shield", "Lightning Shield" } end
      return { "Lightning Shield", "Water Shield" }
    end, buffs = { "Lightning Shield", "Water Shield", "Earth Shield" } },
  { imbue = true, warn = 120, spells = function(plan)
      if plan == "enhancement" then return { "Windfury Weapon", "Flametongue Weapon", "Rockbiter Weapon" } end
      return { "Flametongue Weapon", "Rockbiter Weapon" }
    end },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {
  { zone = "Kharanos",
    text = { "There's a shaman trainer here, closer than Ironforge.", "Här finns en shaman-trainer, närmare än Ironforge." } },
  { zone = "Three Corners",
    text = { "Merchant's Favor vendors are here: Mivin Shadowweave (Tailoring patterns) and Alynsia (Enchanting).", "Här finns Merchant's Favor-försäljarna: Mivin Shadowweave (Tailoring-mönster) och Alynsia (Enchanting)." } },
}

ns.PLAN_ORDER = { "enhancement", "elemental", "resto" }
ns.PLAN_STEPS = {
  -- Elemental, caster: 31/20/0. Lightning Overload at 32, Lightning Mastery at 40.
  elemental = {
    { "Concussion", 5 },
    { "Elemental Alacrity", 3 }, { "Reverberation", 5, 2 },
    { "Elemental Focus", 1 }, { "Elemental Devastation", 3 }, { "Convection", 5, 1 },
    { "Eye of the Storm", 3 }, { "Convection", 5, 2 },
    { "Lightning Overload", 3 }, { "Call of Thunder", 1 }, { "Elemental Reach", 2, 1 },
    { "Elemental Fury", 5 },
    { "Lightning Mastery", 1 },
    { "Thundering Strikes", 5 }, { "Ancestral Knowledge", 5 }, { "Improved Lightning Shield", 3, 1 },
    { "Shamanistic Focus", 1 }, { "Elemental Weapons", 3 }, { "Toughness", 5 },
  },
  -- Restoration, healer for dungeons: 0/8/43. Riptide at 40.
  resto = {
    { "Improved Healing Wave", 5 },
    { "Mindfulness", 3 }, { "Totemic Focus", 5, 2 },
    { "Water Shield", 1 }, { "Ancestral Healing", 3 }, { "Healing Focus", 3, 1 },
    { "Tidal Mastery", 5 },
    { "Healing Way", 3 }, { "Nature's Swiftness", 1 }, { "Mana Tide Totem", 1 },
    { "Purification", 5 },
    { "Riptide", 1 },
    { "Tidal Focus", 5 }, { "Restorative Totems", 5 }, { "Healing Focus", 3, 2 },
    { "Ancestral Knowledge", 5 }, { "Thundering Strikes", 5, 3 },
  },
}
-- Stat weights per spec: attack power for Enhancement, spell power for Elemental, healing for Restoration.
ns.PLAN_WEIGHTS = {
  elemental = { sp = 1.0, school = 0.6, int = 0.4, scrit = 9, shit = 9, mp5 = 1.2, spi = 0.1, sta = 0.25 },
  resto = { heal = 1.0, sp = 1.0, int = 0.8, mp5 = 2.0, scrit = 8, spi = 0.2, sta = 0.25 },
}
ns.COMBAT_CMD = "combat"

-- Class tick box: the Stormstrike call-out (Combat group), for those who only want Maelstrom.
ns.EXTRA_FEATURES = {
  { group = "CAT_COMBAT", key = "MM_STORMSTRIKE", on = function() return not ns.db.stormstrikeOff end, cmd = "stormstrike" },
}

-- Icy Veins link characters, one per talent in TalentIds order (tree, row, column), read
-- from the data-talenturlid of their talent calculator (2026-11-11). "-" = not on Icy Veins.
ns.ICY_IDS = "0123456789abcdefghijkmnopqrsltuvwxyzABCDEFGHIJKLMN"
