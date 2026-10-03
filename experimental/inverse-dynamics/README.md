# Native inverse dynamics

The owned smooth and constrained adapters compute required generalized force
from an arbitrary acceleration. The source model may be released after creating
the engine. The implementation uses native mass, bias, gravity, passive force and
constraint rows; the C library is used only by the test oracle.

The mass product follows MuJoCo 3.14.0's diagonal, reversed lower-column and upper
scatter order. Required force is evaluated as
`(bias - gravity) + ((mass_times_acceleration - passive) - constraint)`.
Constraint response supports equality, friction, unilateral/pyramidal and elliptic
rows. Its explicit dense/sparse choice preserves the different C remainder
grouping; the constrained inverse entry currently selects sparse rows.

Fresh validation evidence in `evidence/recovery-20261003` records 2,848 scenarios
on 712 model configurations and 412 independent prepared-row cases. The latter
coincide exactly with the official C response, including cancellation, structural
zero and tail cases. These are differential results, not universal equivalence
proofs. Prepared rows do not establish coverage of every geometry/equality
producer. No integrated timing result is claimed.

All five `Inverse_Kernels` subprograms and the whole unit pass: 35 proof checks
plus 9 flow checks, with complete SPARK coverage. Contracts describe the ordered
floating-point operations, bounds, individual writes and unchanged entries.
The mass model's shape and bounds also pass. The final `Multiply = Model`
postcondition remains open and requires a prefix/composition model for the
nested loops. The full constraint response and adapter composition remain
unproved; none inherit the kernel's proof status.

Public C ABI, inverse-discrete semantics, all producer combinations and complete
API success/frame contracts remain in the project queue. The candidate's bounds
and status returns are explicit native API policies.
