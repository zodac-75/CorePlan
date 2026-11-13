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


def latest_notes(cls, name, version):
    """The top section of classes/<cls>/CHANGELOG.md, as Markdown for CurseForge."""
    with open(os.path.join(ROOT, "classes", cls, "CHANGELOG.md"), encoding="utf-8") as f:
        lines = f.read().splitlines()
    body = []
    for line in lines[1:]:
        if line.startswith("# "):
            break
        body.append(line)
    text = "\n".join(body).strip()
    return "## %s %s\n\n%s\n" % (name, version, text)


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
    # The file's changelog on CurseForge and GitHub: only this version's notes, not the
    # whole history (the full CHANGELOG.md stays in the repo).
    with open(os.path.join(addon_dir, "CHANGELOG.md"), "w", encoding="utf-8") as f:
        f.write(latest_notes(cls, name, version))
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


def release_allclass():
    """AllClassPlan (allclass/): the loader and every class part in one zip, one project."""
    import buildall
    acp = buildall.info()
    name, version = acp["name"], buildall.version()
    tag = "%s-%s" % (name, version)
    if tag_exists(tag):
        print("%s %s is already released." % (name, version))
        return
    print("== Releasing %s %s" % (name, version), flush=True)
    env = dict(os.environ, LUA=LUA)
    run([sys.executable, os.path.join(ROOT, "tests", "allclass.py")], cwd=ROOT, env=env)

    # One checkout for the packager: the loader at the top, the class parts as subfolders
    # that the packager moves out next to it (move-folders).
    out = os.path.join(ROOT, "dist", "allclass")
    if os.path.exists(out):
        shutil.rmtree(out)
    parts = []
    for cls in build.classes():
        buildall.build_part(cls, out, version)
        parts.append((cls, build.meta(cls)["name"]))
    addon_dir = buildall.build_loader(out, version, parts)
    moves = []
    for cls, _ in parts:
        part = buildall.part_name(cls)
        shutil.move(os.path.join(out, part), os.path.join(addon_dir, part))
        moves.append("  %s/%s: %s" % (name, part, part))

    with open(os.path.join(ROOT, "allclass", "CHANGELOG.md"), encoding="utf-8") as f:
        lines = f.read().splitlines()
    body = []
    for line in lines[1:]:
        if line.startswith("# "):
            break
        body.append(line)
    with open(os.path.join(addon_dir, "CHANGELOG.md"), "w", encoding="utf-8") as f:
        f.write("## %s %s\n\n%s\n" % (name, version, "\n".join(body).strip()))
    with open(os.path.join(addon_dir, ".pkgmeta"), "w") as f:
        f.write("package-as: %s\n\nmanual-changelog:\n  filename: CHANGELOG.md\n  markup-type: markdown\n\n"
                "move-folders:\n%s\n\nignore:\n  - CHANGELOG.md\n" % (name, "\n".join(moves)))
    git = ["git", "-c", "user.name=github-actions[bot]",
           "-c", "user.email=41898282+github-actions[bot]@users.noreply.github.com"]
    run(["git", "init", "-q", "-b", "main"], cwd=addon_dir)
    run(["git", "add", "-A"], cwd=addon_dir)
    run(git + ["commit", "-q", "-m", tag], cwd=addon_dir)
    run(git + ["tag", "-a", version, "-m", tag], cwd=addon_dir)
    env = dict(os.environ, GITHUB_EVENT_NAME="release", GITHUB_REF="refs/tags/" + version,
               GITHUB_REF_NAME=version)
    env.pop("GITHUB_OAUTH", None)
    run([os.environ["PACKAGER"], "-g", "1.60.1", "-n", "{package-name}-{project-version}"]
        + os.environ.get("PACKAGER_ARGS", "").split(), cwd=addon_dir, env=env)
    zips = glob.glob(os.path.join(addon_dir, ".release", "*.zip"))
    if not zips:
        sys.exit("%s: the packager made no zip" % name)
    if os.environ.get("PACKAGER_ARGS"):
        return  # dry run
    run(git + ["tag", "-a", tag, "-m", tag], cwd=ROOT)
    run(["git", "push", "origin", tag], cwd=ROOT)
    cmd = ["gh", "release", "create", tag, zips[0], "--title", "%s %s" % (name, version),
           "--notes-file", os.path.join(addon_dir, "CHANGELOG.md")]
    if "beta" in version or "alpha" in version:
        cmd.append("--prerelease")
    run(cmd, cwd=ROOT)


def main():
    if os.environ.get("ONLY_ALLCLASS"):
        release_allclass()
        return
    for cls in build.classes():
        release(cls)
    release_allclass()


if __name__ == "__main__":
    main()
