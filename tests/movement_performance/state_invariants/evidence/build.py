#!/usr/bin/env python3
"""Build isolated baseline, profiled baseline and unpromoted invariant shortcut.

Instrumentation is diagnostic code, never included in SPARK proof evidence.
Ready_Flag replaces only seven explicit entry guards in the shortcut experiment.
It requires the same Valid_State precondition; runtime numerical checks remain.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
sys.path.insert(0, str(REPO / 'experimental/smooth/tools'))
from prove_fragments import isolated_project

FLAGS = ['-gnat2022', '-gnatn', '-gnatp', '-O3', '-march=native', '-flto',
         '-ffat-lto-objects', '-ffp-contract=off', '-ffinite-math-only',
         '-fno-trapping-math', '-fno-math-errno', '-ffunction-sections', '-fdata-sections']


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def wrap(text, call, phase):
    assert text.count(call) == 1, call
    return text.replace(call, f'Movement_Profile.Start (Movement_Profile.{phase});\n      {call}\n'
                        f'      Movement_Profile.Stop (Movement_Profile.{phase});')


def instrument(src):
    smooth = src / 'experimental/smooth/src'
    main = src / 'tests/movement_performance/movement_bench.adb'
    for name in ('movement_profile.ads', 'movement_profile.adb'):
        shutil.copy2(HERE/name, main.parent/name)
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
            text=wrap(text,'Inertia.Solve_Euler (D, Result);','Euler_Solve')
            text=wrap(text,'Integrate (D, Result);','Integration')
        if unit=='inertia':
            text=text.replace('      D.Scratch.Factor.all := D.Dynamics.Mass.all;',
                              '      Movement_Profile.Start (Prepare_Factor);\n      D.Scratch.Factor.all := D.Dynamics.Mass.all;')
            text=text.replace('      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);',
                '      Movement_Profile.Stop (Prepare_Factor);\n      Movement_Profile.Start (Condition);\n'
                '      Check_Condition (D, Matrix_Norm, 1.0 / Relative_Tolerance, Result);\n'
                '      Movement_Profile.Stop (Condition);')
        p.write_text(text)
    p=smooth/'mj-data-forward.adb';text='with Movement_Profile; use Movement_Profile;\n'+p.read_text()
    for call,phase in [('Kinematics.Update','Kinematics'),('Inertia.Assemble','Mass'),
                       ('Forces.Compute','Forces'),('Actuation.Compute','Actuation'),
                       ('Inertia.Solve_Acceleration','Acceleration')]:
        text=wrap(text,call+' (D, Result);',phase)
    p.write_text(text)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out',type=Path,required=True)
    parser.add_argument('--toolchain-root',type=Path,required=True)
    args=parser.parse_args();out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    env=os.environ.copy()
    env['PATH']=':'.join(str(next((args.toolchain_root/t).glob('*/bin')))
                         for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
    snapshot=out/'source';snapshot.mkdir()
    for directory in ['src','experimental/smooth/src']:
        for p in (REPO/directory).rglob('*.ad?'):
            dst=snapshot/p.relative_to(REPO);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
    for p in [HERE.parent/'movement_bench.adb',REPO/'experimental/smooth/tests/smooth_probe.adb']:
        dst=snapshot/p.relative_to(REPO);dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dst)
    builds={}
    for variant in ['baseline','profile','shortcut','checked_shortcut']:
        work=out/variant;work.mkdir();src=work/'source';shutil.copytree(snapshot,src)
        # All variants share frozen smooth sources; only the helper and seven
        # entry guards differ in the isolated shortcut experiment.
        for p in (HERE/'baseline').glob('*.ad?'):
            shutil.copy2(p,src/'experimental/smooth/src'/p.name)
        if variant in ['shortcut','checked_shortcut']:
            shutil.copy2(HERE/'shortcut/mj-data.ads',src/'experimental/smooth/src/mj-data.ads')
            for unit in ['kinematics','forces','actuation','inertia','euler']:
                p=src/f'experimental/smooth/src/mj-data-{unit}.adb'
                text=p.read_text();assert 'if not Is_Ready (D) then' in text
                p.write_text(text.replace('if not Is_Ready (D) then','if not Ready_Flag (D) then'))
        if variant=='profile':instrument(src)
        main='smooth_probe' if variant=='checked_shortcut' else 'movement_bench'
        project=isolated_project(src,work,main)
        text=project.read_text().replace('project Fragment is',
            f'project Fragment is\n   for Main use ("{main}.adb");\n   for Exec_Dir use "bin";')
        if variant!='checked_shortcut':
            a=text.index('        ("-gnat2022"');b=text.index(';',a)
            text=text[:a]+'('+', '.join('"'+f+'"' for f in FLAGS)+')'+text[b:]
            text=text.replace('end Fragment;', '   package Linker is\n'
                '      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n'
                '   end Linker;\nend Fragment;')
        project.write_text(text)
        cmd=['gprbuild','-P',str(project),'-j2']
        with (work/'build.log').open('w') as log:
            subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
        binary=work/'bin'/main
        builds[variant]=dict(binary=str(binary),binary_sha256=digest(binary),command=cmd,
            sources={str(p.relative_to(src)):digest(p) for p in src.rglob('*.ad?')})
    (out/'build.json').write_text(json.dumps(dict(builds=builds),indent=2)+'\n')


if __name__=='__main__':main()
