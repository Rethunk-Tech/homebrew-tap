# Mortar Homebrew tap

Linux [Homebrew](https://brew.sh) formula for [Mortar](https://mortar.rethunk.tech/) (AGPL-3.0-only), the desktop mod manager for PC games. macOS is not supported.

```sh
brew install rethunk-tech/tap/mortar
```

That installs the `mortar` binary. `brew upgrade mortar` keeps it current; Mortar's own updater stays off when Homebrew installed it.

The formula ships the release AppImage: `mortar-linux-aarch64.AppImage` on ARM Linux, `mortar-linux-x86_64.AppImage` on any other Linux host. SHA-256 pins come from the release's `SHA256SUMS` after `scripts/update.sh` checks the signature against the Mortar packages key (`D8B1 C4C2 05C5 FB36 33CB 8B99 00B7 5959 B637 DCB5`). A scheduled GitHub Actions workflow (cron `17 */6 * * *`, plus `workflow_dispatch`) moves the formula to each new release.

The AppImage needs FUSE 2 (`libfuse2`) on the host. The formula does not depend on a FUSE package.
