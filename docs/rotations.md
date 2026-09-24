# Vector rotations

`MJ.Rotations` gives fixed-size 3D vectors one rotation interface for scalar-first
quaternions and row-major 3×3 matrices. It reuses `MJ.Quaternions.Rotate`,
`MJ.Matrices.MulMatVec3` and `MJ.Matrices.MulMatTVec3`; it adds no second
implementation of their arithmetic. Every operation has a separate-result and
an explicit in-place overload.

```ada
with MJ.Rotations; use MJ.Rotations;
-- Declarations:
Q : Quaternion := [0.5, 0.5, 0.5, 0.5];
A : Matrix_3 := [[0.0, 0.0, 1.0],
                 [1.0, 0.0, 0.0],
                 [0.0, 1.0, 0.0]];
V : Vector_3 := [1.0, 2.0, 3.0];
R : Vector_3;
-- Statements:
Rotate (R, Q, V);             -- R = [3, 1, 2], V is unchanged
Rotate_Conjugate (R, Q);      -- R = [1, 2, 3]
Rotate (V, A);               -- V = [3, 1, 2]
Rotate_Transpose (V, A);     -- V = [1, 2, 3]
```

| Operation | Result | Corresponding C operations |
|---|---|---|
| `Rotate (R, Q, V)` / `Rotate (V, Q)` | Apply quaternion Q | `mju_rotVecQuat` |
| `Rotate_Conjugate` | Apply `[qw,-qx,-qy,-qz]` | `mju_negQuat` + `mju_rotVecQuat` |
| `Rotate (R, A, V)` / `Rotate (V, A)` | Apply A | `mju_mulMatVec3` |
| `Rotate_Transpose` | Apply A transpose | `mju_mulMatTVec3` |

All input components must satisfy the existing Tier0 bound `[-1e10,1e10]`.
Matrix results are Tier1; quaternion results are Tier2. The contracts specify
the exact ordered floating-point algorithm, including the quaternion kernel's
zero-vector and positive-identity branches. They do not silently normalize
quaternions, enforce orthogonality, or broaden the input domain of a subsequent
operation. Callers must reestablish its preconditions when chaining results.

Conjugation describes the inverse geometric rotation for a unit quaternion;
transpose describes the inverse for an orthogonal matrix. These are not general
quaternion or matrix inverses, nor do the contracts assert exact round trips or
norm preservation in floating point. Nonunit quaternions and nonorthogonal
matrices remain supported according to the specified C formulas. Quaternion
application and application of `To_Matrix(Q)` are not interchangeable formulas
for arbitrary nonunit Q, and even unit inputs can differ through rounding.

The separate-result forms require disjoint input/output actual parameters under
SPARK's aliasing rules. The in-place forms preserve the original three components where needed.
Identity quaternion rotation is an in-place no-op; zero vectors use the same
zero-result branch as C, before the identity branch. Conjugate application snapshots four quaternion components;
transpose application never materializes a transposed matrix. Storage is fixed,
there is no heap allocation, and all eight entry points request inlining.
Release builds erase the static ghost specification functions.
`Conjugated(Q)` is the small inline value constructor shared by the executable
path and its contract; its postcondition proves all four component relations.
The quaternion wrapper stores the three output components explicitly after
calling the shared kernel. This avoids an aggregate copy through the stack on
8-byte-aligned destinations in a contiguous vector array; the regular quaternion path writes computed components directly. Fixed input
snapshots can still appear on the stack in other paths. Arithmetic is unchanged.

## Reproduce

The reference is the pinned official MuJoCo 3.14.0 source, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, rechecked against the latest stable
[release](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0) on
2026-09-23. The harness compiles the actual upstream C sources with platform
SIMD enabled; `reference.json` verifies their normalized source/header hashes.

From the repository root with GNAT, GPRbuild, GNATprove and Python on PATH:

```sh
python3 tests/rotations/prove.py
gprbuild -P tests/rotations/checks.gpr -XROTATION_MODE=development -p -j2
python3 tests/rotations/numeric.py --mode development
gprbuild -P tests/rotations/checks.gpr -XROTATION_MODE=validation -p -j2
python3 tests/rotations/numeric.py --mode validation
gprbuild -P tests/rotations/checks.gpr -XROTATION_MODE=release -p -j2
python3 tests/rotations/numeric.py --mode release
python3 tests/rotations/measure.py --pairs 31 --ms 25
```

Benchmarking uses Linux CPU affinity, thread CPU time and wall time. Both
languages use matching release optimization, native ISA, LTO, FP contraction
disabled and no reassociation. The loop counter and memory barriers match.
Each batch contains up to 32,768 output vectors; each is visited once. All input
initialization, checksumming and I/O are outside both timers. In-place inputs
are prepared by the same C fixture before either backend runs. An untimed
eight-vector probe with distinct inputs checks every output component against
the scalar C reference before sampling. Conjugation is inside timing on both
sides. Raw alternating samples, paired
median ratios, MAD, bootstrap intervals, checksums, context switches, source
hashes and toolchain metadata are retained. Measurements apply to the recorded
hardware/build, not to complete simulator performance. Reported CPU/wall times
sum only kernel batch intervals; the context-switch count covers the complete
sample, including preparation and checksumming.

The initial diagnostic fixture reset one vector inside each timed iteration.
Its Ada whole-array copy introduced extra reloads and a roughly 15% cost in the
matrix in-place case, absent from the standalone matrix kernel. The final
fixture separates preparation from the kernel on both sides, as required by
the verification policy. It measures independent vectors, not the combined
cost of an application-specific copy followed by rotation. This is a benchmark
scope correction, not a claim that arbitrary surrounding copy code is faster.

The numerical corpus covers 6,377 inputs and 153,048 scalar comparisons per
build profile. It includes independent cyclic-rotation and asymmetric-matrix
anchors, in-place equivalence, identity and negative identity, zero vectors,
subnormals, extreme signs at the Tier0 bound, random unit/nonunit quaternions
and general matrices. Equality means exact finite numerical equality with C;
the sign bit of zero is not asserted. Differential tests do not prove universal
C equivalence. The formal checks establish contracts of the new module relative
to the existing kernel contracts, rather than accuracy against ideal arithmetic.

## Verified result

The integrated complete-unit gate passes **68 proof checks**, with **zero
unproved checks, zero warnings, and 12 entities wholly in SPARK**. No assumptions,
suppressions, skipped bodies, or new trusted project bodies were introduced.
The called `Dot_3`, `MulMatVec3`, `MulMatTVec3` and quaternion `Rotate` routines
were independently rechecked at subprogram scope (14, 43, 43 and 26 checks).
The ordinary project release build also passes for this unit and its dependency
subset. No complete-library or simulator verification is claimed.

All three numerical profiles pass the 6,377-case corpus. Release disassembly
shows **zero calls and zero FMA instructions** in the eight-path Ada benchmark
kernel, with packed-double multiplication present. Fixed input snapshots remain
in some generated branches; no heap allocation or secondary-stack helper is
executed by these paths.

On the AMD Ryzen 7 9800X3D under Linux/WSL, GNU GNAT/GCC 16.1.0 and GPRbuild
26.0.0, the final classifications are **33 faster and 31 within measurement
uncertainty**, with no reproducible slower case among the 64 combinations.
The full run used 31 alternating pairs and a 25 ms faster-side target. It
initially flagged three small differences (about 1–3%). Independent checks of
all three, using 81 pairs at 50 ms with unchanged source and binary, classified
the tiny-quaternion case as faster and both matrix cases as overlapping parity.
An additional matrix identity control also overlapped parity. Both the initial
observations and all follow-up samples are retained; no initial result is erased.

The following table uses those higher-sample checks where available. Ratios
are Ada/C; results remain specific to the recorded hardware and fixture.

| Operation | Median ratio range | Faster | Within noise |
|---|---:|---:|---:|
| Quaternion | 0.618–0.971 | 8 | 0 |
| Quaternion in place | 0.709–0.979 | 8 | 0 |
| Conjugate | 0.477–0.844 | 8 | 0 |
| Conjugate in place | 0.341–0.877 | 8 | 0 |
| Matrix | 0.996–1.006 | 0 | 8 |
| Matrix in place | 0.987–1.007 | 0 | 8 |
| Transpose | 0.986–1.005 | 1 | 7 |
| Transpose in place | 0.988–1.007 | 0 | 8 |

`tests/rotations/evidence/performance-summary.json` links each final case to
its source report. The directory also contains the full proof report and
source receipt, numerical results, disassembly, dependency checks and a hash
manifest. The benchmark runner retains incomplete runs and exits nonzero for
any flagged slower case, so follow-up decisions remain explicit.
