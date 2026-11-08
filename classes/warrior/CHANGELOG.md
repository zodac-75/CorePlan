# WarriorPlan 1.0.0-beta32

- Buff watcher: right-click support for icons that have a choice (used by PaladinPlan's blessings).

# WarriorPlan 1.0.0-beta31

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
- **Easter eggs on/off:** a new box under Fun in the settings (or `/war eggs`) turns all of it off.

# WarriorPlan 1.0.0-beta30

- Buff watcher: groundwork for party buffs (shown for classes with a group buff: mage, druid, paladin).

# WarriorPlan 1.0.0-beta29

- **Tidier settings window:** everything is sorted into groups in three columns: Combat and buffs, Gear and quests, Leveling, Windows, Talent plan, Professions (both professions and Cooking/First Aid/Fishing together), Look, Alerts and sounds, and Profiles. The quick menu on the minimap icon uses the same groups.

# WarriorPlan 1.0.0-beta28

- **Tick boxes for secondary skills:** Cooking, First Aid and Fishing each have their own tick box under Features. Ticked shows it in the crafting assistant (with where to learn it if you haven't yet), unticked hides it. By default the ones you've learned are ticked.

# WarriorPlan 1.0.0-beta27

- **Pick your secondary skills:** a new "Secondary" choice in the settings, below your professions: Auto (the ones you've learned), all three, any one or two of Cooking, First Aid and Fishing, or none. Ones you pick but haven't learned yet show with where to learn them. `/war secondary` steps through the choices.

# WarriorPlan 1.0.0-beta26

- **Cooking, First Aid and Fishing** in the crafting assistant. They don't use a profession slot, so they show below your two main professions once you've learned them:
  - **Cooking and First Aid:** what to make for every skill range, with the materials you have and need, and where to learn or buy the recipe (trainer or vendor).
  - **Fishing:** where to fish for your skill, and which pole and lures to use and where to buy them.
  - When you're close to the cap: where the next rank is (Expert books, the Clamlette Surprise, Triage and Nat Pagle quests).
  - Turn them off under Features ("Cooking, First Aid, Fishing") or with `/war secondary`.

# WarriorPlan 1.0.0-beta25

- **Walk on Air timer (Skyborne):** when you use Walk on Air, a big countdown with a bar shows how long you can still glide. It turns yellow, then red with "LAND NOW!" for the last 3 seconds, and plays the alert sound if sounds are on, so you don't drop out of the sky. It moves with the combat helper ("Move"), Ctrl + mouse wheel for size, and you can turn it off under Features or with `/war glide`.

# WarriorPlan 1.0.0-beta24

- **Separate lock for the buff row:** the buff watcher now moves with the combat helper ("Move combat helper & buffs" in the settings or the quick menu, or `/war move`) instead of with "Lock windows". You can keep your windows unlocked and the buff row stays put, or move the buff row without unlocking every window.

# WarriorPlan 1.0.0-beta23

- **Fix: action bars disappearing or moving in combat** ("Interface action failed"/blocked actions). The addon no longer opens Blizzard's talent window itself, never attaches its talent arrow, hint or map pin to Blizzard's windows, and no longer closes Blizzard's settings window. Those could "taint" the game's own UI so it got blocked in combat. To see the next talent, open your talents with N as usual: the green arrow is still there.

# WarriorPlan 1.0.0-beta22

- **Fix:** the rank check could say "your bars look good" with an old rank on a button (e.g. an older rank of a spell), because Forever often hides the rank text. It now also compares the level each rank is learned at, and the mana cost, so old ranks are found anyway. `/war ranks debug` shows what it sees for every button.

# WarriorPlan 1.0.0-beta21

- **Fix:** the talent arrow could point at a Spellbook tab (e.g. the Frost tab) when you opened the Spellbook, because its icon looks like a talent's. It now only marks talents while the Talents tab is showing.

# WarriorPlan 1.0.0-beta20

- **Rebuff reminder:** out of combat the buff watcher now warns you early, by default when a buff has **3 minutes left** (e.g. Frost Armor). A line above the icons says "Rebuff soon: Frost Armor (2:59 left)", the icon pulses, and you hear the alert sound if sounds are on. Click the icon to rebuff. Pick 1, 2, 3, 5 or 10 minutes, or off, under "Rebuff reminder" in the settings. Short buffs warn at a third of their length so they don't nag right after you cast them. In combat it still only warns at the last minute.

# WarriorPlan 1.0.0-beta19

- **Easier to move the buff watcher:** unlock windows and the row now shows all your watched buffs (faded when they're up), so you can always find it. Drag it by any icon, Ctrl + mouse wheel to resize. Clicking doesn't cast while it's unlocked.

# WarriorPlan 1.0.0-beta18

- **Buff watcher:** a row of icons that appears when one of your buffs is missing (red frame) or about to run out (yellow frame, with time left). **Click an icon to cast the buff.** Drag it where you want it while windows are unlocked, and use Ctrl + mouse wheel to resize it. Turn it on or off under Features or with the quick menu. Watches Battle Shout, when you have an enemy targeted.

# WarriorPlan 1.0.0-beta17

- **DialogueUI support:** when you hover a quest reward in DialogueUI, its tooltip now shows "+ Best upgrade" and "$ Sells for the most" too.

# WarriorPlan 1.0.0-beta16

- **Quest rewards, two marks:** a green **+** on the reward that is your biggest upgrade, and a gold **$** on the one that sells for the most at a vendor. One item can get both. Chat says which is which.
- Works with quest dialog addons (DialogueUI, Immersion, ...) too: hover a reward and the tooltip says "+ Best upgrade" or "$ Sells for the most".

# WarriorPlan 1.0.0-beta15

- **Alerts with icons:** every combat helper alert now shows the icon of the spell it is about, for example the Devotion Aura icon next to "No aura", or the Overpower icon next to "OVERPOWER!".
- New **Alert style** setting (settings window → Plan and look): *Icon + text*, *Icons only* (big icons side by side, no text) or *Text only*. It's saved in your profile.

# WarriorPlan 1.0.0-beta14

- Talent marker: a big green arrow now points down at the next talent.

# WarriorPlan 1.0.0-beta13

- **Clearer talent marker:** the next talent in your plan now gets a thick green frame that pulses, with a big green arrow bobbing above it. The old faint blue glow is gone, and so is the flicker.

# WarriorPlan 1.0.0-beta12

- Talent window: the glow now shows up when the window was already open, and stays on the right talent while you click around. The "next talent" line sits at the bottom of the window.

# WarriorPlan 1.0.0-beta11

- **Talents now work with WoW Forever's talent window.** Forever uses Blizzard's modern talent system, which the addon didn't read before. That's why "next talent" was missing and every talent got the same red icon. Now the next talent in your plan glows in the talent window, the plan window shows it with its real icon, and clicking the row opens the talent window.

# WarriorPlan 1.0.0-beta10

- **Crafting assistant redone:** each profession has its icon and a skill bar. The bar turns orange when it's time to train the next rank. Materials show as item icons with have/need on them (green when you have enough), with the item tooltip on hover. Herbs, ore and leather you can gather now, and what's in your bags, show as icons too.
- Plan window: gear notes get the icon of their profession.

# WarriorPlan 1.0.0-beta9

- **New plan window.** No more wall of text:
  - **Do this now** at the top lists only what you can act on: a talent point to spend, spells to train, old ranks on your bars and professions that fall behind. Click a row to act on it: it opens the talent window, lists what to train or checks your bars. When there's nothing to do it says "All caught up".
  - Spells show as icons, with the real spell tooltip when you hover them. Long lists show the first five names, and hovering shows the rest.
  - XP, gold goal and professions on track get small icons underneath.
  - **Coming up** (the next three levels) is folded into one line. Click it to open or close it; the window remembers your choice.

# WarriorPlan 1.0.0-beta8

- **Combat helper size** in the settings window, from 75% to 250%. You can still unlock it with "Move combat helper" and use the mouse wheel.
- **Alert sound:** off, on call-outs only, or on call-outs and reminders. Pick between five sounds; each one plays when you choose it.

# WarriorPlan 1.0.0-beta7

- The mugs easter egg now comes with `/drink`. WoW Forever has no `/toast` emote, so it never fired before.

# WarriorPlan 1.0.0-beta6

- Rank check understands macros: a spell in a macro counts as on your bars, and a macro is only reported when it names an old rank, like "Frostbolt(Rank 1)".

# WarriorPlan 1.0.0-beta5

- Fixed the logo missing at the top of the settings window (and in the game's AddOns settings).

# WarriorPlan 1.0.0-beta4

- No more drink reminder: warriors use rage. The drink settings are gone from the menus too.
- Buff reminders no longer say a buff is missing when the game hides your buff list from addons (it can do that in combat). They stay quiet when they can't tell.

# WarriorPlan 1.0.0-beta3

- **Quick menu:** left-click the minimap icon for a small menu right next to it: switch spec, open the plan window, dungeon guide, crafting assistant or trainer list, and turn features on and off with one click. Right-click still opens all settings.

# WarriorPlan 1.0.0-beta2

- Plate armor shows "usable at level 40" in the upgrade check until you can wear it, and the quest reward picker skips it.
- Shields now get the upgrade check too (they were never compared before).
- Fury and other dual wielders: a one-hand weapon is compared with the weaker of your two weapons.
- Talent window: one odd frame can no longer stop the search for the talent to mark.
- Execute is called out even when the game hides your target's health.

# WarriorPlan 1.0.0-beta1

First beta of WarriorPlan, the warrior leveling companion for WoW Forever.

- Pick your spec in the settings window (or `/war plan`): **Arms** (two-hander), **Fury** (dual wield) or **Protection** (tank). The talent plan, the upgrade check and the combat helper follow the spec.
- Talent plans for all three specs, checked against the live talent tree.
- Combat helper: Overpower (Arms/Fury), Revenge (Protection), Execute and Victory Rush call-outs, plus Battle Shout, Rend and Demoralizing Shout reminders.
- Upgrade check and quest reward picker with weapon-focused weights for Arms/Fury and tank weights (stamina, defense, avoidance, block) for Protection.
- Trainer list and rank check for every warrior ability.
- Dungeon guide with warrior loot, profession assistant (Blacksmithing and Mining by default, pick any two), XP tracker, profiles and the emote easter eggs.
