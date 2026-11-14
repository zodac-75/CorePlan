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
