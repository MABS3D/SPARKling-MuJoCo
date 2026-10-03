# Native dynamics derivatives

This workspace owns its smooth and constrained scratch simulations. It computes
transition matrices A/B, velocity derivatives of smooth/passive force, and inverse
force/mass derivatives. Transition state is the tangent vector `[dq,dv,da]`;
inverse derivative matrices use the C convention of input directions as rows.
The source model can be freed after creation, and output matrices are preserved
on reported failures. All simulation and contact work runs in native Ada.

The C 3.14.0 comparison now includes 80 model configurations and 12 samples each:
smooth manifolds, fluid, tendons, activations, solver methods, dense/sparse
elliptic cones and 55 adhesion configurations. The final ablation snapshot
`/var/tmp/sparkling-services-derivatives-axis-20261003` passes 960/960 with the
original finite-difference tolerances. The subsequent production closure
`/var/tmp/sparkling-services-inverse-derivatives-production-20261003` also passes
960/960 after both common patches were applied. Source and binary hashes are
saved in `evidence/recovery-20261003`.

Three defects were isolated without widening tolerances:

- Constraint reference velocity must use C's dense/sparse reduction order.
- Quaternion perturbation normalizes the input before the multiplication and
  keeps the resulting quaternion without a second normalization.
- Joint axes and anchors use C's quaternion-vector rotation. Matrix rotation
  has different floating-point rounding despite algebraic equivalence.

Seven executable arithmetic/storage kernels and their whole unit pass 82 proof
checks plus 14 flow checks. Their contracts cover ordered differences, control
stencil selection, matrix writes and preservation of other entries. `Within`
is a Boolean expression definition with only two flow checks; these are not
counted as arithmetic proofs. These results neither prove real derivative
accuracy nor the full workspace/contact/integration composition.

Remaining scope includes sensor Jacobians C/D and DsDq/DsDv/DsDa, history and all
producer combinations, inverse-discrete correction, integrators beyond the
currently admitted Euler workspace, public C ABI and integrated performance.
The official C finite-difference entry points reject sleep, RK4 and no-slip;
those restrictions are not evidence that the corresponding engine features have
been ported. Complete success/frame and composition proofs remain pending.
