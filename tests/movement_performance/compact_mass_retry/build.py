#!/usr/bin/env python3
"""Reproduce isolated compact-mass candidates; never edit active simulator sources."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import zipfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
spec = importlib.util.spec_from_file_location('proof_tools', REPO/'experimental/smooth/tools/prove_fragments.py')
proof_tools = importlib.util.module_from_spec(spec)
spec.loader.exec_module(proof_tools)
FLAGS = ['-gnat2022', '-gnatn', '-gnatp', '-O3', '-march=native', '-flto',
         '-ffat-lto-objects', '-ffp-contract=off', '-ffinite-math-only',
         '-fno-trapping-math', '-fno-math-errno', '-ffunction-sections', '-fdata-sections']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lane', choices=['measured', 'verification'], default='measured')
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path, required=True)
    parser.add_argument('--reference-build', type=Path, required=True)
    args = parser.parse_args()
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    reference = args.reference_build.resolve()
    metadata = json.loads((reference/'build.json').read_text())
    assert digest(reference/'movement_c') == metadata['builds']['c']['binary_sha256']
    assert digest(Path(metadata['builds']['c']['library'])) == metadata['builds']['c']['library_sha256']
    frozen = HERE.parent/'bounds_validation/evidence'
    expected = json.loads((frozen/'build.json').read_text())['sources']
    baseline = out/'baseline-source'; baseline.mkdir()
    with zipfile.ZipFile(frozen/'build-and-source.zip') as archive:
        for entry in archive.infolist():
            if not entry.filename.startswith('source/') or entry.is_dir():
                continue
            relative = Path(entry.filename).relative_to('source')
            assert not relative.is_absolute() and '..' not in relative.parts
            target = baseline/relative; target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(entry))
    assert all(digest(baseline/name) == sha for name, sha in expected.items())
    current = out/'source'; shutil.copytree(baseline, current)
    manifest = json.loads((HERE/args.lane/'manifest.json').read_text())
    for name, sha in manifest.items():
        path = HERE/args.lane/name; assert digest(path) == sha
        shutil.copy2(path, current/name)
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((args.toolchain_root/t).glob('*/bin')))
                           for t in ['gnat', 'gprbuild', 'gnatprove'])+':'+env['PATH']
    builds = {'c': metadata['builds']['c']}
    for variant in ['baseline', 'current', 'checked', 'helper_test']:
        work = out/variant; work.mkdir()
        src = work/'source'; shutil.copytree(baseline if variant == 'baseline' else current, src)
        unit = {'checked': 'smooth_probe', 'helper_test': 'compact_inertia_test'}.get(variant, 'movement_bench')
        project = proof_tools.isolated_project(src, work, unit)
        text = project.read_text().replace('project Fragment is',
            f'project Fragment is\n   for Main use ("{unit}.adb");\n   for Exec_Dir use "bin";')
        if variant in ['baseline', 'current']:
            start = text.index('        ("-gnat2022"'); stop = text.index(';', start)
            text = text[:start]+'('+', '.join('"'+f+'"' for f in FLAGS)+')'+text[stop:]
            text = text.replace('end Fragment;', '   package Linker is\n'
                '      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n'
                '   end Linker;\nend Fragment;')
        project.write_text(text)
        with (work/'build.log').open('w') as log:
            subprocess.run(['gprbuild', '-P', str(project), '-j2'], env=env,
                           stdout=log, stderr=subprocess.STDOUT, check=True, timeout=600)
        binary = work/'bin'/unit
        builds[variant] = dict(binary=str(binary), binary_sha256=digest(binary),
            sources={str(p.relative_to(src)): digest(p) for p in src.rglob('*.ad?')})
        if variant == 'helper_test':
            result = subprocess.check_output([str(binary)], text=True)
            (work/'test.log').write_text(result)
        print(variant, 'built', flush=True)
    (out/'movement_c').symlink_to(reference/'movement_c')
    metadata.update(builds=builds, experiment='compact mass retry: '+args.lane,
                    baseline_note='Accepted scan-only source, after bf265c8f; frozen source hashes verified.')
    metadata['sources'] = {str(p.relative_to(current)): digest(p) for p in current.rglob('*.ad?')}
    (out/'build.json').write_text(json.dumps(metadata, indent=2)+'\n')


if __name__ == '__main__':
    main()
