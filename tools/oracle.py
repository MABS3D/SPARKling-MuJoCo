#!/usr/bin/env python3
"""Trusted producer for the tests: compiles MJCF/URDF with the official MuJoCo
3.12.0 wheel and saves .mjb images.

  python tools/oracle.py compile <model.xml> <model.mjb>
  python tools/oracle.py corpus     -> tests/out/corpus/*.mjb and tests/corpus_expected.txt
"""
from __future__ import annotations

import pathlib
import sys

import mujoco

ROOT = pathlib.Path(__file__).resolve().parent.parent
MJ = ROOT / "mujoco"
OUT = ROOT / "tests" / "out" / "corpus"
LISTING = ROOT / "tests" / "corpus_expected.txt"

assert mujoco.__version__ == "3.12.0", f"need mujoco 3.12.0, found {mujoco.__version__}"


def compile_one(xml: pathlib.Path, mjb: pathlib.Path) -> mujoco.MjModel:
    m = mujoco.MjModel.from_xml_path(str(xml))
    mjb.parent.mkdir(parents=True, exist_ok=True)
    mujoco.mj_saveModel(m, str(mjb), None)
    return m


def expected_status(m: mujoco.MjModel) -> str:
    """The Load_Status the SPARK validator must report for this model (spec 5.1, 5.6)."""
    if m.nplugin > 0:
        return "Unsupported_Plugins"
    if any(int(m.geom_type[g]) == int(mujoco.mjtGeom.mjGEOM_SDF) for g in range(m.ngeom)):
        return "Unsupported_Plugins"
    if m.nflex > 0:
        return "Unsupported_Flex"
    return "OK"


def corpus() -> None:
    sources = sorted((MJ / "model").rglob("*.xml")) + sorted((MJ / "test" / "testdata").glob("*.xml"))
    rows, compiled, skipped = [], 0, 0
    for xml in sources:
        rel = xml.relative_to(MJ).as_posix()
        mjb = OUT / (rel.replace("/", "__")[:-4] + ".mjb")
        try:
            m = compile_one(xml, mjb)
        except Exception as e:  # include fragments, missing assets, unsupported features
            rows.append(f"SKIP {rel} {type(e).__name__}")
            skipped += 1
            continue
        rows.append(f"{expected_status(m)} {mjb.name} {rel}")
        compiled += 1
    LISTING.write_text("\n".join(rows) + "\n", newline="\n")
    print(f"{compiled} compiled, {skipped} skipped -> {OUT} and {LISTING}")


def main(argv: list[str]) -> None:
    if len(argv) == 4 and argv[1] == "compile":
        compile_one(pathlib.Path(argv[2]), pathlib.Path(argv[3]))
    elif len(argv) == 2 and argv[1] == "corpus":
        corpus()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main(sys.argv)
