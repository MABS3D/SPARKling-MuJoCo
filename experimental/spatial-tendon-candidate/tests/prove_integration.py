"""Prove minimal integration routines against an immutable dependency snapshot."""
import argparse,sys,re,json,hashlib,shutil,subprocess,tempfile,resource
from datetime import datetime, timezone
from pathlib import Path
from common import ROOT,REPO,SCRATCH,environment
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project,source_files


def main():
    a=argparse.ArgumentParser();a.add_argument('--scope',choices=['kernels','loader','phase','callers','flow'],default='kernels');a.add_argument('--seconds',type=int,default=10);a.add_argument('--only');args=a.parse_args()
    limits=resource.getrlimit(resource.RLIMIT_STACK);resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,limits[1]))
    work=Path(tempfile.mkdtemp(prefix='spatial-integration-proof-',dir=SCRATCH));snap=work/'source'
    hashes={}
    for file in source_files(REPO):
        rel=file.relative_to(REPO);dst=snap/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(file,dst)
        hashes[str(rel)]=hashlib.sha256(dst.read_bytes()).hexdigest()
    assert all(hashlib.sha256((REPO/k).read_bytes()).hexdigest()==v for k,v in hashes.items()),'source changed during snapshot'
    selection={'kernels':{'mj-tendon_adapters.ads':['Column','Jacobian'],'mj-spatial_tendon_models.ads':['Displacement','Polynomial'],'mj-spatial_tendon_models.adb':['Spring_Damper']},
               'loader':{'mj-spatial_tendon_models.ads':['Ready'],'mj-spatial_tendon_models.adb':['Load','Load_Valid','Free']},
               'phase':{'mj-data-spatial_tendon_phase.adb':['Compute_Passive']},
               'callers':{'mj-data.adb':['Prove_Configuration_Equality','Free','Initialize','Create','Get_Tendon_Outputs'],'mj-data-forces_phase.adb':['Complete_Passive'], 'mj-data-pipeline.adb':['Ensure_Jacobians']},
               'flow':{'mj-spatial_tendon_models.adb':[], 'mj-data-spatial_tendon_phase.adb':[]}}
    out=ROOT/'evidence'/('integration-proof-'+args.scope);out.mkdir(exist_ok=True)
    if args.only:
        out = out / args.only; out.mkdir(exist_ok=True)
    results=[]
    for filename,names in selection[args.scope].items():
        path=next(snap.rglob(filename))
        targets=[(m[1],i) for i,s in enumerate(path.read_text().splitlines(),1) if (m:=re.match(r'   (?:function|procedure) (\w+)',s)) and m[1] in names] if names else [('whole',0)]
        targets = list({name: line for name, line in targets}.items())
        for name,line in targets:
            label=path.stem+'-'+name
            if args.only and args.only not in label:continue
            task=work/label;task.mkdir()
            project=isolated_project(snap,task,path.stem)
            cmd=[sys.executable,str(REPO/'tools/guarded.py'),'--cap-mb','3800','--min-free-mb','2048','--timeout','600','--', 'gnatprove','-P',str(project),('--prover=cvc5' if args.seconds==1 else '--prover=cvc5,z3,altergo'),f'--timeout={args.seconds}',('--steps=300' if args.seconds==1 else '--steps=0'),'--proof=per_check','-j2','--report=all','--checks-as-errors=on','--warnings=continue','--counterexamples=off']
            cmd += ['--mode=flow','-u',filename] if args.scope=='flow' else [f'--limit-subp={filename}:{line}']
            with (out/(label+'.log')).open('w') as log:r=subprocess.run(cmd,env=environment(),stdout=log,stderr=subprocess.STDOUT)
            records=[];dest=out/label;dest.mkdir(exist_ok=True)
            for p in task.rglob(path.stem+'.spark'):
                shutil.copy2(p,dest/p.name);d=json.loads(p.read_text());records=d.get('proof',[])
            info=dict(name=label,returncode=r.returncode,proved=sum(x['severity']=='info' for x in records),open=sum(x['severity']!='info' for x in records),command=cmd)
            results.append(info);print(label,r.returncode,info['proved'],info['open'],flush=True)
    (out/'manifest.json').write_text(json.dumps(dict(timestamp=datetime.now(timezone.utc).isoformat(),snapshot=str(snap),source_sha256=hashes,results=results),indent=2)+'\n')
    return int(any(x['returncode'] for x in results))
if __name__=='__main__':raise SystemExit(main())
