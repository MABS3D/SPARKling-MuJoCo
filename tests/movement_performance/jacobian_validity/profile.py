#!/usr/bin/env python3
"""Build or run diagnostic instrumentation on the frozen readiness build.

Nested timings include clock overhead; never use these as A/B speed claims.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE=Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
spec=importlib.util.spec_from_file_location('instrumentation',HERE.parent/'state_invariants/build.py')
base=importlib.util.module_from_spec(spec);spec.loader.exec_module(base)


def instrument(src):
    smooth = src / 'experimental/smooth/src'
    main = src / 'tests/movement_performance/movement_bench.adb'
    for name in ('movement_profile.ads', 'movement_profile.adb'):
        shutil.copy2(base.HERE/name, main.parent/name)
    text=main.read_text()
    text='with Movement_Profile;\n'+text
    text=text.replace('         Started := Clock;',
        '         Movement_Profile.Enabled := Run > Warmups;\n         Started := Clock;')
    text=text.replace('            Get_State (D, Qout',
        '            Movement_Profile.Enabled := False;\n            Get_State (D, Qout')
    text=text.replace('   Free (D);', '   Movement_Profile.Dump;\n   Free (D);')
    main.write_text(text)
    p=smooth/'mj-data.ads';text='with Movement_Profile;\n'+p.read_text()
    text=text.replace('end MJ.Data;', '   function Measured_Ready (D : Simulation; P : Movement_Profile.Phase) return Boolean;\nend MJ.Data;')
    p.write_text(text)
    p=smooth/'mj-data.adb';text=p.read_text().replace('end MJ.Data;', '''   function Measured_Ready (D : Simulation; P : Movement_Profile.Phase) return Boolean is
      R : Boolean;
   begin
      Movement_Profile.Start (P);
      R := Is_Ready (D);
      Movement_Profile.Stop (P);
      return R;
   end Measured_Ready;
end MJ.Data;''');p.write_text(text)
    for unit, phases in [('kinematics',['Ready_Kinematics']), ('forces',['Ready_Forces']),
                         ('actuation',['Ready_Actuation']), ('euler',['Ready_Step']),
                         ('inertia',['Ready_Mass','Ready_Acceleration','Ready_Euler'])]:
        p=smooth/f'mj-data-{unit}.adb';text='with Movement_Profile; use Movement_Profile;\n'+p.read_text()
        assert text.count('if not Is_Ready (D) then')==len(phases)
        for phase in phases:
            text=text.replace('if not Is_Ready (D) then',f'if not Measured_Ready (D, {phase}) then',1)
        if unit=='euler':
            text=base.wrap(text,'Inertia.Solve_Euler (D, Result);','Euler_Solve')
            text=base.wrap(text,'Integrate (D, Result);','Integration')
        if unit=='inertia':
            text=text.replace('      D.Scratch.Factor.all := D.Dynamics.Mass.all;',
                              '      Movement_Profile.Start (Prepare_Factor);\n      D.Scratch.Factor.all := D.Dynamics.Mass.all;')
            text=text.replace('      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);',
                '      Movement_Profile.Stop (Prepare_Factor);\n      Movement_Profile.Start (Condition);\n'
                '      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);\n'
                '      Movement_Profile.Stop (Condition);')
        p.write_text(text)
    p=smooth/'mj-data-pipeline.adb';text='with Movement_Profile; use Movement_Profile;\n'+p.read_text()
    for call,phase in [('Update_Poses','Kinematics'),('Inertia.Assemble','Mass'),
                       ('Forces.Compute','Forces'),('Actuation.Compute','Actuation'),
                       ('Inertia.Solve_Acceleration','Acceleration')]:
        text=base.wrap(text,call+' (D, Result);',phase)
    p.write_text(text)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--toolchain-root',type=Path,required=True)
    p.add_argument('--fixtures',type=Path)
    p.add_argument('--cpu',type=int,default=12)
    a=p.parse_args();out=a.out.resolve()
    if not a.fixtures:
        out.mkdir(parents=True,exist_ok=False)
        src=out/'source';shutil.copytree(a.build/'source',src)
        instrument(src)
        smooth=src/'experimental/smooth/src'
        phase=src/'tests/movement_performance/movement_profile.ads'
        text=phase.read_text().replace('Prepare_Factor, Condition);',
            'Prepare_Factor, Condition, Physical_Solve, Jacobians, CRB, RNE, Mass_Fallback, Forces_Fallback);')
        phase.write_text(text)
        path=smooth/'mj-data-inertia.adb';text=path.read_text()
        text=text.replace('      D.Scratch.Solution.all := D.Dynamics.Total.all;',
            '      Movement_Profile.Stop (Prepare_Factor);\n      Movement_Profile.Start (Physical_Solve);\n      D.Scratch.Solution.all := D.Dynamics.Total.all;',1)
        text=text.replace('      Result := Success;\n   end Solve_Compatible;',
            '      Movement_Profile.Stop (Physical_Solve);\n      Result := Success;\n   end Solve_Compatible;',1)
        text=base.wrap(text,'Try_Assemble_CRB (D, Candidate, Used_CRB);','CRB')
        text=text.replace('      --  Kinetic energy:', '      Movement_Profile.Start (Mass_Fallback);\n      --  Kinetic energy:',1)
        text=text.replace('      D.Cache.Mass_Valid := True;\n      Result := Success;\n   end Assemble;',
            '      Movement_Profile.Stop (Mass_Fallback);\n      D.Cache.Mass_Valid := True;\n      Result := Success;\n   end Assemble;',1)
        path.write_text(text)
        path=smooth/'mj-data-forces.adb';text=path.read_text()
        text=base.wrap(text,'Try_Recursive (D, Gravity, Bias, Used_Recursive);','RNE')
        text=text.replace('      if not Used_Recursive then',
            '      if not Used_Recursive then\n         Movement_Profile.Start (Forces_Fallback);',1)
        text=text.replace('      for J in 0 .. D.Nj - 1 loop\n         declare\n            C : constant Joint_Parameters := D.Joint_Config (J);\n            Value',
            '      if not Used_Recursive then Movement_Profile.Stop (Forces_Fallback); end if;\n      for J in 0 .. D.Nj - 1 loop\n         declare\n            C : constant Joint_Parameters := D.Joint_Config (J);\n            Value',1)
        path.write_text(text)
        path=smooth/'mj-data-jacobians.adb';text='with Movement_Profile; use Movement_Profile;\n'+path.read_text()
        text=text.replace('      Ok := False;\n      Linear :=', '      Movement_Profile.Start (Movement_Profile.Jacobians);\n      Ok := False;\n      Linear :=',1)
        text=text.replace('      Ok := True;\n   end Build;', '      Movement_Profile.Stop (Movement_Profile.Jacobians);\n      Ok := True;\n   end Build;',1)
        path.write_text(text)
        project=base.isolated_project(src,out,'movement_bench')
        text=project.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
        start=text.index('        ("-gnat2022"');stop=text.index(';',start)
        text=text[:start]+'('+', '.join('"'+f+'"' for f in base.FLAGS)+')'+text[stop:]
        text=text.replace('end Fragment;','   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
        project.write_text(text)
        env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
        with (out/'build.log').open('w') as log:
            subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
        (out/'manifest.json').write_text(json.dumps(dict(
            source_build=json.loads((a.build/'build.json').read_text()),
            sources={str(p.relative_to(src)):base.digest(p) for p in src.rglob('*.ad?')},
            binary_sha256=base.digest(out/'bin/movement_bench')),indent=2)+'\n')
        return
    from run import parse
    os.sched_setaffinity(0,{a.cpu})
    results=[];raw=out/'timings';raw.mkdir(exist_ok=False)
    for model in ('hinge_motor','branched_multijoint','chain_12','crb_no_damping','crb_chain_24'):
        for state in range(3):
            key=f'{model}-{state}';data=(a.fixtures/(key+'.input')).read_text();mjb=a.fixtures/(model+'.mjb')
            ref=subprocess.run([str(a.build/'current/bin/movement_bench'),str(mjb),'100','1','2'],input=data,text=True,capture_output=True,check=True)
            expected=parse(ref.stdout)[0]
            for repeat in range(8):
                run=subprocess.run([str(out/'bin/movement_bench'),str(mjb),'100','4','2'],input=data,text=True,capture_output=True,check=True)
                (raw/f'{key}-{repeat}.txt').write_text(run.stdout+run.stderr)
                lines=run.stdout.splitlines();rows=parse('\n'.join(s for s in lines if not s.startswith('profile ')))
                for row in rows:
                    for field in ('qpos','qvel','time'): assert row[field]==expected[field],(key,field)
                phases={}
                for line in lines:
                    if line.startswith('profile '):
                        _,phase,seconds,count=line.split()
                        phases[phase]=dict(ns_per_step=float(seconds)*1e9/400,count=int(count))
                assert sum(v['count'] for k,v in phases.items() if k.startswith('READY_'))==2400
                assert phases['READY_KINEMATICS']['count']==0
                assert phases['JACOBIANS']['count']==(400 if model=='hinge_motor' else 0)
                assert phases['CONDITION']['count']==0
                assert phases['PHYSICAL_SOLVE']['count']==(400 if model=='crb_no_damping' else 800)
                for phase in ('MASS_FALLBACK','FORCES_FALLBACK'):
                    assert phases[phase]['count']==(400 if model=='hinge_motor' else 0)
                results.append(dict(case=key,repeat=repeat,total_ns_per_step=sum(r['seconds'] for r in rows)*1e9/400,phases=phases))
    (out/'results.json').write_text(json.dumps(dict(complete=True,cpu=a.cpu,clock_overhead_included=True,records=results),indent=2)+'\n')
    print('Profile complete:',len(results),'runs; numerical outputs exactly match release')


if __name__=='__main__': main()
