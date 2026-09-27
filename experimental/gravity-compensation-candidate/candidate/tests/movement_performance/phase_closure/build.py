#!/usr/bin/env python3
"""Build frozen pre-optimization Ada, active Ada, checked Ada and reference C."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
sys.path.insert(0, str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project

FLAGS = ['-gnat2022', '-gnatn', '-gnatp', '-O3', '-march=native', '-flto',
         '-ffat-lto-objects', '-ffp-contract=off', '-ffinite-math-only',
         '-fno-trapping-math', '-fno-math-errno', '-ffunction-sections', '-fdata-sections']


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--toolchain-root', type=Path, required=True)
    p.add_argument('--reference-build', type=Path, required=True)
    a = p.parse_args(); out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    reference = a.reference_build.resolve()
    metadata = json.loads((reference/'build.json').read_text())
    assert digest(reference/'movement_c') == metadata['builds']['c']['binary_sha256']
    assert digest(Path(metadata['builds']['c']['library'])) == metadata['builds']['c']['library_sha256']
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((a.toolchain_root/t).glob('*/bin')))
                           for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
    frozen = json.loads((HERE/'baseline.json').read_text())
    for name, expected in frozen.items(): assert digest(HERE/'baseline'/name) == expected
    snapshot = out/'source'; snapshot.mkdir()
    paths = [p for d in ['src', 'experimental/smooth/src'] for p in (REPO/d).rglob('*.ad?')]
    paths += [HERE.parent/'movement_bench.adb', REPO/'experimental/smooth/tests/smooth_probe.adb']
    for path in paths:
        target = snapshot/path.relative_to(REPO); target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    builds = {'c': metadata['builds']['c']}
    for variant in ['baseline', 'current', 'checked']:
        work = out/variant; work.mkdir(); src = work/'source'; shutil.copytree(snapshot, src)
        if variant == 'baseline':
            for path in (src/'experimental/smooth/src').glob('*.ad?'): path.unlink()
            for path in (HERE/'baseline').glob('*.ad?'): shutil.copy2(path, src/'experimental/smooth/src'/path.name)
        main = 'smooth_probe' if variant == 'checked' else 'movement_bench'
        project = isolated_project(src, work, main)
        text = project.read_text().replace('project Fragment is',
            f'project Fragment is\n   for Main use ("{main}.adb");\n   for Exec_Dir use "bin";')
        if variant != 'checked':
            start = text.index('        ("-gnat2022"'); stop = text.index(';', start)
            text = text[:start]+'('+', '.join('"'+f+'"' for f in FLAGS)+')'+text[stop:]
            text = text.replace('end Fragment;', '   package Linker is\n'
                '      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n'
                '   end Linker;\nend Fragment;')
        project.write_text(text)
        cmd = ['gprbuild', '-P', str(project), '-j2']
        with (work/'build.log').open('w') as log:
            subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=600)
        binary = work/'bin'/main
        builds[variant] = dict(command=cmd, binary=str(binary), binary_sha256=digest(binary),
            sources={str(p.relative_to(src)): digest(p) for p in src.rglob('*.ad?')})
        print(variant, 'built', flush=True)
    (out/'movement_c').symlink_to(reference/'movement_c')
    metadata.update(builds=builds, experiment='active dynamics optimization versus frozen prior implementation')
    metadata['sources'] = {str(p.relative_to(snapshot)): digest(p) for p in snapshot.rglob('*.ad?')}
    metadata['harness'] = {str(p.relative_to(REPO)): digest(p) for p in
        [Path(__file__), HERE/'baseline.json', HERE.parent/'run.py',
         REPO/'experimental/smooth/tools/compare_numerics.py',
         REPO/'experimental/smooth/tools/prove_fragments.py']}
    (out/'build.json').write_text(json.dumps(metadata, indent=2)+'\n')


if __name__ == '__main__':
    main()
