#!/usr/bin/env python3
"""DIAGNOSTIC ONLY: deliberately unproved guard ablations, never production sources."""
import argparse, pathlib, shutil, subprocess, os, re, json, hashlib, difflib
P=pathlib.Path
ap=argparse.ArgumentParser(); ap.add_argument('--frozen',type=P,required=True); ap.add_argument('--out',type=P,required=True); ap.add_argument('--toolchains',type=P,required=True); ap.add_argument('--only', nargs='+')
a=ap.parse_args(); a.out.mkdir(parents=True,exist_ok=bool(a.only))
env=os.environ.copy(); env['PATH']=':'.join(str(next((a.toolchains/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
base=a.frozen/'baseline'; records=json.loads((a.out/'manifest.json').read_text()) if a.only else {}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def modify(src,kind):
    changed=[]
    def edit(name,fn):
        p=src/'experimental/smooth/src'/name; old=p.read_text(); new=fn(old)
        if old!=new: p.write_text(new); changed.extend(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile=name,tofile=name))
    if kind in ('scans','phase_scans','both','combined'):
        for name,predicate in [('mj-data-euler.adb','Is_Ready'),('mj-data-forces_phase.adb','Phase_Ready'),('mj-data-actuation_phase.adb','Phase_Ready'),('mj-data-inertia_phase.adb','Phase_Ready')]:
            if kind=='phase_scans' and predicate=='Is_Ready': continue
            edit(name,lambda s,predicate=predicate:s.replace('if not '+predicate+' (D) then','if False then'))
    if kind in ('guards','both','combined'):
        names=['mj-data-pipeline.adb','mj-data-spatial.adb','mj-data-forces_phase.adb','mj-data-inertia_phase.adb','mj-data-actuation_phase.adb','mj-data-euler.adb']
        pattern=re.compile(r'(?m)^(\s*)(?:if|elsif)\s+([^;]+?)\s+then(?=\s*(?:\n|return;|pragma))')
        def guards(s):
            def sub(m):
                cond=m.group(2)
                if any(x in cond for x in ('Within_Work (','Bounded (','Division_Bounded (','not in Tier0_Real')) and not any(x in cond for x in (' loop',' begin',' end','pragma','=>')):
                    return m.group(0).replace(cond,'False',1)
                return m.group(0)
            s=pattern.sub(sub,s)
            s=re.sub(r'Ok := Motion_Bounded \(S\);','Ok := True;',s)
            return s
        for name in names: edit(name,guards)
        edit('mj-solver_kernels.adb',lambda s:re.sub(r'Rejected := Rejected \+ Boolean\x27Pos \([^;]+;','Rejected := 0;',s))
        # Fast-product guards: all measured inputs must retain the same fast path.
        edit('mj-solver_reductions.adb',lambda s:re.sub(r'Rejected := (?:Rejected \+ )?Boolean\x27Pos \([^;]+;','Rejected := 0;',s))
    if kind in ('fused','combined'):
        def fuse(s):
            first,rest=s.split('   end Try_Recursive;',1)
            first=first.replace('Acceleration (0) := [others => 0.0];','Acceleration (0) := (if D.Gravity_Enabled then [0.0, 0.0, 0.0, -D.Gravity (0), -D.Gravity (1), -D.Gravity (2)] else [others => 0.0]);')
            first=re.sub(r'Gravity \(B\) := \(if D.Gravity_Enabled.*?else \[others => 0.0\]\);','Gravity (B) := [others => 0.0];',first,flags=re.S)
            first=re.sub(r'               Sum := SK.Add_Wrenches \(Gravity \(P\), Gravity \(B\)\);.*?               Gravity \(P\) := Sum;','',first,flags=re.S)
            first=first.replace('G : constant Real := SK.Dot (Axis, Gravity (Body_Id));','G : constant Real := 0.0;')
            return first+'   end Try_Recursive;'+rest
        edit('mj-data-forces_phase.adb',fuse)
    return ''.join(changed)
for kind in (a.only or ('baseline','scans','phase_scans','guards','both','fused','compact','combined','no_vector')):
    root=a.out/kind; root.mkdir(); shutil.copytree(base/'source',root/'source')
    patch=''
    if kind in ('compact','combined'):
        for p in (a.frozen/'current/source/experimental/smooth/src').iterdir():
            q=root/'source/experimental/smooth/src'/p.name
            if p.is_file() and (not q.exists() or p.read_bytes()!=q.read_bytes()):
                old=q.read_text() if q.exists() else ''; new=p.read_text(); patch+=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile=p.name,tofile=p.name)); shutil.copy2(p,q)
    patch+=modify(root/'source',kind)
    project=next(base.glob('*.gpr')).read_text().replace(str(base),str(root))
    if kind in ('compact','combined'):
        project=next((a.frozen/'current').glob('*.gpr')).read_text().replace(str(a.frozen/'current'),str(root))
    if kind=='no_vector': project=project.replace('"-O3",','"-O3", "-fno-tree-vectorize", "-fno-tree-slp-vectorize",')
    (root/'fragment.gpr').write_text(project); (root/'changes.patch').write_text(patch)
    with (root/'build.log').open('w') as log: subprocess.run(['gprbuild','-P',str(root/'fragment.gpr'),'-j4'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    records[kind]={'binary':str(root/'bin/movement_bench'),'binary_sha256':sha(root/'bin/movement_bench'),'source_hashes':{str(p.relative_to(root/'source')):sha(p) for p in sorted((root/'source').rglob('*')) if p.is_file()},'patch_sha256':sha(root/'changes.patch')}
    print(kind,'built',flush=True)
reference=json.loads((a.frozen/'build.json').read_text())['builds']['c']
assert sha(P(reference['library']))==reference['library_sha256']
records['c']={'binary':str(a.frozen/'movement_c'),'binary_sha256':sha(a.frozen/'movement_c'),'library':reference['library'],'library_sha256':reference['library_sha256']}
(a.out/'manifest.json').write_text(json.dumps(records,indent=2))
