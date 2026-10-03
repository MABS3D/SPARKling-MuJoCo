#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

static double seconds(struct timespec a, struct timespec b) {
  return (b.tv_sec-a.tv_sec) + 1e-9*(b.tv_nsec-a.tv_nsec);
}

int main(int argc, char** argv) {
  if (argc != 3) return 1;
  mjModel* m = mj_loadModel(argv[1], NULL);
  if (!m) return 2;
  if (!strcmp(argv[2], "smooth")) m->opt.disableflags |= mjDSBL_CONSTRAINT;
  mjData* d = mj_makeData(m);
  int samples, steps;
  if (scanf("%d %d", &samples, &steps) != 2) return 3;
  for (int s=0; s<samples; ++s) {
    mj_resetData(m, d);
    for (int i=0; i<m->nq; ++i) if(scanf("%lf", d->qpos+i)!=1) return 4;
    for (int i=0; i<m->nv; ++i) if(scanf("%lf", d->qvel+i)!=1) return 4;
    for (int i=0; i<m->nmocap; ++i) {
      for(int k=0;k<3;++k) if(scanf("%lf", d->mocap_pos+3*i+k)!=1) return 4;
      for(int k=0;k<4;++k) if(scanf("%lf", d->mocap_quat+4*i+k)!=1) return 4;
    }
    mj_forward(m, d);
    struct timespec begin, end;
    clock_gettime(CLOCK_MONOTONIC, &begin);
    for (int k=0; k<steps; ++k) mj_step(m, d);
    clock_gettime(CLOCK_MONOTONIC, &end);
    printf("seconds %.17g\nstate", seconds(begin, end));
    for(int i=0;i<m->nq;++i) printf(" %.17g",d->qpos[i]);
    for(int i=0;i<m->nv;++i) printf(" %.17g",d->qvel[i]);
    printf(" %.17g",d->time);
    for(int i=0;i<m->na;++i) printf(" %.17g",d->act[i]);
    for(int i=0;i<3*m->nmocap;++i) printf(" %.17g",d->mocap_pos[i]);
    for(int i=0;i<4*m->nmocap;++i) printf(" %.17g",d->mocap_quat[i]);
    printf("\n");
  }
  mj_deleteData(d); mj_deleteModel(m);
  return 0;
}
