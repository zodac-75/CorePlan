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
  { level = 10, skill = 50,  note = { "Train Journeyman (Stormwind)", "Träna Journeyman (Stormwind)" } },
  { level = 15, skill = 75,  note = { "Needed for Filigreed Silky Gown", "Krävs för Filigreed Silky Gown" } },
  { level = 20, skill = 125, note = { "Train Expert (Georgio Bolero / Kitta Firewind)", "Träna Expert (Georgio Bolero / Kitta Firewind)" } },
  { level = 35, skill = 200, note = { "Train Artisan (Theramore / Annora in Uldaman)", "Träna Artisan (Theramore / Annora i Uldaman)" } },
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
ns.STATS.armor = { [0] = true, [1] = true }
ns.STATS.weapon = { [7] = true, [10] = true, [15] = true, [19] = true }

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
ns.PLAN_ORDER = { "frost", "fire", "arcane" }
ns.PLAN_STEPS = {
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

-- Settings window: the combat helper's command, extra checkboxes and tools, logo layout.
ns.COMBAT_CMD = "shatter"
ns.EXTRA_FEATURES = {
  { key = "MM_TT", on = function() return not ns.db.tooltipOff end, cmd = "tooltip" },
  { key = "MM_POLY", on = function() return not ns.db.polyOff end, cmd = "poly" },
}
ns.EXTRA_TOOLS = { { key = "MM_DE", cmd = "de" } }
ns.LOGO = { h = 407 / 512, size = 250, y = 64, panel = 300 }
