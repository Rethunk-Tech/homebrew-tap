# TODO

Work that is decided but not built. `README.md` describes what
exists; this file is the only place that describes what does not.

Sections are unordered.

## caveats mention libfuse2 but the formula does not depend on it

`def caveats` at `Formula/mortar.rb:27` tells the user the AppImage needs
FUSE 2 (`libfuse2`) on the host. `depends_on` is only `:linux` at `:11`.
`brew install` will succeed on a host without FUSE; the binary then fails
at runtime.

Decided shape: add an explicit `depends_on` for the Homebrew linux FUSE 2
package whose current formula name is confirmed against homebrew-core at
implementation time, **or** keep caveats-only if that package is not a
stable linux dependency. Do not vendor FUSE. Do not change the AppImage
install.

Rejected: `uses_from_macos`. This formula is linux-only.

### Read

1. `Formula/mortar.rb:11` `depends_on :linux`
2. `Formula/mortar.rb:30` caveats line naming `libfuse2`
3. `README.md:9` the same FUSE 2 sentence

### Traps

- **The linux package name is the decision.** Debian/Fedora `libfuse2` is
  not automatically a Homebrew formula name. A wrong `depends_on` breaks
  install on every host.
- **Adding a dep changes `brew install`.** That is why this stayed out of
  the small gap-fill: it is a contract change for the tap's users.

### Acceptance

- Either `depends_on` names a real homebrew-core linux formula and
  `brew install mortar` pulls it, or the caveats/README wording stays and
  this section records that Homebrew has no such dep.
- AppImage url, sha256, and rewrite script are unchanged.

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
