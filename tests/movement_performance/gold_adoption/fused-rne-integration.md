# Fused RNE prerequisite and separate-force API boundary

Reference: MuJoCo 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd.
Local C: engine_core_smooth.c:2355-2420 (`mj_rne`, flg_acc=0).

The new standalone MJ.Fused_RNE package supplies the world acceleration with
negative gravity and the rounded force of one body, I*a + v x* (I*v), using
the same existing spatial multiply/cross/add kernels and their fixed FP order.
The intended acceleration includes propagated negative gravity. Consequently
the returned force is combined inertial-minus-gravity, not our public
velocity-only Bias or positive Gravity.

Try_Body_Force explicitly retains the existing narrow fast-path rejection
conditions. Ok is true exactly when the gyroscopic wrench and final sum both
fit 1e54. On rejection the output is all zero. The new contracts prove the
rounded expression and these branches; they assert neither equality to the
old separately rounded gravity/bias split nor real-arithmetic accuracy.

No Simulation, Dynamics cache or public API is modified. The helper is a
proved prerequisite, not an implemented fused stepping path or performance
result. Its current isolated compilation must not be called full dynamics Gold.

## Integration design preserving the separate-force API

1. Keep public Forward/Evaluate and Get_Forces/Force_Value on the existing
   separate gravity/velocity-bias representation. Get_Forces copies both arrays;
   Force_Value directly indexes them. Reusing either array for the combined
   wrench would silently violate that API.
2. Give stepping an explicit separate scratch array for combined generalized
   bias, and a validity fact distinct from Passive_Current/Forces_Current.
   Seed world acceleration with World_Acceleration, propagate it, call the new
   helper, accumulate one wrench backward and project once per DOF.
3. Compose total force with an explicit rounded contract. C fwdAcceleration
   uses ((passive-combined_bias)+applied)+actuator. The current Ada Total_Force
   uses ((((gravity-bias)+passive)+actuator)+applied). Changing to C's expression
   is deliberate and needs numerical comparison, not an exact-equality claim.
4. On a successful Euler step all caches are invalidated by Integrate, so no
   separate force results need to be published. Error exits need extra care:
   an earlier successful forward evaluation could leave separate-force queries
   available even if Euler solving/integration fails. Preserve this behavior
   by materializing separate results before such an error return, or prove
   an equivalent state transition; never mark fused-only buffers Passive_Valid.
   Domain rejection must retain the existing wider fallback before committing.
5. Prove these publication, failure and invalidation transitions before enabling
   dispatch from Step. Then perform integrated baseline/current/C movement and
   separate-force API tests, covering successful and failed steps.

The standalone tests cover gravity enabled/disabled, a nonzero-velocity body
with a hand-computed force, both distinct rejection branches, and zero inertia
at motion bounds. They do not replace the eventual tree/pipeline tests.
