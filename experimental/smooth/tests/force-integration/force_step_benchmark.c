#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
int main(int argc, char** argv) {
  if (argc != 3) return 1;
  mjModel* m=mj_loadModel(argv[1],NULL); if (!m) return 2;
  mjData* d=mj_makeData(m); if (!d) return 3;
  int batches=atoi(argv[2]); if (batches<=0) return 4;
  double* durations=calloc(batches,sizeof(double)); if (!durations) return 5;
  double* cpu_durations=calloc(batches,sizeof(double)); if (!cpu_durations) return 5;
  double checksum=0; struct timespec start,end,cpu_start,cpu_end;
  for (int b=0;b<batches;b++) {
    mj_resetData(m,d);
    for (int k=0;k<m->nv;k++) {
      d->qvel[k]=((b%11-5)*.005)*(k+1);
    }
    for (int k=0;k<m->nu;k++) d->ctrl[k]=.1+.01*(b%5);
    for (int k=0;k<m->na;k++) d->act[k]=.2+.01*(b%3);
    clock_gettime(CLOCK_MONOTONIC,&start);
    clock_gettime(CLOCK_THREAD_CPUTIME_ID,&cpu_start);
    for (int s=0;s<64;s++) mj_step(m,d);
    clock_gettime(CLOCK_THREAD_CPUTIME_ID,&cpu_end);
    cpu_durations[b]=(cpu_end.tv_sec-cpu_start.tv_sec)+(cpu_end.tv_nsec-cpu_start.tv_nsec)*1e-9;
    clock_gettime(CLOCK_MONOTONIC,&end);
    durations[b]=(end.tv_sec-start.tv_sec)+(end.tv_nsec-start.tv_nsec)*1e-9;
    for (int k=0;k<m->nq;k++) checksum+=d->qpos[k];
    for (int k=0;k<m->nv;k++) checksum+=d->qvel[k];
    for (int k=0;k<m->na;k++) checksum+=d->act[k];
    for (int k=0;k<mjNWARNING;k++) if (d->warning[k].number) return 6;
  }
  printf("%.17g\n",checksum);
  for (int b=0;b<batches;b++) printf("%.17g\n",durations[b]);
  for (int b=0;b<batches;b++) printf("%.17g\n",cpu_durations[b]);
  free(cpu_durations); free(durations); mj_deleteData(d); mj_deleteModel(m);
  return 0;
}
