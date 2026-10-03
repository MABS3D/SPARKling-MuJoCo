"""Preserve the first harness failure; replay verified binaries with a new harness."""
import argparse, hashlib, json, shutil, subprocess, time
from pathlib import Path
from build import ROOT, environment


def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    bm=json.loads((a.base/'manifest.json').read_text())
    if not bm['complete'] or not all(any(s['name']=='build-'+m and s['exit']==0 for s in bm['steps']) for m in ('validation','release')):
        raise RuntimeError('both binaries must be terminal and built')
    src=a.out/'source';src.mkdir();hashes={}
    for n in ('compare_contact_side.py','reference_contact_side.py','reference_response.py'):
        origin=ROOT/'experimental/flex-state-integration/tests'/n
        if n!='compare_contact_side.py':origin=a.base/'source/experimental/flex-state-integration/tests'/n
        shutil.copyfile(origin,src/n);hashes[n]=digest(src/n)
    shutil.copyfile(ROOT/'tools/guarded.py',a.out/'guarded.py');shutil.copyfile(Path(__file__),a.out/Path(__file__).name)
    models={}
    for n,h in bm['models'].items():
        if digest(Path(n))!=h:raise RuntimeError('fixture changed')
        models[n]=h
    rows=[];manifest=dict(base=str(a.base),base_manifest_sha256=digest(a.base/'manifest.json'),
        sources=hashes,models=models,steps=rows,complete=False,
        binaries={m:digest(a.base/'build'/m/'bin/flex_contact_side_probe') for m in ('validation','release')},
        guard_sha256=digest(a.out/'guarded.py'),runner_sha256=digest(Path(__file__)))
    def save():(a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save();env=environment();env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1')
    for mode in ('validation','release'):
        for name in models:
            model=Path(name)
            cmd=['/var/tmp/sparkling-movement-env/bin/python',str(a.out/'guarded.py'),'--cap-mb','2500','--timeout','360','--',
                 '/var/tmp/sparkling-movement-env/bin/python',str(src/'compare_contact_side.py'),
                 '--binary',str(a.base/'build'/mode/'bin/flex_contact_side_probe'),'--reference',str(a.base/'reference'),
                 '--model',name,'--out',str(a.out/mode/model.stem)]
            start=time.monotonic()
            with (a.out/(mode+'-'+model.stem+'.log')).open('w') as log:r=subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
            rows.append(dict(name=mode+'-'+model.stem,command=cmd,exit=r.returncode,seconds=time.monotonic()-start));save();print(json.dumps(rows[-1]),flush=True)
    manifest['complete']=True;save();raise SystemExit(any(s['exit'] for s in rows))


if __name__=='__main__':main()
