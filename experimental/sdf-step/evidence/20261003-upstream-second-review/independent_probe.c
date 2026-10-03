#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
  if (argc != 4) return 2;
  char error[1024] = {0};
  mjModel *m = mj_loadXML(argv[1], NULL, error, sizeof(error));
  if (!m) { fprintf(stderr, "load: %s\n", error); return 3; }
  mjData *d = mj_makeData(m);
  if (!d || m->ngeom != 2) return 4;
  int threads = atoi(argv[2]);
  if (threads) mju_threadpool(d, threads);
  int g1 = 0, g2 = 1;
  if (m->geom_type[g1] > m->geom_type[g2]) {g1 = 1; g2 = 0;}
  mj_kinematics(m, d);
  mjPreContact con[mjMAXCONPAIR];
  int n = mjCOLLISIONFUNC[m->geom_type[g1]][m->geom_type[g2]](m, d, con, g1, g2, 0);
  int safe = 1;
  printf("version=%s bytes=%zu initpoints=%d types=%d,%d faces=%d,%d direct=%d", mj_versionString(), sizeof(mjtNum), m->opt.sdf_initpoints, m->geom_type[0], m->geom_type[1], m->mesh_facenum[m->geom_dataid[0]], m->mesh_facenum[m->geom_dataid[1]], n);
  for (int margin=-1; margin<=1; margin++) {
    int a=mj_maxContact(m,0,1,margin), b=mj_maxContact(m,1,0,margin);
    printf(" cap[%d]=%d,%d", margin,a,b);
    if (a < n || b < n) safe=0;
  }
  printf(" safe=%d\n",safe);fflush(stdout);
  if (safe || atoi(argv[3])) {
    mj_forward(m,d);
    printf("forward=%d\n",d->ncon);
    if (d->ncon != n) return 5;
  }
  mj_deleteData(d);mj_deleteModel(m);
  return safe?0:10;
}
