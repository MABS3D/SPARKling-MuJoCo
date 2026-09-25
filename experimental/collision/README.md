# Collision primitives: first port increment

Current reference: MuJoCo **3.14.0**; see [migration scope and evidence](../../docs/mujoco-3.14-alignment.md). The 3.12 results below are historical evidence, not results relabelled for 3.14.

This separate project ports the plane–sphere and plane–capsule narrowphase
functions from MuJoCo 3.12.0, commit
`13827e9ee56f097f57acf69ae52b078f9839682d`. It depends only on the existing
`MJ` and `MJ.Types` units, and can be checked independently of the loader and
the smooth dynamics draft.

Verified on Linux/WSL, 2026-09-23: **106 complete-unit checks proved, zero
unproved checks and zero warnings**, with functional contracts for both
primitives. All 5,260 differential cases pass in each of the two checked builds.
The [property ledger](verification.md) defines the Gold scope and the
mathematical limits; [results](evidence/results.json) and the
[evidence archive](evidence/collision-evidence.zip) preserve the matching run.

## API and conventions

`MJ.Collision.Plane_Sphere` and `Plane_Capsule` take world-space positions,
the plane's outward unit normal, radius, and contact margin. The capsule also
takes its unit axis and half-length. Results contain a count and two fixed
slots, with no heap allocation. Only slots below `Count` describe contacts;
unused slots are deterministically zero.

The result corresponds to C's `mjPreContact`, not the solver's `mjContact`:
signed surface distance (negative for penetration), the midpoint between
the surfaces, a normal, and a tangent hint. Capsule contacts keep the axis as
their hint; sphere contacts use zero. The normal points into the plane's
positive half-space even when the other shape's center lies behind the plane.

The C rejection test is preserved as `cdist > margin + radius`, rather than
rearranging floating-point operations. Equality produces a contact. Capsule
endpoints are processed in positive-axis then negative-axis order; a lone
second contact is compacted to slot zero. Zero half-length keeps both
coincident contacts, matching C. Negative margins and zero radii are supported
by these raw kernels; model-level size validation remains the caller's job.

Public positions have component bounds ±2e10. Capsule centers are additionally
limited to ±1e10 so their endpoints remain representable. Radii and half-lengths
are in [0, 1e10], margins in ±1e10. Directions have components in [-1, 1] and
must have squared norm within 1e-12 of one. Directions are checked, not silently
renormalized. These are valid typed Ada inputs, not a decoder for arbitrary
foreign bytes. The contact vectors are not ABI-compatible C structs.

## Verification

With native GNAT/GPRbuild/GNATprove and GCC on PATH, from the repository root:

```sh
python3 experimental/collision/tests/check.py
```

The runner creates a new build/evidence directory under `/tmp`, prints its
path and saves `results.json`. Use `--only proof` or `--only tests` for a selected
check. This runner targets Linux/WSL; Windows execution has not been validated.

Proof runs first select each expression function and subprogram with
`--limit-subp`. Only the subsequent complete-unit invocation is accepted as
unit evidence. The checker records source and report hashes, requires every
collision body in SPARK, and rejects unproved obligations, skipped proofs,
assumptions, stale reports and warnings. The scope is `MJ.Collision`; imported
foundation units retain their separate verification scope. No whole-engine
correctness claim follows from this increment.

The numeric runner compiles and calls the actual C collision functions, with
the C BLAS implementation. All 23 C/header dependencies are pinned by
LF-normalized SHA-256 and were checked against the stated Git commit. It runs
5,260 cases in each of two Ada builds (`-O0` and `-O2`, runtime checks enabled),
including ten independent exact analytic cases, 0/1/2 contacts, both single
capsule-end cases, touching, signed margins, degenerate shapes, subnormal
inputs, large coordinates, arbitrary unit directions and deterministic random
inputs. Count, direction hints and unused slots are checked exactly. Distance
and position comparisons allow 32 machine epsilons times the input operation
scale, plus 32 smallest subnormals; this is a testing tolerance, not a proved
forward-error bound. The C build disables fused multiply-add contraction.
Four additional cases per build verify that invalid normals, invalid capsule
axes and out-of-contract capsule centers are rejected by runtime preconditions.

## Proof annotations

The two local `Hide_Info` annotations in `Plane_Sphere` and `Plane_Capsule`
hide only the expression body of `Is_Unit`. Its body is verified separately.
The same predicate remains a required precondition and is passed unchanged to
the sphere calls inside the capsule function. Component subtype bounds suffice
for the arithmetic proof; expanding squared-norm constraints there adds
unneeded nonlinear floating-point terms. These annotations neither assume
facts nor suppress checks. Explicit bounded intermediates also keep the
distance and contact-position proofs small.

`Pack_Contacts` is a separate proved helper. Its contract preserves contact
positions and distances, sums the two counts, compacts in endpoint order and
sets the tangent hints. Its complete result must equal `Packed_Model`, a ghost
sequence specification that does not call the implementation. The sphere's
public contract gives the exact threshold, signed distance and position formula.
The capsule's public contract equates its complete result to `Capsule_Model`,
which composes the separately proved sphere operation at both specified
endpoints and applies `Packed_Model`. This covers the count, order and every
contact field. Differential testing checks the implementation against C.

`Endpoint` separately proves the exact coordinate formula and its output
bounds; `Capsule_End` lifts that relation to all three coordinates. A proved
`Assert_And_Cut` before contact packing retains the two counts, valid-contact
normals, model preconditions and equality with the complete capsule model.
It discards intermediate arithmetic facts from subsequent proof context;
the assertion itself is an obligation, not an assumption.

The two ghost model expression bodies are hidden by default. `Pack_Contacts`
unhides `Packed_Model` to prove its implementation; `Plane_Capsule` unhides
`Capsule_Model` to prove composition. Both model bodies are independently
checked. This is proof modularity, without a new trusted body or suppression.

The assurance target follows the repository's [Gold policy](../../docs/verification-policy.md).
Functional floating-point behavior, runtime safety and numerical accuracy over
the reals are separate claims. No Silver-only exception is taken for these
primitives. See [the property ledger](verification.md) for exact coverage.

## Next integration steps

1. Extend the numeric foundation with a verified norm/normalization policy,
   then port sphere–sphere and sphere–capsule, including coincident centers.
2. Add plane–box/cylinder and the remaining primitive pairs, with tests for
   contact ordering and near-degenerate orientations.
3. Provide geometry world transforms and a model/data adapter; retain the
   raw kernels as the small proof units.
4. Port candidate-pair generation and filtering: masks, excluded pairs,
   explicit pairs, body relationships and collision margins.
5. Build complete contact frames and material parameters, then integrate
   contact storage and constraint construction with the solver.
6. Handle convex meshes, height fields, continuous collision and other
   advanced geometry in separately validated increments.

This increment does not yet make a simulation respond to collisions.

The adapted Ada implementation retains the upstream Apache-2.0 attribution;
see the bundled reference's `mujoco/LICENSE`.
