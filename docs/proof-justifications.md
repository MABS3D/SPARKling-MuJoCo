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
