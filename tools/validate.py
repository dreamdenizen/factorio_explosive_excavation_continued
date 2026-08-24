#!/usr/bin/env python3
"""Pre-release checks for this mod.

Catches the things the game will not: Factorio's --dump-data exits 0 even when an
icon path points at a file that does not exist, because sprites load after the data
stage. That exact bug shipped once already, so it is checked here explicitly.

Run from the repo root:  tools/validate.py
Exits non-zero on the first category that fails. Requires Pillow.
"""
import json
import re
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FAIL: list[str] = []
NOTE: list[str] = []


def fail(msg): FAIL.append(msg)
def ok(msg):   NOTE.append(msg)


def mip_widths(icon_size):
    """Valid total widths for an icon strip: the base plus any prefix of its mipmaps."""
    widths, total, s = [], 0, icon_size
    while s >= 1:
        total += s
        widths.append(total)
        s //= 2
    return widths


def load_info():
    try:
        return json.loads((ROOT / "info.json").read_text())
    except Exception as e:
        fail(f"info.json does not parse: {e}")
        sys.exit(report())


def check_info(info):
    for k in ("name", "version", "title", "author", "factorio_version"):
        if not info.get(k):
            fail(f"info.json missing required field {k!r}")
    if not re.fullmatch(r"\d+\.\d+\.\d+", info.get("version", "")):
        fail(f"info.json version {info.get('version')!r} is not number.number.number")
    name = info.get("name", "")
    if not (3 < len(name) < 50) or not all(c.isalnum() or c in "-_" for c in name):
        fail(f"info.json name {name!r} is not portal-valid (4-49 chars, alnum/dash/underscore)")
    if len(info.get("title", "")) > 100:
        fail("info.json title exceeds the 100 character limit")
    ok(f"info.json: {name} {info['version']} ({info['title']!r})")


def check_changelog(info):
    p = ROOT / "changelog.txt"
    if not p.exists():
        fail("changelog.txt is missing")
        return
    lines = p.read_text().split("\n")
    state, seen = None, []
    for n, l in enumerate(lines, 1):
        if l == "":
            if n != len(lines):
                fail(f"changelog.txt:{n} blank line (only a single trailing newline is allowed)")
            continue
        if l.rstrip() != l or "\t" in l:
            fail(f"changelog.txt:{n} tab or trailing whitespace")
        if re.fullmatch(r"-+", l):
            if len(l) != 99:
                fail(f"changelog.txt:{n} separator is {len(l)} dashes, must be exactly 99")
            state = "sep"
        elif l.startswith("Version:"):
            if state != "sep":
                fail(f"changelog.txt:{n} version line must follow a separator")
            v = l.split(":", 1)[1].strip()
            if v in seen:
                fail(f"changelog.txt:{n} duplicate version {v}")
            seen.append(v)
            state = "ver"
        elif l.startswith("Date:"):
            if state != "ver":
                fail(f"changelog.txt:{n} Date must directly follow Version")
            state = "date"
        elif re.fullmatch(r"  \S.*:", l):
            state = "cat"
        elif l.startswith("    - "):
            if state not in ("cat", "entry"):
                fail(f"changelog.txt:{n} entry with no preceding category line")
            state = "entry"
        elif re.fullmatch(r"      \S.*", l):
            if state != "entry":
                fail(f"changelog.txt:{n} continuation line outside an entry")
        else:
            fail(f"changelog.txt:{n} unrecognised line: {l[:60]!r}")
    if info["version"] not in seen:
        fail(f"changelog.txt has no entry for the current version {info['version']}")
    else:
        ok(f"changelog.txt: {len(seen)} versions, current {info['version']} present")


def check_locale():
    protos = {}
    for f, kind in (("prototypes/items.lua", "item"), ("prototypes/technology.lua", "technology")):
        src = (ROOT / f).read_text()
        protos[kind] = re.findall(rf'type\s*=\s*"{kind}".*?name\s*=\s*"([^"]+)"', src, re.S)
    have = {}
    for cfg in (ROOT / "locale").rglob("*.cfg"):
        section = None
        for line in cfg.read_text(encoding="utf-8-sig").splitlines():
            line = line.strip()
            if line.startswith("[") and line.endswith("]"):
                section = line[1:-1]
            elif "=" in line and section:
                have.setdefault(section, set()).add(line.split("=", 1)[0].strip())
    need = set()
    for kind, names in protos.items():
        for n in names:
            need |= {(f"{kind}-name", n), (f"{kind}-description", n)}
    missing = [f"[{s}] {k}" for s, k in sorted(need) if k not in have.get(s, set())]
    if missing:
        fail(f"locale is missing keys: {missing}")
    else:
        ok(f"locale: all {len(need)} keys present for {sum(len(v) for v in protos.values())} prototypes")
    unused = [f"[{s}] {k}" for s in have for k in have[s] if (s, k) not in need]
    if unused:
        fail(f"locale has keys for prototypes that do not exist: {unused}")


def check_icons(info):
    """The check --dump-data cannot do: that every icon path actually resolves."""
    from PIL import Image
    found = 0
    for f in sorted((ROOT / "prototypes").glob("*.lua")):
        src = f.read_text()
        for m in re.finditer(r'icon\s*=\s*"__([^"]+?)__/([^"]+)"', src):
            found += 1
            ref, rel = m.group(1), m.group(2)
            if ref != info["name"]:
                fail(f"{f.name}: icon path says __{ref}__ but info.json name is {info['name']!r}")
            target = ROOT / rel
            if not target.exists():
                fail(f"{f.name}: icon file does not exist: {rel}")
                continue
            size_m = re.search(r"icon_size\s*=\s*(\d+)", src)
            icon_size = int(size_m.group(1)) if size_m else 64
            im = Image.open(target)
            w, h = im.size
            if h != icon_size:
                fail(f"{rel}: height {h} does not equal icon_size {icon_size}")
            if w not in mip_widths(icon_size):
                fail(f"{rel}: width {w} is not a valid mip strip for icon_size {icon_size} "
                     f"(expected one of {mip_widths(icon_size)})")
            if im.mode != "RGBA":
                fail(f"{rel}: mode is {im.mode}, icons need RGBA")
            ok(f"icon {rel}: {w}x{h} {im.mode}, icon_size {icon_size}")
    if not found:
        fail("no icon declarations found in prototypes/, which cannot be right")


def check_thumbnail():
    from PIL import Image
    p = ROOT / "thumbnail.png"
    if not p.exists():
        fail("thumbnail.png is missing")
        return
    w, h = Image.open(p).size
    if w != h:
        fail(f"thumbnail.png is {w}x{h}, must be square")
    else:
        ok(f"thumbnail.png: {w}x{h}")


def check_build(info):
    z = ROOT / "dist" / f"{info['name']}_{info['version']}.zip"
    if not z.exists():
        NOTE.append(f"dist zip not built yet ({z.name}); skipping package checks")
        return
    zf = zipfile.ZipFile(z)
    root = f"{info['name']}_{info['version']}"
    tops = {n.split("/")[0] for n in zf.namelist()}
    if tops != {root}:
        fail(f"zip must contain exactly one top-level folder named {root!r}, found {sorted(tops)}")
    for required in ("info.json", "data.lua", "control.lua", "changelog.txt", "thumbnail.png"):
        if f"{root}/{required}" not in zf.namelist():
            fail(f"zip is missing {required}")
    leaked = [n for n in zf.namelist() if n.endswith((".py", ".sh", ".gitignore")) or "README" in n]
    if leaked:
        fail(f"tooling leaked into the released zip: {leaked}")
    else:
        ok(f"package: {root}.zip clean, {len(zf.namelist())} entries")


def report():
    for n in NOTE:
        print(f"  ok    {n}")
    for f in FAIL:
        print(f"  FAIL  {f}")
    print(f"\n{'FAILED' if FAIL else 'PASSED'}: {len(FAIL)} problem(s), {len(NOTE)} check(s) ok")
    return 1 if FAIL else 0


def main():
    info = load_info()
    check_info(info)
    check_changelog(info)
    check_locale()
    check_icons(info)
    check_thumbnail()
    check_build(info)
    return report()


if __name__ == "__main__":
    sys.exit(main())
