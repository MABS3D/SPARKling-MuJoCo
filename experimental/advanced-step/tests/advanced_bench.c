#include <mujoco/mujoco.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
int main(int argc, char** argv) {
  if(argc!=3) return 1;
  mjModel* m=mj_loadModel(argv[1],NULL); if(!m) return 2;
  mjData* d=mj_makeData(m); if(!d) return 3;
  int batches=atoi(argv[2]); if(batches<=0) return 4;
  double* wall=calloc(batches,sizeof(double)), *cpu=calloc(batches,sizeof(double));
  if(!wall||!cpu) return 5;
  double checksum=0; struct timespec a,b,ca,cb;
  for(int j=0;j<batches;j++) {
    mj_resetData(m,d);
    for(int k=0;k<m->nv;k++) d->qvel[k]=(k%5-2)*.005;
    for(int k=0;k<m->nu;k++) d->ctrl[k]=(k%3-1)*.01;
    clock_gettime(CLOCK_MONOTONIC,&a); clock_gettime(CLOCK_THREAD_CPUTIME_ID,&ca);
    for(int s=0;s<128;s++) mj_step(m,d);
    clock_gettime(CLOCK_THREAD_CPUTIME_ID,&cb); clock_gettime(CLOCK_MONOTONIC,&b);
    cpu[j]=(cb.tv_sec-ca.tv_sec)+(cb.tv_nsec-ca.tv_nsec)*1e-9;
    wall[j]=(b.tv_sec-a.tv_sec)+(b.tv_nsec-a.tv_nsec)*1e-9;
    for(int k=0;k<m->nq;k++) checksum+=d->qpos[k];
    for(int k=0;k<m->nv;k++) checksum+=d->qvel[k];
    checksum+=d->time;
    for(int k=0;k<m->na;k++) checksum+=d->act[k];
    for(int k=0;k<mjNWARNING;k++) if(d->warning[k].number) return 6;
  }
  printf("%.17g\n",checksum);
  for(int j=0;j<batches;j++) printf("%.17g\n",wall[j]);
  for(int j=0;j<batches;j++) printf("%.17g\n",cpu[j]);
  free(wall); free(cpu); mj_deleteData(d); mj_deleteModel(m); return 0;
}
