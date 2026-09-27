/* Oracle calls the actual pinned MuJoCo scalar implementation. */
#include <stdio.h>
#include <string.h>
#include "engine/engine_util_blas.h"
static void put(const mjtNum* v, int n) {
  for (int i=0; i<n; ++i) printf("%.17g ", v[i]);
}
static int get(mjtNum* a, int n) {
  for (int i=0; i<n; ++i) if (scanf("%lf", a+i) != 1) return 0;
  return 1;
}
int main(int argc, char** argv) {
  int transpose_only = argc == 2 && strcmp(argv[1], "--transpose-only") == 0;
  if (argc != 1 && !transpose_only) return 2;
  enum { MAX_DIM = 128, MAX_COMPONENTS = MAX_DIM * MAX_DIM };
  int nr, nc, nk, ni, count, ind[128];
  mjtNum a[MAX_COMPONENTS], b[MAX_COMPONENTS], c[MAX_COMPONENTS], e[MAX_COMPONENTS];
  mjtNum v[MAX_DIM], u[MAX_DIM], d[MAX_DIM], r[MAX_COMPONENTS];
  while ((count=scanf("%d %d %d %d", &nr, &nc, &nk, &ni)) != EOF) {
    if (count!=4 || nr<0 || nr>MAX_DIM || nc<0 || nc>MAX_DIM || nk<0 || nk>MAX_DIM || ni<0 || ni>128) return 2;
    if (!get(a,nr*nc) || !get(b,nc*nk) || !get(c,nk*nc) || !get(e,nr*nk) ||
        !get(v,nc) || !get(u,nr) || !get(d,nr)) return 2;
    for (int i=0; i<ni; ++i) if (scanf("%d", ind+i)!=1 || ind[i]<0 || ind[i]>=nr) return 2;
    if (transpose_only) {
      mju_transpose(r,a,nr,nc); put(r,nr*nc); puts("");
      continue;
    }
    mju_mulMatVec(r,a,v,nr,nc); put(r,nr);
    mju_mulMatTVec(r,a,u,nr,nc); put(r,nc);
    mju_transpose(r,a,nr,nc); put(r,nr*nc);
    mju_eye(r,nc); put(r,nc*nc);
    mju_fill(r,-7,nr*nc); mju_copyRows(r,a,ind,ni,nc); put(r,nr*nc);
    mju_mulMatMat(r,a,b,nr,nc,nk); put(r,nr*nk);
    mju_mulMatMatT(r,a,c,nr,nc,nk); put(r,nr*nk);
    mju_mulMatTMat(r,a,e,nr,nc,nk); put(r,nc*nk);
    mju_sqrMatTD(r,a,NULL,nr,nc); put(r,nc*nc);
    mju_sqrMatTD_impl(r,a,NULL,nr,nc,0); put(r,nc*nc);
    mju_sqrMatTD(r,a,d,nr,nc); put(r,nc*nc);
    mju_sqrMatTD_impl(r,a,d,nr,nc,0); put(r,nc*nc);
    if (nr==nc) { mju_symmetrize(r,a,nr); put(r,nr*nr); printf("%.17g ",mju_mulVecMatVec(u,a,v,nr)); }
    if (nr==3 && nc==3 && nk==3) {
      mju_copy9(r,a); put(r,9);
      mju_mulMatVec3(r,a,v); put(r,3); mju_mulMatTVec3(r,a,v); put(r,3);
      mju_mulMatMat3(r,a,b); put(r,9); mju_mulMatTMat3(r,a,b); put(r,9); mju_mulMatMatT3(r,a,b); put(r,9);
    }
    puts("");
  }
  return 0;
}
