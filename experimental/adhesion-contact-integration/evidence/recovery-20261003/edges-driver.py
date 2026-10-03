"""Exercise bounded failure publication and recovery in the integrated adapter."""
import argparse, hashlib, json, subprocess
from pathlib import Path
import mujoco

p = argparse.ArgumentParser()
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=False)
assert mujoco.__version__ == '3.14.0'
fixtures = {
    'numeric-failure': '<geom type="sphere" size=".1" mass="1"/>',
    'capacity-failure': ''.join(f'<geom type="sphere" pos="{i*.21} 0 0" size=".1" mass="1"/>' for i in range(129)),
}
results = []
for mode, geometry in fixtures.items():
    gain = '1e10' if mode == 'numeric-failure' else '3'
    xml = ('<mujoco><option timestep=".001"><flag island="disable" warmstart="disable"/></option>'
           '<worldbody><geom type="plane" size="50 50 .1"/>'
           '<body name="b" pos="0 0 .095"><joint type="slide" axis="0 0 1"/>'
           + geometry + '</body></worldbody><actuator>'
           f'<general body="b" gainprm="{gain}"/></actuator></mujoco>')
    m = mujoco.MjModel.from_xml_string(xml)
    path = a.out/(mode+'.mjb'); mujoco.mj_saveModel(m, str(path))
    (a.out/(mode+'.xml')).write_text(xml)
    r = subprocess.run([str(a.binary), str(path), mode], capture_output=True, text=True, timeout=60)
    (a.out/(mode+'.log')).write_text(r.stdout+r.stderr)
    passed = r.returncode == 0 and 'adhesion failure atomicity PASS' in r.stdout
    results.append(dict(mode=mode, passed=passed, exit=r.returncode))
result = dict(reference=mujoco.__version__, binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(), cases=results)
(a.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result))
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
