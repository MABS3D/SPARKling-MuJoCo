// Benchmark wrapper; MuJoCo engine and private helper excerpts retain their licenses.
#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include "engine_util_sparse.h"
#include "engine_support.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

static double now(void) {
  struct timespec t; if (clock_gettime(CLOCK_MONOTONIC,&t)) exit(2);
  return t.tv_sec+t.tv_nsec*1e-9;
}
static void read_values(FILE* f, double* x, int n) {
  for (int i=0;i<n;i++) if (fscanf(f,"%lf",x+i)!=1) exit(2);
}
static void stage(const mjModel* m, mjData* d, double* next) {
  mj_transmission(m,d);
  mju_mulMatVecSparse(d->actuator_velocity,d->actuator_moment,d->qvel,m->nout,
                     d->moment_rownnz,d->moment_rowadr,d->moment_colind,NULL);
  mj_fwdActuation(m,d);
  for (int a=0;a<m->nactuator;a++) for (int k=0;k<m->actuator_actnum[a];k++) {
    int adr=m->actuator_actadr[a]+k;
    next[5*a+k]=mj_nextActivation(m,d,a,adr,d->act_dot[adr]);
  }
}
static void emit(const double* p,int n) {
  for (int k=0;k<n;k++) printf(" %.17g",p[k]);
}
static void dump(const mjModel* m,const mjData* d,const double* next,int frame) {
  printf("frame %d",frame);
  emit(d->actuator_length,m->nout); emit(d->actuator_velocity,m->nout); emit(d->actuator_force,m->nout);
  for (int a=0;a<m->nactuator;a++) for (int k=0;k<5;k++) {
    double dot=k<m->actuator_actnum[a]?d->act_dot[m->actuator_actadr[a]+k]:0;
    printf(" %.17g",dot);
  }
  emit(next,5*m->nactuator); emit(d->qfrc_actuator,m->nv);
  for (int o=0;o<m->nout;o++) {
    printf(" %d",d->moment_rownnz[o]);
    for (int k=d->moment_rowadr[o];k<d->moment_rowadr[o]+d->moment_rownnz[o];k++)
      printf(" %d %.17g",d->moment_colind[k],d->actuator_moment[k]);
  }
  putchar('\n');
}
int main(int argc,char** argv) {
  if (argc!=6 || mj_version()!=3014000) return 2;
  mjModel* m=mj_loadModel(argv[1],NULL); if (!m) return 2;
  FILE* f=fopen(argv[2],"r"); if (!f) return 2;
  int nf; if (fscanf(f,"%d",&nf)!=1 || nf<1) return 2;
  int steps=atoi(argv[3]),samples=atoi(argv[4]),warmups=atoi(argv[5]);
  if (steps<1 || samples<1 || warmups<0) return 2;
  mjData** frames=calloc(nf,sizeof(mjData*));
  double* next=calloc(5*m->nactuator,sizeof(double));
  if (!frames || !next) return 2;
  for (int i=0;i<nf;i++) {
    frames[i]=mj_makeData(m); if (!frames[i]) return 2;
    read_values(f,frames[i]->qpos,m->nq); read_values(f,frames[i]->qvel,m->nv);
    read_values(f,frames[i]->ctrl,m->nu); read_values(f,frames[i]->act,m->na);
    mj_forward(m,frames[i]); stage(m,frames[i],next); dump(m,frames[i],next,i);
  }
  fclose(f);
  double sink=0;
  for (int run=0;run<warmups+samples;run++) {
    double start=now();
    for (int k=0;k<steps;k++) {
      __asm__ __volatile__("":::"memory");
      mjData* d=frames[k%nf]; stage(m,d,next);
      sink+=d->actuator_force[0]+d->qfrc_actuator[m->nv-1]+next[5*m->nactuator-1];
    }
    double elapsed=now()-start;
    if (run>=warmups) printf("sample %.17g\n",elapsed);
  }
  printf("sink %.17g\n",sink);
  if (!isfinite(sink)) return 3;
  for (int i=0;i<nf;i++) {
    for (int w=0;w<mjNWARNING;w++) if (frames[i]->warning[w].number) return 3;
    mj_deleteData(frames[i]);
  }
  free(next); free(frames); mj_deleteModel(m); return 0;
}
