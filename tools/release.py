#!/usr/bin/env python3
"""Releases every Plan addon whose version in classes/<class>/CHANGELOG.md is new.

Used by .github/workflows/release.yml. For each class whose tag "<Addon>-<version>"
doesn't exist yet it:
  1. builds the addon (tools/build.py),
  2. runs the syntax check and the simulator tests (tests/),
  3. packages it with the BigWigs packager, which uploads it to the addon's own
     CurseForge project (X-Curse-Project-ID in the generated .toc),
  4. tags the commit and makes a GitHub release with the zip.

A version containing "beta" or "alpha" becomes a beta/alpha file on CurseForge.
Environment: CF_API_KEY, GH_TOKEN, PACKAGER (path to the packager's release.sh),
LUA (Lua 5.3 interpreter for the tests, default "lua5.3").
"""
import glob
import os
import shutil
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import build  # noqa: E402

LUA = os.environ.get("LUA", "lua5.3")


def run(cmd, cwd=None, env=None, capture=False):
    print("+", " ".join(cmd), flush=True)
    r = subprocess.run(cmd, cwd=cwd, env=env, text=True,
                       stdout=subprocess.PIPE if capture else None,
                       stderr=subprocess.STDOUT if capture else None)
    if r.returncode != 0:
        if capture:
            print(r.stdout)
        sys.exit("failed: " + " ".join(cmd))
    return r.stdout if capture else ""


def tag_exists(tag):
    return subprocess.run(["git", "rev-parse", "-q", "--verify", "refs/tags/" + tag],
                          cwd=ROOT, stdout=subprocess.DEVNULL).returncode == 0


def test(cls, addon_dir):
    run(["texlua" if shutil.which("texlua") else LUA, os.path.join(ROOT, "tools", "checktalents.lua"), cls], cwd=ROOT)
    run([sys.executable, os.path.join(ROOT, "tests", "luablocks.py")] + glob.glob(os.path.join(addon_dir, "*.lua")))
    for mode in ("classic", "modern"):
        for lang in ("enUS", "svSE"):
            out = run([LUA, os.path.join(ROOT, "tests", cls + ".lua"), addon_dir, mode, lang], capture=True)
            if "--- FEL (0) ---" not in out:
                print(out[-4000:])
                sys.exit("%s: simulator test failed (%s %s)" % (cls, mode, lang))
    print("%s: tests passed" % cls)


def release(cls):
    meta = build.meta(cls)
    name, version = meta["name"], build.version_of(cls)
    tag = "%s-%s" % (name, version)
    if tag_exists(tag):
        print("%s %s is already released." % (name, version))
        return
    print("== Releasing %s %s" % (name, version), flush=True)

    out = os.path.join(ROOT, "dist")
    addon_dir, _, _ = build.build(cls, out, version)
    test(cls, addon_dir)

    # The packager works on a git checkout tagged with the version.
    shutil.copy(os.path.join(ROOT, "classes", cls, "CHANGELOG.md"), os.path.join(addon_dir, "CHANGELOG.md"))
    with open(os.path.join(addon_dir, ".pkgmeta"), "w") as f:
        f.write("package-as: %s\n\nmanual-changelog:\n  filename: CHANGELOG.md\n  markup-type: markdown\n\n"
                "ignore:\n  - CHANGELOG.md\n" % name)
    git = ["git", "-c", "user.name=github-actions[bot]",
           "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com"]
    run(["git", "init", "-q", "-b", "main"], cwd=addon_dir)
    run(["git", "add", "-A"], cwd=addon_dir)
    run(git + ["commit", "-q", "-m", tag], cwd=addon_dir)
    run(git + ["tag", "-a", version, "-m", tag], cwd=addon_dir)
    env = dict(os.environ, GITHUB_EVENT_NAME="release", GITHUB_REF="refs/tags/" + version,
               GITHUB_REF_NAME=version)
    env.pop("GITHUB_OAUTH", None)  # the GitHub release is made below, in this repo
    run([os.environ["PACKAGER"], "-g", "1.60.1", "-n", "{package-name}-{project-version}"],
        cwd=addon_dir, env=env)
    zips = glob.glob(os.path.join(addon_dir, ".release", "*.zip"))
    if not zips:
        sys.exit("%s: the packager made no zip" % name)

    run(git + ["tag", "-a", tag, "-m", tag], cwd=ROOT)
    run(["git", "push", "origin", tag], cwd=ROOT)
    notes = os.path.join(addon_dir, "CHANGELOG.md")
    cmd = ["gh", "release", "create", tag, zips[0], "--title", "%s %s" % (name, version), "--notes-file", notes]
    if "beta" in version or "alpha" in version:
        cmd.append("--prerelease")
    run(cmd, cwd=ROOT)


def main():
    for cls in build.classes():
        release(cls)


if __name__ == "__main__":
    main()
