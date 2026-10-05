# Mortar Homebrew tap

[Homebrew](https://brew.sh) on Linux formula for [Mortar](https://mortar.rethunk.tech/), the Stardew Valley mod manager.

```sh
brew install rethunk-tech/tap/mortar
```

`brew upgrade mortar` keeps it current; Mortar's own updater stays off when Homebrew installed it. The formula installs the release AppImage (x86_64 or ARM64), pinned by SHA-256 taken from the release's `SHA256SUMS` after checking its signature against the Mortar packages key (`3283 6046 06CA E229 5D47 6F98 83BC 8751 EE6F 773D`). A scheduled workflow moves the formula to each new release. The AppImage needs FUSE 2 (`libfuse2`) on the host.
