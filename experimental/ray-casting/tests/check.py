"""Freeze the actual Model/Data dependency closure; keep artifacts outside the checkout."""
import argparse, hashlib, json, os, pathlib, shutil, subprocess, sys, time
HERE=pathlib.Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
FOLDERS=['src','src/gen','experimental/smooth/src','experimental/spatial-tendon-candidate/src',
         'experimental/muscle-candidate/src','experimental/ray-casting/src','experimental/ray-casting/tests']
def environment():
    env=os.environ.copy();tc=pathlib.Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=':'.join(str(p) for n in ['gnat','gprbuild','gnatprove'] for p in (tc/n).glob('*/bin'))+':'+env['PATH']
    return env
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=pathlib.Path,required=True)
    ap.add_argument('--action',choices=['build','small','whole','flow'],default='build')
    ap.add_argument('--mode',default='validation',choices=['validation','release'])
    ap.add_argument('--resume',action='store_true');ap.add_argument('--unit',default='mj-ray_kernels')
    ap.add_argument('--refresh',action='store_true',help='refresh ray sources/tests only, preserving frozen dependencies')
    ap.add_argument('--only');ap.add_argument('--timeout',type=int,default=5)
    ap.add_argument('--proof-mode',choices=['per_check','per_path'],default='per_check')
    ap.add_argument('--no-inlining',action='store_true');a=ap.parse_args()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=a.resume);snap=out/'source'
    if not a.resume or a.refresh:
        if a.refresh and not a.resume:ap.error('--refresh requires --resume')
        hashes=json.loads((out/'sources.json').read_text()) if a.resume else {}
        for folder in (FOLDERS[-2:] if a.refresh else FOLDERS):
            for f in (ROOT/folder).iterdir():
                if f.is_file() and f.suffix in ['.ads','.adb','.py','.c']:
                    rel=f.relative_to(ROOT);dest=snap/rel;dest.parent.mkdir(parents=True,exist_ok=True)
                    data=f.read_bytes();dest.write_bytes(data);hashes[str(rel)]=hashlib.sha256(data).hexdigest()
        project=snap/'experimental/ray-casting/rays.gpr';shutil.copyfile(HERE/'rays.gpr',project)
        hashes['experimental/ray-casting/rays.gpr']=hashlib.sha256(project.read_bytes()).hexdigest()
        (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    env=environment();env['RAYS_BUILD_ROOT']=str(out/'build');env['RAYS_MODE']=a.mode
    project=snap/'experimental/ray-casting/rays.gpr'
    targets=[]
    if a.action=='build':targets=[('build-'+a.mode,['gprbuild','-P',str(project),'-j1'])]
    else:
        base=['gnatprove','-f','-P',str(project),'-u',a.unit+'.ads','--prover=cvc5,z3,altergo',
              '--timeout='+str(a.timeout),'--steps=0','--proof='+a.proof_mode,'-j1',
              '--report=all','--warnings=continue','--counterexamples=off']
        if a.action=='flow':base+=['--mode=flow']
        if a.no_inlining:base+=['--no-inlining']
        if a.action=='small':
            import re
            f=snap/'experimental/ray-casting/src'/f'{a.unit}.adb'
            for i,line in enumerate(f.read_text().splitlines(),1):
                m=re.match(r'\s*(function|procedure) (\w+)',line)
                if m and (not a.only or a.only==m[2]):targets.append(('small-'+m[2],base+['--limit-subp='+f.name+':'+str(i)]))
        else:targets=[(a.action+'-'+a.unit,base)]
    records=[]
    for label,cmd in targets:
        report=out/'build'/a.mode/'obj/gnatprove'/(a.unit+'.spark')
        if report.exists():report.unlink()
        start=time.monotonic()
        r=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout',('600' if a.action=='build' else '300'),'--',*cmd],
                         env=env,text=True,capture_output=True)
        (out/(label+'.log')).write_text(r.stdout+r.stderr)
        rec=dict(label=label,command=cmd,exit=r.returncode,seconds=time.monotonic()-start)
        if report.exists():
            d=json.loads(report.read_text());shutil.copyfile(report,out/(label+'.spark.json'))
            diags=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[])]
            rec.update(checks=sum(x.get('severity')=='info' for x in diags),
                       open=[x for x in diags if x.get('severity') not in ['info','warning']],
                       warnings=[x for x in diags if x.get('severity')=='warning'],
                       coverage=all(v=='all' for v in d.get('spark',{}).values())
                         and not d.get('skip_proof') and not d.get('skip_flow_proof') and not d.get('pragma_assume'))
        records.append(rec);print(label,'exit',r.returncode,'checks',rec.get('checks'),'open',len(rec.get('open',[])),flush=True)
        (out/(a.action+'-'+a.mode+'-'+a.unit+'.json')).write_text(json.dumps(records,indent=2)+'\n')
        if a.action=='build' and r.returncode:
            print((r.stdout+r.stderr)[-4000:]);raise SystemExit(r.returncode)
    return 0 if all(r['exit']==0 and (a.action=='build' or not r.get('open',[1])) for r in records) else 1
if __name__=='__main__':raise SystemExit(main())
