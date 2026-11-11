# RoguePlan 1.0.0-beta36

- **Talent window with Daylight UI (and similar):** the yellow plan frames, green ticks and the next-talent glow now follow the window when you move it. They were anchored to Blizzard's hidden copy of the talent tree, which Daylight leaves at alpha 0 in the old spot; invisible buttons and windows are now skipped. `/rp talentui` also shows where the next talent's button is and which window holds it.

# RoguePlan 1.0.0-beta35

- **Talent import:** Icy Veins and wow-forever-forge.com links are now the recommended ones in the import window, since they keep the order you clicked the talents in. The Icy Veins reading is verified for the whole Mage tree.

# RoguePlan 1.0.0-beta34

- **Import from Icy Veins:** copy the address of your build from Icy Veins' WoW Forever talent calculator (the link with `#tc-...` at the end) and paste it into "Import talents" (or `/<slash> import <link>`). Like a forge link it keeps the order you clicked the talents in, so it becomes your leveling plan from level 10. Checked for Mage so far: a link that doesn't fit your class is refused with a message instead of being read wrongly, and the other classes are verified one by one as links come in.

# RoguePlan 1.0.0-beta33

- **Import from talentsforever.com:** paste the link from "Copy link" on talentsforever.com into "Import talents" (or `/<slash> import <link>`) and it becomes your leveling plan, the same way as a Wowhead link: the tree with the most points is filled first, row by row.
- Fixed the `/<slash> rankcontroller` command showing as "CMD_rankcontroller" in the command list.

# RoguePlan 1.0.0-beta32

- **Bag check for enchanters, take two:** items stay in the best-price group again (AH, sell or DE), but every row you can disenchant now also offers it: Alt-click disenchants instead (the row says "Sell/DE" or "AH/DE"). Away from a vendor, a plain click disenchants.

# RoguePlan 1.0.0-beta31

- **Bag check for enchanters:** if you can disenchant an item (Enchanting skill high enough), it now always goes in the Disenchant group, even when a vendor or the AH would pay a little more. Click disenchants it; at a vendor, shift-click still sells it.

# RoguePlan 1.0.0-beta30

- **Bag check sells white gear:** white (common) armor and weapons from drops now show up in the sell list at a vendor, unless the item would be an upgrade for you. Fishing poles, profession tools (Mining Pick, Skinning Knife, Blacksmith Hammer …), shirts and tabards are never offered. Right-click a row to keep an item.

# RoguePlan 1.0.0-beta29

- **Buff watcher in boss fights, take two:** also notices the boss fight from the game's encounter events (for clients without IsEncounterInProgress), and a buff whose name the game hides counts as "can't tell" instead of "missing". `/rp buffdebug` now also lists what it can see of each party member's buffs.

# RoguePlan 1.0.0-beta28

- **Buff watcher in boss fights:** at the pull the game hides other players' buffs, which made the buff row ask you to buff the whole party again. A buff you can't see during a boss fight now counts as "can't tell" instead of "missing".
- **Someone else's stronger buff:** when a higher-level player has put a higher rank of your buff on you or your party (a higher Mark of the Wild, Arcane Intellect, Fortitude …), the buff watcher leaves it alone until it runs out, since your weaker rank can't replace it. `/rp buffdebug` says when that is the case.
- **Rank check:** reads the spell rank on clients without C_Spell.GetSpellSubtext too.

# RoguePlan 1.0.0-beta27

- **Talent window in replacement UIs (Daylight UI):** the yellow frames and green ticks now stay inside the talent window you actually see, instead of landing on Blizzard's hidden talent buttons elsewhere on the screen.

# RoguePlan 1.0.0-beta26

- **Green tick on finished talents:** talents in your plan that you have taken all the planned points in now get a small green tick in the top right corner in the talent window, beside the icon so you still see which talent it is. Yellow frames still show what's left and the green frame and arrow the next one.

# RoguePlan 1.0.0-beta25

- **Yellow talent frames follow your plan:** switching plans or reopening the talent window could leave frames from an earlier plan on the wrong talents. Each frame is now placed fresh every time, and one talent that can't be found no longer stops the rest. /rp talentui lists the planned talents by name.

# RoguePlan 1.0.0-beta24

- **Yellow frames on the talent tree now show:** the frames for the rest of your plan didn't appear because of a bug in how the plan was read. Fixed. /rp talentui also lists what the check sees.

# RoguePlan 1.0.0-beta23

- **The whole plan on the talent tree:** besides the green frame and arrow on your next talent, every other talent in your plan that you haven't taken yet now gets a yellow frame in the talent window, so you can see where the build is heading. Talents you skip or have finished lose their frame.

# RoguePlan 1.0.0-beta22

- **Rank check ignores buttons you can't see:** an old rank left on one of the controller's hidden button sets (buttons above 180) no longer shows up when you play with keyboard and mouse. Those sets are counted when a controller is detected. A new "I use a controller" tick box in the settings (or /rp ranks controller on|off|auto) overrides the detection.

# RoguePlan 1.0.0-beta21

- **Party marks on their own button:** marking moved out of the buff row to a small mark button that shows while you're in a party, with no alert or sound. One click puts your picked marks on, and it now works in combat too, so you can bring the marks back when the tank's marking took them. Shift-drag moves the button, Ctrl + mouse wheel resizes it.

# RoguePlan 1.0.0-beta20

- **Rank check finds controller buttons:** spells on WoW Forever's controller layouts no longer show as "not on any button". The check now looks at more action slots and asks the game whether a spell is on any button. /rp ranks debug lists where each spell was found.

# RoguePlan 1.0.0-beta19

- **Import Wowhead talent links too:** "Import talents" (or /rp import <link>) now also takes a link from Wowhead's WoW Forever talent calculator. Wowhead links don't carry the order you clicked in, so the plan fills the tree with the most points first, row by row; forge links keep your exact order.

# RoguePlan 1.0.0-beta18

- **Import your own talent build:** make a build in the wow-forever-forge.com talent calculator, click Share, and paste the link with the new "Import talents" button in the settings (or /rp import <link>). The order you clicked the talents in becomes your leveling plan, shown as "Imported" next to our plans. It acts like our plan for the same tree for stat weights and call-outs. "Remove import" (or /rp import clear) takes it away.

# RoguePlan 1.0.0-beta17

- **Skip a talent in the plan:** right-click "Next talent" in the plan window (or type /rp skip) to skip that talent, for example when you already put those points somewhere else. /rp skip reset brings skipped talents back.
- **Call-outs respect cooldowns in combat:** the game can hide cooldowns in combat, and a "use it now" call-out then stayed up while the spell was on cooldown. It now counts as on cooldown after you cast it.

# RoguePlan 1.0.0-beta16

- **No more repeated buff alerts:** a party member stepping out of range and back no longer sets off the "buff missing" sound again (it waits until they've been gone a minute), and party buff alerts are silent in combat.

# RoguePlan 1.0.0-beta15

- **Dungeon guide stays open through loading screens:** the window now comes back after /reload, login and zoning into a dungeon if it was open (the game could hide it during the loading screen before the addon saved it).

# RoguePlan 1.0.0-beta14

- **Party marks follow party slots:** you pick you or party member 2-5 (the order in the party frames) for each mark, so the marks stay set when people leave or join. A new "Party marks icon" tick box (or /rp marks) turns the feature on or off.

# RoguePlan 1.0.0-beta13

- **Party marks only for players in range:** party members out of range get no mark icon until they come closer.

# RoguePlan 1.0.0-beta12

- **Party marks:** pick who gets Star, Circle, Diamond, Triangle and Moon in the settings window (click or scroll a mark to go through your party). When you're in a party and someone near you is missing their mark, a mark icon shows in the buff row: one click marks them all, without changing your target.

# RoguePlan 1.0.0-beta11

- **Arrow for quests that start from an item:** clicking such a quest (like Dark Iron Map for Old Ironforge Incursion) now points the arrow at the mob that drops the item, and the guide says who drops it and where.

# RoguePlan 1.0.0-beta10

- **Waypoint arrow always on top:** a resized dungeon window could cover the arrow after you clicked a quest. The arrow now stays above the addon's windows.

# RoguePlan 1.0.0-beta9

- **Dungeon guide stays open after /reload:** if the dungeon window was open, it opens again after a reload or login, on the same dungeon.

# RoguePlan 1.0.0-beta8

- **Dungeon guide window resizes:** Ctrl + mouse wheel now makes the dungeon window bigger or smaller, also over its lists. A plain wheel still scrolls. The size is saved.

# RoguePlan 1.0.0-beta7

- **Party marks removed:** the game only lets a click set raid marks, so the automatic party marks from the last version couldn't work and caused a "blocked action" warning. The feature is gone.

# RoguePlan 1.0.0-beta6

- **Party marks:** a new "Party marks" row in the settings window with the five usual marks (Star, Circle, Diamond, Triangle, Moon). Click or scroll a mark to pick who gets it: you or one of your party members. The addon puts them on while you're in a party, out of combat, and never twice on the same player.

# RoguePlan 1.0.0-beta5

- **Party buffs only for players near you:** a party member in another zone or out of range of your buff no longer gets an icon. It shows up again as soon as they're in range.

# RoguePlan 1.0.0-beta4

- **Dungeon guide for Horde and the new dungeons:** Horde characters now get their own dungeon quests and quest givers, and the list leaves out dungeons in the other faction's capital. Added Ragefire Chasm and the nine new WoW Forever dungeons: Hall of Thanes, Ruins of Lordaeron, Excavation Site: Wetlands and City of Dalaran with their quests, and The Drowned City, Krol'dok Stronghold, Alcaz Prison, Blackmaw Hold and Shaper's Terrace with levels and location (the entrance comes from the game's dungeon journal when it knows it). Level ranges updated to Forever's. The dungeon list scrolls.

# RoguePlan 1.0.0-beta3

- **Professions rebuilt for WoW Forever:** every crafting route (Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) and Cooking and First Aid now follow wow-professions.com's WoW Forever guides, where skill ranges differ from Classic.
- **Horde trainers and vendors:** the crafting assistant now names the right trainer for the next rank and the right recipe vendors for your faction. Before, Horde players were sent to Alliance trainers.
- Steps the guides wrote during the beta (mostly 225-300) say so, and alternatives are listed when another recipe can be cheaper.
- Skinning now shows where to skin for your skill, and the herb, mining and fishing zones are split by faction.
- Fixed a wrong zone tip: the Superior Mana Potion recipe is sold by Algernon in Undercity (Horde) and Ulthir in Darnassus (Alliance).

# RoguePlan 1.0.0-beta2

- First version on CurseForge.

# RoguePlan 1.0.0-beta1

- First version: talent plans for Combat, Assassination and Subtlety, trainer list, rank check, poisons in the buff watcher (click to put them on your weapons), combo point and Slice and Dice call-outs, upgrade check with agility and attack power weights, dungeon guide and everything else the Plan addons share.
