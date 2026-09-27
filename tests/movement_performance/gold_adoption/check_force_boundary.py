#!/usr/bin/env python3
"""Build a probe for a public phase boundary from a frozen candidate build.

The injected checks use explicit exceptions in checked and release builds.
Run the resulting probe with compare_numerics.py; no instrumented timings count.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parents[2] / 'experimental/smooth/tools'))
from prove_fragments import isolated_project
from build import FLAGS


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path, required=True)
    parser.add_argument('--release', action='store_true')
    parser.add_argument('--boundary', choices=('force', 'step'), default='force')
    args = parser.parse_args()
    metadata = json.loads((args.build / 'build.json').read_text())
    origin = args.build / 'current/source'
    for name, expected in metadata['builds']['current']['sources'].items():
        assert digest(origin / name) == expected, name
    args.out.mkdir(parents=True, exist_ok=False)
    source = args.out / 'source'
    shutil.copytree(origin, source)
    package = args.boundary.title() + '_Boundary_Checks'
    for path in HERE.glob(f'mj-data-{args.boundary}_boundary_checks.ad?'):
        shutil.copy2(path, source / 'experimental/smooth/src' / path.name)
    probe = source / 'experimental/smooth/tests/smooth_probe.adb'
    text = f'with MJ.Data.{package};\n' + probe.read_text()
    needle = '         Set_State (D, Q, V, Input_Time, Result); Check;'
    assert text.count(needle) == 1
    enabled = 'False' if args.release else 'True'
    probe.write_text(text.replace(needle, needle +
        f'\n         if C = 1 then MJ.Data.{package}.Check'
        f' (D, {enabled}); end if;'))
    project = isolated_project(source, args.out, 'smooth_probe')
    text = project.read_text().replace('project Fragment is',
        'project Fragment is\n   for Main use ("smooth_probe.adb");\n'
        '   for Exec_Dir use "bin";')
    if args.release:
        start = text.index('        ("-gnat2022"')
        stop = text.index(';', start)
        text = text[:start] + '(' + ', '.join('"' + f + '"' for f in FLAGS) + ')' + text[stop:]
        text = text.replace('end Fragment;', '   package Linker is\n'
            '      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n'
            '   end Linker;\nend Fragment;')
    project.write_text(text)
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((args.toolchain_root / t).glob('*/bin')))
                           for t in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    command = ['gprbuild', '-P', str(project), '-j2']
    with (args.out / 'build.log').open('w') as log:
        subprocess.run(command, env=env, stdout=log, stderr=subprocess.STDOUT,
                       check=True, timeout=600)
    (args.out / 'manifest.json').write_text(json.dumps(dict(
        source_build=str(args.build.resolve()), release=args.release, boundary=args.boundary,
        command=command, project=project.read_text(),
        sources={str(p.relative_to(source)): digest(p) for p in source.rglob('*.ad?')},
        probe_sha256=digest(args.out / 'bin/smooth_probe')), indent=2) + '\n')


if __name__ == '__main__':
    main()
