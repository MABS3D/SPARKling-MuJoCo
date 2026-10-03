# Equality constraints

Owned Ada assembly, response and integration against MuJoCo 3.14.0
(`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`). The implementation is in:

- `../constraint-assembly-candidate/src/mj-equality_geometry.*`: ordered
  floating-point geometry, scalar proof decomposition and functional contracts.
- `../constraint-assembly-candidate/src/mj-equality_scalar.*`: joint/tendon
  quartic residual and derivative, preserving the expanded C evaluation order.
- `../constrained-step/src/mj-data-constrained-equalities.*`: owned model
  metadata, precomputed ancestor unions, activation, block rows and Jdot*v.
- `../constrained-step/src/mj-data-constrained.*`: equality response and solve
  before friction, limits and contacts.

Body and site semantics follow the native anchor ordering. Weld preserves the
quaternion sign and signed/zero `torquescale`. Common ancestors remain in the
Jacobian, unlike the contact chain. Impedance uses the norm of the entire 3/6
row block; stiffness acts on each signed component. The inverse-weight
approximation distinguishes translation and rotation without squaring
`torquescale`. Jdot*v includes both point acceleration bias and the three
quaternion product-rule terms used by C.

Joint and tendon equalities use the ordered quartic residual and derivative,
initial `qpos0`/`tendon_length0` references and the sum of object inverse weights.
Fixed and spatial tendon CSR columns are merged once at creation; shared columns
and structural zeros are retained. The cached tendon Jacobian is refreshed before
equality assembly, including tendons referenced only by initially inactive
equalities. C does not apply the connect/weld Jdot*v correction to these scalar
rows. Repeated fixed-tendon columns remain explicitly unsupported.

The model can be freed after `Create`. `Set_Equality_Active` updates activation
without replacing dynamic state. An assembly-capacity failure preserves the
complete state; deactivating constraints allows the engine to continue.

## Verification

Run `tests/check.py` with `--phase small --unit <unit> --only <names>` before
`--phase whole --unit <unit>`. `--limit-line file:line` is a diagnostic within
one selected subprogram and is explicitly recorded as line-only evidence.
Inputs and tool versions are frozen in a fresh output directory; the runner
rejects open checks, warnings and incomplete whole-unit coverage. No proof result
is inherited across changed source hashes. `--phase build` produces validation
or release profiles; neither suppresses runtime range checks.

`tests/compare.py` checks geometry against native engine rows and arithmetic
kernels. `tests/compare_step.py` sends only MJB models, state, controls and loads
to the owned engine, then compares rows, response, solved forces and trajectories.
`tests/lifecycle.py` checks activation and atomic recovery after capacity failure.
`tests/export_solver_cases.py` freezes failing assembled problems for diagnosis;
these isolated solver tests do not replace the integrated comparison.

The scalar joint/tendon kernel has fresh whole-unit evidence: 83 checks,
zero open checks/warnings and complete entity coverage, after the twelve
minimal subprogram proofs. Its validation binary matches all 432 native C row
assembly cases exactly, covering joint, fixed tendon and spatial tendon,
one/two objects, dense/sparse storage, quartic coefficients and signed/extreme
values. This establishes the ordered floating-point kernel within its explicit
domain; the adapter's complete functional proof remains open. Inputs use
Tier0 positions/references/coefficients. Residual/Jacobian outputs are deliberately
wider than assembly storage; the adapter checks narrowing explicitly.
`tests/compare_scalar.py` is the native differential harness.

The integrated r62 snapshot passes 468/468 scalar cases over 100 steps in both
validation and release, with identical numerical records between profiles.
Jacobian, reference acceleration and regularization match C exactly in this
corpus; maximum trajectory error is 1.07e-14. The corpus covers PGS/CG/Newton,
dense/sparse, quartic/linear/constant coefficients, initially inactive and
disabled equalities, disabled passive forces and multiple rows. The lifecycle
suite passes 46/46 in both profiles, including activation after freeing the
model and recovery after mixed scalar/weld capacity exhaustion. These tests
do not replace the outstanding proof of the adapter.

Fresh validation and release geometry snapshots on 2026-10-03 each passed
656/656 cases. Their binary/source hashes and proof receipts are in
`evidence/20261003-recovery`. The rotation composition and scalar component
contracts passed their minimal proofs; Weld and complete-unit acceptance remain
open. Integrated r62 passes 755/768 comparable connect/weld samples over 30
steps; 13 extreme torque-scale numerical failures and two interrupted PGS
configurations remain. Current
results and source attribution are recorded in
`../../plans/2026-10-02-recovery-equalities.md` and `evidence/20261002-recovery`.
Functional proofs are in progress; neither the entire geometry unit nor the
owned composition is currently claimed Gold. No integrated performance claim
has been established for equality workloads. Flex equality types remain outside
this producer and must still be completed for the full port.
