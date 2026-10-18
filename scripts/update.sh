#!/usr/bin/env bash
# Point Formula/*.rb (and Scoop bucket/*.json) at each tool's latest release.
# Mortar hashes come from SHA256SUMS after GPG verification against the vendored
# Mortar packages key. Other tools trust SHA256SUMS fetched over HTTPS from GitHub
# and the asset hashes listed in it. A Mortar release without a signed SHA256SUMS
# is rejected. Other tools with no matching linux assets are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."
FPR=${MORTAR_UPDATE_FPR:-D8B1C4C205C5FB3633CB8B9900B75959B637DCB5}
KEYRING=${MORTAR_UPDATE_KEYRING:-scripts/mortar-archive-keyring.asc}
F=Formula/mortar.rb
curl_get() {
  curl --proto '=https' --connect-timeout 10 --max-time 60 -L "$@"
}
camel() {
  awk -F- '{for (i = 1; i <= NF; i++) printf "%s", toupper(substr($i, 1, 1)) substr($i, 2); print ""}' <<<"$1"
}
hash() {
  awk -v f="$1" '($2 == f || $2 == "*" f) && $1 ~ /^[0-9a-f]{64}$/ { print $1; exit }' "$2"
}

write_formula() {
  local name=$1 repo=$2 tag=$3 x86_hash=$4 arm_hash=$5 x86_asset=$6 arm_asset=$7 homepage=$8 license=$9 desc=${10}
  local class
  class=$(camel "$name")
  cat >"Formula/${name}.rb" <<EOF
class ${class} < Formula
  desc "${desc}"
  homepage "${homepage}"
  license "${license}"

  livecheck do
    url "https://github.com/${repo}/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/${repo}/releases/download/${tag}/${arm_asset}"
      sha256 "${arm_hash}"
    elsif Hardware::CPU.intel?
      url "https://github.com/${repo}/releases/download/${tag}/${x86_asset}"
      sha256 "${x86_hash}"
    else
      odie "${name} is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install "${name}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/${name} --version")
  end
end
EOF
}

write_scoop() {
  local name=$1 repo=$2 tag=$3 asset=$4 sha=$5 homepage=$6 license=$7 desc=$8
  local ver=${tag#v}
  mkdir -p bucket
  cat >"bucket/${name}.json" <<EOF
{
  "version": "${ver}",
  "description": "${desc}",
  "homepage": "${homepage}",
  "license": "${license}",
  "architecture": {
    "64bit": {
      "url": "https://github.com/${repo}/releases/download/${tag}/${asset}",
      "hash": "${sha}"
    }
  },
  "bin": "${name}.exe"
}
EOF
}

update_mortar_from_url() {
  local latest=$1 tag x86 arm current
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
  [ "$current" != "download/$tag" ] || return 0
  mortar_tmp=$tmp_root/mortar
  mkdir -p "$mortar_tmp"
  base="https://github.com/Rethunk-Tech/mortar/releases/download/$tag"
  curl_get -fsSLo "$mortar_tmp/SHA256SUMS" "$base/SHA256SUMS"
  curl_get -fsSLo "$mortar_tmp/SHA256SUMS.asc" "$base/SHA256SUMS.asc"
  export GNUPGHOME="$mortar_tmp/gnupg"
  install -d -m 700 "$GNUPGHOME"
  gpg --batch --quiet --import "$KEYRING"
  if ! gpg --batch --status-fd 1 --verify "$mortar_tmp/SHA256SUMS.asc" "$mortar_tmp/SHA256SUMS" 2>/dev/null | grep -q "VALIDSIG $FPR"; then
    echo "update.sh: SHA256SUMS not signed by $FPR" >&2
    exit 1
  fi
  x86=$(hash mortar-linux-x86_64.AppImage "$mortar_tmp/SHA256SUMS")
  arm=$(hash mortar-linux-aarch64.AppImage "$mortar_tmp/SHA256SUMS")
  if [ -z "$x86" ] || [ -z "$arm" ]; then
    echo "update.sh: SHA256SUMS missing mortar-linux-x86_64.AppImage or mortar-linux-aarch64.AppImage" >&2
    exit 1
  fi
  awk -v tag="$tag" -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk "$F" >"$mortar_tmp/mortar.rb"
  mv "$mortar_tmp/mortar.rb" "$F"
  unset GNUPGHOME
  echo "mortar $tag"
}

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

while IFS='|' read -r name repo signed linux_amd64 linux_arm64 windows_amd64 homepage license desc; do
  latest=$(curl --proto '=https' --connect-timeout 10 --max-time 60 -fsSI -o /dev/null -w '%{redirect_url}' "https://github.com/$repo/releases/latest" || true)
  tag=${latest##*/}
  if [ "$signed" = gpg ]; then
    update_mortar_from_url "$latest"
    continue
  fi
  if [ -z "$tag" ] || [ "$tag" = "latest" ] || [[ ! "$tag" =~ ^v[0-9][0-9A-Za-z._-]*$ ]]; then
    echo "update.sh: $name: skip: no matching release" >&2
    continue
  fi
  formula=Formula/${name}.rb
  if [ -f "$formula" ]; then
    current=$(grep -m1 -o 'download/v[^/]*' "$formula" || true)
    [ "$current" != "download/$tag" ] || continue
  fi
  sums=$tmp_root/${name}.SHA256SUMS
  base="https://github.com/$repo/releases/download/$tag"
  if ! curl_get -fsSLo "$sums" "$base/SHA256SUMS"; then
    echo "update.sh: $name: skip: no matching release" >&2
    continue
  fi
  x86=$(hash "$linux_amd64" "$sums")
  arm=$(hash "$linux_arm64" "$sums")
  if [ -z "$x86" ] || [ -z "$arm" ]; then
    echo "update.sh: $name: skip: no matching release" >&2
    continue
  fi
  write_formula "$name" "$repo" "$tag" "$x86" "$arm" "$linux_amd64" "$linux_arm64" "$homepage" "$license" "$desc"
  echo "$name $tag"
  if [ -n "$windows_amd64" ]; then
    win=$(hash "$windows_amd64" "$sums")
    if [ -z "$win" ]; then
      echo "update.sh: $name: skip: no windows-amd64 asset" >&2
    else
      write_scoop "$name" "$repo" "$tag" "$windows_amd64" "$win" "$homepage" "$license" "$desc"
    fi
  fi
done < <(awk -f scripts/parse-tools.awk scripts/tools.tsv)
