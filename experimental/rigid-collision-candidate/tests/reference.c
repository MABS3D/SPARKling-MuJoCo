// Test oracle and timing harness only. Production detection is entirely Ada.
#define _POSIX_C_SOURCE 200809L
#include <mujoco/mujoco.h>
#include "engine/engine_collision_driver.h"
#include <stdint.h>
#include <time.h>

int rigid_pair(const mjModel* m, mjData* d, int a, int b, double margin) {
  if (m->geom_type[a] > m->geom_type[b]) { int t=a; a=b; b=t; }
  mjfCollision f=mjCOLLISIONFUNC[m->geom_type[a]][m->geom_type[b]];
  if (!f) return 0;
  mjPreContact con[mjMAXCONPAIR];
  return f(m, d, con, a, b, margin) > 0;
}

double rigid_time(const mjModel* m, mjData* d, int repetitions, uint64_t* checksum) {
  struct timespec start, end;
  uint64_t sum=0;
  clock_gettime(CLOCK_MONOTONIC, &start);
  for (int i=0; i<repetitions; ++i) {
    mj_collision(m, d);
    int last_a=-1, last_b=-1;
    for (int j=0; j<d->ncon; ++j) {
      int a=d->contact[j].geom[0], b=d->contact[j].geom[1];
      if (a>b) {int t=a;a=b;b=t;}
      if (a!=last_a || b!=last_b) {sum+=1+(uint64_t)a*4096+b;last_a=a;last_b=b;}
    }
  }
  clock_gettime(CLOCK_MONOTONIC, &end);
  *checksum=sum;
  return ((end.tv_sec-start.tv_sec)*1e9+end.tv_nsec-start.tv_nsec)/repetitions;
}

#include "engine/engine_collision_gjk.h"
#include <stdlib.h>

int rigid_contacts(const mjModel* m, mjData* d, int a, int b, double margin, double* out) {
  int reverse=m->geom_type[a]>m->geom_type[b];
  if(reverse){int t=a;a=b;b=t;}
  mjfCollision f=mjCOLLISIONFUNC[m->geom_type[a]][m->geom_type[b]];
  if(!f)return 0;
  mjPreContact con[mjMAXCONPAIR];int n=f(m,d,con,a,b,margin);
  for(int i=0;i<n;i++) {
    out[10*i]=con[i].dist;
    for(int j=0;j<3;j++) {
      out[10*i+1+j]=con[i].pos[j];
      out[10*i+4+j]=(reverse?-1:1)*con[i].normal[j];
      out[10*i+7+j]=con[i].tangent[j];
    }
  }
  return n;
}

int rigid_convex_contacts(const mjModel* m,mjData* d,int a,int b,double margin,double* out) {
  mjCCDObj x,y;mjCCDStatus status;
  mjc_initCCDObj(&x,m,d,a,margin);mjc_initCCDObj(&y,m,d,b,margin);
  mjCCDConfig config={.max_iterations=m->opt.ccd_iterations,.tolerance=m->opt.ccd_tolerance,
    .max_contacts=1,.dist_cutoff=0,.npolygonmax=m->npolygonmax,.nmeshdegmax=m->nmeshdegmax};
  config.buffer=malloc(mjc_ccdSize(config.npolygonmax,config.nmeshdegmax,config.max_iterations));
  double distance=mjc_ccd(&config,&status,&x,&y);int n=0;
  if(distance<0) {
    n=status.nx;
    for(int i=0;i<n;i++) {
      double normal[3];mju_sub3(normal,status.x1+3*i,status.x2+3*i);mju_normalize3(normal);
      out[10*i]=margin+status.dist[i];
      for(int j=0;j<3;j++) {
        out[10*i+1+j]=.5*(status.x1[3*i+j]+status.x2[3*i+j]);out[10*i+4+j]=normal[j];out[10*i+7+j]=0;
      }
    }
  }
  free(config.buffer);return n;
}

// Raw CCD diagnostics: distances, simplex and native termination status.
double rigid_ccd_status(const mjModel* m, mjData* d, int a, int b,
                        double margin, int* info, double* vertices) {
  mjCCDObj x,y; mjCCDStatus status;
  mjc_initCCDObj(&x,m,d,a,margin);mjc_initCCDObj(&y,m,d,b,margin);
  mjCCDConfig config={.max_iterations=m->opt.ccd_iterations,
    .tolerance=m->opt.ccd_tolerance,.max_contacts=1,.dist_cutoff=0,
    .npolygonmax=m->npolygonmax,.nmeshdegmax=m->nmeshdegmax};
  config.buffer=malloc(mjc_ccdSize(config.npolygonmax,config.nmeshdegmax,config.max_iterations));
  double result=mjc_ccd(&config,&status,&x,&y);
  info[0]=status.gjk_iterations;info[1]=status.epa_iterations;info[2]=status.epa_status;
  info[3]=status.nsimplex;info[4]=status.separated;
  for(int i=0;i<4;i++)for(int j=0;j<3;j++)vertices[3*i+j]=status.simplex[i].vert[j];
  free(config.buffer);return result;
}

// Precomputed kinematic frames, selected by pointer in both benchmark loops.
double rigid_time_frames(const mjModel* m, mjData** frames, int nf,
                         int repetitions, uint64_t* checksum) {
  struct timespec start,end;uint64_t sum=0;
  clock_gettime(CLOCK_MONOTONIC,&start);
  for(int r=0;r<repetitions;r++)for(int f=0;f<nf;f++) {
    mjData* d=frames[f];mj_collision(m,d);
    int last_a=-1,last_b=-1;
    for(int j=0;j<d->ncon;j++) {
      int a=d->contact[j].geom[0],b=d->contact[j].geom[1];
      if(a>b){int t=a;a=b;b=t;}
      if(a!=last_a || b!=last_b){sum+=1+(uint64_t)a*4096+b;last_a=a;last_b=b;}
    }
  }
  clock_gettime(CLOCK_MONOTONIC,&end);*checksum=sum;
  return ((end.tv_sec-start.tv_sec)*1e9+end.tv_nsec-start.tv_nsec)/(repetitions*nf);
}

// Diagnostic reference only: original heightfield prism support does not set
// its vertex index, but native discrete EPA stops on repeated vertex indices.
// Keep the upstream algorithm and explicitly set the selected prism index.
#include "engine/engine_inline.h"
#include "engine/engine_macro.h"
static void indexed_prism_support(mjtNum res[3],mjCCDObj* obj,const mjtNum dir[3]) {
  int start=dir[2]<0?0:3,best=start;
  double value=mju_dot3(obj->data.hfield.prism[start],dir);
  for(int i=1;i<3;i++) {
    double v=mju_dot3(obj->data.hfield.prism[start+i],dir);
    if(v>value){value=v;best=start+i;}
  }
  obj->vertindex=best;mju_copy3(res,obj->data.hfield.prism[best]);
}
static int indexed_penetration(const mjModel* m,mjData* d,mjCCDObj* a,mjCCDObj* b,
                               mjPreContact* con,int maximum,double margin) {
  mjCCDConfig cfg={.max_iterations=m->opt.ccd_iterations,.tolerance=m->opt.ccd_tolerance,
    .max_contacts=maximum,.dist_cutoff=0,.npolygonmax=m->npolygonmax,.nmeshdegmax=m->nmeshdegmax};
  cfg.buffer=malloc(mjc_ccdSize(cfg.npolygonmax,cfg.nmeshdegmax,cfg.max_iterations));
  mjCCDStatus status;int n=0;
  if(mjc_ccd(&cfg,&status,a,b)<0) {
    n=status.nx;
    for(int i=0;i<n;i++) {
      con[i].dist=margin+status.dist[i];
      mju_add3(con[i].pos,status.x1+3*i,status.x2+3*i);mju_scl3(con[i].pos,con[i].pos,.5);
      mju_sub3(con[i].normal,status.x1+3*i,status.x2+3*i);mju_normalize3(con[i].normal);mju_zero3(con[i].tangent);
    }
  }
  free(cfg.buffer);return n;
}
static inline void addPrismVert(mjCCDObj* obj, int r, int c, int i, mjtNum dx, mjtNum dy, mjtNum margin) {
  // move old data
  mji_copy3(obj->data.hfield.prism[0], obj->data.hfield.prism[1]);
  mji_copy3(obj->data.hfield.prism[1], obj->data.hfield.prism[2]);
  mji_copy3(obj->data.hfield.prism[3], obj->data.hfield.prism[4]);
  mji_copy3(obj->data.hfield.prism[4], obj->data.hfield.prism[5]);

  int dr = 1 - i;

  // add new vertex at last position
  obj->data.hfield.prism[2][0] = obj->data.hfield.prism[5][0] = dx*c - obj->size[0];
  obj->data.hfield.prism[2][1] = obj->data.hfield.prism[5][1] = dy*(r + dr) - obj->size[1];
  obj->data.hfield.prism[5][2] = obj->data.hfield.hfield_data[(r + dr)*obj->data.hfield.hfield_ncol + c]*obj->size[2];

  // factor in margin
  obj->data.hfield.prism[5][2] += margin;
}


static int indexed_heightfield(const mjModel* m, mjData* d, mjPreContact* con, int g1, int g2,
                     mjtNum margin) {
  // hfield frame
  const mjtNum* pos1 = d->geom_xpos + 3*g1;
  const mjtNum* mat1 = d->geom_xmat + 9*g1;

  // geom2 frame
  mjtNum* pos2 = d->geom_xpos + 3*g2;
  mjtNum* mat2 = d->geom_xmat + 9*g2;

  // hfield data
  int hid = m->geom_dataid[g1];
  int nrow = m->hfield_nrow[hid];
  int ncol = m->hfield_ncol[hid];
  mjtNum size0 = m->hfield_size[4*hid + 0], size1 = m->hfield_size[4*hid + 1];
  mjtNum size2 = m->hfield_size[4*hid + 2], size3 = m->hfield_size[4*hid + 3];

  // try early return using box-sphere test

  // express geom2 pos in hfield frame
  mjtNum local_pos[3] = {pos2[0] - pos1[0], pos2[1] - pos1[1], pos2[2] - pos1[2]};
  mju_mulMatTVec3(local_pos, mat1, local_pos);

  // sphere radius is geom2 rbound + margin
  mjtNum radius = m->geom_rbound[g2] + margin;

  // box-sphere test
  if ((size0 < local_pos[0] - radius) || (-size0 > local_pos[0] + radius) ||
      (size1 < local_pos[1] - radius) || (-size1 > local_pos[1] + radius) ||
      (size2 < local_pos[2] - radius) || (-size3 > local_pos[2] + radius)) {
    return 0;
  }

  // ccd set up
  mjCCDObj obj1, obj2;
  mjc_initCCDObj(&obj1, m, d, g1, 0);
  mjc_initCCDObj(&obj2, m, d, g2, 0);
  obj1.support = indexed_prism_support;


  // try early return using AABB box-box test

  // express geom2 mat in hfield frame
  mjtNum mat[9];
  mji_mulMatTMat3(mat, mat1, mat2);

  mji_copy9(obj2.mat, mat);
  mji_copy3(obj2.pos, local_pos);

  mjtNum local_dir[3] = {0, 0, 0}, res[3];

  // get support point in +X
  local_dir[0] = 1;
  obj2.support(res, &obj2, local_dir);
  mjtNum xmax = res[0];

  // get support point in -X
  local_dir[0] = -1;
  obj2.support(res, &obj2, local_dir);
  mjtNum xmin = res[0];

  local_dir[0] = 0;

  // get support point in +Y
  local_dir[1] = 1;
  obj2.support(res, &obj2, local_dir);
  mjtNum ymax = res[1];

  // get support point in -Y
  local_dir[1] = -1;
  obj2.support(res, &obj2, local_dir);
  mjtNum ymin = res[1];

  local_dir[1] = 0;

  // get support point in +Z
  local_dir[2] = 1;
  obj2.support(res, &obj2, local_dir);
  mjtNum zmax = res[2];

  // get support point in -Z
  local_dir[2] = -1;
  obj2.support(res, &obj2, local_dir);
  mjtNum zmin = res[2];

  // AABB box-box test
  if ((xmin - margin > size0) || (xmax + margin < -size0) ||
      (ymin - margin > size1) || (ymax + margin < -size1) ||
      (zmin - margin > size2) || (zmax + margin < -size3)) {
    return 0;
  }

  // compute sub-grid bounds
  int cmin = (int) mju_floor((xmin + size0) / (2.0*size0) * (ncol-1));
  int cmax = (int) mju_ceil ((xmax + size0) / (2.0*size0) * (ncol-1));
  int rmin = (int) mju_floor((ymin + size1) / (2.0*size1) * (nrow-1));
  int rmax = (int) mju_ceil ((ymax + size1) / (2.0*size1) * (nrow-1));
  cmin = mjMAX(0, cmin);
  cmax = mjMIN(ncol-1, cmax);
  rmin = mjMAX(0, rmin);
  rmax = mjMIN(nrow-1, rmax);

  // geom margin needed for actual collision test
  obj2.margin = margin;

  // compute real-valued grid step
  mjtNum dx = (2.0*size0) / (ncol-1);
  mjtNum dy = (2.0*size1) / (nrow-1);

  // set zbottom value using base size
  mjtNum (*prism)[3] = obj1.data.hfield.prism;
  prism[0][2] = prism[1][2] = prism[2][2] = -size3;

  // process all prisms in subgrid
  int ncon = 0;
  for (int r=rmin; r < rmax; r++) {
    addPrismVert(&obj1, r, cmin, 0, dx, dy, margin);
    addPrismVert(&obj1, r, cmin, 1, dx, dy, margin);
    for (int c=cmin + 1; c <= cmax; c++) {
      for (int i=0; i < 2; i++) {
        // send vertex to prism constructor
        addPrismVert(&obj1, r, c, i, dx, dy, margin);

        // prism height test
        if (prism[3][2] < zmin && prism[4][2] < zmin && prism[5][2] < zmin) {
          continue;
        }

        // run penetration function, save contact
        if (indexed_penetration(m, d, &obj1, &obj2, con + ncon, 1, 0.0)) {
          // transform to global coordinates
          mji_copy3(local_dir, con[ncon].normal);
          mji_copy3(local_pos, con[ncon].pos);
          mji_mulMatVec3(con[ncon].normal, mat1, local_dir);
          mji_mulMatVec3(con[ncon].pos, mat1, local_pos);
          mji_addTo3(con[ncon].pos, pos1);

          // force out of all loops if max contacts reached
          if (++ncon >= mjMAXCONPAIR) {
            r = rmax+1;
            c = cmax+1;
            i = 3;
            break;
          }
        }
      }
    }
  }

  if (mjDISABLED(mjDSBL_NATIVECCD)) {
    // fix contact normals
    for (int i=0; i < ncon; i++) {
      /* native CCD only in this diagnostic oracle */;
    }
  }

  return ncon;
}



int rigid_indexed_terrain_contacts(const mjModel* m,mjData* d,int a,int b,double margin,double* out) {
  mjPreContact con[mjMAXCONPAIR];int n=indexed_heightfield(m,d,con,a,b,margin);
  for(int i=0;i<n;i++) {
    out[10*i]=con[i].dist;
    for(int j=0;j<3;j++){out[10*i+1+j]=con[i].pos[j];out[10*i+4+j]=con[i].normal[j];out[10*i+7+j]=con[i].tangent[j];}
  }
  return n;
}

// Full geometric precontacts, including all witnesses and 16 changing poses.
// Setup, dispatch lookup and protocol I/O are outside the timed interval.
double rigid_contact_time(const mjModel* m,mjData* d,int a,int b,double margin,
                          int repetitions,double* checksum) {
  static const double offset[16]={0,.0003,.001,.0006,-.0002,-.001,-.0007,.0002,
                                 .0008,.0001,-.0005,-.0009,.0004,.0009,-.0003,-.0006};
  int moving=b,reverse=m->geom_type[a]>m->geom_type[b];
  if(reverse){int t=a;a=b;b=t;}
  mjfCollision f=mjCOLLISIONFUNC[m->geom_type[a]][m->geom_type[b]];
  mjPreContact con[mjMAXCONPAIR];struct timespec start,end;
  double original=d->geom_xpos[3*moving],sum=0;
  clock_gettime(CLOCK_MONOTONIC,&start);
  for(int r=1;r<=repetitions;r++) {
    d->geom_xpos[3*moving]=original+offset[r&15];int n=f?f(m,d,con,a,b,margin):0;
    for(int i=0;i<n;i++) {
      sum+=con[i].dist;
      for(int j=0;j<3;j++)sum+=con[i].pos[j];
      for(int j=0;j<3;j++)sum+=(reverse?-1:1)*con[i].normal[j];
      for(int j=0;j<3;j++)sum+=con[i].tangent[j];
      sum+=n;
    }
  }
  clock_gettime(CLOCK_MONOTONIC,&end);d->geom_xpos[3*moving]=original;
  *checksum=sum;
  return ((end.tv_sec-start.tv_sec)*1e9+end.tv_nsec-start.tv_nsec)/repetitions;
}
