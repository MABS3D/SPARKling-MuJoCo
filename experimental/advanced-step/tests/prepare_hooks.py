"""Generate private factory hooks without modifying the shared parent."""
from pathlib import Path
import argparse,difflib,hashlib,json
here=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser()
p.add_argument('--base',type=Path,default=here.parents[1])
a=p.parse_args();root=a.base
out=here/'integration'
changes={}
name='experimental/constrained-step/src/mj-data-constrained.ads';s=(root/name).read_text();old=s
needle='private\n   --  Shared stages';s=s.replace(needle,'''private
   --  Child force producers can own activation/control while sharing D.
   procedure Create_Core (M : in out MJ.Models.Model; E : in out Engine;
                          Result : out Status; Dynamics_Only : Boolean)
     with Post => M.Opt.Disableflags = M.Opt.Disableflags'Old
       and then M.Flg_Adhesion = M.Flg_Adhesion'Old
       and then (if Result = Success then Ready (E));
   procedure Generate_Contacts (E : in out Engine; Result : out Status);
   --  Shared stages''');assert s!=old;changes[name]=(old,s)
name='experimental/constrained-step/src/mj-data-constrained.adb';s=(root/name).read_text();old=s
needle='   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is'
s=s.replace(needle,needle+'''
   begin
      Create_Core (M, E, Result, Dynamics_Only => False);
   end Create;

   procedure Create_Core (M : in out MJ.Models.Model; E : in out Engine;
                          Result : out Status; Dynamics_Only : Boolean) is''',1)
s=s.replace('      MJ.Data.Create (M, E.D, Result);','''      if Dynamics_Only then
         MJ.Data.Create_Dynamics (M, E.D, Result);
      else
         MJ.Data.Create (M, E.D, Result);
      end if;''',1)
# Preserve the new public wrapper's end marker; rename only the factory body.
i=s.index('   procedure Create_Core');j=s.index('   end Create;',i);s=s[:j]+s[j:].replace('   end Create;','   end Create_Core;',1)
assert s!=old;changes[name]=(old,s)
patch=''.join(''.join(difflib.unified_diff(a.splitlines(True),b.splitlines(True),fromfile='a/'+n,tofile='b/'+n)) for n,(a,b) in changes.items())
(out/'advanced-factory-hooks.patch').write_text(patch)
(out/'advanced-factory-hooks.json').write_text(json.dumps({n:dict(before=hashlib.sha256(a.encode()).hexdigest(),after=hashlib.sha256(b.encode()).hexdigest()) for n,(a,b) in changes.items()},indent=2)+'\n')
# Do not mutate the shared parent; build.py applies this patch only to its copy.
