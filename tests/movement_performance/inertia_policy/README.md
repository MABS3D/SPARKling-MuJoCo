# Inertia policy experiment

`baseline/` freezes the 26 smooth sources immediately before the policy change;
`baseline.json` records their hashes. This compares the prior CRB/RNE build with
the default Compatible policy and reverse factorization. It does not activate
Ready_Flag or remove Jacobians. See [results](../../../docs/inertia-policy.md).

Use the existing toolchains and Python with MuJoCo 3.14.0/NumPy:

```sh
python3 tests/movement_performance/inertia_policy/build.py \
  --out /var/tmp/policy-build-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --reference-build /var/tmp/sparkling-movement-final

/var/tmp/sparkling-movement-env/bin/python experimental/smooth/tools/compare_numerics.py \
  --probe /var/tmp/policy-build-new/checked/bin/smooth_probe \
  --report-dir /var/tmp/policy-compatible-new --policy Compatible \
  --extra-fixtures tests/movement_performance/dynamics_optimization/fixtures
# Repeat with --policy Strict and a new report directory.

/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/inertia_policy/check_policy.py \
  --probe /var/tmp/policy-build-new/checked/bin/smooth_probe --out /var/tmp/policy-edges-new

python3 tests/movement_performance/inertia_policy/profile.py \
  --build /var/tmp/policy-build-new --out /var/tmp/policy-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains

# Only after builds/proofs/checks finish; repeat in a second output directory.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/dynamics_optimization/compare.py \
  --build /var/tmp/policy-build-new --out /var/tmp/policy-first-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --cpu 12

# Run profiling separately from the uninstrumented sessions.
/var/tmp/sparkling-movement-env/bin/python tests/movement_performance/inertia_policy/profile.py \
  --build /var/tmp/policy-build-new --out /var/tmp/policy-profile-new \
  --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains \
  --fixtures /var/tmp/policy-first-new/timings --cpu 12
```

The builder uses this directory's baseline. Historical benchmark keys mean
`current` = Compatible, `baseline` = prior strict implementation. Profiling
never enters proof or release binaries. The numerical runner always executes
its historical rejection cases with explicit Strict; `policy_tests_mode`
records that separately from the mode selected for numerical scenarios.

Read the report's fixture notes about `dof_simplenum` and armature edits before
using the policy test as an oracle for another path. `evidence/` contains both
timing sessions/raw records, checked suites for both modes, boundary tests,
strict-output preservation, proof snapshots/logs, profile and build inputs.
Open proofs remain open; successful tests do not establish whole-solver Gold.
