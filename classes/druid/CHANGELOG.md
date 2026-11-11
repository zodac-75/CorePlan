# DruidPlan 1.14.1

- **Rank check and controllers:** buttons above 180 (the controller's own button sets) are now only checked when "I use a controller" is ticked. It is no longer switched on by itself, so keyboard players stop getting an "old rank" on a button they can't see. When a controller button is flagged, the message now says "controller button 200".

# DruidPlan 1.14.0

- **Ten new easter eggs** for friends who also run a Plan addon: /fart (a green cloud), /sing (music notes), /gasp or /surprised (a huge "!!"), /moo (bigger if one of you is a Tauren), /thank (hearts and gold stars), /charge ("LEEEROY!"), /violin (the world's smallest violin), /bow (a crown), /slap (a big fish) and /eat or /hungry (a cake).
- **Bigger together:** /hug at each other within 30 seconds for a group hug, kiss back within 10 seconds for two hearts, and when three or more Plan users in a party /drink within 30 seconds everyone gets a round ("Skål!").
- **By themselves:** a rain cloud when the whole party is dead, and a grand finale when you or a friend reach level 60.
- **Seasonal:** it snows with /wave in December, and /chicken lays a pumpkin around Halloween.
- New pictures were added, so this update needs a full game restart (not just /reload).

# DruidPlan 1.13.1

- **Easter egg /drink:** the two mugs now clink glass to glass, with the handles pointing outwards (they used to bump handles).

# DruidPlan 1.13.0

- **Settings window regrouped by feature:** every feature now has its on/off box first and its options right under it. Left: talent plan, professions, leveling and profiles. Middle: the combat helper (with size, alert style and sounds) and buffs and reminders (heads-up time and "drink at" next to their boxes). Right: gear and bags, party marks (button and pickers together) and look and windows. The buttons at the bottom are split into windows to open and actions.

# DruidPlan 1.12.1

- **Shorter quick menu:** the menu on the minimap icon is now a short list: your spec, the windows to open (now with the bag check), and five switches: combat helper, move, buff watcher, party buffs and lock windows. Everything else is one click away under "All settings...".

# DruidPlan 1.12.0

- **Buff watcher is off during boss fights:** the game hides buffs while a boss is engaged, so the buff row now shows nothing (no icons, no alerts) for the whole fight and comes back when it ends. Outside boss fights a missing party buff shows as before.
- **Stronger buff with another name:** a higher group buff from someone else (Gift of the Wild over your Mark of the Wild, Arcane Brilliance over Arcane Intellect, Prayer of Fortitude over Fortitude) is left alone until it runs out, like a higher rank of the same buff already was.
- **Bag check keeps white gear worth wearing:** white armor or a white weapon you can use is no longer listed for sale when the slot is empty, or when it has more armor (or weapon damage) than what you wear.

# DruidPlan 1.11.2

- **Talent window with Daylight UI (and similar):** the yellow plan frames, green ticks and the next-talent glow now follow the window when you move it. They were anchored to Blizzard's hidden copy of the talent tree, which Daylight leaves at alpha 0 in the old spot; invisible buttons and windows are now skipped. `/dp talentui` also shows where the next talent's button is and which window holds it.

# DruidPlan 1.11.1

- **Talent import:** Icy Veins and wow-forever-forge.com links are now the recommended ones in the import window, since they keep the order you clicked the talents in. The Icy Veins reading is verified for the whole Mage tree.

# DruidPlan 1.11.0

- **Import from Icy Veins:** copy the address of your build from Icy Veins' WoW Forever talent calculator (the link with `#tc-...` at the end) and paste it into "Import talents" (or `/<slash> import <link>`). Like a forge link it keeps the order you clicked the talents in, so it becomes your leveling plan from level 10. Checked for Mage so far: a link that doesn't fit your class is refused with a message instead of being read wrongly, and the other classes are verified one by one as links come in.

# DruidPlan 1.10.0

- **Import from talentsforever.com:** paste the link from "Copy link" on talentsforever.com into "Import talents" (or `/<slash> import <link>`) and it becomes your leveling plan, the same way as a Wowhead link: the tree with the most points is filled first, row by row.
- Fixed the `/<slash> rankcontroller` command showing as "CMD_rankcontroller" in the command list.

# DruidPlan 1.9.2

- **Balance gear score:** Intellect and Spirit were valued as if they gave spell power (thanks Ebemidej). They don't in WoW Forever, so Balance now weighs them far lower and spell power, crit, hit and mp5 count for more in the upgrade check.

# DruidPlan 1.10.4

- **Bag check for enchanters, take two:** items stay in the best-price group again (AH, sell or DE), but every row you can disenchant now also offers it: Alt-click disenchants instead (the row says "Sell/DE" or "AH/DE"). Away from a vendor, a plain click disenchants.

# DruidPlan 1.10.3

- **Bag check for enchanters:** if you can disenchant an item (Enchanting skill high enough), it now always goes in the Disenchant group, even when a vendor or the AH would pay a little more. Click disenchants it; at a vendor, shift-click still sells it.

# DruidPlan 1.10.2

- **Bag check sells white gear:** white (common) armor and weapons from drops now show up in the sell list at a vendor, unless the item would be an upgrade for you. Fishing poles, profession tools (Mining Pick, Skinning Knife, Blacksmith Hammer …), shirts and tabards are never offered. Right-click a row to keep an item.

# DruidPlan 1.10.1

- **Buff watcher in boss fights, take two:** also notices the boss fight from the game's encounter events (for clients without IsEncounterInProgress), and a buff whose name the game hides counts as "can't tell" instead of "missing". `/dp buffdebug` now also lists what it can see of each party member's buffs.

# DruidPlan 1.10.0

- **Buff watcher in boss fights:** at the pull the game hides other players' buffs, which made the buff row ask you to buff the whole party again. A buff you can't see during a boss fight now counts as "can't tell" instead of "missing".
- **Someone else's stronger buff:** when a higher-level player has put a higher rank of your buff on you or your party (a higher Mark of the Wild, Arcane Intellect, Fortitude …), the buff watcher leaves it alone until it runs out, since your weaker rank can't replace it. `/dp buffdebug` says when that is the case.
- **Rank check:** reads the spell rank on clients without C_Spell.GetSpellSubtext too.

# DruidPlan 1.9.1

- **Talent window in replacement UIs (Daylight UI):** the yellow frames and green ticks now stay inside the talent window you actually see, instead of landing on Blizzard's hidden talent buttons elsewhere on the screen.

# DruidPlan 1.9.0

- **Green tick on finished talents:** talents in your plan that you have taken all the planned points in now get a small green tick in the top right corner in the talent window, beside the icon so you still see which talent it is. Yellow frames still show what's left and the green frame and arrow the next one.

# DruidPlan 1.8.2

- **Yellow talent frames follow your plan:** switching plans or reopening the talent window could leave frames from an earlier plan on the wrong talents. Each frame is now placed fresh every time, and one talent that can't be found no longer stops the rest. /dp talentui lists the planned talents by name.

# DruidPlan 1.8.1

- **Yellow frames on the talent tree now show:** the frames for the rest of your plan didn't appear because of a bug in how the plan was read. Fixed. /dp talentui also lists what the check sees.

# DruidPlan 1.8.0

- **The whole plan on the talent tree:** besides the green frame and arrow on your next talent, every other talent in your plan that you haven't taken yet now gets a yellow frame in the talent window, so you can see where the build is heading. Talents you skip or have finished lose their frame.

# DruidPlan 1.7.1

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /dp ranks controller on|off|auto) overrides the detection.

# DruidPlan 1.7.0

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# DruidPlan 1.6.2

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /dp ranks debug lists where each spell was found.

# DruidPlan 1.6.1

- **Import Wowhead talent links too:** "Import talents" (or /dp import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# DruidPlan 1.6.0

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /dp import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /dp import clear) takes it away.

# DruidPlan 1.5.0

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /dp skip) to skip that talent, for example when you already put those points somewhere else. /dp skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# DruidPlan 1.4.4

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# DruidPlan 1.4.3

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# DruidPlan 1.4.2

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /dp marks) turns the feature on or off.

# DruidPlan 1.4.1

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# DruidPlan 1.4.0

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# DruidPlan 1.3.5

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# DruidPlan 1.3.4

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# DruidPlan 1.3.3

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# DruidPlan 1.3.2

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# DruidPlan 1.3.1

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# DruidPlan 1.3.0

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# DruidPlan 1.2.1

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# DruidPlan 1.2.0

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# DruidPlan 1.1.0

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# DruidPlan 1.0.0

- **First stable release.** Thanks to everyone who played the betas and reported bugs. Same features as the last beta.

# DruidPlan 1.0.0-beta51

- **Fix: Omen of Clarity no longer shows in the buff watcher.** It's passive in WoW Forever, so there was nothing to click and the icon kept flashing red.

# DruidPlan 1.0.0-beta50

- **Rank check can be quiet:** untick "Rank check messages in chat" under Leveling in the settings (or `/dp rankchat`). `/dp ranks` still checks your bars when you ask.
- The rank check no longer repeats the same list in chat every time your bars change.
- **Controllers:** spells bound straight to a key or a controller button now count as "on a button", and the check also looks at the extra bar pages (slots 121-180) that controller and bar addons use.

# DruidPlan 1.0.0-beta49

- **Bag check button on your bags:** a small disenchant icon above your open bags opens the bag check. Works with the normal bags and with Baganator, Bagnon, AdiBags, ArkInventory, BetterBags and ElvUI bags. Turn it off with "Bag check button on your bags" in the settings.
- **Middle-click the minimap icon** to open the bag check.

# DruidPlan 1.0.0-beta48

- **Fix: the bag check opened behind the settings window**, so clicking "Bag check" there looked like it did nothing. It now opens on top.

# DruidPlan 1.0.0-beta47

- The Walk on Air timer setting only shows on Skyborne characters (High Order and Windshaper), since nobody else has the racial.

# DruidPlan 1.0.0-beta46

- **Fix: a missing buff could stay hidden** when the game hides the aura list (secret values in WoW Forever). The buff watcher now asks for the buff by name, so the icon shows up again (for you and your party).
- **Fix: the dance party didn't always start** when you /dance at each other. Now whoever dances back starts it for both of you, and you have 30 seconds (it used to be 10).
- The buff icons' tooltip tells you when "Move" is on, since a click doesn't cast then.
- New: `/dp buffdebug` shows why a buff icon does or doesn't show.

# DruidPlan 1.0.0-beta45

- **Bag check window** (`/dp de`, or "Bag check" in the settings): lists the junk, gear to vendor, gear to disenchant and gear worth more on the AH in your bags, with what each is worth.
- **Sell and disenchant from it:** with a vendor open, click a row to sell it, or press "Sell junk and vendor items" (12 at a time, so you can still buy them back). With Enchanting, click a row to disenchant it. Shift-click sells anything to the vendor anyway.
- **Keep items:** right-click a row and that item is never sold or disenchanted from the window.
- Opens by itself when you talk to a vendor and have something to sell (turn it off with "Open the bag check at vendors").
- The sell / disenchant / AH advice in item tooltips now comes with every Plan addon (turn it off under "Gear and quests").

# DruidPlan 1.0.0-beta44

- **Fix: clicking a party member's buff icon could buff you instead** when they were out of range (the game's auto self-cast). The range now uses the buff spell's own range (30 yards, not the 40-yard party range); out of range the icon is faded, says so in its tooltip and a click does nothing; and the click names its target, so the game can never put it on you.

# DruidPlan 1.0.0-beta43

- **Choose which buffs to watch:** a new "Buffs and reminders" group in the settings (and the quick menu) has the buff watcher, a tick box for every buff it watches (and for your party buff), and the drink reminder. Untick a buff and its icon never shows.

# DruidPlan 1.0.0-beta42

- **Fix: the drink alert never showed on WoW Forever.** Forever hides your current mana from addons, so the addon couldn't tell you were low. Now the addon gives the game a rule ("show below your drink %") and the game shows or hides the alert itself, the official way to handle hidden values.

# DruidPlan 1.0.0-beta41

- Drink alert: reports problems in chat instead of failing silently, and `/dp drinktest` shows what it sees (for bug reports).

# DruidPlan 1.0.0-beta40

- **Real drink alert:** low mana out of combat now shows a big "Drink! Mana 23%" with a drink icon in the middle of the screen, like the combat helper's call-outs, with a short flash and the alert sound (when sounds are on for all reminders). It hides in combat, while you drink and when you're full. Move it with the "Move" switch, mouse wheel for size.

# DruidPlan 1.0.0-beta39

- Buff watcher: right-click support for icons that have a choice (used by PaladinPlan's blessings).

# DruidPlan 1.0.0-beta38

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
- **Easter eggs on/off:** a new box under Fun in the settings (or `/dp eggs`) turns all of it off.

# DruidPlan 1.0.0-beta37

- **Party buffs:** the buff watcher also shows your party members who are missing your buff (Mark of the Wild on everyone), one icon each with their name on it. Click the icon to cast it on them; it's faded when they're out of range. Turn it on or off with "Buff my party too" under Combat and buffs.

# DruidPlan 1.0.0-beta36

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# DruidPlan 1.0.0-beta35

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# DruidPlan 1.0.0-beta34

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/dp secondary` steps through the choices.

# DruidPlan 1.0.0-beta33

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/dp secondary`.

# DruidPlan 1.0.0-beta32

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/dp glide`.

# DruidPlan 1.0.0-beta31

- **Separate lock for the buff row:** the buff watcher now moves with the combat helper ("Move combat helper & buffs" in the settings or the quick menu, or `/dp move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# DruidPlan 1.0.0-beta30

- **Fix: action bars disappearing or moving in combat** ("Interface action failed"/blocked actions). The addon no longer opens Blizzard's talent window itself, never attaches its talent arrow, hint or map pin to Blizzard's windows, and no longer closes Blizzard's settings window. Those could "taint" the game's own UI so it got blocked in combat. To see the next talent, open your talents with N as usual: the green arrow is still there.

# DruidPlan 1.0.0-beta29

- **Fix:** the rank check could say "your bars look good" with an old rank on a button (e.g. an older rank of a spell), because Forever often hides the rank text. It now also compares the level each rank is learned at, and the mana cost, so old ranks are found anyway. `/dp ranks debug` shows what it sees for every button.

# DruidPlan 1.0.0-beta28

- **Fix:** the talent arrow could point at a Spellbook tab (e.g. the Frost tab) when you opened the Spellbook, because its icon looks like a talent's. It now only marks talents while the Talents tab is showing.

# DruidPlan 1.0.0-beta27

- **Rebuff reminder:** out of combat the buff watcher now warns you early, by default when a buff has **3 minutes left** (e.g. Frost Armor). A line above the icons says "Rebuff soon: Frost Armor (2:59 left)", the icon pulses, and you hear the alert sound if sounds are on. Click the icon to rebuff. Pick 1, 2, 3, 5 or 10 minutes, or off, under "Rebuff reminder" in the settings. Short buffs warn at a third of their length so they don't nag right after you cast them. In combat it still only warns at the last minute.

# DruidPlan 1.0.0-beta26

- **Easier to move the buff watcher:** unlock windows and the row now shows all your watched buffs (faded when they're up), so you can always find it. Drag it by any icon, Ctrl + mouse wheel to resize. Clicking doesn't cast while it's unlocked.

# DruidPlan 1.0.0-beta25

- **Buff watcher:** a row of icons that appears when one of your buffs is missing (red frame) or about to run out (yellow frame, with time left). **Click an icon to cast the buff.** Drag it where you want it while windows are unlocked, and use Ctrl + mouse wheel to resize it. Turn it on or off under Features or with the quick menu. Watches Mark of the Wild, Thorns and Omen of Clarity.

# DruidPlan 1.0.0-beta24

- **DialogueUI support:** when you hover a quest reward in DialogueUI, its tooltip now shows "+ Best upgrade" and "$ Sells for the most" too.

# DruidPlan 1.0.0-beta23

- **Quest rewards, two marks:** a green **+** on the reward that is your biggest upgrade, and a gold **$** on the one that sells for the most at a vendor. One item can get both. Chat says which is which.
- Works with quest dialog addons (DialogueUI, Immersion, ...) too: hover a reward and the tooltip says "+ Best upgrade" or "$ Sells for the most".

# DruidPlan 1.0.0-beta22

- **Alerts with icons:** every combat helper alert now shows the icon of the spell it is about, for example the Devotion Aura icon next to "No aura", or the Overpower icon next to "OVERPOWER!".
- New **Alert style** setting (settings window → Plan and look): *Icon + text*, *Icons only* (big icons side by side, no text) or *Text only*. It's saved in your profile.

# DruidPlan 1.0.0-beta21

- Talent marker: a big green arrow now points down at the next talent.

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
