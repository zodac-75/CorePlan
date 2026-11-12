#!/usr/bin/env python3
"""Builds AllClassPlan: every class in one install.

    python3 tools/buildall.py [--out dist] [--version 0.1.0]

Writes <out>/AllClassPlan/ (a small loader, allclass/Loader.lua) and one load-on-demand part
per class, <out>/AllClassPlan_Mage/, <out>/AllClassPlan_Paladin/, ... Each part is the
normal class build from core/ + classes/<class>/, with the addon name AllClassPlan instead
of MagePlan, so the windows, chat lines and settings say AllClassPlan. Only one part is
loaded per character (the loader picks it by class), so the parts can share the
AllClassPlan* global names.

AllClassPlan lives in allclass/, not classes/, so tools/release.py (CI) never uploads it.
The version comes from the first line of allclass/CHANGELOG.md ("# AllClassPlan 0.1.0").
"""
import json
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import build  # noqa: E402

ROOT = build.ROOT
HERE = os.path.join(ROOT, "allclass")


def info():
    with open(os.path.join(HERE, "allclass.json"), encoding="utf-8") as f:
        return json.load(f)


def version():
    name = info()["name"]
    with open(os.path.join(HERE, "CHANGELOG.md"), encoding="utf-8") as f:
        first = f.readline()
    v = re.match(r"^# %s ([0-9][0-9.]*(?:-[A-Za-z0-9.]+)?)\s*$" % re.escape(name), first)
    if not v:
        sys.exit("allclass/CHANGELOG.md must start with '# %s <version>'" % name)
    return v.group(1)


def suffix(cls):
    """MagePlan -> Mage."""
    return build.meta(cls)["name"][:-len("Plan")]


def part_name(cls):
    return info()["name"] + "_" + suffix(cls)


def write(path, text):
    with open(path, "w", encoding="utf-8") as f:
        f.write(text)


def build_part(cls, out, ver):
    acp = info()
    m = dict(build.meta(cls))
    standalone = m["name"]
    m["name"] = acp["name"]  # @ADDON@ = AllClassPlan in globals, chat and window titles
    folder = part_name(cls)
    dest = os.path.join(out, folder)
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(os.path.join(dest, "Media"))

    sources = {}
    for src in (os.path.join(ROOT, "core"), os.path.join(ROOT, "classes", cls)):
        for f in os.listdir(src):
            if f.endswith(".lua"):
                if f in sources:
                    sys.exit("%s is in both the core and classes/%s" % (f, cls))
                sources[f] = os.path.join(src, f)
        media = os.path.join(src, "Media")
        if os.path.isdir(media):
            for f in os.listdir(media):
                shutil.copy(os.path.join(media, f), os.path.join(dest, "Media", f))

    files = []
    for f in build.ORDER:
        if f == "CLASS_MODULES":
            files += m.get("modules", [])
        elif f in sources:
            files.append(f)
    if [f for f in files if f not in sources] or set(sources) - set(files):
        sys.exit("%s: load order doesn't match the files" % cls)

    slash_up = acp["name"].upper()
    for f in files:
        with open(sources[f], encoding="utf-8") as src:
            text = build.fill(src.read(), m)
        if re.search(r"@[A-Z]+@", re.sub(r"@project-version@", "", text)):
            sys.exit("%s: unfilled placeholder in %s" % (cls, f))
        if f == "Core.lua":
            # /acp next to the class's own command (/mp, /pal, ...).
            line = 'SLASH_%s2 = "/%s"\n' % (slash_up, m["slash"])
            if line not in text:
                sys.exit("Core.lua: slash line not found")
            text = text.replace(line, line + 'SLASH_%s3 = "/%s"\n' % (slash_up, acp["slash"]))
        write(os.path.join(dest, f), text)

    with open(os.path.join(ROOT, "LICENSE"), encoding="utf-8") as src:
        write(os.path.join(dest, "LICENSE"), src.read().replace("@ADDON@", acp["name"]))
    toc = [
        "## Interface: 16001, 11509",
        "## Title: %s |cff%s%s|r" % (acp["name"], m["color"], suffix(cls)),
        "## Notes: The %s part of %s (same as %s). Loaded by %s on %s characters." % (
            suffix(cls), acp["name"], standalone, acp["name"], suffix(cls).lower()),
        "## Author: zodac",
        "## IconTexture: Interface\\AddOns\\%s\\Media\\Icon" % folder,
        "## Version: " + ver,
        "## LoadOnDemand: 1",
        "## Dependencies: " + acp["name"],
        # Language and profiles (AllClassPlanGlobal) are saved by the loader, shared by all
        # characters; the per-character settings are saved by each part.
        "## SavedVariablesPerCharacter: %sDB" % acp["name"],
        "## OptionalDeps: " + m.get("optionalDeps", "Auctionator"),
        "## X-License: GPL-3.0",
        "",
    ]
    write(os.path.join(dest, folder + ".toc"), "\n".join(toc + files) + "\n")
    return dest, standalone


def build_loader(out, ver, parts):
    acp = info()
    dest = os.path.join(out, acp["name"])
    if os.path.exists(dest):
        shutil.rmtree(dest)
    os.makedirs(dest)
    rows = []
    for cls, standalone in parts:
        m = build.meta(cls)
        rows.append('  %s = { suffix = "%s", standalone = "%s", color = "%s" },' % (
            m["class"], suffix(cls), standalone, m["color"]))
    with open(os.path.join(HERE, "Loader.lua"), encoding="utf-8") as f:
        text = f.read()
    if "--@CLASSES@" not in text:
        sys.exit("allclass/Loader.lua: --@CLASSES@ missing")
    write(os.path.join(dest, "Loader.lua"), text.replace("--@CLASSES@", "\n".join(rows)))
    with open(os.path.join(ROOT, "LICENSE"), encoding="utf-8") as src:
        write(os.path.join(dest, "LICENSE"), src.read().replace("@ADDON@", acp["name"]))
    toc = [
        "## Interface: 16001, 11509",
        "## Title: " + acp["name"],
        "## Notes: " + acp["notes"],
        "## Author: zodac",
        "## IconTexture: Interface\\Icons\\INV_Misc_Book_09",
        "## Version: " + ver,
        "## SavedVariables: %sGlobal" % acp["name"],
        # The stand-alone class addons load first, so the loader can see them and step aside.
        "## OptionalDeps: Auctionator, " + ", ".join(s for _, s in parts),
        "## X-License: GPL-3.0",
        "",
        "Loader.lua",
    ]
    write(os.path.join(dest, acp["name"] + ".toc"), "\n".join(toc) + "\n")
    return dest


def main(argv):
    out, ver = os.path.join(ROOT, "dist"), None
    i = 0
    while i < len(argv):
        if argv[i] == "--out":
            out = argv[i + 1]; i += 2
        elif argv[i] == "--version":
            ver = argv[i + 1]; i += 2
        else:
            sys.exit("unknown argument " + argv[i])
    ver = ver or version()
    parts = []
    for cls in build.classes():
        dest, standalone = build_part(cls, out, ver)
        parts.append((cls, standalone))
        print("%s %s -> %s" % (part_name(cls), ver, dest))
    print("%s %s -> %s" % (info()["name"], ver, build_loader(out, ver, parts)))


if __name__ == "__main__":
    main(sys.argv[1:])
