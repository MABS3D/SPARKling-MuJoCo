# Compact mass retry: isolated candidates

Neither candidate replaces the active simulation. The active standalone
`MJ.Compact_Inertia` helper has been extended and proved (185 checks), with
checked/release structural tests. Integration proofs remain unfinished.

- `measured/`: canonical compact allocation, direct parent walk and direct writes,
  with the total symmetry query corrected. Its release binary is identical to
  the one used in the first two 24-block confirmation sessions.
- `verification/`: the same representation, with separate loading/accumulation
  routines and proved whole-buffer operations. It uses the already validated
  ancestor column list in reverse order. Its own final tests and timings must
  be used; do not attach the first candidate's speedups to this source.
- The two patches are reviewable differences from the accepted scan-only source,
  not from bare commit `bf265c8f`. Each source set has its own hash manifest.

The baseline is reconstructed from the prior bounds experiment's frozen source
archive, including its magnitude-scan optimization. This avoids counting that
optimization again. The build tool does not edit active simulator sources.

```sh
python3 tests/movement_performance/compact_mass_retry/build.py \
  --lane verification --out /var/tmp/compact-retry-build \
  --toolchain-root TOOLCHAINS --reference-build PINNED_C_BUILD
PYTHON_WITH_MUJOCO experimental/smooth/tools/compare_numerics.py \
  --report-dir /var/tmp/compact-retry-numerics \
  --probe /var/tmp/compact-retry-build/checked/bin/smooth_probe \
  --samples 24 --policy Compatible --extra-fixtures tests/tree_invariants/fixtures
PYTHON_WITH_MUJOCO tests/movement_performance/c_parity_six/compare.py \
  --build /var/tmp/compact-retry-build --out /var/tmp/compact-retry-session1 \
  --toolchain-root TOOLCHAINS --cpu 12 --blocks 24
```

Run numerical checks under Strict as well, in another report directory. Run a
second independent timing session while no build, proof or other benchmark is
running. Summarize with `c_parity_six/summarize.py`. The checked probe exercises
stale/current dense API calls, unusual output bounds and the symmetry query
immediately after creation. The standalone helper test covers whole-buffer
projection, rejection, clearing and store frame properties.

`evidence/proof-index.json` includes passing, failing, interrupted and timed-out
attempts. Zero checks or timeout is never a passing proof. Proof-source maps
identify the exact snapshots, which are not interchangeable with either runtime
candidate. The complete-unit helper proof is valid for the active helper through
its recorded dependency closure.

See [the report](../../../docs/compact-mass-retry.md) for results and remaining work.
