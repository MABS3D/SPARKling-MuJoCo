# Collision assurance ledger

The target is the project's [Gold policy](../../docs/verification-policy.md):
prove useful functional behavior as well as absence of runtime errors.
[SPARK Gold](https://docs.adacore.com/spark2014-docs/html/ug/en/source/gold_level.html)
concerns stated integrity/functional properties, not a certification or a
prover effort setting. The scope here is the two initial plane collision
primitives and their helpers, not the complete MuJoCo collision pipeline.

## Functional specification

| Subprogram | Property specified and proved |
| --- | --- |
| `Is_Unit` | Exactly the stated ordered floating-point squared-norm test against 1 ± 1e-12. |
| `In_Tier0` | True exactly when every position component satisfies the Tier0 bound. |
| `Projected_Distance` | Exact three-component dot expression, preserving subtraction and addition order, with bounded result. |
| `Plane_Sphere` | Count is 0 or 1 according to the exact C rejection predicate; signed distance and each contact coordinate follow the stated floating-point formulas; normal is copied, tangent is zero, and every unused slot is empty. |
| `Endpoint` | Exact positive/negative endpoint coordinate expression, including its branch and output bound. |
| `Capsule_End` | The endpoint relation holds for each of the three coordinates. |
| `Packed_Model` | Ghost specification of accepting first/second contacts in order, replacing only tangent hints and filling unused slots with zero. Its body is checked. |
| `Pack_Contacts` | The entire result equals `Packed_Model`; counts add, accepted positions/distances are preserved, and contact order and unused slots are specified. |
| `Capsule_Model` | Ghost composition of the proved sphere operation at both specified endpoints, followed by `Packed_Model`. Its body and calls are checked. |
| `Plane_Capsule` | The entire result equals `Capsule_Model`: exact count, order, distances, positions, normals, tangents and unused slots. This includes only the second endpoint hitting and zero half-length retaining duplicates. |

All these properties are conditional on the public type bounds and
preconditions in `mj-collision.ads`. Those bounds are checked by the caller
and carried through the helpers; they were not tightened to discard a failing
test. All bodies are in SPARK, terminate, initialize their outputs and have
their runtime checks proved. No `Assume`, proof suppression, or new trusted
application body is introduced. The ghost models do not call `Plane_Capsule`
or `Pack_Contacts`, so equality with them is not circular.

The capsule model uses `Plane_Sphere` compositionally. That call has a complete
floating-point result contract, proved separately in the same unit. The C
implementation is a differential oracle, not an axiom of the SPARK proof.

## Mathematical scope and limits

**No Silver-only exception is taken for this increment.** Functional behavior
of the implemented floating-point algorithms is covered in addition to safety.
No claim of exact real-arithmetic geometry, numerical stability, or universal
equivalence to every C compiler configuration follows from these proofs.

There is a concrete mathematical obstruction to strengthening the C contact
predicate into an unconditional real-valued `distance <= margin` guarantee.
Take a plane at the origin with normal `(0,0,1)`, sphere center `(0,0,1)`,
radius `1`, and margin `-2**-54`. In binary64 round-to-nearest/ties-to-even,
`1 - 2**-54` is exactly halfway between `1` and its predecessor and rounds
to `1`. Thus `cdist > margin + radius` is false and a contact is emitted,
with returned distance `0`, which is greater than the negative margin.
Exact real arithmetic would reject this contact. The analytic regression
checks the emitted result independently in Ada and C.

Preserving MuJoCo's branch requires specifying its floating-point predicate;
claiming the stronger exact-real classification would be false. A theorem
bounding error or classifying cases separated from the boundary by a suitable
tolerance remains possible and is additional proof work, not an accepted
Silver downgrade or an alleged impossibility. Similarly, direction inputs
satisfy a tolerance-based floating-point norm test; exact real unit length is
not silently assumed.

## Evidence

Final verification on 2026-09-23 passed: **106 checks, zero unproved checks,
zero warnings**, covering all ten subprograms including the ghost models.
Tool versions: GNATprove/GNAT/GCC 16.1.0 and GPRbuild 26.0.0, Linux/WSL.
All numerical and rejected-input checks below passed on the same source hashes.
Windows and unchecked release builds are outside this recorded validation.

The runner first checks each of the ten subprograms individually, then performs
a complete-unit proof with source/report hashes and coverage checks. It rejects
unproved checks, warnings, skipped/assumed proofs, out-of-SPARK bodies and
changes to Ada, tooling or pinned C input files during verification.

The differential suite uses 5,260 cases per Ada build at `-O0` and `-O2`, with
runtime contracts enabled: 105,200 scalar comparisons per build, ten exact
analytic cases, and four additional rejected-input cases per build. Numerical
comparison tolerances are documented in `README.md`; test success is distinct
from formal proof.

`evidence/results.json`, `evidence/mj-collision.spark` and
`evidence/proof-receipt.json` record the final run. The evidence archive contains
the matching sources, pinned C dependencies, raw proof/test logs and a SHA-256
manifest. Reproduce using the command in `README.md` with the recorded tools.
