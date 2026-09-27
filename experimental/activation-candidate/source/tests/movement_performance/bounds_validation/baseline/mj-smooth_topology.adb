package body MJ.Smooth_Topology with SPARK_Mode is
   procedure Build (T : in out Cache;
                    Roots, Last, Parents, Bodies, Joints, Simple : Int_Array;
                    Masses, Arms, Fixed : Real_Array) is
   begin
      T.Nb := Roots'Length;
      T.Nv := Parents'Length;
      T.Roots := new Int_Array'(Roots);
      T.Last := new Int_Array'(Last);
      T.Parents := new Int_Array'(Parents);
      T.Bodies := new Int_Array'(Bodies);
      T.Joints := new Int_Array'(Joints);
      T.Simple := new Int_Array'(Simple);
      T.Masses := new Real_Array'(Masses);
      T.Arms := new Real_Array'(Arms);
      T.Fixed := new Real_Array'(Fixed);
   end Build;

   procedure Free (T : in out Cache) is
   begin
      Free_Int (T.Roots);
      Free_Int (T.Last);
      Free_Int (T.Parents);
      Free_Int (T.Bodies);
      Free_Int (T.Joints);
      Free_Int (T.Simple);
      Free_Real (T.Masses);
      Free_Real (T.Arms);
      Free_Real (T.Fixed);
      T.Nb := 0;
      T.Nv := 0;
   end Free;

   procedure Add_Subtree (Masses : in out Real_Array; Parent, Child : Natural; Ok : out Boolean) is
      Sum : constant Real := Masses (Parent) + Masses (Child);
   begin
      Ok := Sum <= 1.0e14;
      if Ok then Masses (Parent) := Sum; end if;
   end Add_Subtree;

   procedure Build_Body_Links (Parents, First, Counts : Int_Array; Nv : Natural;
                               Roots, Last : out Int_Array) is
   begin
      Roots := [others => 0];
      Last := [others => -1];
      for B in 1 .. Parents'Last loop
         Roots (B) := (if Parents (B) = 0 then B else Roots (Parents (B)));
         Last (B) := (if Counts (B) = 0 then Last (Parents (B)) else First (B) + Counts (B) - 1);
         pragma Loop_Invariant (Roots (0) = 0 and then Last (0) = -1);
         pragma Loop_Invariant (for all K in 0 .. B => Roots (K) in 0 .. K
           and then (if K > 0 then Roots (K) > 0) and then Last (K) in -1 .. Nv - 1);
         pragma Loop_Invariant (for all K in 1 .. B =>
           Roots (K) = (if Parents (K) = 0 then K else Roots (Parents (K)))
           and then Last (K) = (if Counts (K) = 0 then Last (Parents (K)) else First (K) + Counts (K) - 1));
      end loop;
   end Build_Body_Links;
end MJ.Smooth_Topology;
