# Humans

User install is in `README.md`. This file is how to operate the tap.

## Formula bump

`scripts/update.sh` takes no flags and reads no caller env besides the usual `PATH`. It reads `scripts/tools.tsv` and for each tool:

1. Follows `https://github.com/<repo>/releases/latest` (HTTPS only, 10s connect / 60s total).
2. Accepts a tag matching `^v[0-9][0-9A-Za-z._-]*$`.
3. Downloads `SHA256SUMS` for that tag (Mortar also downloads `SHA256SUMS.asc`).

### Mortar (signed SHA256SUMS)

1. Imports `scripts/mortar-archive-keyring.asc` into a throwaway `GNUPGHOME` and requires `VALIDSIG D8B1C4C205C5FB3633CB8B9900B75959B637DCB5`.
2. Takes SHA-256 for `mortar-linux-x86_64.AppImage` and `mortar-linux-aarch64.AppImage` (two-space text lines or GNU `*filename` lines).
3. Rewrites `Formula/mortar.rb` via `scripts/rewrite-formula.awk` (`-v tag=`, `-v x86=`, `-v arm=`).

Exit 0 with no rewrite if the formula already points at that tag. A Mortar release without those AppImage hashes, or without a signature from that key, fails the run. Do not send this repo's GitHub token to `Rethunk-Tech/mortar`.

### Other tools (HTTPS SHA256SUMS)

Trust model: GitHub HTTPS for `SHA256SUMS` and for `/releases/latest`; asset SHA-256 values must appear in that file. There is no GPG signature check (only Mortar publishes `SHA256SUMS.asc`).

If the latest tag cannot be resolved, `SHA256SUMS` is missing, or the linux-amd64/linux-arm64 assets named in the table are absent, that tool is skipped (info on stderr) and no placeholder formula is written. A matching linux pair creates `Formula/<name>.rb` on first sight and overwrites it on later tags. A windows-amd64 asset in the same `SHA256SUMS` also writes `bucket/<name>.json` (Scoop); tools without that asset have no Scoop manifest.

Do not send this repo's GitHub token to upstream release repos.

## Checks

From the repo root: `gate`. Detection covers actionlint and shellcheck; `.gate.toml` adds `scripts/test-rewrite.sh`. Lefthook `pre-push` runs `gate` only.

## Workflows

- `.github/workflows/ci.yml` — `push` to `main` and `pull_request`; `contents: read`; runs `gate`.
- `.github/workflows/update.yml` — cron `17 */6 * * *` and `workflow_dispatch`; `contents: write`; runs `scripts/update.sh`, then on a `Formula/` or `bucket/` diff runs `scripts/test-rewrite.sh` and commits the changed files (`mortar: <tag>` when only `Formula/mortar.rb` changed, otherwise `packaging: latest releases`).
