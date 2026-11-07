# DruidPlan 1.0.0-beta20

- **Clearer talent marker:** the next talent in your plan now gets a thick green frame that pulses, with a big green arrow bobbing above it. The old faint blue glow is gone, and so is the flicker.

# DruidPlan 1.0.0-beta19

- Talent window: the glow now shows up when the window was already open, and stays on the right talent while you click around. The "next talent" line sits at the bottom of the window.

# DruidPlan 1.0.0-beta18

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# DruidPlan 1.0.0-beta17

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# DruidPlan 1.0.0-beta16

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# DruidPlan 1.0.0-beta15

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# DruidPlan 1.0.0-beta14

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# DruidPlan 1.0.0-beta13

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# DruidPlan 1.0.0-beta12

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# DruidPlan 1.0.0-beta11

- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# DruidPlan 1.0.0-beta10

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# DruidPlan 1.0.0-beta9

- Talent window: one odd frame can no longer stop the search for the talent to mark.

# DruidPlan 1.0.0-beta8

- Pick your spec in the settings window (or `/dp plan`): Feral, **Balance** or **Restoration**. The talent plan and the upgrade check follow the spec (spell power for Balance, healing for Restoration).
- The talent tree now marks your next talent in WoW Forever's own talent window.

# DruidPlan 1.0.0-beta7

**Changed**
- No more "you're not playing a ..." message at login on characters of another class. Handy if you have more than one of the Plan addons installed.

## DruidPlan 1.0.0-beta6

**New**
- More secrets for players who both run one of my Plan addons. `/kiss` was only the start: try a few other emotes on a friend... `/dance` is a good place to begin. 🪩

## DruidPlan 1.0.0-beta5

**New**
- **Pick your two main professions** in the settings window (Profession 1 and 2). "Auto" uses the professions you've learned.
- The professions window (`/dp craft`) now covers all nine main professions:
  - Crafting: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking and Tailoring, each with a WoW Forever 1-300 route and what you have and miss in bags and bank.
  - Gathering: Herbalism, Mining (best ore now, next ore, where to go) and Skinning (highest beast level you can skin, best leather).
- Profession goals in the plan window name the trainer for your next rank, and gear notes and zone tips follow the professions you picked.

## DruidPlan 1.0.0-beta4

**New**
- A little secret for players who both use one of my Plan addons (MagePlan, ShamanPlan, DruidPlan). Try `/kiss` on a friend. <3

## DruidPlan 1.0.0-beta3

**New**
- **Train now:** the plan window lists exactly which spell ranks your class trainer has for you (e.g. "Wrath 2"), and you get a ping with a sound when something new becomes trainable. `/dp train` shows the list again.
- Replaces the old "visit your trainer at every even level" reminder, which didn't say what to train and stayed quiet right after install.

## DruidPlan 1.0.0-beta2

First version: a leveling companion for **Feral druids in WoW Forever**, built on MagePlan and ShamanPlan.

**Leveling plan**
- Feral (cat) talent plan 10-60, checked against the live talent tree. The next talent glows in the talent window.
- Spells to train per level, class quests for Bear and Cat Form, a "Not trained yet" list and a trainer reminder.
- Rank check for your action bars, form bars included (`/dp ranks`).

**Combat helper**
- In Cat Form: "CLEARCASTING!" for a free Shred or Claw, and "5 COMBO POINTS!" with Rip or Ferocious Bite.
- Reminders for a missing Mark of the Wild, Thorns, and Rake on your target.

**Gear and loot**
- Upgrade check in tooltips, scored in attack power with Feral weights (Strength, Agility, crit, hit, and weapon DPS, which feral attacks use in Forever). Leather, maces, staves, polearms, fist weapons and daggers.
- Quest reward picker.
- Dungeon guide for all Alliance leveling dungeons: quests with status and an arrow to the quest giver, plus druid loot from the bosses.

**Professions**
- Alchemy assistant: the next step of a Forever 1-300 route with herbs and vials in your bags and bank.
- Herbalism: the herbs you can pick now, the next one, and where to go.

**Also included**
- Settings window, profiles shared by all characters, XP tracker, gold goal, drink reminder, zone tips, themes and resizable windows. English and Swedish.
