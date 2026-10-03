/* Test oracle only. Production Ada never links libmujoco or this file. */
#include <mujoco/mujoco.h>
#include <stdlib.h>
#include <string.h>
static double parameter(const mjModel* m, int i, const char* key, double fallback) {
  const char* s = mj_getPluginConfig(m, i, key);
  return s && *s ? strtod(s, 0) : fallback;
}
static int nstate(const mjModel* m, int i) { (void)m; (void)i; return 3; }
static int nsensor(const mjModel* m, int i, int s) { (void)m; (void)i; (void)s; return 4; }
static int init(const mjModel* m, mjData* d, int i) {
  mju_zero(d->plugin_state+m->plugin_stateadr[i], 3); return 0;
}
static void reset(const mjModel* m, mjtNum* state, void* opaque, int i) {
  (void)m; (void)opaque; (void)i; state[0] += 1; state[1] = 0; state[2] = 0;
}
static void destroy(mjData* d, int i) { (void)d; (void)i; }
static void copy(mjData* dest, const mjModel* m, const mjData* src, int i) {
  mju_copy(dest->plugin_state+m->plugin_stateadr[i],src->plugin_state+m->plugin_stateadr[i],3);
}
static void advance(const mjModel* m, mjData* d, int i) { d->plugin_state[m->plugin_stateadr[i]+2] += 1; }
static void compute(const mjModel* m, mjData* d, int i, int capability) {
  d->plugin_state[m->plugin_stateadr[i]+1] += 1;
  if (capability == mjPLUGIN_PASSIVE) {
    d->qfrc_passive[0] = (d->qfrc_passive[0] - parameter(m,i,"k",0)*d->qpos[0])
                                                - parameter(m,i,"d",0)*d->qvel[0];
  } else if (capability == mjPLUGIN_ACTUATOR) {
    for (int a=0; a<m->nactuator; a++) if (m->actuator_plugin[a] == i) {
      double drive = m->actuator_actadr[a] >= 0 ? d->act[m->actuator_actadr[a]] : d->ctrl[a];
      d->actuator_force[m->actuator_outadr[a]] = parameter(m,i,"gain",1)*drive;
    }
  } else if (capability == mjPLUGIN_SENSOR) {
    for (int s=0; s<m->nsensor; s++) if (m->sensor_plugin[s] == i) {
      double* out = d->sensordata + m->sensor_adr[s];
      out[0] = d->qpos[0]; out[1] = d->qvel[0]; out[2] = d->qacc[0]; out[3] = d->time;
    }
  }
}
static void act_dot(const mjModel* m, mjData* d, int i) {
  for (int a=0; a<m->nactuator; a++) if (m->actuator_plugin[a] == i && m->actuator_actadr[a] >= 0)
    d->act_dot[m->actuator_actadr[a]] = parameter(m,i,"dot",.3);
}
int register_reference(void) {
  static const char* keys[] = {"k", "d", "gain", "dot"};
  static const char* names[] = {"spark.test.passive", "spark.test.actuator", "spark.test.sensor.none",
    "spark.test.sensor.pos", "spark.test.sensor.vel", "spark.test.sensor.acc", "spark.test.multi"};
  int last = -1;
  for (int j=0; j<7; j++) {
    mjpPlugin p; mjp_defaultPlugin(&p); p.name=names[j]; p.nattribute=4; p.attributes=keys;
    p.capabilityflags = j==0 ? mjPLUGIN_PASSIVE : j==1 ? mjPLUGIN_ACTUATOR :
      j==6 ? mjPLUGIN_PASSIVE | mjPLUGIN_SENSOR | mjPLUGIN_ACTUATOR : mjPLUGIN_SENSOR;
    p.needstage = j>=2 && j<6 ? j-2 : mjSTAGE_ACC;
    p.nstate=nstate; p.nsensordata=nsensor; p.init=init; p.destroy=destroy; p.copy=copy;
    p.reset=reset; p.compute=compute; p.advance=advance; p.actuator_act_dot=act_dot;
    last=mjp_registerPlugin(&p);
  }
  return last;
}
