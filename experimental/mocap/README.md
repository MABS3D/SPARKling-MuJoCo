# Owned mocap state and kinematics

Recovered from the original pre-crash workspace and integrated into the owned smooth/constrained data path on 2026-10-02. Model metadata, raw positions and raw quaternions are retained after the source model is freed. Set_Mocap invalidates cached poses/forces; its rejection paths preserve inputs and cache validity. Kinematics normalizes a local quaternion, while reset copies the original model quaternion bit-for-bit. Motion of dynamic descendants, constraints, spatial tendons and fluid forces use the actual updated Ada poses.

The scoped integration patch and recovery provenance are in `integration`; the common engine owner applied that patch. The original kernel is preserved under integration/recovered-kernels; runtime and proof projects both select the productive copy in smooth.

Fresh validation against C 3.14.0 passed 272/272 trajectories (9 models, smooth/constrained, 16 samples, 100 steps), plus raw/reset, arbitrary source-array origins, invalid index/size atomicity and lifecycle checks. Zero, tiny, nonunit, large and near-unit quaternions are represented. Write_Pose minimum and whole-unit proofs each discharged 46 functional/safety checks. Renewed production receipts and hashes are in `evidence/recovery-20261003`: 272/272 after the common allocation/mapping fixes, high array origins near Integer'Last, Create_Dynamics with zero/nonzero mocap and duplicate-ID rejection. Productive Write_Pose minimum and whole proofs discharge 45 proof checks plus one flow check; the historical total of 46 included flow.

These kernel results do not prove Set_Mocap, creation/reset/free or the complete kinematics/physics composition. Their fresh proof diagnosis is separate. Integrated performance remains pending; no benchmark result is attributed under concurrent load. The constrained engine currently requires at least one velocity DOF, so its zero-DOF mocap-only case remains unsupported.

```sh
python3 experimental/mocap/tests/build.py --out /var/tmp/mocap-repro --working-dependencies
/var/tmp/sparkling-movement-env/bin/python experimental/mocap/tests/compare.py --binary /var/tmp/mocap-repro/build/validation/bin/mocap_probe --out /var/tmp/mocap-compare --samples 16 --steps 100
python3 experimental/mocap/tests/prove.py --out /var/tmp/mocap-write --only Write_Pose
python3 experimental/mocap/tests/prove.py --out /var/tmp/mocap-whole
```

Snapshots include source hashes and use one build/proof job with explicit process-group memory/time limits. Evidence applies to its frozen closure, not automatically to later common changes.
