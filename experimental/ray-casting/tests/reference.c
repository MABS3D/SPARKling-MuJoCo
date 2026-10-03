// Test/benchmark oracle only; never linked into Ada production code.
#define _POSIX_C_SOURCE 200809L
#include <time.h>
#include <mujoco/mujoco.h>
double ray_benchmark(const mjModel* m, mjData* d, const double* queries,
                     int count, int repeats, double* checksum) {
  struct timespec begin,end;
  double sum=0;
  clock_gettime(CLOCK_MONOTONIC,&begin);
  for(int r=0;r<repeats;r++) for(int i=0;i<count;i++) {
    const double* q=queries+15*i;
    unsigned char groups[6];
    for(int k=0;k<6;k++) groups[k]=(unsigned char)q[9+k];
    int id; double normal[3];
    double distance=mj_ray(m,d,q,q+3,q[8]?groups:0,(mjtBool)q[6],(int)q[7],&id,normal);
    sum+=distance+id;
  }
  clock_gettime(CLOCK_MONOTONIC,&end);
  *checksum=sum;
  return (end.tv_sec-begin.tv_sec)+(end.tv_nsec-begin.tv_nsec)*1e-9;
}
