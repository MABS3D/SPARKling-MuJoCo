#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char** argv) {
  if (argc < 2) return 2;
  char error[1024] = {0};
  mjModel* m = mj_loadXML(argv[1], NULL, error, sizeof(error));
  if (!m) { fprintf(stderr, "%s\n", error); return 3; }
  mjData* d = mj_makeData(m);
  if (argc > 2 && atoi(argv[2])) {
    mju_threadpool(d, atoi(argv[2]));
  }
  printf("version %s initpoints %d precision %zu\n", mj_versionString(), m->opt.sdf_initpoints, sizeof(mjtNum));
  fflush(stdout);
  mj_forward(m, d);
  printf("contacts %d\n", d->ncon);
  mj_deleteData(d);
  mj_deleteModel(m);
  return 0;
}
