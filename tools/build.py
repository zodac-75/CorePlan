#!/usr/bin/env python3
"""Builds the Plan addons from the shared core and the class folders.

    python3 tools/build.py [class ...] [--out dist] [--version 1.2.3]

For each class (mage, shaman, druid, ... = the folders in classes/) this writes
<out>/<AddonName>/ with core/*.lua, core/Media, the class's .lua files and Media,
the LICENSE and a generated .toc. Placeholders in the core are filled from the
class's class.json:

    @ADDON@ / @ADDONUP@ / @ADDONLOW@   addon name (MagePlan / MAGEPLAN / mageplan)
    @COLOR@                            class color for chat and window titles
    @SLASH@                            short slash command (mp -> /mp)
    @CLASS@                            class token the addon runs for (MAGE)

The version is read from the first line of classes/<class>/CHANGELOG.md
("# MagePlan 1.8.0") unless --version is given.
"""
import json
import os
import re
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Load order. Class modules (class.json "modules") go where CLASS_MODULES is.
ORDER = [
    "Locale.lua", "LocaleClass.lua", "Data.lua", "TrainData.lua", "ProfData.lua",
    "Core.lua", "Rows.lua", "Plans.lua", "Ranks.lua", "Talents.lua", "Trainer.lua", "Helper.lua",
    "CLASS_MODULES",
    "Craft.lua", "Upgrades.lua", "ZoneTips.lua", "Goals.lua", "XP.lua", "QuestReward.lua",
    "Drink.lua", "Minimap.lua", "DungeonData.lua", "Arrow.lua", "Dungeons.lua",
    "Config.lua", "Profiles.lua", "Emotes.lua",
]


def classes():
    return sorted(d for d in os.listdir(os.path.join(ROOT, "classes"))
                  if os.path.isfile(os.path.join(ROOT, "classes", d, "class.json")))


def meta(cls):
    with open(os.path.join(ROOT, "classes", cls, "class.json"), encoding="utf-8") as f:
        return json.load(f)


def version_of(cls):
    m = meta(cls)
    with open(os.path.join(ROOT, "classes", cls, "CHANGELOG.md"), encoding="utf-8") as f:
        first = f.readline()
    v = re.match(r"^# %s ([0-9][0-9.]*(?:-[A-Za-z0-9.]+)?)\s*$" % re.escape(m["name"]), first)
    if not v:
        sys.exit("classes/%s/CHANGELOG.md must start with '# %s <version>'" % (cls, m["name"]))
    return v.group(1)


def fill(text, m):
    name = m["name"]
    return (text.replace("@ADDONUP@", name.upper()).replace("@ADDONLOW@", name.lower())
            .replace("@ADDON@", name).replace("@COLOR@", m["color"])
            .replace("@SLASH@", m["slash"]).replace("@CLASS@", m["class"]))


def toc(m, version, files):
    lines = [
        "## Interface: 16001, 11509",
        "## Title: " + m["name"],
        "## Notes: " + m["notes"],
        "## Author: zodac",
        "## IconTexture: Interface\\AddOns\\%s\\Media\\Icon" % m["name"],
        "## Version: " + version,
        "## SavedVariables: %sGlobal" % m["name"],
        "## SavedVariablesPerCharacter: %sDB" % m["name"],
    ]
    if m.get("optionalDeps"):
        lines.append("## OptionalDeps: " + m["optionalDeps"])
    if m.get("curseId"):  # no ID yet: the release goes to GitHub only
        lines.append("## X-Curse-Project-ID: %d" % m["curseId"])
    lines += ["## X-License: GPL-3.0", ""]
    return "\n".join(lines + files) + "\n"


def build(cls, out, version=None):
    m = meta(cls)
    version = version or version_of(cls)
    dest = os.path.join(out, m["name"])
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(os.path.join(dest, "Media"))

    sources = {}
    for folder in (os.path.join(ROOT, "core"), os.path.join(ROOT, "classes", cls)):
        for f in os.listdir(folder):
            if f.endswith(".lua"):
                if f in sources:
                    sys.exit("%s is in both the core and classes/%s" % (f, cls))
                sources[f] = os.path.join(folder, f)
        media = os.path.join(folder, "Media")
        if os.path.isdir(media):
            for f in os.listdir(media):
                shutil.copy(os.path.join(media, f), os.path.join(dest, "Media", f))

    files = []
    for f in ORDER:
        if f == "CLASS_MODULES":
            files += m.get("modules", [])
        elif f in sources:
            files.append(f)
    missing = [f for f in files if f not in sources]
    unlisted = sorted(set(sources) - set(files))
    if missing or unlisted:
        sys.exit("%s: missing %s, not in the load order %s" % (cls, missing, unlisted))

    for f in files:
        with open(sources[f], encoding="utf-8") as src:
            text = fill(src.read(), m)
        if "@" in re.sub(r"@project-version@", "", text) and re.search(r"@[A-Z]+@", text):
            sys.exit("%s: unfilled placeholder in %s" % (cls, f))
        with open(os.path.join(dest, f), "w", encoding="utf-8") as dst:
            dst.write(text)
    with open(os.path.join(ROOT, "LICENSE"), encoding="utf-8") as src:
        lic = src.read().replace("@ADDON@", m["name"])
    with open(os.path.join(dest, "LICENSE"), "w", encoding="utf-8") as dst:
        dst.write(lic)
    with open(os.path.join(dest, m["name"] + ".toc"), "w", encoding="utf-8") as dst:
        dst.write(toc(m, version, files))
    return dest, m, version


def main(argv):
    out, version, wanted = os.path.join(ROOT, "dist"), None, []
    i = 0
    while i < len(argv):
        if argv[i] == "--out":
            out = argv[i + 1]; i += 2
        elif argv[i] == "--version":
            version = argv[i + 1]; i += 2
        else:
            wanted.append(argv[i]); i += 1
    for cls in wanted or classes():
        dest, m, v = build(cls, out, version)
        print("%s %s -> %s" % (m["name"], v, dest))


if __name__ == "__main__":
    main(sys.argv[1:])
