from pathlib import Path
import json,hashlib,shutil,re
base=Path('/var/tmp/sparkling-services-advanced-evaluation-child14-r19-20261003');dst=Path('/var/tmp/sparkling-services-advanced-evaluation-child16-r19-20261003');dst.mkdir();shutil.copytree(base/'source',dst/'source');p=dst/'source/experimental/advanced-step/src'
read=set('Nq Nv Nb Initialized Has_Sites Nu No Na Nactuator Disabled_Groups Config Control Control_Lo Control_Hi Control_Limited Act'.split())
write=set('Valid Can_Advance Next_Act Dot L V F Qforce Acc Rows'.split())
def mapped(s):
 def convert(m):
  n=m[1]
  assert n in read|write, n
  return 'E.'+('Source.' if n in read else 'Work.')+n
 return re.sub(r'\bE\.(\w+)',convert,s)
f=p/'mj-data-advanced_control.ads';s=f.read_text();start=s.index('   type Controller is limited record');end=s.index('   end record;',start)+len('   end record;')
replacement='''   --  Both records remain limited, preserving by-reference calls. Evaluation
   --  receives Source as an in parameter and changes only Work.
   type Input_Storage is limited record
      Nq : Natural range 0 .. Max_Positions := 0;
      Nv : Dof_Width := 0;
      Nb : Natural range 0 .. Max_Bodies := 0;
      Initialized, Has_Sites : Boolean := False;
      Nu : Natural range 0 .. Max_Controls := 0;
      No : Natural range 0 .. Max_Outputs := 0;
      Na, Nactuator : Natural range 0 .. Max_Actuators := 0;
      Disabled_Groups : Natural := 0;
      Config : Config_Array (0 .. Max_Actuators - 1);
      Control : Real_Array (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Lo, Control_Hi : State_Vector (0 .. Max_Controls - 1) := [others => 0.0];
      Control_Limited : Bool_Array (0 .. Max_Controls - 1) := [others => False];
      Act : Real_Array (0 .. Max_Actuators - 1) := [others => 0.0];
   end record;
   type Evaluation_Storage is limited record
      Valid, Can_Advance : Boolean := False;
      Next_Act, Dot : Real_Array (0 .. Max_Actuators - 1) := [others => 0.0];
      L, V, F : Real_Array (0 .. Max_Outputs - 1) := [others => 0.0];
      Qforce, Acc : Real_Array (0 .. Max_Dofs - 1) := [others => 0.0];
      Rows : TX.Result (3 * Max_Dofs - 1);
   end record;
   type Controller is limited record
      Source : Input_Storage;
      Work : Evaluation_Storage;
   end record;'''
s=s[:start]+replacement+s[end:];f.write_text(mapped(s))
for name in ['mj-data-advanced_control.adb','mj-data-advanced_control-evaluation.adb','mj-data-advanced_control-computation.ads']:
 f=p/name;f.write_text(mapped(f.read_text()))
f=p/'mj-data-advanced_control-computation.adb';s=f.read_text();s=s.replace('E : Controller;', 'E : Input_Storage;')
old='procedure Compute (D : Simulation; E : in out Controller; Result : out Status) is';new='procedure Compute_Core (D : Simulation; E : Input_Storage; Work : in out Evaluation_Storage;\n                           Result : out Status) with Global => null is';assert s.count(old)==1;s=s.replace(old,new).replace('end Compute;','end Compute_Core;')
s=re.sub(r'\bE\.(\w+)',lambda m:('Work.' if m[1] in write else 'E.')+m[1],s)
s=s.replace('end MJ.Data.Advanced_Control.Computation;','''   procedure Compute (D : Simulation; E : in out Controller; Result : out Status) is
   begin
      Compute_Core (D, E.Source, E.Work, Result);
   end Compute;
end MJ.Data.Advanced_Control.Computation;''');f.write_text(s)
for name in ['mj-data-advanced_control.ads','mj-data-advanced_control.adb','mj-data-advanced_control-evaluation.adb','mj-data-advanced_control-computation.ads']:
 assert set(re.findall(r'\bE\.(\w+)',(p/name).read_text())) <= {'Source','Work'}
# Verify the arithmetic body only changes the names of work buffers.
old=(base/'source/experimental/advanced-step/src/mj-data-advanced_control-computation.adb').read_text();new=f.read_text()
a=old[old.index('      F, Drive, G, B, Raw, X : Real;'):old.index('   end Compute;')]
b=new[new.index('      F, Drive, G, B, Raw, X : Real;'):new.index('   end Compute_Core;')]
assert re.sub(r'\bWork\.', 'E.', b)==a
m=json.loads((base/'manifest.json').read_text());m['sources']={k:hashlib.sha256((dst/'source'/k).read_bytes()).hexdigest() for k in m['sources']};m['candidate_note']='Limited Source/Work records and a component-formal Compute_Core, existing Compute frame contract retained. Arithmetic body text identical after buffer-name mapping. Pending proofs/runtime.';(dst/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
print(dst)
