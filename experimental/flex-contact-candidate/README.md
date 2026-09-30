# Cartesian flex with plane contacts

An isolated, executable SPARK candidate combining the existing elastic network
with frictionless contacts against **one fixed plane of arbitrary orientation**.
This is not general MuJoCo flex support and does not enable flex in the rigid
body `MJ.Data` loader. Existing sources and the other candidates are unchanged.

## Supported operation

`MJ.Flex_Contact_Network.Step` computes, in order:

1. Edge spring and damper forces, using `MJ.Elastic_Network.Forces`.
2. Gravity and the caller's Cartesian applied forces, followed by inverse mass.
3. Plane contacts at flex vertices, with radius, margin and gap, followed by
   the C 3.14.0 contact filter when more than 50 candidates are detected.
4. Positive-solref, quadratic-solimp frictionless normal rows (`condim=1`),
   regularization, nonnegative normal force, and Cartesian force projection.
5. Semi-implicit Euler for every unpinned particle, with an atomic commit.

Particles have three independent translation coordinates and isotropic mass.
Consequently different vertices have independent normal constraint rows; the
direct scalar solve has the same supported equations as the C PGS solve. An
arbitrary plane uses its full three-component Jacobian, including `J M^-1 J'`;
this is not three unrelated one-dimensional contact simulations. Edge damping
is explicit, matching these flex-edge fixtures under Euler.

The public preconditions require the existing network topology and input
domains, matching array bounds, and a normal whose squared norm differs from
one by at most `1e-12`. Solver parameters are **effective pair parameters**:
material mixing, override flags and collision masks must be resolved by a
future model adapter. `Evaluate` returns the pre-step geometry, free and total
accelerations, and normal forces. `Step` returns the same pre-step diagnostics.
Always inspect its status before consuming the diagnostics.

No heap allocation is introduced. Static ghost models and proof lemmas are
removed from executable builds. Input/output bounds are checked before committing
the next state; a rejected step preserves positions, velocities, masses and pins
for the entire network, including vertices already visited by the loop.

## Exact scope and differences from C

- At most 4096 particles and 4096 edges, inherited from the elastic network.
- Up to 4096 detected contacts. The literal C 3.14.0 `filterFlexContacts`
  algorithm retains at most `mjMAXCONPAIR=50`, using the deepest contact and
  farthest-point distance updates. It compares contact positions, not vertex
  centers, preserves strict tie comparisons and the `mjMAXVAL=1e10` cache cap.
  The C implementation leaves its selected/distance caches unpermuted when
  swapping contacts and omits the swap on the final iteration; both details
  are deliberately preserved. The old `Contact_Limit` status is removed.
- `Contact` reports geometric detection. `Retained_Rank=0` means the vertex was
  discarded or not detected; positive ranks give the retained **filter-prefix
  order**. C's default midphase subsequently sorts this prefix by vertex ID;
  these independent normal rows produce the same motion in either order. The
  API exposes filter order explicitly, not C's later global contact order.
  `Active` additionally requires penetration below the margin and a mobile
  vertex. Discarded contacts produce zero normal force. Pinned and gap-only
  candidates participate in filtering, as in C.
- Pinned particles remain unchanged and have zero reported contact force and
  acceleration. `Contact` still reports geometric detection; `Active` excludes
  pinned vertices. C can retain zero-Jacobian rows for penetrating pinned
  vertices and report large regularized reactions that cannot move anything.
  Those diagnostic reactions are not reproduced. Differential tests compare
  mobile-vertex reactions and the state of all vertices. They disable C islands:
  with the pinned penetrating fixture, C 3.14.0's island path reports
  `mj_island: no tree found for constraint 0`. No C source is patched.
- Only fixed planes and frictionless vertex contacts. General rigid shapes
  require edge/triangle/tetrahedron collision handling, rather than substituting
  independent spheres for the vertices. Flex-flex contacts, self-collision,
  friction cones, adhesion, multiple planes per vertex, articulated coupling,
  flex interpolation, continuum/bending elasticity, edge equality constraints
  and implicit integration remain outside this candidate.
- `Numeric_Limit` reports a rejected elastic/row evaluation or next-state domain
  overflow. A failed evaluation initializes diagnostics but may fill only a
  prefix. A failed step never partially commits the network.

## Verification

See [the recorded results](results/README.md). Functional contracts connect each
normal load to its floating-point row model, the retained contact set to an
ordered recursive filter model, and each accepted network update to
the existing elastic `Prefix` specification. They also prove rollback, pinned
state and metadata preservation. The ghost `Relate_Forces` lemma proves the
componentwise link between accumulated forces and the network model; it is not
an assumption or a run-time scan. The filter's ghost equality lemmas likewise
prove composition across floating-point records. They do not add executable
scans. Runtime buffers are sized to the particle count, without heap allocation.

`Contact_Point` and `Distance2` specify ordered binary64 geometry; `Collect`
implements the ascending-vertex candidate model; `Deepest` and `Scan` implement
strict first-tie comparisons; `Advance` specifies the exact cache/swap transition;
`Reduce` matches its 50-transition model (a missing next contact is an identity
transition); `Select_Contacts` maps the final prefix to vertex ranks. Network
contracts connect these ranks to every applied normal force and Euler update.

GNAT 16.1 required two source-level workarounds in the ghost specification: an
explicit `Empty` constructor and explicit state-array initialization. A delta
aggregate over an `Old` array in a checked postcondition also triggered an
internal compiler error; this functional postcondition is static, proved and
erased like the other Gold models. Checked builds retain runtime input/index/
range/overflow checks. No compiler output or verification result was patched.

These are properties of the specified floating-point algorithm, not ideal-real
energy conservation or universal equivalence to C. Existing elastic lengths
retain their established Ada runtime square-root contract boundary.

The reference is MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; the latest official stable release was
checked on 2026-09-30. Reviewed C stages are `mjc_PlaneFlex`,
`mj_collidePlaneFlex`, `filterFlexContacts`, normal contact Jacobian/regularizer
construction, `solPGS`, Cartesian flex passive forces and Euler integration.

## Reproduce

Run from the repository root, using a Python environment with MuJoCo 3.14.0 and
NumPy. Build and proof snapshots go outside the checkout. `check.py` locates the
existing GNAT/GPRbuild/GNATprove 16.1 toolchain under
`/var/tmp/sparkling-matrix-recovery/toolchains`; adapt its `TC` setting on another
machine. The compiler-generated project uses only the required snapshotted units.

```sh
python3 experimental/flex-contact-candidate/tests/check.py --out /var/tmp/flex-check --phase small
python3 experimental/flex-contact-candidate/tests/check.py --out /var/tmp/flex-check --phase whole
python3 experimental/flex-contact-candidate/tests/check.py --out /var/tmp/flex-validation --phase build
python3 experimental/flex-contact-candidate/tests/compare.py --exe /var/tmp/flex-validation/bin/flex_contact_probe --out /var/tmp/flex-numeric
python3 experimental/flex-contact-candidate/tests/filter_tests.py --exe /var/tmp/flex-validation/bin/flex_contact_probe --out /var/tmp/flex-filter-order
python3 experimental/flex-contact-candidate/tests/check.py --out /var/tmp/flex-release --phase build --mode release
python3 experimental/flex-contact-candidate/tests/compare.py --exe /var/tmp/flex-release/bin/flex_contact_probe --out /var/tmp/flex-numeric-release
python3 experimental/flex-contact-candidate/tests/benchmark.py --exe /var/tmp/flex-release/bin/flex_contact_probe --out /var/tmp/flex-performance --cpu 8
```

For small-subprogram diagnosis, `check.py --phase small --only NAME` narrows the
proof. `--phase small --line FILE:LINE` isolates an individual diagnostic; it is
rejected in whole-proof mode. Whole-unit runs reject skipped proof/flow, assumptions, missing SPARK
coverage and unproved obligations, and record source hashes. Benchmarking uses
the existing native C build under `/var/tmp/sparkling-movement-c` (override with
`--c-root`) and records compiler flags, library/binary hashes, CPU and timings.
The C build retains its normal AVX paths. One real C flex contains the whole
network, avoiding duplicated contacts or one-flex-per-edge overhead.

The extracted-C filter harness uses the original function body without edits;
only its stack allocation and arena bookkeeping are replaced by local stubs.
It checks exact selected IDs and order, including coincident/tied points, saturated
distance caches and 4096 candidates. Separate `compare.py` tests exercise the
actual full MuJoCo engine and real flex models. `benchmark.py --baseline PATH`
compares a previous Ada executable on the common <=50-contact domain; larger
cases were rejected by that version and have no old-Ada timing baseline.

Mobile-only performance fixtures use native C Newton with warm-start and islands
enabled, AVX and LTO retained, 100 iterations and tolerance `1e-12`. Numerical
reference tests separately retain PGS and disabled islands/warm-start, including
the documented penetrating-pin C case. Timed Newton trajectories are also checked
against SPARK, not inferred from the PGS tests.
