"""Fresh, bounded proof scopes, starting from the smallest subprograms.

All selected scopes must close. Helper proofs do not establish the complete
BVH traversal, SDF or flex drivers; full flow analysis is listed separately.
"""
from __future__ import annotations
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys

ROOT=Path(__file__).resolve().parents[1]
TOOLS=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
GNAT=TOOLS/'gnat/gnat-x86_64-linux-16.1.0-1/bin'
GPR=TOOLS/'gprbuild/gprbuild-x86_64-linux-26.0.0-1/bin'
PROVE=TOOLS/'gnatprove/gnatprove-x86_64-linux-16.1.0-1/bin'
UNITS=['mj-bvh.adb','mj-sdf_fields.adb','mj-builtin_sdf.ads','mj-flex_collisions.adb',
       'mj-builtin_flex.ads','mj-flex_support.adb','mj-collision_sap.adb','mj-collision_poses.adb',
       'mj-flex_normals.adb','mj-flex_kernels.adb','mj-flex_terrain.adb','mj-sdf_provider.adb']

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--gnat-bin',type=Path,default=GNAT)
    ap.add_argument('--gpr-bin',type=Path,default=GPR)
    ap.add_argument('--gnatprove',type=Path,default=PROVE/'gnatprove')
    ap.add_argument('--guarded',type=Path,default=ROOT.parents[1]/'tools/guarded.py')
    ap.add_argument('--audit-bvh',action='store_true',
                    help='compatibility flag; BVH helper proofs are now required by default')
    names=['product','interpolation','support','bvh-min','bvh-max','bvh-lower','bvh-upper','bvh-monotonic',
           'bvh-transitive','bvh-enclose','bvh-axis','bvh-contains','bvh-overlap','bvh-sphere','bvh-union','flow']
    ap.add_argument('--scope',action='append',choices=names,
                    help='select minimal scopes; repeat to select more than one')
    a=ap.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    snap=out/'snapshot';snap.mkdir()
    for d in ('src','vendor','tests'):shutil.copytree(ROOT/d,snap/d,ignore=shutil.ignore_patterns('__pycache__'))
    shutil.copy2(ROOT/'advanced.gpr',snap/'advanced.gpr')
    shutil.copy2(a.guarded,out/'guarded.py')
    env=os.environ.copy();env['PATH']=':'.join(map(str,(a.gnat_bin,a.gpr_bin,a.gnatprove.parent)))+':'+env['PATH']
    scopes=[]
    def line_of(file,name):
        lines=(snap/'src'/file).read_text().splitlines()
        return next(i for i,line in enumerate(lines,1)
                    if re.match(r'\s*(?:function|procedure) '+name+r'\b',line))
    def selected(name):return a.scope is None or name in a.scope
    def run(name,opts,kind='proof',required=True,seconds=150):
        cmd=[sys.executable,str(out/'guarded.py'),'--cap-mb','3000','--timeout',str(seconds),'--',str(a.gnatprove),
             '-Padvanced.gpr','-XADVANCED_BUILD_ROOT='+str(out/name),'-j2','--report=all',*opts]
        print('analyze',name,flush=True)
        with (out/(name+'.log')).open('w') as f:
            p=subprocess.run(cmd,cwd=snap,env=env,stdout=f,stderr=subprocess.STDOUT)
        log=(out/(name+'.log')).read_text();m=re.search(r'Success: all checks proved \((\d+) checks\)',log)
        passed=p.returncode==0 and m is not None and int(m[1])>0
        summary=out/name/'validation/obj/gnatprove/gnatprove.out'
        if summary.is_file():shutil.copy2(summary,out/(name+'-summary.txt'))
        scopes.append({'scope':name,'kind':kind,'passed':passed,'checks':int(m[1]) if m else None,
                       'exit_code':p.returncode,'command':cmd,'log':name+'.log'})
        if required and not passed:raise RuntimeError('proof scope did not close: '+name)
    try:
        for name,subp in [('product','Product'),('interpolation','Interpolate')]:
            if selected(name):
                run(name,['--mode=prove','-u','mj-sdf_fields.adb',
                          '--limit-subp=mj-sdf_fields.adb:'+str(line_of('mj-sdf_fields.adb',subp)),
                          '--level=2','--timeout=5'])
        if selected('support'):
            run('support',['--mode=prove','-u','mj-flex_support.adb','--level=2','--timeout=15','--prover=all'])
        for name,subp,file in [('bvh-min','Minimum','mj-bvh.adb'),
                              ('bvh-max','Maximum','mj-bvh.adb'),
                              ('bvh-lower','Lemma_Lower','mj-bvh.adb'),
                              ('bvh-upper','Lemma_Upper','mj-bvh.adb'),
                              ('bvh-monotonic','Lemma_Monotonic','mj-bvh.adb'),
                              ('bvh-transitive','Lemma_Transitive','mj-bvh.adb'),
                              ('bvh-enclose','Enclose','mj-bvh.adb'),
                              ('bvh-axis','Union_Axis','mj-bvh.adb'),
                              ('bvh-contains','Contains','mj-bvh.ads'),
                              ('bvh-overlap','Overlap','mj-bvh.ads'),
                              ('bvh-sphere','Sphere_Overlap','mj-bvh.ads'),
                              ('bvh-union','Union_Box','mj-bvh.adb')]:
            if selected(name):
                run(name,['--mode=prove','-u','mj-bvh.adb',
                          '--limit-subp='+file+':'+str(line_of(file,subp)),
                          '--level=3','--timeout=15','--prover=all','--no-inlining',
                          '--counterexamples=off'],seconds=360 if name=='bvh-union' else 180)
        if selected('flow'):
            run('flow',['--mode=flow','-u',*UNITS],kind='flow')
    finally:
        manifest={'scopes':scopes,'source_sha256':{str(p.relative_to(snap)):hashlib.sha256(p.read_bytes()).hexdigest()
            for p in sorted(snap.rglob('*')) if p.is_file()},
            'gnatprove_version':subprocess.check_output([str(a.gnatprove),'--version'],env=env,text=True).strip(),
            'scope_limits':'flow does not prove runtime checks or functional contracts; full drivers remain pending'}
        (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print('all selected proof/flow scopes passed:',out,flush=True)

if __name__=='__main__':main()
