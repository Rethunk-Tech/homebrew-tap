#!/usr/bin/env bash
# Point Formula/mortar.rb at Mortar's latest release. Hashes come from the release's SHA256SUMS after
# GPG verification against the vendored Mortar packages key. A release without a signed SHA256SUMS is rejected.
set -euo pipefail
cd "$(dirname "$0")/.."
FPR=D8B1C4C205C5FB3633CB8B9900B75959B637DCB5
F=Formula/mortar.rb
# GitHub's /releases/latest redirect is public. The Actions token is this tap's
# repo-scoped github.token and must not be sent to Rethunk-Tech/mortar.
latest=$(curl -fsSI -o /dev/null -w '%{redirect_url}' https://github.com/Rethunk-Tech/mortar/releases/latest)
tag=${latest##*/}
[ -n "$tag" ]
current=$(grep -o 'download/v[^/]*' "$F" | head -1)
[ "$current" != "download/$tag" ] || exit 0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base="https://github.com/Rethunk-Tech/mortar/releases/download/$tag"
curl -fsSLo "$tmp/SHA256SUMS" "$base/SHA256SUMS"
curl -fsSLo "$tmp/SHA256SUMS.asc" "$base/SHA256SUMS.asc"
export GNUPGHOME="$tmp/gnupg"
install -d -m 700 "$GNUPGHOME"
gpg --batch --quiet --import scripts/mortar-archive-keyring.asc
gpg --batch --status-fd 1 --verify "$tmp/SHA256SUMS.asc" "$tmp/SHA256SUMS" 2>/dev/null | grep -q "VALIDSIG $FPR"
hash() { awk -v f="$1" '$2 == f {print $1}' "$tmp/SHA256SUMS"; }
x86=$(hash mortar-linux-x86_64.AppImage)
arm=$(hash mortar-linux-aarch64.AppImage)
[ -n "$x86" ] && [ -n "$arm" ]
awk -v tag="$tag" -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk "$F" >"$tmp/mortar.rb"
mv "$tmp/mortar.rb" "$F"
echo "mortar $tag"
