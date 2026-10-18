#!/usr/bin/env bash
# Fixture formula + known SHA256SUMS must rewrite both urls and both hashes.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d)
formula_orig=$tmp/formula.orig.rb
cp Formula/mortar.rb "$formula_orig"
trap 'cp "$formula_orig" Formula/mortar.rb; find Formula -type f ! -name mortar.rb -delete; rm -rf bucket "$tmp"' EXIT
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

# Arch predicates: intel gets x86_64; neither arm nor intel odies (no x86_64 url).
ruby <<'RUBY'
module Hardware
  module CPU
    class << self
      attr_accessor :arm, :intel
      def arm?; @arm; end
      def intel?; @intel; end
    end
  end
end
def url(u); $url = u; end
def sha256(_); end
def odie(msg); $odie = msg; end
code = File.read("Formula/mortar.rb")[/if Hardware::CPU\.arm\?.*?^    end/m]
abort "Formula/mortar.rb: missing arch if/end" unless code
Hardware::CPU.arm = false
Hardware::CPU.intel = true
eval code
abort "intel did not select x86_64" unless $url.to_s.include?("x86_64")
abort "intel called odie" if $odie
$url = nil
$odie = nil
Hardware::CPU.intel = false
eval code
abort "unsupported arch set url #{$url.inspect}" if $url
abort "unsupported arch did not odie" if $odie.to_s.empty?
RUBY

if awk -v tag= -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk testdata/mortar.rb >"$tmp/empty-tag.rb" 2>"$tmp/empty-tag.err"; then
  echo "rewrite-formula.awk accepted an empty tag" >&2
  exit 1
fi
grep -q 'tag, x86, and arm are required' "$tmp/empty-tag.err"

if awk -v tag=v0.3.5 -v x86= -v arm="$arm" -f scripts/rewrite-formula.awk testdata/mortar.rb >"$tmp/empty-x86.rb" 2>"$tmp/empty-x86.err"; then
  echo "rewrite-formula.awk accepted an empty x86 hash" >&2
  exit 1
fi
grep -q 'tag, x86, and arm are required' "$tmp/empty-x86.err"

cat >"$tmp/one.rb" <<'EOF'
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.0/mortar-linux-aarch64.AppImage"
      sha256 "ffb51fca9ae762f9eb2cd3cc13911aa1bfba00c6e561a452cb951184b9aff042"
EOF
if awk -v tag=v0.3.5 -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk "$tmp/one.rb" >"$tmp/one.out" 2>"$tmp/one.err"; then
  echo "rewrite-formula.awk accepted a single-arch formula" >&2
  exit 1
fi
grep -q 'expected 2 url lines and 2 sha256 lines' "$tmp/one.err"

cat >"$tmp/order.rb" <<'EOF'
      sha256 "ffb51fca9ae762f9eb2cd3cc13911aa1bfba00c6e561a452cb951184b9aff042"
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.0/mortar-linux-aarch64.AppImage"
      sha256 "4913687e6404afab8845e9bfffd428711ff5fb7e1db1fb0ea571cd5a5cc500dd"
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.0/mortar-linux-x86_64.AppImage"
EOF
if awk -v tag=v0.3.5 -v x86="$x86" -v arm="$arm" -f scripts/rewrite-formula.awk "$tmp/order.rb" >"$tmp/order.out" 2>"$tmp/order.err"; then
  echo "rewrite-formula.awk accepted sha256 before url" >&2
  exit 1
fi
grep -q 'sha256 before url' "$tmp/order.err"

bin="$tmp/bin"
mkdir -p "$bin"
stub_curl_tag() {
  tag=$1
  asc=${2-}
  cat >"$bin/curl" <<EOF
#!/bin/sh
dest=
url=
prev=
for a in "\$@"; do
  if [ "\$prev" = "-o" ] || [ "\$prev" = "-fsSLo" ]; then
    dest=\$a
    prev=
    continue
  fi
  case \$a in
    -fsSI)
      echo "https://github.com/Rethunk-Tech/mortar/releases/tag/$tag"
      exit 0
      ;;
    -o|-fsSLo) prev=\$a ;;
    http://*|https://*) url=\$a ;;
  esac
done
case \$url in
  *.asc)
    if [ -n "$asc" ]; then
      cp "$asc" "\$dest"
    else
      : >"\$dest"
    fi
    ;;
  *SHA256SUMS) cp "$tmp/sums" "\$dest" ;;
esac
EOF
  chmod +x "$bin/curl"
}
stub_gpg() {
  cat >"$bin/gpg" <<EOF
#!/bin/sh
for a in "\$@"; do
  [ "\$a" = "--verify" ] || continue
  if [ -f "$tmp/validsig" ]; then
    echo "VALIDSIG D8B1C4C205C5FB3633CB8B9900B75959B637DCB5"
  fi
  exit 0
done
exit 0
EOF
  chmod +x "$bin/gpg"
}
stub_gpg
stub_curl_tag ""
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/empty-latest.out" 2>"$tmp/empty-latest.err"; then
  echo "update.sh accepted an empty latest tag" >&2
  exit 1
fi
grep -q 'could not resolve latest tag' "$tmp/empty-latest.err"

stub_curl_tag latest
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/word-latest.out" 2>"$tmp/word-latest.err"; then
  echo "update.sh accepted tag 'latest'" >&2
  exit 1
fi
grep -q 'could not resolve latest tag' "$tmp/word-latest.err"

: >"$tmp/sums"
: >"$tmp/validsig"
stub_curl_tag v9.9.9
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/nohash.out" 2>"$tmp/nohash.err"; then
  echo "update.sh accepted SHA256SUMS with no AppImage hashes" >&2
  exit 1
fi
grep -q 'SHA256SUMS missing' "$tmp/nohash.err"

cp testdata/SHA256SUMS "$tmp/sums"
rm -f "$tmp/validsig"
stub_curl_tag v9.9.9
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/badsig.out" 2>"$tmp/badsig.err"; then
  echo "update.sh accepted an unsigned SHA256SUMS" >&2
  exit 1
fi
grep -q 'SHA256SUMS not signed' "$tmp/badsig.err"

grep -F -q 'D8B1C4C205C5FB3633CB8B9900B75959B637DCB5' scripts/update.sh
grep -F -q 'scripts/mortar-archive-keyring.asc' scripts/update.sh

test_gnupg=$tmp/test-gnupg
install -d -m 700 "$test_gnupg"
GNUPGHOME=$test_gnupg gpg --batch --passphrase '' --pinentry-mode loopback --quick-gen-key 'Mortar tap test <tap-test@invalid>' default default never
test_fpr=$(GNUPGHOME=$test_gnupg gpg --batch --list-secret-keys --with-colons | awk -F: '/^fpr:/ {print $10; exit}')
[ -n "$test_fpr" ]
GNUPGHOME=$test_gnupg gpg --batch --export --armor >"$tmp/test-keyring.asc"
GNUPGHOME=$test_gnupg gpg --batch --yes --pinentry-mode loopback --passphrase '' --detach-sign -o "$tmp/SHA256SUMS.asc" testdata/SHA256SUMS
cp testdata/SHA256SUMS "$tmp/sums"
rm -f "$bin/gpg"
stub_curl_tag v9.9.9 "$tmp/SHA256SUMS.asc"
if MORTAR_UPDATE_FPR="$test_fpr" MORTAR_UPDATE_KEYRING="$tmp/test-keyring.asc" PATH="$bin:$PATH" scripts/update.sh >"$tmp/realsig.out" 2>"$tmp/realsig.err"; then
  :
else
  echo "update.sh rejected a SHA256SUMS signed by the test key" >&2
  cat "$tmp/realsig.err" >&2
  exit 1
fi
grep -q 'download/v9.9.9/mortar-linux-x86_64.AppImage' Formula/mortar.rb
grep -q 'download/v9.9.9/mortar-linux-aarch64.AppImage' Formula/mortar.rb
cp "$formula_orig" Formula/mortar.rb

if MORTAR_UPDATE_FPR=0000000000000000000000000000000000000000 MORTAR_UPDATE_KEYRING="$tmp/test-keyring.asc" PATH="$bin:$PATH" scripts/update.sh >"$tmp/wrongfpr.out" 2>"$tmp/wrongfpr.err"; then
  echo "update.sh accepted a signature that did not match FPR" >&2
  exit 1
fi
grep -q 'SHA256SUMS not signed' "$tmp/wrongfpr.err"
stub_gpg

stub_curl_tag '..'
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/dottag.out" 2>"$tmp/dottag.err"; then
  echo "update.sh accepted tag '..'" >&2
  exit 1
fi
grep -q 'invalid latest tag' "$tmp/dottag.err"

stub_curl_tag 'v1.0;rm'
if PATH="$bin:$PATH" scripts/update.sh >"$tmp/sctag.out" 2>"$tmp/sctag.err"; then
  echo "update.sh accepted a tag with a semicolon" >&2
  exit 1
fi
grep -q 'invalid latest tag' "$tmp/sctag.err"

: >"$tmp/validsig"
cp testdata/SHA256SUMS "$tmp/sums"
stub_curl_tag v9.9.9
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/textsums.out" 2>"$tmp/textsums.err"; then
  echo "update.sh rejected a two-space SHA256SUMS" >&2
  cat "$tmp/textsums.err" >&2
  exit 1
fi
grep -q 'download/v9.9.9/mortar-linux-x86_64.AppImage' Formula/mortar.rb
grep -q 'download/v9.9.9/mortar-linux-aarch64.AppImage' Formula/mortar.rb
grep -q 'releases/latest' Formula/mortar.rb
cp "$formula_orig" Formula/mortar.rb

awk '{ print $1 " *" $2 }' testdata/SHA256SUMS >"$tmp/sums"
stub_curl_tag v9.9.9
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/starsums.out" 2>"$tmp/starsums.err"; then
  echo "update.sh rejected a GNU *filename SHA256SUMS" >&2
  cat "$tmp/starsums.err" >&2
  exit 1
fi
grep -q 'download/v9.9.9/mortar-linux-x86_64.AppImage' Formula/mortar.rb
grep -q 'download/v9.9.9/mortar-linux-aarch64.AppImage' Formula/mortar.rb
cp "$formula_orig" Formula/mortar.rb

awk '/^curl_get\(\)/,/^}/' scripts/update.sh | grep -q -- '-L' || {
  echo "curl_get lacks -L; GitHub release assets 302" >&2
  exit 1
}
cat >"$bin/curl" <<EOF
#!/bin/sh
dest=
url=
prev=
follow=0
for a in "\$@"; do
  if [ "\$prev" = "-o" ] || [ "\$prev" = "-fsSLo" ]; then
    dest=\$a
    prev=
    continue
  fi
  case \$a in
    -L|--location) follow=1; continue ;;
    -fsSI)
      echo "https://github.com/Rethunk-Tech/mortar/releases/tag/v9.9.9"
      exit 0
      ;;
    -o|-fsSLo) prev=\$a ;;
    http://*|https://*) url=\$a ;;
  esac
done
case \$url in
  *.asc) : >"\$dest" ;;
  *SHA256SUMS)
    if [ "\$follow" != 1 ]; then
      : >"\$dest"
    else
      cp "$tmp/sums" "\$dest"
    fi
    ;;
esac
EOF
chmod +x "$bin/curl"
: >"$tmp/validsig"
cp testdata/SHA256SUMS "$tmp/sums"
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/follow.out" 2>"$tmp/follow.err"; then
  echo "update.sh failed a 302 SHA256SUMS that -L would follow" >&2
  cat "$tmp/follow.err" >&2
  exit 1
fi
grep -q 'download/v9.9.9/mortar-linux-x86_64.AppImage' Formula/mortar.rb
grep -q 'download/v9.9.9/mortar-linux-aarch64.AppImage' Formula/mortar.rb
cp "$formula_orig" Formula/mortar.rb

# Table: six tools, GPG only for Mortar, Scoop only when a windows-amd64 asset is named.
got=$(awk -f scripts/parse-tools.awk scripts/tools.tsv)
[ "$(printf '%s\n' "$got" | wc -l)" -eq 6 ]
[ "$(printf '%s\n' "$got" | awk -F'|' '$3=="gpg" {print $1}')" = mortar ]
[ "$(printf '%s\n' "$got" | awk -F'|' '$3=="https" {print $1}' | tr '\n' ' ')" = "rgit gate heft engined claude-format-hooks " ]
[ "$(printf '%s\n' "$got" | awk -F'|' '$6!="" {print $1}' | tr '\n' ' ')" = "rgit gate claude-format-hooks " ]

if echo 'too|few' | awk -f scripts/parse-tools.awk >"$tmp/nf.out" 2>"$tmp/nf.err"; then
  echo "parse-tools.awk accepted a short row" >&2
  exit 1
fi
grep -q 'expected 9 fields' "$tmp/nf.err"

if echo 'x|Rethunk-Tech/x|https||linux-arm64||https://example|MIT|d' | awk -f scripts/parse-tools.awk >"$tmp/nolinux.out" 2>"$tmp/nolinux.err"; then
  echo "parse-tools.awk accepted an empty linux_amd64" >&2
  exit 1
fi
grep -q 'linux_amd64' "$tmp/nolinux.err"

if echo 'x|Rethunk-Tech/x|pgp|a.tar.gz|b.tar.gz||https://example|MIT|d' | awk -f scripts/parse-tools.awk >"$tmp/signed.out" 2>"$tmp/signed.err"; then
  echo "parse-tools.awk accepted signed=pgp" >&2
  exit 1
fi
grep -q 'signed must be gpg or https' "$tmp/signed.err"

rgit_sums=$tmp/rgit.SHA256SUMS
cat >"$rgit_sums" <<'EOF'
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa  rgit-linux-amd64.tar.gz
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb  rgit-linux-arm64.tar.gz
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc  rgit-windows-amd64.zip
EOF
stub_multi_url() {
  sums_rgit=${1:-}
  cat >"$bin/curl" <<EOF
#!/bin/sh
dest=
url=
prev=
head=0
for a in "\$@"; do
  if [ "\$prev" = "-o" ] || [ "\$prev" = "-fsSLo" ]; then
    dest=\$a
    prev=
    continue
  fi
  case \$a in
    -L|--location) continue ;;
    -fsSI) head=1 ;;
    -o|-fsSLo) prev=\$a ;;
    http://*|https://*) url=\$a ;;
  esac
done
if [ "\$head" = 1 ]; then
  case \$url in
    *Rethunk-Tech/mortar/releases/latest)
      echo "https://github.com/Rethunk-Tech/mortar/releases/tag/v0.3.5"
      ;;
    *rethunk-git-cli/releases/latest)
      echo "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/tag/v1.2.3"
      ;;
    *)
      echo "https://github.com/Rethunk-Tech/skip/releases/tag/latest"
      ;;
  esac
  exit 0
fi
case \$url in
  *rethunk-git-cli/*/SHA256SUMS)
    if [ -n "$sums_rgit" ]; then
      cp "$sums_rgit" "\$dest"
    else
      exit 22
    fi
    ;;
  *) exit 22 ;;
esac
EOF
  chmod +x "$bin/curl"
}

stub_multi_url "$rgit_sums"
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/create.out" 2>"$tmp/create.err"; then
  echo "update.sh failed to create rgit formula from a matching release" >&2
  cat "$tmp/create.err" >&2
  exit 1
fi
grep -q 'rgit v1.2.3' "$tmp/create.out"
grep -q 'download/v1.2.3/rgit-linux-amd64.tar.gz' Formula/rgit.rb
grep -q 'download/v1.2.3/rgit-linux-arm64.tar.gz' Formula/rgit.rb
grep -q 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' Formula/rgit.rb
grep -q 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' Formula/rgit.rb
grep -q 'class Rgit ' Formula/rgit.rb
[ -f bucket/rgit.json ]
grep -q 'rgit-windows-amd64.zip' bucket/rgit.json
grep -q 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc' bucket/rgit.json
grep -q '"version": "1.2.3"' bucket/rgit.json
[ ! -f Formula/heft.rb ]
[ ! -f Formula/gate.rb ]

# Update: existing formula moves to the new tag (same fixture sums).
PATH="$bin:$PATH" scripts/update.sh >"$tmp/current.out" 2>"$tmp/current.err" || {
  echo "update.sh failed when rgit was already at v1.2.3" >&2
  cat "$tmp/current.err" >&2
  exit 1
}
grep -q 'download/v1.2.3/rgit-linux-amd64.tar.gz' Formula/rgit.rb

sed -i 's/v1.2.3/v0.1.0/g' Formula/rgit.rb
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/update.out" 2>"$tmp/update.err"; then
  echo "update.sh failed to update an existing rgit formula" >&2
  cat "$tmp/update.err" >&2
  exit 1
fi
grep -q 'rgit v1.2.3' "$tmp/update.out"
grep -q 'download/v1.2.3/rgit-linux-amd64.tar.gz' Formula/rgit.rb
grep -q 'download/v1.2.3/rgit-linux-arm64.tar.gz' Formula/rgit.rb

rm -f Formula/rgit.rb bucket/rgit.json
: >"$tmp/rgit.empty"
stub_multi_url "$tmp/rgit.empty"
if ! PATH="$bin:$PATH" scripts/update.sh >"$tmp/skip.out" 2>"$tmp/skip.err"; then
  echo "update.sh failed a skip (no matching rgit assets)" >&2
  cat "$tmp/skip.err" >&2
  exit 1
fi
grep -q 'rgit: skip: no matching release' "$tmp/skip.err"
[ ! -f Formula/rgit.rb ]
[ ! -d bucket ] || [ ! -f bucket/rgit.json ]
