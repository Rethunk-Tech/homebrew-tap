# TODO

Work that is decided but not built. `README.md` describes what
exists; this file is the only place that describes what does not.

Sections are unordered.

## formula test does not run the AppImage

`test do` at `Formula/mortar.rb:34` checks that `bin/"mortar"` exists and
is executable. It never starts the AppImage. A corrupt download that
still unpacks to a +x file would pass `brew test`.

Decided shape: `assert_match` on `shell_output("#{bin}/mortar --version")`
(or the flag Mortar actually implements — confirm against the installed
binary's `--help` at implementation time), once it is known the AppImage
runs without FUSE in Homebrew's linux test env **or** FUSE is a formula
dependency from the libfuse2 section.

Rejected: curling a network service from `brew test`.

### Read

1. `Formula/mortar.rb:34` current test.
2. `Formula/mortar.rb:23` `bin.install` of the AppImage as `mortar`.
3. `Formula/mortar.rb:30` FUSE caveat — why `--version` may fail today.

### Traps

- **AppImages often need FUSE.** A `--version` assertion on ubuntu-fuse-less
  CI fails for a reason the caveats already document. Land this only with
  the FUSE dependency decision, or with an extract-and-run path that
  Mortar documents.
- **`--version` text is not a contract of this tap.** Match a stable
  substring (`mortar` / a version regex from `livecheck`), not a full
  help dump.

### Acceptance

- `brew test mortar` fails if the installed file is not a runnable Mortar
  binary, on an environment that has whatever FUSE decision was made.
- `scripts/test-rewrite.sh` and `update.sh` are unchanged.
