#!/usr/bin/env python3
"""Diagnose phases of a frozen six-optimization build; clock overhead included.

Instrumented timings are never release A/B evidence. Every observed trajectory
must exactly match the uninstrumented executable from the same frozen build.
"""
import argparse
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('base', HERE.parent/'state_invariants/build.py')
base = importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)
sys.path.insert(0, str(HERE.parent))


def instrument(src):
    smooth = src/'experimental/smooth/src'
    main = src/'tests/movement_performance/movement_bench.adb'
    for name in ('movement_profile.ads', 'movement_profile.adb'):
        shutil.copy2(base.HERE/name, main.parent/name)
    p = main.parent/'movement_profile.ads'
    s = p.read_text().replace('Prepare_Factor, Condition);',
        'Prepare_Factor, Condition, Physical_Solve, Spatial_Prepare, CRB, RNE);')
    p.write_text(s)
    s = 'with Movement_Profile;\n' + main.read_text()
    s = s.replace('         Started := Clock;', '         Movement_Profile.Enabled := Run > Warmups;\n         Started := Clock;')
    s = s.replace('            Get_State (D, Qout', '            Movement_Profile.Enabled := False;\n            Get_State (D, Qout')
    s = s.replace('   Free (D);', '   Movement_Profile.Dump;\n   Free (D);')
    main.write_text(s)
    p = smooth/'mj-data.ads'
    s = 'with Movement_Profile;\n' + p.read_text()
    s = s.replace('end MJ.Data;', '''   function Measured_Ready (D : Simulation; P : Movement_Profile.Phase; Mutable_Only : Boolean) return Boolean;
end MJ.Data;''')
    p.write_text(s)
    p = smooth/'mj-data.adb'
    s = p.read_text().replace('end MJ.Data;', '''   function Measured_Ready (D : Simulation; P : Movement_Profile.Phase; Mutable_Only : Boolean) return Boolean is
      R : Boolean;
   begin
      Movement_Profile.Start (P);
      R := (if Mutable_Only then Phase_Ready (D) else Is_Ready (D));
      Movement_Profile.Stop (P);
      return R;
   end Measured_Ready;
end MJ.Data;''')
    p.write_text(s)
    for unit, phases, mutable in [
        ('euler', ['Ready_Step'], False),
        ('inertia_phase', ['Ready_Mass', 'Ready_Acceleration', 'Ready_Euler'], True),
        ('forces_phase', ['Ready_Forces'], True),
        ('actuation_phase', ['Ready_Actuation'], True)]:
        p = smooth/f'mj-data-{unit}.adb'
        s = 'with Movement_Profile; use Movement_Profile;\n' + p.read_text()
        old = f'if not {"Phase_Ready" if mutable else "Is_Ready"} (D) then'
        assert s.count(old) == len(phases), unit
        for phase in phases:
            s = s.replace(old, f'if not Measured_Ready (D, {phase}, {str(mutable)}) then', 1)
        if unit == 'euler':
            s = base.wrap(s, 'Inertia_Phase.Solve_Euler (D, Result);', 'Euler_Solve')
            s = base.wrap(s, 'Integrate (D, Result);', 'Integration')
        if unit in ('inertia_phase', 'forces_phase'):
            s = base.wrap(s, 'Spatial.Prepare (D, Spatial_Ok);', 'Spatial_Prepare')
        if unit == 'inertia_phase':
            s = base.wrap(s, 'Try_Assemble_CRB (D, Candidate, Used_CRB);', 'CRB')
            start = s.index('   procedure Solve_Compatible ')
            stop = s.index('   end Solve_Compatible;', start)
            chunk = s[start:stop]
            chunk = chunk.replace('      Result := Numeric_Limit;', '      Movement_Profile.Start (Prepare_Factor);\n      Result := Numeric_Limit;', 1)
            chunk = chunk.replace('      D.Scratch.Solution.all :=', '      Movement_Profile.Stop (Prepare_Factor);\n      Movement_Profile.Start (Physical_Solve);\n      D.Scratch.Solution.all :=', 1)
            chunk = chunk.replace('      Result := Success;', '      Movement_Profile.Stop (Physical_Solve);\n      Result := Success;', 1)
            s = s[:start] + chunk + s[stop:]
        if unit == 'forces_phase':
            s = base.wrap(s, 'Try_Recursive (D, Gravity, Bias, Used_Recursive);', 'RNE')
        p.write_text(s)
    p = smooth/'mj-data-pipeline.adb'
    s = 'with Movement_Profile; use Movement_Profile;\n' + p.read_text()
    for call, phase in [('Update_Poses', 'Kinematics'), ('Inertia_Phase.Assemble', 'Mass'),
                        ('Forces_Phase.Compute', 'Forces'), ('Actuation_Phase.Compute', 'Actuation'),
                        ('Inertia_Phase.Solve_Acceleration', 'Acceleration')]:
        s = base.wrap(s, call+' (D, Result);', phase)
    p.write_text(s)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--toolchain-root', type=Path, required=True)
    p.add_argument('--fixtures', type=Path)
    p.add_argument('--cpu', type=int, default=12)
    a = p.parse_args()
    out = a.out.resolve()
    if not a.fixtures:
        out.mkdir(parents=True, exist_ok=False)
        src = out/'source'
        shutil.copytree(a.build/'source', src)
        instrument(src)
        project = base.isolated_project(src, out, 'movement_bench')
        s = project.read_text().replace('project Fragment is', 'project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
        start = s.index('        ("-gnat2022"'); stop = s.index(';', start)
        s = s[:start]+'('+', '.join('"'+f+'"' for f in base.FLAGS)+')'+s[stop:]
        s = s.replace('end Fragment;', '   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
        project.write_text(s)
        env = os.environ.copy()
        env['PATH'] = ':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat', 'gprbuild', 'gnatprove'))+':'+env['PATH']
        with (out/'build.log').open('w') as log:
            subprocess.run(['gprbuild', '-P', str(project), '-j2'], env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
        (out/'manifest.json').write_text(json.dumps(dict(source_build=json.loads((a.build/'build.json').read_text()),
            sources={str(p.relative_to(src)):base.digest(p) for p in src.rglob('*.ad?')},
            binary_sha256=base.digest(out/'bin/movement_bench')), indent=2)+'\n')
        return
    from run import parse
    os.sched_setaffinity(0, {a.cpu})
    results = []
    raw = out/'timings'; raw.mkdir(exist_ok=False)
    for data in sorted(a.fixtures.glob('*-0.input')):
        model = data.stem[:-2]
        mjb = a.fixtures/(model+'.mjb')
        cmd = [str(mjb), '100', '4', '2']
        ref = subprocess.run([str(a.build/'current/bin/movement_bench'), *cmd], input=data.read_text(), text=True, capture_output=True, check=True)
        expected = parse(ref.stdout)
        for repeat in range(6):
            run = subprocess.run([str(out/'bin/movement_bench'), *cmd], input=data.read_text(), text=True, capture_output=True, check=True)
            (raw/f'{model}-{repeat}.txt').write_text(run.stdout+run.stderr)
            lines = run.stdout.splitlines()
            rows = parse('\n'.join(s for s in lines if not s.startswith('profile ')))
            assert len(rows) == len(expected) == 4
            for row, reference in zip(rows, expected):
                for field in ('qpos', 'qvel', 'time'):
                    assert row[field] == reference[field], (model, field)
            phases = {}
            for line in lines:
                if line.startswith('profile '):
                    _, phase, seconds, count = line.split()
                    phases[phase] = dict(ns_per_step=float(seconds)*1e9/400, count=int(count))
            assert phases['READY_STEP']['count'] == 400
            assert sum(v['count'] for k,v in phases.items() if k.startswith('READY_')) == 2400
            results.append(dict(model=model, repeat=repeat, total_ns_per_step=sum(r['seconds'] for r in rows)*1e9/400, phases=phases))
    assert results
    (out/'results.json').write_text(json.dumps(dict(complete=True, cpu=a.cpu, clock_overhead_included=True, records=results), indent=2)+'\n')
    print('Profile complete:',len(results),'runs; numerical outputs exactly match release')


if __name__ == '__main__':
    main()
