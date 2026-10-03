#include <mujoco/mujoco.h>
#include "src/engine/engine_collision_driver.h"
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  if (argc != 3) return 2;
  char error[1024] = {0};
  mjModel* m = mj_loadXML(argv[1], NULL, error, sizeof(error));
  if (!m) { fprintf(stderr, "%s\n", error); return 3; }
  mjData* d = mj_makeData(m);
  if (atoi(argv[2])) mju_threadpool(d, atoi(argv[2]));
  printf("version %s precision %zu types %d %d initpoints %d budget %d %d\n",
         mj_versionString(), sizeof(mjtNum), m->geom_type[0], m->geom_type[1],
         m->opt.sdf_initpoints, mj_maxContact(m, 0, 1, -1), mj_maxContact(m, 1, 0, -1));
  fflush(stdout);
  mj_forward(m, d);
  printf("contacts %d\n", d->ncon);
  for (int i = 0; i < d->ncon; ++i) {
    const mjContact* c = d->contact + i;
    printf("%d %d %.17g %.17g %.17g %.17g %.17g %.17g %.17g\n", c->geom[0], c->geom[1],
           (double)c->dist, (double)c->pos[0], (double)c->pos[1], (double)c->pos[2],
           (double)c->frame[0], (double)c->frame[1], (double)c->frame[2]);
  }
  mj_deleteData(d);
  mj_deleteModel(m);
  return 0;
}
