# Positive nodal endpoints and initial dynamics admission

Reference: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. This document describes an
integration contract, not completed nodal movement support.

`MJ.Flex_State.Nodal_Contacts.Weights` reads the owned state, a flex index,
up to four vertex indices and signed vertex coefficients, and produces a separate
`MJ.Flex_Node_Weights.Endpoint` with capacity 27. It returns an empty endpoint on
failure. A zero input count returns an empty successful endpoint for an admitted
nodal flex; inactive vertex indices are not read. Ordinary flexes are explicitly
unsupported by this nodal API and must retain their existing producer in a mixed
simulation. The adapter does not retain model pointers or require current world
positions: body weights use compiled parametric coordinates.

The kernel uses the sign of the first coefficient, accumulates parametric
coordinates with absolute coefficients, evaluates the array basis, drops basis
values below `1e-5` (including negative values), and merges repeated body IDs in
first-occurrence order. It does not renormalize. Duplicate merging happens inside
each endpoint; the two endpoint lists must not be merged together. The Jacobian
and diagonal inverse-weight producer have different sign usage. For diagApprox,
the C driver accumulates inverse body weights linearly with positive endpoint
weights, rather than their squares. Do not map the result into the existing
four-body endpoint.

## First zero-elasticity domain

For each flex whose interpolation is positive, the initial integration should
check these compiled MJB fields independently of spring/damper enable flags:

| Field | Initial admitted value | C use |
|---|---|---|
| `flex_interp[f]` | 1 or 2 | `engine_passive.c:96`; negative order selects shell/TFI |
| `flex_stiffnessadr[f]` | -1 | Nodal stretch returns before reading K at `engine_passive.c:88–91`; implicit derivative also returns at `engine_derivative.c:1311–1313` |
| `flex_bendingadr[f]` | -1 | Shell bending block at `engine_passive.c:273–281`; positive order already returns at 269–271 |
| `flex_damping[f]` | 0 | Nodal Rayleigh force at `engine_passive.c:210`; derivative scale at `engine_derivative.c:1328–1329` |
| `flex_edgestiffness[f]` | 0 | Separate edge force loop at `engine_passive.c:794–817`, not excluded by positive interpolation |
| `flex_edgedamping[f]` | 0 | Same independent edge force loop |
| `flex_edgeequality[f]` | 0 | Strain equality changes stretch gating at `engine_passive.c:116`; ordinary edge-Jacobian selection at `engine_core_smooth.c:705–708` |
| `eq_type[id]`, `eq_obj1id[id]` | No FLEX/FLEXVERT/FLEXSTRAIN equality referencing this flex | Equality row families at `engine_core_smooth.c:2636–2672`; reject even initially inactive entries until activation is supported |

The address=-1 checks are a deliberately strict initial domain. C can also return
without force for an allocated stiffness block with first value zero. That wider
case is not required by the first domain. To admit a genuinely all-zero allocated
positive-order stiffness block later, validate its entire range using the nodal
layout: `cells_x*cells_y*cells_z * (3*(order+1)^3)^2` entries, then check every
coefficient. The ordinary layout of 21 values per simplex is not applicable to
nodal interpolation. Do not infer no stiffness from absent XML `young` or from
interpolation alone. Positive interpolation never enters shell bending in this
reference; the additional bending-address rejection makes the first policy
explicit rather than silently accepting an unimplemented block format.

These checks apply per interpolated flex. Global `nflexstiffness=0`,
`nflexbending=0`, `nefm0dof=0` or removal of every flex would incorrectly exclude or
ignore supported ordinary flexes in a mixed model. Ordinary force/cache/equality
processing must still execute, in original flex order and with original IDs.
The compiler's EFM bending factor is built only for non-interpolated, nonrigid
flexes (`user_model.cc:2080–2150`); its existing support remains a separate
ordinary-flex concern. The new admission must not relax unrelated core model,
body/DOF, integrator, force or contact restrictions.

## Evidence scope

Kernel weights5: 1548/1548 bitwise C cases in validation and release, 116 proof
and 18 flow obligations closed, one retained warning. Endpoint3: 816/816 cases
per profile on 12 compiled mixed ordinary+nodal models, byte-identical outputs;
49 proof and 9 flow obligations closed, zero open, four retained warnings. The
proved contract covers rejection with an empty result, body-reference validity
and runtime safety under the called contracts; the exact fold contract belongs
to the kernel. Full FS state composition and mixed
movement and all force/equality admission rejections still require integration
receipts. No performance claim is made.

## Separate shell expansion under development

`MJ.Flex_Shell_Weights` is a separate candidate at this checkpoint. It
does not change positive-order admission, the verified 27-entry endpoint, or
the dynamics caller. Its endpoint has capacity 729 and its 26 TFI terms follow
`mju_shellTFIWeights`: six face terms, twelve negative edge terms, and eight
corner terms, in the original order. Zero and signed coefficients are retained;
the basis cutoff belongs before this expansion. Repeated body identifiers update
the first existing entry, including when the input endpoint already contains
duplicates. No final renormalization or sum-to-one property is asserted.

The candidate's `Generate` contract specifies each term's body and floating
coefficient. `Merge` specifies the first match, exact floating addition and the
unaffected-array frame. `Accumulate` specifies an ordered ghost fold whose body
also requires proof. Frozen kernel5 passes **336/336 bitwise cases in both
profiles**, including a full 729-entry result, against the unchanged official
shared library. All fourteen minima and the complete unit proof close on the
same sources: **299 proof + 28 flow obligations, zero open**, with four retained
warnings (recursive contracts and three integer operator-reassociation notices). Validation/release inputs and outputs are identical.
The functional scope is the ordered floating-point algorithm under explicit
bounds; real-arithmetic accuracy, FS admission, and dynamics remain separate.
Earlier failures and their complete reports are retained as kernel1–4 evidence.

Shell geometry needs a separate position reconstruction. The C
`mju_shellTrackInterior` first adds three grouped face pairs, then subtracts
twelve edge contributions and adds eight corners. Applying the flattened body
weight list to positions changes that floating evaluation order and is not an
equivalent implementation. The FS adapter must preserve rejected-update
atomicity, the ordinary-flex route, and an explicit distinction between signed
shell order and positive nodal order before the new endpoint can be connected.

The positive adapter's coefficient bound cannot simply be copied to shells.
At the central node of a 3x3x3 grid, assign all six face nodes and eight corners
to one body and all twelve edge nodes to another. For unit input weight the C
formula yields +4 and -3. This example now matches the native function bit for
bit in both profiles. Shell diagonal inverse-weight accumulation also keeps the
signed linear coefficients (`engine_core_constraint.c:1923–1924`); replacing
them with absolute values or squares would change the reference algorithm.


The separate `MJ.Flex_Shell_Geometry` geometry2 snapshot now closes 259 proof
and 22 flow checks (two retained warnings), with 216/216 bitwise native C cases
in each profile. It reconstructs a requested interior node from the boundary
stencil and proves the ordered floating-point fold. Whole FS and dynamics are
not included. The draft signed-order FS hook lives outside the source directories
under `integration/shell-state`; it has not changed the live admission policy.


`MJ.Flex_Shell_Node_Weights` kernel7 composes the existing lookup/basis with
interior TFI expansion. The cutoff is applied before expansion, and signed terms
are merged in C order with no renormalization. Its complete proof closes 206
proof and 22 flow checks, with four retained warnings; 1,262 bitwise cases pass
in each profile (up to 82 distinct output bodies in this corpus). Capacity 729
is tested separately in the low-level expansion.

The owned Shell_Contacts endpoint2 adapter is separately frozen under
`integration/shell-endpoint`. Its complete proof closes 59 proof and 11 flow
checks, zero open, with seven retained warnings (two recursive-contract notices
and five reassociation notices from dependencies). Validation and release each
pass 3,228 bitwise shell endpoint cases, 816 positive endpoint regressions, and
14 loading-admission checks per negative order. Replaying the accepted geometric
state fixtures reproduces all 141 records / 936 samples byte for byte in both
profiles. FS/adapter flow closes 102 checks with 19 retained warnings; whole FS
proof remains open. See the separate delivery manifest for the exact frozen
sources, cross-API rejection receipts, and renewed positive adapter proof.

This is an owned geometric state and endpoint checkpoint, without shell
Jacobians, forces, integration or performance results. FS live has not changed.
The signed 729-entry result must not be connected to the positive 27-entry or
ordinary four-entry solver interface. The endpoint proof covers failure output,
body validity and safety; the ordered functional fold remains a property of the
dedicated kernels, not a universal C-equivalence assertion for FS.
