"""Compiled mesh/heightfield assets through the complete constrained step.

Only MJB/state/loads enter Ada. The production probe frees its source model
before evaluation, so every case also checks asset lifetime ownership.
"""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import mujoco
import numpy as np

from compare import model_xml, oracle, parse


CUBE = " ".join(str(x) for v in [
    (-.1, -.1, -.1), (-.1, -.1, .1), (-.1, .1, -.1), (-.1, .1, .1),
    (.1, -.1, -.1), (.1, -.1, .1), (.1, .1, -.1), (.1, .1, .1),
] for x in v)


def fixtures():
    asset = f'<asset><mesh name="hull" vertex="{CUBE}"/></asset>'
    for solver in ["PGS", "CG", "Newton"]:
        for dim in [1, 3, 4, 6]:
            body = '<body pos=".03 -.02 .095"><freejoint/><geom type="mesh" mesh="hull" mass="1"/></body>'
            yield f"mesh_plane_{solver}_{dim}", model_xml(body, dim=dim, solver=solver).replace("<worldbody>", asset + "<worldbody>"), None
    for kind, size, z in [("sphere", ".08", ".175"), ("capsule", ".05 .08", ".225"),
                           ("ellipsoid", ".08 .07 .06", ".155"), ("cylinder", ".06 .07", ".165"),
                           ("box", ".07 .06 .05", ".145"), ("mesh", "", ".195")]:
        geom = 'mesh="hull"' if kind == "mesh" else f'size="{size}"'
        dynamic = f'<body pos=".025 -.013 {z}"><freejoint/><geom type="{kind}" {geom} mass="1"/></body>'
        static = '<body><geom type="mesh" mesh="hull"/></body>'
        for reverse in [False, True]:
            body = dynamic + static if reverse else static + dynamic
            yield f"mesh_{kind}_{reverse}", model_xml(body, plane=False).replace("<worldbody>", asset + "<worldbody>"), None
    for reverse in [False, True]:
        for grid, profile in [(3, "flat"), (5, "slope"), (9, "relief")]:
            hasset = f'<asset><hfield name="terrain" nrow="{grid}" ncol="{grid}" size="1.2 .9 .2 .1"/><mesh name="hull" vertex="{CUBE}"/></asset>'
            for kind, size, z in [("sphere", ".08", ".125"), ("capsule", ".05 .08", ".175"),
                                   ("ellipsoid", ".08 .07 .06", ".105"), ("cylinder", ".06 .07", ".115"),
                                   ("box", ".07 .06 .05", ".095"), ("mesh", "", ".145")]:
                geom = 'mesh="hull"' if kind == "mesh" else f'size="{size}"'
                dynamic = f'<body pos=".04 -.03 {z}"><freejoint/><geom type="{kind}" {geom} mass="1"/></body>'
                static = '<body><geom type="hfield" hfield="terrain"/></body>'
                xml = model_xml(dynamic + static if reverse else static + dynamic, plane=False)
                yield f"heightfield_{kind}_{grid}_{reverse}", xml.replace("<worldbody>", hasset + "<worldbody>"), profile
    ring = " ".join(format(x, ".17g") for z in [-.1, .1] for k in range(12)
                    for x in [.1 * np.cos(2 * np.pi * k / 12), .1 * np.sin(2 * np.pi * k / 12), z])
    rasset = f'<asset><mesh name="ring" vertex="{ring}"/></asset>'
    yield "mesh_hillclimb_plane", model_xml('<body pos=".01 .02 .095"><freejoint/><geom type="mesh" mesh="ring" mass="1"/></body>').replace("<worldbody>", rasset + "<worldbody>"), None
    assets = f'<asset><mesh name="cube" vertex="{CUBE}"/><mesh name="ring" vertex="{ring}"/></asset>'
    bodies = '<body pos="-.3 0 .095"><freejoint/><geom type="mesh" mesh="cube" mass="1"/></body><body pos=".3 0 .095"><freejoint/><geom type="mesh" mesh="ring" mass="1"/></body><body pos=".6 0 .095"><freejoint/><geom type="mesh" mesh="cube" mass="1"/></body>'
    yield "mesh_shared_and_multiple_assets", model_xml(bodies).replace("<worldbody>", assets + "<worldbody>"), None
    assets = '<asset><hfield name="a" nrow="3" ncol="3" size=".5 .5 .2 .1"/><hfield name="b" nrow="5" ncol="5" size=".5 .5 .2 .1"/></asset>'
    bodies = '<body pos="-1 0 0"><geom type="hfield" hfield="a"/></body><body pos="1 0 0"><geom type="hfield" hfield="b"/></body><body pos="-1 .03 .125"><freejoint/><geom type="sphere" size=".08" mass="1"/></body><body pos="1 -.03 .125"><freejoint/><geom type="sphere" size=".08" mass="1"/></body>'
    yield "heightfield_multiple_assets", model_xml(bodies, plane=False).replace("<worldbody>", assets + "<worldbody>"), "slope"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--binary", type=Path, required=True)
    p.add_argument("--out", type=Path, required=True)
    p.add_argument("--samples", type=int, default=4)
    p.add_argument("--steps", type=int, default=100)
    p.add_argument("--only")
    p.add_argument("--local-angle", type=float, default=0.,
                   help="Rotate moving geoms locally after compilation; preserves body inertia.")
    a = p.parse_args()
    assert mujoco.__version__ == "3.14.0"
    a.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(3141002)
    records, failures = [], []
    for name, xml, profile in fixtures():
        if a.only and a.only not in name:
            continue
        m = mujoco.MjModel.from_xml_string(xml)
        if a.local_angle:
            axis = np.array([.3, -.5, .8]); axis /= np.linalg.norm(axis)
            local = np.empty(4)
            mujoco.mju_axisAngle2Quat(local, axis, a.local_angle)
            for geom in range(m.ngeom):
                if m.geom_bodyid[geom] != 0:
                    original = m.geom_quat[geom].copy()
                    mujoco.mju_mulQuat(m.geom_quat[geom], original, local)
                    m.geom_sameframe[geom] = 0
        if profile:
            for terrain in range(m.nhfield):
                nr, nc = int(m.hfield_nrow[terrain]), int(m.hfield_ncol[terrain])
                first = int(m.hfield_adr[terrain])
                x, y = np.meshgrid(np.linspace(-1, 1, nc), np.linspace(-1, 1, nr))
                h = .25 + (0 if profile == "flat" else .03 * x + .02 * y)
                if profile == "relief":
                    h = h + .01 * x * y
                m.hfield_data[first:first + nr * nc] = np.broadcast_to(h, (nr, nc)).ravel()
        file = a.out / (name + ".mjb")
        mujoco.mj_saveModel(m, str(file))
        (a.out / (name + ".xml")).write_text(xml)
        inputs, references = [], []
        for sample in range(a.samples):
            q = m.qpos0.copy()
            if sample:
                mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .001)
            v = rng.uniform(-.025, .025, m.nv)
            force = rng.uniform(-.03, .03, m.nv)
            loads = rng.uniform(-.01, .01, (m.nbody, 6))
            references.append(oracle(m, q, v, force, a.steps, loads=loads))
            inputs.extend([0., *q, *v, *force, *loads.ravel()])
        data = f"{a.samples} {a.steps}\n" + " ".join(format(x, ".17g") for x in inputs) + "\n"
        run = subprocess.run([str(a.binary), str(file), "loads"], input=data, text=True,
                             capture_output=True, timeout=180)
        (a.out / (name + ".input")).write_text(data)
        (a.out / (name + ".output")).write_text(run.stdout + run.stderr)
        try:
            if run.returncode or run.stdout.startswith("create"):
                raise ValueError(run.stdout[-1200:] + run.stderr[-1200:])
            actual = parse(run.stdout, m.nv)
            assert len(actual) == len(references)
            for i, (x, y) in enumerate(zip(actual, references)):
                errors = {}
                # Row order/frame may differ when C swaps geom IDs by type.
                # Compare invariant physical outputs, not arbitrary pyramid
                # edge numbering. Counts and free dynamics remain separate.
                for key in ["counts", "free", "acc", "qfrc", "state"]:
                    delta = float(np.max(np.abs(x[key] - y[key]))) if y[key].size else 0.
                    atol = 2e-10 if key in ["counts", "free"] else 3e-6
                    errors[key] = dict(max_abs=delta, passed=bool(np.allclose(x[key], y[key], atol=atol, rtol=1e-8)))
                passed = all(v["passed"] for v in errors.values())
                record = dict(model=name, sample=i, passed=passed, errors=errors)
                records.append(record)
                if not passed:
                    failures.append(record)
        except (ValueError, AssertionError, StopIteration) as exc:
            failures.append(dict(model=name, error=str(exc)))
        print(name, "failures", len(failures), flush=True)
    result = dict(reference=mujoco.__version__, binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  local_angle=a.local_angle,
                  samples=a.samples, steps=a.steps, cases=len(records),
                  passed=sum(r["passed"] for r in records), failures=failures, records=records)
    (a.out / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print("RESULT", result["passed"], result["cases"], "failures", len(failures))
    raise SystemExit(bool(failures))


if __name__ == "__main__":
    main()
