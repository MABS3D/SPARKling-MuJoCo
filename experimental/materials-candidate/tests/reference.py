#!/usr/bin/env python3
"""Compile unchanged upstream private bodies; save their provenance and source."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import mujoco

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
PIN = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'

def function(text, marker):
    start = text.index(marker)
    brace = text.index('{', start)
    depth = 0
    for i in range(brace, len(text)):
        if text[i] == '{': depth += 1
        elif text[i] == '}': depth -= 1
        if depth == 0:
            return text[start:i+1]
    raise ValueError(marker)

def build(out):
    assert mujoco.__version__ == '3.14.0'
    assert subprocess.check_output(['git', '-C', str(ROOT/'mujoco'), 'rev-parse', 'HEAD'], text=True).strip() == PIN
    out.mkdir(parents=True, exist_ok=True)
    paths = ['src/user/user_mesh.cc', 'src/user/user_util.cc',
             'src/engine/engine_collision_driver.c', 'src/engine/engine_core_constraint.c',
             'src/engine/engine_util_spatial.c', 'src/engine/engine_passive.c']
    texts = {p: (ROOT/'mujoco'/p).read_text() for p in paths}
    # Verify checkout bodies against the pinned commit before extracting them.
    for p, text in texts.items():
        pinned = subprocess.check_output(['git', '-C', str(ROOT/'mujoco'), 'show', PIN+':'+p]).decode().replace('\r\n', '\n')
        assert text == pinned, p
    mesh = texts[paths[0]]
    material = function(mesh, 'template <typename T>\nvoid inline ComputeStiffness(')
    statements = re.findall(r'double (?:mu|la) = .*?;', material)
    linear = function(mesh, 'void inline ComputeLinearStiffness(')
    la_linear = re.search(r'double\s+la\s*=.*?;', linear).group()
    plane = function(mesh, 'void inline ComputeLinearStiffness2D(')
    la_plane = re.search(r'double la = .*?;', plane).group()
    bend = re.search(r'double D_bend = .*?;', mesh).group()
    parts = [function(mesh, 'struct Stencil2D')+';', function(mesh, 'struct Stencil3D')+';']
    util = texts[paths[1]]
    parts += [function(util, marker) for marker in [
        'double mjuu_dot3(', 'double mjuu_normvec(double*', 'void mjuu_crossvec(']]
    parts += ['template <typename T> inline double ComputeVolume(const double* x, const int* v);']
    parts += [function(mesh, marker) for marker in [
        'template <>\ninline double ComputeVolume<Stencil2D>',
        'template <>\ninline double ComputeVolume<Stencil3D>']]
    parts += ['template <typename T> void ComputeBasis(double* b, const double* x, const int* v, const int* fl, const int* fr, double volume);']
    parts += [function(mesh, marker) for marker in [
        'template <>\nvoid inline ComputeBasis<Stencil2D>',
        'template <>\nvoid inline ComputeBasis<Stencil3D>',
        'template <typename T>\nvoid inline MetricTensor(']]
    collision = texts[paths[2]]
    constraint = texts[paths[3]]
    parts += [function(constraint, marker) for marker in [
        'void mj_assignFriction(', 'void mj_assignRef(', 'void mj_assignImp(', 'mjtNum mj_assignMargin(']]
    parts += [function(texts[paths[4]], 'void mju_makeFrame(')]
    parts += [function(collision, 'static void mj_contactParam('),
              function(collision, 'static void mj_setContact(')]
    helpers = '\n\n'.join(parts)
    source = HEADER + helpers + WRAPPER
    source = source.replace('WEIGHTED_PARAMETERS', '\n'.join(statements))
    source = source.replace('LINEAR_PARAMETER', la_linear.replace('la', 'la_linear', 1))
    source = source.replace('PLANE_PARAMETER', la_plane.replace('la', 'la_plane', 1))
    source = source.replace('BENDING_PARAMETER', bend)
    passive = texts[paths[5]]
    damping = re.search(r'mjtNum kD = enbl_damper &&.*?;', passive).group()
    damping = damping.replace('mjtNum', 'double').replace('enbl_damper', 'damp').replace('m->opt.timestep', 'h').replace('m->flex_damping[f]', 'rayleigh')
    spring = re.search(r'elongation\[e\] = deformed\[idx\].*?;', passive).group().split(' = ', 1)[1].rstrip(';')
    spring = spring.replace('deformed[idx]', 'len').replace('reference[idx]', 'rest')
    dl = re.search(r'mjtNum dL = vel\[idx\].*?;', passive).group().replace('mjtNum', 'double').replace('vel[idx]', 'velocity').replace('m->opt.timestep', 'h')
    damper = re.search(r'elongation\[e\] = dL\*.*?;', passive).group().split(' = ', 1)[1].rstrip(';').replace('deformed[idx]', 'len')
    source = source.replace('DAMPING_PARAMETER', damping+' '+dl).replace('SPRING_EXPRESSION', spring).replace('DAMPER_EXPRESSION', damper)
    path = out/'reference.cpp'
    path.write_text(source)
    wheel = Path(mujoco.__file__).parent
    library = wheel/'libmujoco.so.3.14.0'
    command = ['g++', '-std=c++17', '-O3', '-march=native', '-ffp-contract=off',
               '-MMD', '-MF', str(out/'reference.d'), '-I'+str(ROOT/'mujoco/include'), '-I'+str(ROOT/'mujoco/src'), str(path),
               str(library), '-Wl,-rpath,'+str(wheel), '-o', str(out/'reference')]
    p = subprocess.run(command, capture_output=True, text=True)
    (out/'build.log').write_text(p.stdout+p.stderr)
    if p.returncode: raise RuntimeError((p.stdout+p.stderr)[-6000:])
    hashes = {p: hashlib.sha256((ROOT/'mujoco'/p).read_bytes()).hexdigest() for p in paths}
    import shlex
    dependencies = shlex.split((out/'reference.d').read_text().replace('\\\n', ' ').split(':', 1)[1])
    for dependency in dependencies:
        header = Path(dependency)
        if header.is_relative_to(ROOT/'mujoco'):
            rel = str(header.relative_to(ROOT/'mujoco'))
            pinned = subprocess.check_output(['git', '-C', str(ROOT/'mujoco'), 'show', PIN+':'+rel]).decode().replace('\r\n', '\n')
            assert header.read_text() == pinned, rel
            hashes[rel] = hashlib.sha256(header.read_bytes()).hexdigest()
    hashes['reference.cpp'] = hashlib.sha256(path.read_bytes()).hexdigest()
    (out/'reference.json').write_text(json.dumps(dict(version=mujoco.__version__,
        commit=PIN, sources=hashes, library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        command=command, extracted_bodies_sha256=hashlib.sha256(helpers.encode()).hexdigest()), indent=2)+'\n')
    return out/'reference'

HEADER = r'''
// Extracts: Copyright 2021 DeepMind Technologies Limited.
// Licensed under the Apache License, Version 2.0.
// See https://www.apache.org/licenses/LICENSE-2.0
// Distributed without warranties or conditions of any kind.
#include <cmath>
#include <iostream>
#include <iomanip>
#include <sstream>
#include <string>
#include <mujoco/mujoco.h>
#include "engine/engine_macro.h"
#include "engine/engine_inline.h"
#include "engine/engine_util_blas.h"
#include "engine/engine_util_errmem.h"
#include "engine/engine_util_spatial.h"
#include "user/user_util.h"
'''

WRAPPER = r'''
void put(double x) { std::cout << x << ' '; }
void params(int dim,const double* sr,const double* sfr,const double* si,const double* fr,double adhesion) {
  put(dim); for(int i=0;i<2;i++)put(sr[i]); for(int i=0;i<2;i++)put(sfr[i]);
  for(int i=0;i<5;i++)put(si[i]);for(int i=0;i<5;i++)put(fr[i]);put(adhesion);
}
template<class T> void geometry(const double* pos) {
  int v[4]={0,1,2,3}; double volume=ComputeVolume<T>(pos,v),basis[6][9]={};put(volume);
  for(int e=0;e<T::kNumEdges;e++) ComputeBasis<T>(basis[e],pos,v,T::face[T::edge2face[e][0]],T::face[T::edge2face[e][1]],volume);
  for(int e=0;e<6;e++)for(int j=0;j<9;j++)put(basis[e][j]);
}
int main(){
 std::cout << std::setprecision(17) << std::scientific;
 std::string line;
 while(std::getline(std::cin,line)) {
  std::istringstream in(line);int op;in>>op;
  if(op==1){
   int kind,damp,spring;double E,nu,thickness,rayleigh,volume,h,len,rest,velocity,basis[6][9],metric[21]={};
   in>>kind>>E>>nu>>thickness>>rayleigh>>volume>>h>>len>>rest>>velocity>>damp>>spring;
   for(int e=0;e<6;e++)for(int j=0;j<9;j++)in>>basis[e][j];
   double mu_base=E/(2*(1+nu));
   double la_base=E*nu/((1+nu)*(1-2*nu));
   LINEAR_PARAMETER
   PLANE_PARAMETER
   double young=E,poisson=nu;
   BENDING_PARAMETER
   if(kind==1)thickness=4;
   WEIGHTED_PARAMETERS
   DAMPING_PARAMETER
   put(mu_base);put(la_base);put(la_linear);put(la_plane);put(D_bend);put(mu);put(la);put(kD);
   put(spring?SPRING_EXPRESSION:0);put(kD?DAMPER_EXPRESSION:0);
   if(kind==0)MetricTensor<Stencil2D>(metric,0,mu,la,basis);
   else MetricTensor<Stencil3D>(metric,0,mu,la,basis);
   for(int i=0;i<21;i++)put(metric[i]);
  }else if(op==3){
   int kind;double pos[12];in>>kind;for(double&x:pos)in>>x;
   if(kind==0)geometry<Stencil2D>(pos);else geometry<Stencil3D>(pos);
  }else if(op==2){
   mjModel m{};int kind[2],priority[2],dim[2];double mix[2],sr[4],si[10],fr[6],adh[2],margin[2],gap[2];
   for(int i=0;i<2;i++){
    in>>kind[i]>>priority[i]>>dim[i]>>mix[i];for(int j=0;j<2;j++)in>>sr[2*i+j];
    for(int j=0;j<5;j++)in>>si[5*i+j];for(int j=0;j<3;j++)in>>fr[3*i+j];in>>adh[i]>>margin[i]>>gap[i];
   }
   m.geom_priority=m.flex_priority=priority;m.geom_condim=m.flex_condim=dim;
   m.geom_solmix=m.flex_solmix=mix;m.geom_solref=m.flex_solref=sr;m.geom_solimp=m.flex_solimp=si;
   m.geom_friction=m.flex_friction=fr;m.geom_adhesion=adh;
   int pd,pe;double psr[2],psfr[2],psi[5],pfr[5],pa,pm,pg;
   in>>pe>>pd;for(double&x:psr)in>>x;for(double&x:psfr)in>>x;for(double&x:psi)in>>x;for(double&x:pfr)in>>x;in>>pa>>pm>>pg;
   int over;in>>over;for(double&x:m.opt.o_solref)in>>x;for(double&x:m.opt.o_solimp)in>>x;
   for(double&x:m.opt.o_friction)in>>x;in>>m.opt.o_margin;
   double distance;int self;in>>distance>>self;
   int cd;double csr[2],csi[5],cfr[5],ca,csfr[2]={};
   mj_contactParam(&m,&cd,csr,csi,cfr,&ca,kind[0]?-1:0,kind[1]?-1:1,kind[0]?0:-1,kind[1]?1:-1);
   params(cd,csr,csfr,csi,cfr,ca);
   double cm=margin[0]+margin[1],cg=gap[0]+gap[1];
   if(pe){cd=pd;for(int j=0;j<2;j++)csr[j]=psr[j];for(int j=0;j<5;j++){csi[j]=psi[j];cfr[j]=pfr[j];}ca=pa;cm=pm;cg=pg;
     if(psfr[0]||psfr[1])for(int j=0;j<2;j++)csfr[j]=psfr[j];}
   if(over)m.opt.enableflags|=mjENBL_OVERRIDE;
   cm=self?0:mj_assignMargin(&m,cm);
   mjContact con{};con.dist=distance;con.frame[2]=1;con.frame[3]=1;
   mj_setContact(&m,&con,cd,cm,csr,csfr,csi,cfr,ca);
   params(con.dim,con.solref,con.solreffriction,con.solimp,con.friction,con.adhesion);
   put(con.includemargin);put(cg);put(con.exclude);
  }else return 2;
  std::cout << '\n';
 }
}
'''
