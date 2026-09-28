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
_Static_assert(sizeof(double)==8, "binary64 required");
extern void matquat_evaluate(void*, void*, int*);
extern void matquat_run(int, void*, void*);
static inline void barrier(double *a, double *r) {
  __asm__ __volatile__("" : : "r"(a), "r"(r) : "memory");
}
__attribute__((noinline))
static void c_run(int reps, double a[64][9], double r[64][4]) {
  for (int k=0; k<reps; ++k) {
    barrier(a[0], r[0]);
    for (int i=0; i<64; ++i) mju_mat2Quat(r[i], a[i]);
    barrier(a[0], r[0]);
  }
}
static uint64_t ns(clockid_t id) {
  struct timespec t; if (clock_gettime(id, &t)) abort();
  return (uint64_t)t.tv_sec*1000000000ull + t.tv_nsec;
}
static uint64_t seed=20260928;
static double uniform(void) {
  seed ^= seed << 13; seed ^= seed >> 7; seed ^= seed << 17;
  return 2.0*(double)(seed >> 11)*0x1p-53 - 1.0;
}
static void prepare(double a[64][9], int pattern) {
  for (int i=0; i<64; ++i) {
    double q[4]={uniform(), uniform(), uniform(), uniform()};
    if (pattern==0) { q[0]=1; q[1]=q[2]=q[3]=0; }
    if (pattern>=1 && pattern<=4) q[pattern-1]=3.0;
    mju_normalize4(q); mju_quat2Mat(a[i], q);
    if (pattern==5) { double tie[9]={0,0,1,1,0,0,0,1,0}; memcpy(a[i],tie,sizeof(tie)); }
    if (pattern==6) for (int j=0; j<9; ++j) a[i][j]=10*uniform();
    if (pattern==7) for (int j=0; j<9; ++j) a[i][j]=1e10*uniform();
    if (pattern==8) memset(a[i],0,9*sizeof(double));
  }
}
static volatile double sink;
int matquat_driver(int mode, int backend, int reps, int pattern) {
  if (mode<0 || mode>1 || backend<0 || backend>1 || reps<1 || pattern<0 || pattern>9) return 2;
  double a[64][9], r[64][4], c[64][4], before[64][9];
  if (mode==0) {
    while (scanf("%lf",a[0])==1) {
      for (int j=1; j<9; ++j) if (scanf("%lf",a[0]+j)!=1) return 3;
      memcpy(before[0],a[0],9*sizeof(double));
      int status=-1; matquat_evaluate(a[0],r[0],&status); mju_mat2Quat(c[0],a[0]);
      if (status || memcmp(before[0],a[0],9*sizeof(double))) return 4;
      for (int j=0; j<4; ++j) if (!isfinite(r[0][j]) || !isfinite(c[0][j]) || r[0][j]!=c[0][j]) return 5;
      printf("%.17g %.17g %.17g %.17g\n",r[0][0],r[0][1],r[0][2],r[0][3]);
    }
    return 0;
  }
  prepare(a,pattern); memcpy(before,a,sizeof(a));
  for (int i=0; i<64; ++i) {
    int status=-1; matquat_evaluate(a[i],r[i],&status); mju_mat2Quat(c[i],a[i]);
    if (status) return 4;
    for (int j=0; j<4; ++j) if (!isfinite(r[i][j]) || r[i][j]!=c[i][j]) return 5;
  }
  if (backend) matquat_run(8,a,r); else c_run(8,a,r);
  struct rusage pre,post; getrusage(RUSAGE_THREAD,&pre);
  uint64_t c0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
  if (backend) matquat_run(reps,a,r); else c_run(reps,a,r);
  uint64_t t1=ns(CLOCK_MONOTONIC_RAW),c1=ns(CLOCK_THREAD_CPUTIME_ID);
  getrusage(RUSAGE_THREAD,&post);
  if (memcmp(before,a,sizeof(a))) return 6;
  double sum=0;
  for (int i=0; i<64; ++i) for (int j=0; j<4; ++j) {
    if (r[i][j]!=c[i][j]) return 5;
    sum+=r[i][j];
  }
  sink=sum;
  printf("{\"backend\":%d,\"pattern\":%d,\"reps\":%d,\"batch\":64,\"cpu_ns\":%llu,\"wall_ns\":%llu,\"switches\":%ld,\"sink\":%.17g}\n",
    backend,pattern,reps,(unsigned long long)(c1-c0),(unsigned long long)(t1-t0),post.ru_nivcsw-pre.ru_nivcsw,sum);
  return 0;
}
