"""Small contact/asset properties first, then fresh whole-unit diagnostics."""
from pathlib import Path
import argparse,json,subprocess
from common import environment,ROOT,digest

def run(out):
    out.mkdir(exist_ok=True);env=environment();runs=[]
    def prove(unit,subprogram=None,flow=False):
        label=('flow-' if flow else '')+(subprogram or unit);env.update(RIGID_MODE='validation',RIGID_BUILD_ROOT=str(out/label))
        cmd=['gnatprove','-P',str(Path('rigid.gpr').resolve()),'-u',unit,'-j1','--checks-as-errors=on','--report=all']
        cmd+=['--mode=flow'] if flow else ['--level=2','--timeout=5','--counterexamples=off']
        if subprogram:
            source=(Path('src')/unit).read_text();kind='procedure' if ('   procedure '+subprogram) in source else 'function';line=source.count('\n',0,source.index('   '+kind+' '+subprogram))+1;cmd+=['--limit-subp='+unit+':'+str(line)]
        with (out/(label+'.log')).open('w') as f:r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','180','--',*cmd],env=env,stdout=f,stderr=subprocess.STDOUT)
        runs.append(dict(unit=unit,subprogram=subprogram,mode='flow' if flow else 'prove',exitcode=r.returncode,command=cmd,source_sha256=digest(Path('src')/unit)))
        (out/'summary.json').write_text(json.dumps(runs,indent=2)+'\n');print(label,r.returncode,flush=True)
    prove('mj-contact_geometry.adb','Reverse_Manifold');prove('mj-convex_assets.adb','Best_Vertex')
    prove('mj-contact_geometry.adb');prove('mj-convex_assets.adb')
    prove('mj-rigid_math.adb')
    prove('mj-contact_inflation.adb','Inflate');prove('mj-contact_inflation.adb')
    for subp in ['Weight','Mix_Value','Mix_Reference','Combine','Configure']:prove('mj-contact_parameters.adb',subp)
    prove('mj-contact_parameters.adb')
    for subp in ['Scale_Normal','Make_Frame','Finalize']:prove('mj-full_contacts.adb',subp)
    prove('mj-full_contacts.adb')
    for unit in ['mj-convex_contacts.adb','mj-contact_features.adb','mj-contact_perturbations.adb','mj-primitive_contacts.adb','mj-advanced_contacts.adb','mj-heightfield_contacts.adb','mj-full_contacts.adb','mj-collision_contacts.adb']:prove(unit,flow=True)
    return not any(r['exitcode'] for r in runs)
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);a=p.parse_args();raise SystemExit(0 if run(a.out.resolve()) else 1)
