# Compact ancestor factor evidence

Recorded 2026-09-25. The interpretation and limitations are in
`docs/ancestor-storage-performance.md` at the repository root.

- `build.json` and `build-inputs.zip`: final build 9, source snapshots, frozen
  previous Ada baseline, compiler settings, harnesses and reviewed C routines.
- `first.json`, `repeat.json`, their build records and raw ZIP files: the two
  final 24-block whole-step sessions. `summary.json` preserves per-state results;
  `layouts.json` contains structural counts, not measured speedups.
- `binary-identity.json`: final release and baseline executables are byte-identical
  to measured build 8. Checked executables differ and were retested on build 9.
- `compatible9.json`, `strict9.json`: final checked numerical validation,
  552 scenarios / 157,152 comparisons per policy. Their raw files retain inputs.
- `patterns.json`, `patterns-inputs.zip`: final checked/release pattern and packing
  tests, 5,962 patterns per variant, including repeated construction/destruction.
- `boundaries8.json`, `failures8.json`, `replay-*.json`: policy, injected failure
  and exact-input replay tests. `validation8-*` and `fault-*` retain their precise
  earlier source/build provenance. Final solver/data sources are unchanged;
  only ghost constructor proof annotations changed before build 9.
- `replay-inputs.zip`: original prior-stage inputs and outputs, required for a
  valid bitwise comparison; regenerating random inputs after adding fixtures
  does not reproduce this comparison.
- `proofs/unit9`: final whole-unit proof, 758 checks, zero unproved obligations.
  `proofs/solver8`: bounded integration diagnostic, with 5/17 and 50/112 checks
  open in loading and solving respectively. The complete solver is not Gold.
  Other proof directories preserve incremental attempts, including failures and
  timeouts; those attempts must not be counted as successful proofs.
- `proof-source-objects.zip`: source contents addressed by SHA-256. Each proof
  manifest maps original relative paths to these objects, so historical `/tmp`
  paths are not needed to reconstruct its exact source snapshot.
- `exploration/` and `exploration-*-raw.zip`: superseded full first experiment
  and short pilots. Final performance claims use `first.json` / `repeat.json`.
- `manifest.json`: SHA-256 hashes of every other evidence file. Hashes establish
  artifact consistency, not independent certification of the measurements.

## Reproduction

Run from the repository root, using new output directories for each invocation.
The commands below use the recorded machine's toolchain and MuJoCo Python
environment. On another machine, provide equivalent GNAT/GNATprove toolchains,
MuJoCo 3.14.0 and a reference build from the existing movement harness, with its
`build.json`, `movement_c` and native SIMD MuJoCo library. Historical absolute
paths in manifests are provenance, not portable install locations. CPU 12 must
be replaced with an available isolated CPU when necessary. Do not run builds,
proofs or validation concurrently with timings.

```sh
ancestor_tools=/var/tmp/sparkling-matrix-recovery/toolchains
ancestor_python=/var/tmp/sparkling-movement-env/bin/python
ancestor_harness=tests/movement_performance/ancestor_storage
ancestor_build=/var/tmp/ancestor-reproduce-build

python3 "$ancestor_harness/build.py" --out "$ancestor_build" \
  --toolchain-root "$ancestor_tools" \
  --reference-build /var/tmp/sparkling-movement-final

python3 "$ancestor_harness/check_patterns.py" --build "$ancestor_build" \
  --toolchain-root "$ancestor_tools" --out /var/tmp/ancestor-reproduce-patterns

for ancestor_policy in Compatible Strict; do
  "$ancestor_python" experimental/smooth/tools/compare_numerics.py \
    --probe "$ancestor_build/checked/bin/smooth_probe" \
    --policy "$ancestor_policy" --extra-fixtures "$ancestor_harness/fixtures" \
    --report-dir "/var/tmp/ancestor-reproduce-$ancestor_policy"
done

for ancestor_session in first repeat; do
  "$ancestor_python" "$ancestor_harness/compare.py" --build "$ancestor_build" \
    --toolchain-root "$ancestor_tools" --cpu 12 --blocks 24 \
    --out "/var/tmp/ancestor-reproduce-$ancestor_session"
done

python3 experimental/smooth/tools/prove_fragments.py \
  --toolchain-root "$ancestor_tools" --whole-unit mj-ancestor_rows \
  --wall-seconds 240 --prepare-seconds 240 --total-seconds 260 \
  --prover-seconds 20 --steps 0 --provers altergo,cvc5 --level 2 \
  --jobs 2 --cap-mb 4000 --report-dir /var/tmp/ancestor-reproduce-proof
```

Failure injection is built by `check_failures.py`; its checked probe is passed
to the same numerical harness. Policy boundaries use
`tests/movement_performance/inertia_policy/check_policy.py`. `replay.py` accepts
`--probe`, `--prior`, `--out` and `--policy`; extract `replay-inputs.zip` and use
the matching prior policy directory. Each helper provides `--help`.
