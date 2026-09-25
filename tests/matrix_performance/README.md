# Matrix performance regression

The primary comparison builds one Ada implementation plus normal MuJoCo C SIMD
in each executable. Current Ada and an immutable baseline are measured in
balanced four-treatment blocks: baseline C, baseline Ada, current C, current
Ada. Backend 0 is C and backend 1 is Ada. Each operation has a separate noinline
repetition loop; kernels retain their normal release inlining policy.

The baseline matrix sources come from commit `2c26e49b`. Both builders verify
their hashes, unchanged shared dependencies, and pinned upstream C dependencies.
Generated sources are written into the selected build directory. The production
package is not modified by building the fixture.

## Reproduce

Use native GNAT/GCC 16.1, GPRbuild 26, GNATprove and Python on PATH from the
repository root. Timing requires Linux CPU-affinity support.

```sh
python3 tests/matrix_performance/prove_small.py
# To diagnose one helper:
# python3 tests/matrix_performance/prove_small.py --match Transpose_5_Rows

SPARKLING_BUILD_ROOT=/tmp/matrix-proof python3 tools/prove.py \
  --jobs 4 --guard-timeout 1800 --unit mj-blas --unit mj-vector_models \
  --unit mj-matrix_types --unit mj-matrix_models --unit mj-matrices \
  -- --proof=progressive --timeout=30 --counterexamples=off

python3 tests/matrix_performance/build_standalone.py \
  --variant baseline --build-root /tmp/matrix-baseline
python3 tests/matrix_performance/build_standalone.py \
  --variant current --build-root /tmp/matrix-current
python3 tests/matrix_performance/compare_builds.py \
  --baseline /tmp/matrix-baseline/bin/bench_main \
  --candidate /tmp/matrix-current/bin/bench_main \
  --cases tests/matrix_performance/reference-cases.json \
  --pairs 16 --ms 15 --cpu 12 --seed 20260928 --output /tmp/matrix-full.json
python3 tests/matrix_performance/compare_builds.py \
  --baseline /tmp/matrix-baseline/bin/bench_main \
  --candidate /tmp/matrix-current/bin/bench_main \
  --cases tests/matrix_performance/transpose-cases.json \
  --pairs 32 --ms 25 --cpu 12 --seed 20260929 \
  --output /tmp/matrix-transpose.json
```

Select an allowed CPU on the host. `reference-cases.json` preserves the original
228 cases over all 20 benchmark variants; `transpose-cases.json` has 49 cases,
including rectangular, empty and dispatch-boundary checks. Each entry lists
`[op, nr, nc, nk, pattern]`. Operation names are in the comparator. Pattern 0 is
dense; pattern 1 inserts the fixture's deterministic zero coefficients. The
input seed is 71. Avoid concurrent proofs, builds and test suites while timing.

Small proofs are diagnostics, not complete-unit receipts. Follow them with the
whole-unit gate and `tests/run.py` development/validation/release profiles.
`tools/compare_matrices.py` also runs the large transpose-only corpus. Both Ada
and C probes accept `--transpose-only`, avoiding unrelated Gram runtime contracts
when checking dimensions 65 and 128.

## Interpretation

The comparator uses four-treatment Williams blocks, with equal repetitions and
exact position/adjacent-pair balance for multiples of four. Raw CPU/wall times,
switches, checksums, order strata, paired ratios, MAD and bootstrap intervals are
retained. Source and generated-file hashes, compiler, recipe and executable hash
are in each build's metadata; binary hashes are checked before and after timing.
Keep both build metadata and timing reports.

Exit status 2 means a completed run detected a current-Ada/C slowdown. Inspect
`complete` and `error` in the JSON. Intervals are individual within-session
estimates without multiplicity correction. An interval containing 1 is
inconclusive, not proof of equivalence. No samples are discarded for their result
or context-switch count. C/C exposes reference drift between builds and runs.

Preparation and result consumption are outside the clocks. Checksums do not
replace differential numerical tests, which compare individual output values.
Empty shapes mostly measure repetition/barrier overhead. These warm-buffer cases
have no production-workload weights; their classification counts and percentage
gains are not whole-engine speedups. Integrated caller/cache behavior remains a
separate measurement requirement.

## Shared-executable experiment

`build.py` and `benchmark.gpr` additionally link both Ada versions and one C
reference into one executable; use `--baseline-ada-backend 2` and the same binary
for both paths to compare that context. This removes between-binary C-code
variation, but it also changes LTO inlining of unchanged Ada routines. For example,
MulMatVec and the bilinear kernel gain out-of-line calls, and MulMatMatT calls a
component helper inside its loop. Those calls are absent from the one-version
build. Shared-executable whole-run counts therefore cannot replace the primary
one-version measurements. The experiment, source snapshots and unfavorable
results remain in the [evidence history](evidence/before-boundary-fix/README.md).
