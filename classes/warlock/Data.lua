-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Tailoring", "Enchanting" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "affliction", "demonology", "destruction" }
ns.PLAN_STEPS = {
  -- Affliction leveling: 38/13/0. DoTs and drains, Nightfall for free Shadow Bolts,
  -- Siphon Life at 30 and Wrack at 40, then Demonology for stamina and Demonic Sacrifice.
  affliction = {
    { "Improved Corruption", 5 },
    { "Soul Harvest", 2 }, { "Improved Drains", 3 },
    { "Improved Bane of Agony", 2 }, { "Fel Concentration", 3 },
    { "Nightfall", 2 }, { "Malevolence", 5, 3 },
    { "Siphon Life", 1 }, { "Soul Siphon", 3 }, { "Malevolence", 5, 1 },
    { "Shadow Mastery", 5 },
    { "Wrack", 1 },
    { "Pandemic", 3 }, { "Malevolence", 5, 1 }, { "Improved Life Tap", 2 },
    { "Demonic Embrace", 5 }, { "Fel Vitality", 3 }, { "Demonic Aegis", 2 },
    { "Demonic Sacrifice", 1 }, { "Improved Health Funnel", 2 }, { "Amplify Curse", 1 },
  },
  -- Demonology pet leveling: 16/35/0. Voidwalker early,
  -- Soul Link at 30, Master Demonologist and Demonic Pact at 40, then Affliction.
  demonology = {
    { "Demonic Embrace", 5 },
    { "Fel Vitality", 3 }, { "Improved Voidwalker", 3, 2 },
    { "Demonic Sacrifice", 1 }, { "Master Summoner", 2 }, { "Improved Voidwalker", 3, 1 },
    { "Unholy Power", 5, 1 },
    { "Fel Domination", 1 }, { "Demonic Brand", 3 }, { "Unholy Power", 5, 1 },
    { "Soul Link", 1 }, { "Demonic Knowledge", 3 }, { "Unholy Power", 5, 1 },
    { "Master Demonologist", 5 },
    { "Demonic Pact", 1 },
    { "Unholy Power", 5, 2 }, { "Demonic Aegis", 2 },
    { "Improved Corruption", 5 }, { "Improved Drains", 3 }, { "Soul Harvest", 2 },
    { "Improved Life Tap", 2 }, { "Improved Bane of Agony", 2 }, { "Fel Concentration", 3, 2 },
  },
  -- Destruction: 41/0/10. Faster Shadow Bolts first, Ruin for big crits, Conflagrate,
  -- Shadow and Flame at 40 and Incinerate, then Affliction for Corruption and drains.
  destruction = {
    { "Bane", 5 },
    { "Cataclysm", 3 }, { "Aftermath", 5, 2 },
    { "Ruin", 5 },
    { "Shadowburn", 1 }, { "Conflagrate", 1 }, { "Agonizing Flames", 3 },
    { "Fire and Brimstone", 3 }, { "Intensity", 3 },
    { "Shadow and Flame", 5 },
    { "Bane of Havoc", 1 }, { "Incinerate", 1 },
    { "Improved Shadow Bolt", 5 }, { "Aftermath", 5, 3 },
    { "Improved Corruption", 5 }, { "Improved Drains", 3 }, { "Soul Harvest", 2 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [5]  = { "Lesser Magic Wand (Enchanting)" },
  [10] = { { "Novice Arcanist's Sash (Tailoring, belt)", "Novice Arcanist's Sash (Tailoring, bälte)" },
           { "Keep a few Soul Shards: Drain Soul a mob as it dies", "Ha några Soul Shards: Drain Soul på ett mob när det dör" } },
  [12] = { { "Silky boots (Tailoring)", "Silky-stövlar (Tailoring)" } },
  [13] = { "Greater Magic Wand (Enchanting)" },
  [15] = { { "Silky gloves (Tailoring)", "Silky-handskar (Tailoring)" },
           { "Filigreed Silky Gown (Tailoring 75, pattern from SFK/Deadmines)", "Filigreed Silky Gown (Tailoring 75, mönster från SFK/Deadmines)" } },
  [17] = { { "Silky belt (Tailoring)", "Silky-bälte (Tailoring)" } },
  [20] = { { "Silky hood (Tailoring)", "Silky-huva (Tailoring)" },
           { "Filigreed Silky Leggings (Tailoring 100, pattern from SFK)", "Filigreed Silky Leggings (Tailoring 100, mönster från SFK)" },
           { "Demon Armor replaces Demon Skin: put it in the buff watcher's place", "Demon Armor ersätter Demon Skin" } },
  [25] = { { "Silky pants / Filigreed Silky hood (Tailoring)", "Silky-byxor / Filigreed Silky-huva (Tailoring)" },
           "Glimmering Staff (Enchanting 140, +34 spell dmg)",
           "Orb of Mystic Insight (Enchanting 140, off-hand)" },
  [30] = { { "Frothing boots (Tailoring)", "Frothing-stövlar (Tailoring)" },
           { "Felhunter: Spell Lock and Devour Magic for casters", "Felhunter: Spell Lock och Devour Magic mot casters" } },
  [35] = { { "Frothing gloves (Tailoring)", "Frothing-handskar (Tailoring)" } },
  [40] = { { "Frothing belt (Tailoring)", "Frothing-bälte (Tailoring)" } },
  [42] = { { "Netherfroth shoulders (Tailoring)", "Netherfroth-axlar (Tailoring)" } },
  [45] = { { "Netherfroth bracers (Tailoring)", "Netherfroth-armband (Tailoring)" },
           "Radiant Staff (Enchanting, +56 spell dmg)" },
  [50] = { { "Frothing gloves/boots (Tailoring)", "Frothing-handskar/-stövlar (Tailoring)" } },
  [55] = { "Brilliant Wand (Enchanting 275)" },
  [60] = { { "Felcloth pieces (Tailoring 300)", "Felcloth-delar (Tailoring 300)" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Corruption", "Curse of Weakness" },
  [6]  = { "Life Tap" },
  [8]  = { "Bane of Agony", "Fear" },
  [10] = { "Create Healthstone", "Drain Soul", "Summon Voidwalker" },
  [12] = { "Health Funnel" },
  [14] = { "Curse of Recklessness", "Drain Life" },
  [18] = { "Create Soulstone", "Searing Pain" },
  [20] = { "Demon Armor", "Rain of Fire", "Ritual of Summoning", "Summon Incubus", "Summon Succubus" },
  [24] = { "Drain Mana" },
  [26] = { "Curse of Tongues" },
  [28] = { "Banish", "Create Firestone" },
  [30] = { "Hellfire", "Subjugate Demon", "Summon Felhunter" },
  [36] = { "Create Spellstone" },
  [40] = { "Howl of Terror" },
  [42] = { "Death Coil" },
  [48] = { "Soul Fire" },
  [50] = { "Inferno" },
  [60] = { "Bane of Doom", "Portal of Summoning", "Ritual of Doom" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (Stormwind)", "Träna Journeyman (Stormwind)" } },
  { level = 15, skill = 75,  note = { "Needed for Filigreed Silky Gown", "Krävs för Filigreed Silky Gown" } },
  { level = 20, skill = 125, note = { "Train Expert (Georgio Bolero / Kitta Firewind)", "Träna Expert (Georgio Bolero / Kitta Firewind)" } },
  { level = 35, skill = 200, note = { "Train Artisan (Theramore / Annora in Uldaman)", "Träna Artisan (Theramore / Annora i Uldaman)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Affliction", "Demonology", "Destruction" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Shadow Bolt", "Immolate", "Corruption", "Bane of Agony", "Curse of Weakness", "Life Tap",
  "Drain Life", "Drain Soul", "Drain Mana", "Fear", "Searing Pain", "Rain of Fire", "Hellfire",
  "Soul Fire", "Death Coil", "Howl of Terror", "Banish", "Health Funnel", "Demon Armor",
  "Curse of Recklessness", "Curse of Tongues", "Shadowburn", "Conflagrate", "Incinerate",
  "Siphon Life", "Wrack", "Create Healthstone", "Create Soulstone",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
-- Affliction and Demonology count Shadow damage, Destruction Shadow and Fire.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  affliction = { shadow = 1.0, sp = 1.0, int = 0.35, spi = 0.3, sta = 0.4, crit = 6, hit = 10, mp5 = 1.0, wdps = 1.5 },
  demonology = { shadow = 1.0, sp = 1.0, int = 0.35, spi = 0.25, sta = 0.6, crit = 6, hit = 9, mp5 = 1.0, wdps = 1.5 },
  destruction = { shadow = 0.8, fire = 0.5, sp = 1.0, int = 0.35, spi = 0.2, sta = 0.35, crit = 10, hit = 10, mp5 = 1.0, wdps = 1.5 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.affliction
ns.STATS.patterns = {
  { "Shadow spells and effects by up to (%d+)", "shadow" },
  { "Fire spells and effects by up to (%d+)", "fire" },
  { "[Ss]hadow [Ss]pell [Pp]ower by (%d+)", "shadow" },
  { "[Ff]ire [Ss]pell [Pp]ower by (%d+)", "fire" },
  { "^%+(%d+) Shadow Spell Damage", "shadow" },
  { "^%+(%d+) Fire Spell Damage", "fire" },
  { "magical spells and effects by up to (%d+)", "sp" },
  { "[Ss]pell [Pp]ower by (%d+)", "sp" },
  { "^%+(%d+) Spell Damage", "sp" },
  { "^%+(%d+) Damage and Healing Spells", "sp" },
  { "critical strike with spells by (%d+)%%", "crit" },
  { "chance to hit with spells by (%d+)%%", "hit" },
  { "(%d+) mana per 5 sec", "mp5" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
  { "^%+(%d+) Stamina", "sta" },
  { "%((%d+%.?%d*) damage per second%)", "wdps" },
}
ns.STATS.armor = { [0] = true, [1] = true }
ns.STATS.weapon = { [7] = true, [10] = true, [15] = true, [19] = true }

-- Demonic Sacrifice gives one of these instead of a pet: no "summon your demon" then.
ns.SACRIFICE_BUFFS = { "Demonic Sacrifice", "Touch of Shadow", "Burning Wish", "Fel Stamina", "Fel Energy" }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = { "Demon Armor", "Demon Skin" }, buffs = { "Demon Armor", "Demon Skin" } },
  { spells = { "Soul Link" }, buffs = { "Soul Link" },
    only = function() return UnitExists("pet") and not UnitIsDead("pet") end },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {
  { cost = 45,  name = "Glimmering Staff" },
  { cost = 180, name = "Brilliant Wand" },
}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {
  { zone = "Three Corners",
    text = { "Merchant's Favor vendors are here: Mivin Shadowweave (Tailoring patterns) and Alynsia (Enchanting).", "Här finns Merchant's Favor-försäljarna: Mivin Shadowweave (Tailoring-mönster) och Alynsia (Enchanting)." } },
}

-- Settings window: the combat helper's command and the class theme colors.
ns.COMBAT_CMD = "combat"
ns.THEME_BG = { 0.06, 0.03, 0.09, 0.92 }
ns.THEME_BORDER = { 0.58, 0.51, 0.79, 0.9 }
ns.LOGO = { h = 471 / 512, size = 210, y = 62, panel = 260 }
