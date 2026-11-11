# WarlockPlan 1.0.0-beta66

- **Icy Veins import:** links from the newer Icy Veins talent calculator work again. It now numbers the first talent of the first tree as "0", which the import didn't know, so those links were refused.

# WarlockPlan 1.0.0-beta65

- **Group bar:** in a party a small button trades your best healthstone. Each click opens a trade with your target, or the next party member in range who hasn't had one, and puts the stone in. When a party member opens a trade with you, it goes in by itself. You press Trade. Shift-drag to move, Ctrl + mouse wheel to resize, turn it off in the settings (Party marks) or with /wl groupbar.

# WarlockPlan 1.0.0-beta64

- **Rank check and controllers:** buttons above 180 (the controller's own button sets) are now only checked when "I use a controller" is ticked. It is no longer switched on by itself, so keyboard players stop getting an "old rank" on a button they can't see. When a controller button is flagged, the message now says "controller button 200".

# WarlockPlan 1.0.0-beta63

- **Ten new easter eggs** for friends who also run a Plan addon: /fart (a green cloud), /sing (music notes), /gasp or /surprised (a huge "!!"), /moo (bigger if one of you is a Tauren), /thank (hearts and gold stars), /charge ("LEEEROY!"), /violin (the world's smallest violin), /bow (a crown), /slap (a big fish) and /eat or /hungry (a cake).
- **Bigger together:** /hug at each other within 30 seconds for a group hug, kiss back within 10 seconds for two hearts, and when three or more Plan users in a party /drink within 30 seconds everyone gets a round ("Skål!").
- **By themselves:** a rain cloud when the whole party is dead, and a grand finale when you or a friend reach level 60.
- **Seasonal:** it snows with /wave in December, and /chicken lays a pumpkin around Halloween.
- New pictures were added, so this update needs a full game restart (not just /reload).

# WarlockPlan 1.0.0-beta62

- **Easter egg /drink:** the two mugs now clink glass to glass, with the handles pointing outwards (they used to bump handles).

# WarlockPlan 1.0.0-beta61

- **Settings window regrouped by feature:** every feature now has its on/off box first and its options right under it. Left: talent plan, professions, leveling and profiles. Middle: the combat helper (with size, alert style and sounds) and buffs and reminders (heads-up time and "drink at" next to their boxes). Right: gear and bags, party marks (button and pickers together) and look and windows. The buttons at the bottom are split into windows to open and actions.

# WarlockPlan 1.0.0-beta60

- **Shorter quick menu:** the menu on the minimap icon is now a short list: your spec, the windows to open (now with the bag check), and five switches: combat helper, move, buff watcher, party buffs and lock windows. Everything else is one click away under "All settings...".

# WarlockPlan 1.0.0-beta59

- **Buff watcher is off during boss fights:** the game hides buffs while a boss is engaged, so the buff row now shows nothing (no icons, no alerts) for the whole fight and comes back when it ends. Outside boss fights a missing party buff shows as before.
- **Stronger buff with another name:** a higher group buff from someone else (Gift of the Wild over your Mark of the Wild, Arcane Brilliance over Arcane Intellect, Prayer of Fortitude over Fortitude) is left alone until it runs out, like a higher rank of the same buff already was.
- **Bag check keeps white gear worth wearing:** white armor or a white weapon you can use is no longer listed for sale when the slot is empty, or when it has more armor (or weapon damage) than what you wear.

# WarlockPlan 1.0.0-beta58

- **Talent window with Daylight UI (and similar):** the yellow plan frames, green ticks and the next-talent glow now follow the window when you move it. They were anchored to Blizzard's hidden copy of the talent tree, which Daylight leaves at alpha 0 in the old spot; invisible buttons and windows are now skipped. `/wl talentui` also shows where the next talent's button is and which window holds it.

# WarlockPlan 1.0.0-beta57

- **Talent import:** Icy Veins and wow-forever-forge.com links are now the recommended ones in the import window, since they keep the order you clicked the talents in. The Icy Veins reading is verified for the whole Mage tree.

# WarlockPlan 1.0.0-beta56

- **Import from Icy Veins:** copy the address of your build from Icy Veins' WoW Forever talent calculator (the link with `#tc-...` at the end) and paste it into "Import talents" (or `/<slash> import <link>`). Like a forge link it keeps the order you clicked the talents in, so it becomes your leveling plan from level 10. Checked for Mage so far: a link that doesn't fit your class is refused with a message instead of being read wrongly, and the other classes are verified one by one as links come in.

# WarlockPlan 1.0.0-beta55

- **Import from talentsforever.com:** paste the link from "Copy link" on talentsforever.com into "Import talents" (or `/<slash> import <link>`) and it becomes your leveling plan, the same way as a Wowhead link: the tree with the most points is filled first, row by row.
- Fixed the `/<slash> rankcontroller` command showing as "CMD_rankcontroller" in the command list.

# WarlockPlan 1.0.0-beta54

- **Bag check for enchanters, take two:** items stay in the best-price group again (AH, sell or DE), but every row you can disenchant now also offers it: Alt-click disenchants instead (the row says "Sell/DE" or "AH/DE"). Away from a vendor, a plain click disenchants.

# WarlockPlan 1.0.0-beta53

- **Bag check for enchanters:** if you can disenchant an item (Enchanting skill high enough), it now always goes in the Disenchant group, even when a vendor or the AH would pay a little more. Click disenchants it; at a vendor, shift-click still sells it.

# WarlockPlan 1.0.0-beta52

- **Bag check sells white gear:** white (common) armor and weapons from drops now show up in the sell list at a vendor, unless the item would be an upgrade for you. Fishing poles, profession tools (Mining Pick, Skinning Knife, Blacksmith Hammer …), shirts and tabards are never offered. Right-click a row to keep an item.

# WarlockPlan 1.0.0-beta51

- **Buff watcher in boss fights, take two:** also notices the boss fight from the game's encounter events (for clients without IsEncounterInProgress), and a buff whose name the game hides counts as "can't tell" instead of "missing". `/wl buffdebug` now also lists what it can see of each party member's buffs.

# WarlockPlan 1.0.0-beta50

- **Buff watcher in boss fights:** at the pull the game hides other players' buffs, which made the buff row ask you to buff the whole party again. A buff you can't see during a boss fight now counts as "can't tell" instead of "missing".
- **Someone else's stronger buff:** when a higher-level player has put a higher rank of your buff on you or your party (a higher Mark of the Wild, Arcane Intellect, Fortitude …), the buff watcher leaves it alone until it runs out, since your weaker rank can't replace it. `/wl buffdebug` says when that is the case.
- **Rank check:** reads the spell rank on clients without C_Spell.GetSpellSubtext too.

# WarlockPlan 1.0.0-beta49

- **Talent window in replacement UIs (Daylight UI):** the yellow frames and green ticks now stay inside the talent window you actually see, instead of landing on Blizzard's hidden talent buttons elsewhere on the screen.

# WarlockPlan 1.0.0-beta48

- **Green tick on finished talents:** talents in your plan that you have taken all the planned points in now get a small green tick in the top right corner in the talent window, beside the icon so you still see which talent it is. Yellow frames still show what's left and the green frame and arrow the next one.

# WarlockPlan 1.0.0-beta47

- **Yellow talent frames follow your plan:** switching plans or reopening the talent window could leave frames from an earlier plan on the wrong talents. Each frame is now placed fresh every time, and one talent that can't be found no longer stops the rest. /wl talentui lists the planned talents by name.

# WarlockPlan 1.0.0-beta46

- **Yellow frames on the talent tree now show:** the frames for the rest of your plan didn't appear because of a bug in how the plan was read. Fixed. /wl talentui also lists what the check sees.

# WarlockPlan 1.0.0-beta45

- **The whole plan on the talent tree:** besides the green frame and arrow on your next talent, every other talent in your plan that you haven't taken yet now gets a yellow frame in the talent window, so you can see where the build is heading. Talents you skip or have finished lose their frame.

# WarlockPlan 1.0.0-beta44

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /wl ranks controller on|off|auto) overrides the detection.

# WarlockPlan 1.0.0-beta43

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# WarlockPlan 1.0.0-beta42

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /wl ranks debug lists where each spell was found.

# WarlockPlan 1.0.0-beta41

- **Import Wowhead talent links too:** "Import talents" (or /wl import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# WarlockPlan 1.0.0-beta40

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /wl import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /wl import clear) takes it away.

# WarlockPlan 1.0.0-beta39

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /wl skip) to skip that talent, for example when you already put those points somewhere else. /wl skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# WarlockPlan 1.0.0-beta38

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# WarlockPlan 1.0.0-beta37

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# WarlockPlan 1.0.0-beta36

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /wl marks) turns the feature on or off.

# WarlockPlan 1.0.0-beta35

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

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
