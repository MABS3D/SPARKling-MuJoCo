// Adapted from MuJoCo 3.14.0, Copyright 2021 DeepMind Technologies Limited.
// SPDX-License-Identifier: Apache-2.0
// Test oracle only. Production Ada never links this file.
#include <mujoco/mujoco.h>
#include <math.h>
#include <string.h>

static int qcqp5(mjtNum* res, const mjtNum* Ain, const mjtNum* bin,
             const mjtNum* d, mjtNum r, int n) {
  mjtNum A[25], Ala[25], b[5];
  mjtNum la, val, deriv, tmp[5];

  // check size
  if (n > 5) {
    return 0;
  }

  // scale A,b so that constraint becomes x'*x <= r*r
  for (int i=0; i < n; i++) {
    b[i] = bin[i] * d[i];

    for (int j=0; j < n; j++) {
      A[j+i*n] = Ain[j+i*n] * d[i] * d[j];
    }
  }

  // Newton iteration
  la = 0;
  for (int iter=0; iter < 20; iter++) {
    // make A+la
    mju_copy(Ala, A, n*n);
    for (int i=0; i < n; i++) {
      Ala[i*(n+1)] += la;
    }

    // factorize, check rank with 1e-10 threshold
    if (mju_cholFactor(Ala, n, 1e-10) < n) {
      mju_zero(res, n);
      return 0;
    }

    // set res = -Ala \ b
    mju_cholSolve(res, Ala, b, n);
    mju_scl(res, res, -1, n);

    // val = b' * Ala^-2 * b - r*r
    val = mju_dot(res, res, n) - r*r;

    // check for convergence, or initial solution inside constraint set
    if (val < 1e-10) {
      break;
    }

    // deriv = -2 * b' * Ala^-3 * b
    mju_cholSolve(tmp, Ala, res, n);
    deriv = -2.0 * mju_dot(res, tmp, n);

    // compute update, exit if too small
    mjtNum delta = -val/deriv;
    if (delta < 1e-10) {
      break;
    }

    // update
    la += delta;
  }

  // undo scaling
  for (int i=0; i < n; i++) {
    res[i] = res[i] * d[i];
  }

  return (la != 0);
}



static double residual(int n, const double* ar, const double* r, const double* b,
                       const double* f, int row) {
  return b[row] + mju_dot(ar+row*n, f, n) - r[row]*f[row];
}
static double cost(const double* a, double* f, const double* old,
                   const double* res, int n) {
  double delta[5];
  mju_sub(delta, f, old, n);
  double change = .5*mju_mulVecMatVec(delta, a, delta, n) + mju_dot(delta, res, n);
  if (change > 1e-10) {mju_copy(f, old, n); return 0;}
  return change;
}
// Exact ordered operations from solNoSlip, adapted to caller-owned dense arrays.
void oracle_noslip(int n, const double* ar, const double* r, const double* b,
                  double* f, const int* type, const int* dim, const double* loss,
                  const double* mu, int maxiter, double tolerance, double scale,
                  int* iterations, double* final_improvement) {
  double inv[256], a[25], bc[5], res[5], old[5], x[5];
  *iterations=0; *final_improvement=0;
  for (int i=0; i<n; ++i) inv[i]=1/fmax(mjMINVAL, ar[i*(n+1)]-r[i]);
  for (int iter=0; iter<maxiter; ++iter) {
    double improvement=0;
    if (!iter) for (int i=0;i<n;i++) improvement+=.5*f[i]*f[i]*r[i];
    for (int i=0;i<n;i++) if(type[i]==1 || type[i]==2) {
      double res0=residual(n,ar,r,b,f,i), old0=f[i];
      f[i]-=res0*inv[i];
      if(f[i]<-loss[i]) f[i]=-loss[i]; else if(f[i]>loss[i]) f[i]=loss[i];
      double delta=f[i]-old0;
      improvement-=.5*delta*delta/inv[i] + delta*res0;
    }
    for (int i=0; i<n; i++) {
      if(type[i]==6) {
        for(int j=i;j<i+2*(dim[i]-1);j+=2) {
          for(int k=0;k<2;k++) {
            res[k]=residual(n,ar,r,b,f,j+k);old[k]=f[j+k];
            for(int t=0;t<2;t++) a[k*2+t]=ar[(j+k)*n+j+t];
            a[k*3]=fmax(1e-10,a[k*3]-r[j+k]);
          }
          for(int k=0;k<2;k++) bc[k]=res[k]-mju_dot(a+k*2,old,2);
          double mid=.5*(f[j]+f[j+1]);
          double k1=a[0]+a[3]-a[1]-a[2];
          double k0=mid*(a[0]-a[3])+bc[0]-bc[1];
          if(k1<mjMINVAL) f[j]=f[j+1]=mid;
          else {
            double y=-k0/k1;
            if(y<-mid){f[j]=0;f[j+1]=2*mid;}
            else if(y>mid){f[j]=2*mid;f[j+1]=0;}
            else{f[j]=mid+y;f[j+1]=mid-y;}
          }
          improvement-=cost(a,f+j,old,res,2);
        }
        i+=2*(dim[i]-1)-1;
      } else if(type[i]==7) {
        int width=dim[i]-1;
        for(int k=0;k<width;k++) {
          res[k]=residual(n,ar,r,b,f,i+1+k);old[k]=f[i+1+k];
          for(int t=0;t<width;t++) a[k*width+t]=ar[(i+1+k)*n+i+1+t];
          a[k*(width+1)]=fmax(1e-10,a[k*(width+1)]-r[i+1+k]);
        }
        for(int k=0;k<width;k++) bc[k]=res[k]-mju_dot(a+k*width,old,width);
        if(f[i]<mjMINVAL) mju_zero(f+i+1,width);
        else {
          int active;
          if(width==2) active=mju_QCQP2(x,a,bc,mu+i*5,f[i]);
          else if(width==3) active=mju_QCQP3(x,a,bc,mu+i*5,f[i]);
          else active=qcqp5(x,a,bc,mu+i*5,f[i],width);
          if(active) {
            double sum=0;for(int k=0;k<width;k++)sum+=x[k]*x[k]/(mu[i*5+k]*mu[i*5+k]);
            double scl=sqrt(f[i]*f[i]/fmax(mjMINVAL,sum));
            for(int k=0;k<width;k++)x[k]*=scl;
          }
          mju_copy(f+i+1,x,width);
        }
        improvement-=cost(a,f+i+1,old,res,width);
        i+=width;
      }
    }
    improvement*=scale;
    *iterations=iter+1;*final_improvement=improvement;
    if(improvement<tolerance)break;
  }
}
