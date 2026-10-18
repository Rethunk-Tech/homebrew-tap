# Agents

Linux Homebrew tap. User-facing install is `brew install rethunk-tech/tap/mortar`.

## Surface the code actually has

No CLI, no `--help`, no config file for the tap, no caller-facing env vars. The only runnable entrypoints are:

| What | Behaviour |
| --- | --- |
| `Formula/mortar.rb` | `depends_on :linux` and `depends_on "libfuse@2"`. `Hardware::CPU.arm?` → aarch64 AppImage; `Hardware::CPU.intel?` → x86_64 AppImage; otherwise `odie`. `bin.install` as `mortar`. `livecheck` uses `github_latest` on `Rethunk-Tech/mortar/releases/latest`. `test do` runs `mortar --version` and `assert_match`es the formula version. |
| `scripts/update.sh` | No flags. See `HUMANS.md`. Sets `GNUPGHOME` itself. |
| `scripts/rewrite-formula.awk` | Requires `-v tag=`, `-v x86=`, `-v arm=`. Expects exactly two `url` AppImage lines and two following `sha256` lines. |
| `scripts/test-rewrite.sh` | No flags. Fixture rewrite, stubbed `update.sh` failure paths, and a test-key GPG verify success path. |
| `gate` | `.gate.toml` `[gates.test] run = "scripts/test-rewrite.sh"`. |
| Lefthook | `pre-push` → `gate`. No `pre-commit`. |

## Do not

- Send `github.token` to `Rethunk-Tech/mortar`.
- Add formula `url`/`sha256` pairs (the awk rewriter requires exactly two).
- Treat non-Intel Linux as x86_64; only `arm?` and `intel?` get an AppImage.
- Treat FUSE as a formula dependency (`libfuse@2`), not a caveat-only note.
