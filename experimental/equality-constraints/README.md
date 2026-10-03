# Equality constraints

Owned Ada assembly, response and integration against MuJoCo 3.14.0
(`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`). The implementation is in:

- `../constraint-assembly-candidate/src/mj-equality_geometry.*`: ordered
  floating-point geometry, scalar proof decomposition and functional contracts.
- `../constraint-assembly-candidate/src/mj-equality_scalar.*`: joint/tendon
  quartic residual and derivative, preserving the expanded C evaluation order.
- `../constraint-assembly-candidate/src/mj-equality_flex.*`: edge residual
  and ordered projection, including the zero-axis branches of C's matrix
  transpose product. This kernel is not yet connected to the flex producer.
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
rejects open checks, warnings, empty line selections and incomplete whole-unit
coverage. No proof result is inherited across changed source hashes.
`--phase build` produces validation
or release profiles; neither suppresses runtime range checks.

`tests/compare.py` checks geometry against native engine rows and arithmetic
kernels. `tests/compare_step.py` sends only MJB models, state, controls and loads
to the owned engine, then compares rows, response, solved forces and trajectories.
`tests/lifecycle.py` checks activation and atomic recovery after capacity failure.
`tests/export_solver_cases.py` freezes failing assembled problems for diagnosis;
these isolated solver tests do not replace the integrated comparison.
Its records also retain the actual native CSR slots, including stored zeros
and duplicate columns; a dense numeric Jacobian cannot recover that order.

The flex edge arithmetic has complete unit evidence: 33 checks after five
minimal subprogram proofs, zero open checks/warnings and complete coverage.
Both validation and release match all 1,883 native cases bitwise, including
signed zeros and vector C calls of widths 1/4/5/16/17/64/128. Proof and build
source manifests are identical. This covers the declared floating-point
residual/projection formulas; geometry, model ownership, row assembly and flex
trajectory integration remain pending.

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

The integrated r72 snapshot passes 576/576 scalar cases over 100 steps in both
validation and release, with identical numerical records between profiles.
Jacobian, reference acceleration and regularization match C exactly in this
corpus; maximum trajectory error is 3.91e-14. The corpus covers PGS/CG/Newton,
dense/sparse, quartic/linear/constant coefficients, initially inactive and
disabled equalities, disabled passive forces, multiple rows, and simultaneous
joint friction, limits and plane contacts. The lifecycle
suite passes 46/46 in both profiles, including activation after freeing the
model and recovery after mixed scalar/weld capacity exhaustion. These tests
do not replace the outstanding proof of the adapter.

The mixed cases exposed an overly narrow force argument in the final projection:
C can generate a large force on a zero Jacobian row while generalized force and
acceleration remain small. `MJ.Constrained_Kernels.Accumulate_Force` now accepts
the solver's force domain, preserving the ordered multiply/add and final state
admission. Its minimum proof passes seven checks; the complete kernel unit passes
39, including exact functional contracts, with no open checks or warnings.

The complete geometry unit now passes 619 checks, with full entity coverage,
zero open checks/warnings and no assumptions or skipped proofs. This includes
Weld's initialization, prefix preservation and final exact component relations.
Fresh validation and release builds from those same sources each pass 656/656
native cases. Binary/source hashes and proof receipts are in
`evidence/20261003-recovery`. Integrated r72 passes 755/768 comparable
connect/weld samples over 30
steps; 13 extreme torque-scale numerical failures and two interrupted PGS
configurations remain. Current
results and source attribution are recorded in
`../../plans/2026-10-02-recovery-equalities.md` and `evidence/20261002-recovery`.
The geometry kernel's ordered floating-point contracts are proved; the owned
adapter and global simulation composition still require their functional proofs.
No integrated performance claim
has been established for equality workloads. Flex equality types remain outside
this producer and must still be completed for the full port.
