# Functional property ledger

The final complete-unit results are in `results/summary.json`; the matching
sources, commands, detailed reports and numeric outputs are in
`results/contact-evidence.zip`. Diagnostic attempts are not accepted evidence.

All properties below concern the specified finite floating-point algorithm
under the public input subtypes/preconditions. “Exact” means Ada numeric equality
with the stated operation order, not bitwise identity of signed zero or equality
with an ideal real-arithmetic calculation.

| Runtime subprogram | Functional property |
|---|---|
| `Mass_Inverse` | Ordered `1 / mass`; strictly positive typed input |
| `Stiffness` | C-order denominator and `refsafe` time-constant clamp, with tiny-denominator fallback |
| `Damping` | C-order damping gain and denominator clamp |
| `Shape` | Both branches of the quadratic sigmoid for `X` in [0,1] |
| `Impedance` | Constant/tiny-width fallback, saturation, endpoint and sigmoid branches |
| `Regularizer` | Ordered impedance/mass regularization with positive floor |
| `Smooth` | Gravity plus externally applied generalized force, divided by mass |
| `Reference` | Ordered velocity damping and impedance-weighted positional term |
| `Projected_Force` | Scalar projected solve: negative candidate force becomes zero |
| `Accelerated` | Smooth acceleration plus mass-inverse-scaled normal reaction |
| `Assemble` | Every field of an accepted row; exact rejected-row status and defaults |
| `Detect` | Exact detection predicate and returned signed distance/empty default |
| `Evaluate` | All detection/activation branches; row construction and returned status; no state mutation |
| `Step` | Evaluation correspondence, exact acceptance condition, semi-implicit Euler and time; entire state preserved on rejection |

The 11 `MJ.Contact_Rows.Model` expression functions/predicates and four
`MJ.Contact_Slider.Model` functions/predicates are themselves verified. Their
arithmetic safety and call preconditions are included in complete-unit checks.
The two models express composition through fully specified intermediate output
relations; they do not substitute an assumed result for the runtime body.

`MJ.Collision` is rechecked as a whole, including its existing supporting
functions and plane–capsule primitive. This candidate calls only plane–sphere.
The foundation `MJ`/`MJ.Types` declarations are recorded dependencies; this is
not a new proof of all repository packages or the generic dynamics pipeline.

Useful physical consequences within scope include nonnegative normal force,
zero reaction when the projected candidate force is negative, and exact atomic
rejection. This does not establish universal hard nonpenetration, exact real
complementarity, universal long-term stability, or error bounds relative to C.
The positive impedance guard remains explicit; a sharper rounded sigmoid bound
would be further proof work, not a reason to describe that guard as eliminated.

Differential evidence is separate: exact status/contact/constraint counts,
explicit numeric tolerances, analytical free-fall/static-load checks and long
trajectories against C. Complete-unit proof counts are never obtained by adding
repeated diagnostic runs. Performance evidence applies only to the isolated
single-slider model described in the README.
