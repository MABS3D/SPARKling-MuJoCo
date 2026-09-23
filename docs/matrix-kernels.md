# Dense matrix kernels

`MJ.Matrices` covers the 18 matrix entry points of MuJoCo 3.14.0
`engine_util_blas.c` through 17 public kernels: `SqrMatTD` represents both the
public full Gram routine and the internal optional-upper-triangle routine.
The fixed-size kernels use `MJ.Matrix_Types.Matrix_3`; generic kernels use
`Matrix`, a row-major two-dimensional Ada array. Both axes start at zero.
`Row` and `Column` return zero-based vectors for composition with `MJ.BLAS`.
This is an Ada API, not a flat-pointer ABI replacement for MuJoCo.

## Functional contracts

| Kernel | Specified floating-point behavior |
|---|---|
| `Copy9` | Every component is copied exactly. |
| `MulMatVec3`, `MulMatTVec3` | Each row/column is combined with the vector using the explicit three-term, left-associated dot expression. |
| `MulMatMat3`, `MulMatTMat3`, `MulMatMatT3` | All nine component expressions specify the respective transpose orientation. |
| `MulMatVec` | One MuJoCo four-lane `Dot_Value` per row. |
| `MulMatTVec` | Sequential updates in row order, skipping zero vector coefficients. |
| `MulVecMatVec` | Sequential sum of `U(i) * Dot_Value(Row(A,i), V)`; no zero-coefficient skip. |
| `Transpose` | Output `(i,j)` equals input `(j,i)`. |
| `Symmetrize` | Preserve the diagonal; each off-diagonal pair uses `0.5 * (lower + upper)` in that order. |
| `Eye` | Ones on the diagonal and zeros elsewhere. |
| `CopyRows` | Copy to the same selected row positions and preserve every unselected component. Duplicate indices are accepted. |
| `MulMatMat` | Sequential inner-dimension accumulation, skipping zero left coefficients. |
| `MulMatTMat` | Sequential shared-row accumulation, skipping zero left coefficients. |
| `MulMatMatT` | One MuJoCo four-lane dot per pair of rows. |
| `SqrMatTD` | Sequential lower-triangle recurrence, with optional weights and zero skips; the full result uses the same lower-triangle value in both symmetric positions. With `Upper=False`, the upper triangle is exactly zero. |

`Dot_3` isolates the six scalar inputs of the fixed dot expression.
`Product3_Component` isolates the row/column selection for all three fixed
matrix products, avoiding nine expanded floating-point expressions per proof.
`Mean_2`, `Symmetric_Component`, and the generic product/Gram component
helpers do the same for averages, dimension mapping, and triangle selection.
`Sequential_Dot`, `Bilinear_Dot`, `Weighted_Dot`, `Gram_Value`, and `Row_Dots`
provide independently checkable contracts for composition. The private
`MatT_Row` and `Fill_MatT_Row` separate four-lane row calculation from matrix
updates; the outer proof preserves every previously completed row.
`MJ.Matrix_Models`
contains the recursive ghost recurrences and their unfolding lemmas. Lemma
bodies are proved, not assumed; `Ghost => Static` removes the recursive models
from all executables, including builds with runtime assertions.

Sequential reductions are not interchangeable with the four-lane reduction.
For products of `[1e10, 1, -1e10, 1]` and `[1e10, 1, 1e10, 1]`, the sequential
result is 1 and the four-lane result is 2. The kernels retain the appropriate
MuJoCo association, zero skips, and weighted multiplication order
`right * (left * weight)`. Independent result components may be traversed in a
different order, without changing the recurrence within a component.

## Input domains and bounds

- Generic input matrices satisfy `Valid`: zero-based axes, each dimension at
  most `Max_Size`, and at most `Max_Size` stored input components. Dimension
  products are checked with division to avoid integer overflow.
- Output shapes are stated separately in preconditions, without reading an
  uninitialized `out` value. Every output component is initialized.
- Arithmetic inputs use Tier0, including diagonal weights. Zero, positive, and
  negative weights are accepted. Copy and transpose impose no Tier0 restriction.
- Ordinary products have Tier1 scalar results; symmetrization stays in Tier0.
  Scalar and component helpers isolate these bounds from matrix traversal.
- Bilinear forms and weighted Gram results use Tier2. Intermediate triple
  products and their sums can exceed Tier1 even for valid Tier0 inputs.
- Generic vectors are zero-based and match their matrix dimension. The row
  index list for `CopyRows` may have arbitrary bounds, including a final index
  at `Natural'Last`, and may be empty or contain repetitions.
- Zero rows, zero columns, and zero inner dimensions are supported. Empty
  reductions return zero. An empty diagonal means the unweighted Gram variant.
- SPARK aliasing rules apply: input and output objects of out-of-place matrix
  procedures must not overlap. `CopyRows` changes its destination in place,
  but its source is a distinct object.

The count-dependent rounding allowances are `2**68` per ordinary product and
`2**136` per wide term. They bound the actual rounded accumulator and establish
safety; they are not error estimates relative to an ideal real sum.

Gold here describes the functional floating-point algorithm and its frame
properties. It does not assert exact real-algebra identities, positive
semidefiniteness of a rounded Gram matrix, conditioning, or forward/backward
error bounds. None of the matrix algorithms requires an elementary-function
model such as `Sqrt`; no matrix functional property is deliberately left at
Silver. Quantitative numerical analysis is a separate specification layer.

## Differential and regression tests

`python tools/compare_matrices.py --mode validation` compiles and invokes the
actual pinned MuJoCo C source, with `-ffp-contract=off`. Existing reference
hash checks cover its transitive source/header dependencies. Every output must
be finite and numerically equal to the C result: this suite uses no tolerance.
This compares floating-point values, not NaN payloads or the sign bit of zero,
and is empirical evidence, not a proof of universal C equivalence.

The deterministic corpus (seed 20260924) has 371 cases and 286,012 output
comparisons. It covers fixed 3x3, rectangular and empty shapes, dimensions around
four-lane boundaries, Tier0 endpoints, subnormals, zero skips, cancellation,
negative diagonal weights, both triangle modes, and repeated row selections.
The Ada tests add explicit small-integer results, selected-row frame checks,
maximum index-list bounds, and output values above Tier1. Python gate tests
reject incorrect, incomplete, and nonfinite outputs.

The implementation currently materializes row/column vectors for its scalar
reductions. This keeps the proof boundary small but adds temporary storage and
copying compared with the C pointer implementation; no performance claim or
benchmark is attached to this increment. The type and contracts allow later
optimization while retaining the stated component recurrences.

The shared performance policy requires parity with the corresponding C kernels.
That acceptance gate remains pending: no performance measurements are included
in this functional-proof increment, and temporary row/column copies remain an
optimization concern.

## Verification status

The three new complete units (`MJ.Matrix_Types`, `MJ.Matrix_Models`, and
`MJ.Matrices`) pass **879 checks, zero unproved obligations, and 25
reviewed warnings**. The dense numeric integration gate also refreshes
`MJ.BLAS` and `MJ.Vector_Models`: **1628 checks and 54 reviewed warnings
across five complete units**, all over the same frozen core source hashes.
The new warning occurrences concern conservative array-initialization analysis
and recursive contract/variant context. Full zero aggregates initialize the
destinations before traversal; initialization, component behavior, recursive
bodies, termination and unfolding lemmas are all proved. The existing vector Sqrt
accuracy boundary is unchanged. No assumptions, suppressions, new application
trusted bodies or deallocator changes were introduced.

Every kernel has proved functional behavior in addition to runtime safety.
Diagnostic runs selected the smallest scalar/component subprogram first;
final evidence uses fresh complete-unit `.spark` reports and original
`.invocation.json` receipts checked by `tools/prove_report.py`.
The guard remained at 4,000 MB per process group.

All three profiles pass 1085 Ada assertions (10 executables),
72 Python tests and 1,028,505 C scalar comparisons
(4,014 cases) each. The new matrix suite contributes 33 Ada assertions,
eight Python gate tests, 371 cases and 286,012 comparisons. The target checked
is x86-64 Linux/WSL, GNAT/GNATprove 16.1.0, GPRbuild 26.0.0, binary64 with
round-to-nearest-even and gradual underflow. Release object and linked probe
inspection found no FMA instructions or executable ghost model functions.
Windows/Alire and unchanged foundation proof units are outside this refresh.

The final five-unit integration evidence is produced from an isolated 3.14.0
snapshot, so concurrent migration edits cannot invalidate a running proof.
The preceding coherent 3.12.0 snapshot also passed the full selected proof gate
and all three runtime profiles. These numeric-unit results do not certify the
foundation migration as a whole. A separate matrix-only check against 3.14.0 C
passes both scalar and native SIMD variants (371 cases, 286,012 exact scalar
comparisons each), with contraction disabled.
