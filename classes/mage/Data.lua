-- @ADDON@ data: the leveling plan, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Tailoring", "Enchanting" }

-- Talent point per level (Frost leveling, 10/0/41 at 50, then 10 in Arcane).
-- Checked against the live tree (build 1.60.1.70755).
ns.talents = {
  [10] = "Improved Frostbolt 1/5", [11] = "Improved Frostbolt 2/5",
  [12] = "Improved Frostbolt 3/5", [13] = "Improved Frostbolt 4/5",
  [14] = "Improved Frostbolt 5/5",
  [15] = "Frostbite 1/3", [16] = "Frostbite 2/3",
  [17] = "Ice Shards 1/5", [18] = "Ice Shards 2/5", [19] = "Ice Shards 3/5",
  [20] = "Ice Lance 1/1",
  [21] = "Frost Channeling 1/3", [22] = "Frost Channeling 2/3",
  [23] = "Frost Channeling 3/3",
  [24] = "Improved Blizzard 1/3",
  -- Improved Frost Nova before Shatter, in case Shatter still requires it (as in Classic).
  [25] = "Improved Frost Nova 1/2", [26] = "Improved Frost Nova 2/2",
  [27] = "Shatter 1/3", [28] = "Shatter 2/3", [29] = "Shatter 3/3",
  [30] = "Fingers of Frost 1/2",
  [31] = "Ice Block 1/1",
  [32] = "Fingers of Frost 2/2",
  [33] = "Cold Snap 1/1",
  [34] = "Improved Cone of Cold 1/3", [35] = "Improved Cone of Cold 2/3",
  [36] = "Winter's Chill 1/5", [37] = "Winter's Chill 2/5",
  [38] = "Winter's Chill 3/5", [39] = "Winter's Chill 4/5",
  [40] = "Ice Barrier 1/1",
  [41] = "Winter's Chill 5/5",
  [42] = "Frostbite 3/3",
  [43] = "Precision 1/3", [44] = "Precision 2/3", [45] = "Precision 3/3",
  [46] = "Arctic Reach 1/2", [47] = "Arctic Reach 2/2",
  [48] = "Ice Shards 4/5", [49] = "Ice Shards 5/5",
  [50] = "Improved Blizzard 2/3",
  -- 51-60: Arcane. Row 1 (5 points) opens row 2, where Arcane Concentration gives Clearcasting.
  [51] = "Arcane Resilience 1/3", [52] = "Arcane Resilience 2/3", [53] = "Arcane Resilience 3/3",
  [54] = "Wand Specialization 1/2", [55] = "Wand Specialization 2/2",
  [56] = "Arcane Concentration 1/5", [57] = "Arcane Concentration 2/5",
  [58] = "Arcane Concentration 3/5", [59] = "Arcane Concentration 4/5",
  [60] = "Arcane Concentration 5/5",
}

-- Crafted gear that becomes available at the level.
ns.gear = {
  [5]  = { "Lesser Magic Wand (Enchanting)" },
  [10] = { { "Novice Arcanist's Sash (Tailoring, belt)", "Novice Arcanist's Sash (Tailoring, bälte)" } },
  [12] = { { "Silky boots (Tailoring)", "Silky-stövlar (Tailoring)" } },
  [13] = { "Greater Magic Wand (Enchanting)" },
  [15] = { { "Silky gloves (Tailoring)", "Silky-handskar (Tailoring)" },
           { "Filigreed Silky Gown (Tailoring 75, pattern from SFK/Deadmines)", "Filigreed Silky Gown (Tailoring 75, mönster från SFK/Deadmines)" } },
  [17] = { { "Silky belt (Tailoring)", "Silky-bälte (Tailoring)" } },
  [20] = { { "Silky hood (Tailoring)", "Silky-huva (Tailoring)" },
           { "Filigreed Silky Leggings (Tailoring 100, pattern from SFK)", "Filigreed Silky Leggings (Tailoring 100, mönster från SFK)" } },
  [22] = { { "Silky robe (Tailoring) - only if better than the Gown", "Silky-robe (Tailoring) - bara om bättre än Gown" } },
  [25] = { { "Silky pants / Filigreed Silky hood (Tailoring)", "Silky-byxor / Filigreed Silky-huva (Tailoring)" },
           "Glimmering Staff (Enchanting 140, +34 spell dmg)",
           "Orb of Mystic Insight (Enchanting 140, off-hand)" },
  [30] = { { "Frothing boots (Tailoring)", "Frothing-stövlar (Tailoring)" },
           { "Icefury Wand (mage class quest)", "Icefury Wand (mage-klassquest)" } },
  [35] = { { "Frothing gloves (Tailoring)", "Frothing-handskar (Tailoring)" } },
  [40] = { { "Frothing belt (Tailoring)", "Frothing-bälte (Tailoring)" } },
  [42] = { { "Netherfroth shoulders (Tailoring)", "Netherfroth-axlar (Tailoring)" } },
  [45] = { { "Netherfroth bracers (Tailoring)", "Netherfroth-armband (Tailoring)" },
           "Radiant Staff (Enchanting, +56 spell dmg)" },
  [47] = { { "Frothing piece (Tailoring, check the slot in game)", "Frothing-del (Tailoring, kolla slot i spelet)" } },
  [50] = { { "Frothing gloves/boots (Tailoring)", "Frothing-handskar/-stövlar (Tailoring)" },
           "Frozen Heart of the Mountain (Enchanting, trinket)" },
  [55] = { "Brilliant Wand (Enchanting 275)" },
  [60] = { "Robe of the Archmage (Tailoring)",
           { "Manaflare piece (Tailoring 300, Mount Hyjal)", "Manaflare-del (Tailoring 300, Mount Hyjal)" },
           { "RESPEC to Arcane 32/16/3 before raids (Dec 9)", "RESPECCA till Arcane 32/16/3 inför raid 9 dec" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Frostbolt", "Conjure Water" },
  [6]  = { "Conjure Food" },
  [8]  = { "Polymorph", "Arcane Missiles" },
  [10] = { "Frost Nova" },
  [14] = { "Arcane Explosion" },
  [16] = { "Flamestrike" },
  [20] = { "Blizzard", "Blink", "Teleport: Stormwind", "Teleport: Ironforge" },
  [24] = { "Counterspell" },
  [26] = { "Cone of Cold" },
  [30] = { "Ice Armor", "Teleport: Darnassus" },
}

-- Profession goals: at this level you want at least this skill.
ns.profTargets = {
  { level = 10, skill = 50,  note = { "Train Journeyman (from level 10)", "Träna Journeyman (från level 10)" } },
  { level = 15, skill = 75,  note = { "Needed for Filigreed Silky Gown", "Krävs för Filigreed Silky Gown" } },
  { level = 20, skill = 125, note = { "Train Expert (from level 20)", "Träna Expert (från level 20)" } },
  { level = 35, skill = 200, note = { "Train Artisan (from level 35)", "Träna Artisan (från level 35)" } },
  { level = 50, skill = 260, note = { "Keep pace towards 300", "Håll takten mot 300" } },
  { level = 58, skill = 300, note = { "300 needed for Manaflare", "300 krävs för Manaflare" } },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Arcane", "Fire", "Frost" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Frostbolt", "Blizzard", "Ice Lance", "Frost Nova", "Cone of Cold", "Ice Barrier",
  "Ice Block", "Cold Snap", "Ice Armor", "Frost Armor", "Arcane Explosion",
  "Arcane Missiles", "Arcane Intellect", "Arcane Blast", "Arcane Power", "Fire Blast",
  "Flamestrike", "Scorch", "Pyroblast", "Mana Shield", "Polymorph", "Counterspell",
  "Blink", "Evocation", "Conjure Water", "Conjure Food",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
ns.STATS = {}
ns.STATS.weights = {
  frost = 1.0, sp = 1.0, int = 0.4, spi = 0.2, sta = 0.25,
  crit = 8, hit = 9, mp5 = 1.2, wdps = 1.5,
}
ns.STATS.patterns = {
  { "Frost spells and effects by up to (%d+)", "frost" },
  { "Fire spells and effects by up to (%d+)", "fire" },
  { "Arcane spells and effects by up to (%d+)", "arcane" },
  { "[Ff]ire [Ss]pell [Pp]ower by (%d+)", "fire" },
  { "[Aa]rcane [Ss]pell [Pp]ower by (%d+)", "arcane" },
  { "^%+(%d+) Fire Spell Damage", "fire" },
  { "^%+(%d+) Arcane Spell Damage", "arcane" },
  { "[Ff]rost [Ss]pell [Pp]ower by (%d+)", "frost" },
  { "^%+(%d+) Frost Spell Damage", "frost" },
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
-- Fire and Arcane count their own school instead of Frost.
ns.PLAN_WEIGHTS = {
  fire = { fire = 1.0, sp = 1.0, int = 0.4, spi = 0.2, sta = 0.25, crit = 9, hit = 9, mp5 = 1.2, wdps = 1.5 },
  arcane = { arcane = 1.0, sp = 1.0, int = 0.6, spi = 0.3, sta = 0.25, crit = 7, hit = 9, mp5 = 1.4, wdps = 1.5 },
}
ns.STATS.armor = { [0] = true, [1] = true }
ns.STATS.weapon = { [7] = true, [10] = true, [15] = true, [19] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = { "Arcane Intellect" }, buffs = { "Arcane Intellect", "Arcane Brilliance" } },
  { spells = { "Mage Armor", "Ice Armor", "Frost Armor" }, buffs = { "Mage Armor", "Ice Armor", "Frost Armor" } },
}

-- Party buffs: Arcane Intellect on party members who use mana.
ns.PARTY_BUFFS = {
  { spells = { "Arcane Intellect" }, buffs = { "Arcane Intellect", "Arcane Brilliance" }, mana = true },
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

-- Talent plans: the first is ns.talents above; the others are built from these steps.
ns.PLAN_ORDER = { "frost", "frostsolo", "frostaoe", "fire", "arcane" }
ns.PLAN_STEPS = {
  -- Frost solo questing, 18/0/33: Maxroll's build (updated 2026-11-04). Maxroll's level
  -- order isn't published, so the Frost core comes first (Ice Lance at 20, Shatter at 25-27,
  -- Ice Barrier at 40), then Arcane for Clearcasting, Missile Barrage and mana regen.
  frostsolo = {
    { "Improved Frostbolt", 5 }, { "Frostbite", 3 }, { "Ice Shards", 5, 2 }, { "Ice Lance", 1 },
    { "Frost Channeling", 3 }, { "Ice Shards", 5, 1 }, { "Shatter", 3 }, { "Ice Block", 1 },
    { "Arctic Reach", 2 }, { "Fingers of Frost", 2 }, { "Cold Snap", 1 }, { "Ice Shards", 5, 2 },
    { "Precision", 3 }, { "Permafrost", 3, 1 }, { "Ice Barrier", 1 }, { "Permafrost", 3, 2 },
    { "Improved Channeling", 5 }, { "Arcane Concentration", 5 }, { "Arcane Subtlety", 2 },
    { "Missile Barrage", 2 }, { "Arcane Blast", 1 }, { "Arcane Meditation", 3 },
  },
  -- Frost AoE grinding, 0/13/38: Kargoz's AoE guide (Mobalytics, 2026-10-11) and its
  -- level order, moved to the live tree: Elemental Precision 5/5 is now Precision 3/3
  -- (2 points back) and Piercing Ice is gone (3 points back); those 5 go to Ice Shards,
  -- his own pick for Shatter AoE. Incineration fills the first Fire row (his Improved
  -- Fireball) to open Impact and Improved Flamestrike.
  frostaoe = {
    { "Precision", 3 }, { "Improved Frostbolt", 5, 2 }, { "Improved Frost Nova", 2 },
    { "Permafrost", 3 }, { "Improved Blizzard", 3 }, { "Ice Lance", 1 }, { "Frost Channeling", 3, 1 },
    { "Ice Block", 1 }, { "Arctic Reach", 2 }, { "Shatter", 3, 2 }, { "Cold Snap", 1 },
    { "Shatter", 3, 1 }, { "Frost Channeling", 3, 2 }, { "Improved Cone of Cold", 3 },
    { "Ice Shards", 5, 3 }, { "Ice Barrier", 1 },
    { "Incineration", 5 }, { "Flame Throwing", 2 }, { "Impact", 3 }, { "Improved Flamestrike", 3 },
    { "Improved Frostbolt", 5, 3 }, { "Ice Shards", 5, 2 }, { "Frost Warding", 2 },
  },
  -- Fire leveling. 10-37 follows the most common community order; 38-60 is adapted
  -- for launch (Precision has 3 ranks, Piercing Ice is gone, Incineration was buffed).
  fire = {
    { "Accelerant", 5 }, { "Ignite", 5 }, { "Flame Throwing", 2, 1 }, { "Burning Soul", 3 },
    { "Pyroblast", 1 }, { "Improved Scorch", 3 }, { "Heating Up", 1 }, { "Master of Elements", 3 },
    { "Critical Mass", 3 }, { "Fire Power", 3 }, { "Precision", 3 }, { "Incineration", 5 },
    { "Flame Throwing", 2, 1 }, { "Improved Fire Blast", 2 }, { "Blast Wave", 1 }, { "Impact", 3 },
    { "Combustion", 1 }, { "Improved Flamestrike", 3 }, { "Improved Fire Ward", 2 },
    { "Wand Specialization", 2 },
  },
  -- Arcane raid, 32/16/3 (arc-fire), filled from the live tree.
  arcane = {
    { "Improved Channeling", 5 }, { "Arcane Concentration", 5 }, { "Arcane Subtlety", 2 },
    { "Missile Barrage", 2 }, { "Arcane Impact", 3 }, { "Arcane Blast", 1 }, { "Arcane Meditation", 3 },
    { "Arcane Wrath", 1 }, { "Arcane Mind", 5 }, { "Presence of Mind", 1 }, { "Arcane Instability", 3 },
    { "Arcane Power", 1 },
    { "Incineration", 5 }, { "Ignite", 5 }, { "Improved Fire Blast", 2 }, { "Burning Soul", 3 },
    { "Pyroblast", 1 }, -- Heating Up needs Pyroblast, so Pyroblast it is
    { "Precision", 3 },
  },
}
-- Shown after "Talent plan done!" unless you're already on the Arcane raid plan.
function ns.PlanDoneExtra()
  if ns.PlanKey() ~= "arcane" then return ns.T("PLAN_DONE2") end
end

-- Settings window: the combat helper's command, extra checkboxes and logo layout.
ns.COMBAT_CMD = "shatter"
ns.EXTRA_FEATURES = {
  { key = "MM_POLY", on = function() return not ns.db.polyOff end, cmd = "poly" },
  { key = "MM_NOVA", on = function() return not ns.db.novaGuessOff end, cmd = "novaguess" },
  { key = "MM_GROUPBAR", group = "CAT_MARKS", on = function() return not ns.db.groupBarOff end, cmd = "groupbar" },
  { key = "MM_GROUPAUTO", group = "CAT_MARKS", on = function() return not ns.db.groupBarManual end, cmd = "groupbarauto", indent = 16 },
}

-- Required levels, in case the game doesn't say (water 5350-8079, food 5349-8076).
ns.ITEM_MIN_LEVEL = {
  [5350] = 1, [2288] = 5, [2136] = 15, [3772] = 25, [8077] = 35, [8078] = 45, [8079] = 55,
  [5349] = 1, [1113] = 5, [1114] = 15, [1487] = 25, [8075] = 35, [8076] = 45,
}
-- Group bar: conjured water for mana users, food for warriors and rogues (best rank first).
local function Reversed(t) local r = {} for i = #t, 1, -1 do r[#r + 1] = t[i] end return r end
ns.GROUP_TRADES = { {
  key = "GB_WATER", icon = "Interface\\Icons\\INV_Drink_18", spell = "Conjure Water", oncePer = 300,
  items = function(unit)
    local _, class = UnitClass(unit)
    local noMana = class == "WARRIOR" or class == "ROGUE"
    return Reversed((noMana and ns.CONJURED_FOOD or ns.CONJURED_WATER) or {})
  end,
} }
ns.LOGO = { h = 407 / 512, size = 250, y = 64, panel = 300 }

-- Icy Veins link characters, one per talent in TalentIds order (tree, row, column), read
-- from the data-talenturlid of their talent calculator (2026-11-11). "-" = not on Icy Veins.
ns.ICY_IDS = "023456789abcdefghiklmnopqrjstuvwxyzABCDEFGHIJKLMNOPQR"
