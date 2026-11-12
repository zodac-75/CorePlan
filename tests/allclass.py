#!/usr/bin/env python3
"""Tests AllClassPlan (tools/buildall.py).

    python3 tests/allclass.py [lua]      # lua defaults to texlua

1. Builds AllClassPlan into a temp folder.
2. Runs every class's own simulator test (tests/<class>.lua) against its AllClassPlan part,
   in all four modes, with the addon's names swapped (MagePlan -> AllClassPlan,
   MagePlan.toc -> AllClassPlan_Mage.toc).
3. Runs tests/allclass_loader.lua against the loader.

Prints one line per run and ends with "--- FEL (n) ---".
"""
import os
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build  # noqa: E402
import buildall  # noqa: E402


def main():
    lua = sys.argv[1] if len(sys.argv) > 1 else "texlua"
    fails = []
    with tempfile.TemporaryDirectory() as tmp:
        out = os.path.join(tmp, "out")
        with open(os.devnull, "w") as null:
            sys.stdout, real = null, sys.stdout
            try:
                buildall.main(["--out", out])
            finally:
                sys.stdout = real
        name = buildall.info()["name"]
        for cls in build.classes():
            standalone = build.meta(cls)["name"]
            part = buildall.part_name(cls)
            with open(os.path.join(ROOT, "tests", cls + ".lua"), encoding="utf-8") as f:
                text = f.read()
            text = text.replace('"/%s.toc"' % standalone, '"/%s.toc"' % part)
            text = (text.replace(standalone, name).replace(standalone.upper(), name.upper())
                    .replace(standalone.lower(), name.lower()))
            test = os.path.join(tmp, cls + ".lua")
            with open(test, "w", encoding="utf-8") as f:
                f.write(text)
            for mode in ("classic", "modern"):
                for lang in ("enUS", "svSE"):
                    r = subprocess.run([lua, test, os.path.join(out, part), mode, lang],
                                       capture_output=True, text=True, cwd=tmp)
                    last = (r.stdout.strip().splitlines() or [""])[-1]
                    ok = last == "--- FEL (0) ---"
                    print("%-22s %-8s %s  %s" % (part, mode, lang, "ok" if ok else "FAIL " + last))
                    if not ok:
                        fails.append("%s %s %s" % (part, mode, lang))
        r = subprocess.run([lua, os.path.join(ROOT, "tests", "allclass_loader.lua"),
                            os.path.join(out, name)], capture_output=True, text=True)
        print(r.stdout.rstrip())
        if (r.stdout.strip().splitlines() or [""])[-1] != "--- FEL (0) ---":
            fails.append("loader")
    print("--- FEL (%d) ---" % len(fails))
    for f in fails:
        print(f)
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
