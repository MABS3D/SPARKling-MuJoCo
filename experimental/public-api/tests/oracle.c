// Apache-2.0. Test-only calls to the official MuJoCo API; never linked to Ada.
#include <mujoco/mujoco.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
static int sizes[14];
static void model(mjModel* m) {
  m->nq=sizes[1]; m->nv=sizes[2]; m->na=sizes[3]; m->nhistory=sizes[4];
  m->nu=sizes[6]; m->nbody=sizes[8]/6; m->neq=sizes[9]; m->nmocap=sizes[10]/3;
  m->nuserdata=sizes[12]; m->npluginstate=sizes[13];
}
static void bind(mjData* d, double* full, mjtBool* flags) {
  int off=0; double* a[14];
  for(int i=0;i<14;i++){a[i]=full+off;off+=sizes[i];}
  d->time=a[0][0]; d->qpos=a[1]; d->qvel=a[2]; d->act=a[3]; d->history=a[4];
  d->qacc_warmstart=a[5]; d->ctrl=a[6]; d->qfrc_applied=a[7]; d->xfrc_applied=a[8];
  d->eq_active=flags; d->mocap_pos=a[10]; d->mocap_quat=a[11];
  d->userdata=a[12]; d->plugin_state=a[13];
  for(int i=0;i<sizes[9];i++)flags[i]=a[9][i]!=0;
}
int main(void) {
  int op, ss, ds, ns, nd;
  while(scanf("%d",&op)==1){
    if(op==9){mjModel m={0};int nv,j,c,s,n;scanf("%d%d%d%d%d",&nv,&j,&c,&s,&n);m.nv=nv;
      m.opt.jacobian=j;m.opt.cone=c;m.opt.solver=s;m.opt.noslip_iterations=n;
      printf("%s %s %s\n",mj_isSparse(&m)?"TRUE":"FALSE",mj_isPyramidal(&m)?"TRUE":"FALSE",mj_isDual(&m)?"TRUE":"FALSE");continue;}
    if(op==8){int t;scanf("%d",&t);const char* s=mju_type2Str(t);printf("TYPE %s\n",s?s:"(none)");continue;}
    scanf("%d%d",&ss,&ds);for(int i=0;i<14;i++)scanf("%d",&sizes[i]);scanf("%d%d",&ns,&nd);
    double* src=calloc(ns+1,sizeof(double));double* dst=calloc(nd+1,sizeof(double));
    for(int i=0;i<ns;i++)scanf("%lf",&src[i]);for(int i=0;i<nd;i++)scanf("%lf",&dst[i]);
    mjModel m={0};model(&m);mjData a={0},b={0};mjtBool* flags=calloc(sizes[9]+1,sizeof(mjtBool));
    mjtBool* flags2=calloc(sizes[9]+1,sizeof(mjtBool));
    if(op==1)mj_extractState(&m,src,ss,dst,ds);
    if(op==2){bind(&b,dst,flags2);mj_setState(&m,&b,src,ss);mj_getState(&m,&b,dst,mjSTATE_INTEGRATION);}
    if(op==3){bind(&a,src,flags);bind(&b,dst,flags2);mj_copyState(&m,&a,&b,ss);mj_getState(&m,&b,dst,mjSTATE_INTEGRATION);}
    if(op==4){bind(&a,src,flags);mj_getState(&m,&a,dst,ds);}
    printf("SUCCESS");for(int i=0;i<nd;i++)printf(" %.17g",dst[i]);puts("");
    free(src);free(dst);free(flags);free(flags2);
  }
}
