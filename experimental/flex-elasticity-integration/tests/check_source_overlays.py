"""Check that integration cannot silently use an unverified live dependency."""
import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from build_constrained import overlay_sources


class OverlayChecks(unittest.TestCase):
    def test_add_replace_remove_and_reject_tampering(self):
        with tempfile.TemporaryDirectory() as directory:
            root=Path(directory);snap=root/'integrated';build=root/'dependency'
            folder='src';target=snap/folder;source=build/'source'/folder
            target.mkdir(parents=True);source.mkdir(parents=True)
            (target/'old.ads').write_text('old')
            (target/'same.ads').write_text('before')
            (source/'same.ads').write_text('after')
            (source/'new.adb').write_text('new')
            # An unmanifested file in a frozen folder must never enter runtime.
            (source/'unverified.adb').write_text('unverified')
            hashes={str(p.relative_to(snap)):hashlib.sha256(p.read_bytes()).hexdigest()
                    for p in target.iterdir()}
            dependency={str(p.relative_to(build/'source')):hashlib.sha256(p.read_bytes()).hexdigest()
                        for p in source.iterdir() if p.name!='unverified.adb'}
            (build/'manifest.json').write_text(json.dumps({'sources':dependency}))
            receipt=overlay_sources(snap,hashes,folder,build)
            self.assertEqual(hashes,dependency)
            self.assertEqual((target/'same.ads').read_text(),'after')
            self.assertEqual((target/'new.adb').read_text(),'new')
            self.assertFalse((target/'old.ads').exists())
            self.assertFalse((target/'unverified.adb').exists())
            self.assertEqual(receipt['removed_sources'],['src/old.ads'])
            (source/'same.ads').write_text('tampered')
            with self.assertRaisesRegex(RuntimeError,'snapshot mismatch'):
                overlay_sources(snap,hashes,folder,build)
            self.assertEqual((target/'same.ads').read_text(),'after')

    def test_empty_folder_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            build=Path(directory)/'dependency';build.mkdir()
            (build/'manifest.json').write_text('{"sources":{}}')
            with self.assertRaisesRegex(RuntimeError,'no manifested sources'):
                overlay_sources(Path(directory)/'integrated',{},'src',build)


if __name__=='__main__':unittest.main()
