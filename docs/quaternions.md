# Quaternion kernel

`MJ.Quaternions` supplies the scalar-first `(w, x, y, z)` algebraic core.
`Quaternion` is a fixed array of four `MJ.Types.Real` values. Operations write
into caller-owned results; there are no heap allocations or hidden normalization.
`Vector_3` and `Matrix_3` reuse the existing kernel types. Matrix output is row-major.

```ada
with MJ.Quaternions; use MJ.Quaternions;
-- In a subprogram:
Q : Quaternion := Identity;
Delta : Quaternion := [0.5, 0.5, 0.5, 0.5];
Length : Nonnegative_Real;
V : Vector_3 := [1.0, 2.0, 3.0];
Rotated : Vector_3;
Rotation : Matrix_3;
-- In the statement sequence:
Multiply (Q, Delta);
Normalize (Q, Length);
Rotate (Rotated, Q, V);
To_Matrix (Rotation, Q);
```

## Operations and contracts

| Operation | Functional property | MuJoCo reference |
|---|---|---|
| `Set_Identity` | Exactly `(1,0,0,0)` | `mju_unit4` |
| `Conjugate`, both overloads | Preserve `w`, negate `x,y,z` | `mju_negQuat` |
| `Multiply`, both overloads, and value-returning `Product` | Ordered floating-point Hamilton product | `mju_mulQuat` |
| `Norm` | Ordered four-square reduction composed with runtime square root | Norm expression inside `mju_normalize4` |
| `Normalize` | Original length; tiny-norm identity fallback; near-unit no-op; otherwise component scaling | `mju_normalize4` |
| `Rotate` | Exact ordered reference expression, including zero-vector and positive-identity shortcuts | `mju_rotVecQuat` |
| `To_Matrix` | Nine ordered reference expressions and positive-identity shortcut | `mju_quat2Mat` |

Conjugation equals the inverse only for unit quaternions. `q` and `-q` encode the
same ideal rotation, but their floating-point branches need not coincide.
Multiplication and conversion require components in the existing Tier0 domain
`[-1e10,1e10]`; rotation also requires a Tier0 vector. `Norm` and `Normalize`
accept Tier1 inputs (`[-1e30,1e30]`) so products can be normalized by the pose
kernel. Multiplication/conversion outputs are Tier1; rotation outputs are Tier2.
Normalization retains a Tier1 output guarantee for Tier0 inputs and has a
conservative Tier2 guarantee over the extended domain.
Identity and conjugation have no Tier0 precondition. Inputs are finite values
under the project's floating-point model; NaNs and infinities are unsupported.

No unit-length precondition is imposed just to simplify proofs. Conversion uses
MuJoCo's square-and-product formula, including its behavior for nonunit inputs.
It does not substitute the algebraically equivalent `1 - 2*(...)` formula.

Normalization computes the four independent squares with SIMD and then adds
those squares in the original scalar order. Exact squared lengths zero and one
use the standard runtime identities `Sqrt(0)=0` and `Sqrt(1)=1`. The remaining
branches retain the reference algorithm. An immutable four-scalar snapshot keeps
original components available for scaling. The squared-sum helper proves that
its explicit `abs` is numerically redundant; that expression lets the compiler
remove a redundant negative-argument check after SIMD extraction.
Normalization preserves inputs when `abs(length-1) <= 1e-15` and falls back to
identity when `length < 1e-15`, exactly as the reference branches specify.

The in-place overload `Multiply (Q, Right)` means `Q := Q * Right`. `Right` must
be a distinct object under SPARK's aliasing rules. Separate-result operations
likewise require legal, nonoverlapping actual parameters. Conjugation has an
explicit in-place overload. No blanket C-style output/input alias guarantee is
made for the other procedures.

`Model` contains static ghost specification functions. The Gold target is the
behavior of the specified floating-point algorithm: bounds, initialization,
branches and exact component relations. Differential tests support agreement
with the pinned C source; they do not prove universal equivalence to C.

`MJ.Quaternion_Math` instantiates the unmodified standard
`Ada.Numerics.Generic_Elementary_Functions` for `Real`. Its standard `Sqrt`
contract is the same existing runtime trust boundary used by vector norms.
Making that instance local lets release LTO see and inline its body. No custom
square-root approximation, imported replacement, or project assumption is used.
The contracts do not claim exact unit length, exact orthogonality, or a numerical
error bound against real arithmetic. Those are additional accuracy properties,
not consequences of the algorithmic contracts or the runtime's limited `Sqrt`
specification.

## Scope

This increment contains only quaternion algebra and its vector/matrix outputs.
Axis-angle, matrix-to-quaternion conversion, interpolation, angular differences,
Euler angles and time integration are outside this increment. There is no new
6D spatial algebra or simulator integration. Existing experimental smooth code
has not been migrated to this API.

## Reproduce

From the project root, with GNAT/GPRbuild/GNATprove and Python 3 on PATH:

```sh
python3 tests/quaternions/prove.py
gprbuild -P tests/quaternions/checks.gpr -XQUATERNION_MODE=development -p -j2
python3 tests/quaternions/numeric.py --mode development
gprbuild -P tests/quaternions/checks.gpr -XQUATERNION_MODE=validation -p -j2
python3 tests/quaternions/numeric.py --mode validation
gprbuild -P tests/quaternions/checks.gpr -XQUATERNION_MODE=release -p -j2
python3 tests/quaternions/numeric.py --mode release
python3 tests/quaternions/measure.py
```

The C harness compiles the repository's actual `mujoco/src/engine` sources, with
normal platform SIMD enabled. The recorded baseline is MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Check the checkout before reusing a
receipt. The benchmark runner uses Linux CPU affinity, CPU-thread time and wall
time; the kernel itself contains no Linux-specific code.

Both languages use matching release flags, native ISA and LTO. FP contraction
is disabled; reassociation and fast-math are not enabled. Inputs and I/O are
outside timed regions. Memory barriers prevent hoisting and dead-code removal.
Both benchmark loops use a signed C-width counter starting at zero and testing
`counter < repetitions`. In-place and normalization cases include the same input
reset in both languages.
`Norm` is compared with the reference's norm expression because MuJoCo has no
standalone `norm4` export. Other cases call the actual upstream functions.

The runner alternates C/Ada samples and records all raw timings, involuntary
switches, checksums, medians, MAD and a bootstrap confidence interval for the
paired Ada/C ratio. Performance is hardware- and build-specific; a reproducible
slow case remains open and is not offset by faster cases. Run measurements with
other proofs, builds and benchmarks stopped. This suite is separate from the
existing test runner so it does not change other kernel work.

## Historical formal and numerical receipt

The following receipts describe the original quaternion increment. The widened
normalization domain and value-returning `Product` introduced with the pose
kernel have fresh proof and regression evidence documented in [poses.md](poses.md).
The earlier evidence is retained unchanged; it is not a fresh receipt for today's source tree.

The final complete-unit invocation proves **413 checks**, with **zero unproved
checks** and **25 reported entities wholly in SPARK**. The repository coverage
and freshness gate passes. No assumptions, suppressions, skipped bodies or new
trusted project bodies were introduced. Six warnings concern the existing
standard `Sqrt` model boundary described above. One warning states that
GNATprove ignores `Loop_Optimize`; it verifies the sequential independent-square
loop, while the compiler uses the directive for vectorization. All seven
warnings are retained. The loop-unrolling message is informational.

The deterministic corpus contains **4,023 inputs**, including independently
checked Hamilton-product and half-turn anchors, threshold neighbors, signed
zeros, subnormals, all sign combinations at the Tier0 bound, and random unit and
nonunit inputs. All **152,874 scalar comparisons per profile** agree exactly as
finite numerical values with C in development, validation and release builds.
This comparison does not assert equality of the sign bit of zero.

Receipts and raw reports are in `tests/quaternions/evidence/`. The release
code-generation audit finds **no calls or FMA instructions** in the timed Ada
kernel covering all nine API paths; native square-root and packed-double
multiply instructions are present. The ordinary project release build also
passes for this dependency subset. These results do not establish end-to-end
simulator performance or complete verification of unrelated project units.

## Historical performance receipt

On the AMD Ryzen 7 9800X3D under Linux/WSL, GNU/FSF GNAT and GCC 16.1.0,
with native release optimizations and normal C SIMD, the final integrated run
covers **72 operation/branch combinations**, each with **31 alternating pairs**
and a 25 ms sample target. **No measured case is slower by the runner's paired
95% bootstrap criterion.** This is a measurement on this target, not a universal
performance guarantee. Medians and raw dispersion remain available for review.

The table gives the range of median Ada/C time ratios over the eight patterns;
a ratio below one favors Ada. The last two columns count cases classified as
faster and as overlapping parity within measurement uncertainty.

| Operation | Ada/C median range | Faster | Within noise |
|---|---:|---:|---:|
| Identity | 0.990–1.008 | 0 | 8 |
| Conjugate | 0.965–0.976 | 8 | 0 |
| Conjugate in place | 0.472–0.480 | 8 | 0 |
| Multiply | 0.985–0.998 | 6 | 2 |
| Multiply in place | 0.160–0.162 | 8 | 0 |
| Norm (reference expression) | 0.584–1.007 | 2 | 6 |
| Normalize | 0.357–0.997 | 7 | 1 |
| Rotate vector | 0.760–0.919 | 8 | 0 |
| To matrix | 0.896–0.988 | 8 | 0 |

Patterns are a regular unit quaternion, positive identity, zero quaternion,
negative identity, a nonunit quaternion, tiny components, Tier0 boundary values,
and a zero vector. The last pattern changes the vector only for rotation; other
operations provide an additional repeat on the regular unit input. The large
in-place gains include the same reset copy in both fixtures and reflect the
supported SPARK aliasing contract; they are not an end-to-end simulator speedup.

See `tests/quaternions/evidence/performance.json` for every sample, paired
confidence interval, MAD, source/binary hashes, compiler information and CPU
metadata. The measured binary has no calls in the Ada kernel, so neither ghost
models nor secondary-stack helpers are executed in those paths.
