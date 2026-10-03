#define _POSIX_C_SOURCE 200809L
#include <time.h>
#include <mujoco/mujoco.h>

double flex_step_time(const mjModel* m, mjData* d, int steps) {
  struct timespec start, end;
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int i = 0; i < steps; ++i) mj_step(m, d);
  clock_gettime(CLOCK_MONOTONIC, &end);
  return (double)(end.tv_sec - start.tv_sec) + 1e-9*(end.tv_nsec - start.tv_nsec);
}
