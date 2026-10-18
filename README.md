# Mortar Homebrew tap

[Homebrew](https://brew.sh) on Linux formula for [Mortar](https://mortar.rethunk.tech/), the desktop mod manager for PC games.

```sh
brew install rethunk-tech/tap/mortar
```

`brew upgrade mortar` keeps it current; Mortar's own updater stays off when Homebrew installed it. The formula installs the release AppImage (x86_64 or ARM64), pinned by SHA-256 taken from the release's `SHA256SUMS` after checking its signature against the Mortar packages key (`D8B1 C4C2 05C5 FB36 33CB 8B99 00B7 5959 B637 DCB5`). A scheduled workflow moves the formula to each new release. The AppImage needs FUSE 2 (`libfuse2`) on the host.
