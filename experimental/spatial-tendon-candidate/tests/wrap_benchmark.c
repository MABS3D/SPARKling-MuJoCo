// Test driver only. The oracle numerical routines are compiled from upstream.
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mujoco/mujoco.h>
#include "engine/engine_util_misc.h"

typedef struct {
  int kind, side;
  mjtNum radius, a[3], b[3], center[3], rotation[9], sidepos[3];
} Input;

int main(void) {
  int count, repeats;
  if (scanf("%d%d", &count, &repeats) != 2 || count <= 0 || repeats <= 0) return 1;
  Input* cases = calloc(count, sizeof(Input));
  if (!cases) return 1;
  for (int i=0; i<count; i++) {
    Input* c = cases+i;
    if (scanf("%d%lf%d", &c->kind, &c->radius, &c->side) != 3) return 1;
    mjtNum* arrays[] = {c->a, c->b, c->center, c->rotation, c->sidepos};
    int lengths[] = {3,3,3,9,3};
    for (int a=0; a<5; a++)
      for (int j=0; j<lengths[a]; j++)
        if (scanf("%lf", arrays[a]+j) != 1) return 1;
  }
  struct timespec start, end;
  mjtNum total=0, points[6];
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int r=0; r<repeats; r++) {
    for (int i=0; i<count; i++) {
      const Input* c = cases+i;
      mjtNum length = mju_wrap(points, c->a, c->b, c->center, c->rotation, c->radius,
                        c->kind ? mjWRAP_CYLINDER : mjWRAP_SPHERE,
                        c->side ? c->sidepos : NULL);
      total += length;
      if (length >= 0) for (int j=0; j<6; j++) total += points[j];
    }
  }
  clock_gettime(CLOCK_MONOTONIC, &end);
  double elapsed = (end.tv_sec-start.tv_sec) + (end.tv_nsec-start.tv_nsec)*1e-9;
  printf("%.17g %.17g\n", elapsed, total);
  free(cases);
}
