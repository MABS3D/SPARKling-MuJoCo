# Recorded evidence — 2026-09-30

The code is a standalone candidate for one 1D elastic network and independent
free/fixed rigid bodies. It is not part of the main loader/step dispatch.

| Verification | Result | What it establishes |
|---|---:|---|
| C differential cases | 50 passed, 687 Euler steps | Supported contact geometry, forces, reactions and trajectories within `atol=2e-8, rtol=2e-8` |
| Rejection / degeneracy cases | 10 passed | Rollback, nonconvergence, topology guards, capacity, fixed-body preservation and collapsed edges |
| Minimum math subprogram gates | 10 passed | Individual diagnosis before the whole-unit gate |
| Whole contact-math unit | 112/112 | 66 runtime checks, 26 functional checks, 20 dependency/termination checks; zero skipped/Assume/open checks |
| Whole pipeline flow | 174/174 | Initialization and dependency analysis only |
| Whole pipeline arithmetic/functional proof | **Incomplete** | Resource-bounded attempt stopped after 240.2 s, peak group RSS 2567 MB; no whole-pipeline Silver/Gold claim |
| Symmetric 128-vertex trajectory | **Known divergence** | Initially identical contacts; rounding breaks selection ties on later steps. Retained separately, not counted as passing equivalence |

The whole math unit retains five `imprecise-call` messages about the standard
runtime square-root abstraction in its `.spark` evidence. The proved norm
contract relates the implementation to that runtime call; it is not a proof of
the library's real-arithmetic accuracy. No project body is newly trusted, no
check is suppressed, and no proof unit is skipped. Existing warnings are kept.

The largest absolute difference among reported quantities in the passing C
suite is 2.829e-8; acceptance uses the stated combined absolute/relative tolerance,
not that absolute value alone. Counts and failure statuses are checked separately.
The original uniform large-plane failure is preserved by
`tests/selection_sensitivity.py`; tolerances were not widened to make it pass.

## Integrated timings

Both sides advance the same 200-step trajectory. C is the MuJoCo 3.14.0 binary
library with PGS, automatic dense/sparse Jacobian selection, warm starting
disabled, 10000 maximum iterations and tolerance 1e-14. Ada uses deterministic
coupled PGS with the API's convergence criterion. Numerical comparisons run
before timing every workload. C uses one native bulk stepping call, not a Python
per-step loop. Input, reset, initialization, process startup and output are
outside timed regions. Eleven repetitions alternate execution order; the JSON
retains all samples and tail/max values.

| Workload | Ada µs/step | C µs/step | Ada/C | Ada P10–P90 µs | C P10–P90 µs |
|---|---:|---:|---:|---:|---:|
| sphere | 0.428 | 2.945 | 0.145 | 0.393–0.462 | 2.812–4.719 |
| shared_body | 0.784 | 4.601 | 0.170 | 0.746–1.004 | 3.885–5.904 |
| crossing | 0.396 | 2.800 | 0.141 | 0.353–0.496 | 2.401–3.072 |
| attachment_spring | 0.383 | 2.721 | 0.141 | 0.344–0.446 | 2.370–3.037 |
| plane_network_32 | 11.339 | 43.696 | 0.259 | 10.615–11.554 | 42.007–46.292 |
| plane_network_128 | 90.617 | 555.159 | 0.163 | 73.075–127.790 | 458.987–728.046 |

These are specialized workloads, not an engine-wide performance result. In the
sphere, shared-body and crossing trajectories contacts separate during the run;
their final contact counts are zero. The two plane networks keep 32 and 50 active
rows respectively. Other work was running on this machine; treat these as
preliminary workload measurements, not controlled hardware acceptance results.
Hardware, compiler versions, flags, library hash, source hashes, load averages,
contact counts and timing samples are recorded in the JSON files.

## Files

- `verification.json`: scope, counts, hashes and explicit unfinished work.
- `comparison.json`, `rejections.json`: case-by-case outcomes.
- `selection-sensitivity.json`: unhidden failing trajectory-equivalence diagnostic.
- `math-gnatprove.txt`, `math-gate.log`, `math.spark.json`: complete math proof evidence.
- `pipeline-flow.txt`, `pipeline-flow.log`: initialization/dependency evidence.
- `pipeline-proof-incomplete.log`: bounded failed full-proof attempt.
- `benchmark.json`, `release-build.json`: measurement and compiler provenance.

Raw XML, probe input/output, expected C values and individual proof logs remain in
`/var/tmp/sparkling-elastic-contact-20260930`. The source/test harnesses reproduce
these locally without writing into shared build directories.
