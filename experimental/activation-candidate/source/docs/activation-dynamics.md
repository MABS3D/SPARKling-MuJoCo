# Scalar activation dynamics: isolated candidate

This candidate implements `integrator`, `filter`, and `filterexact` in the
experimental scalar hinge/slide simulator, against pinned MuJoCo 3.14.0
(`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`). It is not an accepted whole-engine
Gold or performance-parity baseline. The main working copy is not overwritten.

## Implemented behavior

- Owned, compact activation indices follow `actuator_actadr`; mixed stateless and
  stateful actuators are supported. Create verifies consecutive active slots.
- Controls are clamped before the derivative; activation is not clamped to the
  control range. Force limits and affine bias keep their original semantics.
- `integrator`: `act_dot = ctrl`; `filter` and `filterexact`:
  `act_dot = (ctrl-act) / max(1e-15, tau)`.
- Ordinary integration uses `act + act_dot*h`; exact filtering uses
  `act + (act_dot*tau)*(1-exp(-h/tau))`, preserving the C multiplication order.
- Activation limits apply to the next activation. `actearly` uses that next
  activation for the current force, without advancing the owned state early.
- Successful Euler commits activation once. Rejected steps preserve position,
  velocity, time **and activation**. Disabled actuation holds activation.
- A future activation outside the finite Tier0 domain rejects Euler. With
  `actearly=false`, Forward can still evaluate the current valid activation;
  with `actearly=true`, it rejects the invalid force input immediately.

MuJoCo's reference paths are `mj_fwdActuation` and `advanceStart` in
`engine_forward.c`, and `mj_nextActivation` in `engine_support.c`.

The timestep and actuator configuration are immutable after Create. Therefore
`tau` flooring and the exact-filter exponential are computed once at Create.
For `h/tau > 40`, the factor is one: the subtracted exponential is below half
an ulp at one. Force preparation and activation preparation share one loop;
projection is a separate ordered reduction. A validity flag prevents unsafe
activation commits without adding a second validation scan of the activations.

## API and ownership

Existing Create / Forward / Euler calls now support these models. Reset sets
activation to zero. The additional interface is:

```ada
Activation_Count (D)              -- compact C-style na, not nu
Activation_Values (D)             -- current owned activation
Activation_Rates (D)              -- last evaluated derivative; can be stale
Set_Activation (D, Values, Result)
Complete_State_Values (D)          -- [qpos, qvel, time, activation]
```

`State_Values` keeps its existing `[qpos,qvel,time]` layout. `Set_State` preserves
activation; use `Set_Activation` to replace it. Wrong lengths are rejected
atomically; arbitrary input array lower bounds are accepted. Setting activation
invalidates actuator forces and acceleration. The model can be freed after
Create. External body loads remain usable through the existing optional
Forward/Euler argument.

The current storage uses fixed-capacity activation, next-state, derivative and
drive arrays, with loops/copies restricted to active counts. No allocation or
exponential evaluation occurs in the step loop. Capacity remains 1,024 active
states/actuators. Input activations use the same finite ±1e10 domain as the
existing state API; dynamic parameters and limits must fit the documented
scalar input domain. Derived buffers may change after a rejected operation.

Muscles, DC motors, PID/user/plugin dynamics, multi-input actuators, activation
history/delay and other previously excluded model features remain unsupported.
This is the agreed three-type scalar scope, not full MuJoCo actuation.

## Verification boundaries

Exact floating-point formulas, clamping, early/current drive selection, disabled
behavior and per-actuator numeric rejection are specified in `MJ.Activation`.
The fused loop proves the published transmission/force formulas and the ordered
projection to generalized force. No new assumptions, trusted bodies, suppressed
checks or deallocator changes are introduced to claim proof completion.

Closed scopes and still-open integration work are listed in the accompanying
[activation-verification-results.md](activation-verification-results.md). Those checks prove their contracts under called
contracts; they are not a proof of complete dynamics or universal C equivalence.
The exponential call has an unresolved GNATprove runtime-library obligation:
its generated `exp_no_overflow` predicate is uninterpreted in the saved VC even
for an argument constrained to [-40,0]. This is a missing proof model to close,
not an approved mathematical exception or a justification to call the whole
feature Gold-complete. Phase, loader, reset and Euler composition must also be
closed on this changed representation before full Gold adoption.

## Numerical and performance acceptance

See `tests/movement_performance/activation_dynamics/README.md` for reproduction.
The evidence includes nonzero activation/control, saturation, disabled flags,
100-step trajectories, compact mixed actuator layouts, external body loads,
tiny/negative/large tau and failure atomicity. Both Compatible and Strict modes
are exercised. Tolerances are absolute+relative `2e-10`; tests do not prove a
universal error bound.

Integrated timings compare native Ada and normal native C SIMD builds, matching
models, initial states, inputs and trajectories. Input preparation and I/O are
outside timing. Results use alternating order, CPU 12, 24 blocks, four samples
of 100 steps, two warmups, and two sessions; raw outputs and bootstrap intervals
are retained. Concurrent work elsewhere on this shared host adds noise, so these
are shared-host measurements, not an isolated-machine acceptance result.

**The complete performance target is not met.** The 24-DOF chains with 24
actuators remain slower than C; actuator-heavy cases are generally faster. Some 6-DOF results also show
small regressions; see confidence intervals and repeated measurements. A separate same-trajectory zero-activation diagnostic finds the
24-DOF baseline gap already exists without activation dynamics. Its small
increment estimates are noisy and must not be treated as precise stage timings.
Nonzero workloads, not that diagnostic, are the acceptance comparison.
