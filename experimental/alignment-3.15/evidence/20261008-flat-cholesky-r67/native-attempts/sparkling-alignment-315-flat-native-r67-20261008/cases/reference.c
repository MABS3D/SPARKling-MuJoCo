#include "engine/engine_util_blas.h"
#include "engine/engine_util_sparse.h"
void reference_solve(mjtNum* res, const mjtNum* mat, const mjtNum* vec, int n,
                         const int* rownnz, const int* rowadr, const int* colind) {
  // copy input into result
  mju_copy(res, vec, n);

  // vec <- L^-T vec
  for (int i=n-1; i >= 0; i--) {
    if (res[i]) {
      // get rowadr[i], rownnz[i]
      const int adr = rowadr[i], nnz = rownnz[i];

      // x(i) /= L(i,i)
      res[i] /= mat[adr+nnz-1];
      mjtNum tmp = res[i];

      // x(j) -= L(i,j)*x(i), j=0:i-1
      for (int j=0; j < nnz-1; j++) {
        res[colind[adr+j]] -= mat[adr+j]*tmp;
      }
    }
  }

  // vec <- L^-1 vec
  for (int i=0; i < n; i++) {
    // get rowadr[i], rownnz[i]
    const int adr = rowadr[i], nnz = rownnz[i];

    // x(i) -= sum_j L(i,j)*x(j), j=0:i-1
    if (nnz > 1) {
      res[i] -= mju_dotSparse(mat+adr, res, nnz-1, colind+adr);
      // modulo AVX, the above line does
      // for (int j=0; j<nnz-1; j++)
      //   res[i] -= mat[adr+j]*res[colind[adr+j]];
    }


    // x(i) /= L(i,i)
    res[i] /= mat[adr+nnz-1];
  }
}


