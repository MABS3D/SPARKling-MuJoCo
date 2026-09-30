#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
static double now(void) {
  struct timespec t;if (clock_gettime(CLOCK_MONOTONIC,&t)) exit(2);
  return t.tv_sec+t.tv_nsec*1e-9;
}
int main(int argc,char** argv) {
  if (argc!=6 || mj_version()!=3014000) return 2;
  mjModel* m=mj_loadModel(argv[1],NULL);if (!m) return 2;
  mjData* d=mj_makeData(m);if (!d) return 2;
  FILE* f=fopen(argv[2],"r");if (!f) return 2;
  int frames,steps=atoi(argv[3]),samples=atoi(argv[4]),warmups=atoi(argv[5]);
  if (fscanf(f,"%d",&frames)!=1 || frames<1 || steps<1 || samples<1 || warmups<0) return 2;
  int count=m->nq+m->nv+m->nu+m->na;
  double* initial=calloc(count,sizeof(double));if (!initial) return 2;
  for (int k=0;k<count;k++) if (fscanf(f,"%lf",initial+k)!=1) return 2;
  fclose(f);
  for (int run=0;run<warmups+samples;run++) {
    mj_resetData(m,d);
    mju_copy(d->qpos,initial,m->nq);mju_copy(d->qvel,initial+m->nq,m->nv);
    mju_copy(d->ctrl,initial+m->nq+m->nv,m->nu);mju_copy(d->act,initial+m->nq+m->nv+m->nu,m->na);
    double start=now();for (int k=0;k<steps;k++) mj_step(m,d);double elapsed=now()-start;
    for (int k=0;k<mjNWARNING;k++) if (d->warning[k].number) return 3;
    if (run>=warmups) {
      printf("sample %.17g\nstate %.17g",elapsed,d->time);
      for (int k=0;k<m->nq;k++) printf(" %.17g",d->qpos[k]);
      for (int k=0;k<m->nv;k++) printf(" %.17g",d->qvel[k]);
      for (int k=0;k<m->na;k++) printf(" %.17g",d->act[k]);
      putchar('\n');
    }
  }
  free(initial);mj_deleteData(d);mj_deleteModel(m);return 0;
}
