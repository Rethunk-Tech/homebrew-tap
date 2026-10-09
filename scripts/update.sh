#!/usr/bin/env bash
# Point Formula/mortar.rb at Mortar's latest release. Hashes come from the release's SHA256SUMS, whose GPG signature is
# checked against the Mortar packages key; a release without SHA256SUMS is hashed by downloading its files.
set -euo pipefail
cd "$(dirname "$0")/.."
FPR=D8B1C4C205C5FB3633CB8B9900B75959B637DCB5
F=Formula/mortar.rb
tag=$(gh release view --repo Rethunk-Tech/mortar --json tagName --jq .tagName)
current=$(grep -o 'download/v[^/]*' "$F" | head -1)
[ "$current" != "download/$tag" ] || exit 0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base="https://github.com/Rethunk-Tech/mortar/releases/download/$tag"
if curl -fsLo "$tmp/SHA256SUMS" "$base/SHA256SUMS"; then
  curl -fsSLo "$tmp/SHA256SUMS.asc" "$base/SHA256SUMS.asc"
  export GNUPGHOME="$tmp/gnupg"
  install -d -m 700 "$GNUPGHOME"
  curl -fsSL https://mortar.rethunk.tech/packages/mortar-archive-keyring.asc | gpg --batch --quiet --import
  gpg --batch --status-fd 1 --verify "$tmp/SHA256SUMS.asc" "$tmp/SHA256SUMS" 2>/dev/null | grep -q "VALIDSIG $FPR"
  hash() { awk -v f="$1" '$2 == f {print $1}' "$tmp/SHA256SUMS"; }
else
  hash() { curl -fsSL "$base/$1" | sha256sum | cut -d' ' -f1; }
fi
x86=$(hash mortar-linux-x86_64.AppImage)
arm=$(hash mortar-linux-aarch64.AppImage)
[ -n "$x86" ] && [ -n "$arm" ]
awk -v tag="$tag" -v x86="$x86" -v arm="$arm" '
  /url "/ { sub(/download\/v[^\/]*/, "download/" tag); want = /aarch64/ ? arm : x86 }
  /sha256 "/ { sub(/"[0-9a-f]+"/, "\"" want "\"") }
  { print }' "$F" >"$tmp/mortar.rb"
mv "$tmp/mortar.rb" "$F"
echo "mortar $tag"
