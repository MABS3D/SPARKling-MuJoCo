#define _GNU_SOURCE
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/resource.h>
#include "engine/engine_util_spatial.h"
#include "engine/engine_util_blas.h"

_Static_assert(sizeof(double) == 8, "The fixture requires binary64 storage");
extern void rotation_evaluate(void*, void*, void*, void*);
extern double rotation_run(int, int, void*, void*, void*, void*);

static void c_evaluate(double* q, double* a, double* v, double* r) {
  double conjugate[4];
  mju_rotVecQuat(r, v, q);
  mju_copy3(r+3, v); mju_rotVecQuat(r+3, r+3, q);
  mju_negQuat(conjugate, q);
  mju_rotVecQuat(r+6, v, conjugate);
  mju_copy3(r+9, v); mju_rotVecQuat(r+9, r+9, conjugate);
  mju_mulMatVec3(r+12, a, v);
  mju_copy3(r+15, v); mju_mulMatVec3(r+15, a, r+15);
  mju_mulMatTVec3(r+18, a, v);
  mju_copy3(r+21, v); mju_mulMatTVec3(r+21, a, r+21);
}

static inline void barrier(double* q, double* a, double* v, double* r) {
  __asm__ __volatile__("" : : "r"(q), "r"(a), "r"(v), "r"(r) : "memory");
}

__attribute__((noinline))
static double c_run(int op, int reps, double* q, double* a, double* v, double* r) {
  double conjugate[4];
  // Each output slot is prepared before timing and visited once, as in Ada.
  #define LOOP(BODY) for (int k=0; k<reps; k++) {double* out=r+3*k; barrier(q,a,v,out); BODY; barrier(q,a,v,out);}
  switch (op) {
    case 1: LOOP(mju_rotVecQuat(out,v,q)); break;
    case 2: LOOP(mju_rotVecQuat(out,out,q)); break;
    case 3: LOOP(mju_negQuat(conjugate,q); mju_rotVecQuat(out,v,conjugate)); break;
    case 4: LOOP(mju_negQuat(conjugate,q); mju_rotVecQuat(out,out,conjugate)); break;
    case 5: LOOP(mju_mulMatVec3(out,a,v)); break;
    case 6: LOOP(mju_mulMatVec3(out,a,out)); break;
    case 7: LOOP(mju_mulMatTVec3(out,a,v)); break;
    case 8: LOOP(mju_mulMatTVec3(out,a,out)); break;
  }
  return 0.0;
}

static uint64_t ns(clockid_t clock) {
  struct timespec t;
  if (clock_gettime(clock, &t)) abort();
  return (uint64_t)t.tv_sec*1000000000ull + t.tv_nsec;
}

static volatile double sink;
int rotation_driver(int backend, int op, int reps, int pattern) {
  if (backend<0 || backend>1 || op<0 || op>8 || reps<1 || pattern<0 || pattern>7) return 2;
  double q[4] __attribute__((aligned(64))) = {.5,.5,.5,.5};
  double a[9] __attribute__((aligned(64))) = {0,0,1,1,0,0,0,1,0};
  double v[3] __attribute__((aligned(64))) = {.125,-.75,1.5};
  double r[24] __attribute__((aligned(64))) = {0};
  if (op == 0) {
    while (scanf("%lf", q) == 1) {
      for (int j=1; j<4; j++) if (scanf("%lf",q+j)!=1) return 3;
      for (int j=0; j<9; j++) if (scanf("%lf",a+j)!=1) return 3;
      for (int j=0; j<3; j++) if (scanf("%lf",v+j)!=1) return 3;
      if (backend) rotation_evaluate(q,a,v,r); else c_evaluate(q,a,v,r);
      for (int j=0; j<24; j++) printf("%.17g%c", r[j], j==23?'\n':' ');
    }
    return 0;
  }
  switch (pattern) {
    case 0: break;
    case 1: q[0]=1; q[1]=q[2]=q[3]=0; mju_quat2Mat(a,q); break;
    case 2: memset(q,0,sizeof(q)); memset(a,0,sizeof(a)); break;
    case 3: q[0]=-1; q[1]=q[2]=q[3]=0; mju_quat2Mat(a,q); break;
    case 4:
      q[0]=.25; q[1]=-.75; q[2]=1.25; q[3]=-2;
      for (int j=0; j<9; j++) a[j]=(j-3)*.25;
      break;
    case 5:
      for (int j=0; j<4; j++) q[j]=(j-1)*1e-160;
      for (int j=0; j<9; j++) a[j]=(j-3)*1e-160;
      break;
    case 6:
      for (int j=0; j<4; j++) q[j]=(j%2 ? -1 : 1)*1e10;
      for (int j=0; j<9; j++) a[j]=(j%2 ? -1 : 1)*1e10;
      v[0]=v[2]=1e10; v[1]=-1e10;
      break;
    case 7: memset(v,0,sizeof(v)); break;
  }
  enum { BATCH = 32768 };
  double* slots = aligned_alloc(64, BATCH*3*sizeof(double));
  if (!slots) return 4;
  double expected[8][3], full[24];
  for (int j=0; j<8; j++) {
    for (int k=0; k<3; k++) slots[3*j+k]=v[k]/(j+1);
    c_evaluate(q,a,op%2 ? v : slots+3*j,full);
    mju_copy3(expected[j],full+3*(op-1));
  }
  if (backend) sink=rotation_run(op,8,q,a,v,slots); else sink=c_run(op,8,q,a,v,slots);
  for (int j=0; j<8; j++) {
    for (int k=0; k<3; k++) {
      if (!isfinite(slots[3*j+k]) || slots[3*j+k]!=expected[j][k]) {
        free(slots);
        return 5;
      }
    }
  }
  struct rusage before,after;
  getrusage(RUSAGE_THREAD,&before);
  uint64_t cpu_ns=0,wall_ns=0;
  double acc=0;
  for (int remaining=reps; remaining>0;) {
    int count=remaining<BATCH ? remaining : BATCH;
    // Exactly the same preparation for both backends, outside both clocks.
    for (int j=0; j<count; j++) mju_copy3(slots+3*j,v);
    uint64_t c0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
    if (backend) rotation_run(op,count,q,a,v,slots); else c_run(op,count,q,a,v,slots);
    uint64_t t1=ns(CLOCK_MONOTONIC_RAW),c1=ns(CLOCK_THREAD_CPUTIME_ID);
    cpu_ns+=c1-c0; wall_ns+=t1-t0;
    for (int j=0; j<count*3; j++) acc+=slots[j];
    remaining-=count;
  }
  getrusage(RUSAGE_THREAD,&after);
  sink=acc;
  free(slots);
  printf("{\"backend\":%d,\"op\":%d,\"pattern\":%d,\"reps\":%d,\"cpu_ns\":%llu,\"wall_ns\":%llu,\"switches\":%ld,\"sink\":%.17g}\n",
         backend,op,pattern,reps,(unsigned long long)cpu_ns,(unsigned long long)wall_ns,
         after.ru_nivcsw-before.ru_nivcsw,acc);
  return 0;
}
