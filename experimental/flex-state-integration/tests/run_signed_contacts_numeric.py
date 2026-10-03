"""Frozen Ada kinematics -> owned side producer -> signed response, two profiles."""
import argparse,hashlib,json,re,shutil,subprocess,time
from pathlib import Path
from build import ROOT,environment


def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--proof',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--allow-open',action='store_true')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    pm=json.loads((a.proof/'manifest.json').read_text())
    proved=any(s['name']=='whole' and s['exit']==0 and s.get('counts',{}).get('open')==0 for s in pm['steps'])
    if not pm['complete'] or (not proved and not a.allow_open):raise RuntimeError('proof not complete')
    src=a.out/'source';hashes={}
    for n,h in pm['sources'].items():
        origin=a.proof/'source'/n
        if digest(origin)!=h:raise RuntimeError('source changed')
        dest=src/n;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(origin,dest);hashes[n]=h
    tests=src/'experimental/flex-elasticity-integration/tests';tests.mkdir(exist_ok=True)
    here=ROOT/'experimental/flex-state-integration/tests'
    for n in ('mj-data-constrained-signed_probe.adb','compare_signed_contacts.py','reference_contact_side.py','reference_response.py'):
        origin=here/n;shutil.copyfile(origin,tests/n);hashes[str((tests/n).relative_to(src))]=digest(tests/n)
    project=src/'experimental/flex-elasticity-integration/flex_constrained.gpr'
    project.write_text(re.sub(r'for Main use \([^;]+;', 'for Main use ("mj-data-constrained-signed_probe.adb");',project.read_text()))
    hashes[str(project.relative_to(src))]=digest(project)
    shutil.copyfile(ROOT/'tools/guarded.py',a.out/'guarded.py');shutil.copyfile(Path(__file__),a.out/Path(__file__).name)
    references=dict(side=Path('/var/tmp/sparkling-recovery-shell-contact-side-numeric1-20261003/reference'),
                    response=Path('/var/tmp/sparkling-recovery-shell-response-native1-20261003/reference'))
    models=json.loads(Path('/var/tmp/sparkling-recovery-shell-contact-side-numeric1-20261003/manifest.json').read_text())['models']
    for n,h in models.items():
        if digest(Path(n))!=h:raise RuntimeError('fixture changed')
    env=environment();env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',FLEX_BUILD_ROOT=str(a.out/'build'))
    steps=[];manifest=dict(proof=str(a.proof),proof_manifest_sha256=digest(a.proof/'manifest.json'),formal_acceptance=proved,
        sources=hashes,models=models,references={k:dict(path=str(v),manifest_sha256=digest(v/'manifest.json'),library_sha256=digest(v/'reference.so')) for k,v in references.items()},
        guard_sha256=digest(a.out/'guarded.py'),runner_sha256=digest(Path(__file__)),steps=steps,complete=False,performance='not measured')
    def save():(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def run(name,args,wall=360):
        cmd=['/var/tmp/sparkling-movement-env/bin/python',str(a.out/'guarded.py'),'--cap-mb','2500','--timeout',str(wall),'--',*args]
        started=time.monotonic()
        with (a.out/(name+'.log')).open('w') as log:r=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
        steps.append(dict(name=name,command=cmd,exit=r.returncode,seconds=time.monotonic()-started));save();print(json.dumps(steps[-1]),flush=True);return r.returncode
    save()
    for mode in ('validation','release'):
        env['FLEX_MODE']=mode
        if run('build-'+mode,['gprbuild','-P',str(project),'-j1']):break
        for name in models:
            model=Path(name)
            run(mode+'-'+model.stem,['/var/tmp/sparkling-movement-env/bin/python',str(tests/'compare_signed_contacts.py'),
                '--binary',str(a.out/'build'/mode/'bin/mj-data-constrained-signed_probe'),
                '--model',name,'--side-reference',str(references['side']),'--response-reference',str(references['response']),
                '--out',str(a.out/mode/model.stem)])
    manifest['complete']=True;save();raise SystemExit(any(s['exit'] for s in steps))


if __name__=='__main__':main()
