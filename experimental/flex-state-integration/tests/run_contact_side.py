"""Freeze the new contact-side producer separately from FE and the parent."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import time
from build import ROOT, environment


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
    base = Path('/var/tmp/sparkling-recovery-shell-endpoint2-20261003')
    bm = json.loads((base / 'manifest.json').read_text())
    src = a.out / 'source'; hashes = {}; origins = {}
    def copy(origin,name,expected=None):
        if expected is not None and digest(origin) != expected: raise RuntimeError('base changed: '+name)
        dest = src / name; dest.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(origin,dest)
        hashes[name] = digest(dest); origins[name] = str(origin)
    for name,value in bm['sources'].items(): copy(base / 'source' / name,name,value)
    for ext in ('ads','adb'):
        name = 'mj-flex_state-response_contacts.'+ext
        copy(ROOT / 'experimental/flex-state-integration/integration/shell-dynamics/src' / name,
             'experimental/flex-state-integration/src/'+name)
        name = 'experimental/flex-elasticity-integration/src/mj-flex_contact_weights.'+ext
        copy(ROOT / name,name)
    project = src / 'experimental/flex-state-integration/flex_state.gpr'
    project.write_text(project.read_text().replace('"../constrained-step/src", "../sdf-step/src"',
        '"../constrained-step/src", "../sdf-step/src", "../flex-elasticity-integration/src"'))
    hashes[str(project.relative_to(src))] = digest(project)
    shutil.copyfile(ROOT / 'tools/guarded.py',a.out / 'guarded.py')
    shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    env = environment(); env['FLEX_STATE_MODE'] = 'validation'; rows = []
    manifest = dict(base=str(base),base_manifest_sha256=digest(base / 'manifest.json'),
        sources=hashes,origins=origins,runner_sha256=digest(Path(__file__)),
        guard_sha256=digest(a.out / 'guarded.py'),steps=rows,complete=False)
    def save(): (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save()
    for unit,scope in [('mj-flex_contact_weights','Normalize'),('mj-flex_contact_weights','whole'),
                       ('mj-flex_state-response_contacts','Signed'),('mj-flex_state-response_contacts','Side'),
                       ('mj-flex_state-response_contacts','whole')]:
        if unit.endswith('response_contacts') and scope == 'whole' and any(
                r['exit'] or r.get('report_absent') or r.get('counts',{}).get('open') for r in rows):
            manifest['whole_deferred'] = True; break
        name = unit+'-'+scope
        cmd = ['gnatprove','-P',str(project),'-XFLEX_STATE_BUILD_ROOT='+str(a.out / name),
            '-j1','--report=all','--checks-as-errors=on','--warnings=continue','-u',unit+'.adb',
            '--mode=prove','--prover=cvc5,z3,altergo','--timeout=5','--memlimit=650',
            '--steps=0','--proof=per_check','--no-inlining','--counterexamples=off']
        if scope != 'whole':
            body = next(src.rglob(unit+'.adb'))
            line = next(i for i,t in enumerate(body.read_text().splitlines(),1)
                        if re.match(r'\s*(function|procedure) '+scope+r'\b',t))
            cmd += ['--limit-subp='+unit+'.adb:'+str(line)]
        command = ['/var/tmp/sparkling-movement-env/bin/python',str(a.out / 'guarded.py'),
            '--cap-mb','2500','--timeout','360','--',*cmd]
        start = time.monotonic()
        with (a.out / (name+'.log')).open('w') as log:
            r = subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT)
        row = dict(name=name,command=command,exit=r.returncode,seconds=time.monotonic()-start)
        report = next((a.out / name).rglob(unit+'.spark'),None)
        if report:
            shutil.copyfile(report,a.out / (name+'.spark.json'))
            d = json.loads(report.read_text()); entries = [e for k in ('proof','flow','warn_error') for e in d.get(k,[])]
            row['counts'] = dict(proof=sum(e.get('severity') == 'info' for e in d.get('proof',[])),
                flow=sum(e.get('severity') == 'info' for e in d.get('flow',[])),
                warnings=sum(e.get('severity') == 'warning' for e in entries),
                open=sum(e.get('severity') not in ('info','warning') for e in entries))
        else: row['report_absent'] = True
        rows.append(row); save(); print(json.dumps(row),flush=True)
    manifest['complete'] = True; save()
    raise SystemExit(any(r['exit'] or r.get('report_absent') or r.get('counts',{}).get('open') for r in rows))


if __name__ == '__main__':
    main()
