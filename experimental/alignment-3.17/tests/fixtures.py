"""Real MuJoCo 3.17 MJB fixtures distinguishing the coordinated ABI changes.

The official compiler is an oracle only. Every named case must compile and
expose the property it was selected for; there are no skips or relabelled images.
"""
from pathlib import Path
import argparse
import hashlib
import json
import struct

import mujoco
import numpy as np

REFERENCE = "3.17.0"
COMMIT = "800a109a4bdd02cb60404d565db4ae16fb04a53b"
BASE_BODY = '<body name="b" pos="0 0 1"><joint name="j"/><geom type="sphere" size=".1" mass="1"/></body>'
CASES = {
    "ordinary": '<mujoco><worldbody>' + BASE_BODY + '</worldbody></mujoco>',
    "adhesion": '<mujoco><worldbody>' + BASE_BODY.replace('mass="1"', 'mass="1" adhesion=".25"') + '</worldbody></mujoco>',
    "weld_automatic": '<mujoco><worldbody>' + BASE_BODY + '<body name="c" pos="1 0 1"><freejoint/><geom type="sphere" size=".12" mass="2"/></body></worldbody><equality><weld body1="b" body2="c"/></equality></mujoco>',
    "weld_explicit": '<mujoco><worldbody>' + BASE_BODY + '<body name="c" pos="1 0 1"><freejoint/><geom type="sphere" size=".12" mass="2"/></body></worldbody><equality><weld body1="b" body2="c" relpose="1 0 0 1 0 0 0"/></equality></mujoco>',
    "flex_metric": '<mujoco><option integrator="discrete" solver="Newton"/><worldbody><flexcomp name="f" type="grid" count="3 1 1" spacing=".1 .1 .1" dim="1" radius=".01" mass="1" pos="0 0 1"><elasticity young="1000" poisson=".3"/></flexcomp></worldbody></mujoco>',
    "texture_embedded": '<mujoco><asset><texture name="t" type="2d" builtin="checker" width="2" height="2" rgb1=".1 .2 .3" rgb2=".4 .5 .6"/><material name="m" texture="t"/></asset><worldbody><geom type="sphere" size=".1" material="m"/></worldbody></mujoco>',
    "texture_external": '<mujoco><asset><texture name="t" type="2d" file="intentionally_absent.png" content_type="image/png" embed="false"/><material name="m" texture="t"/></asset><worldbody><geom type="sphere" size=".1" material="m"/></worldbody></mujoco>',
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def integer_values(values):
    return [int(value) for value in np.asarray(values).reshape(-1)]


def real_bits(values):
    return np.asarray(values, dtype="<f8").reshape(-1).view("<u8").tolist()


def expected(m):
    return {
        "FLAGS": [int(m.flg_gravcomp), int(m.flg_surfacevel), int(m.flg_adhesion)],
        "SIZES": [int(m.nefmCvert), int(m.neq), int(m.ntex)],
        "EFMC_PERM": integer_values(m.efmC_perm),
        "EQ_DATA_BITS": real_bits(m.eq_data),
        "BODY_PARENT": integer_values(m.body_parentid),
        "BODY_MASS_BITS": real_bits(m.body_mass),
        "TEX_ADR": integer_values(m.tex_adr),
        "TEX_WIDTH": integer_values(m.tex_width),
        "TEX_HEIGHT": integer_values(m.tex_height),
        "TEX_PATHADR": integer_values(m.tex_pathadr),
        "TEX_CONTENTTYPEADR": integer_values(m.tex_contenttypeadr),
    }


def compile_fixtures(out):
    assert mujoco.__version__ == REFERENCE and mujoco.mj_version() == 3_017_000
    out.mkdir(parents=True, exist_ok=False)
    receipt = {"reference": REFERENCE, "commit": COMMIT, "runner_sha256": digest(Path(__file__)),
               "cases": [], "complete": False, "scope": "Real C-compiled ABI fixtures; Ada decoding is checked separately."}
    for name, xml in CASES.items():
        record = {"name": name, "expected_status": "OK", "expected_roundtrip": True,
                  "expected_validation": "UNSUPPORTED_FLEX" if name == "flex_metric" else "OK"}
        receipt["cases"].append(record)
        try:
            path = out / (name + ".xml")
            path.write_text(xml + "\n")
            m = mujoco.MjModel.from_xml_path(str(path))
            image = out / (name + ".mjb")
            mujoco.mj_saveModel(m, str(image), None)
            header = struct.unpack_from("<5i", image.read_bytes())
            assert header == (54321, 8, 98, 3_017_000, 485), (name, header)
            data = expected(m)
            if name == "adhesion":
                assert data["FLAGS"][2] == 1, data
            if name.startswith("weld_"):
                assert np.asarray(m.eq_data).shape == (1, 12)
                assert bool(m.eq_data[0, 11]) == (name == "weld_automatic")
            if name == "flex_metric":
                assert m.nefmCvert > 0 and data["EFMC_PERM"], data
            if name == "texture_external":
                assert data["TEX_ADR"] == [-1] and data["TEX_WIDTH"] == [0] and data["TEX_HEIGHT"] == [0]
                assert data["TEX_PATHADR"][0] >= 0 and data["TEX_CONTENTTYPEADR"][0] >= 0
                assert int(m.ntexdata) == 0
            if name == "texture_embedded":
                assert data["TEX_ADR"][0] >= 0 and int(m.ntexdata) > 0
            record.update(image=image.name, image_sha256=digest(image), xml_sha256=digest(path),
                          header=list(header), expected=data, compiled=True)
        except Exception as error:
            record.update(compiled=False, error=repr(error))
            (out / "fixtures.json").write_text(json.dumps(receipt, indent=2) + "\n")
            raise
    original = (out / "ordinary.mjb").read_bytes()
    for label, version, sizes, pointers in (("legacy_314_header", 3_014_000, 98, 487),
                                             ("legacy_315_header", 3_015_000, 97, 483)):
        # Deliberately forged old labels on a NEW image must not be admitted as
        # old-ABI compatibility. Genuine old ABI regressions are separate runs.
        image = out / (label + ".mjb")
        image.write_bytes(struct.pack("<5i", 54321, 8, sizes, version, pointers) + original[20:])
        receipt["cases"].append(dict(name=label, image=image.name, image_sha256=digest(image),
            expected_status="BAD_VERSION" if sizes == 98 else "BAD_SIZE_COUNT", forged_header=True))
    original_cases = {case["name"]: case for case in receipt["cases"]}
    for name, base, mutation, key, value, status in (
        ("invalid_perm_low", "ordinary", "perm_low", "EFMC_PERM", -2, "INVALID_REFERENCE"),
        ("invalid_perm_high", "ordinary", "perm_high", "EFMC_PERM", 1, "INVALID_REFERENCE"),
        ("invalid_external_path", "texture_external", "texture_path", "TEX_PATHADR", -1, "INVALID_PARAMETER")):
        parent = original_cases[base]
        data = {key: list(values) for key, values in parent["expected"].items()}
        data[key] = [value]
        if mutation.startswith("perm_"):
            data["SIZES"][0] = 1
        receipt["cases"].append(dict(name=name, image=parent["image"],
            image_sha256=parent["image_sha256"], expected_status="OK", expected=data,
            mutation=mutation, expected_roundtrip=False, expected_validation=status,
            scope="Owned-model corruption after raw decoding; tests real validation rejection while retaining the full caller domain"))
    receipt["complete"] = True
    (out / "fixtures.json").write_text(json.dumps(receipt, indent=2) + "\n")
    return receipt


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, required=True)
    args = parser.parse_args()
    result = compile_fixtures(args.out)
    print(json.dumps({"complete": result["complete"], "cases": len(result["cases"])}))


if __name__ == "__main__":
    main()
