"""Freeze the integrated dependency closure and renew BVH cache contracts.

Only the two BVH sources are refreshed. Missing reports remain unknown, never
zero-open proof results. Minima run serially before optional whole-unit proof.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
OWNED = [f'experimental/advanced-collision-candidate/src/mj-bvh.{x}'
         for x in ('ads', 'adb')]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--base', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--scope', action='append', choices=[
        'Frame_Product', 'Frame_Offset', 'Rows_Equal', 'Plane_Equal', 'Frame_Equal', 'Cache_Equal', 'Same_Offset', 'Model_Cache', 'Model_Offset', 'Cache_Matches',
        'Prepare_Bounded', 'Prepare', 'Traverse', 'whole'])
    parser.add_argument('--timeout', type=int, default=15)
    parser.add_argument('--whole-wall', type=int, default=900,
                        help='Total guarded wall limit for the complete unit, in seconds')
    parser.add_argument('--minimum-wall', type=int, default=240,
                        help='Total guarded wall limit for each minimal scope, in seconds')
    parser.add_argument('--provers', default='cvc5,z3,altergo')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.out / 'source'
    base_manifest = args.base / 'manifest.json'
    original = json.loads(base_manifest.read_text())
    hashes = {}
    for name, expected in original['sources'].items():
        original_path = args.base / 'source' / name
        if digest(original_path) != expected:
            raise RuntimeError('base changed: ' + name)
        origin = ROOT / name if name in OWNED else original_path
        destination = source / name
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(origin, destination)
        hashes[name] = digest(destination)
    for name in OWNED:
        if digest(ROOT / name) != hashes[name]:
            raise RuntimeError('concurrent BVH change: ' + name)
    shutil.copyfile(Path(__file__), args.out / Path(__file__).name)
    shutil.copyfile(ROOT / 'tools/guarded.py', args.out / 'guarded.py')
    env = os.environ.copy()
    tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(p) for tool in ('gnat', 'gprbuild', 'gnatprove')
                           for p in (tc / tool).glob('*/bin')) + ':' + env['PATH']
    rows = []
    manifest = dict(base=str(args.base), base_manifest_sha256=digest(base_manifest),
                    sources=hashes, refreshed=OWNED, scopes=rows, complete=False,
                    runner_sha256=digest(Path(__file__)),
                    guarded_sha256=digest(args.out / 'guarded.py'),
                    gnatprove_version=subprocess.check_output(
                        ['gnatprove', '--version'], env=env, text=True).strip())

    def save():
        pending = args.out / 'manifest.pending.json'
        pending.write_text(json.dumps(manifest, indent=2) + '\n')
        pending.replace(args.out / 'manifest.json')

    save()
    scopes = args.scope or ['Frame_Product', 'Frame_Offset', 'Rows_Equal', 'Plane_Equal', 'Frame_Equal', 'Cache_Equal', 'Same_Offset', 'Model_Cache', 'Model_Offset', 'Cache_Matches', 'Prepare_Bounded',
                            'Prepare', 'whole']
    for scope in scopes:
        if scope == 'whole' and any(not r['passed'] for r in rows):
            manifest['whole_deferred'] = 'A selected minimum did not close.'
            break
        env.update(SDF_MODE='validation', SDF_BUILD_ROOT=str(args.out / scope))
        command = [sys.executable, str(args.out / 'guarded.py'), '--cap-mb', '2500',
                   '--timeout', str(args.whole_wall if scope == 'whole' else args.minimum_wall), '--',
                   'gnatprove', '-P', str(source / 'experimental/sdf-step/sdf.gpr'),
                   '-u', 'mj-bvh.adb', '-j1', '--report=all',
                   '--checks-as-errors=on', '--warnings=continue', '--mode=prove',
                   '--prover=' + args.provers, '--timeout=' + str(args.timeout),
                   '--memlimit=650', '--steps=0', '--proof=per_check',
                   '--counterexamples=off', '--no-inlining']
        if scope != 'whole':
            lines = (source / OWNED[1]).read_text().splitlines()
            line = next(i for i, text in enumerate(lines, 1)
                        if re.match(r'\s*(?:function|procedure) ' + scope + r'\b', text))
            command.append('--limit-subp=mj-bvh.adb:' + str(line))
        started = time.monotonic()
        with (args.out / (scope + '.log')).open('w') as log:
            run = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        report = args.out / scope / 'validation/obj/gnatprove/mj-bvh.spark'
        counts = None
        if report.is_file():
            shutil.copyfile(report, args.out / (scope + '.spark.json'))
            data = json.loads(report.read_text())
            entries = [e for group in ('proof', 'flow', 'warn_error')
                       for e in data.get(group, [])]
            counts = dict(proof=sum(e.get('severity') == 'info'
                                    for e in data.get('proof', [])),
                          flow=sum(e.get('severity') == 'info'
                                   for e in data.get('flow', [])),
                          warnings=sum(e.get('severity') == 'warning' for e in entries),
                          open=sum(e.get('severity') not in ('info', 'warning')
                                   for e in entries))
        row = dict(scope=scope, exit=run.returncode, report_available=report.is_file(),
                   counts=counts, passed=run.returncode == 0 and counts is not None
                   and counts['open'] == 0, seconds=time.monotonic() - started,
                   command=command)
        rows.append(row)
        save()
        print(json.dumps(row), flush=True)
    manifest['complete'] = len(rows) == len(scopes)
    for name, expected in hashes.items():
        if digest(source / name) != expected:
            raise RuntimeError('frozen source changed: ' + name)
    save()
    raise SystemExit(not manifest['complete'] or any(not r['passed'] for r in rows))


if __name__ == '__main__':
    main()
