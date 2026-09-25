# State invariant evidence

The active prototype retains all seven full readiness guards. The fast query
is a proved property under the existing invariant; the measured shortcut is
isolated and unpromoted. See [interpretation](../../../../docs/state-invariants-performance.md).

* `first.json`, `repeat.json` and their raw ZIPs: uninstrumented full-step A/B/C
  runs, 648 process records and every sample/final state per session. The key
  `current` denotes the shortcut experiment. Both reports are complete.
* `phases.json`, `phases-raw.zip`: instrumented baseline, eight processes per
  scenario. Counts verify seven readiness checks and two condition estimates
  per step. Timings include clock overhead and nested phases overlap.
* `checked-numerics.json`, `checked-numerics-raw.zip`: checked shortcut, 360
  scenarios, 33,840 scalar comparisons and the normalization/status tests.
* `build.json`, `build-inputs.zip`: hashes and exact source/build inputs for all
  four binaries, including the instrumentation. `reference.json` links the
  unchanged native C binary/library to the first movement experiment's evidence.
* `source-reconstruction.json`: the maintained frozen-source builder recreates
  every source file of all four measured builds exactly. Builder/profile/compare
  scripts are also preserved here.
* `ready-final/`: the private `Ready_Flag` property, one proof check and two flow
  checks, zero open checks. `ready-proof/` is the initial equivalent run.
* `integrate-before/`: initial 51 checks, two open. `integrate-progressive/`:
  same source, one open. `integrate-input-cut/`: final source, 55 checks, 54
  proved and one open, plus ten successful flow checks. The open property is
  preservation of `Input_Values` on return from `Integrate`.
* `integrate-cuts/`: abandoned stronger snapshot assertions, seven open checks.
  Those changes were reverted. `integrate-final/`: a later Z3-only attempt on
  the final source leaves eight checks open; it does not supersede the stronger
  recorded multi-prover result. Neither run establishes whole-unit closure.
* `input-post/`, `input-post-body/`: exact-line selections emitted no proof
  obligations. They are **not passes**. `empty-selector/` verifies that the
  corrected runner returns exit code 1 for such an empty selection. The proved
  `ready-final` run returns 0. Prefer subprogram selection for postconditions.
* `final-proof-inputs.zip`: final active sources and proof runner. Each proof
  folder also preserves its own changed data/Euler source files, including
  abandoned variants. Raw logs, commands and manifests identify the scope.
* `summary.json`: decision and counts. `manifest.json`: file integrity receipt.

No combined total promotes incomplete unit proofs to Gold. Performance tests,
checked numerical comparisons, and conditional modular proofs remain separate.
