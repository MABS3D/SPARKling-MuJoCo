"""Verify the retired internal XML option and positive modern FLEX models."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import xml.etree.ElementTree as ET
import mujoco

ROOT = Path(__file__).resolve().parents[3]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == "3.15.0"
    spec = importlib.util.spec_from_file_location(
        "legacy_fixture", ROOT / "experimental/flex-state-integration/tests/compare.py")
    fixtures = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(fixtures)
    records = []
    for enabled in (False, True):
        xml = fixtures.fixture(dim=3, internal=enabled)
        rejected = False
        try:
            mujoco.MjModel.from_xml_string(xml)
        except ValueError as error:
            diagnostic = str(error)
            rejected = "unrecognized attribute: 'internal'" in diagnostic
        else:
            diagnostic = "Unexpected acceptance"
        tree = ET.fromstring(xml)
        for contact in tree.findall(".//flex/contact"):
            del contact.attrib["internal"]
        modern = ET.tostring(tree, encoding="unicode")
        model = mujoco.MjModel.from_xml_string(modern)
        mujoco.mj_saveModel(model, str(args.out / (str(enabled) + ".mjb")))
        records.append(dict(legacy_enabled=enabled, obsolete_xml_rejected=rejected,
                            diagnostic=diagnostic, modern_model_compiled=model.nflex == 1,
                            retired_model_fields_absent=all(not hasattr(model, name) for name in
                                ("nflexevpair", "flex_internal", "flex_evpairadr", "flex_evpairnum", "flex_evpair")),
                            xml_sha256=hashlib.sha256(modern.encode()).hexdigest()))
    complete = all(row["obsolete_xml_rejected"] and row["modern_model_compiled"]
                   and row["retired_model_fields_absent"] for row in records)
    receipt = dict(reference=mujoco.__version__, records=records, complete=complete,
                   scope="Reference ABI/XML migration only; no Ada collision or dynamics claim.")
    (args.out / "results.json").write_text(json.dumps(receipt, indent=2) + "\n")
    print(json.dumps(receipt))
    raise SystemExit(not complete)


if __name__ == "__main__":
    main()
