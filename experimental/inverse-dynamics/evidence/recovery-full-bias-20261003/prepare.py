from pathlib import Path
import json,hashlib,shutil,difflib
r=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');common=Path('/var/tmp/sparkling-recovery-dynamics-20261003-19/movement16');base=Path('/var/tmp/sparkling-services-fullbias-consumers-control-20261003');new=Path('/var/tmp/sparkling-services-fullbias-consumers-candidate-20261003')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
commonmap=json.loads((common/'manifest.json').read_text())['sources']
base.mkdir(exist_ok=True);source=base/'source'
for f,h in commonmap.items():
 p=common/'source'/f;assert sha(p)==h,f
 q=source/f;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
owned=['experimental/inverse-dynamics','experimental/dynamics-derivatives-candidate']
for folder in owned:
 for p in (r/folder).rglob('*'):
  if p.is_file() and p.suffix in ['.ads','.adb','.py','.c','.gpr'] and not any(x in p.relative_to(r/folder).parts for x in ['evidence','obj','bin']):
   q=source/p.relative_to(r);q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,q)
for f in ['experimental/smooth/tools/compare_numerics.py','experimental/smooth/tools/prove_fragments.py','experimental/smooth/tools/test_actuation_integration.py','experimental/constrained-step/tests/compare.py','experimental/adhesion-contact-integration/tests/compare_adhesion.py','experimental/constraint-solvers-candidate/tests/differential.py']:
 q=source/f;q.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(r/f,q)
for f in ['experimental/smooth/tests/manifold-fixtures','experimental/smooth/tests/tendon-fixtures']:
 if (r/f).exists():shutil.copytree(r/f,source/f,dirs_exist_ok=True)
shutil.copytree(base,new)
s=new/'source';f=s/'experimental/inverse-dynamics/src/mj-inverse_kernels.ads';t=f.read_text();needle='   procedure Initialize_Entry\n';add='''   -- Complete RNE bias (gravity already included), in C inverse order.
   function Required_Full_Bias (Inertial, Full_Bias, Passive, Constraint : Real) return Real
     with Global => null,
       Pre => Inertial in -1.0e100 .. 1.0e100
         and then Full_Bias in -1.0e60 .. 1.0e60
         and then Passive in -1.0e60 .. 1.0e60
         and then Constraint in -1.0e60 .. 1.0e60,
       Post => Required_Full_Bias'Result = Full_Bias + ((Inertial - Passive) - Constraint)
         and then Required_Full_Bias'Result in -1.1e100 .. 1.1e100;
''';assert needle in t;f.write_text(t.replace(needle,add+needle,1))
f=s/'experimental/inverse-dynamics/src/mj-inverse_kernels.adb';t=f.read_text();needle='   procedure Initialize_Entry\n';add='''   function Required_Full_Bias (Inertial, Full_Bias, Passive, Constraint : Real) return Real is
     (Full_Bias + ((Inertial - Passive) - Constraint));
''';assert needle in t;f.write_text(t.replace(needle,add+needle,1))
f=s/'experimental/inverse-dynamics/src/mj-data-inverse.adb';t=f.read_text();old='''MJ.Inverse_Kernels.Required
                 (Candidate (I), D.Dynamics.Bias (I), D.Dynamics.Gravity (I),''';replace='''MJ.Inverse_Kernels.Required_Full_Bias
                 (Candidate (I), Full_Bias_Value (D, I),''';assert old in t;f.write_text(t.replace(old,replace))
f=s/'experimental/dynamics-derivatives-candidate/src/mj-dynamics_derivatives.adb';t=f.read_text();old='Force_Value (W.S, Velocity_Bias, I) - Force_Value (W.S, Gravity_Force, I)';assert t.count(old)==1;f.write_text(t.replace(old,'Full_Bias_Value (W.S, I)'))
files=[];patch=[]
for p in s.rglob('*'):
 if p.is_file():
  rel=str(p.relative_to(s));before=source/rel
  if p.read_bytes()!=before.read_bytes():
   files.append(rel);patch.extend(difflib.unified_diff(before.read_text().splitlines(True),p.read_text().splitlines(True),fromfile='a/'+rel,tofile='b/'+rel))
for out in [base,new]:
 hashes={str(p.relative_to(out/'source')):sha(p) for p in (out/'source').rglob('*') if p.is_file()}
 (out/'manifest.json').write_text(json.dumps({'sources':hashes,'common_origin':str(common),'common_manifest_sha256':sha(common/'manifest.json'),'modified_consumers':files if out==new else []},indent=2)+'\n')
 (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
 shutil.copy2(__file__,out/'prepare.py')
(new/'candidate.patch').write_text(''.join(patch));print({'common':len(commonmap),'changes':files,'source_files':len(hashes)})
