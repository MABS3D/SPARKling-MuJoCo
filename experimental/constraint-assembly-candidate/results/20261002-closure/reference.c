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

#include <mujoco/mujoco.h>
#define mjMAX(a,b) ((a)>(b)?(a):(b))
#define mjERROR(...) mju_error(__VA_ARGS__)
static void mj_addConstraint(const mjModel* m, mjData* d,
                             const mjtNum* jac, const mjtNum* pos,
                             const mjtNum* margin, mjtNum frictionloss,
                             int size, int type, int id, int NV, const int* chain) {
  int empty, nv = m->nv, nefc = d->nefc;
  int *nnz = d->efc_J_rownnz, *adr = d->efc_J_rowadr, *ind = d->efc_J_colind;
  mjtNum *J = d->efc_J;

  // init empty guard for constraints other than contact
  if (type == mjCNSTR_CONTACT_FRICTIONLESS ||
      type == mjCNSTR_CONTACT_PYRAMIDAL ||
      type == mjCNSTR_CONTACT_ELLIPTIC) {
    empty = 0;
  } else {
    empty = 1;
  }

  // dense: copy entire Jacobian
  if (!mj_isSparse(m)) {
    // make sure jac is not empty
    if (empty) {
      for (int i=0; i < size*nv; i++) {
        if (jac[i]) {
          empty = 0;
          break;
        }
      }
    }

    // copy if not empty
    if (!empty) {
      mju_copy(J + nefc*nv, jac, size*nv);
    }
  }

  // sparse: copy chain
  else {
    // clamp NV (in case -1 was used in constraint construction)
    NV = mjMAX(0, NV);

    if (NV) {
      empty = 0;
    } else if (empty) {
      // all rows are empty, return early
      return;
    }

    // chain required in sparse mode
    if (NV && !chain) {
      mjERROR("called with dense arguments");
    }

    // process size elements
    for (int i=0; i < size; i++) {
      // set row address
      adr[nefc+i] = (nefc+i ? adr[nefc+i-1]+nnz[nefc+i-1] : 0);

      // set row descriptor
      nnz[nefc+i] = NV;

      // copy if not empty
      if (NV) {
        mju_copyInt(ind + adr[nefc+i], chain, NV);
        mju_copy(J + adr[nefc+i], jac + i*NV, NV);
      }
    }
  }

  // all rows empty: skip constraint
  if (empty) {
    return;
  }

  // set constraint pos, margin, frictionloss, type, id
  for (int i=0; i < size; i++) {
    d->efc_pos[nefc+i] = (pos ? pos[i] : 0);
    d->efc_margin[nefc+i] = (margin ? margin[i] : 0);
    d->efc_frictionloss[nefc+i] = frictionloss;
    d->efc_type[nefc+i] = type;
    d->efc_id[nefc+i] = id;
  }

  // increase counters
  d->nefc += size;
  if (type == mjCNSTR_EQUALITY) {
    d->ne += size;
  } else if (type == mjCNSTR_FRICTION_DOF || type == mjCNSTR_FRICTION_TENDON) {
    d->nf += size;
  } else if (type == mjCNSTR_LIMIT_JOINT || type == mjCNSTR_LIMIT_TENDON) {
    d->nl += size;
  }
}

void reference_append(int nv, int size, int type, int id, int width,
  double loss, const int* chain, const double* jac, const double* pos,
  const double* margin, int* counts, int* nnz, int* adr, int* cols,
  double* vals, double* positions, double* margins, double* losses,
  int* types, int* ids) {
  mjModel m = {0}; mjData d = {0};
  m.nv = nv; m.opt.jacobian = mjJAC_SPARSE;
  d.nefc=counts[0]; d.ne=counts[1]; d.nf=counts[2]; d.nl=counts[3];
  d.efc_J_rownnz=nnz; d.efc_J_rowadr=adr; d.efc_J_colind=cols; d.efc_J=vals;
  d.efc_pos=positions; d.efc_margin=margins; d.efc_frictionloss=losses;
  d.efc_type=types; d.efc_id=ids;
  mj_addConstraint(&m,&d,jac,pos,margin,loss,size,type,id,width,chain);
  counts[0]=d.nefc; counts[1]=d.ne; counts[2]=d.nf; counts[3]=d.nl;
}
