#!/usr/bin/env python3
"""Count full and mutable phase guards on a frozen optimized build.

Instrumentation verifies call frequency and release-equivalent outputs; its
clock measurements are deliberately not used as performance evidence.
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

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('builder', HERE.parent/'dynamics_optimization/build.py')
builder = importlib.util.module_from_spec(spec)
spec.loader.exec_module(builder)
sys.path.insert(0, str(HERE.parent))
from run import parse

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--build', type=Path, required=True)
parser.add_argument('--out', type=Path, required=True)
parser.add_argument('--toolchain-root', type=Path, required=True)
parser.add_argument('--fixtures', type=Path, required=True)
a = parser.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
src = a.out/'source'
shutil.copytree(a.build/'source', src)
smooth = src/'experimental/smooth/src'
main = src/'tests/movement_performance/movement_bench.adb'
(main.parent/'guard_counts.ads').write_text('''package Guard_Counts is
   Enabled : Boolean := False;
   Full_Checks, Mutable_Checks : Natural := 0;
end Guard_Counts;
''')
p = smooth/'mj-data.ads'
s = 'with Guard_Counts;\n' + p.read_text()
s = s.replace('end MJ.Data;', '''   function Counted_Full (D : Simulation) return Boolean;
   function Counted_Mutable (D : Simulation) return Boolean;
end MJ.Data;''')
p.write_text(s)
for p in smooth.glob('mj-data*.adb'):
    s = p.read_text().replace('if not Is_Ready (D) then', 'if not Counted_Full (D) then')
    s = s.replace('if not Phase_Ready (D) then', 'if not Counted_Mutable (D) then')
    p.write_text(s)
p = smooth/'mj-data.adb'
s = p.read_text().replace('end MJ.Data;', '''   function Counted_Full (D : Simulation) return Boolean is
   begin
      if Guard_Counts.Enabled then Guard_Counts.Full_Checks := Guard_Counts.Full_Checks + 1; end if;
      return Is_Ready (D);
   end Counted_Full;
   function Counted_Mutable (D : Simulation) return Boolean is
   begin
      if Guard_Counts.Enabled then Guard_Counts.Mutable_Checks := Guard_Counts.Mutable_Checks + 1; end if;
      return Phase_Ready (D);
   end Counted_Mutable;
end MJ.Data;''')
p.write_text(s)
s = 'with Guard_Counts;\n' + main.read_text()
s = s.replace('         Started := Clock;', '         Guard_Counts.Enabled := Run > Warmups;\n         Started := Clock;')
s = s.replace('            Get_State (D, Qout', '            Guard_Counts.Enabled := False;\n            Get_State (D, Qout')
s = s.replace('   Free (D);', '''   Emit ("guards", [Real (Guard_Counts.Full_Checks), Real (Guard_Counts.Mutable_Checks)]);
   Free (D);''')
main.write_text(s)
project = builder.isolated_project(src, a.out, 'movement_bench')
s = project.read_text().replace('project Fragment is', 'project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
start = s.index('        ("-gnat2022"'); stop = s.index(';', start)
s = s[:start] + '(' + ', '.join('"'+f+'"' for f in builder.FLAGS) + ')' + s[stop:]
s = s.replace('end Fragment;', '   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
project.write_text(s)
env = os.environ.copy()
env['PATH'] = ':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove')) + ':' + env['PATH']
with (a.out/'build.log').open('w') as log:
    subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
results = []
for data in sorted(a.fixtures.glob('*-0.input')):
    model = data.stem[:-2]
    mjb = a.fixtures/(model+'.mjb')
    args = [str(mjb), '100', '4', '2']
    reference = subprocess.run([str(a.build/'current/bin/movement_bench'), *args],input=data.read_text(),text=True,capture_output=True,check=True)
    current = subprocess.run([str(a.out/'bin/movement_bench'), *args],input=data.read_text(),text=True,capture_output=True,check=True)
    (a.out/(model+'.output')).write_text(current.stdout+current.stderr)
    lines = current.stdout.splitlines()
    counts = [float(v) for line in lines if line.startswith('guards ') for v in line.split()[1:]]
    assert counts == [400,2000], (model, counts)
    old = parse(reference.stdout)
    new = parse('\n'.join(line for line in lines if not line.startswith('guards ')))
    assert len(old) == len(new) == 4
    for x,y in zip(old,new):
        for field in ('qpos','qvel','time'):
            assert x[field] == y[field], (model,field)
    results.append(dict(model=model,steps=400,full_checks=int(counts[0]),mutable_checks=int(counts[1])))
assert results, 'no movement fixture inputs found'
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
(a.out/'results.json').write_text(json.dumps(dict(status='passed',source_build=str(a.build),binary_sha256=sha(a.out/'bin/movement_bench'),sources={str(p.relative_to(src)):sha(p) for p in src.rglob('*.ad?')},results=results),indent=2)+'\n')
print('Verified one full and five mutable-only checks per step:',len(results),'models; exact release outputs')
