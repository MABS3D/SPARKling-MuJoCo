// Native MuJoCo oracle ONLY; no C link from Ada production.
#include <mujoco/mujoco.h>
#include "engine/engine_inline.h"
#include "engine/engine_collision_driver.h"
#include "engine/engine_collision_flex.h"
#include "engine/engine_collision_primitive.h"
#include "engine/engine_collision_sdf.c"
void mju_makeFrame(mjtNum frame[9]) {
  mjtNum tmp[3];

  // normalize xaxis
  if (mju_normalize3(frame) < 0.5) {
    mjERROR("xaxis of contact frame undefined");
  }

  // if yaxis undefined, set yaxis to (0,1,0) if possible, otherwise (0,0,1)
  if (mju_dot3(frame+3, frame+3) < 0.25) {
    mju_zero3(frame+3);

    if (frame[1] < 0.5 && frame[1] > -0.5) {
      frame[4] = 1;
    } else {
      frame[5] = 1;
    }
  }

  // make yaxis orthogonal to xaxis
  mji_scl3(tmp, frame, mju_dot3(frame, frame+3));
  mji_subFrom3(frame+3, tmp);
  mju_normalize3(frame+3);

  // zaxis = cross(xaxis, yaxis)
  mji_cross(frame+6, frame, frame+3);
}

// Public accessor is equivalent for the valid, registered slots used by tests.
const mjpPlugin* mjp_getPluginAtSlotUnsafe(int slot,int nslot) { return mjp_getPluginAtSlot(slot); }
static void copy_contacts(const mjPreContact* c,int n,double* out) {
  for(int i=0;i<n;i++) { out[10*i]=c[i].dist;
    for(int j=0;j<3;j++) {out[10*i+1+j]=c[i].pos[j];out[10*i+4+j]=c[i].normal[j];out[10*i+7+j]=c[i].tangent[j];}
  }
}
void ref_query(int type,const double* size,const double* point,int gradient,
               int n,const double* boxes,const int* child,const double* coeff,double* out) {
  mjModel m={0}; mjData d={0};int adr=0; int id=0;
  const mjpPlugin* plugin=NULL; mjtGeom gt=type;
  mjSDF s={.id=&id,.plugin=&plugin,.geomtype=&gt,.type=mjSDFTYPE_SINGLE};
  m.geom_size=(double*)size;m.mesh_octadr=&adr;m.oct_aabb=(double*)boxes;m.oct_child=(int*)child;m.oct_coeff=(double*)coeff;
  out[0]=mjc_distance(&m,&d,&s,point);
  out[1]=out[2]=out[3]=0;
  if(gradient)mjc_gradient(&m,&d,&s,out+1,point);
}
void ref_objective(int type1,const double* size1,int type2,const double* size2,
                   const double* relpos,const double* relmat,int mode,
                   const double* point,int iterations,double* out) {
  mjModel m={0}; mjData d={0};int ids[2]={0,1};double size[6];mju_copy3(size,size1);mju_copy3(size+3,size2);
  const mjpPlugin* plugins[2]={NULL,NULL};mjtGeom types[2]={type1,type2};
  mjSDF s={.id=ids,.plugin=plugins,.geomtype=types,.type=mode,.relpos=(mjtNum*)relpos,.relmat=(mjtNum*)relmat};
  m.geom_size=size;
  if(iterations<0) {out[0]=mjc_distance(&m,&d,&s,point);mjc_gradient(&m,&d,&s,out+1,point);}
  else {mju_copy3(out+1,point);out[0]=stepGradient(out+1,&m,&s,&d,iterations);}
}
int ref_obb(const double* a,const double* b,const double* pa,const double* ra,const double* pb,const double* rb,double margin) {
  mjtNum product[36], offset[12];mjtBool initialize=1;
  return mj_collideOBB(a,b,pa,ra,pb,rb,margin,product,offset,&initialize);
}
int ref_triangle(int type,const double* size,const double* pos,const double* mat,
                  const double* corners,double skin,double margin,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=0;
  if(type==mjGEOM_SPHERE)n=mjraw_SphereTriangle(c,margin,pos,size[0],corners,corners+3,corners+6,skin);
  if(type==mjGEOM_BOX)n=mjraw_BoxTriangle(c,margin,pos,mat,size,corners,corners+3,corners+6,skin);
  if(type==mjGEOM_CAPSULE)n=mjraw_CapsuleTriangle(c,margin,pos,mat,size,corners,corners+3,corners+6,skin);
  copy_contacts(c,n,out);return n;
}
int ref_geom(const mjModel* m,mjData* d,int g,int f,int e,double margin,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=mjc_GeomElem(m,d,c,g,f,e,margin);copy_contacts(c,n,out);return n;
}
int ref_elems(const mjModel* m,mjData* d,int f1,int e1,int f2,int e2,double margin,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=mjc_ElemElem(m,d,c,f1,e1,f2,e2,margin);copy_contacts(c,n,out);return n;
}
int ref_ev(const mjModel* m,mjData* d,int f,int e,int v,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=mjc_ElemVert(m,d,c,f,e,v,0);copy_contacts(c,n,out);return n;
}
int ref_plane(const mjModel* m,mjData* d,int g,int f,double margin,double* out,int* ids) {
  mjPreContact c[10000];int n=mjc_PlaneFlex(m,d,c,ids,g,f,margin);copy_contacts(c,n,out);return n;
}
int ref_generate(const mjModel* m,mjData* d,int g1,int g2,double margin,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=mjc_SDF(m,d,c,g1,g2,margin);copy_contacts(c,n,out);return n;
}
int ref_flex_sdf(const mjModel* m,mjData* d,int g,int f,double* out,int* ids,int tree) {
  mjPreContact c[mjMAXCONPAIR];int original=m->flex_bvhadr[f];
  if(!tree)((mjModel*)m)->flex_bvhadr[f]=-1;
  int n=mjc_FlexSDF(m,d,c,ids,g,f,0);
  ((mjModel*)m)->flex_bvhadr[f]=original;copy_contacts(c,n,out);return n;
}
static int pstate(const mjModel* m,int i){return 0;}
static int pinit(const mjModel* m,mjData* d,int i){return 0;}
static void preset(const mjModel* m,mjtNum* state,void* data,int i){}
static void pcompute(const mjModel* m,mjData* d,int i,int bit){}
static double pdistance(const mjtNum* x,const mjData* d,int i){return mju_norm3(x)-0.25;}
static void pgradient(mjtNum* g,const mjtNum* x,const mjData* d,int i) {mju_copy3(g,x);mju_scl3(g,g,1/mju_norm3(x));}
static double pstatic(const mjtNum* x,const mjtNum* attr){return mju_norm3(x)-0.25;}
static void pattribute(mjtNum* attr,const char** name,const char** value){}
static void paabb(mjtNum* box,const mjtNum* attr) {mju_zero3(box);box[3]=box[4]=box[5]=0.25;}
int ref_register_sphere(void) {
  mjpPlugin p; mjp_defaultPlugin(&p);p.name="sparkling.test.sphere";p.capabilityflags=mjPLUGIN_SDF;
  p.nstate=pstate;p.init=pinit;p.reset=preset;p.compute=pcompute;p.sdf_distance=pdistance;p.sdf_gradient=pgradient;
  p.sdf_staticdistance=pstatic;p.sdf_attribute=pattribute;p.sdf_aabb=paabb;return mjp_registerPlugin(&p);
}

int ref_mesh_sdf(const mjModel* m,mjData* d,int g1,int g2,double* out) {
  mjPreContact c[mjMAXCONPAIR];int n=mjc_MeshSDF(m,d,c,g1,g2,0);copy_contacts(c,n,out);return n;
}
