# Working on CorePlan

WoW Forever leveling addons, one per class, sharing `core/`. README.md has the layout, build,
tests and release steps. This file has the rules and the things that bit us before.

## How the owner wants it

- He writes Swedish or English: answer in the same language.
- **Always commit and push.** Every fix and feature is released to all users right away: bump
  every affected class's CHANGELOG (a core change bumps all classes) and push to `main`. CI
  uploads to CurseForge. Check the upload:
  `gh api 'repos/zodac-75/CorePlan/actions/runs?per_page=1'` then
  `gh run view <id> -R zodac-75/CorePlan --log | grep Uploading` (`gh run list` doesn't work).
- **Never** paste or ask for the CurseForge API token. It lives only in the repo secret `CF_API_KEY`.
- **Install on his PC** when the session is linked to his computer:
  `D:\Blizzard\World of Warcraft\_forever_\Interface\AddOns\<Addon>\`, copying from the build
  output. New files need a full game restart; changed files only `/reload`. Tell him which.
- **CurseForge descriptions**: update them when a real feature lands (not for small
  fixes), in the built-in browser where he is logged in (authors.curseforge.com/#/projects/<id>/description).
  The editor is TinyMCE: `tinymce.activeEditor.setContent(html)` without the final ".", type
  the "." with a real keystroke, then click Save and check "Changes saved successfully".
  Wait until the editor content starts with `<h2><Addon></h2>` before editing (the page is an SPA
  and keeps the old project's text for a moment). If logged out, tell him; don't log in.
- Every addon gets every core feature ("same on all addons").
- The CurseForge texts live in `docs/curseforge/`: `kit.html` (name, summary, categories,
  description and first comment for every addon; also published as his "CurseForge kit"
  artifact) and one `<Addon>.html` per addon, written by `node docs/curseforge/export.js`.
  Change the kit, export, push, then in the browser fetch
  `https://raw.githubusercontent.com/zodac-75/CorePlan/main/docs/curseforge/<Addon>.html`
  and put it in the editor (see above).

## Addons

| Addon | Slash | CurseForge ID |
|---|---|---|
| MagePlan | /mp | 1785085 |
| ShamanPlan | /sp | 1787755 |
| DruidPlan | /dp | 1787775 |
| WarriorPlan | /war | 1787968 |
| PaladinPlan | /pal | 1787977 |
| WarlockPlan | /wl | 1792150 |
| PriestPlan | /pp | 1792569 |
| HunterPlan | /hp | 1793633 |
| RoguePlan | /rp | 1794105 |

A new class has no `curseId` in class.json until he creates the CurseForge project and sends the
link; until then CI only makes a GitHub release. He needs a logo (Media/Logo.tga, Icon.tga) and a
description for the project; descriptions are generated from the same text for every addon.

## WoW Forever gotchas

- **Taint**: never parent our frames to Blizzard frames, never call ShowUIPanel/HideUIPanel or
  open/toggle Blizzard panels from addon code. Our glow/hint frames live on UIParent.
  Anchoring to a Blizzard frame is fine.
- **Secret values**: mana is secret even out of combat; aura names/times and rank text can be
  secret. Check with `ns.Readable(v)`. For mana use `C_CurveUtil.CreateCurve` (Step) +
  `UnitPowerPercent(unit, 0, false, curve)` and feed the secret into `frame:SetAlpha`.
  For buffs, fall back to `C_UnitAuras.GetAuraDataBySpellName`.
- **Secure buttons** (buff watcher, bag check): set `type1`/`spell1`/`macrotext1` only out of
  combat; clear them and hide on `PLAYER_REGEN_DISABLED`. Right-click handled in `OnMouseUp`.
  Register clicks `("AnyUp", "AnyDown")`.

## Making a new class (e.g. hunter)

Copy the closest class folder (PriestPlan is the newest pattern). Data sources:

- Talent trees and leveling abilities: https://github.com/brainw0rm/forge (clone it).
  `python3 tools/exporttrees.py forge/public/data/classes` (also writes classes/<class>/TalentIds.lua
  for the forge link import; trees already exported for all
  classes incl. hunter), then plan the specs in Data.lua and check with
  `texlua tools/checktalents.lua <class>` until it reports no problems.
- Trainer: `python3 tools/gentrain.py <class> classes/<class>/TrainData.lua forge` writes the rank
  table and prints `ns.spells` for Data.lua (drop racial spells).
- Dungeons: clone https://github.com/Questie/QuestieDB, run its `tools/export-forever.lua
  --include-authored`, then `QDB=QuestieDB texlua tools/gendungeons.lua <class> classes/<class>/DungeonData.lua`.
- Tests: copy `tests/priest.lua` to `tests/<class>.lua`, adjust names/spells, and run all four
  modes: `texlua tests/<class>.lua <out>/<Addon> classic|modern enUS|svSE` must end with
  `--- FEL (0) ---`. Run every class's tests after a core change.
- Add the class to the README table and to the CLASSES/class lists in the tools.
