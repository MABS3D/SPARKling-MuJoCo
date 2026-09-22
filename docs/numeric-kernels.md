# First numeric kernels

`MJ.BLAS` implements the first four operations from MuJoCo 3.12.0
`engine_util_blas.c`:

| SPARK | C reference | Contract |
|---|---|---|
| `Add3` | `mju_add3` | Component-wise sum, inputs in Tier0, output in Tier1. |
| `Sub3` | `mju_sub3` | Component-wise difference, inputs in Tier0, output in Tier1. |
| `Scl3` | `mju_scl3` | Component-wise scaling, vector and scale in Tier0, output in Tier1. |
| `Dot3` | `mju_dot3` | Three products added left to right, inputs in Tier0, result in Tier1. |

Vectors use the existing `Real_Array` with bounds `0 .. 2`. The functions have
no global state or allocation. The specifications include the arithmetic
relations as well as the output bounds. Calls require finite, bounded inputs;
the future public state setters remain responsible for validating external input.

## Differential checks

`python tools/compare_blas.py --mode validation` builds an Ada probe and a C
probe linked directly to the reference source. Use `--alire` when resolving the
compilers through Alire. `SPARKLING_BUILD_ROOT` selects the artifact directory.

`tools/blas-reference.json` records the pinned commit and hashes of the C source
and relevant headers. The comparison rejects source changes; only CRLF/LF
normalization is allowed. It does not implement a second Python version of the
algorithms.

There are 2,102 input cases and 21,020 scalar comparisons: 100 combinations of
edge values, two directed cases, and 2,000 reproducible random cases with seed
20260922. Cases include zero, signed zero, Tier0 extrema, tiny values, orthogonal
vectors and cancellation. Every input vector and scale stays within Tier0.

The absolute tolerance for each result is `8 * binary64_epsilon * scale + 1e-300`.
For sums/differences, scale is the sum of the input magnitudes; for scaling it
is the product magnitude; for the dot product it is the sum of the three product
magnitudes. This permits bounded floating-point/FMA rounding under cancellation.
It does not promise bit-for-bit equality or preservation of the sign of zero.
Non-finite outputs and incomplete probe output always fail.

Run comparisons in all three project profiles, including the release LTO build.
The regression tests for the comparison gate deliberately supply wrong,
non-finite and missing results to ensure they are rejected.

Norms, normalization, larger vectors/matrices, spatial/quaternion operations,
sparse kernels and solvers are subsequent work; this module is the first slice
of the numeric-kernel milestone.
