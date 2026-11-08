# CorePlan

Leveling companions for **WoW Forever**, one addon per class, built from one shared core:

| Addon | Class / spec | CurseForge |
|---|---|---|
| MagePlan | Frost, Fire or Arcane mage | [mageplan](https://www.curseforge.com/wow/addons/mageplan) (1785085) |
| ShamanPlan | Enhancement, Elemental or Restoration shaman | project 1787755 |
| DruidPlan | Feral, Balance or Restoration druid | project 1787775 |
| WarriorPlan | Arms, Fury or Protection warrior | project 1787968 |
| PaladinPlan | Protection, Retribution or Holy paladin | project 1787977 |
| WarlockPlan | Affliction, Demonology or Destruction warlock | project 1792150 |
| PriestPlan | Shadow, Holy or Discipline priest | not on CurseForge yet |

## Layout

```
core/            shared code: windows, settings, profiles, dungeon guide, waypoint arrow,
                 professions, trainer list, upgrade check, quest rewards, XP, the heart …
core/Media/      shared images (arrow, heart)
classes/<class>/ what's unique to the class:
  class.json       name, color, slash command, class token, CurseForge ID, extra modules
  Data.lua         talent plan, spells, gear notes, stat weights, rank list, zone tips, settings
  TrainData.lua    spell ranks the class trainer teaches (from the game data)
  DungeonData.lua  dungeon quests and loot for the class (generated, see below)
  LocaleClass.lua  class-specific texts (English and Swedish)
  *.lua            class modules (combat helper, …), listed in class.json "modules"
  Media/           Logo.tga and Icon.tga
  CHANGELOG.md     release notes; the first line is the version
tools/build.py   builds dist/<Addon>/ from core + class
tools/release.py builds, tests and releases new versions (used by GitHub Actions)
tests/           WoW API simulator, one per class, and a Lua syntax check
```

Core files use placeholders that the build fills from `class.json`: `@ADDON@`, `@ADDONUP@`,
`@ADDONLOW@`, `@COLOR@`, `@SLASH@` and `@CLASS@`.

## Building and testing

```sh
python3 tools/build.py                 # all addons into dist/
python3 tools/build.py druid           # just one
lua5.3 tests/druid.lua dist/DruidPlan modern enUS   # ends with "--- FEL (0) ---" when all is well
```

## Releasing

1. Change the code (core/ for everyone, classes/<class>/ for one class).
2. Put the new version's notes at the top of that class's `CHANGELOG.md`, starting with a
   heading like `# DruidPlan 1.0.1`. A core change that should reach everyone needs a new
   version in each class's CHANGELOG.
3. Push to `main`. For every addon with a new version, GitHub Actions builds it, runs the
   tests, uploads it to its CurseForge project and makes a GitHub release.

Use a version like `1.0.1-beta1` to upload a beta. Needs the repository secret `CF_API_KEY`.

## Adding a class

Copy a class folder, change `class.json` (name, color, slash, class token, CurseForge ID),
write its Data.lua, TrainData.lua, LocaleClass.lua and combat module, generate its
DungeonData.lua and add the art.

## Talent plans

A class can have several plans (specs) in `ns.PLAN_ORDER` / `ns.PLAN_STEPS`, each with its own
stat weights (`ns.PLAN_WEIGHTS`) and texts (`KEY@plan` in LocaleClass.lua). Check them against
the live tree after every change:

```sh
texlua tools/checktalents.lua warrior
```

`tools/exporttrees.py` refreshes `tools/trees/` from the client data.

## Data

- Dungeon quests: `QDB=path/to/QuestieDB texlua tools/gendungeons.lua <class> classes/<class>/DungeonData.lua`
  from [QuestieDB](https://github.com/Questie/QuestieDB)'s Forever data (GPL-3.0); run
  `tools/export-forever.lua --include-authored` in QuestieDB first.
- Talent trees, trainer ranks and profession recipes: WoW Forever client data
  (build 1.60.1.70790).

## License

GPL-3.0, see `LICENSE`.
