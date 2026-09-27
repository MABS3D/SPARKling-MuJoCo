#!/usr/bin/env python3
"""Archive frozen builds, differential tests, proof diagnostics and raw timings.

Sources used by proof invocations are stored by content hash, including earlier
snapshots. A successful local proof is never inferred from a zero-check run.
"""
import argparse
import hashlib
import json
from pathlib import Path
import zipfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pack(path, files):
    with zipfile.ZipFile(path, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as archive:
        for name, source in sorted(files.items()):
            archive.write(source, name)


def records(paths):
    for value in paths:
        label, directory = value.split('=', 1)
        yield label, Path(directory).resolve()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--performance', action='append', default=[])
    parser.add_argument('--test', action='append', default=[])
    parser.add_argument('--proof', action='append', default=[])
    parser.add_argument('--diagnostic', action='append', default=[])
    a = parser.parse_args()
    out = a.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    source_objects = {}
    proof_sources = {}
    inventory = dict(build=str(a.build), performance={}, tests={}, proofs={}, diagnostics={})
    (out/'build.json').write_bytes((a.build/'build.json').read_bytes())
    files = {str(p.relative_to(a.build)):p for p in (a.build/'source').rglob('*') if p.is_file()}
    for variant in ('baseline', 'current', 'checked'):
        directory = a.build/variant
        files.update({str(p.relative_to(a.build)):p for p in directory.rglob('*') if p.is_file()
                      and (p.suffix == '.gpr' or p.name == 'build.log' or any(x in p.relative_to(directory).parts for x in ('bin','source')))})
    pack(out/'build-inputs-and-binaries.zip', files)
    for kind, entries in [('performance',a.performance), ('tests',a.test), ('proofs',a.proof), ('diagnostics',a.diagnostic)]:
        for label, directory in records(entries):
            target = out/kind; target.mkdir(exist_ok=True)
            raw = {}
            for p in directory.rglob('*'):
                if not p.is_file(): continue
                rel = p.relative_to(directory)
                if any(part.endswith('-obj') or part in ('bin','obj','current','baseline')
                       or (part == 'source' and kind == 'proofs') for part in rel.parts):
                    continue
                if p.suffix in ('.o','.ali','.mmap','.db','.sqlite'): continue
                if p.name == 'movement_c': continue
                raw[str(rel)] = p
            pack(target/(label+'.zip'), raw)
            result = directory/('measurements.json' if kind == 'performance' else 'results.json')
            if result.exists():
                (target/(label+'.json')).write_bytes(result.read_bytes())
            inventory[kind][label] = dict(original_directory=str(directory), archive=str((target/(label+'.zip')).relative_to(out)))
            if kind == 'proofs' and result.exists():
                data = json.loads(result.read_text())
                metadata = json.loads((directory/'manifest.json').read_text()) if (directory/'manifest.json').exists() else {}
                snapshot = Path(data.get('snapshot', directory/'source'))
                hashes = data.get('source_sha256', metadata.get('source_sha256', {}))
                proof_sources[label] = hashes
                for name, expected in hashes.items():
                    path = snapshot/name
                    if not path.exists():
                        path = REPO/name
                    if not path.exists() or sha(path) != expected:
                        raise ValueError(f'missing exact proof source: {label}: {name}')
                    source_objects[expected] = path
                inventory[kind][label]['results'] = [dict(target=r['target']['name'], status=r['status'],
                    checks=r.get('proof_checks',0), unproved=r.get('unproved',0), errors=r.get('errors',0)) for r in data.get('results',[])]
                if 'proof_checks' in data:
                    inventory[kind][label]['selected_batch'] = {k:data[k] for k in ('exit_code','seconds','proof_checks','issues') if k in data}
    pack(out/'proof-source-objects.zip', {digest:path for digest,path in source_objects.items()})
    (out/'proof-sources.json').write_text(json.dumps(proof_sources, indent=2)+'\n')
    (out/'inventory.json').write_text(json.dumps(inventory, indent=2)+'\n')
    (out/'manifest.json').write_text(json.dumps({str(p.relative_to(out)):sha(p) for p in out.rglob('*') if p.is_file()},indent=2)+'\n')
    print('Archived evidence:',out)


if __name__ == '__main__':
    main()
