# Proof justifications

One bullet per `pragma Annotate (GNATprove, ...)` in `src/`, in the form
`- <unit>:<subprogram>: <kind> — <why the tool cannot prove it and why it is true>`.
`prove.ps1` fails when the number of pragmas and bullets differ.

The annotations below only hide expression-function definitions in callers.
They add no assumptions and suppress no verification conditions. The callees'
contracts and the predicate bodies remain subject to separate verification.
Expanding the whole-model predicates in the loader's composition procedures
produced a 36 MB translation for Parse; the combined run exceeded 900 seconds
with a peak process-group RSS of 3.7 GB (2026-09-22, GNATprove 16.1.0).

- MJ.MJB:Parse: Hide_Info Is_Valid — Parse obtains this exact predicate from Validate's postcondition; expanding all validation clauses is unnecessary for composition and overwhelms proof-context generation.
- MJ.MJB:Parse: Hide_Info Valid_Layout — Parse obtains this exact predicate from Parse_Raw and Validate; no array layout is inspected directly in this procedure.
- MJ.MJB:Parse: Hide_Info All_Null — Parse obtains the failure predicate from Parse_Raw or Free, and does not update individual Model components.
- MJ.MJB:Load: Hide_Info Is_Valid — Load obtains this exact predicate from Parse's postcondition; its internal clauses are irrelevant to file input and buffer cleanup.
- MJ.MJB:Load: Hide_Info Valid_Layout — Load obtains the layout predicate from Parse and never alters the model afterwards.
- MJ.MJB:Load: Hide_Info All_Null — Load preserves the predicate on input failure, otherwise obtains it from Parse; freeing the byte buffer cannot modify the model.
- MJ.Validation:Validate: Hide_Info Is_Valid — The OK branch tests this exact predicate and never modifies the model afterwards. Expanding its definition generated a 34 MB proof context and unresolved split postconditions; the definition remains verified in MJ.Models.Validity.
- MJ.Validation:Validate: Hide_Info Valid_Layout — The public precondition and Compute_Caps postcondition supply this exact predicate; Validate does not inspect or mutate array components. This removes proof facts without removing obligations.
- MJ.Validation:Diagnose_Refs: Hide_Info Refs_OK — The generated diagnostic returns OK only after testing this exact predicate. It returns early from chunk scans only for errors and otherwise ends with a non-OK fallback. The predicate and every element clause are proved separately.
- MJ.Validation:Diagnose_Reals: Hide_Info Reals_In_Tier0 — The generated diagnostic tests this exact predicate before returning OK. Chunk scans locate the first error; their OK result continues scanning, and the final fallback is non-OK. The quantified definition is unnecessary for this composition.
- MJ.Validation:Diagnose_Bools: Hide_Info Bools_OK — The generated diagnostic tests this exact predicate before returning OK. Chunk scan errors return immediately and the fallthrough is non-OK. The predicate's own safety obligations remain in MJ.Models.Gen_Clauses.

Reference: [SPARK User's Guide — pruning the proof context](https://docs.adacore.com/spark2014-docs/html/ug/en/appendix/additional_annotate_pragmas.html#pruning-the-proof-context-on-a-case-by-case-basis).

- MJ.Models.Gen_Clauses:Reals_In_Tier0: Hide_Info Real_Values_In_Tier0 — The array helper proves its own bounded-value scan. The model composition only needs to dereference arrays supplied by Valid_Layout; expanding a quantifier for every field exceeded the 4 GB process-group cap.
- MJ.Models.Gen_Clauses:Reals_In_Tier0: Hide_Info Real_Values_In_Tier1 — The same independent array scan is used for bounding boxes. The caller still evaluates its exact result, and the helper body is proved separately without suppressing checks.
- MJ.Models.Gen_Clauses:Bools_OK: Hide_Info Boolean_Values_OK — The byte-array predicate is proved separately. The model composition checks its array dereferences and combines the exact Boolean results without expanding unrelated quantifiers.

- MJ.Validation:Compute_Caps: Hide_Info Jacobian_Capacity — The implementation and Caps_OK use this same pure function with the same bounded arguments. Its saturated multiplication is proved separately; hiding its arithmetic definition keeps unrelated model and loop checks free of nonlinear quantified facts.

- MJ.Validation:Compute_Caps: Hide_Info Has_Positive — The computed adhesion flag and Adhesion_OK use the same pure predicate over the same unchanged arrays. Its quantified definition is proved separately and is unnecessary when composing these equal terms.

- MJ.Validation:Diagnose_Blocks: Hide_Info Block_At — Each loop tests this exact predicate before extending its invariant. Its bounds and ownership checks are proved in MJ.Models.Validity; expanding them during induction obscures preservation of earlier unchanged elements.
- MJ.Validation:Diagnose_Blocks: Hide_Info Covered_At — The second loop tests this exact predicate and retains the earlier Boolean results over unchanged arrays. Its safety precondition still requires the already established Blocks_OK, and its body is proved separately.

- MJ.Validation:Diagnose_Tree: Hide_Info Parent_At — The loop tests the predicate before extending its invariant; Parents_OK combines the same predicate. Its body is verified independently.
- MJ.Validation:Diagnose_Tree: Hide_Info Root_At — The loop composes exact Boolean results over unchanged arrays. Parents_OK required by its contract is still established first; the root traversal is proved separately.
- MJ.Validation:Diagnose_Tree: Hide_Info Weld_At — The loop and Welds_OK use the same element predicate; earlier family preconditions remain checked, while weld indexing is proved in its own body.
- MJ.Validation:Diagnose_Tree: Hide_Info Dof_Tree_At — The loop establishes all element results; the procedure separately checks the first/last dof conditions needed by Dof_Trees_OK.
- MJ.Validation:Diagnose_Tree: Hide_Info Body_Tree_At — The loop establishes this exact predicate for every body, without needing the definition for induction. Its local bounds are proved separately.
- MJ.Validation:Diagnose_Tree: Hide_Info Tree_Body_Range_At — The loop tests this predicate for every tree. Its quantified range checks are proved independently and are unnecessary to preserve earlier results.
- MJ.Validation:Diagnose_Tree: Hide_Info Body_In_Tree_At — The final body loop preserves exact predicate results over unchanged arrays; Body_Trees_OK composes the same results, and the element body's arithmetic remains separately proved.
- MJ.Validation:Diagnose_Tree: Hide_Info Owners_Sorted — Diagnose_Blocks supplies this exact array predicate; the body/joint/dof/tree family clauses combine it unchanged, without inspecting its element-level meaning here.
- MJ.Validation:Diagnose_Tree: Hide_Info Blocks_OK — Each successful Diagnose_Blocks call establishes this exact predicate over unchanged arrays. The family postconditions use the same term and its body remains proved separately.
- MJ.Validation:Diagnose_Tree: Hide_Info Covered_OK — The coverage predicate is obtained from Diagnose_Blocks and composed into family postconditions; no coverage definition is required for this caller's direct indexing.

## Generated reference composition

When proving `Refs_OK`, only the element predicates' preconditions are needed:
`Valid_Layout` supplies the array shapes and each quantifier supplies its index.
Their Boolean definitions add irrelevant quantified facts and caused very large
solver contexts. The following annotations hide those definitions only while
proving `Refs_OK`. Every element body is still proved in the same unit, and its
definition remains available to semantic validators in other proof contexts.
These annotations are generated from the reference table.

- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Parentid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Rootid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Weldid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Mocapid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Jntadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Dofadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Geomadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Bvhadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Body_Plugin_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Jnt_Qposadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Jnt_Dofadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Jnt_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Dof_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Dof_Jntid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Dof_Parentid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Dof_Madr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tree_Bodyadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tree_Dofadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Geom_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Geom_Matid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Site_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Site_Matid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Cam_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Cam_Targetbodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Light_Bodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Light_Targetbodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Vertadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Normaladr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Texcoordadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Faceadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Bvhadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Graphadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Polyadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Polyvertadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Polymapadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Vertadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Edgeadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Elemadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Evpairadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Texcoordadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Elemdataadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Elemedgeadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Shelldataadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Edge_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Elem_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Elemedge_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Shell_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Flex_Bvhadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Matid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Vertadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Texcoordadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Faceadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Boneadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Bonevertadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Bonebodyid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Bonevertid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Pair_Geom1_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Pair_Geom2_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Actuator_Plugin_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Actuator_Actadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Actuator_Ctrladr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Actuator_Outadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Sensor_Plugin_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Plugin_Stateadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Plugin_Attradr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tendon_Adr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tendon_Matid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tendon_Treeid_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Numeric_Adr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Text_Adr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tuple_Adr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Bodyadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Jntadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Geomadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Siteadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Camadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Lightadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Meshadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Skinadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Hfieldadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Texadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Matadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Pairadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Excludeadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Eqadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Tendonadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Actuatoradr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Sensoradr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Numericadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Textadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Tupleadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Name_Keyadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Hfield_Pathadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Mesh_Pathadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Skin_Pathadr_At — reference composition rationale above.
- MJ.Models.Gen_Clauses:Refs_OK: Hide_Info Ref_Tex_Pathadr_At — reference composition rationale above.

## Whole-model validity composition

Is_Valid only calls clause predicates and combines their results. Every callee
precondition is the input Valid_Layout or an earlier clause in the same chain.
The following local annotations hide clause definitions for this composition;
they do not hide any clause body from its own proof or from other callers.
Hiding Valid_Layout also avoids importing hundreds of array facts unused here.

- MJ.Models.Validity:Is_Valid: Hide_Info Sizes_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Refs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Bools_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Reals_In_Tier0 — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Parents_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Roots_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Welds_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Body_Joints_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Body_Dofs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Body_Geoms_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Dof_Trees_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Tree_Dofs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Body_Trees_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Jnt_Types_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Jnt_Adrs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Dof_Joints_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Dof_Parents_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Dof_Parent_Ranges_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Madr_Range_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Madrs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Simplenums_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sparse_M_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sparse_B_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sparse_D_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sparse_Ten_J_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info M_Rownnz_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info M_Rows_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info D_Diags_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Maps_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Geom_Types_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Geom_Datas_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sameframes_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Meshes_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Hfields_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Textures_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Texids_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Bvhs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Octs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Pairs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Excludes_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Eq_Types_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Eq_Objs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Wraps_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Tendons_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Actuator_Types_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Actuator_Trnids_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Actuator_Acts_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Actuator_Ranges_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sensor_Types_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sensor_Objs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sensor_Dims_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Sensor_Adrs_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Tuples_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Names_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Paths_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Option_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Stat_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Body_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Jnt_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Geom_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Dof_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Tendon_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Actuator_Params_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Caps_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Adhesion_OK — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.
- MJ.Models.Validity:Is_Valid: Hide_Info Valid_Layout — whole-model composition rationale above; the exact required predicates remain available from the input and preceding clauses.

## Diagnostic layout composition

Repeated calls to predicates previously expanded the full model layout into
hundreds of precondition checks at each loop iteration. The proved ghost
procedure Reveal_Layout exposes the individual array-group shapes at explicit
proof boundaries, including the tree-block call after its loop. It
has a null body and its postcondition is proved from Valid_Layout; it is not
an assumption. The following local annotations keep Valid_Layout opaque at
subsequent calls, while array accesses use those proved shape facts.

- MJ.Validation:Diagnose_Tree: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose_Joints: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose_Sparse: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose_Assets: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose_Objects: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose_Params: Hide_Info Valid_Layout — the proved Reveal_Layout lemma supplies the array facts, and the input predicate remains available unchanged for callee preconditions.
- MJ.Validation:Diagnose: Hide_Info Valid_Layout — this composition accesses only size fields and chains the exact contracts; it needs no array-layout expansion.
- MJ.Validation:Diagnose: Hide_Info Is_Valid — this failure-only diagnostic returns a non-OK result on every path without relying on the definition of the input failure predicate.

## Degree-of-freedom tree diagnostic

Diagnose_Dof_Trees extracts the unchanged dof/tree checks from Diagnose_Tree,
so their array obligations are proved in a smaller control-flow context. Its
postcondition is proved from the loops and Diagnose_Blocks, then composed by
Diagnose_Tree. The ghost Reveal_Layout supplies the required array shapes.

- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Valid_Layout — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.
- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Sizes_OK — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.
- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Dof_Tree_At — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.
- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Owners_Sorted — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.
- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Blocks_OK — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.
- MJ.Validation:Diagnose_Dof_Trees: Hide_Info Covered_OK — use the exact input predicate or results of the checked scans; array access uses the proved layout projection, and leaf predicate bodies retain their separate proofs.

The dof-tree block call follows an Assert_And_Cut that preserves the input
layout, size predicate, checked dof-tree predicate, and positive tree counts.
GNATprove must prove this assertion before using it to discard earlier branch
paths. Assert_And_Cut has runtime policy Ignore, as the loop invariants do;
this policy does not suppress its proof obligations. See the
[SPARK assertion documentation](https://docs.adacore.com/spark2014-docs/html/ug/en/source/assertion_pragmas.html#pragma-assert-and-cut).

## Joint diagnostic stages

Diagnose_Joints checks each family predicate before scanning that failing
family for its first element. Only the path where all exact predicates pass
returns OK. Each failing stage returns a non-OK fallback after its scan, so
its loops need not reconstruct quantified success postconditions. This is
the same pattern used by the generated diagnostics. Widened final address
sums preserve the existing status/field order without importing leaf bodies.
Jnt_Types_OK stays visible for the width-function input bounds.

- MJ.Validation:Diagnose_Joints: Hide_Info Jnt_Adrs_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Dof_Joints_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Dof_Parents_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Dof_Parent_Ranges_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Madr_Range_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Madrs_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Simplenums_OK — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Jnt_Adr_At — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Dof_Joint_At — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Dof_Parent_At — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.
- MJ.Validation:Diagnose_Joints: Hide_Info Madr_At — joint diagnostic stage rationale above; the checked family results establish subsequent preconditions and the success postcondition, while each predicate body is proved separately.

Diagnostic stage rationale: sparse, asset, object and parameter diagnostics
check each complete family before entering its error scan. A failed
family always produces a non-OK result, including a conservative fallback;
only the path that passes every exact family predicate returns OK.
This preserves error order and avoids induction across unrelated model
families. Local guards protect indirect map indexing in failure scans.

- MJ.Validation:Diagnose_Sparse: Hide_Info Sparse_M_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Sparse_B_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Sparse_D_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Sparse_Ten_J_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info M_Rownnz_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info M_Rows_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info D_Diags_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Maps_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Madr_Range_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Dof_Parent_Ranges_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info Madrs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info M_Row_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Sparse: Hide_Info D_Diag_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Geom_Types_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Geom_Datas_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Sameframes_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Meshes_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Hfields_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Textures_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Texids_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Bvhs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Geom_Type_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Geom_Data_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Mesh_Faces_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Mesh_Polys_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Mesh_Graph_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Hfield_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Texture_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Body_Bvh_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Mesh_Bvh_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Assets: Hide_Info Octs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Pairs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Excludes_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Eq_Types_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Eq_Objs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Wraps_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Tendons_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Types_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Trnids_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Acts_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Ranges_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Types_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Objs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Dims_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Adrs_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Tuples_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Pair_Dim_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Pair_Signature_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Exclude_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Eq_Obj_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Wrap_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Tendon_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Type_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Trnid_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Act_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Control_Range_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Actuator_Range_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Type_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Obj_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sensor_Adr_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Names_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Paths_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Sizes_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Objects: Hide_Info Body_Geoms_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Body_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Jnt_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Geom_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Body_Param_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Jnt_Param_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Geom_Param_At — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Option_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Stat_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Dof_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Tendon_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Actuator_Params_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Caps_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Adhesion_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.
- MJ.Validation:Diagnose_Params: Hide_Info Jnt_Types_OK — diagnostic stage rationale below; complete family checks establish success and subsequent preconditions, while error-only scans retain the first failing field. The predicate body is proved separately.


## Reviewed reader warnings

The complete reader proof retains 133 operator-reassociation warnings for
`Base + fixed_offset + element_offset`. Both offsets are nonnegative constants
from the generated layout, and their sum plus the access width fits the fixed
block. Each reader's proved precondition bounds `Base + block_size` by
`B'Length <= Natural'Last`. Therefore every intermediate sum fits under either
association. These warnings remain visible and are counted separately from
unproved obligations. Three unused-initial-value warnings refer to the integer
and byte array readers: they overwrite every element without an early return;
the input element contents are intentionally unused. The array bounds are used.


Six remaining validation warnings concern four Int64 loop-count invariants
and two associations of the capacity sum. With Natural indexes,
`I - First + 1` has Int64 intermediates with absolute value at most 2**31
under reassociation, and multiplication by at most six fits Int64. For capacities, the
proved helper bounds and layout imply Ne <= 6*Max_Size, Nf <= 2*Max_Size,
Nl <= 4*Max_Size, and Contact <= Max_Cap. All terms are nonnegative. Thus
any association of `Ne + Nf + Nl + 10*Contact` is at most 1,778,384,874,
well below Int64'Last. These warnings are retained and counted separately.

- MJ.Models.Validity:Is_Valid: Hide_Info Site_Datas_OK — The conjunction composes this exact site-mesh reference predicate, which is proved independently under Valid_Layout. No condition is assumed or suppressed.
- MJ.Validation:Diagnose_Assets: Hide_Info Site_Datas_OK — The diagnostic tests this exact predicate before returning OK and otherwise reports a failing site or a non-OK fallback. The element predicate is proved independently.
- MJ.Validation:Diagnose_Assets: Hide_Info Site_Data_At — The diagnostic scans the unchanged sites for an exact failing predicate. Its body and index precondition are proved independently; hiding the body follows the existing geometry element pattern and adds no assumptions.

## Dense matrix optimization proof composition

- MJ.Matrix_Models:Unfold_Product_Row: Hide_Info Product_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrix_Models:Unfold_Vector_Row: Hide_Info Vector_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrix_Models:Unfold_Gram_Row: Hide_Info Gram_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Prove_Product_Cell: Hide_Info Product_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Product_Step: Hide_Info Product_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Transposed_Sweep: Hide_Info Product_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:MulMatMatT: Hide_Info MJ.Vector_Models.Dot_Value — The loop uses the separately proved row-dot component contract, including the four ordered lanes and tail. Hiding the model expression avoids expanding recursive vector reductions at each matrix cell; no property is assumed or suppressed.
- MJ.Matrices:Prove_Gram_Cell: Hide_Info Gram_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Gram_Step: Hide_Info Gram_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Gram_Sweep: Hide_Info Gram_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Skip_Zero_Weight: Hide_Info Gram_Prefix — The separately proved entry-unfold lemma connects the ordered floating-point prefix with one update. Cell and row contracts compose that exact equality and its bounds; hiding the prefix expression avoids expanding array projections and recursive reductions in the outer proof. No property is assumed or suppressed.
- MJ.Matrices:Advance_Gram: Hide_Info Gram_Prefix — The zero-weight branch uses the proved immutable-prefix lemma; the other branch uses the proved Gram sweep. Both establish the same next-prefix contract and bounds, without changing the floating-point operation order.
- MJ.Matrices:Complete_Gram_Prefix: Hide_Info Gram_Prefix — Complete_Gram_Cell proves the exact full-prefix/component identity. The ghost traversal instantiates that identity for the lower triangle and the zero upper triangle. Only the already proved prefix expression is hidden; the final component relation and bounds are verified.
- MJ.Matrices:SqrMatTD: Hide_Info Gram_Prefix — The proved initialization and completion lemmas connect zero/full prefixes to the public component model. Advance_Gram preserves the exact next prefix and bounds. The final Assert_And_Cut checks are proved, retaining the output relation and tier bound while discarding irrelevant intermediate context; no assumption is added.
- MJ.Matrices:Rows_Dot: Hide_Info MJ.Vector_Models.Dot_Value — Unfold_Dot establishes the exact four-lane/tail model. Proved zero-tail and scalar combination lemmas discharge each branch. Only recursive expression expansion is hidden; all contracts and branches are proved. Matrix projections stay inside ghost lemma bodies to avoid residual secondary-stack setup in release callers.

## Independent column updates (2026-09-23)

`Accumulate_Row` and the numeric inner loop of
`Gram_Update_Row` use `Loop_Optimize (Ivdep, Vector)`. For distinct iteration
indices J and K, the written elements R(Target,J)/R(Target,K) or
R(I,J)/R(I,K) are distinct. Each iteration reads only its own old output element,
the read-only input array, and scalar parameters. SPARK anti-aliasing rules
exclude overlap between writable output and input arrays; that restriction is
also documented in the matrix API. Thus no iteration reads another iteration's
write. The dependent outer source loop is unchanged and has no Ivdep hint.

GNATprove ignores these compiler pragmas: the scalar safety, bound, frame and
functional proofs are still required and pass. The independence justification
above is a structural code-generation review, not a claim that GNATprove checks
Ivdep. The supported calling domain continues to require SPARK's non-overlap
rules. Release differential checks and inspection of the generated code are
separate evidence; floating-point contraction remains disabled.

## Short-row matrix product (2026-09-24)

- MJ.Matrices:MulMatMatT_Short: Hide_Info MJ.Vector_Models.Dot_Value — Rows_Dot_Short (widths zero through three) and Rows_Dot (width four) separately prove exact equality to Dot_Value. MatT_Component has the same proved model contract. The traversal composes these two equalities with separately proved initialization, bounds and frame invariants. Hiding only the recursive expression prevents repeated expansion of row projections and the four-lane model in quantified loop obligations; it introduces no assumed property or trusted body. The short scalar body, full traversal and public dispatcher are all required to pass independently.

The short cell loop uses No_Vector while each width-four dot retains its vector lanes. MulMatMatT requests Inline_Always to retain specialization of caller bounds. MulMatVec and MulVecMatVec keep their preceding implementation and inlining policy. Rows_Blocks updates two consecutive blocks per lane, followed by one remaining block when needed; the exact Lane_Sum invariant preserves every lane recurrence. These code-generation choices add no mathematical assumption.

MulMatMatT returns immediately when either output axis is empty. Its full initialization and component postconditions are vacuous for this empty output, and are required to be proved at that return. The fast path introduces no assumption.

- MJ.Poses:Compose: Hide_Info Model.Normalized — The private Normalize wrapper proves the complete tiny/near-unit/scaling relation against the ghost model. Compose applies that proved relation to the value-returning quaternion Product, whose exact ordered component contract is separately proved. Only expansion of the ghost normalization expression is hidden; no runtime body, obligation or property is suppressed or assumed.

- MJ.Poses:Transform: Hide_Info MJ.Quaternions.Model.Rotation_Intermediate — The private Intermediate cell proves equality to this ghost function for each axis. Complete_Transform separately proves the ordered rotation-and-translation expression. The Transform proof composes these proved relations and bounds without expanding the intermediate arithmetic again. The quaternion ghost model body remains covered by the complete quaternion proof; no body is skipped and no property is assumed.

## Transpose dispatch (2026-09-24)

Transpose exposes Relaxed_Initialization together with a proved static
R'Initialized postcondition; its ordinary executable component-equality
postcondition remains in place. An empty axis returns immediately, where both
properties are vacuous. Separate helpers for one through five input rows,
paired copies for six through fifteen rows, and the two general copy loops
all prove complete initialization and R(i,j) = A(j,i). Prefix invariants include
initialization before reading each written component; the odd-row tail is
proved separately from the pairs.

No_Vector on short copies and Vector on the inner loop for square dimensions
16 and 64 are code-generation hints ignored by GNATprove. The latter loop
has the same scalar body as the unrestricted general core; dispatch thresholds
do not restrict the public input domain. Each write reads only the distinct
input object under SPARK's existing anti-aliasing rules. These choices add no
assumption, suppression, trusted body, or floating-point reassociation. The
performance evidence records their target-specific effect separately from the
functional proof.
