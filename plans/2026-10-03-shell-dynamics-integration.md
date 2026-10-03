# Shell dynamics: caller inventory and next integration

Reference is unchanged MuJoCo 3.14.0,
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Five C sources were checked
against the commit and frozen with the three current Ada callers under
`/var/tmp/sparkling-recovery-shell-dynamics-inventory1-20261003`. This is a
read-only caller inventory, not a dynamics receipt. Endpoint2 stays immutable.

| Stage | Stable C | Existing Ada and missing work |
|---|---|---|
| Element coefficients | `engine_core_constraint.c:222`, `mj_elemBodyWeight` | `Constrained.Flex.Flex_Side` already computes inverse distance, removes the last opposite vertex, and normalizes in retained order. A new producer must retain vertex IDs/coefficient values until interpolation, instead of immediately replacing them with `Vertex_Body`. |
| Nodal/shell support | `engine_core_constraint.c:264`, `mj_vertBodyWeight` | Endpoint2 owns and verifies lookup/basis/TFI. The dynamics producer must select ordinary, positive27 or signed729 APIs per flex and preserve separate sides. |
| Sign for Jacobian | `engine_core_constraint.c:1522–1600` | C applies side0's negative sign to vertex coefficients before shell expansion and duplicate accumulation. A post-merge negation is not a proved replacement, including signed zero behavior. Build Jacobian coefficients separately from the diagonal-weight coefficients. |
| Single-body shortcut | `engine_core_constraint.c:1522–1523` | `Flex.Evaluate` currently chooses the single-body setter from the presence of vertex IDs. Interpolated vertices require the general route even when the geometric contact names one vertex. |
| Weighted storage | Parent `Weighted_Side` and setter | Four entries, nonzero weights in (0,2] cannot represent shells. A separate signed domain/storage must preserve zero terms, duplicates/order and valid geom identity, and must follow contacts during stable sorting. Do not expand the existing interface silently. |
| Jacobian support/accumulation | `engine_core_util.c:519`, `mj_jacSum`; `engine_util_sparse.c:382`, `mju_addToSparseMat` | C retains the union of body ancestor supports even when numerical terms cancel. A first present sparse term scales directly; subsequent overlaps add `old + weight*value`. Missing entries preserve the existing value. Dense mode includes every DOF and scales the first body's zero entries too. Parent `Weighted_Contact_Jacobian` handles only the four-entry metadata today. |
| Frame projection | `engine_core_constraint.c:1649` | Project the completed world Jacobian using mju_mulMatMat: start from +0 and skip zero frame coefficients, in k order. The existing scalar expression differs for signed zeros; the new Frame_Step/Project helper preserves the actual C branches. Do not project each body before accumulation. |
| Diagonal inverse weight | `engine_core_constraint.c:1875–1944` | Both sides use unsigned vertex inputs to the shell producer, then accumulate signed shell body weights linearly, in side/body order, starting from +0. Do not square or take absolute values. Existing parent consumer is four-entry-only. |
| Constraint and solver | `mj_instantiateContact`, `mj_diagApprox` | Feed the existing contact row producer with the complete support/Jacobian and diagonal. Respect condim, pyramid/ellipse, excluded/no-DOF contacts and surface velocity only for real geom endpoints. Solver comparisons must include J, aref, R, force, acceleration and trajectories on the new closure. |
| Creation/mixed flexes | `Constrained.Flex.Create` | Current factory explicitly rejects every nonzero interpolation order; FE then uses ordinary layouts. Initial zero-elasticity admission must be per flex, retain ordinary processing and reject unsupported interpolated equalities even when initially inactive. Root owns these hooks. |
| Stretch and damping | `engine_passive.c:88–237`; `engine_derivative.c:1305+` | Shell stretch uses 2D boundary faces, `(order+1)^2` nodes per face and `2*(cy*cz+cx*cz+cx*cy)` stiffness blocks, not the positive-volume or ordinary simplex layout. Corotated gather/rotate/matvec/scatter, damping, force application and implicit derivatives remain unported for this scope. |
| Shell bending | `engine_passive.c:252+` | Separate bending layout: header edge count followed by ten values per edge. Cached face geometry, normals, degeneracy branches, hemisphere-aligned quaternion average, normal residual and ordered node-force scatter all remain. C explicitly warns that interpolated shell bending damping is unsupported; do not invent a replacement. |
| Independent edge forces/equalities | `engine_passive.c:779+` and flex equality families | Nodal stretch/bending admission must also account for independent edge stiffness/damping and equality flags. No generic interpolation bypass or global Nflex reset. |

The next draft is confined to
`experimental/flex-state-integration/integration/shell-dynamics`.
`MJ.Flex_Response_Kernels` first isolates signed scalar scale/add, sparse support
preservation, ordered folding and final projection. Its seed distinguishes
first-term Jacobian scaling from diagonal accumulation into +0. Maximum 1458
terms permits two separate endpoint729 lists without truncation; this is an Ada
working capacity, not a claim that the C caller's combined array admits arbitrary
1458-body inputs. Numeric domains are explicit and require validation at the
future caller boundary. The first minimum-first proof run is response1; no
numerical or integrated receipt is claimed yet.

Next: finish these minima and full kernel proof, compare their use against
native C `mj_jacSum` and diagonal accumulation, implement a separate owned
contact-side producer preserving the sign-before-expansion rule, then supply
scoped parent/FE hooks for coordinated integration. Whole FS remains pending;
its next proof scope should isolate the shell update loop and its state-layout
invariants, without extending endpoint2's flow receipt to full proof.

Response2 closes all seven minima and whole: 50 proof + 15 flow checks, zero open, one recursive-contract warning. Numerical1 passes 23,484 native C component/support/projection checks per profile on three shell MJB models (75/78/210 DOFs). All outputs match across validation/release. The native extract compiles five unchanged C functions against the official library and each model runs in a separate process. This verifies a response building block, not integrated movement.

The next separate draft child, Response_Contacts.Side, now keeps local vertex IDs through inverse-distance normalization and applies the side sign before selecting ordinary/positive/shell conversion. Ordinary duplicates remain unmerged. It requires current owned geometry, exposes the signed729 endpoint and leaves the two geometric APIs unchanged. Initial code is not yet compiled or proved.

The current FE Material_Loading policy admits Edge_Equality only 0..2. Stable user_model.cc:3499–3515 assigns 1=FLEX, 2=FLEXVERT, 3=FLEXSTRAIN while finding the first matching recognized equality. The value3 therefore cannot be treated as unused padding or admitted merely because passive stretch is disabled: the stiffness block carries constraint eigenmodes (engine_core_util.c:1348–1351). It also excludes interpolation derivative processing at engine_derivative.c:1323 and :1758. The first zero-elasticity domain explicitly rejects it and every interpolated equality, including initially inactive entries. Separate implementation of FLEXSTRAIN is required before broadening that admission. Added source receipts in inventory2 preserve user_model.cc, engine_util_blas.c (projection behavior) and engine_core_smooth.c.

Contact-side1 minima and whole are now terminal: whole49proof+8flow, zero open, four warnings. Numeric2 (same binaries as numeric1, after correcting an unavailable Python diagnostic field) passes3,694bitwise per profile, with exact owned vertex positions and byte-identical outputs across profiles. This verifies the actual owned producer on six shell/positive/mixed models; full FS and dynamics remain open. The producer's current contract establishes empty rejection and valid body domain; its full ordered functional specification is still incomplete.

Next implementation is a separate MJ.Data.Constrained.Signed_Contacts child, which computes support, projected J and linear diagonal from separate signed Jacobian and diagonal endpoint lists. It must retain dense versus sparse support semantics and provide explicit failure on domain/capacity overflow. Root will coordinate its hook into contact sorting, assembly and admission; no FE or parent mutation is made by this draft.

Whole FS work is separate from the response child. Ready(S) currently expands only Initialized; no owned layout predicate carries the body's bounds, each active flex's vertex/element counts, local coordinate domain, node-body domain, grid/node-count relationship, element references or imported tree validity. Update consumes these facts after Create, so a successful kernel proof cannot supply them implicitly. The next minimum will isolate reconstruction of the candidate node buffer, preserving boundary nodes and bounded output on rejection. Its wrapper must then compose body poses, interpolation and deferred publication. A failure may leave candidate scratch partly updated while World/Node_World remain unchanged and Positions_Current becomes false; the contract must reflect that existing lifecycle accurately. Create/Loading must eventually establish the owned layout, instead of adding unchecked assumptions to Update.

Signed_Contacts is being composed against common r259-element-source, with endpoint2 and the separate response/contact-side modules. Its consumer requires current Ada Jacobians and validates its numeric domain; it returns a per-contact response instead of storing four729-entry lists in Engine. The common hook must move the response together with every contact insertion/sort and preserve ordinary/single-body routes. For a cross-flex contact, Opposite is -1; only same-flex contacts use the other side's vertex as the excluded corner.
