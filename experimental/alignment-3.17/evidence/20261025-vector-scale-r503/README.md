# Vector Scale_Row and replicated movement measurements

The working smooth kernel retains the separately compiled vector Scale_Row
from r496. The dummy initialization of solver inverses remains unchanged.
All changes are local after published commit `6b552b3af`; no new push is made.
The complete port, C3.17 production migration, full dynamics Gold and overall
C performance parity remain unfinished.

## Retained implementation and proof

Scale_Row uses the same ordered multiplication, with the existing integer-bit
rejection helper instead of a checked running count. Its public input domain,
exact output/rejection/frame specifications and FP evaluation order are unchanged.
The direct expression avoids redundant constrained function argument/result
conversions. No_Inline keeps the vector setup in its own routine, where the
existing release-only 256-bit compiler preference applies. Other arithmetic
bodies and disjoint-row threshold16 are unchanged; the helper declaration moves
before its new use. No assumption, suppression, trusted production body, input
narrowing, fast-math option or deallocator change is introduced.

The C3.17 review covers mj_factorI, mju_scl and its normal four-double AVX helper.
Actual checked Ada release disassembly has two ymm multiply sites in Scale_Row
and no zmm arithmetic or per-element range/overflow-failure sites there. The
routine occupies 327 bytes; its caller occupies 8,810 rather than 8,873 bytes.
These are static instruction/code-size observations, not dynamic time attribution.

The Scale_Row minimum closes 19 checks (17 proof, 2 flow), warning-free. The whole
Solver_Kernels unit closes 156 (139 proof, 17 flow), with five recorded inherited
integer-expression diagnostics; strict warning-free `passed` remains false.
These scopes prove the specified rounded products, rejection and complete frame
under the unchanged preconditions. They are not full factorization, ideal-real
accuracy or whole dynamics proofs. Counts across scopes are not added together.

## Numerical gates and actual adoption

Both ordinary validation and release pass the C3.17/C3.14 suites: 5,760 derivative
cases across the recorded profiles/directions, plus raw mass tests. Shared gates
pass all 14,905 disjoint-row cases and 137,754 generic-row cases per profile,
48 cache records/144 states, and 1,026 compact-CRB constructor cases per profile.
The generic corpus checks signed-zero bits, every rejected lane/sign, empty
arrays, tails, numeric limits and maximum/nonzero origins.

The adopted working files produce the exact full frozen source closure of the
private candidate. Fresh normal shared-builder movement binaries match the
private baseline/current executable SHA256 values exactly. A fresh full actual
default session passes all 30 scenarios and exact Ada endpoint equality, with
C agreement at the unchanged atol/rtol 2e-10. This source/binary binding does not
by itself establish reproducible timings; the placement audit below is required.

The comparator is the pinned source-built C3.17 normal AVX/LTO library, with
known GCC16/native/O3/FP-contraction-off flags. The independent official wheel
is the numerical oracle. Ada keeps checked native O3/LTO, contraction off and
the existing per-file width preference. Sources, commands, toolchain/library
hashes, all raw timings and endpoint outputs are archived.

## Timing qualification: the initial hinge gain is withdrawn

The first two private sessions suggested an approximately 8% hinge gain. A
fresh actual default run using **identical executable bytes, input and model**
does not reproduce it: the baseline itself becomes faster. That gain is
withdrawn. Earlier capture-time scope strings mentioning hinge improvements
are superseded by `timing-qualification.json` and this section; the original
archives are preserved verbatim.

r505 compares two exact-SHA baseline copies and two exact-SHA candidate copies,
plus normal C, at original and common paths and with ordinary/normalized argv0.
It reproduces differences around 8–9% between identical-code copies. Normalizing
argv0 alone does not eliminate them. This does not identify an allocator, cache,
ASLR or filesystem mechanism.

The new benchmark_replicas.py measures three identical-byte executable copies
per implementation, at equal-length paths with normalized argv0, identical
fixtures and balanced cyclic/reverse execution orders. Its uncertainty resamples
replicas first and paired blocks within replicas second. r506 covers all 30
scenarios; r507 independently randomizes copy creation and assignment to neutral
filenames and covers all 30 again. Each uses 36 blocks, eight samples, 32 warmup
trajectories and 100 evolving steps on CPU12. No own heavy jobs overlap timing.
Every executable, numerical output and resolved shared-library hash is checked.

Latest randomized-copy chain24 results (ratio is candidate/baseline time):

| State | Time ratio | Replica/block bootstrap 95% interval | Candidate/C time |
|---|---:|---|---:|
| 0 | 0.97921 | 0.97304–0.98586 | 2.32485 |
| 1 | 0.97982 | 0.97571–0.98658 | 2.32686 |
| 2 | 0.98069 | 0.97616–0.99077 | 2.33077 |

Retain this as an intermediate chain24 improvement: approximately 1.9–2.1%
less time in this randomized-copy session, with the intervals excluding one.
The other replica session and the original paired sessions also support the
chain improvement. Ada still takes about 2.3 times C's time there.

For many small models, randomized-copy intervals include no change. Earlier
paired measurements include real small ball/tendon regressions and a later
replica session includes a small hinge regression. Do not replace those records
with a universal speedup claim. Branch24's latest intervals include one.
No unweighted cross-model average, arbitrary noise allowance or all-workload
performance/parity claim is made. Three sampled placements do not establish a
portable distribution. C launcher copies share the same unchanged pinned MuJoCo
shared-library object; its file placement is not independently varied.

The final driver only adds a positive block-count guard after the recorded run;
a mechanical bridge and synthetic identical/scaled-time/replica-variation
controls are recorded in `bootstrap-controls.json`. No actual timing command or
bootstrap formula changes in that final guard edit.

Example, from the repository root, with frozen movement build metadata and a
previous complete session supplying immutable fixtures:

```sh
python3 experimental/dynamics-derivatives-candidate/tests/benchmark_replicas.py \
  --build MOVEMENT_METADATA --fixtures COMPLETE_SESSION --out NEW_OUTPUT
```

## Other private variants

Outlining the original scalar Scale_Row alone closes the 19/156-check scopes
and passes both corpora, but does not introduce SIMD in that routine and
regresses multi-DOF/tendon workloads. It is not adopted.

The initial no-dummy-inverse-fill version leaves three initialization checks
open. The corrected version explicitly tracks initialized components using
Relaxed_Initialization, a proved prefix invariant and a proved complete-array
initialization assertion. All 93 caller checks close (87 proof, 6 flow), with
12 unchanged recursive-contract/variant warnings. Every relevant read is proved
initialized, including the exit paths; no initialization is assumed. This is
scoped safety/initialization evidence, not a complete functional LDL model.
Its paired movement sessions regress tendons by about 3.1–3.3%, so the change
remains private. r492/r500 no-fill promotion recipes are explicitly unexecuted.

`vector-scale.zip` retains all frozen variants, failed and closed SPARK reports,
private/actual builds, full two-reference gates and initial raw sessions.
`placement-and-replicas.zip` retains the placement audit, both complete replica
sessions, commands, executable copies, old/final providers and raw outputs.
Compiler/prover caches are excluded; source, logs and actual evidence remain.
Use the exact evidence store to restore original ZIP bytes if absent locally.
