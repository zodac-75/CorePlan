# ShamanPlan 1.0.0-beta38

- Buff watcher: groundwork for party buffs (shown for classes with a group buff: mage, druid, paladin).

# ShamanPlan 1.0.0-beta37

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# ShamanPlan 1.0.0-beta36

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# ShamanPlan 1.0.0-beta35

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/sp secondary` steps through the choices.

# ShamanPlan 1.0.0-beta34

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/sp secondary`.

# ShamanPlan 1.0.0-beta33

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/sp glide`.

# ShamanPlan 1.0.0-beta32

- **Separate lock for the buff row:** the buff watcher now moves with the combat helper ("Move combat helper & buffs" in the settings or the quick menu, or `/sp move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# ShamanPlan 1.0.0-beta31

- **Fix: action bars disappearing or moving in combat** ("Interface action failed"/blocked actions). The addon no longer opens Blizzard's talent window itself, never attaches its talent arrow, hint or map pin to Blizzard's windows, and no longer closes Blizzard's settings window. Those could "taint" the game's own UI so it got blocked in combat. To see the next talent, open your talents with N as usual: the green arrow is still there.

# ShamanPlan 1.0.0-beta30

- **Fix:** the rank check could say "your bars look good" with an old rank on a button (e.g. an older rank of a spell), because Forever often hides the rank text. It now also compares the level each rank is learned at, and the mana cost, so old ranks are found anyway. `/sp ranks debug` shows what it sees for every button.

# ShamanPlan 1.0.0-beta29

- **Fix:** the talent arrow could point at a Spellbook tab (e.g. the Frost tab) when you opened the Spellbook, because its icon looks like a talent's. It now only marks talents while the Talents tab is showing.

# ShamanPlan 1.0.0-beta28

- **Rebuff reminder:** out of combat the buff watcher now warns you early, by default when a buff has **3 minutes left** (e.g. Frost Armor). A line above the icons says "Rebuff soon: Frost Armor (2:59 left)", the icon pulses, and you hear the alert sound if sounds are on. Click the icon to rebuff. Pick 1, 2, 3, 5 or 10 minutes, or off, under "Rebuff reminder" in the settings. Short buffs warn at a third of their length so they don't nag right after you cast them. In combat it still only warns at the last minute.

# ShamanPlan 1.0.0-beta27

- **Easier to move the buff watcher:** unlock windows and the row now shows all your watched buffs (faded when they're up), so you can always find it. Drag it by any icon, Ctrl + mouse wheel to resize. Clicking doesn't cast while it's unlocked.

# ShamanPlan 1.0.0-beta26

- **Buff watcher:** a row of icons that appears when one of your buffs is missing (red frame) or about to run out (yellow frame, with time left). **Click an icon to cast the buff.** Drag it where you want it while windows are unlocked, and use Ctrl + mouse wheel to resize it. Turn it on or off under Features or with the quick menu. Watches Lightning/Water Shield and your weapon buff (the best one for your spec).

# ShamanPlan 1.0.0-beta25

- **DialogueUI support:** when you hover a quest reward in DialogueUI, its tooltip now shows "+ Best upgrade" and "$ Sells for the most" too.

# ShamanPlan 1.0.0-beta24

- **Quest rewards, two marks:** a green **+** on the reward that is your biggest upgrade, and a gold **$** on the one that sells for the most at a vendor. One item can get both. Chat says which is which.
- Works with quest dialog addons (DialogueUI, Immersion, ...) too: hover a reward and the tooltip says "+ Best upgrade" or "$ Sells for the most".

# ShamanPlan 1.0.0-beta23

- **Alerts with icons:** every combat helper alert now shows the icon of the spell it is about, for example the Devotion Aura icon next to "No aura", or the Overpower icon next to "OVERPOWER!".
- New **Alert style** setting (settings window → Plan and look): *Icon + text*, *Icons only* (big icons side by side, no text) or *Text only*. It's saved in your profile.

# ShamanPlan 1.0.0-beta22

- Talent marker: a big green arrow now points down at the next talent.

# ShamanPlan 1.0.0-beta21

- **Clearer talent marker:** the next talent in your plan now gets a thick green frame that pulses, with a big green arrow bobbing above it. The old faint blue glow is gone, and so is the flicker.

# ShamanPlan 1.0.0-beta20

- Talent window: the glow now shows up when the window was already open, and stays on the right talent while you click around. The "next talent" line sits at the bottom of the window.

# ShamanPlan 1.0.0-beta19

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# ShamanPlan 1.0.0-beta18

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# ShamanPlan 1.0.0-beta17

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# ShamanPlan 1.0.0-beta16

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# ShamanPlan 1.0.0-beta15

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# ShamanPlan 1.0.0-beta14

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# ShamanPlan 1.0.0-beta13

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# ShamanPlan 1.0.0-beta12

- Fixed "Lightning Shield is missing" showing while Lightning Shield was on. Water Shield and Earth Shield also count.
- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# ShamanPlan 1.0.0-beta11

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# ShamanPlan 1.0.0-beta10

- Mail armor shows "usable at level 40" in the upgrade check until you can wear it, and the quest reward picker skips it.
- Shields now get the upgrade check too (they were never compared before).
- Fury and other dual wielders: a one-hand weapon is compared with the weaker of your two weapons.
- Talent window: one odd frame can no longer stop the search for the talent to mark.

# ShamanPlan 1.0.0-beta9

- Pick your spec in the settings window (or `/sp plan`): Enhancement, **Elemental** or **Restoration**. The talent plan and the upgrade check follow the spec (spell power for Elemental, healing for Restoration).
- The talent tree now marks your next talent in WoW Forever's own talent window.

# ShamanPlan 1.0.0-beta8

**Changed**
- No more "you're not playing a ..." message at login on characters of another class. Handy if you have more than one of the Plan addons installed.

## ShamanPlan 1.0.0-beta7

**New**
- More secrets for players who both run one of my Plan addons. `/kiss` was only the start: try a few other emotes on a friend... `/dance` is a good place to begin. 🪩

## ShamanPlan 1.0.0-beta6

**New**
- **Pick your two main professions** in the settings window (Profession 1 and 2). "Auto" uses the professions you've learned.
- The professions window (`/sp craft`) now covers all nine main professions:
  - Crafting: Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking and Tailoring, each with a WoW Forever 1-300 route and what you have and miss in bags and bank.
  - Gathering: Herbalism, Mining (best ore now, next ore, where to go) and Skinning (highest beast level you can skin, best leather).
- Profession goals in the plan window name the trainer for your next rank, and gear notes and zone tips follow the professions you picked.

## ShamanPlan 1.0.0-beta5

**New**
- A little secret for players who both use one of my Plan addons (MagePlan, ShamanPlan, DruidPlan). Try `/kiss` on a friend. <3

## ShamanPlan 1.0.0-beta4

**New**
- **Train now:** the plan window lists exactly which spell ranks your class trainer has for you (e.g. "Lightning Bolt 2"), and you get a ping with a sound when something new becomes trainable. `/sp train` shows the list again.
- Replaces the old "visit your trainer at every even level" reminder, which didn't say what to train and stayed quiet right after install.

## ShamanPlan 1.0.0-beta3

First version: a leveling companion for **Enhancement shamans in WoW Forever**, built on MagePlan.

**Leveling plan**
- Enhancement talent plan 10-60, checked against the live talent tree. The next talent glows in the talent window.
- Spells to train per level, a "Not trained yet" list and a trainer reminder.
- Rank check for your action bars (`/sp ranks`).

**Combat helper**
- "MAELSTROM 5!" when Lightning Bolt is instant, plus the stack count from 3.
- Reminders for a missing Lightning Shield, a missing weapon imbue (Windfury / Rockbiter) and Flame Shock on your target.

**Gear and loot**
- Upgrade check in tooltips, scored in attack power with Enhancement weights (weapon DPS first, then Strength, Intellect through Mental Dexterity, crit and hit).
- Quest reward picker.
- Dungeon guide for all Alliance leveling dungeons: quests with status and an arrow to the quest giver, plus shaman loot from the bosses.

**Professions**
- Alchemy assistant: the next step of a Forever 1-300 route with herbs and vials in your bags and bank.
- Herbalism: the herbs you can pick now, the next one, and where to go.

**Also included from MagePlan**
- Settings window, profiles shared by all characters, XP tracker, gold goal, drink reminder, zone tips, themes and resizable windows. English and Swedish.
