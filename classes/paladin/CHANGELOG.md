# PaladinPlan 1.15.4

- **Icy Veins import fixed for every class:** the addon now uses Icy Veins' own numbering for each talent, read straight from their talent calculator. Before, it guessed the numbering row by row, which was wrong for Paladin, Rogue, Warrior, Druid, Shaman and Hunter, so links like a 0/35/16 Paladin build were refused.

# PaladinPlan 1.15.3

- **Icy Veins import:** links from the newer Icy Veins talent calculator work again. It now numbers the first talent of the first tree as "0", which the import didn't know, so those links were refused.

# PaladinPlan 1.15.2

- Groundwork for the group bar (class tools in a party, first for Mage and Warlock). Nothing changes for Paladins yet.

# PaladinPlan 1.15.1

- **Rank check and controllers:** buttons above 180 (the controller's own button sets) are now only checked when "I use a controller" is ticked. It is no longer switched on by itself, so keyboard players stop getting an "old rank" on a button they can't see. When a controller button is flagged, the message now says "controller button 200".

# PaladinPlan 1.15.0

- **Ten new easter eggs** for friends who also run a Plan addon: /fart (a green cloud), /sing (music notes), /gasp or /surprised (a huge "!!"), /moo (bigger if one of you is a Tauren), /thank (hearts and gold stars), /charge ("LEEEROY!"), /violin (the world's smallest violin), /bow (a crown), /slap (a big fish) and /eat or /hungry (a cake).
- **Bigger together:** /hug at each other within 30 seconds for a group hug, kiss back within 10 seconds for two hearts, and when three or more Plan users in a party /drink within 30 seconds everyone gets a round ("Skål!").
- **By themselves:** a rain cloud when the whole party is dead, and a grand finale when you or a friend reach level 60.
- **Seasonal:** it snows with /wave in December, and /chicken lays a pumpkin around Halloween.
- New pictures were added, so this update needs a full game restart (not just /reload).

# PaladinPlan 1.14.1

- **Easter egg /drink:** the two mugs now clink glass to glass, with the handles pointing outwards (they used to bump handles).

# PaladinPlan 1.14.0

- **Settings window regrouped by feature:** every feature now has its on/off box first and its options right under it. Left: talent plan, professions, leveling and profiles. Middle: the combat helper (with size, alert style and sounds) and buffs and reminders (heads-up time and "drink at" next to their boxes). Right: gear and bags, party marks (button and pickers together) and look and windows. The buttons at the bottom are split into windows to open and actions.

# PaladinPlan 1.13.1

- **Shorter quick menu:** the menu on the minimap icon is now a short list: your spec, the windows to open (now with the bag check), and five switches: combat helper, move, buff watcher, party buffs and lock windows. Everything else is one click away under "All settings...".

# PaladinPlan 1.13.0

- **Buff watcher is off during boss fights:** the game hides buffs while a boss is engaged, so the buff row now shows nothing (no icons, no alerts) for the whole fight and comes back when it ends. Outside boss fights a missing party buff shows as before.
- **Stronger buff with another name:** a higher group buff from someone else (Gift of the Wild over your Mark of the Wild, Arcane Brilliance over Arcane Intellect, Prayer of Fortitude over Fortitude) is left alone until it runs out, like a higher rank of the same buff already was.
- **Bag check keeps white gear worth wearing:** white armor or a white weapon you can use is no longer listed for sale when the slot is empty, or when it has more armor (or weapon damage) than what you wear.

# PaladinPlan 1.12.2

- **Talent window with Daylight UI (and similar):** the yellow plan frames, green ticks and the next-talent glow now follow the window when you move it. They were anchored to Blizzard's hidden copy of the talent tree, which Daylight leaves at alpha 0 in the old spot; invisible buttons and windows are now skipped. `/pal talentui` also shows where the next talent's button is and which window holds it.

# PaladinPlan 1.12.1

- **Talent import:** Icy Veins and wow-forever-forge.com links are now the recommended ones in the import window, since they keep the order you clicked the talents in. The Icy Veins reading is verified for the whole Mage tree.

# PaladinPlan 1.12.0

- **Import from Icy Veins:** copy the address of your build from Icy Veins' WoW Forever talent calculator (the link with `#tc-...` at the end) and paste it into "Import talents" (or `/<slash> import <link>`). Like a forge link it keeps the order you clicked the talents in, so it becomes your leveling plan from level 10. Checked for Mage so far: a link that doesn't fit your class is refused with a message instead of being read wrongly, and the other classes are verified one by one as links come in.

# PaladinPlan 1.11.0

- **Import from talentsforever.com:** paste the link from "Copy link" on talentsforever.com into "Import talents" (or `/<slash> import <link>`) and it becomes your leveling plan, the same way as a Wowhead link: the tree with the most points is filled first, row by row.
- Fixed the `/<slash> rankcontroller` command showing as "CMD_rankcontroller" in the command list.

# PaladinPlan 1.10.4

- **Bag check for enchanters, take two:** items stay in the best-price group again (AH, sell or DE), but every row you can disenchant now also offers it: Alt-click disenchants instead (the row says "Sell/DE" or "AH/DE"). Away from a vendor, a plain click disenchants.

# PaladinPlan 1.10.3

- **Bag check for enchanters:** if you can disenchant an item (Enchanting skill high enough), it now always goes in the Disenchant group, even when a vendor or the AH would pay a little more. Click disenchants it; at a vendor, shift-click still sells it.

# PaladinPlan 1.10.2

- **Bag check sells white gear:** white (common) armor and weapons from drops now show up in the sell list at a vendor, unless the item would be an upgrade for you. Fishing poles, profession tools (Mining Pick, Skinning Knife, Blacksmith Hammer …), shirts and tabards are never offered. Right-click a row to keep an item.

# PaladinPlan 1.10.1

- **Buff watcher in boss fights, take two:** also notices the boss fight from the game's encounter events (for clients without IsEncounterInProgress), and a buff whose name the game hides counts as "can't tell" instead of "missing". `/pal buffdebug` now also lists what it can see of each party member's buffs.

# PaladinPlan 1.10.0

- **Buff watcher in boss fights:** at the pull the game hides other players' buffs, which made the buff row ask you to buff the whole party again. A buff you can't see during a boss fight now counts as "can't tell" instead of "missing".
- **Someone else's stronger buff:** when a higher-level player has put a higher rank of your buff on you or your party (a higher Mark of the Wild, Arcane Intellect, Fortitude …), the buff watcher leaves it alone until it runs out, since your weaker rank can't replace it. `/pal buffdebug` says when that is the case.
- **Rank check:** reads the spell rank on clients without C_Spell.GetSpellSubtext too.

# PaladinPlan 1.9.1

- **Talent window in replacement UIs (Daylight UI):** the yellow frames and green ticks now stay inside the talent window you actually see, instead of landing on Blizzard's hidden talent buttons elsewhere on the screen.

# PaladinPlan 1.9.0

- **Green tick on finished talents:** talents in your plan that you have taken all the planned points in now get a small green tick in the top right corner in the talent window, beside the icon so you still see which talent it is. Yellow frames still show what's left and the green frame and arrow the next one.

# PaladinPlan 1.8.2

- **Yellow talent frames follow your plan:** switching plans or reopening the talent window could leave frames from an earlier plan on the wrong talents. Each frame is now placed fresh every time, and one talent that can't be found no longer stops the rest. /pal talentui lists the planned talents by name.

# PaladinPlan 1.8.1

- **Yellow frames on the talent tree now show:** the frames for the rest of your plan didn't appear because of a bug in how the plan was read. Fixed. /pal talentui also lists what the check sees.

# PaladinPlan 1.8.0

- **The whole plan on the talent tree:** besides the green frame and arrow on your next talent, every other talent in your plan that you haven't taken yet now gets a yellow frame in the talent window, so you can see where the build is heading. Talents you skip or have finished lose their frame.

# PaladinPlan 1.7.1

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /pal ranks controller on|off|auto) overrides the detection.

# PaladinPlan 1.7.0

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# PaladinPlan 1.6.2

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /pal ranks debug lists where each spell was found.

# PaladinPlan 1.6.1

- **Import Wowhead talent links too:** "Import talents" (or /pal import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# PaladinPlan 1.6.0

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /pal import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /pal import clear) takes it away.

# PaladinPlan 1.5.0

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /pal skip) to skip that talent, for example when you already put those points somewhere else. /pal skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# PaladinPlan 1.4.4

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# PaladinPlan 1.4.3

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# PaladinPlan 1.4.2

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /pal marks) turns the feature on or off.

# PaladinPlan 1.4.1

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# PaladinPlan 1.4.0

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# PaladinPlan 1.3.5

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# PaladinPlan 1.3.4

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# PaladinPlan 1.3.3

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# PaladinPlan 1.3.2

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# PaladinPlan 1.3.1

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# PaladinPlan 1.3.0

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# PaladinPlan 1.2.1

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# PaladinPlan 1.2.0

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# PaladinPlan 1.1.0

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# PaladinPlan 1.0.0

- **First stable release.** Thanks to everyone who played the betas and reported bugs. Same features as the last beta.

# PaladinPlan 1.0.0-beta44

- **Rank check can be quiet:** untick "Rank check messages in chat" under Leveling in the settings (or `/pal rankchat`). `/pal ranks` still checks your bars when you ask.
- The rank check no longer repeats the same list in chat every time your bars change.
- **Controllers:** spells bound straight to a key or a controller button now count as "on a button", and the check also looks at the extra bar pages (slots 121-180) that controller and bar addons use.

# PaladinPlan 1.0.0-beta43

- **Bag check button on your bags:** a small disenchant icon above your open bags opens the bag check. Works with the normal bags and with Baganator, Bagnon, AdiBags, ArkInventory, BetterBags and ElvUI bags. Turn it off with "Bag check button on your bags" in the settings.
- **Middle-click the minimap icon** to open the bag check.

# PaladinPlan 1.0.0-beta42

- **Fix: the bag check opened behind the settings window**, so clicking "Bag check" there looked like it did nothing. It now opens on top.

# PaladinPlan 1.0.0-beta41

- The Walk on Air timer setting only shows on Skyborne characters (High Order and Windshaper), since nobody else has the racial.

# PaladinPlan 1.0.0-beta40

- **Fix: a missing buff could stay hidden** when the game hides the aura list (secret values in WoW Forever). The buff watcher now asks for the buff by name, so the icon shows up again (for you and your party).
- **Fix: the dance party didn't always start** when you /dance at each other. Now whoever dances back starts it for both of you, and you have 30 seconds (it used to be 10).
- The buff icons' tooltip tells you when "Move" is on, since a click doesn't cast then.
- New: `/pal buffdebug` shows why a buff icon does or doesn't show.

# PaladinPlan 1.0.0-beta39

- **Bag check window** (`/pal de`, or "Bag check" in the settings): lists the junk, gear to vendor, gear to disenchant and gear worth more on the AH in your bags, with what each is worth.
- **Sell and disenchant from it:** with a vendor open, click a row to sell it, or press "Sell junk and vendor items" (12 at a time, so you can still buy them back). With Enchanting, click a row to disenchant it. Shift-click sells anything to the vendor anyway.
- **Keep items:** right-click a row and that item is never sold or disenchanted from the window.
- Opens by itself when you talk to a vendor and have something to sell (turn it off with "Open the bag check at vendors").
- The sell / disenchant / AH advice in item tooltips now comes with every Plan addon (turn it off under "Gear and quests").

# PaladinPlan 1.0.0-beta38

- **Fix: clicking a party member's buff icon could buff you instead** when they were out of range (the game's auto self-cast). The range now uses the buff spell's own range (30 yards, not the 40-yard party range); out of range the icon is faded, says so in its tooltip and a click does nothing; and the click names its target, so the game can never put it on you.

# PaladinPlan 1.0.0-beta37

- **Choose which buffs to watch:** a new "Buffs and reminders" group in the settings (and the quick menu) has the buff watcher, a tick box for every buff it watches (and for your party buff), and the drink reminder. Untick a buff and its icon never shows.

# PaladinPlan 1.0.0-beta36

- **Fix: the drink alert never showed on WoW Forever.** Forever hides your current mana from addons, so the addon couldn't tell you were low. Now the addon gives the game a rule ("show below your drink %") and the game shows or hides the alert itself, the official way to handle hidden values.

# PaladinPlan 1.0.0-beta35

- Drink alert: reports problems in chat instead of failing silently, and `/pal drinktest` shows what it sees (for bug reports).

# PaladinPlan 1.0.0-beta34

- **Real drink alert:** low mana out of combat now shows a big "Drink! Mana 23%" with a drink icon in the middle of the screen, like the combat helper's call-outs, with a short flash and the alert sound (when sounds are on for all reminders). It hides in combat, while you drink and when you're full. Move it with the "Move" switch, mouse wheel for size.

# PaladinPlan 1.0.0-beta33

- **Pick a blessing per player:** right-click a blessing icon in the buff watcher (yours or a party member's) to cycle Auto, Wisdom, Might, Kings, Salvation and the others you know. The addon remembers it by name, so Jennie always gets Wisdom and your warrior friend always gets Might. With a pick, only that blessing counts; on Auto it's Wisdom for mana users, Might for the rest, and any blessing counts. Left-click still casts it.

# PaladinPlan 1.0.0-beta32

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
- **Easter eggs on/off:** a new box under Fun in the settings (or `/pal eggs`) turns all of it off.

# PaladinPlan 1.0.0-beta31

- **Party buffs:** the buff watcher also shows your party members who are missing your buff (a blessing on everyone: Wisdom for mana users, Might for the rest, and any blessing counts), one icon each with their name on it. Click the icon to cast it on them; it's faded when they're out of range. Turn it on or off with "Buff my party too" under Combat and buffs.

# PaladinPlan 1.0.0-beta30

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# PaladinPlan 1.0.0-beta29

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# PaladinPlan 1.0.0-beta28

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/pal secondary` steps through the choices.

# PaladinPlan 1.0.0-beta27

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/pal secondary`.

# PaladinPlan 1.0.0-beta26

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/pal glide`.

# PaladinPlan 1.0.0-beta25

- **Separate lock for the buff row:** the buff watcher now moves with the combat helper ("Move combat helper & buffs" in the settings or the quick menu, or `/pal move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# PaladinPlan 1.0.0-beta24

- **Fix: action bars disappearing or moving in combat** ("Interface action failed"/blocked actions). The addon no longer opens Blizzard's talent window itself, never attaches its talent arrow, hint or map pin to Blizzard's windows, and no longer closes Blizzard's settings window. Those could "taint" the game's own UI so it got blocked in combat. To see the next talent, open your talents with N as usual: the green arrow is still there.

# PaladinPlan 1.0.0-beta23

- **Fix:** the rank check could say "your bars look good" with an old rank on a button (e.g. an older rank of a spell), because Forever often hides the rank text. It now also compares the level each rank is learned at, and the mana cost, so old ranks are found anyway. `/pal ranks debug` shows what it sees for every button.

# PaladinPlan 1.0.0-beta22

- **Fix:** the talent arrow could point at a Spellbook tab (e.g. the Frost tab) when you opened the Spellbook, because its icon looks like a talent's. It now only marks talents while the Talents tab is showing.

# PaladinPlan 1.0.0-beta21

- **Rebuff reminder:** out of combat the buff watcher now warns you early, by default when a buff has **3 minutes left** (e.g. Frost Armor). A line above the icons says "Rebuff soon: Frost Armor (2:59 left)", the icon pulses, and you hear the alert sound if sounds are on. Click the icon to rebuff. Pick 1, 2, 3, 5 or 10 minutes, or off, under "Rebuff reminder" in the settings. Short buffs warn at a third of their length so they don't nag right after you cast them. In combat it still only warns at the last minute.

# PaladinPlan 1.0.0-beta20

- **Easier to move the buff watcher:** unlock windows and the row now shows all your watched buffs (faded when they're up), so you can always find it. Drag it by any icon, Ctrl + mouse wheel to resize. Clicking doesn't cast while it's unlocked.

# PaladinPlan 1.0.0-beta19

- **Buff watcher:** a row of icons that appears when one of your buffs is missing (red frame) or about to run out (yellow frame, with time left). **Click an icon to cast the buff.** Drag it where you want it while windows are unlocked, and use Ctrl + mouse wheel to resize it. Turn it on or off under Features or with the quick menu. Watches your aura (the one you picked, or any on Auto), a blessing and Righteous Fury (Protection).

# PaladinPlan 1.0.0-beta18

- **DialogueUI support:** when you hover a quest reward in DialogueUI, its tooltip now shows "+ Best upgrade" and "$ Sells for the most" too.

# PaladinPlan 1.0.0-beta17

- **Quest rewards, two marks:** a green **+** on the reward that is your biggest upgrade, and a gold **$** on the one that sells for the most at a vendor. One item can get both. Chat says which is which.
- Works with quest dialog addons (DialogueUI, Immersion, ...) too: hover a reward and the tooltip says "+ Best upgrade" or "$ Sells for the most".

# PaladinPlan 1.0.0-beta16

- **Alerts with icons:** every combat helper alert now shows the icon of the spell it is about, for example the Devotion Aura icon next to "No aura", or the Overpower icon next to "OVERPOWER!".
- New **Alert style** setting (settings window → Plan and look): *Icon + text*, *Icons only* (big icons side by side, no text) or *Text only*. It's saved in your profile.

# PaladinPlan 1.0.0-beta15

- **Aura reminder any time:** "No aura - turn on Devotion Aura" (or the aura you picked) now shows whenever no aura is on, not only in combat. It stays quiet while you are mounted, on a flight path or dead.
- The combat helper shows up to three reminders at once, so one no longer hides another (Righteous Fury, aura, seal, blessing).
- Talent marker: a big green arrow now points down at the next talent.

# PaladinPlan 1.0.0-beta14

- **Clearer talent marker:** the next talent in your plan now gets a thick green frame that pulses, with a big green arrow bobbing above it. The old faint blue glow is gone, and so is the flicker.

# PaladinPlan 1.0.0-beta13

- Talent window: the glow now shows up when the window was already open, and stays on the right talent while you click around. The "next talent" line sits at the bottom of the window.

# PaladinPlan 1.0.0-beta12

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# PaladinPlan 1.0.0-beta11

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# PaladinPlan 1.0.0-beta10

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# PaladinPlan 1.0.0-beta9

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# PaladinPlan 1.0.0-beta8

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# PaladinPlan 1.0.0-beta7

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# PaladinPlan 1.0.0-beta6

- Pick your aura in the settings window or the quick menu: Auto (by spec) or any aura you know. The combat helper then reminds you to turn that aura on, also when another aura is active.

# PaladinPlan 1.0.0-beta5

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# PaladinPlan 1.0.0-beta4

- New: the combat helper reminds you when no aura is on, and suggests Devotion Aura (Retribution Aura for Retribution).
- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# PaladinPlan 1.0.0-beta3

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# PaladinPlan 1.0.0-beta2

- Plate armor shows "usable at level 40" in the upgrade check until you can wear it, and the quest reward picker skips it.
- Shields now get the upgrade check too (they were never compared before).
- Fury and other dual wielders: a one-hand weapon is compared with the weaker of your two weapons.
- Talent window: one odd frame can no longer stop the search for the talent to mark.
- Hammer of Wrath is called out even when the game hides your target's health.

# PaladinPlan 1.0.0-beta1

First beta of PaladinPlan, the paladin leveling companion for WoW Forever.

- Pick your spec in the settings window (or `/pal plan`): **Protection** (tank), **Retribution** (two-hander) or **Holy** (healer). The talent plan, the upgrade check and the combat helper follow the spec.
- Talent plans for all three specs, checked against the live talent tree.
- Combat helper: Hammer of Wrath and Exorcism call-outs, plus Righteous Fury (Protection), seal, blessing and Holy Shield reminders.
- Upgrade check and quest reward picker with tank weights for Protection, strength and weapon weights for Retribution and healing weights for Holy.
- Trainer list and rank check for every paladin spell.
- Dungeon guide with paladin loot, profession assistant (Blacksmithing and Mining by default, pick any two), XP tracker, profiles and the emote easter eggs.
