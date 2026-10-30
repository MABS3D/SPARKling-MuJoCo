# Owned mocap state and kinematics

Recovered from the original pre-crash workspace and integrated into the owned smooth/constrained data path on 2026-10-02. Model metadata, raw positions and raw quaternions are retained after the source model is freed. Set_Mocap invalidates cached poses/forces; its rejection paths preserve inputs and cache validity. Kinematics normalizes a local quaternion, while reset copies the original model quaternion bit-for-bit. Motion of dynamic descendants, constraints, spatial tendons and fluid forces use the actual updated Ada poses.

The scoped integration patch and recovery provenance are in `integration`; the common engine owner applied that patch. The original kernel is preserved under integration/recovered-kernels; runtime and proof projects both select the productive copy in smooth.

Fresh validation against C 3.14.0 passed 272/272 trajectories (9 models, smooth/constrained, 16 samples, 100 steps), plus raw/reset, arbitrary source-array origins, invalid index/size atomicity and lifecycle checks. Zero, tiny, nonunit, large and near-unit quaternions are represented. Write_Pose minimum and whole-unit proofs each discharged 46 functional/safety checks. Renewed production receipts and hashes are in `evidence/recovery-20261003`: 272/272 after the common allocation/mapping fixes, high array origins near Integer'Last, Create_Dynamics with zero/nonzero mocap and duplicate-ID rejection. Productive Write_Pose minimum and whole proofs discharge 45 proof checks plus one flow check; the historical total of 46 included flow.

These kernel results do not prove Set_Mocap, creation/reset/free or the complete kinematics/physics composition. Their fresh proof diagnosis is separate. Integrated performance remains pending; no benchmark result is attributed under concurrent load. The constrained engine currently requires at least one velocity DOF, so its zero-DOF mocap-only case remains unsupported.

The 2026-10-28 test extension adds integrator, filter and filterexact actuator
models, with nonzero activation, control and generalized applied force. Each
successful mocap update explicitly checks preservation of state, inputs and
activation, including the constrained engine's state/activation queries.
Rejected updates also check input preservation. The original fixtures and
quaternion cases remain. The probe input protocol now supplies activation,
controls and applied forces after qpos/qvel for each sample; use the matching
comparison script and probe together.

The expanded suite passes 368/368 cases in each of eight runs: references
3.14/3.17, validation/release, adopted baseline/private setter prototype.
All 92 corresponding baseline/candidate output files are byte-identical;
poses, acceleration, reset and 100-step trajectories meet the unchanged
2e-10 C tolerances. These results cover the frozen closures in
[the mocap frame checkpoint](../alignment-3.17/evidence/20261028-mocap-frames-and-actuated-trajectories-r2253/README.md).
The mocap type invariant remains private, and full setter/lifecycle proofs
and integrated performance parity remain separate unfinished work.

```sh
python3 experimental/mocap/tests/build.py --out /var/tmp/mocap-repro --working-dependencies
/var/tmp/sparkling-movement-env/bin/python experimental/mocap/tests/compare.py --binary /var/tmp/mocap-repro/build/validation/bin/mocap_probe --out /var/tmp/mocap-compare --samples 16 --steps 100
python3 experimental/mocap/tests/prove.py --out /var/tmp/mocap-write --only Write_Pose
python3 experimental/mocap/tests/prove.py --out /var/tmp/mocap-whole
```

Snapshots include source hashes and use one build/proof job with explicit process-group memory/time limits. Evidence applies to its frozen closure, not automatically to later common changes.

The 2026-10-30 mapping update proves the actual constructor's map validator:
IDs lie in range, nonnegative IDs are unique, and every slot is present. Its
full scope closes45 checks on each reference, using a separately proved12-check
Ghost coverage lemma. All new proof work is Static and introduces no runtime
scan. The final source passes1472 fresh C comparisons across both references
and profiles, with92 outputs identical to baseline.
[Mapping proof and I/O recovery evidence](../alignment-3.17/evidence/20261030-mocap-mapping-gold-and-io-recovery-r2380/README.md).
Reset and the complete state/dynamics lifecycle still require their own proofs.

The private reset-copy helper now closes52 checks per reference, while the
actual Clear_State's new Static preservation contracts close50 per reference
with no change to its runtime assignment body. Actual and private-lifecycle
matrices each pass1472 C comparisons;184 outputs equal baseline. Complete
Reset/constructor proofs and invariant adoption remain open. The raw-reference
projection now tolerates the legitimate joint-to-DOF metadata expansion.
[Reset/frame proof and caller diagnostics](../alignment-3.17/evidence/20261030-reset-mocap-loop-and-state-frame-r2470/README.md).
