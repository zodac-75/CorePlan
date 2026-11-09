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
