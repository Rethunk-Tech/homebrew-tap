# Humans

User install is in `README.md`. This file is how to operate the tap.

## Formula bump

`scripts/update.sh` takes no flags and reads no caller env besides the usual `PATH`. It:

1. Follows `https://github.com/Rethunk-Tech/mortar/releases/latest` (HTTPS only, 10s connect / 60s total).
2. Accepts a tag matching `^v[0-9][0-9A-Za-z._-]*$`.
3. Downloads `SHA256SUMS` and `SHA256SUMS.asc` for that tag.
4. Imports `scripts/mortar-archive-keyring.asc` into a throwaway `GNUPGHOME` and requires `VALIDSIG D8B1C4C205C5FB3633CB8B9900B75959B637DCB5`.
5. Takes SHA-256 for `mortar-linux-x86_64.AppImage` and `mortar-linux-aarch64.AppImage` (two-space text lines or GNU `*filename` lines).
6. Rewrites `Formula/mortar.rb` via `scripts/rewrite-formula.awk` (`-v tag=`, `-v x86=`, `-v arm=`).

Exit 0 with no rewrite if the formula already points at that tag. Do not send this repo's GitHub token to `Rethunk-Tech/mortar`.

## Checks

From the repo root: `gate`. Detection covers actionlint and shellcheck; `.gate.toml` adds `scripts/test-rewrite.sh`. Lefthook `pre-push` runs `gate` only.

## Workflows

- `.github/workflows/ci.yml` — `push` to `main` and `pull_request`; `contents: read`; runs `gate`.
- `.github/workflows/update.yml` — cron `17 */6 * * *` and `workflow_dispatch`; `contents: write`; runs `scripts/update.sh`, then on a `Formula/mortar.rb` diff runs `scripts/test-rewrite.sh` and commits only that file as `mortar: <tag>`.
