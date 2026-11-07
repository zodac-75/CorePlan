# WarriorPlan 1.0.0-beta11

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# WarriorPlan 1.0.0-beta10

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# WarriorPlan 1.0.0-beta9

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# WarriorPlan 1.0.0-beta8

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# WarriorPlan 1.0.0-beta7

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# WarriorPlan 1.0.0-beta6

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# WarriorPlan 1.0.0-beta5

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# WarriorPlan 1.0.0-beta4

- No more drink reminder: warriors use rage. The drink settings are gone from the menus too.
- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# WarriorPlan 1.0.0-beta3

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# WarriorPlan 1.0.0-beta2

- Plate armor shows "usable at level 40" in the upgrade check until you can wear it, and the quest reward picker skips it.
- Shields now get the upgrade check too (they were never compared before).
- Fury and other dual wielders: a one-hand weapon is compared with the weaker of your two weapons.
- Talent window: one odd frame can no longer stop the search for the talent to mark.
- Execute is called out even when the game hides your target's health.

# WarriorPlan 1.0.0-beta1

First beta of WarriorPlan, the warrior leveling companion for WoW Forever.

- Pick your spec in the settings window (or `/war plan`): **Arms** (two-hander), **Fury** (dual wield) or **Protection** (tank). The talent plan, the upgrade check and the combat helper follow the spec.
- Talent plans for all three specs, checked against the live talent tree.
- Combat helper: Overpower (Arms/Fury), Revenge (Protection), Execute and Victory Rush call-outs, plus Battle Shout, Rend and Demoralizing Shout reminders.
- Upgrade check and quest reward picker with weapon-focused weights for Arms/Fury and tank weights (stamina, defense, avoidance, block) for Protection.
- Trainer list and rank check for every warrior ability.
- Dungeon guide with warrior loot, profession assistant (Blacksmithing and Mining by default, pick any two), XP tracker, profiles and the emote easter eggs.
