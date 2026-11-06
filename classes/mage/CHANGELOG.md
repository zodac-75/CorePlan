# MagePlan 1.8.1

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
