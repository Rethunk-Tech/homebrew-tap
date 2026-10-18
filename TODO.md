# TODO

Work that is decided but not built. `README.md` describes what
exists; this file is the only place that describes what does not.

Sections are unordered.

## non-ARM Linux is treated as x86_64

`Formula/mortar.rb` branches on `Hardware::CPU.arm?` at `:14` and the `else`
at `:17` installs `mortar-linux-x86_64.AppImage`. There is no
`Hardware::CPU.intel?` check and no `odie` for any other Linux arch. A
riscv64 or similar host would fetch and install the x86_64 AppImage.

Decided shape: keep the ARM url/sha256 block; wrap the current `else`
body in `Hardware::CPU.intel?`; `odie` with a one-line unsupported-arch
message otherwise. No new bottles, no macOS.

Rejected: a third AppImage url. Mortar does not publish one. Rejected:
leaving the `else` and documenting the assumption only in caveats.

### Read

1. `Formula/mortar.rb:14` `Hardware::CPU.arm?` — the only arch predicate.
2. `Formula/mortar.rb:17` `else` — x86_64 url and sha256.
3. `scripts/rewrite-formula.awk` END — still expects exactly two url lines
   and two sha256 lines after this change.

### Traps

- **Rewrite still has to see both urls.** `on_intel do` / `on_arm do`
  (Homebrew DSL) is fine only if both url/sha256 pairs remain in the file
  as two `url "` lines. A layout that emits one pair per bottle would
  fail `rewrite-formula.awk`.
- **Do not drop `on_linux`.** `depends_on :linux` at `:11` stays; this is
  not a macOS formula.

### Acceptance

- ARM and Intel Linux still get the same two AppImage urls and hashes.
- A formula evaluation where both `arm?` and `intel?` are false calls
  `odie` and does not set an x86_64 url.
- `scripts/test-rewrite.sh` still rewrites both hashes.

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

## scheduled update has no concurrency group

`.github/workflows/ci.yml:14` cancels a superseded `gate` run keyed by
ref. `.github/workflows/update.yml` has no `concurrency` block. Two
scheduled ticks (or dispatch overlapping the cron) can both rewrite
`Formula/mortar.rb` and push.

Decided shape: copy ci.yml's group/cancel-in-progress, keyed by this
workflow and ref:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

Rejected: a mutex job or skip-if-in-progress without cancel. The ci.yml
pattern is already the house rule.

### Read

1. `.github/workflows/ci.yml:14` `concurrency` — the pattern to copy.
2. `.github/workflows/update.yml:3` `on.schedule` / `workflow_dispatch`.
3. `.github/workflows/update.yml:21` `git diff --quiet && exit 0` — the
   no-op path if the cancelled sibling already pushed the same tag.

### Traps

- **This cancels an in-flight bump.** That is a behaviour change for
  overlapping runs, which is why it was not landed with the silent-error
  fill.
- **Do not key by a static string only.** Two workflow_dispatch runs on
  different refs (if that ever exists) must not cancel each other; ci.yml
  already includes `${{ github.ref }}`.

### Acceptance

- `actionlint` stays clean.
- A second Update run on `main` while the first is in progress cancels
  the first, matching ci.yml.
- A successful bump still commits and pushes `Formula/mortar.rb`.

## hash() rejects GNU `*filename` SHA256SUMS lines

`hash` in `scripts/update.sh:30` prints `$1` only when `$2 == f`. GNU
`sha256sum` text mode uses two spaces (`testdata/SHA256SUMS` already
matches). Binary mode prints `hash *filename`, so `$2` is `*mortar-linux-…`
and both hashes stay empty, which now errors with the missing-AppImage
message.

Decided shape: treat `$2 == f` and `$2 == "*" f` as the same file. No
other checksum formats.

Rejected: stripping the first character of `$2` unconditionally. A
filename that starts with `*` would then match the wrong line.

### Read

1. `scripts/update.sh:30` `hash()` awk.
2. `testdata/SHA256SUMS:1` two-space text-mode lines (the format Mortar
   ships today).
3. `scripts/test-rewrite.sh` missing-hash case — still the right failure
   when neither form is present.

### Traps

- **Do not change testdata to binary mode as the only fixture.** Keep a
  two-space line as the success path; add one `*` line in a dedicated
  case.
- **`$2 == "*"f` concatenation in awk** is `*mortar-linux-x86_64.AppImage`,
  not a glob.

### Acceptance

- Two-space SHA256SUMS still yields both hashes and rewrites the formula.
- A SHA256SUMS whose AppImage lines use `*file` yields the same hashes.
- A SHA256SUMS with neither form still exits 1 with the missing-AppImage
  message.

## Update workflow pushes a bump without running gate

`.github/workflows/update.yml:17` runs `scripts/update.sh` and `:19`
commits with `git commit -am` then `git push`. It does not run `gate` or
`scripts/test-rewrite.sh`. A rewrite that produces a formula the awk
tests would reject can still land on `main`.

Decided shape: after a non-empty diff, run `scripts/test-rewrite.sh` on
the already-updated tree (the fixture test, not a second live bump), then
commit. Installing the full `gate` toolchain on this job is optional; the
minimum is the rewrite test that does not need network or Homebrew.

Rejected: running `scripts/update.sh` twice. Rejected: moving the bump
into the ci.yml `check` job (that job has `contents: read`).

### Read

1. `.github/workflows/update.yml:17` bump step.
2. `.github/workflows/update.yml:21` commit/push.
3. `.github/workflows/ci.yml:39` `gate` — the heavier check, needs
   shellcheck/actionlint/gate installed.
4. `scripts/test-rewrite.sh` — no network, uses `testdata/`.

### Traps

- **test-rewrite.sh does not re-read live GitHub.** It cannot catch a bad
  downloaded SHA256SUMS; GPG already did. It catches a broken
  `rewrite-formula.awk` committed alongside a bump.
- **`git commit -am` is a separate gap.** Do not expand this section into
  rewriting the commit invocation unless that section lands in the same
  change.

### Acceptance

- A bump whose tree fails `scripts/test-rewrite.sh` does not push.
- A no-op bump (`git diff --quiet`) still exits 0 without running tests
  if tests stay after the diff check; if tests run always, they must
  still pass on an unchanged tree.
- `actionlint` stays clean.

## GPG verify has no signed testdata

`scripts/test-rewrite.sh` stubs `gpg` and `curl` for the unsigned and
missing-hash paths of `scripts/update.sh`. The happy path — import
`scripts/mortar-archive-keyring.asc`, `VALIDSIG` for
`D8B1C4C205C5FB3633CB8B9900B75959B637DCB5`, then rewrite — is not
exercised. The vendored keyring is public-only, so this tree cannot mint
a real `SHA256SUMS.asc` for `testdata/SHA256SUMS`.

Decided shape: add a **test-only** keypair used solely by
`scripts/test-rewrite.sh` (not the Mortar packages key). Sign
`testdata/SHA256SUMS`, point a test copy of the update flow at that
keyring and fingerprint, assert `Formula/mortar.rb` is rewritten when
the stub latest tag differs. Production `update.sh` keeps `FPR` and
`scripts/mortar-archive-keyring.asc` unchanged.

Rejected: committing a signature made with the production secret key.
Rejected: calling live `gpg --verify` against GitHub in the gate.

### Read

1. `scripts/update.sh:6` `FPR`.
2. `scripts/update.sh:25` import of `scripts/mortar-archive-keyring.asc`.
3. `scripts/update.sh:26` `VALIDSIG $FPR`.
4. `scripts/test-rewrite.sh` `bin/gpg` stub — the stand-in this replaces
   for the success case only.

### Traps

- **Do not replace the production keyring with the test key.** Update.yml
  must keep verifying Mortar's packages key.
- **Parameterise FPR/keyring for the test**, or extract the verify+rewrite
  tail; do not hard-code the test fingerprint into `update.sh`'s default
  `FPR`.

### Acceptance

- `scripts/test-rewrite.sh` fails if verify is skipped or if VALIDSIG is
  the wrong fingerprint.
- `scripts/update.sh` defaults still match
  `D8B1C4C205C5FB3633CB8B9900B75959B637DCB5` and
  `scripts/mortar-archive-keyring.asc`.
- Gate stays offline.

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

## Update commit uses `git commit -am`

`.github/workflows/update.yml:24` runs `git commit -am` after a bump.
That stages every modified tracked file, not just `Formula/mortar.rb`. A
dirty Actions workspace (or a future step that touches another file)
rides along on the `mortar: v…` commit.

Decided shape: `git add Formula/mortar.rb` then `git commit` with the
same message. No `-a`. No `git add -A`.

Rejected: committing `scripts/` or the keyring on this path.

### Read

1. `.github/workflows/update.yml:21` `git diff --quiet && exit 0`.
2. `.github/workflows/update.yml:24` `git commit -am`.
3. `scripts/update.sh:38` `mv` onto `Formula/mortar.rb` — the only file
   the bump should change.

### Traps

- **`git diff --quiet` is the whole tree.** If another file is dirty, the
  job would still commit under `-am` and would still proceed after this
  fix unless the diff check is narrowed to `Formula/mortar.rb` too. Narrow
  both in the same change.

### Acceptance

- A bump commits only `Formula/mortar.rb`.
- An unrelated dirty tracked file is not in that commit.
- Message still starts with `mortar: v`.

## lefthook only runs gate on pre-push

`lefthook.yml:1` defines `pre-push` and not `pre-commit`. The comment at
`:3` says the hook is detection-driven so it cannot drift from
`gate --list`. Commits can land locally without `gate`; only a push runs
it.

Decided shape: a `pre-commit` job that is the same `run: gate` as
pre-push, same comment. No extra listed tools.

Rejected: duplicating shellcheck/actionlint by name in lefthook. That is
what the comment forbids.

### Read

1. `lefthook.yml:1` `pre-push`.
2. `lefthook.yml:6` `run: gate`.
3. `.gate.toml:3` the explicit `gates.test` rewrite script `gate` already
   includes.

### Traps

- **Pre-commit `gate` on every commit is slower** than pre-push only.
  That is the behaviour change.
- **Do not add a second job that runs `scripts/test-rewrite.sh`.** `gate`
  already runs it via `.gate.toml`.

### Acceptance

- `lefthook.yml` has `pre-commit` and `pre-push`, both `run: gate`.
- `gate --list` still matches what those jobs run.
- No named linter besides `gate` is added to lefthook.
