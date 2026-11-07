-- @ADDON@ data: the leveling plans, per level.
-- Text entries are either a plain string or { "English", "Svenska" }.
local _, ns = ...

-- Main professions until you pick or learn others.
ns.DEFAULT_PROFS = { "Blacksmithing", "Mining" }

-- Talent plans (specs), picked in the settings window or with /@SLASH@ plan.
-- Each step is { talent, max rank, points (default: all) }; points go in from level 10.
-- Checked against the live tree (build 1.60.1.70790) with tools/checktalents.lua: every
-- talent comes after 5 points per row in its tree and after its prerequisite.
ns.PLAN_ORDER = { "prot", "ret", "holy" }
ns.PLAN_STEPS = {
  -- Protection: 0/35/16. Holy Shield at 30, Shieldsworn at 40, then Retribution damage.
  prot = {
    { "Redoubt", 5 },
    { "Precision", 3 }, { "Sacred Duty", 2 },
    { "Toughness", 5 },
    { "Improved Righteous Fury", 3 }, { "Shield Specialization", 2 },
    { "Holy Shield", 1 }, { "Templar's Bulwark", 1 }, { "Swift Judgement", 1 }, { "Reckoning", 5, 2 },
    { "Iron Creed", 3 }, { "Anticipation", 5, 2 },
    { "Shieldsworn", 1 },
    { "Benediction", 5 }, { "Conviction", 3 }, { "Improved Judgement", 2 },
    { "Seal of Command", 1 }, { "Pursuit of Justice", 2 }, { "Vindication", 3, 2 },
    { "Sacred Arbiter", 1 },
    { "Anticipation", 5, 3 }, { "Reckoning", 5, 1 },
  },
  -- Retribution, two-hander: 20/0/31. Vengeance at 33, Unsealed Wrath at 40.
  ret = {
    { "Benediction", 5 },
    { "Improved Judgement", 2 }, { "Conviction", 3 },
    { "Seal of Command", 1 }, { "Vindication", 3 }, { "Pursuit of Justice", 2, 1 },
    { "Two-Handed Weapon Specialization", 3 }, { "Sacred Arbiter", 1 }, { "Eye for an Eye", 2, 1 },
    { "Repentance", 1 }, { "Vengeance", 3 }, { "Pursuit of Justice", 2, 1 },
    { "Champion of the Light", 5 },
    { "Unsealed Wrath", 1 },
    { "Divine Strength", 5 }, { "Improved Seals", 5 },
    { "Holy Conduit", 2 }, { "Divine Favor", 1 }, { "Healing Light", 3, 2 },
    { "Divine Precision", 2 }, { "Healing Light", 3, 1 }, { "Purifying Power", 2 },
  },
  -- Holy, healer for dungeons: 35/0/16. Holy Shock at 30, Light's Vigil at 40.
  holy = {
    { "Spiritual Focus", 5 },
    { "Healing Light", 3 }, { "Reverence", 2 },
    { "Illumination", 5 },
    { "Divine Favor", 1 }, { "Infusion of Light", 2 }, { "Oath of Light", 1 }, { "Holy Conduit", 2, 1 },
    { "Holy Shock", 1 }, { "Boundless Light", 2 }, { "Consecrated Ground", 2 },
    { "Holy Power", 5 },
    { "Light's Vigil", 1 },
    { "Holy Conduit", 2, 1 }, { "Divine Precision", 2 }, { "Purifying Power", 2, 1 },
    { "Benediction", 5 }, { "Conviction", 3 }, { "Sanctified Judgement", 3, 2 },
    { "Unyielding Faith", 2 }, { "Pursuit of Justice", 2 }, { "Seal of Command", 1 },
    { "Sacred Arbiter", 1 },
  },
}
ns.talents = {}

-- Quests, gear and consumables worth knowing about at the level.
-- Lines naming a profession only show when you have it.
ns.gear = {
  [10] = { { "Righteous Fury: only on when you tank (Protection)", "Righteous Fury: bara på när du tankar (Protection)" },
           { "Rough Sharpening Stone / Rough Weightstone (Blacksmithing)", "Rough Sharpening Stone / Rough Weightstone (Blacksmithing)" },
           { "Elixir of Lion's Strength (Alchemy)", "Elixir of Lion's Strength (Alchemy)" } },
  [20] = { { "Consecration and Exorcism (undead and demons) from your trainer", "Consecration och Exorcism (odöda och demoner) hos din trainer" },
           { "Coarse Sharpening Stone / Weightstone (Blacksmithing)", "Coarse Sharpening Stone / Weightstone (Blacksmithing)" },
           { "Elixir of Ogre's Strength (Alchemy)", "Elixir of Ogre's Strength (Alchemy)" } },
  [25] = { { "Heavy Sharpening Stone / Weightstone (Blacksmithing)", "Heavy Sharpening Stone / Weightstone (Blacksmithing)" } },
  [35] = { { "Solid Sharpening Stone / Weightstone (Blacksmithing)", "Solid Sharpening Stone / Weightstone (Blacksmithing)" },
           { "Elixir of Agility (Alchemy)", "Elixir of Agility (Alchemy)" } },
  [40] = { { "Plate armor from now on", "Plåt från och med nu" },
           { "Hammer of the Righteous from your trainer", "Hammer of the Righteous hos din trainer" } },
  [44] = { { "Hammer of Wrath: finisher below 20% health", "Hammer of Wrath: avslutare under 20% hälsa" } },
  [45] = { { "Dense Sharpening Stone / Weightstone (Blacksmithing)", "Dense Sharpening Stone / Weightstone (Blacksmithing)" } },
  [50] = { { "Elixir of Giants / Elixir of the Sages (Alchemy)", "Elixir of Giants / Elixir of the Sages (Alchemy)" } },
}

-- Spells to train (exact spell names, so the addon can check what you already know).
ns.spells = {
  [4]  = { "Blessing of Might", "Judgement" },
  [6]  = { "Divine Protection", "Holy Strike", "Seal of the Crusader" },
  [8]  = { "Hammer of Justice", "Purify" },
  [10] = { "Blessing of Protection", "Lay on Hands", "Righteous Fury", "Seal of Fury" },
  [14] = { "Blessing of Wisdom" },
  [16] = { "Retribution Aura" },
  [18] = { "Blessing of Freedom" },
  [20] = { "Blessing of Kings", "Consecration", "Exorcism", "Flash of Light" },
  [22] = { "Concentration Aura", "Seal of Justice" },
  [30] = { "Divine Intervention", "Seal of Light" },
  [34] = { "Divine Shield" },
  [38] = { "Seal of Wisdom" },
  [40] = { "Hammer of the Righteous" },
  [42] = { "Cleanse" },
  [44] = { "Hammer of Wrath" },
  [46] = { "Blessing of Sacrifice" },
  [50] = { "Holy Wrath" },
  [52] = { "Greater Blessing of Might" },
  [54] = { "Greater Blessing of Wisdom" },
  [60] = { "Greater Blessing of Kings" },
}

---------------------------------------------------------------------------
-- Class settings used by the shared core (CorePlan).
---------------------------------------------------------------------------
ns.TALENT_TREES = { "Holy", "Protection", "Retribution" }

-- Spells with ranks that the rank check looks for on your action bars.
ns.RANK_CHECK = {
  "Holy Strike", "Seal of Righteousness", "Seal of the Crusader", "Seal of Fury", "Seal of Light",
  "Seal of Wisdom", "Judgement", "Hammer of Justice", "Consecration", "Exorcism", "Hammer of Wrath",
  "Holy Wrath", "Holy Light", "Flash of Light", "Holy Shock", "Lay on Hands", "Devotion Aura",
  "Retribution Aura", "Blessing of Might", "Blessing of Wisdom", "Blessing of Protection",
  "Divine Protection", "Divine Shield", "Holy Shield",
}

-- Upgrade check: stat weights, tooltip patterns and what this class can use.
-- Weights are "attack power" per point for Retribution, tank points for Protection
-- and healing power for Holy.
ns.STATS = {}
ns.PLAN_WEIGHTS = {
  prot = { wdps = 4, ap = 0.4, str = 1.0, agi = 0.8, sta = 1.6, int = 0.4, sp = 0.4, crit = 6, hit = 10,
           def = 2.0, dodge = 14, parry = 12, block = 8, blockv = 0.6, armor = 0.06 },
  ret = { wdps = 14, ap = 1.0, str = 2.0, agi = 0.8, sta = 0.4, int = 0.4, sp = 0.4, mp5 = 1,
          crit = 20, hit = 16, scrit = 4 },
  holy = { heal = 1.0, sp = 1.0, int = 1.0, mp5 = 2.0, scrit = 10, spi = 0.3, sta = 0.3 },
}
ns.STATS.weights = ns.PLAN_WEIGHTS.prot
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
  { "healing done by spells and effects by up to (%d+)", "heal" },
  { "magical spells and effects by up to (%d+)", "sp" },
  { "[Ss]pell [Pp]ower by (%d+)", "sp" },
  { "^%+(%d+) Spell Damage", "sp" },
  { "^%+(%d+) Damage and Healing Spells", "sp" },
  { "^%+(%d+) Healing Spells", "heal" },
  { "(%d+) mana per 5 sec", "mp5" },
  { "^%+(%d+) Strength", "str" },
  { "^%+(%d+) Agility", "agi" },
  { "^%+(%d+) Stamina", "sta" },
  { "^%+(%d+) Intellect", "int" },
  { "^%+(%d+) Spirit", "spi" },
}
ns.STATS.armor = { [0] = true, [1] = true, [2] = true, [3] = true, [4] = true, [6] = true }
ns.STATS.armorFrom = { [4] = 40 } -- plate from level 40
ns.STATS.weapon = { [0] = true, [1] = true, [4] = true, [5] = true, [6] = true, [7] = true, [8] = true }

-- Buff watcher: icons for buffs that are missing or running out (click to cast).
ns.BUFF_WATCH = {
  { spells = function(plan)
      local want = ns.WantedAura and ns.WantedAura()
      if want then return { want } end
      return plan == "ret" and { "Retribution Aura", "Devotion Aura" } or { "Devotion Aura" }
    end,
    -- The aura you picked, or any aura when it's on Auto.
    match = function(name)
      local want = ns.WantedAura and ns.WantedAura()
      if want then return name == want end
      return name:sub(-5) == " Aura"
    end },
  { spells = function(plan)
      if plan == "holy" then return { "Blessing of Wisdom", "Blessing of Might" } end
      return { "Blessing of Might", "Blessing of Wisdom" }
    end,
    match = function(name) return name:find("Blessing of ", 1, true) ~= nil end },
  { spells = { "Righteous Fury" }, buffs = { "Righteous Fury" },
    only = function() return ns.PlanKey() == "prot" end },
}

-- Merchant's Favor goals shown in the plan window.
ns.FAVOR_GOALS = {}

-- Zone tips for this class (profession tips are in the core).
ns.CLASS_TIPS = {}

-- Which aura the combat helper wants on: "auto" (by spec) or one you pick.
ns.AURAS = { "Devotion Aura", "Retribution Aura", "Concentration Aura",
  "Shadow Resistance Aura", "Frost Resistance Aura", "Fire Resistance Aura" }

function ns.WantedAura()
  local a = ns.db and ns.db.paladinAura
  if a and a ~= "auto" then return a end
  return nil
end

ns.EXTRA_SELECTORS = {
  { key = "CFG_AURA",
    value = function()
      return ns.WantedAura() or ns.T("AURA_AUTO")
    end,
    step = function(dir)
      -- "auto" plus the auras you know.
      local list = { "auto" }
      for _, a in ipairs(ns.AURAS) do
        if ns.SpellInfo(a) then table.insert(list, a) end
      end
      local cur, i = ns.db.paladinAura or "auto", 1
      for n, a in ipairs(list) do if a == cur then i = n end end
      i = ((i - 1 + dir) % #list) + 1
      ns.db.paladinAura = list[i]
    end },
}

-- Settings window: the combat helper's command and the class theme colors.
ns.COMBAT_CMD = "combat"
ns.THEME_BG = { 0.08, 0.06, 0.03, 0.92 }
ns.THEME_BORDER = { 0.95, 0.75, 0.30, 0.9 }
