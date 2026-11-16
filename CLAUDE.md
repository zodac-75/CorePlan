# Working on CorePlan

WoW Forever leveling addons, one per class, sharing `core/`. README.md has the layout, build,
tests and release steps. This file has the rules and the things that bit us before.

## How the owner wants it

- He writes Swedish or English: answer in the same language.
- **From now on only AllClassPlan is updated.** The nine stand-alone addons are frozen: do not bump
  their CHANGELOGs (CI only uploads a class when its version is new, so no bump = no release). Bump
  `allclass/CHANGELOG.md` for every change and push; the shared `core/` and `classes/` code still
  builds into AllClassPlan. (Languages went out to the old nine by mistake on 2026-11-13.) On 2026-11-13 he said go for the move notice: the nine got one last release with `ns.ACP_LIVE = true` and the AllClassPlan logo (core/Media/ACP.tga) in the popup. Frozen again after that.
- **Test on his PC before pushing (since 2026-11-14).** Build, run the tests, install the changed files on his PC (when linked) and tell him what to test. Commit and push only after he says it works / gives the go-ahead. Gather several fixes into one release instead of many small patches. Without a linked PC, ask before pushing. This is for addon changes; repo notes like this file can be pushed right away.
- **Commit and push when he approves** (AllClassPlan, see above). Every fix and feature is released to all users right away: bump
  `allclass/CHANGELOG.md` (never the nine class CHANGELOGs) and push to `main`. CI
  uploads to CurseForge. Check the upload:
  `gh api 'repos/zodac-75/CorePlan/actions/runs?per_page=1'` then
  `gh run view <id> -R zodac-75/CorePlan --log | grep Uploading` (`gh run list` doesn't work).
- **Notes, release zips and images live outside this repo**, on his own storage (the folder is connected when the PC is linked; the full paths and the overview are in the overview CLAUDE.md there, kept out of this public repo on purpose). After each AllClassPlan release put `AllClassPlan-<version>.zip` (the same folders as the CurseForge package) in its Releases folder; logos, icons and screenshots are in its Bilder folder. After every addon change or release update the "Läge just nu" section and add a line at the top of the "Logg" of that overview; update the paste-in prompt when the way of working changes. Keep private details (paths, drive letters, character and player names) out of this file, the code comments and the changelogs; they belong in that overview.
- **Never** paste or ask for the CurseForge API token. It lives only in the repo secret `CF_API_KEY`.
- **Install on his PC** when the session is linked to his computer:
  the WoW `_forever_\Interface\AddOns\<Addon>\` folder (path in the overview), copying from the build
  output. New files need a full game restart; changed files only `/reload`. Tell him which.
- **CurseForge descriptions**: update them when a real feature lands (not for small
  fixes), in Chrome where he is logged in (authors.curseforge.com/#/projects/<id>/description;
  the built-in browser is logged out). Release uploads go by CI, but the API cannot change the
  description, so this is the one manual step. Since 2026-11-15 the AllClassPlan editor is in
  **Markdown mode** (a textarea with the Markdown source and a live preview, not TinyMCE). Edit
  the existing text: read the textarea, `replace` the exact lines, set it with the native value
  setter plus an `input` event, check the preview, click Save and look for "Changes saved
  successfully". Keep the easter egg line as it is (only the five examples, no more hints).
  If logged out, tell him; don't log in. `docs/curseforge/AllClassPlan.html` is the same text as
  HTML for reference; keep it in step with what is on the page.
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
- **Client language**: data and code name spells, auras and talents in English. Anything that asks
  the game by name goes through `ns.Loc(name)` (English -> client name), and names from the game
  through `ns.Eng(name)` (`ns.ForEachAura` already does that). Both need the spell's ID in
  `core/SpellIds.lua`; a new spell name needs `python3 tools/genspellids.py SpellName.csv` (the csv
  from wago.tools for the current build; the sandbox can't reach wago, fetch it in his Chrome).
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
