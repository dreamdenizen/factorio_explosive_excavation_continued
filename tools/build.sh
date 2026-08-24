#!/usr/bin/env bash
# Package the mod for the Factorio mod portal.
#
# The zip must contain a single top-level folder named "<name>_<version>", both
# read from info.json, or the game will not load it.
#
# The build is reproducible: the same commit produces byte-identical output. A zip
# records each file's mtime, so without pinning them two builds of identical content
# hash differently and comparing hashes tells you nothing about the contents. That
# matters here because the hash is how you confirm the artifact CI released is the
# same thing you tested locally.
set -euo pipefail

cd "$(dirname "$0")/.."
NAME=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' info.json | head -1)
VERSION=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' info.json | head -1)
FOLDER="${NAME}_${VERSION}"

# Clear the whole directory, not just this version's zip. A rename or a version bump
# otherwise leaves the previous artifact sitting next to the new one, which is an
# easy way to upload the wrong file to the portal.
rm -rf dist
mkdir -p "dist/${FOLDER}"

# Everything the game needs, and nothing else: no tooling, no repo metadata.
for item in info.json data.lua control.lua changelog.txt thumbnail.png \
            CREDITS.md LICENSE prototypes locale graphics; do
  cp -R "$item" "dist/${FOLDER}/"
done
find "dist/${FOLDER}" -name '.DS_Store' -delete

STAMP=$(git log -1 --format=%cd --date=format:%Y%m%d%H%M.%S 2>/dev/null || echo "202001010000.00")
find "dist/${FOLDER}" -exec touch -t "$STAMP" {} +

# -X drops platform-specific extra fields; sorted input pins entry order.
( cd dist && find "${FOLDER}" -print | LC_ALL=C sort | zip -qX "${FOLDER}.zip" -@ )
rm -rf "dist/${FOLDER}"
echo "dist/${FOLDER}.zip"
