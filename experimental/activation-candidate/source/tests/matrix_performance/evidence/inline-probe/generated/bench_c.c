#define _GNU_SOURCE
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <time.h>
#include <sys/resource.h>
#include "engine/engine_util_blas.h"
extern double bench_ada_run(int,int,int,int,int,int,void*,void*,void*,void*,void*,void*,void*);
static inline void barrier(double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
  __asm__ __volatile__("" : : "r"(a),"r"(b),"r"(u),"r"(v),"r"(d),"r"(r),"r"(ind) : "memory");
}
__attribute__((noinline))
static double c_run_1(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_copy9(r,a); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_2(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatVec3(r,a,v); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_3(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatTVec3(r,a,v); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_4(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatMat3(r,a,b); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_5(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatTMat3(r,a,b); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_6(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatMatT3(r,a,b); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_7(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatVec(r,a,v,n,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_8(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatTVec(r,a,u,n,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_9(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); acc+=mju_mulVecMatVec(u,a,v,n); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_10(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_transpose(r,a,n,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_11(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_symmetrize(r,a,n); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_12(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_eye(r,n); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_13(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_copyRows(r,a,ind,n/2,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_14(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatMat(r,a,b,n,m,p); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_15(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatTMat(r,a,b,n,m,p); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_16(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_mulMatMatT(r,a,b,n,m,p); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_17(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_sqrMatTD(r,a,NULL,n,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_18(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_sqrMatTD(r,a,d,n,m); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_19(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_sqrMatTD_impl(r,a,d,n,m,0); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run_20(int n,int m,int p,int reps,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 double acc=0;
 for(int k=0;k<reps;++k) { barrier(a,b,u,v,d,r,ind); mju_sqrMatTD_impl(r,a,NULL,n,m,0); barrier(a,b,u,v,d,r,ind); }
 return acc;
}
__attribute__((noinline))
static double c_run(int op,int n,int m,int p,int reps,int pattern,double*a,double*b,double*u,double*v,double*d,double*r,int*ind) {
 switch(op) {
 case 1: return c_run_1(n,m,p,reps,a,b,u,v,d,r,ind);
 case 2: return c_run_2(n,m,p,reps,a,b,u,v,d,r,ind);
 case 3: return c_run_3(n,m,p,reps,a,b,u,v,d,r,ind);
 case 4: return c_run_4(n,m,p,reps,a,b,u,v,d,r,ind);
 case 5: return c_run_5(n,m,p,reps,a,b,u,v,d,r,ind);
 case 6: return c_run_6(n,m,p,reps,a,b,u,v,d,r,ind);
 case 7: return c_run_7(n,m,p,reps,a,b,u,v,d,r,ind);
 case 8: return c_run_8(n,m,p,reps,a,b,u,v,d,r,ind);
 case 9: return c_run_9(n,m,p,reps,a,b,u,v,d,r,ind);
 case 10: return c_run_10(n,m,p,reps,a,b,u,v,d,r,ind);
 case 11: return c_run_11(n,m,p,reps,a,b,u,v,d,r,ind);
 case 12: return c_run_12(n,m,p,reps,a,b,u,v,d,r,ind);
 case 13: return c_run_13(n,m,p,reps,a,b,u,v,d,r,ind);
 case 14: return c_run_14(n,m,p,reps,a,b,u,v,d,r,ind);
 case 15: return c_run_15(n,m,p,reps,a,b,u,v,d,r,ind);
 case 16: return c_run_16(n,m,p,reps,a,b,u,v,d,r,ind);
 case 17: return c_run_17(n,m,p,reps,a,b,u,v,d,r,ind);
 case 18: return c_run_18(n,m,p,reps,a,b,u,v,d,r,ind);
 case 19: return c_run_19(n,m,p,reps,a,b,u,v,d,r,ind);
 case 20: return c_run_20(n,m,p,reps,a,b,u,v,d,r,ind);
 default: return 0;
 }
}
static uint64_t ns(clockid_t c) { struct timespec ts; if(clock_gettime(c,&ts))abort(); return (uint64_t)ts.tv_sec*1000000000ull+ts.tv_nsec; }
static void init(double*a,double*b,double*u,double*v,double*d,double*r,int*ind,int n,int size,int pattern,int seed) {
 for(int i=0;i<size;++i) { a[i]=((i*17+seed)%251-125)/128.0; b[i]=((i*23+seed)%257-128)/256.0; r[i]=-7; if(pattern==1&&i%4) a[i]=0; }
 for(int i=0;i<256;++i) {u[i]=(i%11-5)/16.0;v[i]=(i%13-6)/16.0;d[i]=(i%7-3)/8.0;if(pattern==1&&i%4){u[i]=0;d[i]=0;}ind[i]=n?i%n:0;}
}
static volatile double sink;
int bench_driver(int backend,int op,int n,int m,int p,int reps,int pattern,int seed) {
 if(backend<0||backend>1||op<1||op>20||n<0||n>256||m<0||m>256||p<0||p>256||reps<1||pattern<0||pattern>1)return 2;
 if(op<=6&&(n!=3||m!=3||p!=3))return 2;
 if((op==9||op==11||op==12)&&n!=m)return 2;
 int size=65536;
 double*a=aligned_alloc(64,size*8),*b=aligned_alloc(64,size*8),*r=aligned_alloc(64,size*8);
 double*u=aligned_alloc(64,2048),*v=aligned_alloc(64,2048),*d=aligned_alloc(64,2048);int*ind=aligned_alloc(64,1024);
 if(!a||!b||!r||!u||!v||!d||!ind)abort();
 init(a,b,u,v,d,r,ind,n,size,pattern,seed);
 if(backend==1)sink=bench_ada_run(op,n,m,p,8,pattern,a,b,u,v,d,r,ind);else sink=c_run(op,n,m,p,8,pattern,a,b,u,v,d,r,ind);
 init(a,b,u,v,d,r,ind,n,size,pattern,seed);
 struct rusage before,after;getrusage(RUSAGE_THREAD,&before);
 uint64_t cpu0=ns(CLOCK_THREAD_CPUTIME_ID),t0=ns(CLOCK_MONOTONIC_RAW);
 double result=backend==1?bench_ada_run(op,n,m,p,reps,pattern,a,b,u,v,d,r,ind):c_run(op,n,m,p,reps,pattern,a,b,u,v,d,r,ind);
 uint64_t t1=ns(CLOCK_MONOTONIC_RAW),cpu1=ns(CLOCK_THREAD_CPUTIME_ID);getrusage(RUSAGE_THREAD,&after);
 for(int i=0;i<size;++i)result+=r[i];
 printf("{\"backend\":%d,\"op\":%d,\"nr\":%d,\"nc\":%d,\"nk\":%d,\"pattern\":%d,\"reps\":%d,\"wall_ns\":%llu,\"cpu_ns\":%llu,\"switches\":%ld,\"sink\":%.17g}\n",backend,op,n,m,p,pattern,reps,(unsigned long long)(t1-t0),(unsigned long long)(cpu1-cpu0),after.ru_nivcsw-before.ru_nivcsw,result);
 free(a);free(b);free(r);free(u);free(v);free(d);free(ind);return 0;
}
