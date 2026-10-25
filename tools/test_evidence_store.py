"""Exercise exact ZIP restoration, streaming descriptors and existing-file safety."""
import io
import json
from pathlib import Path
import tempfile
import unittest
import zipfile
import evidence_store as store


class NonSeeking(io.BytesIO):
    def seek(self, *args):
        raise io.UnsupportedOperation

    def seekable(self):
        return False


class EvidenceStoreTests(unittest.TestCase):
    def test_exact_streaming_and_chunked_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / 'root'
            root.mkdir()
            stream = NonSeeking()
            with zipfile.ZipFile(stream, 'w', zipfile.ZIP_DEFLATED) as archive:
                archive.writestr('empty', b'')
                archive.writestr('directory/value.txt', b'duplicate payload' * 100)
                archive.writestr('second.txt', b'duplicate payload' * 100)
            originals = {'stream.zip': stream.getvalue()}
            (root / 'stream.zip').write_bytes(originals['stream.zip'])
            with zipfile.ZipFile(root / 'chunked.zip', 'w', zipfile.ZIP_STORED) as archive:
                archive.writestr('wide.bin', bytes(range(256)) * (store.CHUNK // 256 + 1))
            originals['chunked.zip'] = (root / 'chunked.zip').read_bytes()
            location = Path(tmp) / 'storage'
            manifest = store.pack(root, location, list(originals))
            store.verify(root, location)
            restored = Path(tmp) / 'restored'
            restored.mkdir()
            store.restore(restored, location, list(originals))
            for name, data in originals.items():
                self.assertEqual((restored / name).read_bytes(), data)
            self.assertLessEqual(max(p['bytes'] for p in manifest['packs'].values()), store.PACK)
            store.pack(root, location, list(originals))  # Re-ingestion is harmless.
            store.verify(root, location)

    def test_rejects_an_unstored_inventory_zip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            inventory = root / store.INVENTORY
            inventory.parent.mkdir(parents=True)
            bundle = inventory.parent / 'not-packed.zip'
            with zipfile.ZipFile(bundle, 'w') as archive:
                archive.writestr('value', b'unstored proof')
            inventory.write_text(json.dumps({'files': {'not-packed.zip': store.digest(bundle)}}))
            with zipfile.ZipFile(root / 'other.zip', 'w') as archive:
                archive.writestr('value', b'other')
            with self.assertRaisesRegex(ValueError, 'Unstored proof archive'):
                store.pack(root, root / 'storage', ['other.zip'])
            self.assertTrue(bundle.is_file())

    def test_refuses_overwrites_and_preserves_existing_partial(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            with zipfile.ZipFile(root / 'input.zip', 'w') as archive:
                archive.writestr('value', b'original')
            location = root / 'storage'
            store.pack(root, location, ['input.zip'])
            restored = root / 'restored'
            restored.mkdir()
            partial = restored / 'input.zip.partial'
            partial.write_bytes(b'existing partial')
            with self.assertRaises(FileExistsError):
                store.restore(restored, location, ['input.zip'])
            self.assertEqual(partial.read_bytes(), b'existing partial')
            (restored / 'input.zip').write_bytes(b'different existing file')
            with self.assertRaises(ValueError):
                store.restore(restored, location, ['input.zip'])
            self.assertEqual((restored / 'input.zip').read_bytes(), b'different existing file')
            manifest, _ = store.load(location)
            pack = location / next(iter(manifest['packs']))
            pack.write_bytes(b'corrupt')
            with self.assertRaises(ValueError):
                store.verify(root, location)


if __name__ == '__main__':
    unittest.main()
