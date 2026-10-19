#!/usr/bin/env bash
# Point Formula/*.rb (and Scoop bucket/*.json) at each tool's latest release.
# Mortar hashes come from SHA256SUMS after GPG verification against the vendored
# Mortar packages key. Other tools trust SHA256SUMS or per-asset .sha256 files
# fetched over HTTPS from GitHub and the asset hashes listed in them. A Mortar
# release without a signed SHA256SUMS is rejected. Other tools with no matching
# linux assets are skipped.
set -euo pipefail
cd "$(dirname "$0")/.."
FPR=${MORTAR_UPDATE_FPR:-D8B1C4C205C5FB3633CB8B9900B75959B637DCB5}
KEYRING=${MORTAR_UPDATE_KEYRING:-scripts/mortar-archive-keyring.asc}
F=Formula/mortar.rb
curl_get() {
  local a url='' final host
  for a in "$@"; do
    case $a in
      https://*) url=$a ;;
    esac
  done
  host=${url#https://}
  host=${host%%/*}
  if [ "$host" != github.com ] && [ "$host" != objects.githubusercontent.com ] && [ "$host" != release-assets.githubusercontent.com ]; then
    echo "update.sh: refused host ${host:-empty}" >&2
    return 1
  fi
  final=$(curl --proto '=https' --connect-timeout 10 --max-time 60 --max-redirs 5 -L -w '%{url_effective}' "$@") || return 1
  host=${final#https://}
  host=${host%%/*}
  if [ "$host" != github.com ] && [ "$host" != objects.githubusercontent.com ] && [ "$host" != release-assets.githubusercontent.com ]; then
    echo "update.sh: redirect to non-GitHub host ${host:-empty}" >&2
    return 1
  fi
}
camel() {
  awk -F- '{for (i = 1; i <= NF; i++) printf "%s", toupper(substr($i, 1, 1)) substr($i, 2); print ""}' <<<"$1"
}
hash() {
  awk -v f="$1" '($2 == f || $2 == "*" f) && $1 ~ /^[0-9a-f]{64}$/ { print $1; exit }' "$2"
}
hash_file() {
  local asset=$1 file=$2 h
  [ -f "$file" ] || return 0
  h=$(hash "$asset" "$file")
  if [ -n "$h" ]; then
    printf '%s\n' "$h"
    return 0
  fi
  awk '$1 ~ /^[0-9a-f]{64}$/ { print $1; exit }' "$file"
}

write_formula() {
  local name=$1 repo=$2 tag=$3 x86_hash=$4 arm_hash=$5 x86_asset=$6 arm_asset=$7 homepage=$8 license=$9 desc=${10}
  local darwin_amd64=${11} darwin_arm64=${12} darwin_amd64_hash=${13} darwin_arm64_hash=${14} install=${15} cmd=${16}
  local class platforms linux_dep bun_dep macos_block install_block
  class=$(camel "$name")
  if [ -n "$darwin_amd64" ]; then
    platforms="macOS and Linux x86_64 and aarch64"
    linux_dep=""
    macos_block=$(
      cat <<EOF
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/${repo}/releases/download/${tag}/${darwin_arm64}"
      sha256 "${darwin_arm64_hash}"
    elsif Hardware::CPU.intel?
      url "https://github.com/${repo}/releases/download/${tag}/${darwin_amd64}"
      sha256 "${darwin_amd64_hash}"
    else
      odie "${name} is only packaged for ${platforms}"
    end
  end
EOF
    )
    # Command substitution drops the heredoc's trailing newlines; on_linux must start on its own line.
    macos_block+=$'\n\n'
  else
    platforms="Linux x86_64 and aarch64"
    linux_dep=$'  depends_on :linux\n\n'
    macos_block=""
  fi
  if [ "$install" = archive ]; then
    # The release tarball holds the self-contained binary at its root.
    bun_dep=""
    install_block=$(
      cat <<EOF
  def install
    bin.install "${cmd}"
  end
EOF
    )
  else
    bun_dep=""
    install_block=$(
      cat <<EOF
  def install
    bin.install File.basename(stable.url) => "${cmd}"
  end
EOF
    )
  fi
  cat >"Formula/${name}.rb" <<EOF
class ${class} < Formula
  desc "${desc}"
  homepage "${homepage}"
  license "${license}"

  livecheck do
    url "https://github.com/${repo}/releases/latest"
    strategy :github_latest
  end

${linux_dep}${bun_dep}${macos_block}  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/${repo}/releases/download/${tag}/${arm_asset}"
      sha256 "${arm_hash}"
    elsif Hardware::CPU.intel?
      url "https://github.com/${repo}/releases/download/${tag}/${x86_asset}"
      sha256 "${x86_hash}"
    else
      odie "${name} is only packaged for ${platforms}"
    end
  end

${install_block}

  test do
    assert_match version.to_s, shell_output("#{bin}/${cmd} --version")
  end
end
EOF
}

write_scoop() {
  local name=$1 repo=$2 tag=$3 asset=$4 sha=$5 homepage=$6 license=$7 desc=$8 cmd=$9
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
  "bin": [
    [
      "${asset}",
      "${cmd}"
    ]
  ]
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

asset_hash() {
  local checksum=$1 asset=$2 sums=$3 dest
  if [ "$checksum" = sha256sums ]; then
    hash "$asset" "$sums"
    return 0
  fi
  dest=$tmp_root/${name}.$(basename "$asset").sha256
  if ! curl_get -fsSLo "$dest" "$base/${asset}.sha256" || [ ! -s "$dest" ]; then
    return 0
  fi
  hash_file "$asset" "$dest"
}

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

while IFS='|' read -r name repo checksum linux_amd64 linux_arm64 windows_amd64 homepage license desc darwin_amd64 darwin_arm64 install cmd; do
  latest=$(curl --proto '=https' --connect-timeout 10 --max-time 60 -fsSI -o /dev/null -w '%{redirect_url}' "https://github.com/$repo/releases/latest" || true)
  tag=${latest##*/}
  if [ "$checksum" = gpg ]; then
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
  ver=${tag#v}
  linux_amd64=${linux_amd64//\{VERSION\}/$ver}
  linux_arm64=${linux_arm64//\{VERSION\}/$ver}
  windows_amd64=${windows_amd64//\{VERSION\}/$ver}
  darwin_amd64=${darwin_amd64//\{VERSION\}/$ver}
  darwin_arm64=${darwin_arm64//\{VERSION\}/$ver}
  base="https://github.com/$repo/releases/download/$tag"
  sums=$tmp_root/${name}.SHA256SUMS
  if [ "$checksum" = sha256sums ]; then
    if ! curl_get -fsSLo "$sums" "$base/SHA256SUMS"; then
      echo "update.sh: $name: skip: no matching release" >&2
      continue
    fi
  else
    : >"$sums"
  fi
  x86=$(asset_hash "$checksum" "$linux_amd64" "$sums")
  arm=$(asset_hash "$checksum" "$linux_arm64" "$sums")
  if [ -z "$x86" ] || [ -z "$arm" ]; then
    echo "update.sh: $name: skip: no matching release" >&2
    continue
  fi
  darwin_amd64_hash=""
  darwin_arm64_hash=""
  if [ -n "$darwin_amd64" ] || [ -n "$darwin_arm64" ]; then
    darwin_amd64_hash=$(asset_hash "$checksum" "$darwin_amd64" "$sums")
    darwin_arm64_hash=$(asset_hash "$checksum" "$darwin_arm64" "$sums")
    if [ -z "$darwin_amd64_hash" ] || [ -z "$darwin_arm64_hash" ]; then
      echo "update.sh: $name: skip: no matching release" >&2
      continue
    fi
  fi
  write_formula "$name" "$repo" "$tag" "$x86" "$arm" "$linux_amd64" "$linux_arm64" "$homepage" "$license" "$desc" "$darwin_amd64" "$darwin_arm64" "$darwin_amd64_hash" "$darwin_arm64_hash" "$install" "$cmd"
  echo "$name $tag"
  if [ -n "$windows_amd64" ]; then
    win=$(asset_hash "$checksum" "$windows_amd64" "$sums")
    if [ -z "$win" ]; then
      echo "update.sh: $name: skip: no windows-amd64 asset" >&2
    else
      write_scoop "$name" "$repo" "$tag" "$windows_amd64" "$win" "$homepage" "$license" "$desc" "$cmd"
    fi
  fi
done < <(awk -f scripts/parse-tools.awk scripts/tools.tsv)
