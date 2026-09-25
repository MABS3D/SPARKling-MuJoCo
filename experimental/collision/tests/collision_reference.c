/* Calls the actual pinned C narrowphase functions; no copied algorithm. */
#include <stdio.h>
#include <mujoco/mjmodel.h>
#include <mujoco/mjdata.h>
#include "engine/engine_collision_primitive.h"

int main(void) {
  int kind;
  while (scanf("%d", &kind) == 1) {
    mjtNum pos[6], mat[18] = {0}, size[6] = {0}, margin;
    for (int i = 0; i < 3; ++i) if (scanf("%lf", pos+i) != 1) return 2;
    for (int i = 0; i < 3; ++i) if (scanf("%lf", mat+3*i+2) != 1) return 2;
    for (int i = 0; i < 3; ++i) if (scanf("%lf", pos+3+i) != 1) return 2;
    for (int i = 0; i < 3; ++i) if (scanf("%lf", mat+9+3*i+2) != 1) return 2;
    if (scanf("%lf %lf %lf", size+3, size+4, &margin) != 3) return 2;
    mjModel m = {0};
    mjData d = {0};
    m.geom_size = size;
    d.geom_xpos = pos;
    d.geom_xmat = mat;
    mjPreContact contacts[2] = {0};
    int n;
    if (kind == 0) n = mjc_PlaneSphere(&m, &d, contacts, 0, 1, margin);
    else if (kind == 1) n = mjc_PlaneCapsule(&m, &d, contacts, 0, 1, margin);
    else return 2;
    printf("%d ", n);
    for (int i = 0; i < 2; ++i) {
      /* C may touch unused slots; only the first n contacts are meaningful. */
      if (i >= n) {
        for (int j = 0; j < 10; ++j) printf("0 ");
      } else {
        printf("%.17g ", contacts[i].dist);
        for (int j = 0; j < 3; ++j) printf("%.17g ", contacts[i].pos[j]);
        for (int j = 0; j < 3; ++j) printf("%.17g ", contacts[i].normal[j]);
        for (int j = 0; j < 3; ++j) printf("%.17g ", contacts[i].tangent[j]);
      }
    }
    puts("");
  }
  return feof(stdin) ? 0 : 2;
}
