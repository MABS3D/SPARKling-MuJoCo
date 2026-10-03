from pathlib import Path
import shutil,json,hashlib
base=Path('/var/tmp/sparkling-services-advanced-constrained-r19-r3-20261003');dst=Path('/var/tmp/sparkling-services-controller-stage-kernel-r19-20261003');dst.mkdir();shutil.copytree(base/'source',dst/'source');p=dst/'source/experimental/advanced-step'
f=p/'src/mj-advanced_state.ads';s=f.read_text();marker='end MJ.Advanced_State;';assert s.count(marker)==1
s=s.replace(marker,'''   --  Activation staging keeps the C clamp order. Even an invalid value
   --  may be admitted for evaluation: it clears Can_Advance without writing.
   function Staged_Value (Value : Real; Lower, Upper : Tier0_Real;
                          Apply_Limit : Boolean) return Real is
     (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value)
     with Global => null,
       Post => Staged_Value'Result =
         (if Apply_Limit then Real'Min (Upper, Real'Max (Lower, Value)) else Value)
         and then (if Apply_Limit then Staged_Value'Result in Tier0_Real);

   procedure Stage_Activation
     (Next_Act : in out Real_Array; Can_Advance : in out Boolean;
      Base, Offset : Natural; Value : Real; Lower, Upper : Tier0_Real;
      Apply_Limit : Boolean)
     with Global => null,
       Pre => (if Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real then
         Base <= Natural'Last - Offset and then Base + Offset in Next_Act'Range),
       Post => Can_Advance =
         (Can_Advance'Old and then Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real)
         and then (for all I in Next_Act'Range => Next_Act (I) =
           (if Staged_Value (Value, Lower, Upper, Apply_Limit) in Tier0_Real
              and then I = Base + Offset
            then Staged_Value (Value, Lower, Upper, Apply_Limit)
            else Next_Act'Old (I)));
end MJ.Advanced_State;''');f.write_text(s)
f=p/'src/mj-advanced_state.adb';s=f.read_text();s=s.replace(marker,'''   procedure Stage_Activation
     (Next_Act : in out Real_Array; Can_Advance : in out Boolean;
      Base, Offset : Natural; Value : Real; Lower, Upper : Tier0_Real;
      Apply_Limit : Boolean) is
      X : constant Real := Staged_Value (Value, Lower, Upper, Apply_Limit);
   begin
      if X not in Tier0_Real then
         Can_Advance := False;
      else
         Next_Act (Base + Offset) := X;
      end if;
   end Stage_Activation;
end MJ.Advanced_State;''');f.write_text(s)
s=(p/'controller_arrays_proof.gpr').read_text().replace('Controller_Arrays_Proof','Controller_State_Proof').replace('mj-controller_array_kernels','mj-advanced_state');(p/'controller_state_proof.gpr').write_text(s)
m=json.loads((base/'manifest.json').read_text());m['sources']['experimental/advanced-step/controller_state_proof.gpr']='';m['sources']={k:hashlib.sha256((dst/'source'/k).read_bytes()).hexdigest() for k in m['sources']};m['candidate_note']='Activation staging kernel only, not connected to controller yet. Exact clamp, target/tail frame and Can_Advance on rejection; index precondition applies only when the original code writes.';(dst/'manifest.json').write_text(json.dumps(m,indent=2)+'\n');print(dst)
