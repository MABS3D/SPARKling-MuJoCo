// Benchmark harness only; calls the unmodified official mj_collision.
#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include <stdint.h>
#include <time.h>

// An opaque external call for Ada LTO, outside production sources. It makes
// the entire output buffer observable without timing a full checksum walk.
__attribute__((noinline, noclone))
void scene_escape(const void* buffer, int length) {
  __asm__ __volatile__("" : : "r"(buffer), "r"(length) : "memory");
}

double scene_time_frames(const mjModel* m, mjData** frames, int nf, int repetitions,
                         uint64_t* count, double* digest) {
  for (int r=0; r<4; ++r) for (int f=0; f<nf; ++f) mj_collision(m, frames[f]);
  struct timespec start, end;
  uint64_t total=0;
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int r=0; r<repetitions; ++r) for (int f=0; f<nf; ++f) {
    mjData* d=frames[f];
    mj_collision(m, d);
    scene_escape(d->contact, d->ncon);
    total+=d->ncon;
  }
  clock_gettime(CLOCK_MONOTONIC, &end);
  *count=total;
  // Diagnostic checksum after the timer, in canonical ID orientation.
  mjData* d=frames[nf-1]; double sum=0;
  for (int i=0; i<d->ncon; ++i) {
    const mjContact* c=d->contact+i;
    int a=c->geom[0], b=c->geom[1], reverse=a>b;
    if (reverse) { int t=a; a=b; b=t; }
    sum+=1+(uint64_t)a*4096+b;
    sum+=c->dist;
    for (int k=0; k<3; ++k) sum+=c->pos[k];
    for (int k=0; k<3; ++k) sum+=(reverse?-1:1)*c->frame[k];
  }
  *digest=sum;
  return ((end.tv_sec-start.tv_sec)*1e9+end.tv_nsec-start.tv_nsec)/(repetitions*nf);
}
