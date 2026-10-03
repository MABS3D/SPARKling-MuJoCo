"""Compose r259 common with immutable shell endpoints, then prove new minima."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment


def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    base=Path('/var/tmp/sparkling-flex-equality-step-20261003-r259-element-source')
    endpoint=Path('/var/tmp/sparkling-recovery-shell-endpoint2-delivery-20261003')
    side=Path('/var/tmp/sparkling-recovery-shell-contact-side1-20261003')
    response=Path('/var/tmp/sparkling-recovery-shell-response2-20261003')
    src=a.out/'source';hashes={};origins={}
    def copy(origin,name,want):
        if digest(origin)!=want:raise RuntimeError('source mismatch: '+str(origin))
        target=src/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(origin,target)
        hashes[name]=want;origins[name]=str(origin)
    for n,h in json.loads((base/'manifest.json').read_text())['sources'].items():copy(base/'source'/n,n,h)
    for n,r in json.loads((endpoint/'manifest.json').read_text())['sources'].items():copy(Path(r['frozen_source']),n,r['sha256'])
    sm=json.loads((side/'manifest.json').read_text())
    for stem in ('mj-flex_node_weights','mj-flex_state-nodal_contacts','mj-flex_state-response_contacts'):
        for ext in ('ads','adb'):
            n='experimental/flex-state-integration/src/'+stem+'.'+ext
            copy(side/'source'/n,n,sm['sources'][n])
    rm=json.loads((response/'manifest.json').read_text())
    for n,h in rm['sources'].items():
        if 'mj-flex_response_kernels.' in n:
            copy(response/'source'/Path(n).name,'experimental/flex-state-integration/src/'+Path(n).name,h)
    for ext in ('ads','adb'):
        name='mj-data-constrained-signed_contacts.'+ext
        origin=ROOT/'experimental/flex-state-integration/integration/shell-dynamics/src'/name
        copy(origin,'experimental/flex-state-integration/src/'+name,digest(origin))
    project=src/'experimental/flex-elasticity-integration/flex_constrained.gpr'
    shutil.copyfile(ROOT/'tools/guarded.py',a.out/'guarded.py');shutil.copyfile(Path(__file__),a.out/Path(__file__).name)
    env=environment();env['FLEX_MODE']='validation';steps=[]
    manifest=dict(sources=hashes,origins=origins,base=str(base),base_manifest_sha256=digest(base/'manifest.json'),
        endpoint_manifest_sha256=digest(endpoint/'manifest.json'),steps=steps,complete=False,
        guard_sha256=digest(a.out/'guarded.py'),runner_sha256=digest(Path(__file__)))
    def save():(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save()
    for scope in ('Storage_Valid','Add_Diagonal','Diagonal','Add_Jacobian','Build','whole'):
        if scope=='whole' and any(s['exit'] or s.get('report_absent') or s.get('counts',{}).get('open') for s in steps):
            manifest['whole_deferred']=True;break
        unit='mj-data-constrained-signed_contacts';body=src/'experimental/flex-state-integration/src'/(unit+'.adb')
        cmd=['gnatprove','-P',str(project),'-XFLEX_BUILD_ROOT='+str(a.out/'proof'),'-j1','--report=all',
            '--checks-as-errors=on','--warnings=continue','-u',unit+'.adb','--mode=prove','--prover=cvc5,z3,altergo',
            '--timeout=5','--memlimit=650','--steps=0','--proof=per_check','--no-inlining','--counterexamples=off']
        if scope!='whole':
            line=next(i for i,t in enumerate(body.read_text().splitlines(),1) if re.match(r'\s*(function|procedure) '+scope+r'\b',t))
            cmd+=['--limit-subp='+unit+'.adb:'+str(line)]
        command=['/var/tmp/sparkling-movement-env/bin/python',str(a.out/'guarded.py'),'--cap-mb','2500','--timeout','360','--',*cmd]
        start=time.monotonic()
        with (a.out/(scope+'.log')).open('w') as log:r=subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT)
        row=dict(name=scope,command=command,exit=r.returncode,seconds=time.monotonic()-start)
        report=next((a.out/'proof').rglob(unit+'.spark'),None)
        if report:
            shutil.copyfile(report,a.out/(scope+'.spark.json'));d=json.loads(report.read_text());entries=[e for k in ('proof','flow','warn_error') for e in d.get(k,[])]
            row['counts']=dict(proof=sum(e.get('severity')=='info' for e in d.get('proof',[])),flow=sum(e.get('severity')=='info' for e in d.get('flow',[])),
                warnings=sum(e.get('severity')=='warning' for e in entries),open=sum(e.get('severity') not in ('info','warning') for e in entries))
            report_text=report.parent/'gnatprove.out'
            if report_text.exists():shutil.copyfile(report_text,a.out/(scope+'.report.txt'))
        else:row['report_absent']=True
        steps.append(row);save();print(json.dumps(row),flush=True)
        if row.get('report_absent'):break
    manifest['complete']=True;save();raise SystemExit(any(s['exit'] or s.get('report_absent') or s.get('counts',{}).get('open') for s in steps))


if __name__=='__main__':main()
