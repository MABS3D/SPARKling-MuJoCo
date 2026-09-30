// Copyright 2021 DeepMind Technologies Limited.
// Licensed under the Apache License, Version 2.0; see candidate LICENSE.
// Assembled by the test harness from verbatim MuJoCo 3.14.0 excerpts.
#include <mujoco/mujoco.h>
#include "engine_support.h"
#include "engine_util_misc.h"
#include "engine_util_blas.h"
#include "engine_core_util.h"
mjtNum mj_lugreStribeck(mjtNum velocity, mjtNum F_C, mjtNum F_S, mjtNum v_S) {
  mjtNum ratio = velocity / mju_max(mjMINVAL, v_S);
  return F_C + (F_S - F_C) * mju_exp(-ratio*ratio);
}

mjDCMotorSlots mj_dcmotorSlots(const mjtNum* dynprm, const mjtNum* gainprm) {
  mjDCMotorSlots s = {-1, -1, -1, -1, -1, 0};
  if (dynprm[7] > 0)  s.slew        = s.num_slots++;  // slew rate limiting
  if (gainprm[5] > 0) s.integral    = s.num_slots++;  // PI integral
  if (dynprm[2] > 0)  s.temperature = s.num_slots++;  // thermal model
  if (dynprm[5] > 0)  s.bristle     = s.num_slots++;  // LuGre bristle
  if (dynprm[0] > 0)  s.current     = s.num_slots++;  // current filter

  return s;
}

mjtNum mj_dcmotorResistance(const mjModel* m, const mjData* d, int id) {
  const mjtNum* dynprm = m->actuator_dynprm + mjNDYN*id;
  const mjtNum* gainprm = m->actuator_gainprm + mjNGAIN*id;
  mjtNum R = gainprm[0];
  mjDCMotorSlots slots = mj_dcmotorSlots(dynprm, gainprm);

  // account for temperature if thermal model is enabled
  if (slots.temperature >= 0) {
    mjtNum T = d->act[m->actuator_actadr[id]+slots.temperature];
    mjtNum alpha = gainprm[2];  // temperature coefficient
    mjtNum T0 = gainprm[3];     // reference temperature
    mjtNum Ta = dynprm[4];      // ambient temperature
    R *= 1 + alpha * (T + Ta - T0);
  }

  return mju_max(mjMINVAL, R);
}

mjtNum mj_nextActivation(const mjModel* m, const mjData* d,
                         int actuator_id, int act_adr, mjtNum act_dot) {
  mjtNum act = d->act[act_adr];
  int dyntype = m->actuator_dyntype[actuator_id];

  if (dyntype == mjDYN_FILTEREXACT) {
    // exact filter integration
    // act_dot(0) = (ctrl-act(0)) / tau
    // act(h) = act(0) + (ctrl-act(0)) (1 - exp(-h / tau))
    //        = act(0) + act_dot(0) * tau * (1 - exp(-h / tau))
    mjtNum tau = mju_max(mjMINVAL, m->actuator_dynprm[actuator_id*mjNDYN]);
    act = act + act_dot * tau * (1 - mju_exp(-m->opt.timestep / tau));
  } else if (dyntype == mjDYN_DCMOTOR) {
    const mjtNum* dynprm = m->actuator_dynprm + actuator_id * mjNDYN;
    const mjtNum* gainprm = m->actuator_gainprm + actuator_id * mjNGAIN;
    mjDCMotorSlots slots = mj_dcmotorSlots(dynprm, gainprm);

    int offset = act_adr - m->actuator_actadr[actuator_id];

    // current filter: exact integration
    if (offset == slots.current) {
      mjtNum te = mju_max(mjMINVAL, dynprm[0]);
      act = act + act_dot * te * (1 - mju_exp(-m->opt.timestep / te));
    }

    // LuGre bristle:  dz/dt = a*z + v  where a = -sigma0*|v|/g(v)
    else if (offset == slots.bristle) {
      const mjtNum* biasprm = m->actuator_biasprm + mjNBIAS*actuator_id;
      mjtNum F_C = biasprm[3];    // Coulomb friction
      mjtNum F_S = biasprm[4];    // static friction
      mjtNum v_S = biasprm[5];    // Stribeck velocity
      mjtNum sigma0 = dynprm[5];  // bristle stiffness
      mjtNum velocity = d->actuator_velocity[m->actuator_outadr[actuator_id]];
      mjtNum g = mj_lugreStribeck(velocity, F_C, F_S, v_S);

      // ZOH exact ZOH integration: z(h) = exp(ah)*z(0) + ((exp(ah)-1)/a)*v
      mjtNum a = -sigma0 * mju_abs(velocity) / mju_max(mjMINVAL, g);  // decay rate
      mjtNum h = m->opt.timestep;
      mjtNum exp_ah = mju_exp(a * h);                                 // state transition
      mjtNum int_h = mju_abs(a) > mjMINVAL ? (exp_ah - 1) / a : h;    // input integral
      act = exp_ah * act + int_h * velocity;
    }

    // integral state: Euler integration with anti-windup clamp
    else if (offset == slots.integral) {
      act = act + act_dot * m->opt.timestep;
      mjtNum Imax = dynprm[8];
      if (Imax > 0) {
        act = mju_clip(act, -Imax, Imax);
      }
    }

    // temperature and slew: Euler integration
    else {
      act = act + act_dot * m->opt.timestep;
    }
  }

  // otherwise Euler integration
  else {
    act = act + act_dot * m->opt.timestep;
  }

  // clamp to actrange unless DC motor
  if (dyntype != mjDYN_DCMOTOR && m->actuator_actlimited[actuator_id]) {
    const mjtNum* actrange = m->actuator_actrange + 2*actuator_id;
    act = mju_clip(act, actrange[0], actrange[1]);
  }

  return act;
}
