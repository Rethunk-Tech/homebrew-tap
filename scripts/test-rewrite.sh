#!/usr/bin/env bash
# Fixture formula + known SHA256SUMS must rewrite both urls and both hashes.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
x86=$(awk '$2 == "mortar-linux-x86_64.AppImage" {print $1}' testdata/SHA256SUMS)
arm=$(awk '$2 == "mortar-linux-aarch64.AppImage" {print $1}' testdata/SHA256SUMS)
[ -n "$x86" ] && [ -n "$arm" ]
awk -v tag=v0.3.5 -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk testdata/mortar.rb >"$tmp/out.rb"
got_arm_url=$(awk '/aarch64.AppImage/ {print}' "$tmp/out.rb")
got_arm_hash=$(awk '/aarch64.AppImage/{getline; print}' "$tmp/out.rb")
got_x86_url=$(awk '/x86_64.AppImage/ {print}' "$tmp/out.rb")
got_x86_hash=$(awk '/x86_64.AppImage/{getline; print}' "$tmp/out.rb")
[ "$got_arm_url" = '      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-aarch64.AppImage"' ]
[ "$got_arm_hash" = "      sha256 \"$arm\"" ]
[ "$got_x86_url" = '      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-x86_64.AppImage"' ]
[ "$got_x86_hash" = "      sha256 \"$x86\"" ]
