// Unchanged extract: Copyright 2021 DeepMind Technologies Limited.
// Apache-2.0: https://www.apache.org/licenses/LICENSE-2.0
#include <mujoco/mujoco.h>
#include "engine/engine_util_blas.h"
#include "engine/engine_util_misc.h"
#include "engine/engine_util_spatial.h"
static int mj_vertBodyWeight(const mjModel* m, const mjData* d, int f, int* v,
                             int* body, mjtNum* bweight, const mjtNum* vweight, int nw) {
  if (nw == 0) {
    return 0;
  }

  // determine sign: vweight may be negative for side-0 of a contact pair
  mjtNum sign = vweight[0] < 0 ? -1 : 1;

  // compute parametric coordinates using absolute weights
  mjtNum coord[3] = {0, 0, 0};
  for (int i = 0; i < nw; i++) {
    mju_addToScl3(coord, m->flex_vert0 + 3*v[i], mju_abs(vweight[i]));
  }

  int interp = m->flex_interp[f];
  int order = interp < 0 ? -interp : interp;
  int npc = (order+1)*(order+1)*(order+1);  // number of nodes per cell

  // grid dimensions for shell mode
  int nx = 0, ny = 0, nz = 0;
  if (interp < 0) {
    nx = m->flex_cellnum[3*f+0] * order + 1;
    ny = m->flex_cellnum[3*f+1] * order + 1;
    nz = m->flex_cellnum[3*f+2] * order + 1;
  }

  // cell lookup: get local coords and node indices
  mjtNum local[3];
  int nodeindices[27];  // max npc for quadratic: 3^3 = 27
  mju_cellLookup(coord, m->flex_cellnum+3*f, order, local, nodeindices);

  // evaluate basis functions for this cell's local nodes
  int nstart = m->flex_nodeadr[f];
  int nb = 0;

  if (!m->flex_nodebodyid) {
    return 0;
  }

  if (npc > 27) {
    for (int j = 0; j < npc; j++) {
      mjtNum w = mju_evalBasis(local, j, order);
      if (w < 1e-5) {
        continue;
      }

      int idx = nodeindices[j];

      // shell mode: map interior nodes to boundary
      if (interp < 0) {
        int k_idx = idx % nz;
        int rest = idx / nz;
        int j_idx = rest % ny;
        int i_idx = rest / ny;

        if (i_idx > 0 && i_idx < nx-1 && j_idx > 0 && j_idx < ny-1 && k_idx > 0 && k_idx < nz-1) {
          mju_shellTFIWeights(nx, ny, nz, i_idx, j_idx, k_idx, sign * w, &nb, body, bweight, m->flex_nodebodyid, nstart);
          continue;
        }
      }

      // add node, check for duplicates (especially needed when combining with TFI)
      int b = m->flex_nodebodyid[nstart + idx];
      int found = 0;
      for (int k = 0; k < nb; k++) {
        if (body[k] == b) {
          if (bweight) bweight[k] += sign * w;
          found = 1;
          break;
        }
      }
      if (!found) {
        if (bweight) bweight[nb] = sign * w;
        body[nb++] = b;
      }
    }
  } else {
    mjtNum basis[27];
    mju_evalBasisArray(basis, local, order);

    for (int j = 0; j < npc; j++) {
      mjtNum w = basis[j];
      if (w < 1e-5) {
        continue;
      }

      int idx = nodeindices[j];

      // shell mode: map interior nodes to boundary
      if (interp < 0) {
        int k_idx = idx % nz;
        int rest = idx / nz;
        int j_idx = rest % ny;
        int i_idx = rest / ny;

        if (i_idx > 0 && i_idx < nx-1 && j_idx > 0 && j_idx < ny-1 && k_idx > 0 && k_idx < nz-1) {
          mju_shellTFIWeights(nx, ny, nz, i_idx, j_idx, k_idx, sign * w, &nb, body, bweight, m->flex_nodebodyid, nstart);
          continue;
        }
      }

      // add node, check for duplicates (especially needed when combining with TFI)
      int b = m->flex_nodebodyid[nstart + idx];
      int found = 0;
      for (int k = 0; k < nb; k++) {
        if (body[k] == b) {
          if (bweight) bweight[k] += sign * w;
          found = 1;
          break;
        }
      }
      if (!found) {
        if (bweight) bweight[nb] = sign * w;
        body[nb++] = b;
      }
    }
  }


  return nb;
}
int weights(int degree, const int* cells, const double* vertices, const double* weights,
            int nw, int* nodebodies, int* bodies, double* result, double* coord) {
  mjModel m = {0}; int start=0, v[4]={0,1,2,3};
  m.flex_interp=&degree; m.flex_cellnum=(int*)cells; m.flex_nodeadr=&start;
  m.flex_vert0=(double*)vertices; m.flex_nodebodyid=nodebodies;
  coord[0]=coord[1]=coord[2]=0;
  for(int i=0;i<nw;i++)mju_addToScl3(coord,vertices+3*i,mju_abs(weights[i]));
  return mj_vertBodyWeight(&m,0,0,v,bodies,result,weights,nw);
}
