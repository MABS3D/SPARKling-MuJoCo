#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#ifndef REFERENCE_VERSION
#error "Set the exact pinned reference version"
#endif
static double now(void) {
  struct timespec t;
  if (clock_gettime(CLOCK_MONOTONIC, &t)) exit(2);
  return t.tv_sec + t.tv_nsec * 1e-9;
}
static void read_values(double* p, int n) {
  for (int i=0; i<n; ++i) if (scanf("%lf", p+i) != 1) exit(2);
}
static void emit(const char* name, const double* p, int n) {
  printf("%s", name);
  for (int i=0; i<n; ++i) printf(" %.17g", p[i]);
  putchar('\n');
}
int main(int argc, char** argv) {
  if (argc != 5 || mj_version() != REFERENCE_VERSION) return 2;
  int steps=atoi(argv[2]), samples=atoi(argv[3]), warmups=atoi(argv[4]);
  if (steps<1 || samples<1 || warmups<0) return 2;
  mjModel* m=mj_loadModel(argv[1], NULL);
  if (!m || m->na) return 2;
  mjData* d=mj_makeData(m);
  if (!d) return 2;
  int nq=m->nq, nv=m->nv, nu=m->nu, nx=6*m->nbody;
  double* input=calloc((size_t)nq+2*nv+nu+nx, sizeof(double));
  int width=nq+nv+2;
  double* output=calloc((size_t)samples*width, sizeof(double));
  if (!input || !output) return 2;
  read_values(input,nq+2*nv+nu+nx);
  for (int run=0; run<warmups+samples; ++run) {
    mj_resetData(m,d);
    mju_copy(d->qpos,input,nq); mju_copy(d->qvel,input+nq,nv);
    mju_copy(d->ctrl,input+nq+nv,nu); mju_copy(d->qfrc_applied,input+nq+nv+nu,nv);
    mju_copy(d->xfrc_applied,input+nq+2*nv+nu,nx); d->time=.125;
    double start=now();
    for (int i=0; i<steps; ++i) mj_step(m,d);
    double elapsed=now()-start;
    for (int i=0; i<mjNWARNING; ++i) if (d->warning[i].number) return 3;
    if (run>=warmups) {
      double* row=output+(run-warmups)*width;
      row[0]=elapsed; mju_copy(row+1,d->qpos,nq); mju_copy(row+1+nq,d->qvel,nv);
      row[width-1]=d->time;
    }
  }
  for (int i=0; i<samples; ++i) {
    double* row=output+i*width;
    emit("sample",row,1); emit("qpos",row+1,nq); emit("qvel",row+1+nq,nv); emit("time",row+width-1,1);
  }
  free(output); free(input); mj_deleteData(d); mj_deleteModel(m); return 0;
}
