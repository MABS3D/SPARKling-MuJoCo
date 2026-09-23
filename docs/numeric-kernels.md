# Dense vector kernels

`MJ.BLAS` implements all dense vector operations in MuJoCo 3.14.0
`engine_util_blas.c`, plus `Cross3` from `engine_util_spatial.c` and a standalone
`Norm4`. There are 35 vector kernels (31 added after the four-kernel foundation),
plus the scalar helpers `Scaled_Add` and `Det2`.
Dense matrix operations are documented in [matrix-kernels.md](matrix-kernels.md).
Quaternion rotations, six-dimensional spatial algebra, and indexed/sparse
variants remain separate milestones.

The current reference migration is documented in [mujoco-3.14-alignment.md](mujoco-3.14-alignment.md). Historical proof and test totals below retain their original scope.

## Functional contracts (Gold target)

| Kernel | Proved functional property |
|---|---|
| `Zero3`, `Zero4`, `Unit4` | Exact constant vector. |
| `Copy3`, `Copy4` | Every output component equals its input. |
| `Equal3` | Every absolute component difference is strictly below `Min_Val`. |
| `Add3`, `Sub3`, `Scl3`, `AddScl3` | Exact component expressions and Tier1 output bounds. |
| `AddTo3`, `SubFrom3`, `AddToScl3` | Exact component update relative to the old vector and Tier1 bounds. |
| `Scaled_Add`, `Det2` | Exact scalar scaled addition / 2x2 determinant and Tier1 bounds. |
| `Dot3`, `Cross3` | Exact parenthesized floating-point expressions and output bounds. |
| `Norm3`, `Norm4` | Standard runtime square root of the specified left-associated squared sum. |
| `Dist3` | `Norm3(Sub3(A, B))`, including differences outside Tier0. |
| `Normalize3` | Original length, exact tiny-norm fallback, otherwise multiplication by the reciprocal length. |
| `Normalize4` | The same, plus exact preservation when `abs(length - 1) <= Min_Val`. |
| `Zero`, `Fill`, `Copy` | Every output component equals the requested value/input; bounds are preserved. |
| `Scl`, `Add`, `Sub`, `AddScl` | Exact component expressions and Tier1 bounds. |
| `AddTo`, `SubFrom`, `AddToScl` | Exact updates relative to old values and Tier1 bounds. |
| `Sum`, `L1` | Equality to the ordered floating-point prefix recurrence (ordinary/absolute terms). |
| `Dot` | Equality to the four-lane recurrence, lane combination, and remainder used by MuJoCo. |
| `Norm` | Runtime square root of the specified `Dot(A, A)` result. |
| `Normalize` | Original generic norm, fallback at the actual first index, or component scaling. |

The historical complete-unit verification against the 3.12 baseline on 2026-09-23 passes **749 checks** (607 in
`MJ.BLAS`, 142 in `MJ.Vector_Models`), with **zero unproved obligations** and
29 reviewed warnings. This includes helper contracts, recursive-model bodies,
unfolding lemmas and termination. The evidence has fresh complete-unit invocation
receipts over identical source hashes; partial diagnostic runs are not certificates.

The 29 warning entries are: 21 `imprecise-call` occurrences at six `Sqrt` sites,
four `contracts-recursive`, and four `numeric-variant` occurrences for the two
recursive ghost functions (some warnings are repeated across reports/contexts).
The square-root warning is the documented runtime accuracy boundary below.
The recursion warnings describe facts that GNATprove may withhold; proved
variants and unfolding lemmas close the functional obligations. They do not
represent skipped or assumed proofs. None of these warnings is suppressed.

`MJ.Vector_Models` defines the reductions with decreasing-count recursive
functions. `Model_Add` isolates the rounded addition bound; its body is proved,
not assumed. `Unfold_Lane` and `Unfold_Dot` expose definitions through
separately proved null-body lemmas. Loop invariants connect the executable
accumulators to the models. `Dot` is composed from the lane update, block loop,
remainder, and scalar-combination helpers; each has its own proved contract.
`Ghost => Static`, static postconditions, and static loop invariants keep the
recursive specification out of executables, including assertion-enabled builds.
They remain proof obligations in GNATprove. See the
[SPARK assertion-level documentation](https://docs.adacore.com/spark2014-docs/html/ug/en/source/specification_features.html#assertion-levels).

The scalar helpers for scaled addition, determinants, reciprocal length,
component scaling and accumulation
have independently proved arithmetic contracts. No `Assume`, suppressed proof,
new application trusted body, or replacement of a proof with a C test is used.
Existing reviewed warnings and deallocator handling are unchanged.

The four generic out-of-place arithmetic loops use `Relaxed_Initialization`
only on their output parameter. Each invariant proves the processed prefix is
initialized, and each postcondition proves the entire output is initialized
before reading its values. Initialization is therefore proved explicitly, without
an extra zeroing pass or a suppression. This follows the
[SPARK array-initialization pattern](https://docs.adacore.com/spark2014-docs/html/ug/en/source/loop.html).

## Domains and array semantics

- Arithmetic input components and scale factors use Tier0 (`[-1e10, 1e10]`).
  Output components and scalar reductions stay within Tier1 (`[-1e30, 1e30]`).
- `Norm3` and `Norm4` accept Tier1 components, permitting norms of differences.
  Norm results are nonnegative `Real`; no upper bound on `Sqrt` beyond its
  runtime contract is invented.
- Generic reductions accept lengths through `Max_Size = 2**27 - 1`.
  Their count-dependent bounds leave room for every rounded addition.
- Generic arrays may start at any nonnegative index, including an interval
  ending at `Natural'Last`. Paired arrays and destinations have identical
  bounds. Shape preconditions on `out` arrays read attributes, not values.
- Empty arrays are valid for zero/fill/copy/arithmetic/reductions; empty
  reductions return zero. `Normalize` requires at least one component, since
  MuJoCo writes its fallback to the first element.
- `Copy` and `Fill` impose no Tier0 restriction. Arithmetic calls still require
  valid finite Ada floating-point values and the stated numeric preconditions.
- In-place kernels preserve their array bounds. SPARK's aliasing rules apply;
  callers use the explicit in-place operation rather than overlapping output
  and input arguments of an out-of-place operation.

For a tiny length (`length < 1e-15`), normalization returns `[1, 0, ...]`, retaining
and returning the original computed length, which may itself underflow to zero.
The threshold is strict. Only the four-component variant has the near-unit
shortcut. General `Dot` does **not** use a sequential real or floating-point sum:
its four independent accumulators combine as `(r0 + r2) + (r1 + r3)` and then add
the remaining one, two, or three products with the C association.

## Mathematical and runtime boundary

Gold here concerns the specified floating-point algorithm. It does not assert
that a rounded dot product equals the ideal real dot product. Even a correct
normalization need not have an exactly unit Euclidean norm in binary64.

`Ada.Numerics.Long_Elementary_Functions.Sqrt` uses the supplied Ada runtime
contract: nonnegative input, nonnegative result, exact zero/one special cases,
and positivity for inputs at least the smallest positive machine value. The
runtime implementation is not proved by this project. Its contract has no
quantitative error bound or equation tying `result*result` to the input.
Consequently, the norm/normalization composition and branches are verified,
but a universal forward-error bound and an approximate-unit-norm theorem are
not claimed. In particular, normalization currently promises Tier1 output and
the exact scaling relation, not a Tier0 or unit-norm postcondition. Establishing
stronger norm properties requires a sound accuracy model of the actual
square-root implementation plus a rounding/underflow analysis. These are separate
numerical-analysis obligations, not Silver substitutes for unfinished functional
proofs and not inherently open mathematical research.

The arithmetic model assumes binary64, round-to-nearest-even, and gradual
underflow. Floating-point contraction is disabled with `-ffp-contract=off` in
compilation and LTO linking, so FMA cannot silently change a proved recurrence.
See [SPARK floating-point semantics](https://docs.adacore.com/spark2014-docs/html/ug/en/appendix/semantics_of_floating_point_operations.html).
The validated target is x86-64 Linux/WSL with its default SSE arithmetic; a new
target must preserve the same arithmetic configuration. NaN/infinity are not
valid inputs to these bounded kernels.

## Differential and regression checks

`python tools/compare_vectors.py --mode validation` compiles an Ada probe and
links the actual pinned C sources. `tests/run.py` runs it in addition to the
original four-kernel comparison. Use `--alire` to resolve the compilers through
Alire; `SPARKLING_BUILD_ROOT` isolates artifacts.

`tools/blas-reference.json` records the MuJoCo commit and LF-normalized hashes
of every project source/header in the C probes' transitive dependency set.
The harness rejects a changed reference, stale/missing executables, incomplete
output, and non-finite results. `Norm4` is compared to the original length
returned by C `mju_normalize4`; C has no standalone `mju_norm4`.

The new deterministic suite contains 1,541 cases and 721,473 scalar comparisons
(seed 20260923), covering lengths 0 through 257, all four dot-product remainder
sizes, zeros, signs, Tier0 extremes, subnormal inputs, cancellation, threshold
neighbors, the four-component no-op, and shifted/extreme array bounds. The
original suite retains 2,102 cases and 21,020 comparisons. Ada regression tests
also include a 4,096-component reduction and a case distinguishing the four-lane
sum from a naive sequential implementation.

Zero, fill, copy, equality, fallback outputs and the four-component no-op must
match exactly (without requiring a particular sign for zero). Arithmetic
comparisons allow `k * binary64_epsilon * scale + 1e-300`: `k=8` for component
operations, `k=16*(n+1)` for generic reductions/norms/normalization, and `k=64/80`
for fixed-size norm/normalization. For sums the scale is the sum of absolute
terms, for products it is the corresponding sum of product magnitudes, and for
norm/normalized outputs it is the magnitude of the C result. These are test
acceptance tolerances, not formally established universal error bounds.
Tests deliberately corrupt results, branches, and output lengths to exercise
the comparison gate. Differential results do not establish universal equivalence
to every C optimization/SIMD configuration.
