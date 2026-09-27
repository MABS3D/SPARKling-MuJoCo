#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
static double now(void) {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec + 1e-9*t.tv_nsec;
}
int main(int argc, char **argv) {
  if (argc != 4 || mj_version() != 3014000) return 2;
  int steps=atoi(argv[2]), samples=atoi(argv[3]);
  if (steps < 1 || samples < 1) return 2;
  mjModel *m=mj_loadModel(argv[1], NULL);
  if (!m || m->nq != m->nv) return 2;
  mjData *d=mj_makeData(m);
  int size=m->nq+2*m->nv;
  mjtNum *input=calloc(size ? size : 1, sizeof(mjtNum));
  if (!d || !input) return 2;
  for (int i=0;i<size;++i) if (scanf("%lf",input+i)!=1) return 2;
  for (int s=0;s<=samples;++s) {
    mj_resetData(m,d);
    memcpy(d->qpos,input,m->nq*sizeof(mjtNum));
    memcpy(d->qvel,input+m->nq,m->nv*sizeof(mjtNum));
    memcpy(d->qfrc_applied,input+m->nq+m->nv,m->nv*sizeof(mjtNum));
    double start=now();
    for (int i=0;i<steps;++i) mj_step(m,d);
    double elapsed=now()-start;
    for (int i=0;i<mjNWARNING;++i) if (d->warning[i].number) return 3;
    if (s) printf("timing %.17g\n",elapsed);
  }
  mj_kinematics(m,d);
  for (int b=1;b<m->nbody;++b) {
    printf("position %.17g %.17g %.17g\n",d->xpos[3*b],d->xpos[3*b+1],d->xpos[3*b+2]);
    int a=m->body_dofadr[b];
    if (m->body_dofnum[b]==0) printf("velocity 0 0 0\n");
    else if (m->body_dofnum[b]==3) printf("velocity %.17g %.17g %.17g\n",d->qvel[a],d->qvel[a+1],d->qvel[a+2]);
    else return 2;
  }
  free(input); mj_deleteData(d); mj_deleteModel(m);
  return 0;
}
