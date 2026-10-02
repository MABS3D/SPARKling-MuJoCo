# Joint limits, isolated candidate

This directory implements the per-joint rows and their reference response from
MuJoCo 3.14.0, pinned to commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. It is deliberately isolated from
the main thread's changes to the smooth pipeline and the constraint solvers.

## Current receipts (2026-10-02)

| Verification | Passed checks/cases | Open obligations | Warnings |
| --- | ---: | ---: | ---: |
| Complete `MJ.Joint_Limits` unit | 212 | 1 (`Build_Ball` composition) | 0 |
| Complete `MJ.Joint_Limit_Response` unit | 230 | 0 | 0 |
| Reused complete `MJ.Contact_Rows` unit | 226 | 0 | 0 |
| C comparison, each of development/validation/release | 5,350 cases / 224,700 field comparisons | 0 numerical mismatches | expected C mixed-solref warnings |

All reported finite values matched the official C library exactly in these
tests, including the near-pi regression. This is observed agreement, not a
universal binary-equivalence or numerical-accuracy proof. Whole-unit coverage
was checked against every declared subprogram, including static ghost models
and the nested force-projection helper. No proof/flow skips or Assume pragmas
occur in the receipts. The suite covers scalar threshold neighbors, simultaneous
lower/upper activation, signed margins, direct/mixed solref, solimp clamping and
branches, ball quaternion degeneracies, metadata, clearing and force projection.

`results/summary.json` records the pending proof and integration explicitly;
`results/proofs/` contains the fresh whole-unit reports. `results/source/`
freezes their exact source closure. Build/comparison receipts include compiler,
CPU, source, binary, official MuJoCo library and numerical-runtime provenance.

## Implemented behavior

`MJ.Joint_Limits` constructs sparse local rows without allocation:

- Hinge and slide: lower side first, upper side second, exact strict
  `distance < margin` activation. Both sides can be active. Signed margins
  are accepted; the rounded lower-distance expression retains C's sign order.
- Ball: normalize the quaternion, form the shortest rotation vector, normalize
  that vector again, use `max(range[0], range[1]) - angle`, and negate the axis
  for the three-component Jacobian. Tiny-vector fallbacks, antipodal
  quaternions and the strict branch at pi follow C.
- Free: no joint-limit row. The enable predicate accounts for the global
  constraint/limit flags, `jnt_limited`, and the caller's sleep filter.
- Empty and rejected batches clear all unused rows. Metadata and row order are
  preserved. `Project_Forces` maps solved nonnegative row forces into local
  generalized forces or torques, including both scalar sides.

`MJ.Joint_Limit_Response` computes velocity, impedance and its derivative,
K/B/I/P, regularization R, inverse weight D, and reference acceleration aref.
It supports the standard positive and direct nonpositive solref formats,
mixed-sign replacement with defaults, refsafe, and linear/quadratic solimp.
Sanitization clamps the impedance endpoints, midpoint and width as C does.
The returned `Used_Default` flag exposes replacement without printing a warning
from a pure kernel.

R uses the approximate weight of the joint's **first DOF** (`dof_invweight0`),
as C does. A ball row's current projected inverse inertia is a different
quantity. `Prepare` does not pretend to solve this coupled system.

## Proof and numeric boundary

Static ghost contracts specify the ordered floating-point operations,
activation, Jacobians, metadata, unused fields, and generalized force
projection. Preparatory functions specify every response field and rejection
default. They do not assert exact real-arithmetic identities or certify the
whole simulator. Proof diagnostics start with the smallest subprograms; fresh
whole-unit reports are required for acceptance.

The complete `Build_Ball = Model.Ball` composition obligation remains OPEN.
Its normalization, rotation-vector, short-angle and final-row kernels have
proved functional contracts; the complete wrapper's safety, initialization and
row-well-formedness checks are proved. Differential agreement does not close
the missing composition proof. `Build` relies on the ball callee's contract,
so its modular proof does not establish an unconditional end-to-end claim for
ball joints. This is pending proof engineering, not a Silver-only mathematical
exception. Whole-unit receipts must retain this open obligation.

The elementary runtime boundary is explicit. `MJ.Joint_Limit_Math` imports
**libm sqrt and atan2**, the same elementary operations called by MuJoCo.
Neither declaration has an assumed accuracy or output-range postcondition.
Sqrt receives a proved nonnegative squared reduction. Norm results are checked
before their use as angular lengths; normalization handles the tiny result
through its specified fallback. Atan2's return is checked before multiplying
by two. This is
not a C implementation of the joint-limit algorithm. The algorithm, guards,
rows and projections remain in SPARK. GNAT's generic Arctan instead reduces
quadrants through atan and additional rounded subtractions: a regression near
pi demonstrated that it can reverse the axis compared with C. The differential
suite preserves this case.

The proof runner retains any `imprecise-call` warnings for Sqrt/Atan2 and records
them as reviewed numeric-runtime warnings. Application proofs stop at the
elementary runtime interface and do not verify libm's bodies or error bounds.
This does not replace an unproved application check. There are no new Assume
pragmas, check suppressions, or application bodies marked SPARK off.

Inputs have the project's Tier0 bounds for positions, ranges, signed margins,
quaternions and velocities. Diagonal approximations use the existing positive
inverse-mass domain. Checks at normalization boundaries explicitly reject a
result outside the typed working domain, clearing the entire row batch.

## Remaining integration and unsupported features

This candidate is **not yet connected to the engine's movement entry point**.
A caller must assemble these rows with the other constraints, solve them
together using the actual mass metric, and accumulate the solved forces into
the dynamics state. Solving the lower and upper sides independently is invalid
when both are active. The projection test deliberately supplies forces solved
by C; it does not test a new solver or a full trajectory.

The discrete integrator is explicitly returned as `Unsupported_Integrator`.
In 3.14.0 it changes K/B/R and aref together, including an implicit row factor
and an additional refsafe bound. Other real solimp powers remain to implement;
the typed API currently represents powers 1 and 2, not arbitrary powers.
Tendon limits, actuator/control limits, frictionloss and other constraint types
are separate features. None of these gaps is a documented Silver-only
mathematical exception: they are pending implementation/integration work.

Integrated movement performance, including constraints and integration, remains
pending. The row differential tests and proofs do not establish performance
parity with the C engine.

## Reproduce

Use `/var/tmp/sparkling-movement-env/bin/python` (MuJoCo 3.14.0 installed).
Build and proof runners find the existing GNAT/GPRbuild/GNATprove toolchains
under `/var/tmp/sparkling-matrix-recovery/toolchains`. All generated build and
proof files go outside the checkout.

```sh
python tests/build.py --out /var/tmp/sparkling-joint-limits-20261001/build --mode validation
python tests/compare.py --binary /var/tmp/sparkling-joint-limits-20261001/build/validation/bin/limit_probe --out /var/tmp/sparkling-joint-limits-20261001/compare-validation
python tests/prove.py --out /var/tmp/sparkling-joint-limits-20261001/proof-small --phase small
python tests/prove.py --out /var/tmp/sparkling-joint-limits-20261001/proof-whole --phase whole
```

Repeat build/comparison for development and release. The runners record source,
binary and official C-library hashes and reject source changes during a run.
`results/reference.json` also checks the normalized hashes of the pinned C
constraint and vector/quaternion source files before verification.
