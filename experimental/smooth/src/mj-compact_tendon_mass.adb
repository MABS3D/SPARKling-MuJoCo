package body MJ.Compact_Tendon_Mass with SPARK_Mode is
   function Slot (P : AR.Pattern; Row, Col : Natural) return Integer is
      A : constant Natural := AR.Length (P, Col) - 1;
   begin
      pragma Assert (Static => (for all B in 0 .. AR.Length (P, Row) - 1 =>
        (if AR.Column (P, Row, B) = Col then B = A)));
      if A < AR.Length (P, Row) and then AR.Column (P, Row, A) = Col then
         return AR.Start (P, Row) + A;
      end if;
      return -1;
   end Slot;

   procedure Add (Mass : in out Real_Array; Index : Natural; Change : TK.Mass_Change) is
   begin
      Mass (Index) := TK.Accumulate_Mass (Mass (Index), Change);
   end Add;

   procedure Unfold_Model
     (C : TM.Description; P : AR.Pattern; Initial : Real_Array; Count : Natural) is
   begin
      null;
   end Unfold_Model;

   procedure Accumulate (C : TM.Description; P : AR.Pattern;
                         Mass : in out Real_Array; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Model);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Work_Array);
      Initial : constant Real_Array := Mass with Ghost => Static;
      Target : Integer;
   begin
      Ok := False;
      for K in 1 .. C.Nm loop
         Target := Matrix_Slot (P, C.Mass (K).Index);
         if Target < 0 then return; end if;
         Unfold_Model (C, P, Initial, K);
         Add (Mass, Target, C.Mass (K).Value);
         pragma Loop_Invariant (Static => Work_Array (Mass));
         pragma Loop_Invariant (Static => (for all J in 1 .. K =>
           Matrix_Slot (P, C.Mass (J).Index) >= 0));
         pragma Loop_Invariant (Static => (for all H in Mass'Range =>
           Mass (H) = Model (C, P, Initial, H, K)));
      end loop;
      Ok := True;
   end Accumulate;
end MJ.Compact_Tendon_Mass;
