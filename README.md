<h1 align="center">Mortar Homebrew tap</h1>

<div align="center">

[![ci](https://github.com/Rethunk-Tech/homebrew-tap/actions/workflows/ci.yml/badge.svg)](https://github.com/Rethunk-Tech/homebrew-tap/actions/workflows/ci.yml)

</div>

---

Linux [Homebrew](https://brew.sh) formula for [Mortar](https://mortar.rethunk.tech/) (AGPL-3.0-only), the desktop mod manager for PC games. macOS is not supported.

That install puts `mortar` on `PATH`. `brew upgrade mortar` keeps it current; Mortar's own updater stays off when Homebrew installed it.

## Quick start

```sh
brew install rethunk-tech/tap/mortar
```

Install, upgrade, and maintainer bump steps: [HUMANS.md](HUMANS.md).

## Highlights

- Ships the release AppImage: `mortar-linux-aarch64.AppImage` on ARM Linux, `mortar-linux-x86_64.AppImage` on any other Linux host.
- SHA-256 pins come from the release `SHA256SUMS` after `scripts/update.sh` checks the signature against the Mortar packages key (`D8B1 C4C2 05C5 FB36 33CB 8B99 00B7 5959 B637 DCB5`).
- A scheduled GitHub Actions workflow (cron `17 */6 * * *`, plus `workflow_dispatch`) moves the formula to each new release.
- The AppImage needs FUSE 2. The formula depends on `libfuse@2`.

## Documentation

| Doc | Role |
| --- | --- |
| [HUMANS.md](HUMANS.md) | Install, upgrade, uninstall, maintainer bump |
| [AGENTS.md](AGENTS.md) | Layout and invariants |
| [TODO.md](TODO.md) | Work that is decided but not built |

## License

Mortar and this formula are AGPL-3.0-only (same key as `Formula/mortar.rb`).
