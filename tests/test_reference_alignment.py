"""Reject stale corpus images and disagreement between the pinned ABI inputs."""
import hashlib
import json
from pathlib import Path
import re
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]


class ReferenceAlignmentTests(unittest.TestCase):
    def test_header_tables_and_reference_agree(self):
        reference = json.loads((ROOT / "tools/blas-reference.json").read_text())
        major, minor, patch = map(int, reference["version"].split("."))
        version = major * 1_000_000 + minor * 1_000 + patch
        header = (ROOT / "mujoco/include/mujoco/mujoco.h").read_text()
        self.assertEqual(int(re.search(r"#define mjVERSION_HEADER (\d+)", header)[1]), version)
        self.assertIn(f"META version {version}\n", (ROOT / "tools/fields.txt").read_text())
        corpus = json.loads((ROOT / "tests/corpus-reference.json").read_text())
        self.assertEqual(corpus["version"], reference["version"])
        self.assertEqual(corpus["version_header"], version)

    def test_corpus_images_and_headers_match_receipt(self):
        receipt = json.loads((ROOT / "tests/corpus-reference.json").read_text())
        listing = (ROOT / "tests/corpus_expected.txt").read_bytes().replace(b"\r\n", b"\n")
        self.assertEqual(hashlib.sha256(listing).hexdigest(), receipt["listing_sha256"])
        names = {line.split()[1] for line in listing.decode().splitlines() if not line.startswith("SKIP ")}
        self.assertEqual(names, set(receipt["images_sha256"]))
        meta = dict((p[1], int(p[2])) for line in (ROOT / "tools/fields.txt").read_text().splitlines()
                    if (p := line.split()) and p[0] == "META")
        for name, digest in receipt["images_sha256"].items():
            with self.subTest(model=name):
                data = (ROOT / "tests/out/corpus" / name).read_bytes()
                self.assertEqual(hashlib.sha256(data).hexdigest(), digest)
                self.assertEqual(struct.unpack_from("<5i", data),
                                 (54321, 8, meta["nsize"], receipt["version_header"], meta["nptr"]))


if __name__ == "__main__":
    unittest.main()
