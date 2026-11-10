# HunterPlan 1.0.0-beta33

- **Bag check for enchanters, take two:** items stay in the best-price group again (AH, sell or DE), but every row you can disenchant now also offers it: Alt-click disenchants instead (the row says "Sell/DE" or "AH/DE"). Away from a vendor, a plain click disenchants.

# HunterPlan 1.0.0-beta32

- **Bag check for enchanters:** if you can disenchant an item (Enchanting skill high enough), it now always goes in the Disenchant group, even when a vendor or the AH would pay a little more. Click disenchants it; at a vendor, shift-click still sells it.

# HunterPlan 1.0.0-beta31

- **Bag check sells white gear:** white (common) armor and weapons from drops now show up in the sell list at a vendor, unless the item would be an upgrade for you. Fishing poles, profession tools (Mining Pick, Skinning Knife, Blacksmith Hammer …), shirts and tabards are never offered. Right-click a row to keep an item.

# HunterPlan 1.0.0-beta30

- **Buff watcher in boss fights, take two:** also notices the boss fight from the game's encounter events (for clients without IsEncounterInProgress), and a buff whose name the game hides counts as "can't tell" instead of "missing". `/hp buffdebug` now also lists what it can see of each party member's buffs.

# HunterPlan 1.0.0-beta29

- **Buff watcher in boss fights:** at the pull the game hides other players' buffs, which made the buff row ask you to buff the whole party again. A buff you can't see during a boss fight now counts as "can't tell" instead of "missing".
- **Someone else's stronger buff:** when a higher-level player has put a higher rank of your buff on you or your party (a higher Mark of the Wild, Arcane Intellect, Fortitude …), the buff watcher leaves it alone until it runs out, since your weaker rank can't replace it. `/hp buffdebug` says when that is the case.
- **Rank check:** reads the spell rank on clients without C_Spell.GetSpellSubtext too.

# HunterPlan 1.0.0-beta28

- **Talent window in replacement UIs (Daylight UI):** the yellow frames and green ticks now stay inside the talent window you actually see, instead of landing on Blizzard's hidden talent buttons elsewhere on the screen.

# HunterPlan 1.0.0-beta27

- **Green tick on finished talents:** talents in your plan that you have taken all the planned points in now get a small green tick in the top right corner in the talent window, beside the icon so you still see which talent it is. Yellow frames still show what's left and the green frame and arrow the next one.

# HunterPlan 1.0.0-beta26

- **Yellow talent frames follow your plan:** switching plans or reopening the talent window could leave frames from an earlier plan on the wrong talents. Each frame is now placed fresh every time, and one talent that can't be found no longer stops the rest. /hp talentui lists the planned talents by name.

# HunterPlan 1.0.0-beta25

- **Yellow frames on the talent tree now show:** the frames for the rest of your plan didn't appear because of a bug in how the plan was read. Fixed. /hp talentui also lists what the check sees.

# HunterPlan 1.0.0-beta24

- **The whole plan on the talent tree:** besides the green frame and arrow on your next talent, every other talent in your plan that you haven't taken yet now gets a yellow frame in the talent window, so you can see where the build is heading. Talents you skip or have finished lose their frame.

# HunterPlan 1.0.0-beta23

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /hp ranks controller on|off|auto) overrides the detection.

# HunterPlan 1.0.0-beta22

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# HunterPlan 1.0.0-beta21

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /hp ranks debug lists where each spell was found.

# HunterPlan 1.0.0-beta20

- **Import Wowhead talent links too:** "Import talents" (or /hp import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# HunterPlan 1.0.0-beta19

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /hp import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /hp import clear) takes it away.

# HunterPlan 1.0.0-beta18

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /hp skip) to skip that talent, for example when you already put those points somewhere else. /hp skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# HunterPlan 1.0.0-beta17

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# HunterPlan 1.0.0-beta16

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# HunterPlan 1.0.0-beta15

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /hp marks) turns the feature on or off.

# HunterPlan 1.0.0-beta14

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# HunterPlan 1.0.0-beta13

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# HunterPlan 1.0.0-beta12

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# HunterPlan 1.0.0-beta11

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# HunterPlan 1.0.0-beta10

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# HunterPlan 1.0.0-beta9

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# HunterPlan 1.0.0-beta8

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# HunterPlan 1.0.0-beta7

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# HunterPlan 1.0.0-beta6

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# HunterPlan 1.0.0-beta5

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# HunterPlan 1.0.0-beta4

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# HunterPlan 1.0.0-beta3

- New logo and minimap icon.

# HunterPlan 1.0.0-beta2

- First version on CurseForge.

# HunterPlan 1.0.0-beta1

- First version: talent plans for Beast Mastery, Marksmanship and Survival, trainer list, rank check, aspects in the buff watcher, ammo alert, pet reminders, upgrade check with agility and ranged weights, dungeon guide and everything else the Plan addons share.
