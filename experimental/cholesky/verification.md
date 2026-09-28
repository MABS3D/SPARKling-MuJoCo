# Verification and performance — dense Cholesky

Implementation checkpoint, 2026-09-28. Scope: the dense factorization, solve,
and rank-one update/downdate APIs. This is **not** complete Gold closure,
global C parity, or integration into the dynamics solver.

## Numerical differential and independent checks

Both validation (`-gnata -gnato -gnatVa`) and release builds pass **1,210 cases
and 1,648,938 scalar/rank comparisons each**, or **3,297,876 comparisons** total.
All compared numerical values equal the MuJoCo 3.14.0 reference in this sample.
This is a numerical sample, not a universal or bit-pattern equivalence theorem.
Sizes include 0–17, 24, 32, 64, 96 and 128; the deterministic seed is 20260928.
Coverage includes SPD matrices, triangular solves, positive updates, admissible
downdates, clamped deficient pivots, exact threshold neighbours, zero and sparse
update vectors, diagonal scales, unchanged upper triangles and destructive X.
Independent LLᵀ reconstruction / solve residuals reach at most
**1.865e-15 relative residual** in the tested SPD cases.
Indefinite downdates are compared against C clamping semantics rather than
asserting that the clamped result exactly factors the requested indefinite matrix.

[Validation results](results/numerics-validation.json),
[release results](results/numerics-release.json),
[source manifest](results/manifest.json).

## Formal verification

`MJ.Cholesky_Steps` is closed: **57 checks**, consisting of 43 proof obligations
and 14 flow/termination checks. The proved scalar functional contracts specify
product, pivot square, pivot clamp/root, factor-entry update, signed rank-one
entry update, and destructive vector update under the documented magnitude
domains. Root equality is relative to the existing Ada elementary-function
contract, not a new correctly-rounded-sqrt theorem.
[Complete-unit report](results/proofs/steps/summary.txt).

`MJ.Cholesky_Models`: **97/105 proof obligations closed**, plus 11 flow checks.
Eight remain open: the recursive lane result bound, six operand bounds in
the tail, and the combined dot result bound. The recurrence unfold lemma,
bounded addition and input-shape predicate are proved under their contracts.
The four-lane production reduction has an exact ordered floating-point model;
its composition is not promoted to Gold while supporting obligations remain open.
[Complete-unit report](results/proofs/models/summary.txt).

`MJ.Cholesky`, final complete-unit attempt: **147/236 proof obligations closed**,
89 still open. This is neither complete Silver nor complete Gold.
[Full report](results/proofs/algorithms/summary.txt) and
[remaining obligations by location](results/proofs/algorithms/status.json).

| Subprogram | Proof obligations closed |
| --- | ---: |
| `MJ.Cholesky.Dot` | 61/90 |
| `MJ.Cholesky.Factor` | 27/41 |
| `MJ.Cholesky.Positive_Diagonal` | 3/3 |
| `MJ.Cholesky.Same_Upper` | 7/7 |
| `MJ.Cholesky.Shape` | 1/1 |
| `MJ.Cholesky.Solve` | 13/29 |
| `MJ.Cholesky.Update` | 34/64 |
| `MJ.Cholesky.Vector_Shape` | 1/1 |

The initial attempt found 62 open obligations, including shape predicates that
could raise during length conversion for excessively large arrays. The final
predicates guard length before conversion; the two predicate proofs now close.
The older attempt and its exact algorithm sources are retained only as a
[diagnostic/measured snapshot](results/proofs/algorithms-initial/summary.txt).
Changing prover strategy/time limits changes which other checks close; counts
from these attempts must not be interpreted as a monotonic progress percentage.

No `Assume`, suppression or trusted replacement body was introduced.
Unclosed bounds/invariants are unfinished proof engineering. No mathematical
limitation or Silver-only exception is claimed to excuse these obligations.
In particular, shape and a positive diagonal alone do not bound arbitrarily
ill-conditioned computations. A checked call may raise a numeric range or
overflow exception; callers need stronger numerical admissibility contracts
before the iterative kernels can have a complete safety/functional claim.

## Release timing against the unmodified C algorithms

AMD Ryzen 7 9800X3D, GNAT/GCC 16.1.0. C is built from the pinned MuJoCo sources
with the normal platform SIMD path enabled. Both languages use O3, native ISA,
LTO and disabled FMA contraction; exact switches are in [benchmark.gpr](benchmark.gpr).
Nine paired samples alternate Ada/C order on the same pinned logical CPU.
Input reset and checksum consumption are outside the timed interval; each
batch has independent prepared inputs. Checksums of both modified arrays are
compared. Compiler-switch experiments use a forced fresh build.
The machine was shared with other work; some intervals are wide.
The JSON preserves all samples and paired-median bootstrap 95% intervals.
These intervals describe this run and do not eliminate host scheduling bias.

Ratios below are median paired **Ada time / C time**; smaller is faster.
The cycle consists of factorization, solve, positive update and another solve.
It is an algebra workload, **not an integrated MuJoCo simulation step**.

| N | Factor | Solve | Update | Downdate | Algebra cycle | Cycle 95% interval |
| ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 | 1.326 | 1.471 | 0.601 | 0.582 | 1.249 | 0.954–1.594 |
| 3 | 1.387 | 0.924 | 0.753 | 0.804 | 1.100 | 0.668–1.377 |
| 6 | 1.473 | 0.989 | 0.896 | 0.767 | 1.075 | 0.834–1.117 |
| 12 | 1.450 | 0.914 | 0.897 | 0.914 | 1.002 | 0.976–1.062 |
| 24 | 1.564 | 0.820 | 0.950 | 1.001 | 1.220 | 1.080–1.344 |
| 48 | 1.613 | 0.918 | 1.062 | 1.048 | 1.228 | 1.144–1.475 |
| 96 | 1.244 | 0.923 | 1.449 | 1.288 | 1.271 | 1.087–1.414 |

Factorization remains slower in the reproducible larger cases. Several small
updates/downdates are faster, but those improvements do not establish aggregate
parity: the algebra cycle is approximately 22–27% slower at N=24–96.
At N=12 its measured interval includes parity. There is no prior implemented
Ada Cholesky baseline in this delivery and no integrated dynamics speedup claim.
[Raw measurements and build/source hashes](results/performance.json).
The final shape-predicate guard change and removal of an unused initializer leave
the entire release executable byte-identical: [binary and section hashes](results/performance-applicability.json).
The measured source snapshot is retained with the initial algorithm proof report.

## Build and integration status

The standalone checked/release probes and C/Ada benchmark compile successfully.
The default checked library project also builds against published base commit
`89648379ce915846dc63febbeccaa434ea6fc720` in an isolated snapshot.
An attempted build against the concurrently edited shared tree encountered
ghost-policy errors in existing quaternion/rotation units. Those files were
not modified by this task; the isolated baseline check avoids altering that work.
[Library build log](results/library-build.txt).

Next proof work: close model operand bounds; express admissible intermediate
growth in caller contracts; prove the row-major frame invariants and every
iteration against the ordered model. Next performance work: factorization
code generation and large updates, followed by equivalent integrated workloads.
Sparse and banded variants require separate algorithms and contracts.
