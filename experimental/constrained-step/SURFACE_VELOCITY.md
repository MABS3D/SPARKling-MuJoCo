# Surface velocity in the constrained step

The implementation follows MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`:
`engine_core_util.c:mj_geomSurfaceVelocity` and
`engine_core_constraint.c:mj_addSurfaceVel`. The official latest stable release
was checked on 2026-10-02 and remains 3.14.0.

`Create` owns a copy of all six compiled `geom_surfacevel` components, so
freeing the input MJB model does not remove surface motion. `Generate_Contacts`
caches world poses only for active surface geometries. For each admitted
contact, `MJ.Surface_Velocity` rotates local linear/angular motion, adds
`angular x (contact_point - geom_position)`, and forms geom2 minus geom1.
The relative motion is projected into the contact frame. Normal and rolling
components are zero; tangential motion and spin about the normal remain.

Pyramidal rows receive the ordered `normal +/- friction * component`
contribution. Elliptic rows receive their contact-frame component directly.
The correction is added **after** the original sparse `J*qvel` reduction and
**before** computing the reference acceleration. It changes neither the
Jacobian nor the constraint regularization, and does not replace body motion.
Friction-loss, limit and equality rows do not read this cache. Excluded contacts
and contacts without an active DOF chain do not publish surface rows.

Models without surface motion bypass the new per-contact calculations. Contacts
between inactive surfaces also bypass the transformations. Buffers are reused;
only admitted contact rows are written, without allocation or full-buffer scans.
The surface feature does not independently enable unsupported geometry types,
solvers or other features of the constrained entry.

The new kernels specify exact ordered binary64 operations, bounded intermediates,
zero-surface fallback, normal/rolling masking and both row encodings. Formal
checks start at individual subprograms and then the complete unit; they do not
close the pre-existing global contracts of `MJ.Data.Constrained` or its solvers.
No assumptions, skipped application bodies or runtime-check suppressions are
introduced. Standard SPARK expression-body hiding is used with proved explicit
contracts; it is not an unchecked trusted implementation.

Recovery receipt (2026-10-03): the minimal helpers were proved first, including
Geometry_Value (11 checks) and Geometry (15), then the complete unit passed 171
checks with zero open obligations or warnings and complete body coverage. This
establishes the specified ordered floating-point transformations and masking;
it does not close the engine-level composition. Frozen sources and reports:
`/var/tmp/sparkling-recovery-dynamics-20261003-surface-03-whole`.
The latest accepted integrated validation corpus before the subsequent Newton
and endpoint changes was 92/92 at 30 steps; that composition is being renewed.

Reproduce from the repository root, using fresh absolute output directories:

```sh
python3 experimental/constrained-step/tests/build.py --out /var/tmp/surface-check
python3 experimental/constrained-step/tests/prove_surface_velocity.py --out /var/tmp/surface-proof
/var/tmp/sparkling-movement-env/bin/python experimental/constrained-step/tests/test_surface_velocity.py --binary /var/tmp/surface-check/build/validation/bin/constrained_probe --out /var/tmp/surface-numerics --samples 8 --steps 100 --loads
python3 experimental/constrained-step/tests/build.py --out /var/tmp/surface-check --frozen --mode release
/var/tmp/sparkling-movement-env/bin/python experimental/constrained-step/tests/benchmark_surface_velocity.py --binary /var/tmp/surface-check/build/release/bin/constrained_probe --out /var/tmp/surface-performance
```

The differential suite covers both cones, PGS/CG/Newton, dimensions 1/3/4/6,
rotated frames, angular lever arms, either/both contact sides, moving geometries,
normal-only and zero motion, mixed noncontact rows, excluded/empty contacts and
full trajectories. Timings cover the equivalent full step with native C SIMD,
alternating order and independent trajectory checks. Source hashes scope all
receipts; concurrent changes to shared modules require a new frozen build.
