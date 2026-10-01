# Elastic and contact materials candidate

Isolated implementation of the material laws requested on 2026-09-30.
Reference: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
Existing loader, model storage, collision pipeline and simulation step are not
changed by this candidate. Both modules use `MJ.Types.Real` (binary64), fixed
size arrays and no heap allocation.

## Elasticity

`MJ.Elastic_Materials` implements:

- Young's modulus, Poisson ratio, thickness and Rayleigh damping.
- Shear modulus and the separately associated Lamé expressions used by C for
  simplices and interpolated solids; plane-stress Lamé coefficient for
  interpolated membranes; bending modulus `E*t^3/(12*(1-nu^2))`.
- Material-weighted element metrics from supplied strain bases and signed
  area/volume. The simplex formula uses `abs(measure)/4`; triangle thickness is
  supplied, tetrahedron thickness is the C default 4. The plane-stress
  coefficient belongs to the separate interpolated-membrane formulation and
  is deliberately not substituted into the simplex compiler.
- Ordered tensor contraction and packed upper-triangular assembly: six entries
  for three triangle edges, twenty-one for six tetrahedron edges. Triangle
  padding in the 21-entry output is zero, matching `flex_stiffness` storage.
- Squared-length spring elongation and the cancellation-resistant damper
  expression `dL*(2*L-dL)*kD`, with `dL=velocity*h` and `kD=rayleigh/h`.

The geometry phase must provide the same ordered strain bases as C. This
candidate does not compute those bases, assemble interpolated flex matrices,
project elastic forces to vertices/DOFs or implement bending-flap forces.
It supplies the material coefficients and simplex metric compiler needed by
those phases. Geometry from C is used as input in the actual compiled-flex
comparison; material assembly itself runs in Ada.

Domain: `0 <= E <= 1e15`, `0 <= nu < 0.5` (including the nearest binary64
value below 0.5), thickness and damping in `[0,1e10]`, signed area/volume in
`[-1e30,1e30]`, basis entries in `[-1e10,1e10]`. Timestep is zero or
`1e-15 <= h <= 1`. Zero thickness/measure are permitted by the algebra API;
the eventual model compiler must retain C's validation for physical models,
including positive membrane thickness. NaN, infinity and values outside
these typed domains are not supported inputs.

## Contact properties

`MJ.Contact_Materials` implements C's parameter selection and assignment:

- Priority selection; equal-priority `solmix` weighting with the `1e-15`
  threshold; maximum contact dimension; maximum surface friction.
- Weighted positive-time-constant `solref`, component-wise minimum when
  either reference uses the direct nonpositive format, and weighted `solimp`.
- Three surface friction values expanded to five contact values, or five
  explicit pair values, with the C `1e-5` friction floor after override.
- Explicit pair parameters, including optional `solreffriction`, margin, gap
  and adhesion; global overrides for reference, impedance, friction and margin.
- Geometry adhesion, zero flex adhesion and priority-dependent adhesion
  combination. Contacts in the gap remain active with dimension 1 if adhesive.
- Detection gap and inclusion margin; `Self_Flex` reproduces zero inclusion
  margin for the same-flex element-contact path, including enabled overrides.

`Self_Flex` identifies that specific path, not every internal flex collision
routine: C also has internal routines with fixed contact dimension. The caller
must supply correct surface identities, kinds and path metadata. Explicit
pairs require geometry/geometry; `Self_Flex` requires flex/flex.

Inputs use Tier0 bounds (`[-1e10,1e10]`, nonnegative adhesion), signed margin,
gap and `solmix`, and dimensions 1, 3, 4 or 6. Parameter assignment intentionally
does not clamp `solimp`: that happens later in the solver, as in C. There is no
independent restitution coefficient substituted for `solref`/`solimp`.
Collision detection, contact frames, Jacobians and the constraint solver are
outside this module.

## Verification and reproducibility

Current whole-unit results (2026-10-01): **126 checks** in
`MJ.Elastic_Materials` and **73 checks** in `MJ.Contact_Materials`, with complete
declared-subprogram coverage, **zero open obligations and zero warnings**.
The 2026-09-30 archive records the earlier implementation and its 182 checks;
it must not be used as the source manifest of the optimized version.

See `PERFORMANCE-20261001.md`, `results/summary-20261001.json` and
`results/evidence-20261001.zip` for
actual acceptance counts, source hashes, tool versions, commands, raw SPARK
reports and numerical inputs/outputs. Gold functional contracts specify all
packed metric entries and all composed contact fields. Scalar expression
functions specify their arithmetic association and branch behavior; each is
proved separately for safety, before whole-unit verification. Static ghost
models/postconditions disappear from the executable and add no proof scans.
`Hide_Info` only prevents expansion into callers: the corresponding expression
bodies are separately verified. No `Assume`, proof skips or application-body
trust boundary is introduced.

These claims concern the floating-point algorithm under its typed domains;
they do not establish real-arithmetic accuracy, positive-definiteness of every
material tensor, or correctness of the full flex dynamics. Differential tests
are numerical compatibility evidence, not a universal C equivalence proof.

Both checked and release executables are compared with an oracle built from
pinned C/C++ bodies and scalar statements. Their source and upstream header
hashes, the linked official MuJoCo library hash and oracle build command are
saved. Extracted scalar damping/spring statements only rename input bindings;
the arithmetic expressions are retained. The suite has 1,536 elastic and
1,536 contact algebra cases (101,376 output values), 96 contacts actually
created by `mj_collision`, and 32 `flex_stiffness` matrices compiled by the
MuJoCo XML compiler. Algebra values match bit for bit. Actual-engine contact
fields and compiled-flex coefficients match exactly. Sixty-four additional contact cases compare signed-zero ties in both references
and friction, bit for bit; nine additional domain
rejections run only with checks enabled; release relies on the caller's typed
contracts. The MuJoCo compiler emits its "no equality constraints or passive
forces" warning for the isolated flex fixtures; those diagnostics are retained
in the logs. Ada proof acceptance requires zero open checks and zero warnings.

Use fresh output directories for every run:

```sh
python3 experimental/materials-candidate/tests/check.py --phase small --out /var/tmp/material-small
python3 experimental/materials-candidate/tests/check.py --phase whole --out /var/tmp/material-whole
python3 experimental/materials-candidate/tests/check.py --phase build --out /var/tmp/material-checked
python3 experimental/materials-candidate/tests/check.py --phase build --mode release --out /var/tmp/material-release
/var/tmp/sparkling-movement-env/bin/python experimental/materials-candidate/tests/numerics.py --binary /var/tmp/material-checked/build/validation/bin/materials_probe --out /var/tmp/material-numerics-checked
/var/tmp/sparkling-movement-env/bin/python experimental/materials-candidate/tests/numerics.py --binary /var/tmp/material-release/build/release/bin/materials_probe --out /var/tmp/material-numerics-release
```

The runner uses the existing native toolchains under
`/var/tmp/sparkling-matrix-recovery/toolchains`, `tools/guarded.py`, Python
with NumPy and official `mujoco==3.14.0`, and g++ with the pinned `mujoco/`
checkout. Binary inputs are immutable copied snapshots; source changes during
checks cause failure. Numerical tests verify that the binary's source manifest
still matches the checkout. See `NOTICE.md` and `LICENSE.mujoco` for oracle
source attribution.

## Optimization on 2026-10-01

The triangle compiler spells out its six edge pairs, exposing repeated traces
and fixed contractions to the compiler. Tetrahedra retain packed iteration.
`Prepare` selects whole parameter blocks once, calculates a mixing weight only
for equal-priority ordinary contacts, computes the three surface friction
values once and writes the return object directly. Both entry points request
inlining so the compiler can optimize them in the caller.

Finite `Minimum`/`Maximum` selectors match C's comparisons and preserve its
first-operand tie choice, including signed zero. Their equivalence to Ada's
numeric min/max is proved independently. This also fixes the checked-build
signed-zero discrepancy in the old generic reference mixing expression.
Existing input domains and functional output requirements are retained.
The independent `Expected` model uses these verified scalar selectors;
it still does not call `Prepare` or `Mix`.

## Integration still required

1. Connect the model compiler to `Compile_Metric`, supplying verified ordered
   geometry bases and storing the 21 coefficients per element. Use the separate
   interpolated and bending coefficients only in their corresponding formulas.
2. Connect existing collision paths to `Prepare`, preserving pair selection,
   same-flex metadata and global option flags. Feed prepared parameters to the
   constraint solver, which must support the selected dimension and adhesion.
3. Establish calling preconditions through those phases and verify them, then
   compare force accumulation and complete simulation trajectories with C.
4. Measure an equivalent integrated release workload before making any
   performance-parity claim. The text-I/O differential probe is not a benchmark.
