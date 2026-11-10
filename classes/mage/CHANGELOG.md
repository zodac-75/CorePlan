# MagePlan 1.29.2

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /mp ranks debug lists where each spell was found.

# MagePlan 1.29.1

- **Import Wowhead talent links too:** "Import talents" (or /mp import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# MagePlan 1.29.0

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /mp import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /mp import clear) takes it away.

# MagePlan 1.28.0

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /mp skip) to skip that talent, for example when you already put those points somewhere else. /mp skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# MagePlan 1.27.4

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# MagePlan 1.27.3

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# MagePlan 1.27.2

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /mp marks) turns the feature on or off.

# MagePlan 1.27.1

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# MagePlan 1.27.0

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# MagePlan 1.26.5

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# MagePlan 1.26.4

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# MagePlan 1.26.3

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# MagePlan 1.26.2

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# MagePlan 1.26.1

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# MagePlan 1.26.0

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# MagePlan 1.25.1

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# MagePlan 1.25.0

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# MagePlan 1.24.0

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# MagePlan 1.23.1

- **Rank check can be quiet:** untick "Rank check messages in chat" under Leveling in the settings (or `/mp rankchat`). `/mp ranks` still checks your bars when you ask.
- The rank check no longer repeats the same list in chat every time your bars change.
- **Controllers:** spells bound straight to a key or a controller button now count as "on a button", and the check also looks at the extra bar pages (slots 121-180) that controller and bar addons use.

# MagePlan 1.23.0

- **Bag check button on your bags:** a small disenchant icon above your open bags opens the bag check. Works with the normal bags and with Baganator, Bagnon, AdiBags, ArkInventory, BetterBags and ElvUI bags. Turn it off with "Bag check button on your bags" in the settings.
- **Middle-click the minimap icon** to open the bag check.

# MagePlan 1.22.3

- **Fix: the bag check opened behind the settings window**, so clicking "Bag check" there looked like it did nothing. It now opens on top.

# MagePlan 1.22.2

- The Walk on Air timer setting only shows on Skyborne characters (High Order and Windshaper), since nobody else has the racial.

# MagePlan 1.22.1

- **Fix: a missing buff could stay hidden** when the game hides the aura list (secret values in WoW Forever). The buff watcher now asks for the buff by name, so the icon shows up again (for you and your party).
- **Fix: the dance party didn't always start** when you /dance at each other. Now whoever dances back starts it for both of you, and you have 30 seconds (it used to be 10).
- The buff icons' tooltip tells you when "Move" is on, since a click doesn't cast then.
- New: `/mp buffdebug` shows why a buff icon does or doesn't show.

# MagePlan 1.22.0

- **Bag check window** (`/mp de`, or "Bag check" in the settings): lists the junk, gear to vendor, gear to disenchant and gear worth more on the AH in your bags, with what each is worth.
- **Sell and disenchant from it:** with a vendor open, click a row to sell it, or press "Sell junk and vendor items" (12 at a time, so you can still buy them back). With Enchanting, click a row to disenchant it. Shift-click sells anything to the vendor anyway.
- **Keep items:** right-click a row and that item is never sold or disenchanted from the window.
- Opens by itself when you talk to a vendor and have something to sell (turn it off with "Open the bag check at vendors").
- The sell / disenchant / AH advice in item tooltips is still there, and now in every Plan addon (turn it off under "Gear and quests").

# MagePlan 1.21.1

- **Fix: clicking a party member's buff icon could buff you instead** when they were out of range (the game's auto self-cast). The range now uses the buff spell's own range (30 yards, not the 40-yard party range); out of range the icon is faded, says so in its tooltip and a click does nothing; and the click names its target, so the game can never put it on you.

# MagePlan 1.21.0

- **Choose which buffs to watch:** a new "Buffs and reminders" group in the settings (and the quick menu) has the buff watcher, a tick box for every buff it watches (and for your party buff), and the drink reminder. Untick a buff and its icon never shows.

# MagePlan 1.20.5

- **Fix: the drink alert never showed on WoW Forever.** Forever hides your current mana from addons, so the addon couldn't tell you were low. Now the addon gives the game a rule ("show below your drink %") and the game shows or hides the alert itself, the official way to handle hidden values.

# MagePlan 1.20.4

- Drink alert: reports problems in chat instead of failing silently, and `/mp drinktest` shows what it sees (for bug reports).

# MagePlan 1.20.2

- **Real drink alert:** low mana out of combat now shows a big "Drink! Mana 23%" with a drink icon in the middle of the screen, like the combat helper's call-outs, with a short flash and the alert sound (when sounds are on for all reminders). It hides in combat, while you drink and when you're full. Move it with the "Move" switch, mouse wheel for size.
- **Low on water** shows in the same alert ("Low on water (4 left)" with the Conjure Water icon) instead of only in chat.

# MagePlan 1.20.1

- Buff watcher: right-click support for icons that have a choice (used by PaladinPlan's blessings).

# MagePlan 1.20.0

- **More easter eggs** (with a friend who also runs a Plan addon):
  - `/train`: a little train chugs across the screen.
  - `/sleep`: Z z z floats up.
  - `/laugh`: bouncing HA HA HA.
  - `/salute` or `/applaud`: fireworks.
  - `/cry`: a rain cloud drizzles.
  - `/flex`: a strong arm and gold stars.
- **Dance party:** `/dance` at each other within 10 seconds and you both get a much bigger disco with confetti.
- **Ding party:** when you level up you get fireworks, and so does everyone in your group or guild who runs a Plan addon ("Jennie reached level 30!").
- **Talent plan complete:** a little celebration when the last talent of your plan goes in.
- **Easter eggs on/off:** a new box under Fun in the settings (or `/mp eggs`) turns all of it off.

# MagePlan 1.19.0

- **Party buffs:** the buff watcher also shows your party members who are missing your buff (Arcane Intellect on party members who use mana), one icon each with their name on it. Click the icon to cast it on them; it's faded when they're out of range. Turn it on or off with "Buff my party too" under Combat and buffs.

# MagePlan 1.18.0

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# MagePlan 1.17.2

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# MagePlan 1.17.1

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/mp secondary` steps through the choices.

# MagePlan 1.17.0

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/mp secondary`.

# MagePlan 1.16.0

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/mp glide`.

# MagePlan 1.15.4

- **Separate lock for the buff row:** the buff watcher now moves with the shatter indicator ("Move shatter indicator & buffs" in the settings or the quick menu, or `/mp move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# MagePlan 1.15.3

- **Fix: action bars disappearing or moving in combat** ("Interface action failed"/blocked actions). The addon no longer opens Blizzard's talent window itself, never attaches its talent arrow, hint or map pin to Blizzard's windows, and no longer closes Blizzard's settings window. Those could "taint" the game's own UI so it got blocked in combat. To see the next talent, open your talents with N as usual: the green arrow is still there.

# MagePlan 1.15.2

- **Fix:** the rank check could say "your bars look good" with an old rank on a button (e.g. Fireball Rank 2 with Rank 3 learned), because Forever often hides the rank text. It now also compares the level each rank is learned at, and the mana cost, so old ranks are found anyway. `/mp ranks debug` shows what it sees for every button.

# MagePlan 1.15.1

- **Fix:** the talent arrow could point at a Spellbook tab (e.g. the Frost tab) when you opened the Spellbook, because its icon looks like a talent's. It now only marks talents while the Talents tab is showing.

# MagePlan 1.15.0

- **Rebuff reminder:** out of combat the buff watcher now warns you early, by default when a buff has **3 minutes left** (e.g. Frost Armor). A line above the icons says "Rebuff soon: Frost Armor (2:59 left)", the icon pulses, and you hear the alert sound if sounds are on. Click the icon to rebuff. Pick 1, 2, 3, 5 or 10 minutes, or off, under "Rebuff reminder" in the settings. Short buffs warn at a third of their length so they don't nag right after you cast them. In combat it still only warns at the last minute.

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
