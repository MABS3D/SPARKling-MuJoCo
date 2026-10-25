#!/usr/bin/env python3
"""Store exact ZIP bytes as deduplicated payloads; verify or restore offline."""
import argparse
import base64
import gzip
import hashlib
import json
import os
from pathlib import Path
import struct
import subprocess
import zipfile

DEFAULT = 'experimental/alignment-3.17/evidence/storage'
INVENTORY = 'experimental/alignment-3.17/evidence/inventory.json'
CHUNK = 16 * 1024 * 1024
PACK = 32 * 1024 * 1024


def digest(path):
    h = hashlib.sha256()
    with path.open('rb') as stream:
        for data in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(data)
    return h.hexdigest()


def safe_name(name):
    path = Path(name)
    if path.is_absolute() or '..' in path.parts:
        raise ValueError('Expected a repository-relative path: ' + name)
    return path


def json_gzip(path, value):
    data = gzip.compress(json.dumps(value, separators=(',', ':')).encode(), mtime=0)
    if path.exists():
        if path.read_bytes() != data:
            raise ValueError('Immutable storage member already differs: ' + str(path))
    else:
        path.write_bytes(data)
    return hashlib.sha256(data).hexdigest()


def load(store):
    manifest = json.loads((store / 'manifest.json').read_text())
    if manifest.get('format') != 1:
        raise ValueError('Unsupported storage format')
    index = store / safe_name(manifest['index']['file'])
    if digest(index) != manifest['index']['sha256']:
        raise ValueError('Object index digest differs')
    for name in manifest['packs']:
        safe_name(name)
    objects = json.loads(gzip.decompress(index.read_bytes()))
    for entry in objects.values():
        pack = manifest['packs'].get(entry['file'])
        if (pack is None or entry['offset'] < 0 or not 0 < entry['size'] <= CHUNK
                or entry['offset'] + entry['size'] > pack['bytes']):
            raise ValueError('Invalid payload extent')
    return manifest, objects


def archive_chunks(store, manifest, objects, name):
    item = manifest['archives'][name]
    recipe_path = store / safe_name(item['recipe'])
    if digest(recipe_path) != item['recipe_sha256']:
        raise ValueError('Archive recipe digest differs: ' + name)
    recipe = json.loads(gzip.decompress(recipe_path.read_bytes()))
    handles = {}
    try:
        for part in recipe:
            yield base64.b64decode(part['prefix'], validate=True)
            for key in part['chunks']:
                entry = objects[key]
                handle = handles.setdefault(entry['file'], None)
                if handle is None:
                    handle = (store / entry['file']).open('rb')
                    handles[entry['file']] = handle
                handle.seek(entry['offset'])
                data = handle.read(entry['size'])
                if len(data) != entry['size'] or hashlib.sha256(data).hexdigest() != key:
                    raise ValueError('Payload digest differs: ' + key)
                yield data
    finally:
        for handle in handles.values():
            if handle is not None:
                handle.close()


def pack(root, store, names):
    store.mkdir(parents=True, exist_ok=True)
    if (store / 'manifest.json').exists():
        manifest, objects = load(store)
    else:
        manifest, objects = {'format': 1, 'packs': {}, 'archives': {}}, {}
    count = len(manifest['packs'])
    handle = None
    current = None

    def close_pack():
        nonlocal handle
        if handle is not None:
            handle.close()
            p = store / current
            manifest['packs'][current] = {'bytes': p.stat().st_size, 'sha256': digest(p)}
            handle = None

    def put(data):
        nonlocal handle, current, count
        key = hashlib.sha256(data).hexdigest()
        if key not in objects:
            if handle is None or handle.tell() + len(data) > PACK:
                close_pack()
                current = f'payloads-{count:04d}.bin'
                count += 1
                handle = (store / current).open('xb')
            objects[key] = {'file': current, 'offset': handle.tell(), 'size': len(data)}
            handle.write(data)
        return key

    try:
        for name in names:
            relative = safe_name(name)
            name = relative.as_posix()
            path = root / relative
            if name in manifest['archives']:
                if path.is_file() and digest(path) != manifest['archives'][name]['sha256']:
                    raise ValueError('Previously stored archive differs: ' + name)
                continue
            original = digest(path)
            recipe = []
            cursor = 0
            with path.open('rb') as stream, zipfile.ZipFile(path) as archive:
                for member in sorted(archive.infolist(), key=lambda x: x.header_offset):
                    stream.seek(member.header_offset)
                    header = stream.read(30)
                    if header[:4] != b'PK\x03\x04':
                        raise ValueError('Invalid local ZIP header: ' + name)
                    filename, extra = struct.unpack_from('<HH', header, 26)
                    start = member.header_offset + 30 + filename + extra
                    stream.seek(cursor)
                    prefix = stream.read(start - cursor)
                    if len(prefix) != start - cursor:
                        raise ValueError('Truncated ZIP prefix: ' + name)
                    left = member.compress_size
                    keys = []
                    while left:
                        data = stream.read(min(left, CHUNK))
                        if not data:
                            raise ValueError('Truncated ZIP payload: ' + name)
                        keys.append(put(data))
                        left -= len(data)
                    cursor = start + member.compress_size
                    recipe.append({'prefix': base64.b64encode(prefix).decode(), 'chunks': keys})
                stream.seek(cursor)
                recipe.append({'prefix': base64.b64encode(stream.read()).decode(), 'chunks': []})
            filename = 'archive-' + original + '.json.gz'
            recipe_sha = json_gzip(store / filename, recipe)
            manifest['archives'][name] = {'sha256': original, 'bytes': path.stat().st_size,
                                         'recipe': filename, 'recipe_sha256': recipe_sha}
            print('stored', name, flush=True)
    finally:
        close_pack()
    index_bytes = gzip.compress(json.dumps(objects, separators=(',', ':')).encode(), mtime=0)
    index_sha = hashlib.sha256(index_bytes).hexdigest()
    filename = 'objects-' + index_sha + '.json.gz'
    (store / filename).write_bytes(index_bytes)
    manifest['index'] = {'file': filename, 'sha256': index_sha}
    legacy = manifest.setdefault('legacy_archives', {})
    inventory = root / INVENTORY
    if inventory.exists():
        for name, expected in json.loads(inventory.read_text())['files'].items():
            relative = (inventory.parent / safe_name(name)).relative_to(root).as_posix()
            if not relative.endswith('.zip') or relative in manifest['archives']:
                continue
            if relative not in legacy:
                tracked = subprocess.run(['git', 'ls-files', '--error-unmatch', '--', relative],
                                         cwd=root, stdout=subprocess.DEVNULL,
                                         stderr=subprocess.DEVNULL)
                if tracked.returncode != 0:
                    raise ValueError('Unstored proof archive; pack it before committing: ' + relative)
                legacy[relative] = expected
            if legacy[relative] != expected or digest(root / relative) != expected:
                raise ValueError('Historical archive digest differs: ' + relative)
    manifest['totals'] = {'original_archive_bytes': sum(x['bytes'] for x in manifest['archives'].values()),
                         'payload_bytes': sum(x['bytes'] for x in manifest['packs'].values()),
                         'objects': len(objects), 'archives': len(manifest['archives'])}
    temporary = store / 'manifest.json.tmp'
    temporary.write_text(json.dumps(manifest, indent=2) + '\n')
    os.replace(temporary, store / 'manifest.json')
    return manifest


def verify(root, store):
    manifest, objects = load(store)
    for name, record in manifest['packs'].items():
        path = store / safe_name(name)
        if path.stat().st_size != record['bytes'] or digest(path) != record['sha256']:
            raise ValueError('Payload pack differs: ' + name)
    for name, record in manifest['archives'].items():
        h = hashlib.sha256()
        size = 0
        for data in archive_chunks(store, manifest, objects, name):
            h.update(data)
            size += len(data)
        if size != record['bytes'] or h.hexdigest() != record['sha256']:
            raise ValueError('Reconstructed ZIP differs: ' + name)
    inventory = root / INVENTORY
    checked = 0
    if inventory.exists():
        for name, expected in json.loads(inventory.read_text())['files'].items():
            relative = (inventory.parent / safe_name(name)).relative_to(root).as_posix()
            if (relative.endswith('.zip') and relative not in manifest['archives']
                    and manifest.get('legacy_archives', {}).get(relative) != expected):
                raise ValueError('Unstored proof archive; pack it before committing: ' + relative)
            actual = (manifest['archives'][relative]['sha256'] if relative in manifest['archives']
                      else digest(root / relative))
            if actual != expected:
                raise ValueError('Evidence inventory differs: ' + relative)
            checked += 1
    print(json.dumps({'passed': True, 'archives': len(manifest['archives']),
                      'inventory_files': checked, **manifest['totals']}))


def restore(root, store, names):
    manifest, objects = load(store)
    for name in names or manifest['archives']:
        name = safe_name(name).as_posix()
        record = manifest['archives'][name]
        target = root / safe_name(name)
        if target.is_file() and digest(target) == record['sha256']:
            continue
        if target.exists() or target.is_symlink():
            raise ValueError('Refusing to replace a different existing file: ' + str(target))
        if not target.parent.resolve().is_relative_to(root):
            raise ValueError('Restore directory escapes the repository')
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary = target.with_name(target.name + '.partial')
        h = hashlib.sha256()
        created = False
        try:
            with temporary.open('xb') as stream:
                created = True
                for data in archive_chunks(store, manifest, objects, name):
                    stream.write(data)
                    h.update(data)
            if h.hexdigest() != record['sha256'] or temporary.stat().st_size != record['bytes']:
                raise ValueError('Restored ZIP differs: ' + name)
            os.replace(temporary, target)
        finally:
            if created and temporary.exists():
                temporary.unlink()
        print('restored', name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('command', choices=['pack', 'verify', 'restore'])
    parser.add_argument('archives', nargs='*', help='Repository-relative ZIP paths')
    parser.add_argument('--root', type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument('--store', type=Path)
    parser.add_argument('--archives-from', type=Path, help='JSON object with an archives list')
    args = parser.parse_args()
    root = args.root.resolve()
    store = args.store.resolve() if args.store else root / DEFAULT
    names = args.archives
    if args.archives_from:
        names += json.loads(args.archives_from.read_text())['archives']
    if args.command == 'pack':
        if not names:
            parser.error('pack requires archive paths')
        pack(root, store, names)
        verify(root, store)
    elif args.command == 'verify':
        verify(root, store)
    else:
        restore(root, store, names)


if __name__ == '__main__':
    main()
