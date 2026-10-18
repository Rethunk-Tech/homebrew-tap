<h1 align="center">Rethunk-Tech Homebrew tap</h1>

<div align="center">

[![ci](https://github.com/Rethunk-Tech/homebrew-tap/actions/workflows/ci.yml/badge.svg)](https://github.com/Rethunk-Tech/homebrew-tap/actions/workflows/ci.yml)

</div>

---

Linux [Homebrew](https://brew.sh) formulas for Rethunk-Tech tools. macOS is not supported.

| Formula | Install | Project |
| --- | --- | --- |
| `mortar` | `brew install rethunk-tech/tap/mortar` | [Mortar](https://mortar.rethunk.tech/) (AGPL-3.0-only), desktop mod manager |
| `rgit` | `brew install rethunk-tech/tap/rgit` | [rethunk-git-cli](https://github.com/Rethunk-Tech/rethunk-git-cli) |
| `gate` | `brew install rethunk-tech/tap/gate` | [rethunk-gate-cli](https://github.com/Rethunk-Tech/rethunk-gate-cli) |
| `heft` | `brew install rethunk-tech/tap/heft` | [heft](https://github.com/Rethunk-Tech/heft) |
| `engined` | `brew install rethunk-tech/tap/engined` | [engined](https://github.com/Rethunk-Tech/engined) |
| `claude-format-hooks` | `brew install rethunk-tech/tap/claude-format-hooks` | [claude-format-hooks](https://github.com/Rethunk-Tech/claude-format-hooks) |

A formula is committed only after a release ships the linux-amd64 and linux-arm64 assets named in `scripts/tools.tsv`. Scoop manifests (`bucket/*.json`) are written for tools that also ship a windows-amd64 asset: `rgit`, `gate`, `claude-format-hooks`.

`brew upgrade <formula>` keeps a Homebrew install current.

## Quick start

```sh
brew install rethunk-tech/tap/mortar
```

Install, upgrade, and maintainer bump steps: [HUMANS.md](HUMANS.md).

## Highlights

- Mortar ships the release AppImage: `mortar-linux-aarch64.AppImage` on ARM Linux, `mortar-linux-x86_64.AppImage` on Intel Linux.
- Mortar SHA-256 pins come from the release `SHA256SUMS` after `scripts/update.sh` checks the signature against the Mortar packages key (`D8B1 C4C2 05C5 FB36 33CB 8B99 00B7 5959 B637 DCB5`).
- Other tools pin hashes from the release `SHA256SUMS` fetched over HTTPS from GitHub (unsigned; hashes in that file must match the named assets).
- A scheduled GitHub Actions workflow (cron `17 */6 * * *`, plus `workflow_dispatch`) creates or updates each formula/manifest when the expected assets exist.
- Mortar's AppImage needs FUSE 2. The formula depends on `libfuse@2`.

## Documentation

| Doc | Role |
| --- | --- |
| [HUMANS.md](HUMANS.md) | Install, upgrade, uninstall, maintainer bump |
| [AGENTS.md](AGENTS.md) | Layout and invariants |
| [TODO.md](TODO.md) | Work that is decided but not built |

## License

Mortar and its formula are AGPL-3.0-only (same key as `Formula/mortar.rb`). Other formulas use the license recorded in `scripts/tools.tsv`.
