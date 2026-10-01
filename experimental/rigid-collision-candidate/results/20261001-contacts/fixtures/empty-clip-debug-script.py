from pathlib import Path
import sys,subprocess,json,ctypes,numpy as np
sys.path.insert(0,'tests');from common import ROOT;from check_contacts import library;from check import pair_model
out=Path('/var/tmp/sparkling-contact-debug-native');out.mkdir(exist_ok=True)
s=(ROOT/'mujoco/src/engine/engine_collision_gjk.c').read_text()
s='#include <stdio.h>\n#define mjc_ccd debug_ccd\n#define mjc_ccdSize debug_ccdSize\n'+s
s=s.replace('  if (npolygon < 1) {','  fprintf(stderr,"clipped polygon %d edge vertices %d\\n",npolygon,nface2);\n  if (npolygon < 1) {')
s=s.replace('  // get dimensions of features of geoms 1 and 2','  fprintf(stderr,"features %d %d %d / %d %d %d\\n",v1i[0],v1i[1],v1i[2],v2i[0],v2i[1],v2i[2]);\n  // get dimensions of features of geoms 1 and 2')
s += '\nvoid mjc_pointSupport(mjtNum r[3],mjCCDObj* o,const mjtNum d[3]) {for(int i=0;i<3;i++)r[i]=o->pos[i];}\nvoid mjc_lineSupport(mjtNum r[3],mjCCDObj* o,const mjtNum d[3]) {double dot=o->mat[2]*d[0]+o->mat[5]*d[1]+o->mat[8]*d[2];double z=dot>=0?o->size[1]:-o->size[1];for(int i=0;i<3;i++)r[i]=o->pos[i]+o->mat[3*i+2]*z;}\n'
(out/'debug.c').write_text(s)
h=Path('tests/reference.c').read_text().replace('int rigid_convex_contacts(', 'int rigid_convex_debug_contacts(').replace('.max_contacts=1,','.max_contacts=4,').replace('double distance=mjc_ccd(', 'double distance=debug_ccd(')
h='double debug_ccd(const void*,void*,void*,void*);\n'+h
(out/'reference.c').write_text(h)
cmd=['gcc','-O3','-fPIC','-shared','-ffp-contract=off','-I'+str(ROOT/'mujoco/include'),'-I'+str(ROOT/'mujoco/src'),'-I/var/tmp/sparkling-movement-c/build/_deps/ccd-src/src','-I/var/tmp/sparkling-movement-c/build/_deps/ccd-build/src',str(out/'debug.c'),str(out/'reference.c'),'/var/tmp/sparkling-movement-env/lib/python3.12/site-packages/mujoco/libmujoco.so.3.14.0','-o',str(out/'debug.so')]
subprocess.run(cmd,check=True)
l=ctypes.CDLL(str(out/'debug.so'));f=l.rigid_convex_debug_contacts;f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_double,np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')];f.restype=ctypes.c_int
r=json.load(open('/var/tmp/sparkling-fullcontact-v11-20261001/primitive-contact-numerics.json'))['validation']['failures']
x=next(x for x in r if x['index']==1809);vals=x['input'].split();sizes=[];positions=[];mats=[];p=3
for i in range(2):sizes.append(np.array(vals[p+1:p+4],float));positions.append(np.array(vals[p+4:p+7],float));mats.append(np.array(vals[p+7:p+16],float));p+=20
m,d=pair_model(*x['pair']);m.geom_size[:]=sizes;d.geom_xpos[:]=positions;d.geom_xmat[:]=mats
v=np.zeros(500);n=f(m._address,d._address,0,1,float(vals[2]),v);print('native multiccd',v[:10*n])
