// Copyright 2021 DeepMind Technologies Limited
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "engine/engine_util_sparse.h"
#define mju_abs fabs
#define mjERROR(...) abort()
static void mju_copy(mjtNum* d, const mjtNum* s, int n) { if(n) memcpy(d,s,n*sizeof(mjtNum)); }
static void mju_copyInt(int* d, const int* s, int n) { if(n) memcpy(d,s,n*sizeof(int)); }
int mju_factorLU(mjtNum* restrict A, int n, int* pivot) {
  for (int k=0; k < n; k++) {
    // initialize pivot
    pivot[k] = k;

    // find pivot: max absolute value in column k, rows k..n-1
    mjtNum maxval = mju_abs(A[k*n+k]);
    int maxrow = k;
    for (int i=k+1; i < n; i++) {
      mjtNum val = mju_abs(A[i*n+k]);
      if (val > maxval) {
        maxval = val;
        maxrow = i;
      }
    }

    // check singularity
    if (maxval < mjMINVAL) {
      return 0;
    }

    // swap rows k and maxrow
    if (maxrow != k) {
      pivot[k] = maxrow;
      for (int j=0; j < n; j++) {
        mjtNum tmp = A[k*n+j];
        A[k*n+j] = A[maxrow*n+j];
        A[maxrow*n+j] = tmp;
      }
    }

    // compute multipliers and update trailing submatrix
    mjtNum diaginv = 1.0 / A[k*n+k];
    for (int i=k+1; i < n; i++) {
      A[i*n+k] *= diaginv;
      mjtNum Aik = A[i*n+k];
      for (int j=k+1; j < n; j++) {
        A[i*n+j] -= Aik * A[k*n+j];
      }
    }
  }

  return 1;
}

void mju_solveLU(mjtNum* restrict x, const mjtNum* LU, const mjtNum* b, const int* pivot, int n) {
  // copy b into x
  mju_copy(x, b, n);

  // apply row permutation and forward substitution: solve L*y = P*b
  for (int i=0; i < n; i++) {
    // apply pivot swap
    if (pivot[i] != i) {
      mjtNum tmp = x[i];
      x[i] = x[pivot[i]];
      x[pivot[i]] = tmp;
    }

    // subtract known terms
    for (int j=0; j < i; j++) {
      x[i] -= LU[i*n+j] * x[j];
    }
  }

  // back substitution: solve U*x = y
  for (int i=n-1; i >= 0; i--) {
    for (int j=i+1; j < n; j++) {
      x[i] -= LU[i*n+j] * x[j];
    }
    x[i] /= LU[i*n+i];
  }
}

int mju_factorLUSparse(mjtNum* LU, int n, int* scratch,
                       const int* rownnz, const int* rowadr, const int* colind,
                       const int* index) {
  int* remaining = scratch;
  int clamped = -1;

  // set remaining = rownnz
  if (index) {
    for (int i=0; i < n; i++) {
      remaining[i] = rownnz[index[i]];
    }
  } else {
    mju_copyInt(remaining, rownnz, n);
  }

  // diagonal elements (i,i)
  for (int r=n-1; r >= 0; r--) {
    int i = index ? index[r] : r;

    // get address of last remaining element of row i, adjust remaining counter
    int ii = rowadr[i] + remaining[r] - 1;
    remaining[r]--;

    // make sure ii is on diagonal
    if (colind[ii] != i) {
      mjERROR("missing diagonal element");
    }

    // near-singular pivot: clamp, preserving the sign
    if (mju_abs(LU[ii]) < mjMINVAL) {
      LU[ii] = LU[ii] < 0 ? -mjMINVAL : mjMINVAL;
      if (clamped < 0) {
        clamped = i;
      }
    }

    // rows j above i
    for (int c=r-1; c >= 0; c--) {
      int j = index ? index[c] : c;

      // get address of last remaining element of row j
      int ji = rowadr[j] + remaining[c] - 1;

      // process row j if (j,i) is non-zero
      if (colind[ji] == i) {
        // adjust remaining counter
        remaining[c]--;

        // (j,i) = (j,i) / (i,i)
        LU[ji] = LU[ji] / LU[ii];
        mjtNum LUji = LU[ji];

        // (j,k) = (j,k) - (i,k) * (j,i) for k<i; handle incompatible sparsity
        int icnt = rowadr[i], jcnt = rowadr[j];
        while (jcnt < rowadr[j]+remaining[c]) {
          // both non-zero
          if (colind[icnt] == colind[jcnt]) {
            // update LU, advance counters
            LU[jcnt++] -= LU[icnt++] * LUji;
          }

          // only (j,k) non-zero
          else if (colind[icnt] > colind[jcnt]) {
            // advance j counter
            jcnt++;
          }

          // only (i,k) non-zero
          else {
            mjERROR("requires fill-in");
          }
        }

        // make sure both rows fully processed
        if (icnt != rowadr[i]+remaining[r] || jcnt != rowadr[j]+remaining[c]) {
          mjERROR("row processing incomplete");
        }
      }
    }
  }

  // make sure remaining points to diagonal
  for (int r=0; r < n; r++) {
    int i = index ? index[r] : r;
    if (remaining[r] < 0 || colind[rowadr[i]+remaining[r]] != i) {
      mjERROR("unexpected sparse matrix structure");
    }
  }

  return clamped;
}

void mju_solveLUSparse(mjtNum* res, const mjtNum* LU, const mjtNum* vec, int n,
                       const int* rownnz, const int* rowadr, const int* diag, const int* colind,
                       const int* index) {
  // solve (U+I)*res = vec
  for (int k=n-1; k >= 0; k--) {
    int i = index ? index[k] : k;

    // init: diagonal of (U+I) is 1
    res[i] = vec[i];

    int d1 = diag[i]+1;
    int nnz = rownnz[i] - d1;
    if (nnz > 0) {
      int adr = rowadr[i] + d1;
      res[i] -= mju_dotSparse(LU+adr, res, nnz, colind+adr);
    }
  }

  //------------------ solve L*res(new) = res
  for (int k=0; k < n; k++) {
    int i = index ? index[k] : k;

    // res[i] -= sum_k<i res[k]*LU(i,k)
    int d = diag[i];
    int adr = rowadr[i];
    if (d > 0) {
      res[i] -= mju_dotSparse(LU+adr, res, d, colind+adr);
    }

    // divide by diagonal element of L
    res[i] /= LU[adr + d];
  }
}
