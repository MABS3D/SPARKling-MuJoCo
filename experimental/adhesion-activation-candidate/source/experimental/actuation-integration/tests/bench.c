#define _GNU_SOURCE
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>
#include <time.h>
#include <sys/resource.h>
extern void contact_run(const double*, double*, int);
static volatile double sink;
static uint64_t ns(clockid_t c) { struct timespec t; if(clock_gettime(c,&t))abort();return (uint64_t)t.tv_sec*1000000000+t.tv_nsec; }
static void init(mjData* d, const double* a) {d->qpos[0]=a[28];d->qvel[0]=a[29];d->time=a[30];d->ctrl[0]=a[32];d->qfrc_applied[0]=a[33];if(d->act)d->act[0]=a[31];}
static void readout(const mjData*d,double*r) {r[0]=d->qpos[0];r[1]=d->qvel[0];r[2]=d->time;r[3]=d->act?d->act[0]:0;r[4]=d->actuator_force[0];r[5]=d->nefc?d->efc_force[0]:0;r[6]=0;}
int contact_driver(int backend,int fixture,int steps,int repeats) {
 if(backend<0||backend>1||fixture<0||fixture>3||steps<1||repeats<1)return 2;
 double a[35]={2,.1,0,-9.81,.002,.01,.02,.02,1,.9,.95,.001,.5,3,.02,4,1,1,1,1,0,1,1,0,1,0,-100,100,.3,0,0,.2,.7,0,0};
 if(fixture==1)a[28]=.099;
 if(fixture==2){a[28]=.105;a[29]=.1;}
 if(fixture==3)a[28]=1e8;
 const char*path=getenv("CONTACT_MODEL_PATH");
 if(!path){fprintf(stderr,"CONTACT_MODEL_PATH is required\n");return 3;}
 mjModel*m=mj_loadModel(path,NULL);
 if(!m){fprintf(stderr,"could not load reference MJB\n");return 3;}mjData*d=mj_makeData(m);
 double expected[7],r[7];init(d,a);for(int k=0;k<steps;k++)mj_step(m,d);readout(d,expected);
 contact_run(a,r,steps);
 for(int j=0;j<6;j++)if(!isfinite(r[j])||fabs(r[j]-expected[j])>2e-10*(1+fabs(expected[j])))return 4;
 uint64_t cpu=0,wall=0;struct rusage u0,u1;getrusage(RUSAGE_THREAD,&u0);
 for(int rep=-2;rep<repeats;rep++) {
  mj_resetData(m,d);init(d,a);memset(r,0,sizeof(r));
  uint64_t c0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
  if(backend)contact_run(a,r,steps);else for(int k=0;k<steps;k++)mj_step(m,d);
  uint64_t t1=ns(CLOCK_MONOTONIC_RAW),c1=ns(CLOCK_THREAD_CPUTIME_ID);
  if(!backend)readout(d,r);
  if(r[6]!=0)return 5;
  for(int j=0;j<6;j++)if(!isfinite(r[j])||fabs(r[j]-expected[j])>2e-10*(1+fabs(expected[j])))return 6;
  sink=r[0]+r[1]+r[2]+r[3];if(rep>=0){cpu+=c1-c0;wall+=t1-t0;}
 }
 getrusage(RUSAGE_THREAD,&u1);
 printf("{\"cpu_ns\":%llu,\"wall_ns\":%llu,\"steps\":%d,\"repeats\":%d,\"switches\":%ld,\"sink\":%.17g}\n",(unsigned long long)cpu,(unsigned long long)wall,steps,repeats,u1.ru_nivcsw-u0.ru_nivcsw,sink);
 mj_deleteData(d);mj_deleteModel(m);return 0;
}
