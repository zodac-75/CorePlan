#!/usr/bin/env python3
"""Translations for the Plan addons.

lang/<code>/*.txt holds one language (deDE, ruRU, ...), as many files as you like. Sections:

    [core]        KEY = text            shared texts (core/Locale.lua)
    [<class>]     KEY = text            class texts (classes/<class>/LocaleClass.lua)
    [data]        hhhhhh = text         data texts: { "English", "Svenska" } pairs in the Lua files,
                                        hhhhhh = crc32 of the English text (hex)

In a text, \\n is a new line and \\\\ a backslash. Texts missing from a language show in English.
tools/build.py and tools/buildall.py put the languages in Languages.lua (only the texts the addon uses).

    python3 tools/langs.py dump        what to translate -> /tmp/langsrc/*.txt
    python3 tools/langs.py check       placeholders and coverage of every language
"""
import glob
import os
import re
import sys
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANG_DIR = os.path.join(ROOT, "lang")

# code -> name in the language itself, in the order the menu cycles them
LANGS = [("deDE", "Deutsch"), ("ruRU", "Русский"), ("frFR", "Français"), ("esES", "Español"), ("ptBR", "Português")]

STR = r'"((?:[^"\\]|\\.)*)"'
KEY = r'(?:\.([A-Za-z0-9_]+)|\["([^"]+)"\])'


def unlua(s):
    return re.sub(r"\\(.)", lambda m: "\n" if m.group(1) == "n" else m.group(1), s)


def tolua(s):
    return s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def totxt(s):
    return s.replace("\\", "\\\\").replace("\n", "\\n")


def fromtxt(s):
    return re.sub(r"\\(.)", lambda m: "\n" if m.group(1) == "n" else m.group(1), s)


def ui_strings(path):
    """{key: English text} of the E.* lines in a Locale file."""
    out = {}
    with open(path, encoding="utf-8") as f:
        for line in f:
            m = re.match(r"^E" + KEY + r"\s*=\s*" + STR + r"\s*$", line)
            if m:
                out[m.group(1) or m.group(2)] = unlua(m.group(3))
                continue
            m = re.match(r"^E" + KEY + r",\s*S" + KEY + r"\s*=\s*" + STR + r"\s*,\s*" + STR + r"\s*$", line)
            if m:
                out[m.group(1) or m.group(2)] = unlua(m.group(5))
    return out


PAIR = re.compile(r'\{\s*' + STR + r'\s*,\s*' + STR + r'\s*\}')


def h(english):
    return "%08x" % (zlib.crc32(english.encode("utf-8")) & 0xffffffff)


def data_strings(text):
    """{hash: English} of the { "English", "Svenska" } pairs in some Lua text."""
    out = {}
    for a, _ in PAIR.findall(text):
        a = unlua(a)
        if not re.search(r"%[^ ]", a) and a != "English":  # tooltip search patterns and the doc comment aren't texts
            out[h(a)] = a
    return out


def classes():
    return sorted(d for d in os.listdir(os.path.join(ROOT, "classes"))
                  if os.path.isfile(os.path.join(ROOT, "classes", d, "class.json")))


def all_data():
    out = {}
    paths = glob.glob(os.path.join(ROOT, "core", "*.lua")) + glob.glob(os.path.join(ROOT, "classes", "*", "*.lua"))
    for p in paths:
        with open(p, encoding="utf-8") as f:
            out.update(data_strings(f.read()))
    return out


def load(code):
    """{section: {key: text}} of lang/<code>.txt (empty when the language isn't there)."""
    out = {}
    for path in sorted(glob.glob(os.path.join(LANG_DIR, code, "*.txt"))):
        sec = None
        with open(path, encoding="utf-8") as f:
            for n, line in enumerate(f, 1):
                line = line.rstrip("\n")
                if not line.strip() or line.startswith("#"):
                    continue
                m = re.match(r"^\[([a-z]+)\]$", line)
                if m:
                    sec = out.setdefault(m.group(1), {})
                    continue
                m = re.match(r"^(\S+) = (.*)$", line)
                if not m or sec is None:
                    sys.exit("%s:%d: can't read '%s'" % (path, n, line))
                sec[m.group(1)] = fromtxt(m.group(2))
    return out


def render(cls, code_text, langs=LANGS):
    """Languages.lua for a class: its texts and the data texts that the addon's Lua uses."""
    used = data_strings(code_text)
    lines = ["-- @ADDON@: translations (generated from lang/*.txt by tools/build.py). Missing texts show in English.",
             "local _, ns = ...", "ns.TX = ns.TX or {}"]
    for code, name in langs:
        t = load(code)
        core, mine, data = t.get("core", {}), t.get(cls, {}), t.get("data", {})
        lines.append("do local L = ns.LOCALES.%s" % code)
        for sec in (core, mine):
            for k in sorted(sec):
                lines.append('L["%s"] = "%s"' % (k, tolua(sec[k])))
        lines.append("ns.TX.%s = {" % code)
        for hh in sorted(used):
            if hh in data:
                lines.append('["%s"] = "%s",' % (tolua(used[hh]), tolua(data[hh])))
        lines.append("} end")
    return "\n".join(lines) + "\n"


PLACEHOLDER = re.compile(r"%[-+#0]*\d*(?:\.\d+)?[sdfgxX%]|\|c[0-9a-fA-F]{8}|\|r|@[A-Z]+@|\|n|\n")


def parts(s):
    return sorted(PLACEHOLDER.findall(s))


def check():
    en_core = ui_strings(os.path.join(ROOT, "core", "Locale.lua"))
    en = {"core": en_core, "data": all_data()}
    for c in classes():
        en[c] = ui_strings(os.path.join(ROOT, "classes", c, "LocaleClass.lua"))
    bad = 0
    for code, name in LANGS:
        t = load(code)
        miss = 0
        for sec, src in en.items():
            have = t.get(sec, {})
            for k in have:
                if k not in src:
                    print("%s [%s] %s: not in the source (old?)" % (code, sec, k)); bad += 1
                elif parts(have[k]) != parts(src[k]):
                    print("%s [%s] %s: placeholders differ\n   en: %s\n   %s: %s" % (code, sec, k, src[k], code, have[k])); bad += 1
            miss += len([k for k in src if k not in have])
        print("%s: %d of %d texts missing" % (code, miss, sum(len(s) for s in en.values())))
    return bad


def dump():
    out = "/tmp/langsrc"
    os.makedirs(out, exist_ok=True)
    with open(os.path.join(out, "core.txt"), "w", encoding="utf-8") as f:
        f.write("[core]\n")
        for k, v in ui_strings(os.path.join(ROOT, "core", "Locale.lua")).items():
            f.write("%s = %s\n" % (k, totxt(v)))
    with open(os.path.join(out, "data.txt"), "w", encoding="utf-8") as f:
        f.write("[data]\n")
        for k, v in all_data().items():
            f.write("%s = %s\n" % (k, totxt(v)))
    with open(os.path.join(out, "classes.txt"), "w", encoding="utf-8") as f:
        for c in classes():
            f.write("[%s]\n" % c)
            for k, v in ui_strings(os.path.join(ROOT, "classes", c, "LocaleClass.lua")).items():
                f.write("%s = %s\n" % (k, totxt(v)))


if __name__ == "__main__":
    if sys.argv[1:] == ["dump"]:
        dump()
    elif sys.argv[1:] == ["check"]:
        sys.exit(1 if check() else 0)
    else:
        sys.exit(__doc__)
