# Recorded evidence — 2026-09-30, coordinate correction

This is a standalone candidate for one 1D elastic network and independent
free/fixed rigid bodies. It is not wired into the main loader/step dispatch.
Historical pre-fix results are retained under `baseline/`; they do not describe
the current sources. Current gate/source hashes were checked against the saved
source tree. No proof obligation was replaced by an assumption or suppression.

| Verification | Result | What it establishes |
|---|---:|---|
| C differential cases | 53 passed, 1,888 Euler steps | Supported geometry, forces, reactions and trajectories at unchanged `atol=2e-8, rtol=2e-8` |
| Rejection / degeneracy cases | 10 passed | Rollback, nonconvergence, topology guards, capacity, fixed-body preservation and collapsed edges |
| Coordinate API lifecycle | 5 passed in validation and release | Persistent origins/offsets, stale-position rejection, explicit rebase, array-bounds rejection and late-failure rollback of nonzero offsets |
| Minimum math subprogram gates | 11 passed | Individual checks before the complete math gate |
| Whole contact-math unit | 123/123 | 74 runtime, 27 functional, 22 flow/termination checks; zero skipped/Assume/open |
| Minimum coordinate subprogram gates | 5 passed | Individual checks before the complete coordinate gate |
| Whole coordinate unit | 47/47 | 26 runtime, 2 assertions, 5 functional, 14 flow/termination checks; zero skipped/Assume/open |
| Whole pipeline flow | 176/176 | Initialization, dependency, aliasing and termination analysis only |
| Whole pipeline arithmetic/functional proof | **Open** | Geometry contracts, arithmetic bounds, loop invariants, coupled solver model and whole-step proof remain |
| Symmetric 128-vertex trajectory | **Corrected** | All 8 checked checkpoints through 2,000 steps retain the same selected vertices as C; final maximum position difference 2.776e-17 |

The two complete-unit proof gates include useful floating-point functional
contracts. The math unit specifies dot/cross/vector operations, norm composition,
clipping, coupled PGS projection, scatter, inverse-distance weighting and the
contact regularizer. The coordinate unit specifies the Euler update order,
acceptance **if and only if** its numeric bounds hold, exact state preservation
on rejection, and the reset origin/zero-displacement mapping. Their types and
preconditions bound the supported inputs; these are not proofs of real-valued
physical accuracy or universal C equivalence.

Five standard-runtime `Sqrt` imprecision warnings remain in the math evidence;
the coordinate gate has no diagnostics. Pipeline flow retains 69 ineffective
statement warnings from inlining, 48 possible reassociation diagnostics, 9 array
initialization imprecision diagnostics and 1 array-component aliasing diagnostic.
They are recorded, not suppressed. A passing flow check does not prove pipeline
arithmetic safety or Gold. The bounded pre-fix full-proof attempt is preserved in
`baseline/pipeline-proof-incomplete.log`; no fresh whole-pipeline proof is claimed.
Its missing contracts/invariants are unfinished engineering, not mathematical
exceptions permitting a Silver completion claim.

## Corrections and C comparison

The symmetric trajectory previously diverged because world positions were
integrated directly, whereas C accumulates slide displacement relative to the
model origin. The new persistent coordinates preserve that operation order.
The previous binary still fails at later checkpoints in the recorded before/after
comparison: at step 200 its position error is 0.012245 and force error 105.267.
The corrected position error there is 3.469e-18 and force error 1.421e-14.
At step 2000 the corrected force error is 5.684e-14. No tolerance was widened and
no epsilon was added to C's geometric tie-breaking. The regular comparison suite
also includes a 1000-step uniform-plane trajectory.

A second correction permits the inverse-mass sum of both contacting sides when
each mass is at the supported minimum `1e-15`. The former single-body bound
rejected this valid contact. Its regularizer now has a proved functional contract
and a C differential case.

The test oracle now projects each attached vertex's world force before every
step, keeping its moment arm consistent with a rotating rigid body. A 200-step
loaded-attachment trajectory exercises this. The largest absolute difference in
the complete passing suite is 2.829e-8; acceptance uses the documented combined
absolute/relative tolerance. Counts and statuses are checked separately.

## Integrated timings

Each workload advances 200 Euler steps with the same input model. Baseline Ada,
current Ada and C are checked numerically on all timed cases. The baseline API
lacks offset output, so only its common outputs are compared. The previously
failing symmetric model is a correctness regression, not a baseline-equivalent
timing workload.

C is the MuJoCo 3.14.0 binary library with PGS, automatic Jacobian selection,
warm starting disabled, 10000 maximum iterations and tolerance 1e-14. Ada uses
its deterministic coupled PGS and projected residual criterion. C uses a native
bulk stepping call, with no Python per-step loop. Timed cases have zero applied
forces at attached vertices, so no per-step force projection callback is needed.
Input, reset, process startup, initialization and output are outside the timed
regions. Twenty-one repetitions rotate and reverse baseline/current/C order.

Values are **median [P10–P90] µs/step**; ratios use medians. Raw min/max, all samples,
paired ratios, contact counts, CPU, compiler flags/versions, library hash, source
hashes and load averages are in `benchmark.json` and the build manifests.

| Workload | Baseline Ada | Current Ada | C | Current/baseline | Current/C |
|---|---:|---:|---:|---:|---:|
| sphere | 0.408 [0.398–0.443] | 0.409 [0.389–0.506] | 3.017 [2.819–4.917] | 1.001 | 0.135 |
| shared_body | 0.765 [0.737–0.951] | 0.816 [0.771–0.922] | 3.973 [3.715–5.630] | 1.067 | 0.205 |
| crossing | 0.367 [0.349–0.466] | 0.403 [0.367–0.471] | 2.954 [2.698–11.319] | 1.097 | 0.136 |
| attachment_spring | 0.375 [0.341–0.408] | 0.391 [0.375–0.473] | 2.669 [2.425–3.376] | 1.043 | 0.147 |
| plane_network_32 | 12.505 [11.184–70.196] | 15.128 [11.390–52.601] | 74.150 [43.286–160.636] | 1.210 | 0.204 |
| plane_network_128 | 95.962 [82.288–206.714] | 98.043 [76.393–112.591] | 543.501 [455.910–761.865] | 1.022 | 0.180 |

The medians on these six specialized workloads remain below C. Some current Ada
medians are higher than baseline (up to 21% for the 32-vertex case), but all their
P10–P90 ranges overlap, with very large scheduling tails. Concurrent work was
running on this machine; these results neither establish a stable small
regression nor prove the added coordinate bookkeeping is free. Controlled
hardware measurements remain necessary for a precise overhead verdict.
No unweighted aggregate percentage or whole-engine speedup is claimed. The
sphere, shared-body and crossing trajectories finish with no contacts; the plane
networks retain 32 and 50 active rows respectively.

## Evidence files

- `verification.json`: current scope, counts, hashes, warnings and unfinished work.
- `comparison.json`, `rejections.json`, `coordinate-api.json`: case outcomes.
- `selection-sensitivity.json`: passing current checkpoints plus the old binary's unhidden failures.
- `math-gates.json`, `coordinate-gates.json`: minimum and full gate commands/statuses.
- `math-gnatprove.txt`, `coordinates-gnatprove.txt`, their `*-gate.log` and `*.spark.json`: complete-unit evidence.
- `pipeline-flow-gate.json`, `pipeline-flow.txt`, `pipeline-flow.log`, `pipeline-flow.spark.json`: flow evidence only.
- `benchmark.json`, `validation-build.json`, `release-build.json`: measurement/build provenance.
- `baseline/`: original proof, numeric and performance evidence, including the formerly failing symmetric diagnostic.

Current raw XML, probe input/output, expected C values, individual proof logs and
the pre-fix source/binary snapshot are in
`/var/tmp/sparkling-elastic-contact-fix-20260930`. The previous complete raw run is
`/var/tmp/sparkling-elastic-contact-20260930`. Reproduction commands are in the
candidate README; build/proof outputs use isolated external directories.
