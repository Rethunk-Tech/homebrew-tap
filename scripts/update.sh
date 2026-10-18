#!/usr/bin/env bash
# Point Formula/mortar.rb at Mortar's latest release. Hashes come from the release's SHA256SUMS after
# GPG verification against the vendored Mortar packages key. A release without a signed SHA256SUMS is rejected.
set -euo pipefail
cd "$(dirname "$0")/.."
FPR=${MORTAR_UPDATE_FPR:-D8B1C4C205C5FB3633CB8B9900B75959B637DCB5}
KEYRING=${MORTAR_UPDATE_KEYRING:-scripts/mortar-archive-keyring.asc}
F=Formula/mortar.rb
curl_get() {
  curl --proto '=https' --connect-timeout 10 --max-time 60 -L "$@"
}
# GitHub's /releases/latest redirect is public. The Actions token is this tap's
# repo-scoped github.token and must not be sent to Rethunk-Tech/mortar.
# HEAD stays unfollowed: -L would land on the tag page and empty %{redirect_url}.
latest=$(curl --proto '=https' --connect-timeout 10 --max-time 60 -fsSI -o /dev/null -w '%{redirect_url}' https://github.com/Rethunk-Tech/mortar/releases/latest)
tag=${latest##*/}
if [ -z "$tag" ] || [ "$tag" = "latest" ]; then
  echo "update.sh: could not resolve latest tag from '$latest'" >&2
  exit 1
fi
if [[ ! "$tag" =~ ^v[0-9][0-9A-Za-z._-]*$ ]]; then
  echo "update.sh: invalid latest tag '$tag'" >&2
  exit 1
fi
current=$(grep -m1 -o 'download/v[^/]*' "$F")
[ "$current" != "download/$tag" ] || exit 0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
base="https://github.com/Rethunk-Tech/mortar/releases/download/$tag"
curl_get -fsSLo "$tmp/SHA256SUMS" "$base/SHA256SUMS"
curl_get -fsSLo "$tmp/SHA256SUMS.asc" "$base/SHA256SUMS.asc"
export GNUPGHOME="$tmp/gnupg"
install -d -m 700 "$GNUPGHOME"
gpg --batch --quiet --import "$KEYRING"
if ! gpg --batch --status-fd 1 --verify "$tmp/SHA256SUMS.asc" "$tmp/SHA256SUMS" 2>/dev/null | grep -q "VALIDSIG $FPR"; then
  echo "update.sh: SHA256SUMS not signed by $FPR" >&2
  exit 1
fi
hash() {
  awk -v f="$1" '($2 == f || $2 == "*" f) && $1 ~ /^[0-9a-f]{64}$/ { print $1; exit }' "$tmp/SHA256SUMS"
}
x86=$(hash mortar-linux-x86_64.AppImage)
arm=$(hash mortar-linux-aarch64.AppImage)
if [ -z "$x86" ] || [ -z "$arm" ]; then
  echo "update.sh: SHA256SUMS missing mortar-linux-x86_64.AppImage or mortar-linux-aarch64.AppImage" >&2
  exit 1
fi
awk -v tag="$tag" -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk "$F" >"$tmp/mortar.rb"
mv "$tmp/mortar.rb" "$F"
echo "mortar $tag"
