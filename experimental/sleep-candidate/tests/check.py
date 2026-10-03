#!/usr/bin/env python3
"""Freeze inputs; build checked/release, diagnose minimal routines, prove units."""
import argparse,hashlib,json,os,re,shutil,subprocess,sys,time
from pathlib import Path
HERE=Path(__file__).resolve().parents[1];ROOT=HERE.parents[1]
UNITS=['mj-sleep_kernels','mj-sleep_manager']
def environment():
    env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=':'.join(str(next((tc/n).glob('*/bin'))) for n in ['gnat','gprbuild','gnatprove'])+':'+env['PATH'];return env
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--phase',choices=['build','small','whole'],required=True);ap.add_argument('--unit',choices=UNITS,default=UNITS[0])
    ap.add_argument('--only');ap.add_argument('--mode',choices=['validation','release'],default='validation');ap.add_argument('--timeout',type=int,default=5);a=ap.parse_args()
    if a.only and a.phase!='small':ap.error('--only requires small')
    out=a.out.resolve();(out/'src').mkdir(parents=True,exist_ok=False)
    files=[ROOT/'src/mj.ads',ROOT/'src/mj-types.ads',*sorted((HERE/'src').glob('mj-sleep_*.ad?')),HERE/'tests/sleep_probe.adb']
    hashes={str(p.relative_to(ROOT)):hashlib.sha256(p.read_bytes()).hexdigest() for p in files}
    for p in files:shutil.copyfile(p,out/'src'/p.name)
    project=(HERE/'sleep.gpr').read_text().replace('("src", "tests", "../../src")','("src")');(out/'sleep.gpr').write_text(project)
    (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    env=environment();env['SLEEP_BUILD_ROOT']=str(out/'build');env['SLEEP_MODE']=a.mode
    def run(cmd,label):
        start=time.time();p=subprocess.run([sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','2400','--timeout','180','--',*cmd],env=env,text=True,capture_output=True)
        (out/(label+'.log')).write_text(p.stdout+p.stderr);return p,dict(label=label,command=cmd,exit=p.returncode,seconds=time.time()-start)
    if a.phase=='build':
        p,r=run(['gprbuild','-P',str(out/'sleep.gpr'),'-j1'],'build')
        if p.returncode:print(p.stdout+p.stderr);raise SystemExit(p.returncode)
        r['binary']=str(out/'build'/a.mode/'bin/sleep_probe');(out/'result.json').write_text(json.dumps(r,indent=2)+'\n');print(r['binary']);return
    targets=[(None,'whole')]
    if a.phase=='small':
        targets=[]
        body=(out/'src'/(a.unit+'.adb')).read_text()
        for ext in ['ads','adb']:
            for i,l in enumerate((out/'src'/(a.unit+'.'+ext)).read_text().splitlines(),1):
                m=re.match(r'\s*(?:function|procedure) (\w+)',l)
                if not m or (a.only and m[1]!=a.only):continue
                if ext=='ads' and re.search(r'\b(?:function|procedure) '+m[1]+r'\b',body):continue
                targets.append((f'{a.unit}.{ext}:{i}',m[1]))
    results=[]
    for limit,label in targets:
        cmd=['gnatprove','-f','-P',str(out/'sleep.gpr'),'-u',a.unit+'.ads','--prover=cvc5,z3,altergo',f'--timeout={a.timeout}','--steps=0','--level=2','--proof=per_path','-j1','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
        if limit:cmd.append('--limit-subp='+limit)
        p,r=run(cmd,label)
        report=out/'build'/a.mode/'obj/gnatprove'/(a.unit+'.spark')
        if report.exists():
            d=json.loads(report.read_text());shutil.copyfile(report,out/(label+'.spark.json'))
            items=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[])]
            r.update(checks=sum(x.get('severity')=='info' for x in items),
                proof_checks=sum(x.get('severity')=='info' for x in d.get('proof',[])),
                flow_checks=sum(x.get('severity')=='info' for x in d.get('flow',[])),
                open=[x for x in items if x.get('severity') not in ['info','warning']],warnings=[x for x in items if x.get('severity')=='warning'])
            r['coverage']=dict(skip_proof=d.get('skip_proof'),skip_flow=d.get('skip_flow_proof'),assumptions=d.get('pragma_assume'),spark=d.get('spark'),progress=d.get('progress'),stop_reason=d.get('stop_reason'))
            r['complete_coverage']=bool(d.get('spark')) and all(v=='all' for v in d['spark'].values()) and not any(d.get(k) for k in ['skip_proof','skip_flow_proof','pragma_assume']) and d.get('progress')=='PROGRESS_PROOF' and d.get('stop_reason')=='STOP_REASON_NONE'
        print(label,r.get('checks'),len(r.get('open',[])),flush=True)
        if p.returncode:print('\n'.join(l for l in (p.stdout+p.stderr).splitlines() if any(k in l for k in ['error:','medium:','high:','low:']))[-4000:],flush=True)
        results.append(r);(out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    raise SystemExit(0 if results and all(r['exit']==0 and 'open' in r and not r['open'] and r.get('proof_checks',0)>0 and r.get('complete_coverage') for r in results) else 1)
if __name__=='__main__':main()
