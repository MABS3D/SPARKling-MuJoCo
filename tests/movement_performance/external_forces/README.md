# External body-force implementation evidence

Implemented world-frame force/torque inputs at body COMs, direct projection on
ancestor DOFs, and Forward/Euler integration. See
[API and assurance scope](../../../docs/external-body-forces.md).

## Checked numerical comparisons

| Suite | Scenarios | Scalar comparisons | Result |
| --- | ---: | ---: | --- |
| External loads, Compatible | 624 | 172,944 | Pass |
| External loads, Strict | 624 | 172,944 | Pass |
| Original workload, Compatible | 624 | 168,192 | Pass |
| 64-DOF chain/star, Compatible | 12 | 63,852 | Pass |
| 64-DOF chain/star, Strict | 12 | 63,852 | Pass |

The main suite has 26 models, 24 states each, including repeated 100-step
trajectories. Two additional 64-DOF models each have six load patterns and up
to five checked Euler steps, exercising C's AUTO sparse-Jacobian path. The
initial 100-step checked runs at 64 DOFs exceeded the 60-second probe cap;
those timeouts are not passes or release-performance measurements. All checks
use `atol = rtol = 2e-10`. Both external suites explicitly test removal and
restoration of loads, world-body exclusion, force/torque-only inputs, fixed
children, rotated/offset COMs, multiple scalar joints, multiple roots and damping
branches. Invalid array length/lower bound is rejected before mutation. Fifteen
separate policy/rejection checks include a valid external force that would
produce an out-of-domain acceleration, and failed-step state preservation.

The checked source and executable are frozen in the archive. The subsequent
source changes make a **Static Ghost** bound lemma unconditional in
`Apply_External_Total`, strengthen a **Static Ghost** ready-state lemma, and
use the existing `Positions_Current` contract for composition. The original
`Fill_Total` declaration/body are preserved exactly. The runtime projection and solve are unchanged. `dependency-audit.json` checks
the 84-file numerical project closure; other concurrent experimental units
found in some snapshots are outside its `Source_Files` list and outside these
verification claims.

## Whole-step measurements

11 models × 3 states × 4 profiles, two independently ordered sessions. Each
profile uses 24 balanced blocks, four 100-step timed trajectories per executable
and two warmups. CPU affinity: 12, Ryzen 7 9800X3D, GNAT/GCC 16.1.0,
O3/native/LTO, FP contraction disabled, normal native C SIMD. C library:
MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

Every timed output is checked against C (maximum absolute error
`3.8914e-14`). With no body-load argument, current and preceding Ada results
match exactly. The preceding Ada build includes the adopted gravity guard
optimization; it is not compared with nonzero body-load profiles it cannot run.

**These are diagnostic measurements with other proof jobs active on the host.**
Start/end process lists and per-run load averages are retained. They do not
establish quiet-host parity or a regression-free build. No absent-load case has
a slowdown interval wholly above 1 in both sessions, but that is not proof of
no overhead. Smaller differences need an uncontended rerun.

The table gives the range of **paired median current-Ada/C time ratios** across
three states and two sessions, not an average of percentages. Below 1 is faster.
The archive contains each case's absolute time, MAD, p95, bootstrap 95% interval,
paired order and raw trajectory measurements. There is no weighted aggregate
claim across unrelated models.

| Model | Argument omitted | Explicit zeros | One loaded body | All nonworld bodies loaded |
| --- | ---: | ---: | ---: | ---: |
| `ancestor_branches_24` | 1.323–1.434 | 1.357–1.438 | 1.332–1.364 | 1.001–1.089 |
| `ancestor_forest_24` | 1.348–1.425 | 1.376–1.443 | 1.323–1.380 | 0.980–1.029 |
| `ancestor_star_24` | 1.383–1.436 | 1.364–1.420 | 1.236–1.385 | 0.835–0.949 |
| `branched_multijoint` | 0.919–0.991 | 0.905–0.968 | 0.898–0.942 | 0.837–0.859 |
| `chain_12` | 1.236–1.310 | 1.247–1.318 | 1.198–1.290 | 1.071–1.173 |
| `crb_chain_24` | 1.347–1.483 | 1.420–1.502 | 1.337–1.424 | 1.206–1.240 |
| `crb_no_damping` | 1.102–1.163 | 1.137–1.206 | 1.039–1.125 | 0.972–0.988 |
| `hinge_motor` | 0.716–0.763 | 0.741–0.774 | 0.662–0.715 | 0.659–0.704 |
| `simple_hinges_6` | 1.325–1.389 | 1.346–1.410 | 1.252–1.316 | 0.983–1.046 |
| `simple_mixed_8` | 0.819–0.926 | 0.899–0.927 | 0.846–0.884 | 0.758–0.856 |
| `simple_sliders_6` | 0.819–0.843 | 0.837–0.861 | 0.764–0.783 | 0.743–0.768 |

With distributed loads, several trees approach or exceed C throughput, whereas
the 24-DOF serial chain remains about 21–24% slower in these sessions. Adding
body loads therefore does not establish general parity. The workload-dependent
benefit must not be presented as an optimization of the pre-existing zero-load
path.

## Formal checks

| Scope | Checks | Status |
| --- | ---: | --- |
| `mj-external_forces.adb` | 25 | completed_no_unproved |
| `mj-data-external_loads.adb` | 37 | completed_no_unproved |
| `Evaluate_Ready` | 26 | completed_no_unproved |
| `Evaluate_Actuation_Acceleration` | 18 | completed_no_unproved |
| `Step_Ready` | 35 | completed_no_unproved |
| `Evaluate` | 6 | completed_no_unproved |
| `Step` | 7 | completed_no_unproved |
| `Solver_Ready_Properties` | 2 | completed_no_unproved |
| `Apply_External_Total` | 14 | completed_no_unproved |
| `Solve_Acceleration` | 29 | completed_no_unproved |

Counts are per emitted scope under its callees' contracts; declaration/body
duplicates are counted once. Exact formulas, single-component updates and frames
are functional properties. Traversal safety, bounds, empty-input identity and
invalid-size identity are proved separately. The unmodified `Fill_Total` is not counted as a new proved scope; its exact
declaration/body continuity is recorded in `fill-continuity.json`. A full ordered traversal model
linking all updates to the complete generalized-force result is **pending proof
engineering**, not a mathematical Silver exception. This is not a proof of all
MuJoCo dynamics. Failed/time-limited earlier attempts are archived separately
and are not counted as accepted proofs.

## Reproduce and inspect

`evidence.zip` contains frozen checked/release sources, input fixtures, reference
outputs, binaries, build commands/flags/hashes, proof logs/source snapshots and
both timing sessions. `evidence.sha256` protects the archive; its internal
`SHA256.json` inventories the files. `proof-summary.json` lists accepted and
pending scopes without counting a timeout as a pass.

Run `compare_numerics.py --external --policy Compatible` and again with
`--policy Strict`, using the documented 26-fixture set. Run without `--external`
for the original-workload regression.

```sh
python tests/movement_performance/external_forces/run.py --build \
  --out /absolute/new-build --previous /absolute/preceding-build \
  --toolchain-root /absolute/toolchains
python tests/movement_performance/external_forces/run.py \
  --out /absolute/new-build --inputs /absolute/fixture-inputs \
  --session 1 --blocks 24
```

The archived input directory contains every MJB and profile-specific input;
for `--inputs`, reconstruct the original `model-state.input` names by copying
the corresponding `model-state-absent.input` files. The baseline build metadata
in `build.json` identifies the preceding binary and source hashes. Keep separate
output directories when changing sources, compilers or the harness.
