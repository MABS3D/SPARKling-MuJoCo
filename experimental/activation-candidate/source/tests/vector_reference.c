/* Differential oracle: call the actual pinned MuJoCo implementations. */
#include <stdio.h>
#include "engine/engine_util_blas.h"
#include "engine/engine_util_spatial.h"

static void put(const mjtNum* v, int n) {
  for (int i = 0; i < n; ++i) printf("%.17g ", v[i]);
}
int main(void) {
  int n, first, count;
  mjtNum a[4096], b[4096], r[4096], scale, length;
  while ((count = scanf("%d %d", &n, &first)) != EOF) {
    if (count != 2 || n < 0 || n > 4096 || first < 0) return 2;
    for (int i = 0; i < n; ++i) if (scanf("%lf", a+i) != 1) return 2;
    for (int i = 0; i < n; ++i) if (scanf("%lf", b+i) != 1) return 2;
    if (scanf("%lf", &scale) != 1) return 2;
    mju_zero(r, n); put(r, n);
    mju_fill(r, scale, n); put(r, n);
    mju_copy(r, a, n); put(r, n);
    mju_scl(r, a, scale, n); put(r, n);
    mju_add(r, a, b, n); put(r, n);
    mju_sub(r, a, b, n); put(r, n);
    mju_copy(r, a, n); mju_addTo(r, b, n); put(r, n);
    mju_copy(r, a, n); mju_subFrom(r, b, n); put(r, n);
    mju_copy(r, a, n); mju_addToScl(r, b, scale, n); put(r, n);
    mju_addScl(r, a, b, scale, n); put(r, n);
    printf("%.17g %.17g %.17g %.17g ", mju_sum(a,n), mju_L1(a,n), mju_dot(a,b,n), mju_norm(a,n));
    mju_copy(r, a, n);
    /* mju_normalize requires n>0 even though mju_norm accepts n=0. */
    length = n ? mju_normalize(r, n) : 0;
    put(r, n); printf("%.17g ", length);
    if (n == 3) {
      mju_zero3(r); put(r, 3);
      mju_copy3(r, a); put(r, 3);
      printf("%d ", mju_equal3(a, b));
      mju_add3(r, a, b); put(r, 3);
      mju_sub3(r, a, b); put(r, 3);
      mju_scl3(r, a, scale); put(r, 3);
      mju_addScl3(r, a, b, scale); put(r, 3);
      mju_copy3(r, a); mju_addTo3(r, b); put(r, 3);
      mju_copy3(r, a); mju_subFrom3(r, b); put(r, 3);
      mju_copy3(r, a); mju_addToScl3(r, b, scale); put(r, 3);
      mju_cross(r, a, b); put(r, 3);
      printf("%.17g %.17g ", mju_norm3(a), mju_dist3(a, b));
      mju_copy3(r, a); length = mju_normalize3(r); put(r, 3); printf("%.17g ", length);
    } else if (n == 4) {
      mju_zero4(r); put(r, 4);
      mju_unit4(r); put(r, 4);
      mju_copy4(r, a); put(r, 4);
      /* normalize4 returns its input norm; MuJoCo has no standalone norm4. */
      mju_copy4(r, a); length = mju_normalize4(r);
      printf("%.17g ", length); put(r, 4); printf("%.17g ", length);
    }
    puts("");
  }
  return 0;
}
