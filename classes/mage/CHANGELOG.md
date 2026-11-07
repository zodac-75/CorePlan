# MagePlan 1.14.1

- **Easier to move the buff watcher:** unlock windows and the row now shows all your watched buffs (faded when they're up), so you can always find it. Drag it by any icon, Ctrl + mouse wheel to resize. Clicking doesn't cast while it's unlocked.

# MagePlan 1.14.0

- **Buff watcher:** a row of icons that appears when one of your buffs is missing (red frame) or about to run out (yellow frame, with time left). **Click an icon to cast the buff.** Drag it where you want it while windows are unlocked, and use Ctrl + mouse wheel to resize it. Turn it on or off under Features or with the quick menu. Watches Arcane Intellect and your armor (Mage/Ice/Frost Armor).

# MagePlan 1.13.2

- **DialogueUI support:** when you hover a quest reward in DialogueUI, its tooltip now shows "+ Best upgrade" and "$ Sells for the most" too.

# MagePlan 1.13.1

- **Quest rewards, two marks:** a green **+** on the reward that is your biggest upgrade, and a gold **$** on the one that sells for the most at a vendor. One item can get both. Chat says which is which.
- Works with quest dialog addons (DialogueUI, Immersion, ...) too: hover a reward and the tooltip says "+ Best upgrade" or "$ Sells for the most".

# MagePlan 1.13.0

- **Alerts with icons:** every combat helper alert now shows the icon of the spell it is about, for example the Devotion Aura icon next to "No aura", or the Overpower icon next to "OVERPOWER!".
- New **Alert style** setting (settings window → Plan and look): *Icon + text*, *Icons only* (big icons side by side, no text) or *Text only*. It's saved in your profile.

# MagePlan 1.12.4

- Talent marker: a big green arrow now points down at the next talent.

# MagePlan 1.12.3

- **Clearer talent marker:** the next talent in your plan now gets a thick green frame that pulses, with a big green arrow bobbing above it. The old faint blue glow is gone, and so is the flicker.

# MagePlan 1.12.2

- Talent window: the glow now shows up when the window was already open, and stays on the right talent while you click around. The "next talent" line sits at the bottom of the window.

# MagePlan 1.12.1

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# MagePlan 1.12.0

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# MagePlan 1.11.0

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# MagePlan 1.10.0

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# MagePlan 1.9.6

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# MagePlan 1.9.5

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# MagePlan 1.9.4

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# MagePlan 1.9.3

- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# MagePlan 1.9.2

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# MagePlan 1.9.1

- Talent window: one odd frame can no longer stop the search for the talent to mark.

# MagePlan 1.9.0

- The talent tree now marks your next talent in WoW Forever's own talent window (all three trees side by side), not only in the old one.
- The spec choice (Frost / Fire / Arcane) now also switches the upgrade check: Fire counts Fire spell damage and Arcane counts Arcane spell damage.
- Fixed the Arcane plan: it took Heating Up before Pyroblast, which the tree doesn't allow.
- The plan selector is now called "Spec".

# MagePlan 1.8.2

**Changed**
- No more "you're not playing a ..." message at login on characters of another class. Handy if you have more than one of the Plan addons installed.

## MagePlan 1.8.1

**New**
- More secrets for players who both run one of my Plan addons. `/kiss` was only the start: try a few other emotes on a friend... `/dance` is a good place to begin. 🪩

## MagePlan 1.8.0

**New**
- **Pick your two main professions** in the settings window (Profession 1 and 2). "Auto" uses the professions you've learned.
- The professions window (`/mp craft`) now covers all nine main professions:
  - Crafting: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking and Tailoring, each with a WoW Forever 1-300 route and what you have and miss in bags and bank.
  - Gathering: Herbalism, Mining (best ore now, next ore, where to go) and Skinning (highest beast level you can skin, best leather).
- Profession goals in the plan window name the trainer for your next rank, and gear notes and zone tips follow the professions you picked.

## MagePlan 1.7.4

**New**
- A little secret for players who both use one of my Plan addons (MagePlan, ShamanPlan, DruidPlan). Try `/kiss` on a friend. <3

## MagePlan 1.7.3

**New**
- **Train now:** the plan window lists exactly which spell ranks your class trainer has for you (e.g. "Frostbolt 2"), and you get a ping with a sound when something new becomes trainable. `/mp train` shows the list again.
- Replaces the old "visit your trainer at every even level" reminder, which didn't say what to train and stayed quiet right after install.

## MagePlan 1.7.2

**Removed**
- "Saved recipes" (`/mp recipes`) and its button in the settings window. It was a check tool for the crafting plan and did nothing useful while playing.

## 1.7.1

**Fixed**
- Drink reminder: no more "attempt to perform arithmetic on a secret number value" errors when WoW Forever hides your mana value from addons. The reminder now simply waits until the value is readable again.

## 1.7.0

**New**
- Profiles, shared by all your characters. In the settings window: ◀ Profile ▶ to switch, plus New and Delete. Everything is saved automatically: window positions and sizes, theme, text size and which features are on. Also `/mp profile <name>`.
- "In dungeons": pick a profile that loads by itself when you enter a dungeon; your normal one comes back when you leave.
- Checkbox "Open dungeon guide in dungeons": opens the guide on that dungeon's quests and loot when you zone in.
- Dungeon guide (`/mp dungeons`, or Tools in the settings window): all Alliance leveling dungeons from Deadmines to Stratholme.
  - Pick a dungeon to see its quests: ✔ in your quest log, completed, available, or what's missing (level, or which pre-quest to do first).
  - Click a quest to get an arrow to the quest giver (or to the pre-quest's giver). Works with TomTom if you have it.
  - Mage loot from the bosses, with upgrades marked.
  - When you zone into a dungeon, MagePlan tells you how many of its quests you have.
- Waypoint arrow: drag to move, right-click to hide (`/mp clearway`). The spot is also marked on the world map.
- Settings window with the new MagePlan logo. Right-click the minimap icon, type `/mp config`, or find MagePlan under the game's AddOns settings.
  - Features: turn every alert and helper on or off with checkboxes.
  - Plan and look: pick talent plan, theme, text size, language and drink-reminder threshold with arrows.
  - Tools: plan window, dungeon guide, crafting assistant, rank check, bag check, recipes, reset windows and more in one click.
- New minimap icon and addon-list icon.

**Changed**
- Right-click on the minimap icon now opens the settings window instead of the small menu.

Dungeon quest data comes from [QuestieDB](https://github.com/Questie/QuestieDB)'s WoW Forever database.


## 1.6.1

- Automatic releases: new versions are now packaged and uploaded to CurseForge straight from GitHub.
- No gameplay changes since 1.6.0.

## 1.6.0

**New**
- Quest reward picker: the best quest reward is highlighted with a green glow and a checkmark (biggest upgrade, or best item to sell).
- Selectable talent plans: Frost leveling, Fire leveling and Arcane raid (32/16/3), in the menu or with `/mp plan`.
- Drink reminder when you're out of combat with low mana (`/mp drinkat 40`).
- Recipe check: opening a profession window saves the crafted gear you know with its required level (`/mp recipes`).

**Changed**
- Frost plan: Improved Frost Nova moved to levels 25–26 (before Shatter), Ice Shards 4–5 moved to 48–49.
