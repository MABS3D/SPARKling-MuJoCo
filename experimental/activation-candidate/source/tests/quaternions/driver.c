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
_Static_assert(sizeof(double)==8,"The fixture requires binary64 storage");
extern void quat_evaluate(void*,void*,void*,void*);
extern double quat_run(int,int,void*,void*,void*,void*);
static void c_evaluate(double*a,double*b,double*v,double*r) {
  double t[4];int p=0;
  #define PUTQ() do {for(int j=0;j<4;j++)r[p++]=t[j];}while(0)
  mju_unit4(t);PUTQ();mju_negQuat(t,a);PUTQ();
  mju_copy4(t,a);mju_negQuat(t,t);PUTQ();
  mju_mulQuat(t,a,b);PUTQ();mju_copy4(t,a);mju_mulQuat(t,t,b);PUTQ();
  mju_copy4(t,a);r[p++]=mju_normalize4(t);
  mju_copy4(t,a);double l=mju_normalize4(t);PUTQ();r[p++]=l;
  mju_rotVecQuat(r+p,v,a);p+=3;mju_quat2Mat(r+p,a);
}
static inline void barrier(double*a,double*b,double*v,double*r) {
 __asm__ __volatile__("" : : "r"(a),"r"(b),"r"(v),"r"(r) : "memory");
}
__attribute__((noinline))
static double c_run(int op,int reps,double*a,double*b,double*v,double*r) {
 double acc=0;
 #define LOOP(BODY) for(int k=0;k<reps;k++){barrier(a,b,v,r);BODY;barrier(a,b,v,r);}
 switch(op) {
 case 1:LOOP(mju_unit4(r));break;
 case 2:LOOP(mju_negQuat(r,a));break;
 case 3:LOOP(mju_copy4(r,a);mju_negQuat(r,r));break;
 case 4:LOOP(mju_mulQuat(r,a,b));break;
 case 5:LOOP(mju_copy4(r,a);mju_mulQuat(r,r,b));break;
 /* MuJoCo has no standalone norm4 export: this is its normalize4 norm expression. */
 case 6:LOOP(acc+=sqrt(((a[0]*a[0]+a[1]*a[1])+a[2]*a[2])+a[3]*a[3]));break;
 case 7:LOOP(mju_copy4(r,a);acc+=mju_normalize4(r));break;
 case 8:LOOP(mju_rotVecQuat(r,v,a));break;
 case 9:LOOP(mju_quat2Mat(r,a));break;
 }
 return acc;
}
static uint64_t ns(clockid_t c) {struct timespec t;if(clock_gettime(c,&t))abort();return (uint64_t)t.tv_sec*1000000000ull+t.tv_nsec;}
static volatile double sink;
int quat_driver(int backend,int op,int reps,int pattern) {
 if(backend<0||backend>1||op<0||op>9||reps<1||pattern<0||pattern>7)return 2;
 double a[4] __attribute__((aligned(64)))={.5,.5,.5,.5};
 double b[4] __attribute__((aligned(64)))={.5,-.5,.5,-.5};
 double v[3] __attribute__((aligned(64)))={.125,-.75,1.5};
 double r[38] __attribute__((aligned(64)))={0};
 if(op==0) {
   while(scanf("%lf",a)==1){
    for(int j=1;j<4;j++)if(scanf("%lf",a+j)!=1)return 3;
    for(int j=0;j<4;j++)if(scanf("%lf",b+j)!=1)return 3;
    for(int j=0;j<3;j++)if(scanf("%lf",v+j)!=1)return 3;
    if(backend)quat_evaluate(a,b,v,r);else c_evaluate(a,b,v,r);
    for(int j=0;j<38;j++)printf("%.17g%c",r[j],j==37?'\n':' ');
   }
   return 0;
 }
 switch(pattern) {
 case 0:break;
 case 1:a[0]=1;a[1]=a[2]=a[3]=0;break;
 case 2:memset(a,0,sizeof(a));break;
 case 3:a[0]=-1;a[1]=a[2]=a[3]=0;break;
 case 4:a[0]=.25;a[1]=-.75;a[2]=1.25;a[3]=-2;break;
 case 5:a[0]=1e-16;a[1]=-2e-16;a[2]=3e-16;a[3]=-4e-16;break;
 case 6:a[0]=1e10;a[1]=-1e10;a[2]=1e10;a[3]=-1e10;break;
 case 7:memset(v,0,sizeof(v));break;
 }
 if(backend)sink=quat_run(op,8,a,b,v,r);else sink=c_run(op,8,a,b,v,r);
 memset(r,0,sizeof(r));
 struct rusage before,after;getrusage(RUSAGE_THREAD,&before);
 uint64_t c0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
 double acc=backend?quat_run(op,reps,a,b,v,r):c_run(op,reps,a,b,v,r);
 uint64_t t1=ns(CLOCK_MONOTONIC_RAW),c1=ns(CLOCK_THREAD_CPUTIME_ID);getrusage(RUSAGE_THREAD,&after);
 for(int j=0;j<38;j++)acc+=r[j];sink=acc;
 printf("{\"backend\":%d,\"op\":%d,\"pattern\":%d,\"reps\":%d,\"cpu_ns\":%llu,\"wall_ns\":%llu,\"switches\":%ld,\"sink\":%.17g}\n",backend,op,pattern,reps,(unsigned long long)(c1-c0),(unsigned long long)(t1-t0),after.ru_nivcsw-before.ru_nivcsw,acc);
 return 0;
}
