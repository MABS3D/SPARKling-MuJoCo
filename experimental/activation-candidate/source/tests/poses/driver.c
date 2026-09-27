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
_Static_assert(sizeof(double)==8,"binary64 required");
extern void pose_evaluate(void*,void*,void*,void*);
extern double pose_run(int,int,void*,void*,void*,void*);
static void c_evaluate(double*a,double*b,double*v,double*r) {
 double old[7];
 mju_mulPose(r,r+3,a,a+3,b,b+3);
 memcpy(r+7,a,56); memcpy(old,r+7,56);
 mju_mulPose(r+7,r+10,old,old+3,b,b+3);
 mju_negPose(r+14,r+17,a,a+3);
 memcpy(r+21,a,56); memcpy(old,r+21,56);
 mju_negPose(r+21,r+24,old,old+3);
 mju_trnVecPose(r+28,a,a+3,v);
 mju_copy3(r+31,v); mju_copy3(old,r+31); mju_trnVecPose(r+31,a,a+3,old);
 mju_mulQuat(r+34,a+3,b+3);
}
static inline void barrier(double*a,double*b,double*v,double*r) {
 __asm__ __volatile__("" : : "r"(a),"r"(b),"r"(v),"r"(r) : "memory");
}
__attribute__((noinline))
static void c_run_7(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);mju_mulQuat(out+3,a+3,b+3);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_1(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);mju_mulPose(out,out+3,a,a+3,b,b+3);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_2(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);double old[7]; memcpy(old,out,56); mju_mulPose(out,out+3,old,old+3,b,b+3);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_3(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);mju_negPose(out,out+3,a,a+3);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_4(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);double old[7]; memcpy(old,out,56); mju_negPose(out,out+3,old,old+3);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_5(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);mju_trnVecPose(out,a,a+3,v);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run_6(int reps,double*a,double*b,double*v,double*r) {
 for(int k=0;k<reps;k++){double*out=r+7*k;barrier(a,b,v,out);double old[3]; mju_copy3(old,out); mju_trnVecPose(out,a,a+3,old);barrier(a,b,v,out);}
}
__attribute__((noinline))
static void c_run(int op,int reps,double*a,double*b,double*v,double*r) {
 switch(op) {
 case 1: c_run_1(reps,a,b,v,r);break;
 case 2: c_run_2(reps,a,b,v,r);break;
 case 3: c_run_3(reps,a,b,v,r);break;
 case 4: c_run_4(reps,a,b,v,r);break;
 case 5: c_run_5(reps,a,b,v,r);break;
 case 6: c_run_6(reps,a,b,v,r);break;
 case 7: c_run_7(reps,a,b,v,r);break;
 }
}
static uint64_t ns(clockid_t c) {struct timespec t;if(clock_gettime(c,&t))abort();return (uint64_t)t.tv_sec*1000000000ull+t.tv_nsec;}
static volatile double sink;
int pose_driver(int backend,int op,int reps,int pattern) {
 if(backend<0||backend>1||op<0||op>7||reps<1||pattern<0||pattern>9)return 2;
 double a[7] __attribute__((aligned(64)))={.25,-.5,2,.5,.5,.5,.5};
 double b[7] __attribute__((aligned(64)))={.125,-.75,1.5,.5,-.5,.5,-.5};
 double v[3] __attribute__((aligned(64)))={.75,-2,1};
 double r[38] __attribute__((aligned(64)))={0};
 if(op==0) {
  while(scanf("%lf",a)==1){
   for(int j=1;j<7;j++)if(scanf("%lf",a+j)!=1)return 3;
   for(int j=0;j<7;j++)if(scanf("%lf",b+j)!=1)return 3;
   for(int j=0;j<3;j++)if(scanf("%lf",v+j)!=1)return 3;
   double input[17];memcpy(input,a,56);memcpy(input+7,b,56);memcpy(input+14,v,24);
   if(backend)pose_evaluate(a,b,v,r);else c_evaluate(a,b,v,r);
   if(memcmp(input,a,56)||memcmp(input+7,b,56)||memcmp(input+14,v,24))return 6;
   for(int j=0;j<38;j++)printf("%.17g%c",r[j],j==37?'\n':' ');
  }
  return 0;
 }
 switch(pattern) {
 case 0:break;
 case 1:a[3]=1;a[4]=a[5]=a[6]=0;break;
 case 2:memset(a+3,0,32);break;
 case 3:a[3]=-1;a[4]=a[5]=a[6]=0;break;
 case 4:a[3]=.25;a[4]=-.75;a[5]=1.25;a[6]=-2;break;
 case 5:for(int j=0;j<4;j++)a[j+3]=(j-1)*1e-160;break;
 case 6:for(int j=0;j<7;j++){a[j]=(j%2?-1:1)*1e10;b[j]=(j%2?1:-1)*1e10;}break;
 case 7:memset(a,0,24);memset(b,0,24);memset(v,0,24);break;
 case 8:a[3]=nextafter(1.0+1e-15,INFINITY);a[4]=a[5]=a[6]=0;mju_unit4(b+3);break;
 case 9:a[3]=nextafter(1e-15,0.0);a[4]=a[5]=a[6]=0;mju_unit4(b+3);break;
 }
 enum {BATCH=32768};
 double*slots=aligned_alloc(64,BATCH*7*sizeof(double));if(!slots)return 4;
 // Check every timed path, including varied in-place inputs, before timing.
 double expected[8][7];int widths[7]={7,7,7,7,3,3,4};int offsets[7]={0,7,14,21,28,31,34};int first=op==7?3:0;
 for(int j=0;j<8;j++) {
  memcpy(slots+7*j,a,56);if(op==5||op==6){mju_copy3(slots+7*j,v);memset(slots+7*j+3,0,32);}
  for(int k=0;k<3;k++)slots[7*j+k]/=(j+1);
  c_evaluate(op%2||op>=5?a:slots+7*j,b,op==6?slots+7*j:v,r);
  memcpy(expected[j],r+offsets[op-1],widths[op-1]*8);
 }
 if(backend)pose_run(op,8,a,b,v,slots);else c_run(op,8,a,b,v,slots);
 for(int j=0;j<8;j++)for(int k=0;k<widths[op-1];k++)if(!isfinite(slots[7*j+first+k])||slots[7*j+first+k]!=expected[j][k]){free(slots);return 5;}
 struct rusage before,after;getrusage(RUSAGE_THREAD,&before);
 uint64_t cpu_ns=0,wall_ns=0;double acc=0;
 for(int remaining=reps;remaining>0;) {
  int count=remaining<BATCH?remaining:BATCH;
  for(int j=0;j<count;j++){memcpy(slots+7*j,a,56);if(op==5||op==6){mju_copy3(slots+7*j,v);memset(slots+7*j+3,0,32);}}
  uint64_t c0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
  if(backend)pose_run(op,count,a,b,v,slots);else c_run(op,count,a,b,v,slots);
  uint64_t t1=ns(CLOCK_MONOTONIC_RAW),c1=ns(CLOCK_THREAD_CPUTIME_ID);
  cpu_ns+=c1-c0;wall_ns+=t1-t0;
  for(int j=0;j<count;j++)for(int k=0;k<widths[op-1];k++)acc+=slots[7*j+first+k];remaining-=count;
 }
 getrusage(RUSAGE_THREAD,&after);sink=acc;free(slots);
 printf("{\"backend\":%d,\"op\":%d,\"pattern\":%d,\"reps\":%d,\"cpu_ns\":%llu,\"wall_ns\":%llu,\"switches\":%ld,\"sink\":%.17g}\n",backend,op,pattern,reps,(unsigned long long)cpu_ns,(unsigned long long)wall_ns,after.ru_nivcsw-before.ru_nivcsw,acc);
 return 0;
}
