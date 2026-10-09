"""Owned scalar-site transmission cases with native C poses and Jacobians."""
import json
from pathlib import Path

import mujoco
import numpy as np


def additional_scalar_fixtures(model):
    shared = '''<body name="base" pos="-.3 0 0" quat=".9238795325 0 0 .3826834324">
      <joint name="root" type="ball"/><geom pos=".05 -.02 0" size=".1" mass="1"/>
      <site name="ref" pos="-.04 .02 .03" quat=".9659258263 .2588190451 0 0"/>
      <body name="tip" pos=".24 .08 .01" quat=".9238795325 .3826834324 0 0">
        <joint name="j" type="ball"/><geom pos="-.02 .03 .04" size=".1" mass=".7"/>
        <site name="s" pos=".06 -.04 .07" quat=".8660254038 0 .5 0"/>
      </body></body>'''
    separate = '''<body name="base" pos="-.3 0 0" quat=".9238795325 0 .3826834324 0">
      <joint name="root" type="ball"/><geom pos=".05 -.02 0" size=".1" mass="1"/>
      <site name="ref" pos="-.04 .02 .03" quat=".9659258263 0 0 .2588190451"/>
      </body><body name="tip" pos=".3 0 0" quat=".9238795325 0 0 .3826834324">
      <joint name="j" type="ball"/><geom pos="-.02 .03 .04" size=".1" mass=".7"/>
      <site name="s" pos=".06 -.04 .07" quat=".8660254038 .5 0 0"/>
      </body>'''
    same = '''<body name="base" quat=".9238795325 0 0 .3826834324">
      <joint name="j" type="ball"/><geom pos=".05 -.02 0" size=".1" mass="1"/>
      <site name="ref" pos="-.04 .02 .03" quat=".9659258263 .2588190451 0 0"/>
      <site name="s" pos=".06 -.04 .07" quat=".8660254038 0 .5 0"/>
      </body>'''
    world = '''<site name="ref" pos="-.2 .1 .05" quat=".9659258263 .2588190451 0 0"/>
      <body name="tip" quat=".9238795325 0 0 .3826834324">
      <joint name="j" type="ball"/><geom pos=".05 -.02 0" size=".1" mass="1"/>
      <site name="s" pos=".06 -.04 .07" quat=".8660254038 0 .5 0"/>
      </body>'''
    gears = {
        "translation": ".7 -.4 .3 0 0 0",
        "rotation": "0 0 0 .4 -.3 .2",
        "mixed": ".7 -.4 .3 .4 -.3 .2",
        "zero": "0 0 0 0 0 0",
    }
    welded = shared.replace('<joint name="j" type="ball"/>', '')
    for topology, body in (("shared", shared), ("separate", separate),
                           ("same", same), ("world", world), ("welded", welded)):
        for kind, gear in gears.items():
            yield f"scalar_site_{topology}_{kind}", model(
                f'<motor site="s" refsite="ref" gear="{gear}"/>', body)
    for kind, gear in gears.items():
        yield f"scalar_site_no_reference_{kind}", model(f'<motor site="s" gear="{gear}"/>', shared)
    for name, actuator in (
        ("position", '<position site="s" refsite="ref" gear="0 0 0 .4 -.3 .2" kp=".3"/>'),
        ("integrator", '<intvelocity site="s" refsite="ref" gear="0 0 0 .4 -.3 .2" kp=".3" actrange="-20 20"/>'),
        ("mixed_position", '<position site="s" refsite="ref" gear=".7 -.4 .3 .4 -.3 .2" kp=".3"/>'),
        ("filter", '<general site="s" refsite="ref" gear=".7 -.4 .3 .4 -.3 .2" dyntype="filterexact" dynprm=".02" gainprm=".3"/>'),
        ("pid", '<pid site="s" refsite="ref" gear="0 0 0 .4 -.3 .2" kp=".3" kv=".04" ki=".1" input="pos vel ff"/>'),
        ("pid_slew", '<pid site="s" refsite="ref" gear="0 0 0 .4 -.3 .2" kp=".3" kv=".04" slewmax="2" input="pos vel ff"/>'),
        ("dc", '<dcmotor site="s" refsite="ref" gear=".7 -.4 .3 .4 -.3 .2" motorconst=".2" resistance="2" input="voltage" inductance="0 .02"/>'),
    ):
        yield "scalar_site_reanchor_" + name, model(actuator, shared)
    yield "scalar_site_mixed_controllers", model(
        '<motor site="s" gear=".1 -.2 .3 .2 .1 -.1"/>'
        '<motor site="s" refsite="ref" gear=".7 -.4 .3 .4 -.3 .2"/>'
        '<orientation site="s" refsite="ref" kp=".3" kv=".04" input="vel"/>'
        '<motor joint="j" gear=".2 .1 -.3"/>', shared)
    yield "scalar_site_static_world", model(
        '<motor site="s" refsite="ref" gear=".7 -.4 .3 .4 -.3 .2"/>',
        '<site name="s" pos=".06 -.04 .07" quat=".8660254038 0 .5 0"/>'
        '<site name="ref" pos="-.04 .02 .03" quat=".9659258263 .2588190451 0 0"/>')


def set_scalar_inputs(name, m, d):
    # Exercise wrapping at multiple full turns, including activation-based
    # servos. Mixed translational/rotational gear must not wrap the setpoint.
    if name.startswith("scalar_site_reanchor_"):
        if m.na:
            d.act[:] = 7.4
        if m.nu:
            d.ctrl[0] = 7.4


def audit_native_scalar_geometry(model, out):
    """Record distinguishing C geometry without substituting it for engine tests."""
    assert mujoco.__version__ == "3.15.0"
    records = []
    for name, xml in additional_scalar_fixtures(model):
        m = mujoco.MjModel.from_xml_string(xml)
        d = mujoco.MjData(m)
        mujoco.mj_forward(m, d)
        if name.endswith("_same_mixed"):
            assert np.all(d.actuator_moment == 0), name
        if "no_reference" in name:
            assert d.actuator_length[0] == 0, name
        sid = mujoco.mj_name2id(m, mujoco.mjtObj.mjOBJ_SITE, "s")
        body = m.site_bodyid[sid]
        jp, jr = np.empty((3, m.nv)), np.empty((3, m.nv))
        cp, cr = np.empty((3, m.nv)), np.empty((3, m.nv))
        mujoco.mj_jacSite(m, d, jp, jr, sid)
        mujoco.mj_jacBodyCom(m, d, cp, cr, body)
        offset_error = float(np.max(np.abs(jp-cp))) if m.nv else 0.0
        if m.nv:
            assert offset_error > 0.01, (name, offset_error)
        records.append(dict(model=name, nv=m.nv, actuator_length=d.actuator_length.tolist(),
                            site_com_jacobian_max_abs_difference=offset_error))
    Path(out).write_text(json.dumps(dict(reference=mujoco.__version__,
        records=records, complete=True, scope="Native fixture discrimination only; integrated Ada comparison recorded separately."), indent=2) + "\n")
