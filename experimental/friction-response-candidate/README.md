# Pyramidal friction response candidate

Standalone SPARK/Ada response for **already assembled**, dense, regularized dual
systems (`AR`, `b`). Based on MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. It is separate from the constraint
solver candidate under development and does not replace the active engine step.

Implemented:

- `condim=3`: normal force and two sliding components;
- `condim=4`: also torsional friction;
- `condim=6`: also two rolling components;
- C's encode/decode of pyramidal coordinates, including its asymmetric encoder
  clipping and ordered normal-force summation;
- coupled scalar PGS rows, with signed equality forces, bounded joint/tendon dry
  friction, and nonnegative contact/limit coordinates;
- C's double-reciprocal cost test, rejected-cost restoration, deterministic PCG32
  shuffle, four-lane residual reduction, Nesterov momentum and adaptive restart;
- explicit rejection of invalid/out-of-domain input without changing the initial
  force; a finite iteration limit publishes a feasible last iterate.

`Friction` has the C ordering: sliding 1/2, torsion, rolling 1/2. `Decode` returns
six local contact-frame components; unused components and edges are zero. The
encoder is C's redundancy convention, **not** a universal projection onto the
friction cone. The `condim=1` encoder copies the scalar force as a documented
extension (C's encoder divides by zero for that dimension; its decoder supports
it). No exact real cone identity is asserted for rounded binary64 arithmetic.

## API and numerical domain

`MJ.Friction_Kernels` provides the coordinates, projections and guarded scalar
update. `MJ.Friction_Random` provides the exact modular PCG32 transition.
`MJ.Pyramidal_PGS.Solve` receives `AR`, `b`, row kinds, friction-loss bounds and
a feasible warm start. Arrays begin at 1; an empty problem is `1 .. 0`.

The candidate supports up to 256 rows, coefficients/right-hand side bounded by
`1e20`, force coordinates bounded by `1e20`, positive diagonal in
`[1e-20,1e20]`, and at most 100,000 iterations. Friction coefficients are in
`[mjMINMU,1e10]`. These are explicit candidate domains, **not** physical limits
of MuJoCo or extra diagonal clamps. A valid positive diagonal is reciprocated
as in C. The caller owns contact assembly, regularization and SPD assumptions.

`Invalid_Input` and `Numeric_Limit` preserve the entire supplied force vector.
`Converged` means C's scaled improvement test; it does not mean an exact solution
or prove global convergence. `Iteration_Limit` is a distinct outcome. Use
`Scale = 1 / (meaninertia * max(1, nv))` for C's monolithic scale.

## Verification and reproduction

The commands freeze source and the two root scalar specifications before running;
object files, binaries, proof sessions, native oracle and logs are external.
Each small proof gets a separate build directory to avoid stale diagnostics.

```sh
python3 tests/prove.py --out /var/tmp/friction-small --phase small
python3 tests/prove.py --out /var/tmp/friction-whole --phase whole
python3 tests/prove.py --out /var/tmp/friction-pgs-small --units mj-pyramidal_pgs --phase small
/var/tmp/sparkling-movement-env/bin/python tests/check.py --out /var/tmp/friction-checked
/var/tmp/sparkling-movement-env/bin/python tests/check.py --out /var/tmp/friction-release --mode release
```

Commands above are run from this candidate directory and require fresh output
directories. The default toolchain locations match this workspace; the Python
environment supplies NumPy and official MuJoCo 3.14.0. Differential contact tests
extract **native C assembled** systems; they validate this solver independently
of contact assembly. They include sliding, torsional and rolling forces,
multi-point box contact, mixed joint friction/equality/contact constraints, and
short iteration budgets. They do not establish end-to-end dynamics parity.

Tests invoke the C pyramid functions through `ctypes` with explicit `dim`. The
3.14.0 Python wrappers in `python/mujoco/functions.cc` incorrectly pass
`mu.size()` although they require `force.size() == mu.size()+1`; using those
wrappers would test one fewer force component. The production C functions are
unaffected by that wrapper discrepancy.

## Remaining integration and proof scope

Still outside this increment: elliptic cones/QCQP, no-slip postprocessing,
sparse rows/islands, friction/contact assembly from `MJ.Model`/`MJ.Data`, force
projection back to accelerations, activation/adhesion/surface-velocity assembly,
and coupling to the runtime step. Those existing effects may be present in a
caller-supplied `AR`/`b`; this module does not independently construct them.

The accepted 2026-10-02 whole-unit reports close **539 checks**, with zero
open obligations, zero warnings and complete subprogram coverage:

| Unit | Closed checks | Functional assurance scope |
|---|---:|---|
| `MJ.Friction_Kernels` | 203 | Ordered force coordinates, clipping, cost change and scalar restoration |
| `MJ.Friction_Random` | 11 | Exact modular generator transition and output |
| `MJ.Pyramidal_PGS` | 325 | Runtime safety, feasible output and atomic input/numeric rejection; local arithmetic helpers |

These are **Gold on the stated contracts and numerical domains**. The global
floating-point PGS trajectory has not been proved equivalent to C by a full
reference model. Global convergence, accuracy against ideal real arithmetic and
the complete runtime simulation remain separate claims. They are not accepted
Silver exceptions. No speed comparison with a complete C step is claimed.

Checked and release builds each pass **2,096 cases**, including 90 native C
assembled systems with **bit-identical force vectors and identical iteration
counts**. Native systems reach 44 rows; separate capacity tests reach 256 rows
and verify rejection above that limit. The last stable release was rechecked on
2026-10-02 and remains [3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0).

Proof-only snapshots and feasibility-transfer lemmas use `Ghost => Static`;
they add no release-time force scans. The public assembled-system entry still
validates input once and reports numeric-domain rejection explicitly.

The compact accepted reports, source hashes, commands and test summaries are in
[`results`](results/README.md). Larger temporary snapshots, binaries, inputs and
oracles are kept under `/var/tmp/sparkling-friction-response-20261002`.
