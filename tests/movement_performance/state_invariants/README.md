# State invariant investigation

This fixture isolates the cost of seven runtime readiness scans in the smooth
prototype. See [results and proof boundaries](../../../docs/state-invariants-performance.md).
The shortcut is **not promoted**. Active dynamics retain the original guards.

`baseline/` freezes the smooth sources at the start of the investigation.
`shortcut/mj-data.ads` adds a proved private query whose existing `Valid_State`
precondition implies `Ready_Flag(D) = Is_Ready(D)`. The builder changes only the
seven explicit guards in its isolated shortcut copies. It keeps all numerical
and cache-freshness checks. No new Silver exception or trusted body is introduced.

Four builds are produced: baseline, instrumented baseline, uninstrumented
shortcut, and shortcut with executable contracts. Instrumentation is outside
SPARK proof claims. Nested readiness/condition timings are included in their
enclosing phases; do not add them to the enclosing totals. Early failures are
rejected by the harness, so partial timing of a failing phase is not accepted.

Use the same native toolchain and Python environment as the parent movement
fixture (`mujoco==3.14.0` and NumPy). First build its native C reference and keep
the parent report directory. Then:

```sh
python tests/movement_performance/state_invariants/build.py \
  --out /var/tmp/state-build-new --toolchain-root /path/to/toolchains

python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/state-build-new/checked_shortcut/bin/smooth_probe \
  --report-dir /var/tmp/state-numerics-new --samples 24

# Run timings only after builds, correctness tests and proofs have finished.
python tests/movement_performance/state_invariants/profile.py \
  --build /var/tmp/state-build-new --fixtures /path/to/parent-report/timings \
  --out /var/tmp/state-phases-new --cpu 12

python tests/movement_performance/state_invariants/compare.py \
  --build /var/tmp/state-build-new --reference-build /path/to/parent-report \
  --out /var/tmp/state-comparison-new --toolchain-root /path/to/toolchains --cpu 12
```

Every output directory must be new. Repeat the last command with another output
directory for a second session. The comparison uses the parent's balanced
24-block runner: `current` in its JSON means the unpromoted shortcut. Compare
complete reports and matching binary hashes, not process wall time or counts of
microbenchmark cases. All timings use 100 evolving Euler steps per trajectory.

Start formal diagnostics at the smallest target:

```sh
python experimental/smooth/tools/prove_fragments.py \
  --unit mj-data --name Ready_Flag --report-dir /var/tmp/ready-proof-new \
  --toolchain-root /path/to/toolchains --level 2 --steps 0 \
  --provers altergo,cvc5 --prover-seconds 5 --jobs 2 --cap-mb 4000 \
  --prepare-seconds 180 --total-seconds 190
```

For integration diagnostics use `--unit mj-data-euler --name Integrate`, then
whole units only after the small target closes. `--proof-mode progressive`
selects the alternative splitting strategy. Zero obligations, incomplete runs
and open postconditions must not be reported as Gold.
