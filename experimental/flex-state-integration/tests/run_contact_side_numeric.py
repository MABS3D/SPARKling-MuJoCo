"""Build the proven side producer and test native models in separate processes."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import time
from build import ROOT, environment


def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof',type=Path,required=True); p.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
    pm = json.loads((a.proof / 'manifest.json').read_text())
    if not pm['complete'] or any(s['exit'] or s.get('counts',{}).get('open') for s in pm['steps']):
        raise RuntimeError('proof incomplete')
    src = a.out / 'source'; hashes = {}; here = Path('experimental/flex-state-integration')
    for name,value in pm['sources'].items():
        origin = a.proof / 'source' / name
        if digest(origin) != value: raise RuntimeError('proof source changed: '+name)
        dest = src / name; dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(origin,dest); hashes[name] = value
    for name in ('flex_contact_side_probe.adb','compare_contact_side.py','reference_contact_side.py','reference_response.py'):
        rel = here / 'tests' / name; shutil.copyfile(ROOT / rel,src / rel); hashes[str(rel)] = digest(src / rel)
    project = src / here / 'flex_state.gpr'
    project.write_text(re.sub(r'for Main use \([^;]+;', 'for Main use ("flex_contact_side_probe.adb");',project.read_text()))
    hashes[str(project.relative_to(src))] = digest(project)
    shutil.copyfile(ROOT / 'tools/guarded.py',a.out / 'guarded.py'); shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    fixtures = Path('/var/tmp/sparkling-recovery-shell-endpoint2-20261003/validation')
    records = json.loads((fixtures / 'endpoints/results.json').read_text())['records']
    names = ['shell1_2x2x2_plane_plain','shell1_1x1x1_box_rotated','shell2_1x1x1_plane_pinned','shell2_2x1x2_plane_mixed']
    models = []
    for n in names:
        r = next(r for r in records if r['model'] == n); model = Path(r['model_path'])
        if not r['passed'] or digest(model) != r['model_sha256']: raise RuntimeError('changed fixture')
        models.append(model)
    models += [fixtures / 'positive-endpoints' / (n+'.mjb') for n in ('order1_1x1x1_pinFalse','order2_1x1x1_pinTrue')]
    env = environment(); env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',FLEX_STATE_BUILD_ROOT=str(a.out / 'build'))
    py = '/var/tmp/sparkling-movement-env/bin/python'; steps = []
    manifest = dict(proof=str(a.proof),proof_manifest_sha256=digest(a.proof / 'manifest.json'),sources=hashes,
        guard_sha256=digest(a.out / 'guarded.py'),runner_sha256=digest(Path(__file__)),steps=steps,complete=False,
        models={str(p):digest(p) for p in models},performance='not measured')
    def save(): (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    def run(name,args,wall=360):
        cmd = [py,str(a.out / 'guarded.py'),'--cap-mb','2500','--timeout',str(wall),'--',*args]
        started = time.monotonic()
        with (a.out / (name+'.log')).open('w') as log: r = subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
        steps.append(dict(name=name,command=cmd,exit=r.returncode,seconds=time.monotonic()-started)); save(); print(json.dumps(steps[-1]),flush=True)
        return r.returncode
    save()
    script = 'from pathlib import Path; from reference_contact_side import build; build(Path('+repr(str(ROOT))+'),Path('+repr(str(a.out / 'reference'))+'))'
    env['PYTHONPATH'] = str(src / here / 'tests')
    if run('reference',[py,'-c',script],60): raise SystemExit(1)
    manifest['reference_manifest_sha256'] = digest(a.out / 'reference/manifest.json'); save()
    for mode in ('validation','release'):
        env['FLEX_STATE_MODE'] = mode
        if run('build-'+mode,['gprbuild','-P',str(project),'-j1']): break
        for model in models:
            run(mode+'-'+model.stem,[py,str(src / here / 'tests/compare_contact_side.py'),
                '--binary',str(a.out / 'build' / mode / 'bin/flex_contact_side_probe'),
                '--reference',str(a.out / 'reference'),'--model',str(model),'--out',str(a.out / mode / model.stem)])
    manifest['complete'] = True; save(); raise SystemExit(any(s['exit'] for s in steps))


if __name__ == '__main__': main()
