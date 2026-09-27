import argparse,ctypes,json,os,subprocess,sys
from pathlib import Path
import mujoco,numpy as np
p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--toolchain-root',type=Path,required=True);a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
r=Path(__file__).resolve().parents[2];env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/n).glob('*/bin'))) for n in ['gnat','gprbuild'])+':'+env['PATH']
proj=out/'kernel.gpr';proj.write_text('project Kernel is\n for Source_Dirs use ("'+str(r/'src')+'", "'+str(r/'experimental/smooth/src')+'", "'+str(Path(__file__).parent)+'");\n for Object_Dir use "obj";\n for Exec_Dir use "bin";\n for Create_Missing_Dirs use "True";\n for Main use ("nonlinear_probe.adb");\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022", "-O0", "-gnata", "-gnato", "-gnatVa", "-ffp-contract=off");\n end Compiler;\n end Kernel;')
with (out/'build.log').open('w') as log:subprocess.run(['gprbuild','-P',str(proj),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
lib=ctypes.CDLL(str(next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))));T=ctypes.c_double;Ptr=ctypes.POINTER(T)
for name in ['mju_polyForce','mjd_xPolyForce']:
 f=getattr(lib,name);f.argtypes=[T,Ptr,T,ctypes.c_int,ctypes.c_int];f.restype=T
rng=np.random.default_rng(20260927);cases=[]
for scale in [1e-100,1.,1e5,1e10]:
 for i in range(128):
  row=rng.uniform(-scale,scale,9);row[3:5]=abs(row[3:5]);cases.append([*row,i%2,(i//2)%2])
for q,r,v in [(1e10,-1e10,1e10),(-1e10,1e10,-1e10),(0,0,0),(0,0,-0.0)]:
 for sign in [-1,1]:
  for flags in [(0,0),(0,1),(1,0),(1,1)]: cases.append([q,r,v,1e10,1e10,*([sign*1e10]*4),*flags])
expected=[]
for q,r,v,k,b,k2,k3,b2,b3,s,d in cases:
 sp=(T*2)(k2,k3);dp=(T*2)(b2,b3);x=q-r
 force=(-x*lib.mju_polyForce(k,sp,x,2,0) if s else 0.)+(-v*lib.mju_polyForce(b,dp,v,2,1) if d else 0.)
 expected.append([force,lib.mjd_xPolyForce(b,dp,v,2,1)])
text=str(len(cases))+'\n'+'\n'.join(' '.join(format(x,'.17g') for x in row) for row in cases)+'\n';(out/'input.txt').write_text(text)
run=subprocess.run([str(out/'bin/nonlinear_probe')],input=text,text=True,capture_output=True,check=True);(out/'output.txt').write_text(run.stdout);got=np.array([[float(x) for x in l.split()] for l in run.stdout.splitlines()]);want=np.asarray(expected)
np.testing.assert_array_equal(got,want)
(out/'results.json').write_text(json.dumps({'status':'passed','cases':len(cases),'comparisons':got.size,'exact_float_equality':True,'oracle':mujoco.__version__},indent=2)+'\n');print((out/'results.json').read_text())
