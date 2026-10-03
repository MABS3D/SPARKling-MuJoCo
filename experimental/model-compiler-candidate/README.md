# Native model compiler: address passes

This directory starts the native Ada/SPARK model compiler. **It is not a
complete MJCF/URDF compiler and does not yet produce `MJ.Models.Model` or MJB.**
The existing `tools/oracle.py` still uses the official MuJoCo compiler for test
models. No production algorithm in this candidate calls C, Python or MuJoCo.

Reference: official MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. The latest stable release API was
checked on 2026-10-02 and returned 3.14.0. The relevant upstream compiler is
primarily C++, rather than a set of C engine kernels.

## Implemented scope

`MJ.Model_Compiler.Addresses` ports the address rules in
[`mjCModel::SaveDofOffsets`](../../mujoco/src/user/user_model.cc):

- Position and velocity widths/addresses for free, ball, slide and hinge joints.
- Activation dimension precedence: computed dimension, explicit specification,
  then the dynamics-derived zero/one default.
- Independent control, output and activation blocks for actuators. This accepts
  general block widths; it does not assume one control and one output each.
- `-1` for absent control/activation blocks. An empty output block still receives
  the current output cursor, exactly as upstream.
- Consecutive mocap IDs, with `-1` for ordinary bodies.
- Body and equality ordinal IDs after their object lists have been resolved.

Input object ordering, resolved actuator widths, plugin/type validation and
geometry are supplied by the future compiler stages. In particular, testing
resolved widths from the C compiler is not evidence that their producer is ported.
Each pass uses caller-owned arrays; it performs no heap allocation. Array shape,
the 131,072-element candidate capacity, and the existing `MJ.Types.Max_Size`
limits are explicit. Rejection preserves every output and count. Actuator
streams are preflighted together before any address is published.

The contracts specify exact ordered integer prefixes, sentinels, final sizes
and failure preservation. Ghost prefix models, composition lemmas and
invariants use `Static` and do not add executable prefix scans. The two actuator
loops are an intentional capacity-preflight/publish split, during compilation;
they are not simulation-step validation scans. Both build profiles keep runtime
checks. No assumption, suppressed proof check or new trusted application body
is used to claim Gold.

The proof driver retains and separately reports two kinds of reviewed notices:
`contracts-recursive` and `numeric-variant` on the recursive ghost prefix models.
They warn about availability of contracts/model unfolding on recursive calls.
The models, their bounds and explicit reveal lemmas are themselves proof
targets; these notices do not waive their obligations. Any other warning or an
unproved check fails the evidence gate.

Final source hashes, minimal diagnostics, whole-unit coverage and checked/release
comparisons will be recorded in `evidence/2026-10-02`. Gold applies to these
address contracts only. No whole-compiler proof or C performance-parity claim
is made. This isolated module does not change the active simulation path.

## Work required to complete the native compiler

| Stage | Upstream reference | Remaining work |
| --- | --- | --- |
| Front end | `src/xml/xml.cc`, `xml_native_reader.cc`, `xml_urdf.cc` | XML grammar, MJCF/URDF schemas, diagnostics and source locations |
| Resources and expansion | XML/user resource providers | Includes, directories/VFS, archives, defaults, frames, replicate, attach and generators |
| Editable specification | `src/user/user_api.cc`, `user_model.cc` | Owned object lists, names, references, edits/recompilation and ordering |
| Object compilation | `src/user/user_objects.cc` | Options, joints, inertials, geoms, materials, contacts, equalities, tendons, actuators, sensors and keyframes |
| Assets | `src/user/user_mesh.cc`, resource loaders | Mesh/texture/heightfield/skin loading, hulls, inertia and asset transforms |
| Trees and sparse structures | `ComputeSparseSizes`, `CopyTree`, `engine_support.c` | Body/DOF ancestry, weld/root/tree IDs, simple optimizations, nM/nB/nC/nD, CSR and mappings |
| Model publication | `TryCompile`, generated model definitions | Allocate and fill every owned field, publish only a complete model and clean up failed construction |
| Physical constants | `mj_setConst`, `AutoSpringDamper`, `LengthRange` | Reference kinematics/dynamics, inverse weights, equilibrium quantities, statistics and actuator calibration |
| Extended systems | Flex, plugin and resource APIs | Flex compilation/metrics, plugin ABI/lifecycle and resource-provider behavior |
| Verification | All stages | Minimal then whole-unit proofs, differential corpus, failure/lifetime tests and compiler timings |

`TryCompile` creates temporary engine data, calls `mj_setConst`, performs
automatic spring/damper adjustment and actuator length-range computation, then
validates the compiled model. A complete native compiler therefore depends on
engine functionality as well as parsing. Current dynamics and collision
candidates do not establish that complete dependency closure. Their remaining
engineering/proof work is not a mathematical Silver exception.

## Reproduce

Run from the repository root, using fresh absolute output paths:

```sh
python3 experimental/model-compiler-candidate/tests/check.py --phase small --out /var/tmp/compiler-small
python3 experimental/model-compiler-candidate/tests/check.py --phase whole --out /var/tmp/compiler-whole
python3 experimental/model-compiler-candidate/tests/check.py --phase build --out /var/tmp/compiler-checked
python3 experimental/model-compiler-candidate/tests/check.py --phase build --mode release --out /var/tmp/compiler-release
/var/tmp/sparkling-movement-env/bin/python experimental/model-compiler-candidate/tests/differential.py --binary /var/tmp/compiler-checked/build/validation/bin/compiler_probe --out /var/tmp/compiler-comparison
printf 'E 0\n' | /var/tmp/compiler-checked/build/validation/bin/compiler_probe
```

The differential oracle is test-only. It follows upstream ordered address
assignments and separately implements the documented port capacity policy;
that policy does not claim identical rejection behavior on oversized C models.
Direct official-engine comparisons verify resolved layouts independently.
Input/shape/capacity cases and every build/proof run retain their source hashes.
