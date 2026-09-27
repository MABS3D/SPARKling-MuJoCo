# Accepted elastic-network evidence — 2026-09-28

The standalone Cartesian particle/edge API implements contact-free elasticity,
viscous edge damping, gravity, applied vertex forces and semi-implicit Euler.
The accepted source and harness snapshots are in [evidence.zip](evidence.zip).
This is the first elastic subset; it does not enable flex loading in `MJ.Data`
or provide articulated coupling, contact, self-contact or continuum FEM.

## Formal verification

Both complete SPARK units passed with zero unproved checks, flow errors or
warnings. Counts below come from complete-unit invocations, not sums of repeated
subprogram runs.

| Unit | Checks proved | Open | Evidence |
| --- | ---: | ---: | --- |
| `MJ.Elastic_Kernels` | 144 | 0 | [Report](proofs/kernels/report.md) |
| `MJ.Elastic_Network` | 616 | 0 | [Report](proofs/network/report.md) |

**760 checks closed.** The functional properties are:

- squared length and ordered composition with the runtime square root;
  tiny-length fallback direction and pinned-aware edge speed;
- exact rounded spring/damper formulas and signed endpoint projection;
- input-order accumulation into a recursive floating-point prefix model;
- successful velocity/position updates equal the specified semi-implicit Euler
  calculation using those accumulated forces;
- mass and pin preservation, fixed-node preservation, valid topology after the
  step, and rollback of the entire particle state on numeric failure;
- array bounds, initialization, arithmetic bounds and termination under the
  documented public preconditions.

The velocity expression is both the executable scalar calculation and its
public ordered model. Proof-only traversals and refinements are static ghost
code. There are no new `Assume`, suppressed checks or trusted bodies. The final
network pass reused the normal GNATprove cache after dependency invalidation;
it requested the complete unit and emitted all 616 checks. The accepted source
hashes match both numerical and release-build snapshots.

Gold here describes these key functional/integrity contracts. It is not a
universal proof of C equivalence, real-arithmetic accuracy, energy conservation,
stability or the rest of the simulator. The existing Ada runtime sqrt contract
is the explicit boundary: nonnegativity is available, an upper accuracy bound
is not. The implementation checks its conservative length limit rather than
assuming that missing property. Floating-point ordering is retained; ideal-real
associativity is never substituted for the rounded accumulation.

## Numerical comparison

The checked build (`-gnata -gnato -gnatVa`, contraction off) passed **312 C
scenarios / 43,056 scalar comparisons**, plus **6 boundary tests**. The reference
is the actual MuJoCo 3.14.0 C engine through its Python binding. Tests cover free
and pinned networks, no edges, rings, grids, stars, disconnected components,
spring-only/damper-only/disabled edges, minimum masses, collapsed and tiny edges,
with randomized geometry, masses, velocities and applied forces. Trajectories
run for one or 100 steps. The tolerance is `atol = rtol = 2e-10`.

Boundary tests cover failure after an earlier particle has already advanced in
the candidate (full rollback), pinned stored velocities and zero timestep,
4,096 vertices, 4,096 duplicate edges, self-edges and out-of-range endpoints.
The last two are rejected by `Valid` before invoking the dynamics API.

| Quantity | Maximum absolute difference from C |
| --- | ---: |
| spring | 0 |
| damper | 4.16334e-17 |
| position | 2.35922e-15 |
| velocity | 7.82707e-14 |

[Per-case results](numerics.json) and archived C expected values distinguish
numerical agreement from proof. The native C performance harness independently
checks final positions and velocities after 1,000 steps (`atol = rtol = 2e-9`).
No simulation warnings or numeric-limit failures occurred in those comparisons.

## Complete-step performance

Ryzen 7 9800X3D, Linux/WSL, CPU affinity 8. Each size has 16 alternating Ada/C
blocks, three timed 1,000-step trajectories per engine per block, and an untimed
warm-up per process. Initial-state construction, model loading and output are
outside timing. Force evaluation, integration and the Ada candidate commit are
inside timing. All final states passed the native C comparison.

C uses MuJoCo 3.14.0 commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`,
its native optimized library with normal SIMD, GCC 16.1, `-O3 -march=native`, LTO,
and contraction disabled. The C harness uses GCC 13.3. Ada uses GNAT/GCC 16.1,
`-O3 -gnatp -gnatn -march=native -flto -ffp-contract=off`. Complete flags, versions,
library hashes and host information are in [environment.json](environment.json)
and the archived build manifests. These are different checked and release
builds; proof contracts justify the release preconditions.

Times are microseconds per step. Speedups use paired block ratios; they need not
exactly equal the ratio of the separately pooled timing medians.

| Nodes | Ada median | C median | Paired speedup | p90 Ada / C | p99 Ada / C |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 4 | 0.055 | 1.067 | 18.7× | 0.080 / 1.454 | 0.118 / 1.882 |
| 16 | 0.229 | 3.942 | 16.6× | 0.350 / 5.162 | 0.579 / 5.791 |
| 64 | 1.025 | 14.595 | 14.3× | 1.268 / 16.466 | 1.432 / 18.851 |
| 128 | 2.029 | 29.004 | 13.7× | 2.861 / 31.274 | 3.423 / 34.290 |

| Nodes | Median Ada/C ratio | Bootstrap 95% interval |
| ---: | ---: | ---: |
| 4 | 0.0535 | 0.0519–0.0568 |
| 16 | 0.0603 | 0.0460–0.0696 |
| 64 | 0.0698 | 0.0651–0.0786 |
| 128 | 0.0729 | 0.0677–0.0753 |

These are specialized Cartesian edge networks with diagonal particle masses.
C performs additional general-engine body, kinematic, inertia and BVH work.
The measured advantage applies to this equivalent supported physical subset;
it is not evidence that the full SPARK MuJoCo port outperforms C. There was no
previous Ada deformable implementation to benchmark as an older baseline.
Host activity and timing dispersion remain visible in [raw timing results](timings.json);
the confidence intervals describe these runs, not all machines or workloads.
Actual run arguments are in `timings.json/run`; build-only defaults in the
archived build manifest do not override those arguments.

## Reproduction and archive

Use the build, comparison and proof commands in the [module README](../README.md).
The shipped `spring_pair.input` example also built and ran successfully using
`elastic.gpr`; its output is archived as `demo.log`.

The zip contains complete numerical fixtures and C expected values, raw timing
samples and final states, build/proof manifests and logs, the verified dependency
closure, harness sources, and a per-file SHA-256 inventory. Binaries and failed
intermediate attempts are excluded. The proof runner's original manifests also
list unrelated source hashes copied for discovery; only the elastic dependency
closure is included in `verified-source/` and involved in these proofs.

Archive SHA-256: `db4995d4e6fe5bf49d94716d1a6ac9d290883db68fc1cdf041aa058a5aaac9a7`.
