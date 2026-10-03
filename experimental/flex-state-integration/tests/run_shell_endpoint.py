"""Freeze the owned signed endpoint separately from live FS and dynamics."""
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
    p.add_argument('--kernel', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    base = Path('/var/tmp/sparkling-recovery-shell-state1-20261003')
    fixtures = Path('/var/tmp/sparkling-recovery-shell-state2-20261003/validation')
    km = json.loads((a.kernel / 'manifest.json').read_text())
    if not any(x['name'] == 'proof-whole' and x['exit'] == 0 and x.get('counts',{}).get('open') == 0
               for x in km['steps']):
        raise RuntimeError('kernel whole proof is not complete')
    bm = json.loads((base / 'manifest.json').read_text())
    source = a.out / 'source'
    hashes, origins = {}, {}

    def copy(original, name, expected=None):
        if expected is not None and digest(original) != expected:
            raise RuntimeError('frozen dependency changed: ' + str(original))
        dest = source / name
        dest.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(original,dest)
        hashes[name], origins[name] = digest(dest),str(original)

    for name, value in bm['sources'].items():
        copy(base / 'source' / name,name,value)
    for name, value in km['sources'].items():
        if '/tests/' in name and not name.endswith('compare_node_weights.py'):
            continue
        if name in hashes and hashes[name] != value:
            raise RuntimeError('kernel dependency differs from FS geometry: ' + name)
        copy(a.kernel / 'source' / Path(name).name,name,value)
    here = 'experimental/flex-state-integration/'
    positive = Path('/var/tmp/sparkling-recovery-nodal-endpoint3-20261003')
    pm = json.loads((positive / 'manifest.json').read_text())
    for name in ('src/mj-flex_state-nodal_contacts.ads', 'src/mj-flex_state-nodal_contacts.adb',
                 'tests/flex_nodal_endpoint_probe.adb', 'tests/compare_nodal_endpoint.py'):
        copy(positive / 'source' / here / name, here + name, pm['sources'][here + name])
    for name in ('mj-flex_state.ads','mj-flex_state.adb','mj-flex_state-shell_contacts.ads',
                 'mj-flex_state-shell_contacts.adb'):
        copy(ROOT / here / 'integration/shell-endpoint' / name,here + 'src/' + name)
    for name in ('flex_shell_endpoint_probe.adb','flex_shell_state_probe.adb',
                 'compare_shell_endpoint.py','policy_shell_endpoint.py'):
        copy(ROOT / here / 'tests' / name,here + 'tests/' + name)
    project = source / here / 'flex_state.gpr'
    project.write_text(project.read_text().replace('("flex_shell_state_probe.adb")',
        '("flex_shell_state_probe.adb", "flex_shell_endpoint_probe.adb", "flex_nodal_endpoint_probe.adb")'))
    hashes[str(project.relative_to(source))] = digest(project)
    shutil.copyfile(ROOT / 'tools/guarded.py',a.out / 'guarded.py')
    shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    env = environment()
    env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1')
    rows = []
    manifest = dict(sources=hashes,origins=origins,base=str(base),kernel=str(a.kernel),
        base_manifest_sha256=digest(base / 'manifest.json'),
        kernel_manifest_sha256=digest(a.kernel / 'manifest.json'),steps=rows,complete=False,
        runner_sha256=digest(Path(__file__)),guarded_sha256=digest(a.out / 'guarded.py'),
        live_FS_changed=False,performance='not measured')

    def save():
        (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')

    def run(name,command,wall=360):
        cmd = ['/var/tmp/sparkling-movement-env/bin/python',str(a.out / 'guarded.py'),
               '--cap-mb','2500','--timeout',str(wall),'--',*command]
        started = time.monotonic()
        with (a.out / (name + '.log')).open('w') as log:
            r = subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
        rows.append(dict(name=name,command=cmd,exit=r.returncode,seconds=time.monotonic()-started))
        save()
        print(json.dumps(rows[-1]),flush=True)
        return r.returncode

    save()
    py = '/var/tmp/sparkling-movement-env/bin/python'
    for mode in ('validation','release'):
        env.update(FLEX_STATE_MODE=mode,FLEX_STATE_BUILD_ROOT=str(a.out / 'build'))
        if run('build-' + mode,['gprbuild','-P',str(project),'-j1']):
            raise SystemExit(1)
        run('compare-' + mode,[py,str(source / here / 'tests/compare_shell_endpoint.py'),
            '--root',str(ROOT),'--binary',str(a.out / 'build' / mode / 'bin/flex_shell_endpoint_probe'),
            '--fixtures',str(fixtures),'--out',str(a.out / mode / 'endpoints')],wall=600)
        run('positive-endpoint-' + mode,[py,str(source / here / 'tests/compare_nodal_endpoint.py'),
            '--root',str(ROOT),'--binary',str(a.out / 'build' / mode / 'bin/flex_nodal_endpoint_probe'),
            '--out',str(a.out / mode / 'positive-endpoints')],wall=600)
        for name in ('shell1_2x2x2_plane_plain','shell2_1x1x1_plane_plain'):
            run(mode + '-admission-' + name,[py,str(source / here / 'tests/policy_shell_endpoint.py'),
                '--binary',str(a.out / 'build' / mode / 'bin/flex_shell_state_probe'),
                '--fixtures',str(fixtures / name),'--model-name',name,
                '--out',str(a.out / mode / ('admission-' + name))],wall=180)
    for scope in ('Local_Bounds','Same_Node_Count','Weights','whole'):
        if scope == 'whole' and any(x['exit'] or x.get('counts',{}).get('open',0) or
                                  x.get('report_absent') for x in rows):
            manifest['whole_deferred'] = True
            break
        env.update(FLEX_STATE_MODE='validation',FLEX_STATE_BUILD_ROOT=str(a.out / 'proof' / scope))
        command = ['gnatprove','-P',str(project),'-u','mj-flex_state-shell_contacts.adb','-j1',
            '--report=all','--checks-as-errors=on','--warnings=continue','--mode=prove','--no-inlining',
            '--prover=cvc5,z3,altergo','--timeout=5','--memlimit=650','--steps=0',
            '--proof=per_check','--counterexamples=off']
        if scope != 'whole':
            line = next(i for i,t in enumerate((source / here / 'src/mj-flex_state-shell_contacts.adb').read_text().splitlines(),1)
                        if re.match(r'\s*procedure ' + scope + r'\b',t))
            command += ['--limit-subp=mj-flex_state-shell_contacts.adb:' + str(line)]
        run('proof-' + scope,command,wall=360)
        report = next((a.out / 'proof' / scope).rglob('mj-flex_state-shell_contacts.spark'),None)
        if report:
            shutil.copyfile(report,a.out / ('proof-' + scope + '.spark.json'))
            data = json.loads(report.read_text())
            entries = [e for k in ('proof','flow','warn_error') for e in data.get(k,[])]
            rows[-1]['counts'] = dict(proof=sum(e.get('severity') == 'info' for e in data.get('proof',[])),
                flow=sum(e.get('severity') == 'info' for e in data.get('flow',[])),
                open=sum(e.get('severity') not in ('info','warning') for e in entries),
                warnings=sum(e.get('severity') == 'warning' for e in entries))
        else:
            rows[-1]['report_absent'] = True
        save()
    for name, value in hashes.items():
        if digest(source / name) != value:
            raise RuntimeError('frozen source changed: ' + name)
    manifest['complete'] = True
    save()
    raise SystemExit(any(r['exit'] or r.get('counts',{}).get('open',0) or r.get('report_absent') for r in rows))


if __name__ == '__main__':
    main()
