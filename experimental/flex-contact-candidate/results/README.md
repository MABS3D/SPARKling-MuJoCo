# Verification results — 2026-09-30, C contact filter

Current Ada hashes are in `sources.json`. All three candidate units have fresh complete-unit proofs, covering every declared subprogram. No proof/flow skips, assumptions or trusted new bodies. Dependency proofs are reused only after verifying identical source bytes; their original reports remain archived.

## Complete-unit proofs

| Unit | Closed | Open | Evidence |
|---|---:|---:|---|
| `mj-flex_contact_filter` | 426 | 0 | fresh complete unit |
| `mj-flex_contact_kernels` | 159 | 0 | fresh complete unit |
| `mj-flex_contact_network` | 361 | 0 | fresh complete unit |
| `mj-contact_rows` | 226 | 0 | unchanged dependency |
| `mj-elastic_kernels` | 179 | 0 | unchanged dependency |
| `mj-elastic_network` | 652 | 0 | unchanged dependency |
| **Total** | **2003** | **0** | **946 in the three candidate units** |

Gold covers the ordered floating-point geometry, collection/filter/cache transitions, retained-rank mapping, force composition, Euler updates and atomic rollback. These proofs do not assert ideal-real stability, energy conservation or universal C equivalence. Ghost congruence lemmas prove replacement of equal floating-point records across recursive models; they disappear from executable builds.

Warnings in `proofs.json` remain visible: inherited runtime `Sqrt` modeling and recursive contract/variant availability, plus the recursive filter-model warnings. The filter also reports an array-initialization approximation at the rank scatter: the entire output is explicitly zero-initialized before that loop, and all flow and functional checks pass. No warning is suppressed.

## Numerical and boundary tests

Each checked and release build passes **144 full-engine differential cases**, **54 exact filter-order cases**, and **5 boundary/rollback tests**. Full-engine fixtures use one actual MuJoCo flex, 2/8/32/51/64/128 vertices, and 1/200 steps. Additional filter fixtures cover 0/1/2/49/50/51/64/128/4096 contacts, ties, coincident points, signed zeros, deepest-last order, and distance-cache saturation. The extracted filter body is unchanged; only allocation and arena bookkeeping use local stubs. These tests complement, rather than replace, the real-engine trajectory tests.

| Quantity | Maximum absolute error |
|---|---:|
| acceleration | 1.137e-13 |
| contact | 2.274e-13 |
| rank | 0 |
| position | 8.838e-14 |
| velocity | 1.301e-11 |

The `rank` error above compares the retained sets after C's later vertex-ID sort; the exact-order harness separately compares the literal filter output. Pinned diagnostic reactions deliberately remain zero in SPARK, as documented in the main README. Mobile forces and all states are compared at absolute and relative tolerance `2e-9`, with no C warnings accepted.

Boundary tests cover exact margin/gap thresholds, position and velocity rollback, and full 4096-particle capacity with 50 and 51 detected contacts. The 51st contact now triggers filtering and a successful step. The 4096-particle step cases test bounds; full-engine trajectory comparisons stop at 128 vertices.

## Integrated supported-subset performance

Microseconds per complete elastic/contact/solve/Euler step, median of 24 measured 1000-step trajectories per backend and model, in eight alternating blocks. Preparation and I/O are outside the clock; all timed final states agree. Previous Ada is compared on its common <=50-contact domain; it rejected larger contact sets.

| Scenario | Vertices | SPARK μs | C μs | SPARK/C paired ratio [95% CI] | Current/previous Ada [95% CI] |
|---|---:|---:|---:|---|---|
| rest | 4 | 0.122 | 4.243 | 0.0297 [0.0260, 0.0301] | 1.208 [1.196, 1.219] |
| rest | 16 | 0.422 | 14.427 | 0.0286 [0.0267, 0.0308] | 1.096 [1.023, 1.153] |
| rest | 32 | 0.818 | 34.393 | 0.0240 [0.0233, 0.0248] | 1.102 [1.067, 1.138] |
| rest | 50 | 1.290 | 52.974 | 0.0240 [0.0223, 0.0259] | 1.108 [1.091, 1.142] |
| rest | 64 | 4.358 | 63.848 | 0.0719 [0.0648, 0.0837] | unsupported by previous Ada |
| rest | 128 | 8.488 | 88.019 | 0.0956 [0.0902, 0.1014] | unsupported by previous Ada |
| tilt_impact | 4 | 0.117 | 3.935 | 0.0292 [0.0280, 0.0298] | 1.222 [1.218, 1.223] |
| tilt_impact | 16 | 0.389 | 12.354 | 0.0316 [0.0283, 0.0318] | 1.054 [1.035, 1.159] |
| tilt_impact | 32 | 0.779 | 30.211 | 0.0261 [0.0224, 0.0264] | 1.081 [1.060, 1.100] |
| tilt_impact | 50 | 1.212 | 50.653 | 0.0240 [0.0236, 0.0249] | 1.067 [1.012, 1.088] |
| tilt_impact | 64 | 3.544 | 58.682 | 0.0604 [0.0575, 0.0623] | unsupported by previous Ada |
| tilt_impact | 128 | 7.514 | 77.371 | 0.0944 [0.0880, 0.0987] | unsupported by previous Ada |

The filter adds measurable overhead on the small workloads versus previous Ada; the table exposes those regressions and their confidence intervals. All measured supported workloads remain faster than native C Newton with warm-start and islands enabled. This is **not full MuJoCo parity**: Cartesian independent normal rows admit a specialized scalar solve, while C performs generic collision/model/constraint bookkeeping. Missing friction, general collision and articulated coupling cannot be inferred from these timings.

The workstation was shared and loaded. Raw samples, p10/p90/p99 dispersion, paired bootstrap intervals, affinity, CPU/compiler details, native C Newton/warm-start/island settings and AVX/LTO flags and executable/library hashes are in `performance*.json` and the archive. Both compilers disable FMA contraction.

## Evidence and remaining scope

`flex-filter-evidence.zip` contains final source/build snapshots, fresh complete-unit reports and logs, dependency reports, small-subprogram diagnostics, numerical/filter fixtures and outputs, and benchmark metadata/raw outputs. `flex-contact-evidence.zip` is the preserved pre-filter baseline, whose claims apply only to its own archived sources. Hashes are in `summary.json` and `SHA256SUMS`.

Remaining: friction, other rigid shapes, flex-flex/self-collision, multiple planes, articulated coupling, continuum/bending/interpolated flex, implicit integration and main-loader integration. The old 50-detected-contact rejection is removed.
