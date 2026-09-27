/* Test driver linked to the actual pinned MuJoCo engine_util_blas.c. */
#include <stdio.h>
#include "engine/engine_util_blas.h"

int main(void) {
  mjtNum a[3], b[3], scale, result[3];
  int count;
  while ((count = scanf("%lf %lf %lf %lf %lf %lf %lf",
                       &a[0], &a[1], &a[2], &b[0], &b[1], &b[2], &scale)) != EOF) {
    if (count != 7) return 2;
    mju_add3(result, a, b);
    for (int i = 0; i < 3; ++i) printf("%.17g ", result[i]);
    mju_sub3(result, a, b);
    for (int i = 0; i < 3; ++i) printf("%.17g ", result[i]);
    mju_scl3(result, a, scale);
    for (int i = 0; i < 3; ++i) printf("%.17g ", result[i]);
    printf("%.17g\n", mju_dot3(a, b));
  }
  return 0;
}
