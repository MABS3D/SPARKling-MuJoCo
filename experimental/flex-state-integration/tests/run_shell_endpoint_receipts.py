"""Renew geometry, API admission and flow on one immutable endpoint closure."""
import argparse
import hashlib
import json
from pathlib import Path
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
    a.out.mkdir(parents=True, exist_ok=False)
    bm = json.loads((a.build / 'manifest.json').read_text())
    for name, value in bm['sources'].items():
        if digest(a.build / 'source' / name) != value:
            raise RuntimeError('frozen source mismatch: '+name)
    if not bm['complete'] or any(r['exit'] or r.get('report_absent') or
                                r.get('counts',{}).get('open',0) for r in bm['steps']):
        raise RuntimeError('endpoint build/proof incomplete')
    here = ROOT / 'experimental/flex-state-integration/tests'
    for name in ('replay_shell_geometry_state.py', 'policy_shell_api.py'):
        shutil.copyfile(here / name, a.out / name)
    shutil.copyfile(a.build / 'guarded.py', a.out / 'guarded.py')
    shutil.copyfile(Path(__file__), a.out / Path(__file__).name)
    scripts = {p.name: digest(p) for p in a.out.glob('*.py')}
    env = environment()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1', FLEX_STATE_MODE='validation')
    rows = []
    manifest = dict(build=str(a.build), sources=bm['sources'], scripts=scripts, steps=rows,
        build_manifest_sha256=digest(a.build / 'manifest.json'), complete=False,
        scope='Owned shell endpoint, geometric state replay and flow; no dynamics or timing.')

    def save():
        (a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')

    def run(name, command, wall):
        cmd = ['/var/tmp/sparkling-movement-env/bin/python', str(a.out / 'guarded.py'),
               '--cap-mb', '2500', '--timeout', str(wall), '--', *command]
        start = time.monotonic()
        with (a.out / (name+'.log')).open('w') as log:
            r = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT)
        rows.append(dict(name=name, command=cmd, exit=r.returncode, seconds=time.monotonic()-start))
        print(json.dumps(rows[-1]), flush=True)
        save()

    save()
    py = '/var/tmp/sparkling-movement-env/bin/python'
    for mode in ('validation', 'release'):
        bins = a.build / 'build' / mode / 'bin'
        run('geometry-'+mode, [py, str(a.out / 'replay_shell_geometry_state.py'),
            '--binary', str(bins / 'flex_shell_state_probe'), '--out', str(a.out / ('geometry-'+mode))], 600)
        run('api-'+mode, [py, str(a.out / 'policy_shell_api.py'), '--binary', str(bins / 'flex_shell_endpoint_probe'),
            '--fixtures', str(a.build / mode / 'positive-endpoints'), '--out', str(a.out / ('api-'+mode))], 240)
    project = a.build / 'source/experimental/flex-state-integration/flex_state.gpr'
    run('flow', ['gnatprove', '-P', str(project), '-XFLEX_STATE_BUILD_ROOT='+str(a.out / 'flow'),
        '-j1', '--report=all', '--checks-as-errors=on', '--warnings=continue', '-u',
        'mj-flex_state.adb', 'mj-data-flex_adapter.adb', '--mode=flow', '--no-inlining'], 240)
    reports = []
    for unit in ('mj-flex_state','mj-data-flex_adapter'):
        report = next((a.out / 'flow').rglob(unit+'.spark'),None)
        if report is None:
            reports.append(dict(unit=unit, report_absent=True))
            continue
        shutil.copyfile(report, a.out / ('flow-'+unit+'.spark.json'))
        d = json.loads(report.read_text())
        entries = [e for k in ('proof','flow','warn_error') for e in d.get(k,[])]
        reports.append(dict(unit=unit, proved=sum(e.get('severity') == 'info' for e in entries),
            warnings=sum(e.get('severity') == 'warning' for e in entries),
            open=sum(e.get('severity') not in ('info','warning') for e in entries)))
    manifest['flow_reports'] = reports
    manifest['complete'] = True
    save()
    for name, value in bm['sources'].items():
        if digest(a.build / 'source' / name) != value:
            raise RuntimeError('frozen source changed: '+name)
    raise SystemExit(any(r['exit'] for r in rows) or any(r.get('report_absent') or r.get('open') for r in reports))


if __name__ == '__main__':
    main()
