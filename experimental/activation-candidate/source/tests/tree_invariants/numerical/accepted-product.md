# Accepted quaternion compositions: removal of the lower-factor-norm premise

This extends, and replaces the lower-norm premise in, sections 4–6 of the
previous `tree-error.md`. It concerns orientation composition, not position,
inertia or integration over time. The reference consists of the exactly
normalized **actual returned factors**, not ideal trigonometric values.

Let u=2^-53 and eta=2^-1074. Keep the binary64 round-to-nearest, gradual
underflow, no reassociation/FMA and correctly rounded sqrt assumptions of the
previous report. All components of each input quaternion have absolute value
at most 1.000002. In particular, this holds for accepted previous orientations,
configured normalized orientations and the `Axis_Angle` result contract.

## Rounding lemma, including tiny intermediates

For each exact scalar operation result z in [-16,16],

    |fl(z)-z| <= u |z| + eta.

Two disjoint cases suffice. Gappa proves a relative error <=u for
|z|>=2^-1021, and an absolute error <=eta for |z|<=2^-1021. Both include their
boundary. The deliberately generous absolute term covers subnormals and the
lowest normal binade. The files `rounding-normal.g` and
`rounding-subnormal.g` certify these cases. All scalar exact intermediates of
the Hamilton product satisfy the range: four terms of magnitude at most
1.000002² plus their rounding errors are far below 16.

## Error of the product, relative to its real norm

Let p=H(a,b), h=fl(H(a,b)), P=||p||. In each Hamilton component write the four
signed exact products as t_j and T_j=|t_j|. Cauchy–Schwarz and the real
Hamilton norm identity give sum T_j <= ||a|| ||b|| = P, for each component
separately. Signs do not affect the bound.

The four multiplication errors are bounded by e_j=u T_j+eta. For the three
left-associated additions/subtractions define an error majorant recursively:

    E_0 = e_0
    E_i = (1+u)(E_(i-1)+e_i) + u sum_(j=0..i) T_j + eta, i=1,2,3.

Triangle inequality and the scalar rounding lemma prove this recurrence for
the actual absolute component error. `hamilton-relative-bound.smt2` proves,
for all nonnegative T_j and P>=sum T_j,

    E_3 <= 5u P + 8eta.

Combining four component errors by the Euclidean norm gives

    ||h-p|| <= 10u P + 16eta.                 (1)

This is a bound for the rounded arithmetic, not an assumption that its
real-algebraic norm identity continues to hold after rounding.

## The existing acceptance test supplies a nonzero denominator

Successful `Normalize` guarantees `Scale_Of(h)>=Min_Val`. The source constant
`Min_Val` is the binary64 value represented by the Ada literal `1.0e-15`;
its exact rational value is recorded in `accepted-product-final/results.json`.
Consequently ||h||>=Min_Val. By (1) and triangle inequality,

    Min_Val <= ||h|| <= (1+10u)P + 16eta.

`accepted-nonzero-product.smt2` proves P>2^-51. In particular p and each
factor are nonzero: no separate `||b||>=1/2` assumption is needed. The second
SMT check proves

    ||h-p||/P <= 10u + 16eta/P < 11u.

The normalization Lipschitz lemma from the earlier report then gives

    ||N(h)-N(p)|| < 22u.

For the accepted normalization result x, the previously certified
||x-N(h)||<=64u implies ||N(x)-N(h)||<=128u. Therefore

    ||N(x)-N(p)|| < 150u < 512u.             (2)

The last SMT check verifies the budget inequality exactly. The existing 512u
budget is retained so the SPARK error-accounting model and previous numerical
examples remain valid. Rejection is still allowed; this proof does not say
normalization always succeeds or may be removed.

## Tree induction and what is now unconditional about it

Using real quaternion linearity and the norm identity, right multiplication
by a unit quaternion is an isometry. Normalizing the real product of two
nonzero factors gives the product of their normalized factors. Applying (2)
at every **accepted** composition yields

    E_path <= 512u * m.

This now follows without an additional lower-norm assumption about the
axis-angle output. It still depends on the arithmetic model and sqrt premise,
and uses the actual returned factors as its reference. The norm gate still
supplies the independent radial bound 144u. The physical rotation angle is
at most 4E_path for E_path<=1, as in the previous report.

For ideal model/trigonometric factors, let eta_j be their quaternion chord
error after exact normalization. Isometry and triangle inequality give

    E_ideal <= 512u*m + sum_path eta_j.

The new SPARK procedure `Bound_Accumulated_Error` proves this tree induction
for an independently supplied nonnegative error sequence satisfying the
local inequality. Unlike `Propagate_Errors`, it does not define the actual
error to equal its bound. Its local-error premise must be connected using
(2) and any separately justified ideal-factor bounds; it is not an axiom
inserted into executable simulation code.

No verified worst-case bound for this platform's libm sin/cos is claimed.
The theorem against actual factors is independent of that bound; the theorem
against ideal rotations contains the explicit eta_j terms. Library
correctness is not inferred from numerical tests.

## Trust and reproduction boundary

Run `accepted-product.py` to regenerate four SMT obligations and replay the
three Gappa rounding/range certificates. The previous normalization certificate and
Hamilton identity must also be replayed with the previous `check.py`.
The Cauchy–Schwarz, triangle inequality, Euclidean norm and normalization
steps above are explicit mathematical arguments; they are not asserted to
be kernel-checked Coq/Lean proofs. Source-to-certificate correspondence is
checked and reviewed, not a verified compiler/translation pass.
