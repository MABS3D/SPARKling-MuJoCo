#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
static double seconds(void) {
  struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t);
  return (double)t.tv_sec + (double)t.tv_nsec * 1e-9;
}
int main(int argc, char **argv) {
  if (argc < 3) return 2;
  mjModel *m = mj_loadModel(argv[1], NULL);
  if (!m) return 3;
  mjData *d = mj_makeData(m);
  int count = atoi(argv[2]);
  int cold = argc > 3 && !strcmp(argv[3], "cold");
  for (int i=0; i<m->nv; ++i) d->qvel[i] = .01 * (i%5);
  mj_inverse(m, d);
  double sum = 0, start = seconds();
  for (int i=1; i<=count; ++i) {
    if (m->nv) d->qacc[0] = .01 * (i%100);
    if (cold) mj_inverse(m, d);
    else mj_inverseSkip(m, d, mjSTAGE_VEL, 1);
    if (m->nv) sum += d->qfrc_inverse[0];
  }
  double elapsed = seconds() - start;
  printf("%.17g %.17g\n", elapsed, sum);
  mj_deleteData(d); mj_deleteModel(m); return 0;
}
