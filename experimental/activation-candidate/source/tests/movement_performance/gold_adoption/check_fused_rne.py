#!/usr/bin/env python3
"""Build and exercise the standalone fused RNE prerequisite, without timing."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((args.toolchain_root / tool).glob('*/bin')))
                           for tool in ('gnat', 'gprbuild')) + ':' + env['PATH']
    results = []
    for mode in ('checked', 'release'):
        work = out / mode
        work.mkdir()
        flags = ['-gnat2022', '-ffp-contract=off']
        flags += ['-O0', '-g', '-gnata', '-gnato', '-gnatVa'] if mode == 'checked' else ['-O3', '-gnatp']
        directories = [HERE, REPO / 'experimental/smooth/src', REPO / 'src', REPO / 'src/gen']
        quote = lambda values: ', '.join('"' + str(value).replace('"', '""') + '"' for value in values)
        project = work / 'test.gpr'
        project.write_text('project Test is\n'
            f' for Source_Dirs use ({quote(directories)});\n'
            ' for Main use ("fused_rne_test.adb");\n'
            ' for Object_Dir use "obj";\n'
            ' for Exec_Dir use "bin";\n'
            ' for Create_Missing_Dirs use "True";\n'
            ' package Compiler is\n'
            f'  for Default_Switches ("Ada") use ({quote(flags)});\n'
            ' end Compiler;\nend Test;\n')
        command = ['gprbuild', '-P', str(project), '-j2']
        with (work / 'build.log').open('w') as log:
            subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                           check=True, timeout=180)
        binary = work / 'bin/fused_rne_test'
        result = subprocess.run([str(binary)], env=env, capture_output=True,
                                text=True, check=True, timeout=30)
        (work / 'test.log').write_text(result.stdout + result.stderr)
        results.append(dict(mode=mode, command=command, flags=flags, status='passed',
                            binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest()))
        print(mode + ': ' + result.stdout.strip(), flush=True)
    (out / 'results.json').write_text(json.dumps(results, indent=2) + '\n')


if __name__ == '__main__':
    main()
