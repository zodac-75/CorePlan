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
