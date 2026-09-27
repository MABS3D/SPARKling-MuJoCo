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
provide independently checkable contracts for composition. Hot kernels now
read the original matrix storage directly. Scalar products, four-lane blocks,
tails, row updates and Gram mirroring have separate proved contracts. Ghost
prefix and unfolding helpers connect those updates to the original ordered
recurrences without constructing runtime row/column copies.
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

The deterministic full-operation corpus (seed 20260924) has 535 cases and
544,872 output comparisons. A separate transpose-only corpus adds 40 cases and
151,125 comparisons across the 64/65 dispatch boundary and up to dimension 128,
including distinct cell values to detect wrong permutations. It covers fixed 3x3, rectangular and empty shapes, dimensions around
four-lane boundaries, Tier0 endpoints, subnormals, zero skips, cancellation,
negative diagonal weights, both triangle modes, and repeated row selections.
The Ada tests add explicit small-integer results, selected-row frame checks,
maximum index-list bounds, and output values above Tier1. Python gate tests
reject incorrect, incomplete, and nonfinite outputs.

The hot matrix operations no longer materialize row/column vectors for each
reduction. The public projection/component helpers remain available. Symmetry
is computed once per pair; transposition, symmetrization and row-dot products
avoid redundant output clearing. Initialization is proved with prefix
invariants. `Transpose`, `Symmetrize` and `MulMatMatT` explicitly expose
`Relaxed_Initialization => R` together with a proved `R'Initialized` postcondition;
their outputs are fully initialized on return and their functional contracts
and input domains are preserved.

The preceding optimization measured all 20 benchmark variants (17 kernels with
the Gram modes distinguished)
measured against the normal C SIMD path, including `-DmjUSEPLATFORMSIMD`, on
228 size/shape/zero-pattern combinations. Each uses 11 alternating C/Ada sample
pairs, dispersion and bootstrap intervals, with equal release/FP flags.
The transposed product now traverses source rows first. Gram uses the same
source-first traversal and skips a zero diagonal weight before visiting the
output triangle. Each cell retains ascending source-index accumulation and
the original multiplication association. Proved sweep/zero-weight contracts
compose the cell proofs; the unused former Gram-row helper was removed.
Inlining permits specialization of constant weighting/upper-triangle modes.
The final benchmark records gains on representative medium/large cases,
but reproducible slowdowns remain, including small and zero-rich cases. **Performance acceptance remains pending.** This increment improves
the implementation and preserves Gold; it does not complete the performance
requirement or accept a permanent slowdown.

## Verification status

The five complete numeric units pass **3,504 checks, zero unproved obligations
and 71 reviewed warnings** on the frozen source snapshot measured below,
with MuJoCo 3.14.0 as the C reference. The three
matrix units contribute 2,755 checks. Fresh `.spark` reports and original
invocation receipts pass the source-hash and complete-unit gate. Diagnostics
started at scalar and single-cell subprograms before composing complete units.

The six additional warnings are the new transpose loop hints ignored by
GNATprove; existing warnings remain. The warning total includes messages stating that GNATprove ignores
code-generation hints (`Machine_Attribute`, `Loop_Optimize`). The scalar lane
recurrences, indexing, initialization and floating-point order are proved;
release differential tests also check the emitted code. Remaining warnings
concern conservative array initialization, recursive contract/variant context,
and the unchanged vector `Sqrt` boundary. No warning is suppressed. No `Assume`,
new application trusted body or deallocator change was introduced. The proof
guard remains 4,000 MB per process group.

Development, validation and release each pass **1,097 Ada assertions** in ten
executables and **72 Python tests**. The matrix differential probes were then
extended, rebuilt and rerun in each profile; the Python tests were repeated.
Combined coverage is **1,438,490 C comparisons** over 4,218 cases per profile,
including the separate transpose-only cases. The release matrix probe also
passes 535 full-operation cases / 544,872 comparisons plus 40 transpose-only
cases / 151,125 comparisons against the actual native SIMD C reference.
Signed-zero bits and NaN payloads are not compared. Inspection of the measured benchmark wrappers and their resolved direct
targets finds no FMA instructions or executable ghost-model functions. Evidence records compiler versions, target, flags and source hashes.

The target is x86-64 Linux/WSL with GNAT/GNATprove 16.1.0 and GPRbuild 26.0.0,
binary64, round-to-nearest-even and gradual underflow. These selected numeric
unit proofs do not certify the entire foundation migration or experimental
physics pipeline. Quantitative error/conditioning/PSD claims remain outside
the functional floating-point specification.

The earlier 1,628-check matrix snapshot remains a separate historical result.
Its SIMD compatibility evidence was corrected on 2026-09-23 by enabling
`mjUSEPLATFORMSIMD`; the current release and timing runs use that flag explicitly.

## Performance-first increment (2026-09-23)

New kernel expansion remains blocked by reproducible performance regressions.
`MulMatVec3` and `MulMatTVec3` now take an output parameter, consistent with the
generic matrix API: use `MulMatVec3 (R, A, V)` instead of `R := MulMatVec3 (A, V)`.
Both routines compute all three scalar results before writing them; SPARK
requires distinct input/output objects for this procedure API. Updating the
input vector itself therefore requires a separate temporary result. The benchmark
uses distinct input/output buffers. Project callers and C probes
use the new interface. The previous returning functions have been removed.

Four-lane reductions initialize the first SIMD block directly, then update the
same four lanes in source order. The block loop is not vectorized across blocks;
row-pair reductions also avoid unrolling that loop. Empty/short inputs and tails
retain the specified evaluation order. Independent Gold lemmas prove the
zero-tail and lane-combination identities. Row projections stay inside ghost
lemma bodies: an assertion with a conditional row projection was observed to
leave secondary-stack bookkeeping in release code and was replaced without
weakening the property. The final timed caller has no such calls. Gram mirroring
now writes the upper triangle by rows, preserving every lower-triangle value.

The benchmark gives square-only bilinear and symmetrize operands a shared
dimension, matching the information provided to C. Both the preceding Gold
3,121 version and the new version were remeasured with this harness. The previous
228-case measurements used independent, equal dimensions and remain historical
evidence; changes between those protocols are not attributed to kernel code.

Previous measurement: 72 faster, 45 overlapping parity, 111 slower out of 228 cases. Performance acceptance remains open. See `matrix-performance.md`.

## Focused slow-case optimization (2026-09-23)


The two independent column-update loops now use `Loop_Optimize (Ivdep, Vector)`.
Their exact output, bounds and frame contracts remain proved. The source-index
accumulation order and the public API are unchanged. SPARK non-overlap rules and
distinct per-iteration destinations justify Ivdep; GNATprove ignores the hint
itself. See the detailed justification in `proof-justifications.md`.

The complete numerical proof still passes 3,201 checks with zero unproved
checks. Latest 228-case result: 78 faster, 50 overlapping
parity, 100 slower. Performance acceptance remains open; see
`matrix-performance.md` and the accompanying raw evidence.

## Short-row matrix-transpose product (2026-09-24, preceding snapshot)

`MulMatMatT` returns immediately for empty outputs and specializes widths
0 through 4 before the output loops,
preserving the exact ordered dot contract. `MulMatVec` and `MulVecMatVec`
retain their previous implementation. The complete
benchmark has 82 faster, 42 inconclusive, and
104 slower cases. All reproducible slowdowns remain open.
The corpus appends 80 short rectangular/empty cases without changing its
historical cases. The new traversal composes separately proved short-dot
contracts; its one new Hide_Info is documented in the justification ledger.
See [the current report](matrix-performance.md) for the complete proof scope,
measurements and confirmation results.

## Transpose dispatch (2026-09-24)

Transpose returns immediately for an empty axis. One through five input rows
have separate helpers with explicit component copies. Six through fifteen
rows copy pairs and then an odd final row. Square matrices with dimensions
16 and 64 use a vector-hinted version of the original loop; other shapes
use the original general core. These thresholds select code shape for the
measured native build and do not narrow the supported domain.

All paths prove full initialization and the same exact per-component transpose
relation. There is no arithmetic reassociation, added assumption or suppression.
The executable public component postcondition is retained; its additional
static initialization postcondition permits avoiding redundant clearing.
The [reproducible performance fixture](../tests/matrix_performance/README.md) builds
current and frozen baseline Ada separately, each with normal SIMD C.
A shared-executable experiment is retained as historical context; its LTO
inlining differs from the one-version builds.
See [the current report](matrix-performance.md) for final measurements and
remaining performance work.
