#!/usr/bin/env python3
"""Reproducible whole Euler-step measurements; setup and I/O outside timer."""
import argparse, hashlib, json, os, shutil, subprocess, sys
from pathlib import Path
import mujoco
import numpy as np
REPO=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project
from compare_numerics import fixtures
FLAGS=['-O3','-march=native','-flto','-ffat-lto-objects','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno','-ffunction-sections','-fdata-sections']
def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def build(out,tc,lib):
 env=os.environ.copy();env['PATH']=':'.join(str(next((tc/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
 meta={'base_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=REPO,text=True).strip(),'oracle':mujoco.__version__,'cpu':Path('/proc/cpuinfo').read_text(),'builds':{}}
 for variant in ['baseline','current']:
  work=out/variant;work.mkdir(parents=True);snapshot=work/'source'
  files=list((REPO/'src').rglob('*.ad?'))+list((REPO/'experimental/smooth/src').glob('*.ad?'))+[REPO/'tests/movement_performance/movement_bench.adb']
  for p in files:
   rel=p.relative_to(REPO);dest=snapshot/rel;dest.parent.mkdir(parents=True,exist_ok=True)
   if variant=='baseline':
    proc=subprocess.run(['git','show','HEAD:'+str(rel)],cwd=REPO,capture_output=True)
    if proc.returncode: continue
    dest.write_bytes(proc.stdout)
   else: shutil.copy2(p,dest)
  proj=isolated_project(snapshot,work,'movement_bench');t=proj.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
  a=t.index('        ("-gnat2022"');b=t.index(';',a)
  flags=['-gnat2022','-gnatn','-gnatp',*FLAGS]
  t=t[:a]+'('+', '.join('"'+f+'"' for f in flags)+')'+t[b:]
  t=t.replace('end Fragment;','   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;');proj.write_text(t)
  with (work/'build.log').open('w') as log: subprocess.run(['gprbuild','-P',str(proj),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
  meta['builds'][variant]={'binary_sha256':digest(work/'bin/movement_bench'),'flags':flags,'sources':{str(p.relative_to(snapshot)):digest(p) for p in snapshot.rglob('*.ad?')}}
 cpp=Path(subprocess.check_output(['g++','-print-file-name=libstdc++.so'],env=env,text=True).strip()).resolve()
 cmd=['gcc','-std=c11',*FLAGS,'-I'+str(Path(mujoco.__file__).parent/'include'),str(REPO/'tests/movement_performance/movement_c.c'),str(lib),str(cpp),'-Wl,-rpath,'+str(lib.parent)+':'+str(cpp.parent),'-o',str(out/'movement_c')]
 subprocess.run(cmd,env=env,check=True)
 meta['builds']['c']={'command':cmd,'binary_sha256':digest(out/'movement_c'),'library_sha256':digest(lib)}
 meta['tools']={n:subprocess.check_output([n,'--version'],env=env,text=True).splitlines()[0] for n in ['gcc','gprbuild','gnatprove']}
 (out/'build.json').write_text(json.dumps(meta,indent=2)+'\n')
def measure(out,cpu,blocks,session):
 rng=np.random.default_rng(20260927);cases={n:fixtures()[n] for n in ['hinge_motor','slide','branched_multijoint','chain_12']}
 for n in ['nonlinear_hinge_motor_both','nonlinear_slide_both','nonlinear_branched_multijoint_both','nonlinear_chain_12_both','nonlinear_chain_12_pure']:
  cases[n]=(REPO/'tests/nonlinear_passive/fixtures'/f'{n}.xml').read_text()
 bins={'baseline':out/'baseline/bin/movement_bench','current':out/'current/bin/movement_bench','c':out/'movement_c'}
 out=out/session;out.mkdir(parents=True,exist_ok=False)
 results={'background_load_start':Path('/proc/loadavg').read_text().strip(),'blocks':blocks,'steps':100,'samples_per_block':8,'cpu':cpu,'cases':[]}
 for name,xml in cases.items():
  m=mujoco.MjModel.from_xml_string(xml);mp=out/(name+'.mjb');mujoco.mj_saveModel(m,str(mp));(out/(name+'.xml')).write_text(xml)
  variants=['current','c'] if name.startswith('nonlinear_') else ['baseline','current','c']
  for state in range(3):
   q=m.qpos0+rng.uniform(-.4,.4,m.nq);v=rng.uniform(-1,1,m.nv);u=rng.uniform(-.2,.2,m.nu);f=rng.uniform(-.1,.1,m.nv)
   data=' '.join(format(float(x),'.17g') for x in np.concatenate([q,v,u,f]))+'\n';(out/f'{name}-{state}.input').write_text(data)
   times={k:[] for k in variants};maxerr=0
   for block in range(blocks):
    outputs={}
    order=variants[block%len(variants):]+variants[:block%len(variants)]
    if (block//len(variants))%2: order=order[::-1]
    for variant in order:
     p=subprocess.run(['taskset','-c',str(cpu),str(bins[variant]),str(mp),'100','8','3'],input=data,text=True,capture_output=True,check=True)
     (out/f'{name}-{state}-{block}-{variant}.output').write_text(p.stdout)
     fields={}
     for line in p.stdout.splitlines():
      a=line.split();fields.setdefault(a[0],[]).append([float(x) for x in a[1:]])
     times[variant].append(float(np.median(fields['sample']))/100)
     outputs[variant]=fields
    for variant in variants:
     for field in ['qpos','qvel','time']:
      got=np.asarray(outputs[variant][field]);want=np.asarray(outputs['c'][field]);np.testing.assert_allclose(got,want,rtol=2e-10,atol=2e-10);maxerr=max(maxerr,float(np.max(np.abs(got-want),initial=0)))
   record={'name':name,'state':state,'seconds_per_step':times,'max_error_C':maxerr,'medians_us':{k:float(np.median(a))*1e6 for k,a in times.items()},'p95_us':{k:float(np.percentile(a,95))*1e6 for k,a in times.items()}}
   ratios=np.array(times['current'])/np.array(times['c']);boot=np.median(rng.choice(ratios,(5000,len(ratios)),replace=True),axis=1)
   record['Ada_C_ratio']=float(np.median(ratios));record['ratio_CI95']=np.percentile(boot,[2.5,97.5]).tolist()
   if 'baseline' in times: record['current_baseline_ratio']=float(np.median(np.array(times['current'])/times['baseline']))
   results['cases'].append(record);(out/'results.json').write_text(json.dumps(results,indent=2)+'\n');print(name,state,record['Ada_C_ratio'],flush=True)
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--toolchain-root',type=Path);p.add_argument('--c-library',type=Path);p.add_argument('--build',action='store_true');p.add_argument('--cpu',type=int,default=12);p.add_argument('--blocks',type=int,default=18);p.add_argument('--session',default='session2');a=p.parse_args();a.out=a.out.resolve()
 if a.build:a.out.mkdir(parents=True,exist_ok=False);build(a.out,a.toolchain_root,a.c_library.resolve())
 else:measure(a.out,a.cpu,a.blocks,a.session)
