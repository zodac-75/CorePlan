# ShamanPlan 1.0.0-beta15

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# ShamanPlan 1.0.0-beta14

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# ShamanPlan 1.0.0-beta13

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# ShamanPlan 1.0.0-beta12

- Fixed "Lightning Shield is missing" showing while Lightning Shield was on. Water Shield and Earth Shield also count.
- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# ShamanPlan 1.0.0-beta11

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# ShamanPlan 1.0.0-beta10

- Mail armor shows "usable at level 40" in the upgrade check until you can wear it, and the quest reward picker skips it.
- Shields now get the upgrade check too (they were never compared before).
- Fury and other dual wielders: a one-hand weapon is compared with the weaker of your two weapons.
- Talent window: one odd frame can no longer stop the search for the talent to mark.

# ShamanPlan 1.0.0-beta9

- Pick your spec in the settings window (or `/sp plan`): Enhancement, **Elemental** or **Restoration**. The talent plan and the upgrade check follow the spec (spell power for Elemental, healing for Restoration).
- The talent tree now marks your next talent in WoW Forever's own talent window.

# ShamanPlan 1.0.0-beta8

**Changed**
- No more "you're not playing a ..." message at login on characters of another class. Handy if you have more than one of the Plan addons installed.

## ShamanPlan 1.0.0-beta7

**New**
- More secrets for players who both run one of my Plan addons. `/kiss` was only the start: try a few other emotes on a friend... `/dance` is a good place to begin. 🪩

## ShamanPlan 1.0.0-beta6

**New**
- **Pick your two main professions** in the settings window (Profession 1 and 2). "Auto" uses the professions you've learned.
- The professions window (`/sp craft`) now covers all nine main professions:
  - Crafting: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking and Tailoring, each with a WoW Forever 1-300 route and what you have and miss in bags and bank.
  - Gathering: Herbalism, Mining (best ore now, next ore, where to go) and Skinning (highest beast level you can skin, best leather).
- Profession goals in the plan window name the trainer for your next rank, and gear notes and zone tips follow the professions you picked.

## ShamanPlan 1.0.0-beta5

**New**
- A little secret for players who both use one of my Plan addons (MagePlan, ShamanPlan, DruidPlan). Try `/kiss` on a friend. <3

## ShamanPlan 1.0.0-beta4

**New**
- **Train now:** the plan window lists exactly which spell ranks your class trainer has for you (e.g. "Lightning Bolt 2"), and you get a ping with a sound when something new becomes trainable. `/sp train` shows the list again.
- Replaces the old "visit your trainer at every even level" reminder, which didn't say what to train and stayed quiet right after install.

## ShamanPlan 1.0.0-beta3

First version: a leveling companion for **Enhancement shamans in WoW Forever**, built on MagePlan.

**Leveling plan**
- Enhancement talent plan 10-60, checked against the live talent tree. The next talent glows in the talent window.
- Spells to train per level, a "Not trained yet" list and a trainer reminder.
- Rank check for your action bars (`/sp ranks`).

**Combat helper**
- "MAELSTROM 5!" when Lightning Bolt is instant, plus the stack count from 3.
- Reminders for a missing Lightning Shield, a missing weapon imbue (Windfury / Rockbiter) and Flame Shock on your target.

**Gear and loot**
- Upgrade check in tooltips, scored in attack power with Enhancement weights (weapon DPS first, then Strength, Intellect through Mental Dexterity, crit and hit).
- Quest reward picker.
- Dungeon guide for all Alliance leveling dungeons: quests with status and an arrow to the quest giver, plus shaman loot from the bosses.

**Professions**
- Alchemy assistant: the next step of a Forever 1-300 route with herbs and vials in your bags and bank.
- Herbalism: the herbs you can pick now, the next one, and where to go.

**Also included from MagePlan**
- Settings window, profiles shared by all characters, XP tracker, gold goal, drink reminder, zone tips, themes and resizable windows. English and Swedish.
