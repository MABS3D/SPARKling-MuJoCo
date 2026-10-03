# Geometry proof context

Expression bodies are opened only at the layer that needs their definition.
These annotations introduce no assumption, suppression or skipped body. The
complete-unit proof includes every model, scalar implementation and vector
constructor. Evaluation order and quaternion signs are unchanged.

The executable vector constructors have explicit contracts for **every output
component**, in addition to bounds. Their scalar callees specify the ordered
floating-point formula down to multiplication. Higher-level models compose these
specified operations; they do not use a bound-only specification or the function
whose result they specify.

- Conjugate: Hide_Info — a pure component-wise constructor shared by executable and model compositions; its body and bounds are checked separately.
- Angular_Difference: Hide_Info — the three specified subtractions are composed unchanged in Weld and its matrix specification; their bounds are checked separately.
- Quaternion_Product_Value: Hide_Info — exposes the exact Product_At relation for every component and conditional bounds. Its aggregate body is checked independently, without expansion at every rotation invariant.
- Axis_Product_Value: Hide_Info — exposes the exact Axis_At relation for every component and bounds. Its body is checked independently.
- Model.Product: Hide_Info — this scalar-component reference is opened when verifying the Multiply wrapper.
- Model.Axis_Product: Hide_Info — this scalar-component reference is opened when verifying the Multiply_Axis wrapper.
- Model.Position: Hide_Info — Weld copies the component values supplied by Rotation_Position; quaternion arithmetic is irrelevant to initialization/frame induction.
- Model.Jacobian: Hide_Info — Weld copies the component values supplied by Rotation_Jacobian and preserves preceding columns; expansion at every invariant exhausted the diagnostic watchdog.
- Multiply: Unhide_Info Model.Product — checks the wrapper against the exact scalar-component reference.
- Multiply_Axis: Unhide_Info Model.Axis_Product — checks the wrapper against the exact scalar-component reference.
- Rotation_Position: Unhide_Info Model.Position — composes Quaternion_Product_Value and the exact Position_Scale relation.
- Rotation_Jacobian: Unhide_Info Model.Jacobian — composes Axis_Product_Value, Quaternion_Product_Value and the exact Jacobian_Scale relation.
- Model.Column_Jacobian: Hide_Info — names the specified angular difference of one matrix column before the quaternion composition. Its body is separately proved; this changes no formula.
- Rotation_Column: Unhide_Info Model.Column_Jacobian — proves the executable column wrapper against that exact definition (22checks in r57).

The current Weld diagnostic also names its expected angular matrix as a
`Ghost => Static` constant. This is proof-only data and is not a runtime
preparation scan. Static ghost entities are always ignored at runtime under
[SPARK RM11.4](https://docs.adacore.com/spark2014-docs/html/lrm/exceptions.html).
This witness has not yet closed the preservation obligation and is not proof
evidence by itself.

Reference: [SPARK User's Guide — pruning the proof context](https://docs.adacore.com/spark2014-docs/html/ug/en/appendix/additional_annotate_pragmas.html#pruning-the-proof-context-on-a-case-by-case-basis).
