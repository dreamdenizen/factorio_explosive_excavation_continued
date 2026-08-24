#!/usr/bin/env bash
# Package the mod for the Factorio mod portal.
#
# The zip must contain a single top-level folder named "<name>_<version>", both
# read from info.json, or the game will not load it.
set -euo pipefail

cd "$(dirname "$0")/.."
NAME=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' info.json | head -1)
VERSION=$(sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' info.json | head -1)
FOLDER="${NAME}_${VERSION}"

rm -rf "dist/${FOLDER}" "dist/${FOLDER}.zip"
mkdir -p "dist/${FOLDER}"

# Everything the game needs, and nothing else: no tooling, no repo metadata.
for item in info.json data.lua control.lua changelog.txt thumbnail.png \
            CREDITS.md LICENSE prototypes locale graphics; do
  cp -R "$item" "dist/${FOLDER}/"
done
find "dist/${FOLDER}" -name '.DS_Store' -delete

( cd dist && zip -qr "${FOLDER}.zip" "${FOLDER}" )
rm -rf "dist/${FOLDER}"
echo "dist/${FOLDER}.zip"
