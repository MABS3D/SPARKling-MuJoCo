#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

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
  if (argc != 5 || mj_version() != 3014000) return 2;
  int steps=atoi(argv[2]), samples=atoi(argv[3]), warmups=atoi(argv[4]);
  if (steps<1 || samples<1 || warmups<0) return 2;
  mjModel* m=mj_loadModel(argv[1], NULL);
  if (!m || m->nq != m->nv) return 2;
  mjData* d=mj_makeData(m);
  if (!d) return 2;
  int n=m->nv, u=m->nu;
  double* input=calloc(3*n+u+1, sizeof(double));
  double* output=calloc((size_t)samples*(2*n+2), sizeof(double));
  if (!input || !output) return 2;
  read_values(input, 3*n+u);
  for (int run=0; run<warmups+samples; ++run) {
    mj_resetData(m,d);
    mju_copy(d->qpos,input,n); mju_copy(d->qvel,input+n,n);
    mju_copy(d->ctrl,input+2*n,u); mju_copy(d->qfrc_applied,input+2*n+u,n);
    d->time=.125;
    double start=now();
    for (int i=0; i<steps; ++i) mj_step(m,d);
    double elapsed=now()-start;
    for (int i=0; i<mjNWARNING; ++i) if (d->warning[i].number) return 3;
    if (run>=warmups) {
      double* row=output+(size_t)(run-warmups)*(2*n+2);
      row[0]=elapsed; row[1]=d->time;
      mju_copy(row+2,d->qpos,n); mju_copy(row+2+n,d->qvel,n);
    }
  }
  for (int run=0; run<samples; ++run) {
    double* row=output+(size_t)run*(2*n+2);
    emit("sample",row,1); emit("qpos",row+2,n); emit("qvel",row+2+n,n);
    emit("time",row+1,1);
  }
  free(input); free(output); mj_deleteData(d); mj_deleteModel(m);
  return 0;
}
