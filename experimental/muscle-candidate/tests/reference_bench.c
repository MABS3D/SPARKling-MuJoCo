// Benchmark glue only. All mju_* bodies above are extracted verbatim from upstream.
#include <time.h>
static double seconds(void) {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec + t.tv_nsec*1e-9;
}
double muscle_bench_c(int rounds, int pattern, double* checksum) {
  double lengths[128], velocities[128], controls[128];
  double p[9]={.75,1.05,-1,200,.5,1.6,1.5,1.3,1.2};
  double dp[3]={.01,.04,pattern ? .2 : 0};
  double range[2]={0,1}, acc0=1, act=.3, sum=0;
  for (int j=0;j<128;j++) {
    lengths[j]=.15+j*(1.7/127.0);
    velocities[j]=-3+j*(6.0/127.0);
    controls[j]=(j%2==0) ? .2 : .8;
  }
  double start=seconds();
  for(int i=0;i<rounds;i++) for(int j=0;j<128;j++) {
    double d=mju_muscleDynamics(controls[j],act,dp);
    double next=mju_clip(act+d*.001,0,1);
    double gain=mju_muscleGain(lengths[j],velocities[j],range,acc0,p);
    double bias=mju_muscleBias(lengths[j],range,acc0,p);
    double force=gain*(pattern ? next : act)+bias;
    if(pattern==2) force=mju_clip(force,-150,0);
    sum+=force;
    act=next;
  }
  double elapsed=seconds()-start;
  *checksum=sum+act;
  return elapsed;
}
