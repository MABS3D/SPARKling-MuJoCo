"""Renew existing advanced tests on an exact integrated source closure.

The numerical oracle and test fixtures come from a previously recorded native-C
run. No runtime source is refreshed from the working tree. All jobs are serial.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import subprocess
import sys
import time


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def checked_copy(source, destination, expected):
    if digest(source) != expected:
        raise RuntimeError('changed source: ' + str(source))
    destination.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(source, destination)
    if digest(destination) != expected:
        raise RuntimeError('changed copy: ' + str(destination))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--closure', type=Path, required=True)
    parser.add_argument('--oracle-run', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--stack-mb', type=int, default=128)
    args = parser.parse_args()
    args.out = args.out.resolve()
    args.out.mkdir(parents=True, exist_ok=False)
    previous_stack = resource.getrlimit(resource.RLIMIT_STACK)
    stack_bytes = args.stack_mb * 1024 * 1024
    resource.setrlimit(resource.RLIMIT_STACK, (stack_bytes, previous_stack[1]))
    source_manifest = args.closure / 'manifest.json'
    oracle_manifest = args.oracle_run / 'manifest.json'
    source = json.loads(source_manifest.read_text())
    oracle = json.loads(oracle_manifest.read_text())
    reference = oracle['reference']
    if (reference['version'] != '3.14.0'
            or reference['actual_commit'] != '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'
            or reference['working_tree_status']):
        raise RuntimeError('oracle is not the clean pinned release')
    if digest(Path(reference['library'])) != reference['library_sha256']:
        raise RuntimeError('native reference library changed')
    for name, expected in source['sources'].items():
        checked_copy(args.closure / 'source' / name,
                     args.out / 'source' / name, expected)
    for name in ('advanced_probe.adb', 'advanced_checks.adb', 'verify.py'):
        checked_copy(args.oracle_run / 'snapshot/tests' / name,
                     args.out / 'tests' / name, oracle['candidate_sha256']['tests/' + name])
    checked_copy(args.oracle_run / 'reference.so', args.out / 'reference.so',
                 oracle['oracle_sha256'])
    checked_copy(args.oracle_run / 'guarded.py', args.out / 'guarded.py',
                 digest(args.oracle_run / 'guarded.py'))
    shutil.copyfile(Path(__file__), args.out / Path(__file__).name)

    # Use the exact integrated dependencies, with the established test mains.
    dirs = sorted({str(Path('source') / Path(n).parent)
                   for n in source['sources'] if Path(n).suffix in ('.ads', '.adb')})
    project = args.out / 'advanced_frozen.gpr'
    project.write_text('''project Advanced_Frozen is
   Build_Root := external ("ADVANCED_BUILD_ROOT");
   Mode := external ("ADVANCED_MODE", "validation");
   for Source_Dirs use (''' + ', '.join('"' + d + '"' for d in ['tests', *dirs]) + ''');
   for Object_Dir use Build_Root & "/" & Mode & "/obj";
   for Exec_Dir use Build_Root & "/" & Mode & "/bin";
   for Create_Missing_Dirs use "True";
   for Main use ("advanced_probe.adb", "advanced_checks.adb");
   package Compiler is
      case Mode is
         when "release" =>
            for Default_Switches ("Ada") use
              ("-gnat2022", "-O3", "-gnatp", "-gnatn", "-march=native", "-flto", "-ffp-contract=off");
         when others =>
            for Default_Switches ("Ada") use
              ("-gnat2022", "-O1", "-gnata", "-gnato", "-gnatVa", "-ffp-contract=off");
      end case;
   end Compiler;
   package Linker is
      for Default_Switches ("Ada") use ("-flto", "-ffp-contract=off");
   end Linker;
end Advanced_Frozen;
''')
    env = os.environ.copy()
    toolchains = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(p) for tool in ('gnat', 'gprbuild')
                          for p in (toolchains / tool).glob('*/bin')) + ':' + env['PATH']
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1')
    rows = []
    receipt = dict(source_manifest=str(source_manifest),
                   source_manifest_sha256=digest(source_manifest),
                   oracle_manifest=str(oracle_manifest),
                   oracle_manifest_sha256=digest(oracle_manifest),
                   reference=reference, sources=source['sources'],
                   fixtures={p.name: digest(p) for p in (args.out / 'tests').iterdir()},
                   oracle_sha256=digest(args.out / 'reference.so'),
                   project_sha256=digest(project),
                   runner_sha256=digest(Path(__file__)),
                   guarded_sha256=digest(args.out / 'guarded.py'),
                   stack_bytes=stack_bytes, previous_stack_limit=previous_stack,
                   compiler=subprocess.check_output(['gcc', '--version'], env=env, text=True),
                   gprbuild=subprocess.check_output(['gprbuild', '--version'], env=env, text=True),
                   scopes=rows, complete=False, performance='not measured')

    def save():
        (args.out / 'manifest.json').write_text(json.dumps(receipt, indent=2) + '\n')

    def run(label, command):
        command = [sys.executable, str(args.out / 'guarded.py'), '--cap-mb', '2500',
                   '--timeout', '360', '--', *map(str, command)]
        started = time.monotonic()
        with (args.out / (label + '.log')).open('w') as log:
            result = subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT)
        rows.append(dict(scope=label, command=command, exit=result.returncode,
                         seconds=time.monotonic() - started))
        save()
        print(json.dumps(rows[-1]), flush=True)
        if result.returncode:
            raise SystemExit(result.returncode)

    save()
    for mode in ('validation', 'release'):
        binary = args.out / 'build' / mode / 'bin'
        run(mode + '-build', ['gprbuild', '-P', project, '-j1',
                              '-XADVANCED_MODE=' + mode,
                              '-XADVANCED_BUILD_ROOT=' + str(args.out / 'build')])
        run(mode + '-checks', [binary / 'advanced_checks'])
        run(mode + '-differential', [sys.executable, args.out / 'tests/verify.py',
                                     '--binary', binary / 'advanced_probe',
                                     '--oracle', args.out / 'reference.so',
                                     '--out', args.out / mode])
    for name, expected in source['sources'].items():
        if digest(args.out / 'source' / name) != expected:
            raise RuntimeError('frozen runtime source changed: ' + name)
    receipt['binaries'] = {str(p.relative_to(args.out)): digest(p)
                           for mode in ('validation', 'release')
                           for p in (args.out / 'build' / mode / 'bin').iterdir()
                           if p.is_file()}
    receipt['complete'] = True
    save()


if __name__ == '__main__':
    main()
