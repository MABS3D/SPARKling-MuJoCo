# Quantitative quaternion error along the body tree

Scope: the scalar-joint orientation path in the source snapshot shipped with
this report. These are bounds on quaternion norm and orientation composition,
not bounds on position, spatial inertia, force, integration error, or agreement
with the full MuJoCo simulator. No normalization or runtime check is removed.

## Arithmetic model and certificate boundary

Let `u = 2^-53`; the binary64 machine epsilon used by the source gate is `2u`.
The model uses IEEE binary64 round-to-nearest, ties-to-even, gradual underflow,
no reassociation and no contracted FMA. All operands are finite and bounded.
The normalization certificate additionally models sqrt as correctly rounded.
These hardware/runtime conditions are explicit: a proof of the C/Ada runtime
library, floating-point environment, or compiler is not included.

`check.py` checks the source expressions and replays three Gappa scripts and
six SMT checks. It uses no random tests to establish the bounds. The Gappa
normalization script uses division rewrites: its nonzero-denominator warnings
are discharged separately by `normalization_rewrite.smt2`, using `1 <= n <= 2`
and `N = sqrt(S)`, `1 <= S <= 4`. No arbitrary rewriting equality or nonzero
assumption is accepted without this check. Gappa itself proves the square-root
error bound without a user-supplied square-root rewrite.

The source-to-Gappa mapping is reviewed and guarded by expression checks;
it is not a verified translation pass. SMT `unsat` results and GNATprove
success are trusted tool results, not independently checked proof-assistant
certificates.

## 1. Actual successful Unit_Quaternion gate

The source tests the rounded expression

```
abs (fl(fl(fl(fl(q0*q0) + fl(q1*q1)) + fl(q2*q2)) + fl(q3*q3)) - 1)
  <= 64 * Model_Epsilon
```

where the subtraction is rounded as well, and checks each component against
`1.000001`. `unit_gate.g` uses the slightly wider enclosure `1.000002` and
proves for the exact real sum of squares `S`:

```
|S - 1| <= 144u = 1.5987211554602254e-14.
```

`unit_gate_to_norm.smt2` proves `|sqrt(S)-1| <= 144u` from this bound.
This is a consequence of the current successful gate; it needs no assumption
about sin/cos accuracy or sqrt rounding. It does not prove that normalization
always succeeds. Rejection remains part of the program's specified behavior.

For every accepted body orientation, the same bound applies regardless of
its depth. It controls radial error, not angular drift. The same accepted norm
at every depth does not mean the accumulated orientation error is zero.

## 2. Local rounded Hamilton product

Let `H(a,b)` be the exact Hamilton product of the actual binary64 input values.
For each input component in `[-1.000002, 1.000002]`, `hamilton.g` reproduces the
four products and three left-associated additions/subtractions in each source
component and proves

```
|fl(H)_i - H_i| <= 16u       for i = 0,1,2,3.
||fl(H) - H||_2 <= 32u.
```

The second line follows by summing four squared component bounds. Subnormal
intermediate results are included in Gappa's binary64 rounding model.
`hamilton_norm.smt2` separately verifies the real polynomial identity
`||H(a,b)||_2^2 = ||a||_2^2 ||b||_2^2`; it is not substituted for a statement
about the rounded product.

## 3. Error introduced by the current scaled normalization

For a nonzero quaternion `q`, let `scale = max |q_i|` and `A_i = q_i/scale`
with this ratio evaluated exactly as a real number. Then `|A_i| <= 1` and
`1 <= sum A_i^2 <= 4`, because at least one component has magnitude one.
The source computes `a_i = fl(A_i)`, the rounded left-associated squared sum,
`n = fl(sqrt(s))`, and `x_i = fl(a_i/n)`.

The successful branch explicitly requires `1 <= n <= 2`.
`normalization-div-hints.g` proves, relative to exact normalization `N(q)`:

```
|x_i - N(q)_i| <= 32u
||x - N(q)||_2 <= 64u.
```

The source recomputes the scaled components for `Scaled_Norm`; determinism of
the same floating-point divisions gives the same values. Exact normalization
of `A` is identical to exact normalization of `q` because scale is positive.
The bound is conditional on correctly rounded sqrt and on the accepted branch.

## 4. Direction error per normalized multiplication

Write `N(x) = x / ||x||`. For nonzero real vectors x,y, the triangle inequality
and reverse triangle inequality give

```
||N(x) - N(y)|| <= 2 ||x-y|| / ||y||.
```

Proof: insert `x/||y||` between the two normalized vectors. The first distance
is `| ||y||-||x|| | / ||y||`; the second is `||x-y||/||y||`.

Assume the prior accepted quaternion is q, and the local supplied factor b
has component magnitudes at most 1.000002 and norm at least 1/2. Let
`p = H(q,b)`, `h = fl(H(q,b))`, and `x` be the accepted scaled normalization
of h. From the gate and real Hamilton identity:

```
||p|| >= (1-144u)/2 > 0.49.
||N(h)-N(p)|| <= 64u/0.49.
||N(x)-N(h)|| <= 128u.
||N(x)-N(p)|| < 512u.
```

The input to normalization is nonzero since `||h-p|| <= 32u < 0.49`.
The accepted result x is nonzero by its Unit_Quaternion gate.
`local_budget.smt2` proves the numerical inequalities used above. Triangle
and reverse-triangle inequalities and the displayed Euclidean argument are
ordinary mathematical proof steps, not GNATprove assertions or added axioms
in the SPARK runtime.

The bound 512u is deliberately conservative; no claim of optimality is made.

## 5. Induction along a tree path

The exact comparison sequence starts from identity and multiplies the EXACTLY
NORMALIZED ACTUAL RETURNED local factors. Right multiplication by a unit
quaternion is a real isometry, by linearity and the Hamilton norm identity.
Thus for direction error `E`:

```
E_next <= E_parent + 512u.
E_after_m_products <= m * 512u.
```

This induction is linear, not exponential: the comparison projects the computed
quaternion back onto the unit sphere before measuring directional error. The
actual computed quaternion has the separate radial bound from section 1.
Its full vector error against the unit reference is at most `m*512u + 144u`.

`MJ.Tree_Error_Budgets.Propagate` proves the actual product-count recurrence
for parent-before-child arrays:

```
depth[B]    = depth[parent[B]] + 1
products[B] = products[parent[B]] + 1 + joint_count[B]
budget[B]   = budget[parent[B]] + 512*(1 + joint_count[B])
```

The one extra product is the fixed body orientation. Each hinge adds one
product. Counting each slide as a product overestimates the error safely.
The inertial frame contributes one further multiplication after the body pose;
it is not fed back into child body orientations.

`Propagate_Errors` is proved over mathematical big reals. Given nonnegative
local body errors within those budgets, it proves the parent-to-child error
recurrence and its upper bound. The prefix invariant covers all processed
bodies; parents are in that prefix. Both routines are ghost code and the whole
unit is checked after the minimal subprogram checks.

These ghost models do not by themselves prove that every real pipeline call
meets every floating-point kernel precondition. The linkage is the source
operation accounting above plus the separately recorded pipeline proof status.
No ghost precondition is silently promoted into a proved runtime fact.

For a chain with 24 bodies and one hinge on each, m=48:

- Quaternion direction chord error <= 2.7284841053187847e-12.
- Physical rotation angle error <= 4E = 1.0913936421275139e-11 radians.

For the angle bound, unit quaternion chord E corresponds to angle at most
`4 asin(E/2)` (taking the smaller sign-equivalent chord). For E<=1,
`asin(E/2)<=E`, giving the conservative `4E` used here.

On a physically consistent model with at most 4096 bodies including world and
256 scalar joints in total, a path has at most 4351 such products; an inertial
frame has at most 4352. These give conditional quaternion direction bounds
2.4732571546337567e-10 and 2.473825588822365e-10 respectively. The SPARK package
itself permits the weaker per-body joint-count premise, so its unconditional
integer bound is `(4096-1)*(256+1)`, not 4351. The stronger global-count premise
must be established by the model/layout validation to use the tighter number.

## 6. What this does not establish yet

`Axis_Angle` currently specifies component bounds and exact use of the returned
Sin/Cos values. It does not give a proved lower norm bound or an accuracy bound
against mathematical sine and cosine. Configured body orientations already
have the unit-gate guarantee; the axis-angle factor's `norm >= 1/2` premise is
therefore an explicit remaining bridge for an unconditional angular theorem.
No epsilon for the platform's trigonometric library has been invented.

If each normalized returned local factor differs from its intended ideal factor
by eta_j, the same real isometry/triangle argument gives

```
E_path <= m*512u + sum eta_j.
```

The eta_j terms include model quantization, normalized-axis error, angle
subtraction and trig evaluation where relevant. They are NOT bounded by the
512u rounding budget proved for multiplication and normalization.

Positions, inertia transforms and dynamics need their own dimensional error
bounds; this report does not transfer an angular bound to those quantities.

## 7. Why normalization cannot be removed on the current contract alone

Take q=(1+32*2^-52,0,0,0). Its rounded Unit_Quaternion gate passes. The rounded
Hamilton product q*q has scalar component 1+64*2^-52 and fails the same gate.
`check.py` records the hexadecimal binary64 values and verifies this example.
This is a counterexample to a proposed inference from the current contracts,
not a claim that Create produces that value or that the simulation is incorrect.
It shows why a stronger invariant/normalization policy is needed before
removing normalization based on those contracts.

## References

- [Gappa: rounding model and proof scripts](https://gappa.gitlabpages.inria.fr/gappa/examples.html).
- [SPARK: floating-point semantics](https://docs.adacore.com/live/wave/spark2014/html/spark2014_ug/en/appendix/semantics_of_floating_point_operations.html).

The bounds and tree derivation above are specific to the supplied source and
certificates, not numerical constants quoted from these references.
