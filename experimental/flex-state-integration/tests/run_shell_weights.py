"""Immutable signed-shell kernel closure; one guarded process at a time."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import time

from build import ROOT, environment

COMMON = ['src/mj.ads', 'src/mj-types.ads',
          *['experimental/rigid-collision-candidate/src/' + n for n in
            ('mj-rigid_geometry.ads', 'mj-contact_geometry.ads', 'mj-contact_geometry.adb')]]
OWNED = ['experimental/flex-state-integration/' + n for n in
         ('src/mj-flex_shell_weights.ads', 'src/mj-flex_shell_weights.adb',
          'tests/flex_shell_weights_probe.adb', 'tests/compare_shell_weights.py')]
SCOPES = ['Flat', 'Ratio', 'Local', 'Scale', 'Term_Point', 'Term_Weight', 'Model_Terms', 'Generate',
          'Find', 'Add_Weight', 'Merge', 'After', 'Fold', 'Accumulate', 'whole']


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--base', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--scope', action='append', choices=SCOPES)
    p.add_argument('--no-numeric', action='store_true')
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    source = a.out / 'source'
    source.mkdir()
    base = json.loads((a.base / 'manifest.json').read_text())
    hashes = {}
    for name in COMMON + OWNED:
        original = (a.base / 'source' if name in COMMON else ROOT) / name
        if name in COMMON and digest(original) != base['sources'][name]:
            raise RuntimeError('base source changed: ' + name)
        destination = source / Path(name).name
        shutil.copyfile(original, destination)
        hashes[name] = digest(destination)
    shutil.copyfile(ROOT / 'tools/guarded.py', a.out / 'guarded.py')
    shutil.copyfile(Path(__file__), a.out / Path(__file__).name)
    project = source / 'shell.gpr'
    project.write_text('''project Shell is
 Mode := external ("SHELL_MODE", "validation");
 Root := external ("SHELL_BUILD_ROOT");
 for Source_Dirs use (".");
 for Object_Dir use Root & "/" & Mode & "/obj";
 for Exec_Dir use Root & "/" & Mode & "/bin";
 for Main use ("flex_shell_weights_probe.adb");
 for Create_Missing_Dirs use "True";
 Flags := ("-gnat2022", "-ffp-contract=off");
 case Mode is
 when "release" => Flags := Flags & ("-O3", "-gnatn", "-march=native");
 when others => Flags := Flags & ("-O1", "-g", "-gnata", "-gnato", "-gnatVa");
 end case;
 package Compiler is
 for Default_Switches ("Ada") use Flags;
 end Compiler;
end Shell;
''')
    env = environment()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1')
    rows = []
    manifest = dict(base=str(a.base), base_manifest_sha256=digest(a.base / 'manifest.json'),
                    sources=hashes, project_sha256=digest(project),
                    runner_sha256=digest(Path(__file__)),
                    guarded_sha256=digest(a.out / 'guarded.py'), steps=rows,
                    toolchains={name: subprocess.check_output([name, '--version'], env=env, text=True)
                                for name in ('gcc', 'gprbuild', 'gnatprove')},
                    complete=False, performance='not measured')

    def save():
        (a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def run(name, args, timeout=240):
        command = ['/var/tmp/sparkling-movement-env/bin/python', str(a.out / 'guarded.py'),
                   '--cap-mb', '2500', '--timeout', str(timeout), '--', *args]
        started = time.monotonic()
        with (a.out / (name + '.log')).open('w') as log:
            r = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        rows.append(dict(name=name, command=command, exit=r.returncode,
                         seconds=time.monotonic() - started))
        save()
        print(json.dumps(rows[-1]), flush=True)
        return r.returncode

    save()
    if not a.no_numeric:
        for mode in ('validation', 'release'):
            env.update(SHELL_MODE=mode, SHELL_BUILD_ROOT=str(a.out / 'build'))
            if run('build-' + mode, ['gprbuild', '-P', str(project), '-j1']):
                raise SystemExit(1)
            run('compare-' + mode, ['/var/tmp/sparkling-movement-env/bin/python',
                str(source / 'compare_shell_weights.py'), '--root', str(ROOT),
                '--binary', str(a.out / 'build' / mode / 'bin/flex_shell_weights_probe'),
                '--out', str(a.out / mode)])
    scopes = a.scope or SCOPES
    for scope in scopes:
        if scope == 'whole' and any(r['exit'] or r.get('report_absent') or r.get('coverage_missing')
                                    or r.get('counts', {}).get('open', 0) for r in rows):
            manifest['whole_deferred'] = 'An earlier comparison or minimum did not close.'
            break
        env.update(SHELL_MODE='validation', SHELL_BUILD_ROOT=str(a.out / 'proof' / scope))
        command = ['gnatprove', '-P', str(project), '-u', 'mj-flex_shell_weights.adb',
                   '-j1', '--report=all', '--checks-as-errors=on', '--warnings=continue',
                   '--mode=prove', '--no-inlining', '--prover=cvc5,z3,altergo',
                   '--timeout=5', '--memlimit=650', '--steps=0', '--proof=per_check', '--counterexamples=off']
        if scope != 'whole':
            unit = 'mj-flex_shell_weights.' + ('ads' if scope == 'Term_Point' else 'adb')
            line = next(i for i, text in enumerate((source / unit).read_text().splitlines(), 1)
                        if re.match(r'\s*(?:function|procedure) ' + scope + r'\b', text))
            command.append('--limit-subp=' + unit + ':' + str(line))
        run('proof-' + scope, command, 600 if scope == 'whole' else 240)
        report = next((a.out / 'proof' / scope).rglob('mj-flex_shell_weights.spark'), None)
        if report:
            shutil.copyfile(report, a.out / ('proof-' + scope + '.spark.json'))
            data = json.loads(report.read_text())
            if scope != 'whole':
                rows[-1]['coverage_missing'] = not any(
                    e.get('name', '').lower() == 'mj.flex_shell_weights.' + scope.lower()
                    for e in data.get('entities', {}).values())
            entries = [e for key in ('proof', 'flow', 'warn_error') for e in data.get(key, [])]
            rows[-1]['counts'] = dict(
                proof=sum(e.get('severity') == 'info' for e in data.get('proof', [])),
                flow=sum(e.get('severity') == 'info' for e in data.get('flow', [])),
                warnings=sum(e.get('severity') == 'warning' for e in entries),
                open=sum(e.get('severity') not in ('info', 'warning') for e in entries))
        else:
            rows[-1]['report_absent'] = True
        save()
    for name, expected in hashes.items():
        if digest(source / Path(name).name) != expected:
            raise RuntimeError('frozen source changed: ' + name)
    manifest['complete'] = not manifest.get('whole_deferred')
    save()
    raise SystemExit(any(r['exit'] or r.get('report_absent') or r.get('coverage_missing')
                         or r.get('counts', {}).get('open', 0)
                         for r in rows))


if __name__ == '__main__':
    main()
