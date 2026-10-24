# Fused support collection: integrated verification, 24 October 2026

Candidate r145 contains the solver support fusion published in e4edda457 and
the previously recorded static force-preparation proof refinements. Only the
solver body, pipeline static lemmas and two new support-count units differ
from the r140 baseline; the archive records the exact source delta.

All numerical gates retain the original samples, cases and tolerances:

| Snapshot | State | Forces | World wrench | Constrained | Total |
|---|---:|---:|---:|---:|---:|
| 3.15 validation r144 | 78 | 66 | 66 | 246 | 456 |
| 3.15 release r145 | 78 | 66 | 66 | 246 | 456 |
| Production 3.14 validation r146 | 78 | 54 | 54 | 234 | 420 |

Timing uses historical C3.15, not latest-stable C3.17. All six MJB/input pairs
are byte-identical to r140. CPU0, 24 alternating complete blocks, 16 measured
100-step trajectories per block, one excluded warmup, normal C SIMD. All own
builds/proofs/profiles were idle; WSL process observations every two seconds
recorded no competing jobs. Arbitrary native Windows activity is not fully
observable. Source, driver and binary integrity passed before and after.

| Workload | Current/previous/C us per step | Duration change [95% CI] | Current/C |
|---|---:|---:|---:|
| membrane_Newton_3 | 10.566/10.651/4.347 | -0.79% [-3.10, +1.87] | 2.431x |
| free | 18.308/18.609/5.865 | -1.62% [-5.26, +2.13] | 3.121x |
| element_2_sphere | 11.154/11.486/4.693 | -2.89% [-6.50, +0.72] | 2.377x |
| element_mixed_pyramidal_3 | 27.628/27.731/10.776 | -0.37% [-2.95, +2.39] | 2.564x |
| element_elastic_cross_elliptic_6 | 64.776/65.910/25.910 | -1.72% [-3.98, +0.62] | 2.500x |
| element_elastic_self_bvh_pyramidal_3 | 53.989/55.094/21.536 | -2.01% [-6.59, +3.20] | 2.507x |

Negative duration changes are faster. Every mean and paired-median interval
includes no change, including the companion six-model Bonferroni intervals.
Therefore this run establishes neither a speedup nor equivalence. Candidate/C
remains about 2.38–3.12x. The broad gap remains; no unweighted average across
models or cross-run absolute timings is used to claim a gain.

The summary retains mean and median estimators, paired mean differences,
trajectory dispersion and P95 with 20,000 paired complete-block bootstrap
draws (seed 2026102402). The 24 blocks are the units, not 384 independent
trajectories. P95 describes whole trajectory duration, not individual-step
tail latency. Unresolved intervals are not proof of parity.

The archive contains commands, logs, frozen current engine sources, numerical
inputs/outputs, both measured runtime probes and all raw timing samples.
Untimed probe ELF payloads (mostly debug sections) are omitted from the public
archive with their SHA-256 listed explicitly; their full sources/build commands
and numerical receipts remain. The complete archive is preserved locally at
the path/hash recorded in archive-manifest.json. The exact baseline
and external C library sources/payloads are reused from the previous verified
archive identified in reused-evidence.json. The 3.15 validation source closure
is identical to release and is stored once. Temporary absolute paths in the
receipts identify actual runs; reproduction requires extracting sources and
adapting these paths with the recorded toolchain and wheel versions.

Gold remains local: the published support counter proves an exact bounded
integer sum, but global solver/caller proofs remain open. This checkpoint does
not establish full engine or latest-stable alignment.
