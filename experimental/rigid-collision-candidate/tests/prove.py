"""Small subprograms first, then fresh whole-unit reports; open work retained."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
from common import ROOT, environment, digest


def main(out,full,flow=False,filters=False):
    snapshot=out/'source';env=environment();env.update(RIGID_MODE='validation',RIGID_BUILD_ROOT=str(out/'proof-build'))
    logs=out/'proof-logs';logs.mkdir(exist_ok=True);summary=[]
    def run(unit,name=None,flow_only=False):
        cmd=['gnatprove','-P',str(snapshot/'rigid.gpr'),'-u',unit,
             '-j1','--report=all','--checks-as-errors=on']
        cmd.extend(['--mode=flow'] if flow_only else ['--level=2','--timeout=5','--counterexamples=off'])
        label=('flow-' if flow_only else '')+(unit if name is None else name)
        env['RIGID_BUILD_ROOT']=str(out/'proof-build'/label)
        if name:
            source=(snapshot/'src'/unit).read_text();match=re.search(r'^   (?:function|procedure) '+name+r'\b',source,re.M)
            if match is None:raise RuntimeError(name)
            cmd.append('--limit-subp='+unit+':'+str(source.count('\n',0,match.start())+1))
        result=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','180','--',*cmd],env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=200)
        (logs/(label+'.log')).write_text(result.stdout)
        summary.append(dict(unit=unit,subprogram=name,mode='flow' if flow_only else 'prove',command=cmd,exitcode=result.returncode))
        import shutil
        target=out/'proof-reports';target.mkdir(exist_ok=True)
        for p in (Path(env['RIGID_BUILD_ROOT'])/'validation/obj/gnatprove').glob('*.spark'):
            shutil.copyfile(p,target/(label+'--'+p.name))
        print(label,result.returncode,flush=True)
        (out/'proof-summary.json').write_text(json.dumps(dict(scope='candidate; whole collision proof is pending until all complete-unit obligations pass',runs=summary),indent=2)+'\n')
    for unit,names in [
        ('mj-rigid_geometry.ads',['Canonical','Compatible','Body_Allowed']),
        ('mj-rigid_math.adb',['Add','Sub','Scale','Dot','Cross','Norm','Unit','Transform','Local'])]:
        for name in names:run(unit,name)
        run(unit)
    if filters and not full:
        for name in ['Key','Contains']:run('mj-rigid_detector.adb',name)
    if flow:
        for unit in ['mj-rigid_support.adb','mj-rigid_simplex.adb','mj-rigid_primitives.adb',
                     'mj-rigid_ccd.adb','mj-rigid_narrowphase.adb','mj-rigid_detector.adb']:
            run(unit,flow_only=True)
    if not full: return
    for unit,names in [('mj-rigid_detector.adb',['Key','Contains','Sort_Endpoints']),
                       ('mj-rigid_ccd.adb',['Face_Distance','GJK'])]:
        for name in names:run(unit,name)
        run(unit)
    # Preserve reports with unresolved obligations too, so partial results
    # cannot be mistaken for a complete proof.
    reportdir=out/'proof-build'
    import shutil
    target=out/'proof-reports';target.mkdir(exist_ok=True)
    for folder in reportdir.iterdir():
        for p in (folder/'validation/obj/gnatprove').glob('*.spark'):
            shutil.copyfile(p,target/(folder.name+'--'+p.name))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--full',action='store_true');p.add_argument('--flow',action='store_true');p.add_argument('--filters',action='store_true');args=p.parse_args();main(args.out.resolve(),args.full,args.flow,args.filters)
