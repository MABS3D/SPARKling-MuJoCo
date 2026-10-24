#!/usr/bin/env python3
"""Verify the public evidence subset, optionally restoring retained logical entries or candidate sources."""
from pathlib import Path, PurePosixPath
import argparse
import hashlib
import json
import zipfile

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def safe(root, name):
    path = PurePosixPath(name)
    if path.is_absolute() or not path.parts or '..' in path.parts:
        raise ValueError('unsafe archive path: ' + name)
    return root.joinpath(*path.parts)

parser = argparse.ArgumentParser(description=__doc__)
mode = parser.add_mutually_exclusive_group()
mode.add_argument('--extract', metavar='NEW_DIRECTORY')
mode.add_argument('--restore-sources', nargs=2, metavar=('RUN_NAME', 'NEW_DIRECTORY'))
args = parser.parse_args()
root = Path(__file__).resolve().parent
receipt = json.loads((root / 'manifest.json').read_text())
archive = root / receipt['archive']
if sha(archive.read_bytes()) != receipt['sha256']:
    raise ValueError('public ZIP SHA256 mismatch')
with zipfile.ZipFile(archive) as z:
    index = json.loads(z.read('entry-map.json'))
    verified = set()
    for name, metadata in index['included'].items():
        digest = metadata['sha256']
        raw = z.read('objects/' + digest)
        if sha(raw) != digest or len(raw) != metadata['bytes']:
            raise ValueError('invalid payload: ' + name)
        verified.add(digest)
    if len(verified) != index['unique_objects']:
        raise ValueError('unique object count mismatch')
    sources = 0
    missing = 0
    for name, metadata in index['included'].items():
        if not (name.startswith('runs/') and name.endswith('/manifest.json')):
            continue
        manifest = json.loads(z.read('objects/' + metadata['sha256']))
        for relative, digest in manifest.get('candidate_sources', {}).items():
            key = 'source-objects/' + digest
            if key in index['included']:
                if index['included'][key]['sha256'] != digest:
                    raise ValueError('source hash mismatch: ' + relative)
                sources += 1
            elif key in index['omitted'] and relative.endswith('.mjb'):
                missing += 1
            else:
                raise ValueError('unexplained missing source: ' + relative)
    if args.extract:
        target = Path(args.extract)
        target.mkdir(parents=True, exist_ok=False)
        for name, metadata in index['included'].items():
            output = safe(target, name)
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(z.read('objects/' + metadata['sha256']))
        (target / 'PUBLIC-SUBSET-OMISSIONS.json').write_text(json.dumps(index['omitted'], indent=2) + '\n')
    if args.restore_sources:
        run, directory = args.restore_sources
        key = 'runs/' + run + '/manifest.json'
        metadata = index['included'][key]
        manifest = json.loads(z.read('objects/' + metadata['sha256']))
        target = Path(directory)
        target.mkdir(parents=True, exist_ok=False)
        skipped = {}
        for relative, digest in manifest['candidate_sources'].items():
            key = 'source-objects/' + digest
            if key in index['omitted']:
                skipped[relative] = index['omitted'][key]
                continue
            output = safe(target, relative)
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(z.read('objects/' + digest))
        (target / 'PUBLIC-SUBSET-OMISSIONS.json').write_text(json.dumps(skipped, indent=2) + '\n')
print(json.dumps({'passed': True, 'logical_entries': len(index['included']), 'unique_objects': len(verified), 'source_paths_reconstructable': sources, 'source_mjb_paths_explicitly_omitted': missing, 'omitted_entries': len(index['omitted'])}, indent=2))
