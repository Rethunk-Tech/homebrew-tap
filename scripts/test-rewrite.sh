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
