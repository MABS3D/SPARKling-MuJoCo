"""Checked atomic rejection includes activation as part of the owned state."""
import argparse
import json
import subprocess
from pathlib import Path

import mujoco
from compare import model_xml


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--capacity-binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    records = []
    for early in (False, True):
        xml = model_xml('<body pos="0 0 .09"><joint name="z" type="slide" axis="0 0 1"/>'
                        '<geom type="sphere" size=".1" mass="1"/></body>')
        xml = xml.replace('</mujoco>', '<actuator><general joint="z" dyntype="integrator" '
                          f'gainprm="0" actearly="{str(early).lower()}"/></actuator></mujoco>')
        model = mujoco.MjModel.from_xml_string(xml)
        path = args.out / f'early-{early}.mjb'
        mujoco.mj_saveModel(model, str(path))
        run = subprocess.run([str(args.binary), str(path)], text=True, capture_output=True, timeout=60)
        row = dict(case=f'early-{early}', passed=run.returncode == 0 and run.stdout.strip() == 'activation atomicity PASS',
                   output=run.stdout + run.stderr)
        records.append(row)
        print(row, flush=True)
    bodies = ''.join(f'<body pos="{i} 0 .095"><freejoint name="j{i}"/>'
                     '<geom type="box" size=".1 .1 .1" mass="1"/></body>' for i in range(17))
    xml = model_xml(bodies).replace('</mujoco>', '<actuator><general joint="j0" dyntype="filter" '
                                   'dynprm=".03" gainprm=".1"/></actuator></mujoco>')
    model = mujoco.MjModel.from_xml_string(xml)
    data = mujoco.MjData(model)
    mujoco.mj_forward(model, data)
    assert data.nefc > 256, data.nefc
    path = args.out / 'capacity-activation.mjb'
    mujoco.mj_saveModel(model, str(path))
    run = subprocess.run([str(args.capacity_binary), str(path)], text=True, capture_output=True, timeout=60)
    row = dict(case='capacity-activation', nv=model.nv, rows=data.nefc,
               passed=run.returncode == 0 and run.stdout.strip() == 'capacity atomicity PASS', output=run.stdout + run.stderr)
    records.append(row)
    print(row, flush=True)
    (args.out / 'results.json').write_text(json.dumps(records, indent=2) + '\n')
    if not all(row['passed'] for row in records):
        raise SystemExit(1)


if __name__ == '__main__':
    main()
