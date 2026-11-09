# WarlockPlan 1.0.0-beta34

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# WarlockPlan 1.0.0-beta33

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# WarlockPlan 1.0.0-beta32

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# WarlockPlan 1.0.0-beta31

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# WarlockPlan 1.0.0-beta30

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# WarlockPlan 1.0.0-beta29

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# WarlockPlan 1.0.0-beta28

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# WarlockPlan 1.0.0-beta27

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# WarlockPlan 1.0.0-beta26

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# WarlockPlan 1.0.0-beta25

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# WarlockPlan 1.0.0-beta24

- New logo and minimap icon.

# WarlockPlan 1.0.0-beta23

- **Rank check can be quiet:** untick "Rank check messages in chat" under Leveling in the settings (or `/wl rankchat`). `/wl ranks` still checks your bars when you ask.
- The rank check no longer repeats the same list in chat every time your bars change.
- **Controllers:** spells bound straight to a key or a controller button now count as "on a button", and the check also looks at the extra bar pages (slots 121-180) that controller and bar addons use.

# WarlockPlan 1.0.0-beta22

- **Bag check button on your bags:** a small disenchant icon above your open bags opens the bag check. Works with the normal bags and with Baganator, Bagnon, AdiBags, ArkInventory, BetterBags and ElvUI bags. Turn it off with "Bag check button on your bags" in the settings.
- **Middle-click the minimap icon** to open the bag check.

# WarlockPlan 1.0.0-beta21

- **Fix: the bag check opened behind the settings window**, so clicking "Bag check" there looked like it did nothing. It now opens on top.

# WarlockPlan 1.0.0-beta20

- The Walk on Air timer setting only shows on Skyborne characters (High Order and Windshaper), since nobody else has the racial.

# WarlockPlan 1.0.0-beta19

- **Fix: a missing buff could stay hidden** when the game hides the aura list (secret values in WoW Forever). The buff watcher now asks for the buff by name, so the icon shows up again (for you and your party).
- **Fix: the dance party didn't always start** when you /dance at each other. Now whoever dances back starts it for both of you, and you have 30 seconds (it used to be 10).
- The buff icons' tooltip tells you when "Move" is on, since a click doesn't cast then.
- New: `/wl buffdebug` shows why a buff icon does or doesn't show.

# WarlockPlan 1.0.0-beta18

- **Bag check window** (`/wl de`, or "Bag check" in the settings): lists the junk, gear to vendor, gear to disenchant and gear worth more on the AH in your bags, with what each is worth.
- **Sell and disenchant from it:** with a vendor open, click a row to sell it, or press "Sell junk and vendor items" (12 at a time, so you can still buy them back). With Enchanting, click a row to disenchant it. Shift-click sells anything to the vendor anyway.
- **Keep items:** right-click a row and that item is never sold or disenchanted from the window.
- Opens by itself when you talk to a vendor and have something to sell (turn it off with "Open the bag check at vendors").
- The sell / disenchant / AH advice in item tooltips now comes with every Plan addon (turn it off under "Gear and quests").

# WarlockPlan 1.0.0-beta17

- **Fix: clicking a party member's buff icon could buff you instead** when they were out of range (the game's auto self-cast). The range now uses the buff spell's own range (30 yards, not the 40-yard party range); out of range the icon is faded, says so in its tooltip and a click does nothing; and the click names its target, so the game can never put it on you.

# WarlockPlan 1.0.0-beta16

- **Choose which buffs to watch:** a new "Buffs and reminders" group in the settings (and the quick menu) has the buff watcher, a tick box for every buff it watches (and for your party buff), and the drink reminder. Untick a buff and its icon never shows.

# WarlockPlan 1.0.0-beta15

- **Fix: the drink alert never showed on WoW Forever.** Forever hides your current mana from addons, so the addon couldn't tell you were low. Now the addon gives the game a rule ("show below your drink %") and the game shows or hides the alert itself, the official way to handle hidden values.

# WarlockPlan 1.0.0-beta14

- Drink alert: reports problems in chat instead of failing silently, and `/wl drinktest` shows what it sees (for bug reports).

# WarlockPlan 1.0.0-beta13

- **Real drink alert:** low mana out of combat now shows a big "Drink! Mana 23%" with a drink icon in the middle of the screen, like the combat helper's call-outs, with a short flash and the alert sound (when sounds are on for all reminders). It hides in combat, while you drink and when you're full. Move it with the "Move" switch, mouse wheel for size.

# WarlockPlan 1.0.0-beta12

- Buff watcher: right-click support for icons that have a choice (used by PaladinPlan's blessings).

# WarlockPlan 1.0.0-beta11

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
- **Easter eggs on/off:** a new box under Fun in the settings (or `/wl eggs`) turns all of it off.

# WarlockPlan 1.0.0-beta10

- Buff watcher: groundwork for party buffs (shown for classes with a group buff: mage, druid, paladin).

# WarlockPlan 1.0.0-beta9

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# WarlockPlan 1.0.0-beta8

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# WarlockPlan 1.0.0-beta7

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/wl secondary` steps through the choices.

# WarlockPlan 1.0.0-beta6

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/wl secondary`.

# WarlockPlan 1.0.0-beta5

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/wl glide`.

# WarlockPlan 1.0.0-beta4

- **Separate lock for the buff row:** the buff watcher now moves with the combat helper ("Move combat helper & buffs" in the settings or the quick menu, or `/wl move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# WarlockPlan 1.0.0-beta3

- First version on CurseForge.

# WarlockPlan 1.0.0-beta2

- The real WarlockPlan logo and minimap icon.

# WarlockPlan 1.0.0-beta1

First version of WarlockPlan for WoW Forever.

- Talent plans for all three specs, checked against the live talent tree: **Affliction** (DoTs and drains, Nightfall, Siphon Life and Wrack), **Demonology** (pet, Soul Link, Master Demonologist and Demonic Pact) and **Destruction** (Ruin, Conflagrate, Shadow and Flame, Incinerate).
- Combat helper: calls out Shadow Trance (instant Shadow Bolt), Shadowburn on low targets, Decimation (fast Soul Fire) and Conflagrate, and reminds you of missing Corruption, Bane of Agony, Siphon Life or Immolate, Life Tap when mana is low and health high, a missing demon and running out of Soul Shards.
- Buff watcher for Demon Skin / Demon Armor and Soul Link, with the rebuff reminder.
- Upgrade check and quest reward picker with Shadow damage weights (Shadow and Fire for Destruction).
- Trainer list and rank check for every warlock spell, dungeon guide with warlock loot, profession assistant (Tailoring and Enchanting by default, pick any two), XP tracker, profiles and the emote easter eggs.
