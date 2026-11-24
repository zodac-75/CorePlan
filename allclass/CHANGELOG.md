# AllClassPlan 0.1.35

- **More campfire talk:** about 150 new lines, now 490 in total. 45 of them are for when you target another player (30 new greetings), plus new jokes, fire, food and weather talk and four new lines for every class.
- **Fix:** a Lua error when the game sent a hidden (secret) chat message about a profession skill-up or experience. Those messages are now skipped.

# AllClassPlan 0.1.34

- **Rank check: low ranks on purpose.** A lower rank next to the best rank of the same spell (a cheap Arcane Explosion rank 1, a small heal) is no longer reported. To allow old ranks of a spell even on their own, use `/acp ranks keep <spell>` (again to undo, `/acp ranks keep` lists them).
- **Buff food:** when Well Fed lands while you eat, the food bar turns gold, says "Well Fed!" and pings, so you know you can stop.

# AllClassPlan 0.1.33

- **Bandage bar:** a third row for bandages that works in combat too. It counts down the 8 seconds of bandaging with your health and %, then shows how long until you can bandage again (Recently Bandaged). Its own tick box in the settings (Buffs), or `/acp bandagebar`.

# AllClassPlan 0.1.32

- **Eating and drinking bars show %:** your health % at the end of the food bar and your mana % at the end of the drink bar (the game fills in the mana number itself, since WoW Forever hides it from addons).

# AllClassPlan 0.1.31

- **Eating and drinking bars:** food and drink each get their own timer that counts down, with your health filling up under the food bar and your mana under the drink bar. A bar says "Full!" when that one is full. Turn it on or off in the settings (Buffs) or with `/acp eatbar`; move it with "Unlock UI".
- **Tailoring 250-300 follows WoW Forever now:** Runecloth Cuffs from 250 (pattern from Pexmit in Mount Hyjal, or the Horde quest Threading a Solution), then Runecloth Shoulders to 300, instead of the old Earthenweave route.

# AllClassPlan 0.1.30

- **Bag check: AH prices from Auctioneer and TSM too.** If you don't use Auctionator, the bag check and the item tooltips now take AH prices from Auctioneer or TradeSkillMaster instead (Auctionator first, then Auctioneer, then TSM's market value).

# AllClassPlan 0.1.29

- A few more surprises for gatherers in your group.
- **Dungeon guide: loot from the new dungeons.** City of Dalaran, Excavation Site, Ruins of Lordaeron and Hall of Thanes now list their boss loot (Dalaran had none before), and every dungeon's loot is refreshed from the latest WoW Forever data. Necks, rings, cloaks, off-hands and trinkets from the new dungeons are no longer left out.
- **Loot is ranked:** the biggest upgrade for you is at the top.
- **Buff watcher and scrolls:** a Scroll of Intellect, Stamina or Spirit that is stronger than your Arcane Intellect, Power Word: Fortitude or Divine Spirit now counts as that buff until it runs out (the game won't let your weaker rank replace it). A weaker scroll still gets the reminder, since your cast replaces it.

# AllClassPlan 0.1.28

- **Mage: range icon.** While you have an enemy target, an icon with Frostbolt (Fireball with the Fire plan) shows whether you can reach it: red out of range, full colour in range. Talents like Arctic Reach count. Move it with "Unlock UI"; turn it off in the settings or with `/acp range`.
- **Shaman: no more false "old rank" warnings for totems.** The rank check counted the game's hidden totem sets (and the vehicle bar), action slots you never see, and asked you to update a totem that wasn't on any of your bars. Those slots are skipped now.

# AllClassPlan 0.1.27

- **Mage: read your scrolls from the bag check.** If you know Comprehend Scroll, the bag check (`/acp de`) lists your undeciphered scrolls in their own group, lowest skill first. Click a row to decipher it. Scrolls you need more Comprehension skill for show the skill needed (English clients).
- **Gold goal in the settings:** a tick box turns the gold goal line on or off (it starts at 100 g if you had none; hiding it keeps the amount), and you type the amount in gold in a box under it. An empty box removes the goal. `/acp goal 100 mount` still works and keeps its label.

# AllClassPlan 0.1.26

- **Where to level:** a new line in the plan window suggests the one or two zones that fit your level best and the next one coming up, per faction (worked out from WoW Forever's quests, including Forever's own zones). Click it for an arrow to the zone's quest hub, right-click for the second zone. Turn it off in the settings or with `/acp levelzones`.
- **Hunter ammo tracker:** counts only ammo that fits your weapon (arrows for bows and crossbows, bullets for guns), shows your ammo and the next best you carry in the plan window, tells you when vendors sell better ammo for your level, and at a vendor says how many stacks to buy. New setting "Ammo to carry" (default: what your quiver or ammo pouch holds).
- **Shaman:** new plan "Enhancement (drakeosvr's build)" (17/26/8), a player's build: no Rage of the Farseer, Tidal Focus and Mindfulness, the rest in Elemental with Convection. Pick it with `/acp plan`.
- **Mage:** the Frost leveling plan takes Shatter (level 25-27) before Improved Frost Nova; it doesn't need Improved Frost Nova in WoW Forever.
- **Tailoring:** the 95-140 route follows WoW Forever's recipe levels: Woolen Boots (95-110), Double-stitched Woolen Shoulders from the trainer at 110 (110-125), then Gloves of Meditation (125-140).

# AllClassPlan 0.1.25

**Better on non-English game clients** (German, French, Spanish, Portuguese, Russian, Italian):
- **Upgrade check works on every client language.** It now reads the stats from the game's own stat list instead of the English tooltip text, so tooltips and the dungeon loot list show upgrades again.
- **Zone tips show up in every language.** Zones are matched by their ID, not their English name.
- **Names in your game's language:** the dungeon guide shows dungeon, quest and NPC names as your client names them, and the zone tips and profession help show trainers, vendors, places, items and recipes the same way (also on the map arrow). NPC and quest names come from QuestieDB's translations (not available for Italian); items, places and spells come from the game itself.

On English clients nothing changes.

# AllClassPlan 0.1.24

- **Dungeon guide on non-English game clients:** the loot list now shows all loot your class can wear, with a note that the comparison with your gear needs an English client. Before, it was empty and said nothing was better than what you wear.

# AllClassPlan 0.1.23

- **Shaman: the Maelstrom Weapon 5/5 call-out now works in combat.** The game doesn't list the talent as a known spell, so the call-out only checked the buff list, which is hidden in combat. It now always looks the buff up by name. `/acp mwdebug` also shows whether the talent is learned.
- **Shaman: new Enhancement talent plan** (12/31/8), after player feedback: gear is Strength now, so only 2/5 Ancestral Knowledge; Maelstrom Weapon was nerfed, so 2/5; Tidal Focus 5/5 (hit) and Mindfulness 3/3 (mana) from Restoration; the rest goes into Elemental (Concussion, Elemental Devastation, Call of Flame).
- **Dungeon guide: the loot list only shows upgrades** for you (also ones you are not high enough level for yet). Before, it also listed items that are worse than what you wear. When nothing is better, it says so instead of showing a raw text key.

# AllClassPlan 0.1.22

- **Fixed wrong "Downgrade" / "Upgrade" in item tooltips.** The upgrade check now understands more tooltip lines:
  - "Increases healing done by up to X and damage done by up to Y for all magical spells and effects" (damage counts for casters, healing for healers). Before, such items counted as 0 and could show as a downgrade.
  - Shaman and druid: damage to one school (for example Nature spell damage) now counts, a bit lower than general spell power.
  - "+X Mana per 5 sec" with a capital M now counts as mp5.
- **No longer counted as stats:** "Use:" and "Chance on hit:" effects (they only last a short time), bonuses that only work against some mobs ("when fighting Undead", "damage done to Undead"), and ranged attack power for shaman, druid, warrior and paladin.
- `/acp eggdebug` also shows addon messages from other players (for finding out why a group ding notice didn't show).

# AllClassPlan 0.1.21

- **One "Unlock UI" switch.** It replaces "Move shatter indicator & buffs" and "Lock windows". Tick it and you can drag the combat helper, the buff icons, the campfire button, the drink alert, the Walk on Air timer and all windows; Ctrl + mouse wheel changes their size. Untick it when you are done. It is in the minimap quick menu, in the settings under "Look & windows" and as `/acp unlock`. (`/acp lock` and `/acp move` still work.)
- `/acp buffdebug` also shows which tracking (Find Minerals / Find Herbs) the addon remembers, to find out why the reminder doesn't show.

# AllClassPlan 0.1.20

- **Works on more game languages.** Spells, buffs, talents and professions are now looked up by their spell ID instead of their English name, so the combat helper, buff watcher, rank check, talent plan and the rest also work on a German, French, Spanish, Portuguese, Russian or Italian game client (the game language is detected on its own). English clients behave exactly as before. I can only play on an English client myself, so please tell me if something is still off on yours. `/acp ids` shows which names the game gives back on your client.
- **Italian added** as an interface language (Italiano), next to English, Svenska, Deutsch, Русский, Français, Español and Português. Try `/acp lang it`.
- **The upgrade check in tooltips is off on non-English clients for now.** It reads the item tooltip text, which is English only. It works as before on English clients.
- Rank check also understands macros with a non-English rank in brackets, for example "(Rang 1)".
- Fixed a language check that wrongly reported a missing text.

# AllClassPlan 0.1.19

- **New: campfire talk.** Sit by a campfire and a button shows up when you have the "Campfire Nearby" buff. Click it and your character says a funny line (jokes, greetings, weather talk, hundreds to pick from). `/acp campfire` says one too, and there is a tick box to turn the button off.
- **Reminder for Find Minerals and Find Herbs.** When the tracking falls off (you died, say), an icon in the buff row reminds you and a click casts it again. It only shows for a tracking you know and have had on before, never while another tracking is active, and each one has its own tick box in the settings.
- **Shaman: Maelstrom Weapon 5/5 now works in combat.** The call-out looks the buff up by name instead of reading the buff list, which the game hides in combat. `/acp mwdebug` shows what the game tells the addon, if it still doesn't show.

# AllClassPlan 0.1.18

- **Arrow to your trainers.** Click the "Trainer: ..." line in the crafting window, or the "train Expert: ..." goal line in the plan, and an arrow points to the nearest profession trainer; click again for the next one. Right-click also opens the map there.
- **Arrow to your class trainer.** Click the "Train now: ..." line for an arrow to the nearest trainer of your class and faction (click again for the next). Right-click also opens the map. `/acp train` still lists what you can train in chat.
- **Fixed: Mark of the Wild reminder vanished with Might of Stormwind.** The buff watcher wrongly believed Might of Stormwind always blocks Mark of the Wild. It now reminds you; if the game really refuses the cast, the icon still hides itself for a while.

# AllClassPlan 0.1.17

- **The flower egg is calmer and only starts now and then.** The herbalist's own addon rolls the dice, 10% for each flower picked (change it with `/acp flowerchance 0-100`), and tells the party, so everybody sees it at the same moment. This means she needs this version for others to see it. The effect is also a little smaller and quieter.
- **New pictures for the easter eggs.** The disco ball, violin, fish, cake, heart, crown, cloud, note, beer mug, egg, pumpkin, rainbow, star and train are redrawn, and the flower is now an orchid, in one consistent, much nicer style.

# AllClassPlan 0.1.16

- **Windows hide in combat.** The plan window, crafting window, dungeon guide and settings go away when a fight starts and come back when it ends. New tick box "Show windows in combat" (`/acp combatwin`) keeps them open. A window you open yourself during the fight stays. The bag check is included: with the tick box on it stays open in combat, but its sell and destroy buttons don't work until the fight is over.

# AllClassPlan 0.1.15

- **The flower egg also starts from the loot line.** When the party sees that the herbalist receives an herb, the flower egg starts, so it works even if her addon is old or her cast isn't visible.

# AllClassPlan 0.1.14

- **New easter egg: a flower.** When a certain herbalist in your party goes astray to pick a flower, the whole screen lets you know. Preview it with `/acp egg flower`.
- **Roll eggs reach the whole group.** Pressing Need now starts the Need egg right away, and your addon tells the party about your Need, 1, 67 and 100 rolls, so everyone with the addon sees them even if the chat line never reaches their screen.

# AllClassPlan 0.1.13

- **Mage: bigger icons in the supplies line** (water, food and runes).

# AllClassPlan 0.1.12

- **Mage: the supplies line shows icons.** Water and food show the icon of the best water and food you carry, with how many you have.
- **Mage: runes in the supplies line.** Once you know a teleport, the supplies line also shows your Rune of Teleportation, and once you know a portal, your Rune of Portals: the rune's icon with how many you carry (red when you have none, yellow when you're down to the last two).

# AllClassPlan 0.1.11

- **Mage: the Frost Nova guess is safer and optional.** The target stops counting as frozen as soon as it moves (a missed or broken Nova), and you can turn the guess off in the settings ("Shatter: count your Frost Nova as frozen") or with `/acp novaguess`.
- `/acp shatterdebug` also checks whether your own buffs (Fingers of Frost and others) can be read by name in combat, whether Ice Lance glows, and whether your target is moving.
- The Frostbolt-without-Ice-Lance call-out is translated into every language.

# AllClassPlan 0.1.10

- **Mage: the shatter call-out sees a frozen target in combat.** The game refuses to show addons the auras on enemies in combat, so the frozen debuff couldn't be read. Now your own Frost Nova counts: for its 8 seconds the target in range is treated as frozen (until you cast Ice Lance). Fingers of Frost can't be seen in combat either; that one is still open.
- `/acp shatterdebug` also prints the full error text, what the game says about secret auras and when you last cast Frost Nova.

# AllClassPlan 0.1.9

- `/acp shatterdebug` now tries every way of reading auras (by name, by index with different filters, the old functions) and says which ones work, to find out why a frozen target isn't seen in the game.

# AllClassPlan 0.1.8

- **Mage: the shatter call-out shows Frostbolt on a frozen target even if you haven't learned Ice Lance yet** (it's a talent). Before, nothing showed until you had Ice Lance.

# AllClassPlan 0.1.7

- **Mage: the frozen-target / Fingers of Frost call-out looks the auras up by name**, which still works when the game hides the aura list from addons (in combat). Before it could miss a frozen target.
- New hidden command `/acp shatterdebug`: prints what the shatter indicator sees (target, Ice Lance, the auras on you and your target).

# AllClassPlan 0.1.6

- **No waiting time on the "somebody needs" egg either.** Everyone rolls at the same time, so every Need roll gets its egg right away.

# AllClassPlan 0.1.5

- **Fixed: the "somebody needs" easter egg didn't start in the real game.** The game doesn't say "X has selected Need", only "Need Roll - 55 for [item] by X"; AllClassPlan now reacts to that line too (and reads the player's name from links).

# AllClassPlan 0.1.4

- **No waiting time between roll eggs.** Every roll of 1, 67 or 100 gets its egg right away, also straight after another one.

# AllClassPlan 0.1.3

- **Fixed: a 100 (or 67) rolled soon after another roll egg didn't show.** Only identical roll lines are skipped now, not every roll for six seconds.
- `/acp eggdebug` now also prints an error if an egg effect fails.

# AllClassPlan 0.1.2

- New hidden command `/acp eggdebug`: prints every loot roll line as the game sends it and what the easter eggs made of it, to track down rolls that don't trigger an egg.

# AllClassPlan 0.1.1

- **Fixed: the roll easter eggs (1, 67, 100) didn't show in the real game.** The roller's name comes as a clickable link in loot roll lines, which AllClassPlan didn't recognise, so nothing happened. Names are now read from links too.

# AllClassPlan 0.1.0

First full release: all nine Plan addons (mage, shaman, druid, warrior, paladin, warlock, priest, hunter, rogue) in one install.

- **Your settings come along:** the first time a character logs in, the settings from MagePlan, PaladinPlan, ... are copied. Keep the old addon installed until every character has logged in once, then remove it.
- **All the old commands work:** `/mp`, `/sp`, `/dp`, `/war`, `/pal`, `/wl`, `/pp`, `/hp` and `/rp` go to AllClassPlan, next to `/acp`.
- **Seven languages:** English, Svenska, Deutsch, Русский, Français, Español and Português (BR).
- Language and layout profiles are shared by all your characters.
- Since beta6: settings only one class uses (the paladin's blessing picks, hidden buff icons, ...) survive the move, and hiding a buff icon on one class no longer hides another class's icon.

# AllClassPlan 0.1.0-beta7

- **Fixed: settings only one class uses were lost when a second class moved over.** The paladin's blessing picks, the shaman's Stormstrike call-out, the mage's Polymorph helper and your hidden buff icons now survive the first login with AllClassPlan, also when another character got there first.
- **Fixed: hiding the paladin's aura icon also hid the shaman's shield icon** (and the other way around), because all classes now share the layout profiles.
- If AllClassPlan can't start, it now says why in chat instead of staying silent.

# AllClassPlan 0.1.0-beta6

- New easter egg: roll a 1 and the screen feels your pain.

# AllClassPlan 0.1.0-beta5

- **Fixed: AllClassPlan didn't start** (no window, no minimap icon, "only active on ... characters"). It now starts properly at login.

# AllClassPlan 0.1.0-beta4

- New easter eggs: roll a 100 on loot (need or greed, or /roll) and the screen celebrates. Need 100 gets the big show. Roll a 67 and you'll see.

# AllClassPlan 0.1.0-beta3

- **New languages: Deutsch, Русский, Français, Español and Português (BR).** Every menu text, message and tip is translated. Until you pick a language yourself, the addon uses your game's language when it has it (otherwise English). Change it in the menu (Language) or with `/acp lang` (or `/acp lang de`, `ru`, `fr`, `es`, `pt`, `sv`, `en`).

# AllClassPlan 0.1.0-beta2

- **Class logos are back in the settings window:** each class shows its own logo again (the mage logo on a mage, and so on). The AllClassPlan icon stays in the addon list and on the minimap button.

# AllClassPlan 0.1.0-beta1

- **Your settings come along:** the first time a character logs in with AllClassPlan, the settings from MagePlan, PaladinPlan, ... are copied (plan, windows, text sizes, profiles, language). Keep the old addon installed until every character has logged in once.
- **All the old commands work:** `/mp`, `/sp`, `/dp`, `/war`, `/pal`, `/wl`, `/pp`, `/hp` and `/rp` all go to AllClassPlan, on every character. Help and chat now say `/acp` (for example `/acp egg dance`).
- **No doubles:** a stand-alone Plan addon that knows about AllClassPlan steps aside by itself. An older one keeps running and AllClassPlan stays out of the way on that character, until you update or remove it.

# AllClassPlan 0.1.0-alpha1

- **First test build:** all nine Plan addons in one install. It loads the part for the class you log in on. If the stand-alone addon for that class (MagePlan, PaladinPlan, ...) is also installed, that one runs and AllClassPlan stays out of the way on that character.
- Language and layout profiles are shared by all your characters.
- `/acp` works on every class, next to the class's own command (`/mp`, `/pal`, ...).
- Not on CurseForge yet.
