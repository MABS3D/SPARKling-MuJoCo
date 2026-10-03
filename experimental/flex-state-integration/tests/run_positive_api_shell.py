"""Renew the positive adapter against the signed-state closure without edits."""
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
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    bm = json.loads((a.build / 'manifest.json').read_text())
    for name, value in bm['sources'].items():
        if digest(a.build / 'source' / name) != value:
            raise RuntimeError('changed frozen dependency: '+name)
    test = ROOT / 'experimental/flex-state-integration/tests/reject_shell_from_positive.py'
    shutil.copyfile(test,a.out / test.name)
    shutil.copyfile(a.build / 'guarded.py',a.out / 'guarded.py')
    shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    rows = []
    manifest = dict(build=str(a.build),build_manifest_sha256=digest(a.build / 'manifest.json'),
        sources=bm['sources'],scripts={p.name:digest(p) for p in a.out.glob('*.py')},
        complete=False,steps=rows)
    env = environment()
    env['FLEX_STATE_MODE'] = 'validation'

    def save():
        (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')

    def run(name,command,wall):
        cmd = ['/var/tmp/sparkling-movement-env/bin/python',str(a.out / 'guarded.py'),
               '--cap-mb','2500','--timeout',str(wall),'--',*command]
        start = time.monotonic()
        with (a.out / (name+'.log')).open('w') as log:
            r = subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
        rows.append(dict(name=name,command=cmd,exit=r.returncode,seconds=time.monotonic()-start))
        save()
        print(json.dumps(rows[-1]),flush=True)

    save()
    for mode in ('validation','release'):
        run(mode,['/var/tmp/sparkling-movement-env/bin/python',str(a.out / test.name),
            '--binary',str(a.build / 'build' / mode / 'bin/flex_nodal_endpoint_probe'),
            '--fixtures',str(a.build / mode / 'endpoints'),'--out',str(a.out / mode)],240)
    project = a.build / 'source/experimental/flex-state-integration/flex_state.gpr'
    for scope in ('Weights','whole'):
        command = ['gnatprove','-P',str(project),'-XFLEX_STATE_BUILD_ROOT='+str(a.out / scope),
            '-j1','--report=all','--checks-as-errors=on','--warnings=continue','-u',
            'mj-flex_state-nodal_contacts.adb','--mode=prove','--prover=cvc5,z3,altergo',
            '--timeout=5','--memlimit=650','--steps=0','--proof=per_check','--no-inlining',
            '--counterexamples=off']
        if scope != 'whole':
            body = a.build / 'source/experimental/flex-state-integration/src/mj-flex_state-nodal_contacts.adb'
            line = next(i for i,t in enumerate(body.read_text().splitlines(),1)
                        if re.match(r'\s*procedure '+scope+r'\b',t))
            command += ['--limit-subp=mj-flex_state-nodal_contacts.adb:'+str(line)]
        run(scope,command,360)
        report = next((a.out / scope).rglob('mj-flex_state-nodal_contacts.spark'),None)
        if report:
            shutil.copyfile(report,a.out / (scope+'.spark.json'))
            d = json.loads(report.read_text())
            entries = [e for k in ('proof','flow','warn_error') for e in d.get(k,[])]
            rows[-1]['counts'] = dict(proof=sum(e.get('severity') == 'info' for e in d.get('proof',[])),
                flow=sum(e.get('severity') == 'info' for e in d.get('flow',[])),
                warnings=sum(e.get('severity') == 'warning' for e in entries),
                open=sum(e.get('severity') not in ('info','warning') for e in entries))
        else:
            rows[-1]['report_absent'] = True
        save()
        if rows[-1]['exit'] or rows[-1].get('report_absent') or rows[-1]['counts']['open']:
            break
    manifest['complete'] = True
    save()
    raise SystemExit(any(r['exit'] or r.get('report_absent') or r.get('counts',{}).get('open',0) for r in rows))


if __name__ == '__main__':
    main()
