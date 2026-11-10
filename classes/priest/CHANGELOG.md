# PriestPlan 1.0.0-beta29

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /pp ranks controller on|off|auto) overrides the detection.

# PriestPlan 1.0.0-beta28

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# PriestPlan 1.0.0-beta27

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /pp ranks debug lists where each spell was found.

# PriestPlan 1.0.0-beta26

- **Import Wowhead talent links too:** "Import talents" (or /pp import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# PriestPlan 1.0.0-beta25

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /pp import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /pp import clear) takes it away.

# PriestPlan 1.0.0-beta24

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /pp skip) to skip that talent, for example when you already put those points somewhere else. /pp skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# PriestPlan 1.0.0-beta23

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# PriestPlan 1.0.0-beta22

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# PriestPlan 1.0.0-beta21

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /pp marks) turns the feature on or off.

# PriestPlan 1.0.0-beta20

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# PriestPlan 1.0.0-beta19

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# PriestPlan 1.0.0-beta18

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# PriestPlan 1.0.0-beta17

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# PriestPlan 1.0.0-beta16

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# PriestPlan 1.0.0-beta15

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# PriestPlan 1.0.0-beta14

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# PriestPlan 1.0.0-beta13

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# PriestPlan 1.0.0-beta12

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# PriestPlan 1.0.0-beta11

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# PriestPlan 1.0.0-beta10

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# PriestPlan 1.0.0-beta9

- New logo and minimap icon.

# PriestPlan 1.0.0-beta8

- **Rank check can be quiet:** untick "Rank check messages in chat" under Leveling in the settings (or `/pp rankchat`). `/pp ranks` still checks your bars when you ask.
- The rank check no longer repeats the same list in chat every time your bars change.
- **Controllers:** spells bound straight to a key or a controller button now count as "on a button", and the check also looks at the extra bar pages (slots 121-180) that controller and bar addons use.

# PriestPlan 1.0.0-beta7

- **Bag check button on your bags:** a small disenchant icon above your open bags opens the bag check. Works with the normal bags and with Baganator, Bagnon, AdiBags, ArkInventory, BetterBags and ElvUI bags. Turn it off with "Bag check button on your bags" in the settings.
- **Middle-click the minimap icon** to open the bag check.

# PriestPlan 1.0.0-beta6

- **Fix: the bag check opened behind the settings window**, so clicking "Bag check" there looked like it did nothing. It now opens on top.

# PriestPlan 1.0.0-beta5

- The Walk on Air timer setting only shows on Skyborne characters (High Order and Windshaper), since nobody else has the racial.

# PriestPlan 1.0.0-beta4

- **Fix: a missing buff could stay hidden** when the game hides the aura list (secret values in WoW Forever). The buff watcher now asks for the buff by name, so the icon shows up again (for you and your party).
- **Fix: the dance party didn't always start** when you /dance at each other. Now whoever dances back starts it for both of you, and you have 30 seconds (it used to be 10).
- The buff icons' tooltip tells you when "Move" is on, since a click doesn't cast then.
- New: `/pp buffdebug` shows why a buff icon does or doesn't show.

# PriestPlan 1.0.0-beta3

- **Bag check window** (`/pp de`, or "Bag check" in the settings): lists the junk, gear to vendor, gear to disenchant and gear worth more on the AH in your bags, with what each is worth.
- **Sell and disenchant from it:** with a vendor open, click a row to sell it, or press "Sell junk and vendor items" (12 at a time, so you can still buy them back). With Enchanting, click a row to disenchant it. Shift-click sells anything to the vendor anyway.
- **Keep items:** right-click a row and that item is never sold or disenchanted from the window.
- Opens by itself when you talk to a vendor and have something to sell (turn it off with "Open the bag check at vendors").
- The sell / disenchant / AH advice in item tooltips now comes with every Plan addon (turn it off under "Gear and quests").

# PriestPlan 1.0.0-beta2

- First version on CurseForge.

# PriestPlan 1.0.0-beta1

First version of PriestPlan for WoW Forever.

- Talent plans for all three specs, checked against the live talent tree: **Shadow** (Spirit Tap, Mind Flay, Vampiric Embrace, Shadowform at 40), **Holy** (Spiritual Guidance, Prayer of Mending at 40) and **Discipline** (shields, Penance, Power Infusion at 40).
- Combat helper: calls out Mind Blast (Shadow) and Penance (Discipline), and reminds you of a missing Shadow Word: Pain, Vampiric Embrace or Inner Fire.
- Buff watcher for Power Word: Fortitude, Inner Fire and Shadowform, and Fortitude for your party (click a party member's icon to buff them).
- Upgrade check and quest reward picker with Shadow damage weights for Shadow and healing weights for Holy and Discipline.
- Trainer list and rank check, dungeon guide with priest loot, profession assistant (Tailoring and Enchanting by default, pick any two, plus Cooking, First Aid and Fishing), drink alert, XP tracker, profiles and the easter eggs.
