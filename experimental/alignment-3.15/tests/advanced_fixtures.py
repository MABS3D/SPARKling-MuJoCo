"""3.15 site/refsite cases with noncommuting rotations at the initial state."""
import json
from pathlib import Path

import mujoco
import numpy as np


def additional_fixtures(model):
    # Both local site rotations fail to commute with their world body frames.
    # Shared ancestors additionally exercise removal of their Jacobian columns.
    shared = '''<body quat=".9238795325 0 0 .3826834324">
      <joint name="root" type="ball"/><geom size=".1"/>
      <site name="ref" quat=".9659258263 .2588190451 0 0"/>
      <body pos=".2 .1 0" quat=".9238795325 .3826834324 0 0">
        <joint name="j" type="ball"/><geom size=".1"/>
        <site name="s" quat=".8660254038 0 .5 0"/>
      </body></body>'''
    separate = '''<body pos="-.3 0 0" quat=".9238795325 0 .3826834324 0">
      <joint name="root" type="ball"/><geom size=".1"/>
      <site name="ref" quat=".9659258263 0 0 .2588190451"/>
      </body><body pos=".3 0 0" quat=".9238795325 0 0 .3826834324">
      <joint name="j" type="ball"/><geom size=".1"/>
      <site name="s" quat=".8660254038 .5 0 0"/>
      </body>'''
    for topology, body in (("shared", shared), ("separate", separate)):
        for chart in ("quat", "expmap", "vel"):
            actuator = (f'<orientation site="s" refsite="ref" kp="4" kv=".3" '
                        f'input="{chart}" forcelimited="true" forcerange="0 .08"/>')
            yield f"so3_noncommuting_{topology}_{chart}", model(actuator, body)


def verify_distinguishing_cases(model, out):
    """Require actual C lengths to reject either independently reversed order."""
    assert mujoco.__version__ == "3.15.0"

    def multiply(a, b):
        result = np.empty(4)
        mujoco.mju_mulQuat(result, a, b)
        return result

    def difference(a, b):
        result = np.empty(3)
        mujoco.mju_subQuat(result, a, b)
        return result

    records = []
    for name, xml in additional_fixtures(model):
        m = mujoco.MjModel.from_xml_string(xml)
        d = mujoco.MjData(m)
        mujoco.mj_forward(m, d)
        site, ref = m.actuator_trnid[0]
        local = m.site_quat[site]
        local_ref = m.site_quat[ref]
        body = d.xquat[m.site_bodyid[site]]
        body_ref = d.xquat[m.site_bodyid[ref]]
        world = multiply(body, local)
        world_ref = multiply(body_ref, local_ref)
        reversed_site = multiply(local, body)
        reversed_ref = multiply(local_ref, body_ref)
        expected = difference(world, world_ref)
        actual = d.actuator_length.copy()
        assert np.allclose(actual, expected, atol=2e-12, rtol=2e-12), name
        mutations = {
            "site_reversed": difference(reversed_site, world_ref),
            "refsite_reversed": difference(world, reversed_ref),
            "both_reversed": difference(reversed_site, reversed_ref),
        }
        errors = {key: float(np.max(np.abs(value - actual)))
                  for key, value in mutations.items()}
        assert min(errors.values()) > 0.01, (name, errors)
        records.append(dict(model=name, reference_length=actual.tolist(),
                            reversed_order_max_abs_error=errors))
    Path(out).write_text(json.dumps(dict(reference=mujoco.__version__,
        cases=records, complete=True), indent=2) + "\n")
