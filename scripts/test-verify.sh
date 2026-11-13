#!/usr/bin/env bash
# verify_sums accepts only a signature from the pinned fingerprint; unsigned, garbage or wrong-key SUMS are refused.
set -euo pipefail
cd "$(dirname "$0")/.."
. scripts/verify-sums.sh
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkkey() {
  install -d -m 700 "$tmp/$1"
  GNUPGHOME=$tmp/$1 gpg --batch --quiet --passphrase '' --pinentry-mode loopback --quick-gen-key "test $1 <$1@invalid>" ed25519 sign never
  GNUPGHOME=$tmp/$1 gpg --batch --armor --export >"$tmp/$1.pub"
  GNUPGHOME=$tmp/$1 gpg --batch --list-secret-keys --with-colons | awk -F: '/^fpr:/ {print $10; exit}'
}
fpr_a=$(mkkey a)
mkkey b >/dev/null
printf '%s  tool\n' "$(printf x | sha256sum | cut -d' ' -f1)" >"$tmp/SHA256SUMS"
GNUPGHOME=$tmp/a gpg --batch --quiet --armor --detach-sign -o "$tmp/good.asc" "$tmp/SHA256SUMS"
GNUPGHOME=$tmp/b gpg --batch --quiet --armor --detach-sign -o "$tmp/wrong.asc" "$tmp/SHA256SUMS"
cat "$tmp/a.pub" "$tmp/b.pub" >"$tmp/both.pub"
printf 'not a signature\n' >"$tmp/garbage.asc"

verify_sums "$tmp/SHA256SUMS" "$tmp/good.asc" "$tmp/both.pub" "$fpr_a" "$tmp/h1"
for bad in wrong garbage missing; do
  if verify_sums "$tmp/SHA256SUMS" "$tmp/$bad.asc" "$tmp/both.pub" "$fpr_a" "$tmp/h-$bad"; then
    echo "verify_sums accepted a $bad signature" >&2
    exit 1
  fi
done
echo "verify ok"
