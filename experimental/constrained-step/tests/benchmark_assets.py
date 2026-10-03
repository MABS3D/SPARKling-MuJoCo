"""Equivalent complete trajectories for the newly owned collision assets."""
import argparse
import ctypes
import hashlib
import json
import os
import platform
import subprocess
from pathlib import Path

import mujoco
import numpy as np
from compare_assets import fixtures

p = argparse.ArgumentParser()
p.add_argument("--binary", type=Path, required=True)
p.add_argument("--out", type=Path, required=True)
p.add_argument("--repeats", type=int, default=15)
p.add_argument("--steps", type=int, default=100)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
wheel = Path(mujoco.__file__).parent
lib = wheel / "libmujoco.so.3.14.0"
native = a.out / "benchmark.so"
command = ["gcc", "-O3", "-march=native", "-ffp-contract=off", "-fPIC", "-shared",
           str(Path(__file__).with_name("benchmark.c")), "-I" + str(wheel / "include"),
           str(lib), "-Wl,-rpath," + str(wheel), "-o", str(native)]
subprocess.run(command, check=True)
timer = ctypes.CDLL(str(native)).constrained_time
timer.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
timer.restype = ctypes.c_double
selected = {"mesh_plane_Newton_3", "mesh_sphere_False", "mesh_hillclimb_plane",
            "heightfield_sphere_9_False", "heightfield_box_5_False"}
records = []
for name, xml, profile in fixtures():
    if name not in selected:
        continue
    m = mujoco.MjModel.from_xml_string(xml)
    if profile:
        nr, nc = int(m.hfield_nrow[0]), int(m.hfield_ncol[0])
        x, y = np.meshgrid(np.linspace(-1, 1, nc), np.linspace(-1, 1, nr))
        m.hfield_data[:] = (.25 + .03 * x + .02 * y + (.01 * x * y if profile == "relief" else 0)).ravel()
    file = a.out / (name + ".mjb")
    mujoco.mj_saveModel(m, str(file))
    d = mujoco.MjData(m)
    q, v, force = m.qpos0.copy(), np.linspace(-.015, .015, m.nv), np.linspace(-.02, .02, m.nv)
    data = f"1 {a.steps}\n" + " ".join(format(x, ".17g") for x in [0., *q, *v, *force]) + "\n"
    times = {"ada": [], "c": []}
    states = {}
    max_error = 0.
    for repeat in range(a.repeats + 2):
        for language in (["ada", "c"] if repeat % 2 == 0 else ["c", "ada"]):
            if language == "ada":
                run = subprocess.run([str(a.binary), str(file), "benchmark"], input=data,
                                     capture_output=True, text=True, check=True, timeout=180)
                lines = run.stdout.splitlines()
                assert lines[0].startswith("seconds "), run.stdout
                seconds = float(lines[0].split()[1])
                states[language] = np.fromstring(lines[1][6:], sep=" ")
            else:
                mujoco.mj_resetData(m, d)
                d.qpos[:], d.qvel[:], d.qfrc_applied[:] = q, v, force
                seconds = timer(m._address, d._address, a.steps)
                states[language] = np.r_[d.qpos, d.qvel, d.time].copy()
            if repeat >= 2:
                times[language].append(seconds / a.steps * 1e6)
        error = float(np.max(np.abs(states["ada"] - states["c"])))
        max_error = max(max_error, error)
        assert np.allclose(states["ada"], states["c"], atol=3e-6, rtol=1e-8), (name, error)
    summary = {language: dict(median_us=float(np.median(values)),
                             p10_us=float(np.percentile(values, 10)),
                             p90_us=float(np.percentile(values, 90)),
                             p95_us=float(np.percentile(values, 95)))
               for language, values in times.items()}
    row = dict(model=name, nv=m.nv, times_us=times, summary=summary, steps=a.steps,
               ratio=summary["ada"]["median_us"] / summary["c"]["median_us"],
               trajectory_max_abs=max_error)
    records.append(row)
    print({k: v for k, v in row.items() if k != "times_us"}, flush=True)
    report = dict(reference=mujoco.__version__,
                  reference_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),
                  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  hardware=platform.uname()._asdict(), affinity=sorted(os.sched_getaffinity(0)),
                  command=command, repeats=a.repeats, results=records)
    (a.out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
