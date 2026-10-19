# Agents

Homebrew tap (Linux for every formula; macOS assets for gate and claude-format-hooks). User-facing install is `brew install rethunk-tech/tap/<formula>` (see `README.md`).

## Surface the code actually has

No CLI, no `--help`, no config file for the tap, no caller-facing env vars. The only runnable entrypoints are:

| What | Behaviour |
| --- | --- |
| `Formula/mortar.rb` | `depends_on :linux` and `depends_on "libfuse@2"`. `Hardware::CPU.arm?` → aarch64 AppImage; `Hardware::CPU.intel?` → x86_64 AppImage; otherwise `odie`. `bin.install` as `mortar`. `livecheck` uses `github_latest` on `Rethunk-Tech/mortar/releases/latest`. `test do` runs `mortar --version` and `assert_match`es the formula version. |
| `scripts/tools.tsv` | Pipe table of tools: Mortar, rgit, gate, heft, engined, claude-format-hooks. Columns: name, repo, checksum (`gpg`, `sha256sums`, or `sha256`), linux-amd64, linux-arm64, windows-amd64 (empty if none), homepage, license, desc, darwin-amd64, darwin-arm64 (empty if none), install (`bare` or `archive`; empty for Mortar), cmd (installed command name; empty for Mortar). `{VERSION}` in an asset name is the tag without a leading `v`. Scoop only when windows-amd64 is set. |
| `scripts/parse-tools.awk` | Requires thirteen fields per row; `checksum` is `gpg`, `sha256sums`, or `sha256`; name, repo, and both linux assets required; non-Mortar rows require `bare` or `archive` and a cmd. |
| `scripts/update.sh` | No flags. See `HUMANS.md`. Loops the table. Mortar: GPG + `rewrite-formula.awk`. Others: HTTPS `SHA256SUMS` or per-asset `.sha256`, `{VERSION}` substitution, create/update `Formula/<name>.rb` (darwin urls when those columns are set; `depends_on :linux` when they are not; archive install is a bun wrapper over `dist/main.js`), optional `bucket/<name>.json`, skip with an info line when assets are missing. Sets `GNUPGHOME` itself for Mortar. `curl_get` follows at most 5 redirects and requires the request and final host in `{github.com, objects.githubusercontent.com, release-assets.githubusercontent.com}`. |
| `scripts/rewrite-formula.awk` | Requires `-v tag=`, `-v x86=`, `-v arm=`. Expects exactly two `url` AppImage lines and two following `sha256` lines. Mortar only. |
| `scripts/test-rewrite.sh` | No flags. Fixture rewrite (arch `eval` on `testdata/mortar.rb` only), stubbed `update.sh` failure paths, test-key GPG verify success path, table parse, create/update/skip. |
| `gate` | `.gate.toml` `[gates.test] run = "scripts/test-rewrite.sh"`. |
| Lefthook | `pre-push` → `gate`. No `pre-commit`. |

## Do not

- Send `github.token` to upstream release repos (`Rethunk-Tech/mortar` or the other table repos).
- Add Mortar formula `url`/`sha256` pairs (the awk rewriter requires exactly two).
- Treat non-Intel Linux as x86_64; only `arm?` and `intel?` get an asset.
- Treat FUSE as a formula dependency (`libfuse@2`), not a caveat-only note.
- Commit placeholder formulas or Scoop manifests for tools with no matching release.
