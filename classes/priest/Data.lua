-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Tailoring", "Enchanting" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "shadow", "holy", "disc" }
ns.PLAN_STEPS = {
  -- Shadow leveling: 13/0/38 (Discipline/Holy/Shadow). Spirit Tap for mana, Mind Flay at 20, Vampiric Embrace,
  -- Shadowform at 40, then Discipline for wands, instant spells and Intellect.
  shadow = {
    { "Spirit Tap", 5 },
    { "Improved Shadow Word: Pain", 2 }, { "Improved Mind Blast", 5, 3 },
    { "Mind Flay", 1 }, { "Improved Mind Flay", 2 }, { "Improved Mind Blast", 5, 2 },
    { "Vampiric Embrace", 1 }, { "Shadow Weaving", 3 }, { "Dark Inspiration", 5, 1 },
    { "Silence", 1 }, { "Dark Inspiration", 5, 4 },
    { "Darkness", 5 },
    { "Shadowform", 1 },
    { "Shadow Focus", 5 }, { "Shadow Reach", 2 },
    { "Wand Specialization", 2 }, { "Twin Disciplines", 5 }, { "Mental Strength", 5 },
    { "Martyrdom", 2, 1 },
  },
  -- Holy healer: 15/36/0. Faster heals, Spiritual Guidance,
  -- Prayer of Mending at 40, then Discipline for Intellect and regen.
  holy = {
    { "Holy Specialization", 5 }, { "Divine Fury", 5 },
    { "Holy Nova", 1 }, { "Inspiration", 3 }, { "Improved Renew", 3, 1 },
    { "Improved Healing", 3 }, { "Searing Light", 2 },
    { "Spirit of Redemption", 1 }, { "Spiritual Guidance", 5 },
    { "Spiritual Healing", 3 }, { "Litany of Light", 2 },
    { "Prayer of Mending", 1 },
    { "Improved Renew", 3, 2 }, { "Twilight Focus", 3, 2 },
    { "Twin Disciplines", 5 }, { "Mental Strength", 5 }, { "Meditation", 3 },
    { "Improved Power Word: Shield", 3, 2 },
  },
  -- Discipline: 34/17/0. Shields, Penance at 30 and Power Infusion at 40, then Holy.
  disc = {
    { "Twin Disciplines", 5 }, { "Wand Specialization", 2 }, { "Mental Strength", 5 },
    { "Improved Power Word: Shield", 3 }, { "Mental Agility", 3 }, { "Inner Focus", 1 },
    { "Soul Warding", 1 }, { "Penance", 1 },
    { "Meditation", 3 }, { "Improved Inner Fire", 3, 1 }, { "Divine Aegis", 3 }, { "Renewed Hope", 5 },
    { "Power Infusion", 1 },
    { "Holy Specialization", 5 }, { "Divine Fury", 5 }, { "Improved Renew", 3 },
    { "Inspiration", 3 }, { "Holy Nova", 1 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [5]  = { "Lesser Magic Wand (Enchanting)" },
  [10] = { { "Novice Arcanist's Sash (Tailoring, belt)", "Novice Arcanist's Sash (Tailoring, bälte)" },
           { "Use your wand between spells: it saves a lot of mana", "Använd wanden mellan spells: det sparar mycket mana" } },
  [12] = { { "Silky boots (Tailoring)", "Silky-stövlar (Tailoring)" } },
  [13] = { "Greater Magic Wand (Enchanting)" },
  [15] = { { "Silky gloves (Tailoring)", "Silky-handskar (Tailoring)" },
           { "Filigreed Silky Gown (Tailoring 75, pattern from SFK/Deadmines)", "Filigreed Silky Gown (Tailoring 75, mönster från SFK/Deadmines)" } },
  [17] = { { "Silky belt (Tailoring)", "Silky-bälte (Tailoring)" } },
  [20] = { { "Silky hood (Tailoring)", "Silky-huva (Tailoring)" },
           { "Filigreed Silky Leggings (Tailoring 100, pattern from SFK)", "Filigreed Silky Leggings (Tailoring 100, mönster från SFK)" } },
  [25] = { { "Silky pants / Filigreed Silky hood (Tailoring)", "Silky-byxor / Filigreed Silky-huva (Tailoring)" },
           "Glimmering Staff (Enchanting 140, +34 spell dmg)",
           "Orb of Mystic Insight (Enchanting 140, off-hand)" },
  [30] = { { "Frothing boots (Tailoring)", "Frothing-stövlar (Tailoring)" } },
  [35] = { { "Frothing gloves (Tailoring)", "Frothing-handskar (Tailoring)" } },
  [40] = { { "Frothing belt (Tailoring)", "Frothing-bälte (Tailoring)" } },
  [42] = { { "Netherfroth shoulders (Tailoring)", "Netherfroth-axlar (Tailoring)" } },
  [45] = { { "Netherfroth bracers (Tailoring)", "Netherfroth-armband (Tailoring)" },
           "Radiant Staff (Enchanting, +56 spell dmg)" },
  [50] = { { "Frothing gloves/boots (Tailoring)", "Frothing-handskar/-stövlar (Tailoring)" } },
  [55] = { "Brilliant Wand (Enchanting 275)" },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
-- Racial priest spells are left out (not every priest can learn them).
ns.spells = {
  [4]  = { "Shadow Word: Pain" },
  [6]  = { "Power Word: Shield" },
  [8]  = { "Fade", "Renew" },
  [10] = { "Mind Blast", "Resurrection" },
  [12] = { "Inner Fire" },
  [14] = { "Cure Disease", "Psychic Scream" },
  [16] = { "Heal" },
  [18] = { "Dispel Magic" },
  [20] = { "Devouring Plague", "Flash Heal", "Holy Fire", "Mind Soothe", "Shackle Undead" },
  [22] = { "Mind Vision" },
  [24] = { "Mana Burn" },
  [30] = { "Divine Spirit", "Mind Control", "Prayer of Healing", "Shadow Protection" },
  [32] = { "Abolish Disease" },
  [34] = { "Levitate" },
  [40] = { "Greater Heal", "Lightwell" },
  [48] = { "Prayer of Fortitude" },
  [56] = { "Prayer of Shadow Protection" },
  [60] = { "Prayer of Spirit" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (from level 10)", "Träna Journeyman (från level 10)" } },
  { level = 15, skill = 75,  note = { "Needed for Filigreed Silky Gown", "Krävs för Filigreed Silky Gown" } },
  { level = 20, skill = 125, note = { "Train Expert (from level 20)", "Träna Expert (från level 20)" } },
  { level = 35, skill = 200, note = { "Train Artisan (from level 35)", "Träna Artisan (från level 35)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Discipline", "Holy", "Shadow" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Smite", "Shadow Word: Pain", "Power Word: Shield", "Renew", "Mind Blast", "Lesser Heal", "Heal",
  "Flash Heal", "Greater Heal", "Holy Fire", "Inner Fire", "Power Word: Fortitude", "Fade",
  "Psychic Scream", "Dispel Magic", "Devouring Plague", "Mana Burn", "Mind Flay", "Holy Nova",
  "Prayer of Healing", "Shadow Protection", "Divine Spirit", "Penance", "Prayer of Mending",
  "Resurrection",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  shadow = { shadow = 1.0, sp = 1.0, int = 0.35, spi = 0.45, sta = 0.4, crit = 6, hit = 10, mp5 = 1.0, wdps = 2.0 },
  holy = { heal = 1.0, sp = 1.0, int = 0.8, spi = 0.7, mp5 = 2.0, scrit = 6, sta = 0.25, wdps = 1.0 },
  disc = { heal = 1.0, sp = 1.0, int = 1.0, spi = 0.5, mp5 = 2.0, scrit = 6, sta = 0.3, wdps = 1.5 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.shadow
ns.STATS.patterns = {
  { "Shadow spells and effects by up to (%d+)", "shadow" },
  { "[Ss]hadow [Ss]pell [Pp]ower by (%d+)", "shadow" },
  { "^%+(%d+) Shadow Spell Damage", "shadow" },
  { "healing done by spells and effects by up to (%d+)", "heal" },
  { "^%+(%d+) Healing Spells", "heal" },
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
ns.STATS.weapon = { [4] = true, [10] = true, [15] = true, [19] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = { "Power Word: Fortitude" }, buffs = { "Power Word: Fortitude", "Prayer of Fortitude" } },
  { spells = { "Inner Fire" }, buffs = { "Inner Fire" } },
  { spells = { "Shadowform" }, buffs = { "Shadowform" },
    only = function() return ns.PlanKey() == "shadow" end },
}

-- Party buffs: Power Word: Fortitude on everyone in your party.
ns.PARTY_BUFFS = {
  { spells = { "Power Word: Fortitude" }, buffs = { "Power Word: Fortitude", "Prayer of Fortitude" } },
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
ns.THEME_BG = { 0.07, 0.06, 0.09, 0.92 }
ns.THEME_BORDER = { 0.92, 0.82, 0.55, 0.9 }

-- Icy Veins link characters, one per talent in TalentIds order (tree, row, column), read
-- from the data-talenturlid of their talent calculator (2026-11-11). "-" = not on Icy Veins.
ns.ICY_IDS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOP"
