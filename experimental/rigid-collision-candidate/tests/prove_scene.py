"""Small shared-search helpers first, then fresh complete-unit diagnostics."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess

from common import ROOT, environment, digest


def run(out,whole=False):
    source=out/'source';logs=out/'scene-proof-logs';logs.mkdir(exist_ok=True)
    reports=out/'scene-proof-reports';reports.mkdir(exist_ok=True);runs=[]
    def prove(unit,name=None,flow=False):
        label=('flow-' if flow else '')+(name or unit)
        env=environment();env.update(RIGID_MODE='validation',RIGID_BUILD_ROOT=str(out/'scene-proof-build'/label))
        cmd=['gnatprove','-P',str(source/'rigid.gpr'),'-u',unit,'-j1','--report=all','--checks-as-errors=on']
        cmd+=['--mode=flow'] if flow else ['--level=2','--timeout=10','--counterexamples=off']
        if name:
            text=(source/'src'/unit).read_text();m=re.search(r'^   (?:procedure|function) '+name+r'\b',text,re.M)
            if m is None:raise ValueError(name)
            cmd+=['--limit-subp='+unit+':'+str(text[:m.start()].count('\n')+1)]
        r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','180','--',*cmd],env=env,text=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=200)
        (logs/(label+'.log')).write_text(r.stdout)
        for p in (Path(env['RIGID_BUILD_ROOT'])/'validation/obj/gnatprove').glob('*.spark'):
            shutil.copyfile(p,reports/(label+'--'+p.name))
        runs.append(dict(unit=unit,subprogram=name,mode='flow' if flow else 'prove',exitcode=r.returncode,command=cmd))
        print(label,r.returncode,flush=True)
        (out/'scene-proof-summary.json').write_text(json.dumps(dict(
            scope='Shared collision candidate. Helper proofs do not close traversal or collision-generation proofs.',
            sources={unit:digest(source/'src'/unit) for unit in ['mj-rigid_detector.adb','mj-collision_scene.adb']},runs=runs),indent=2)+'\n')
    for unit,name in [('mj-rigid_detector.adb','Append_Pair'),('mj-collision_scene.adb','Expanded'),
                      ('mj-collision_scene.adb','Make_Proxy')]:prove(unit,name)
    for unit in ['mj-rigid_detector.adb','mj-collision_scene.adb']:prove(unit,flow=True)
    if whole:
        for unit in ['mj-rigid_detector.adb','mj-collision_scene.adb']:prove(unit)
    return all(r['exitcode']==0 for r in runs)


if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);a.add_argument('--whole',action='store_true');args=a.parse_args()
    raise SystemExit(0 if run(args.out.resolve(),args.whole) else 1)
