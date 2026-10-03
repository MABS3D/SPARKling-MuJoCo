"""Freeze the additive NoSlip entry and current parent dependencies outside Git."""
import argparse, hashlib, json, os, pathlib, re, shutil, subprocess, sys, time
HERE=pathlib.Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
def environment(out,mode):
    env=os.environ.copy(); tc=pathlib.Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=os.pathsep.join(str(next((tc/n).glob('*/bin'))) for n in ['gnat','gprbuild','gnatprove'])+os.pathsep+env['PATH']
    env.update(NOSLIP_BUILD_ROOT=str(out/'build'),NOSLIP_MODE=mode,
               CONSTRAINED_BUILD_ROOT=str(out/'parent-build'),CONSTRAINED_MODE=mode)
    return env
def main():
    p=argparse.ArgumentParser();p.add_argument('--out',type=pathlib.Path,required=True)
    p.add_argument('--phase',choices=['build','small','whole'],default='build')
    p.add_argument('--mode',choices=['validation','release'],default='validation')
    p.add_argument('--resume',action='store_true',help='reuse frozen parent; update only this candidate')
    p.add_argument('--standalone',action='store_true',help='build/prove the post-pass independently')
    p.add_argument('--unit',default='mj-noslip_kernels');p.add_argument('--only')
    p.add_argument('--timeout',type=int,default=5);p.add_argument('--wall-timeout',type=int,default=360)
    p.add_argument('--proof',choices=['per_check','per_path'],default='per_check')
    a=p.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=a.resume)
    parent=ROOT/'experimental/constrained-step';pg=(parent/'constrained.gpr').read_text()
    dirs=re.findall(r'"([^"]+)"',re.search(r'for Source_Dirs use \((.*?)\);',pg,re.S).group(1))
    folders=[(parent/d).resolve() for d in dirs]+[HERE/'src',HERE/'tests']
    if a.standalone:folders=[ROOT/'src',ROOT/'experimental/constraint-solvers-candidate/src',HERE/'src',HERE/'tests']
    files={f for d in (folders[-2:] if a.resume else folders) for f in d.iterdir() if f.is_file() and f.suffix in ['.ads','.adb','.py','.c']}
    files.update([HERE/'noslip.gpr',HERE/'standalone.gpr'] if a.resume else [parent/'constrained.gpr',HERE/'noslip.gpr',HERE/'standalone.gpr'])
    files.add(ROOT/'experimental/constraint-solvers-candidate/tests/differential.py')
    hashes=json.loads((out/'sources.json').read_text()) if a.resume else {}
    for f in sorted(files):
        name=str(f.relative_to(ROOT));data=f.read_bytes();dest=out/'source'/name
        dest.parent.mkdir(parents=True,exist_ok=True);dest.write_bytes(data);hashes[name]=hashlib.sha256(data).hexdigest()
    changed=[str(f.relative_to(ROOT)) for f in files if hashlib.sha256(f.read_bytes()).hexdigest()!=hashes[str(f.relative_to(ROOT))]]
    if changed:raise RuntimeError('Concurrent change while freezing: '+repr(changed))
    (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    project=out/'source/experimental/noslip-candidate'/('standalone.gpr' if a.standalone else 'noslip.gpr');env=environment(out,a.mode);records=[]
    def run(command,label):
        report=out/'build'/a.mode/'obj/gnatprove'/(a.unit+'.spark')
        if a.phase!='build' and report.exists():report.unlink()
        guarded=[sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3500','--min-free-mb','12000','--timeout',str(a.wall_timeout),'--',*command]
        start=time.monotonic();r=subprocess.run(guarded,env=env,text=True,capture_output=True)
        (out/(label+'.log')).write_text(r.stdout+r.stderr)
        rec=dict(command=command,exit=r.returncode,seconds=time.monotonic()-start,label=label)
        if a.phase!='build' and report.exists():
            d=json.loads(report.read_text());(out/(label+'.spark.json')).write_text(json.dumps(d,indent=2)+'\n')
            checks=[x for key in ['proof','flow'] for x in d.get(key,[])]
            rec.update(proved=sum(x.get('severity')=='info' for x in checks),
                       open=[x for x in checks if x.get('severity') not in ['info','warning']],
                       warnings=[x for key in ['proof','flow','warn_error'] for x in d.get(key,[]) if x.get('severity')=='warning'],
                       coverage=dict(skip_proof=d.get('skip_proof'),skip_flow=d.get('skip_flow_proof'),assume=d.get('pragma_assume'),
                                     spark=d.get('spark'),progress=d.get('progress'),stop_reason=d.get('stop_reason')))
            rec['complete_coverage'] = (not d['skip_proof'] and not d['skip_flow_proof']
                and not d['pragma_assume'] and all(v == 'all' for v in d['spark'].values())
                and d['progress'] == 'PROGRESS_PROOF' and d['stop_reason'] == 'STOP_REASON_NONE')
            if a.phase == 'whole':
                expected = {name.lower() for suffix in ('ads','adb')
                    for name in re.findall(r'\b(?:function|procedure)\s+(\w+)',
                        (out/'source/experimental/noslip-candidate/src'/(a.unit+'.'+suffix)).read_text())}
                found = {d['entities'][key]['name'].split('.')[-1].lower() for key in d['spark']}
                rec['missing_entities'] = sorted(expected-found)
                rec['complete_coverage'] = rec['complete_coverage'] and not rec['missing_entities']
        records.append(rec);print(label,'exit',r.returncode,'proved',rec.get('proved'),'open',len(rec.get('open',[])),flush=True)
        if r.returncode and a.phase=='build':print((r.stdout+r.stderr)[-4500:]);raise SystemExit(r.returncode)
    if a.phase=='build':
        run(['gprbuild','-p','-P',str(project),'-j1'],'build')
        for name in (['noslip_probe'] if a.standalone else ['noslip_probe','noslip_step_probe']):
            b=out/'build'/a.mode/'bin'/name;records[-1][name]=dict(path=str(b),sha256=hashlib.sha256(b.read_bytes()).hexdigest())
    else:
        source=out/'source/experimental/noslip-candidate/src'
        body=(source/(a.unit+'.adb')).read_text()
        targets=[(None,'whole')] if a.phase=='whole' else []
        if a.phase=='small':
            for suffix in ('ads','adb'):
                for i,line in enumerate((source/(a.unit+'.'+suffix)).read_text().splitlines(),1):
                    match=re.match(r'\s*(function|procedure) (\w+)\b',line)
                    if not match or (a.only and match[2]!=a.only):continue
                    if suffix=='ads' and re.search(r'\b(?:function|procedure) '+match[2]+r'\b',body):continue
                    targets.append((f'{a.unit}.{suffix}:{i}',match[2]))
        if not targets:raise ValueError('No subprogram matched')
        for limit,name in targets:
            command=['gnatprove','-f','-P',str(project),'-u',a.unit+'.ads','--mode=prove',
                     '--prover=cvc5,z3,altergo','--timeout='+str(a.timeout),'--steps=0','--memlimit=700',
                     '--proof='+a.proof,'-j1','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
            if limit:command.append('--limit-subp='+limit)
            run(command,name)
    (out/'receipts.json').write_text(json.dumps(records,indent=2)+'\n')
    unchanged=all(hashlib.sha256((out/'source'/name).read_bytes()).hexdigest()==digest for name,digest in hashes.items())
    accepted=unchanged and all(r['exit']==0 and (a.phase=='build' or ('open' in r
        and not r['open'] and not r['warnings'] and not r['coverage']['assume']
        and (a.phase!='whole' or r['complete_coverage']))) for r in records)
    (out/'acceptance.json').write_text(json.dumps(dict(passed=accepted,
        snapshot_hashes_unchanged=unchanged,
        checkout_matches_snapshot=all((ROOT/name).is_file() and hashlib.sha256((ROOT/name).read_bytes()).hexdigest()==digest for name,digest in hashes.items())),indent=2)+'\n')
    print(out,flush=True)
    if not accepted:raise SystemExit(1)
if __name__=='__main__':main()
