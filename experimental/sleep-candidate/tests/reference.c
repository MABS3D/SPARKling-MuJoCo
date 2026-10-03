/* Apache-2.0. Test driver for the unmodified pinned engine_sleep.c.
   Group activity is a caller-supplied producer predicate, as in the Ada API. */
#include <stdio.h>
#include <stdlib.h>
#include <mujoco/mujoco.h>
#include "engine/engine_sleep.h"
static int *active;
/* These three predicates are outside the normalized controller boundary. */
int mj_isMetric(const mjModel *m) { (void)m; return 1; }
int tendonLimit(const mjModel *m,const mjtNum *v,int i) { (void)m;(void)v; return active[i]; }
int mj_effTendonPossible(const mjModel *m,int i) { (void)m;return active[i]; }
/* Literal utility used by mj_wake, hidden in the installed shared library. */
void mju_fillInt(int *dst,int value,int n) { for(int i=0;i<n;i++)dst[i]=value; }
static int integer(void) { int x;if(scanf("%d",&x)!=1) exit(2);return x; }
static double real(void) { double x;if(scanf("%lf",&x)!=1) exit(2);return x; }
#define ALLOC(x,n) x=calloc((n)?(n):1,sizeof(*x))
int main(void) {
  mjModel m={0}; mjData d={0};int nops;
  m.ntree=integer();m.nbody=integer();m.nv=integer();nops=integer();
  ALLOC(m.tree_bodyadr,m.ntree);ALLOC(m.tree_bodynum,m.ntree);ALLOC(m.tree_dofadr,m.ntree);
  ALLOC(m.tree_dofnum,m.ntree);ALLOC(m.tree_sleep_policy,m.ntree);ALLOC(d.tree_asleep,m.ntree);
  ALLOC(m.body_treeid,m.nbody);ALLOC(m.body_parentid,m.nbody);ALLOC(m.body_rootid,m.nbody);
  ALLOC(m.body_mocapid,m.nbody);ALLOC(m.dof_bodyid,m.nv);ALLOC(m.dof_length,m.nv);
  ALLOC(d.tree_awake,m.ntree);ALLOC(d.body_awake,m.nbody);ALLOC(d.body_awake_ind,m.nbody);
  ALLOC(d.parent_awake_ind,m.nbody);ALLOC(d.dof_awake_ind,m.nv);
  ALLOC(d.qvel,m.nv);ALLOC(d.qacc,m.nv);ALLOC(d.qfrc_applied,m.nv);ALLOC(d.xfrc_applied,6*m.nbody);
  for(int i=0;i<m.ntree;i++) {m.tree_bodyadr[i]=integer();m.tree_bodynum[i]=integer();
    m.tree_dofadr[i]=integer();m.tree_dofnum[i]=integer();m.tree_sleep_policy[i]=integer();d.tree_asleep[i]=integer();}
  for(int i=0;i<m.nbody;i++){m.body_treeid[i]=integer();m.body_parentid[i]=integer();m.body_rootid[i]=i;m.body_mocapid[i]=integer()?0:-1;}
  for(int i=0;i<m.nv;i++){m.dof_bodyid[i]=integer();m.dof_length[i]=real();}
  for(int i=0;i<m.nv;i++){d.qvel[i]=real();d.qacc[i]=real();d.qfrc_applied[i]=real();}
  for(int i=0;i<6*m.nbody;i++) d.xfrc_applied[i]=real();
  mj_updateSleep(&m,&d);
  for(int op=0;op<nops;op++) {
    int kind=integer(),code=0,n=0;m.opt.enableflags=mjENBL_SLEEP;
    if(kind==0) code=mj_sleepCycle(d.tree_asleep,m.ntree,integer());
    if(kind==1){int i=integer(),v=integer();n=mj_wakeIsland(d.tree_asleep,m.ntree,i,v,NULL,0);}
    if(kind==2) mj_updateSleepInit(&m,&d,integer());
    if(kind==3){if(!integer()) m.opt.enableflags=0;
      for(int i=0;i<m.ntree;i++) if(integer()) d.tree_awake[i]=1;
      n=mj_wake(&m,&d);}
    if(kind==4){int eq=integer();if(!integer())m.opt.enableflags=0;int count=integer();
      if(eq){m.neq=count;ALLOC(m.eq_type,count);ALLOC(m.eq_obj1id,count);ALLOC(m.eq_obj2id,count);
        ALLOC(m.jnt_bodyid,m.nbody);ALLOC(d.eq_active,count);
        for(int i=0;i<m.nbody;i++)m.jnt_bodyid[i]=i;
        for(int i=0;i<count;i++){m.eq_type[i]=mjEQ_JOINT;m.eq_obj1id[i]=integer();m.eq_obj2id[i]=integer();d.eq_active[i]=1;}
        n=mj_wakeEquality(&m,&d);
      }else{d.ncon=count;ALLOC(d.contact,count);ALLOC(m.geom_bodyid,m.nbody);
        for(int i=0;i<m.nbody;i++)m.geom_bodyid[i]=i;
        for(int i=0;i<count;i++){d.contact[i].geom[0]=integer();d.contact[i].geom[1]=integer();}
        n=mj_wakeCollision(&m,&d);}}
    if(kind==5){int flex=integer();if(!integer())m.opt.enableflags=0;int count=integer(),width=integer();
      int *first,*size,*trees;ALLOC(first,count);ALLOC(size,count);ALLOC(active,count);ALLOC(trees,width);
      for(int i=0;i<count;i++){first[i]=integer();size[i]=integer();active[i]=integer();}
      for(int i=0;i<width;i++)trees[i]=integer();
      if(flex){m.neq=count;ALLOC(m.eq_type,count);ALLOC(m.eq_obj1id,count);ALLOC(m.eq_obj2id,count);ALLOC(d.eq_active,count);
        ALLOC(m.flex_interp,count);ALLOC(m.flex_vertnum,count);ALLOC(m.flex_vertadr,count);ALLOC(m.flex_vertbodyid,width);
        for(int i=0;i<count;i++){m.eq_type[i]=mjEQ_FLEX;m.eq_obj1id[i]=i;d.eq_active[i]=active[i];m.flex_vertnum[i]=size[i];m.flex_vertadr[i]=first[i];}
        for(int i=0;i<width;i++){for(int b=0;b<m.nbody;b++)if(m.body_treeid[b]==trees[i]){m.flex_vertbodyid[i]=b;break;}}
        n=mj_wakeEquality(&m,&d);
      }else{m.ntendon=count;ALLOC(m.tendon_treenum,count);ALLOC(m.tendon_treeid,2*count);ALLOC(d.ten_length,count);
        ALLOC(m.ten_J_rowadr,count);ALLOC(m.ten_J_rownnz,count);ALLOC(m.ten_J_colind,width);ALLOC(m.dof_treeid,m.ntree);
        for(int i=0;i<m.ntree;i++)m.dof_treeid[i]=i;
        for(int i=0;i<count;i++){m.tendon_treenum[i]=size[i];m.ten_J_rowadr[i]=first[i];m.ten_J_rownnz[i]=size[i];
          if(size[i])m.tendon_treeid[2*i]=trees[first[i]];if(size[i]>1)m.tendon_treeid[2*i+1]=trees[first[i]+1];}
        for(int i=0;i<width;i++)m.ten_J_colind[i]=trees[i];n=mj_wakeTendon(&m,&d);}}
    if(kind==6){if(!integer())m.opt.enableflags=0;d.nefc=integer();m.opt.sleep_tolerance=real();d.nisland=integer();
      ALLOC(d.island_itreeadr,d.nisland);ALLOC(d.island_ntree,d.nisland);ALLOC(d.map_itree2tree,m.ntree);
      for(int i=0;i<d.nisland;i++){d.island_itreeadr[i]=integer();d.island_ntree[i]=integer();}
      for(int i=0;i<m.ntree;i++)d.map_itree2tree[i]=integer();n=mj_sleep(&m,&d);}
    printf("%d %d",code,n);for(int i=0;i<m.ntree;i++)printf(" %d",d.tree_asleep[i]);
    printf(" %d %d %d %d",d.ntree_awake,d.nbody_awake,d.nparent_awake,d.nv_awake);
    for(int i=0;i<m.ntree;i++)printf(" %d",d.tree_awake[i]);
    for(int i=0;i<m.nbody;i++)printf(" %d",d.body_awake[i]);
    for(int i=0;i<d.nbody_awake;i++)printf(" %d",d.body_awake_ind[i]);
    for(int i=0;i<d.nparent_awake;i++)printf(" %d",d.parent_awake_ind[i]);
    for(int i=0;i<d.nv_awake;i++)printf(" %d",d.dof_awake_ind[i]);
    for(int i=0;i<m.nv;i++)printf(" %.17g",d.qvel[i]);for(int i=0;i<m.nv;i++)printf(" %.17g",d.qacc[i]);puts("");
  }
  return 0;
}
