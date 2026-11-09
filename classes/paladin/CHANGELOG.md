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
