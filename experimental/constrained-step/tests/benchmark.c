#define _POSIX_C_SOURCE 200809L
#include <time.h>
#include <mujoco/mujoco.h>
double constrained_time(const mjModel* m, mjData* d, int steps) {
  struct timespec a,b;
  clock_gettime(CLOCK_MONOTONIC, &a);
  for (int i=0; i<steps; ++i) mj_step(m,d);
  clock_gettime(CLOCK_MONOTONIC, &b);
  return (double)(b.tv_sec-a.tv_sec) + 1e-9*(double)(b.tv_nsec-a.tv_nsec);
}
