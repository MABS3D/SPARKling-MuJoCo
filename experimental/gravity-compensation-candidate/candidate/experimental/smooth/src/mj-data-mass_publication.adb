package body MJ.Data.Mass_Publication with SPARK_Mode is
   procedure Prove_Entry_Symmetry (Mass : Real_Array; Nv, I, J : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
       and then I < Nv and then J < Nv,
     Post => Mass (I * Nv + J) = Mass (J * Nv + I)
   is
      IJ : constant Natural := MJ.Smooth_Kernels.Matrix_Offset (Nv, I, J);
      JI : constant Natural := MJ.Smooth_Kernels.Matrix_Offset (Nv, J, I);
   begin
      pragma Assert (Mass (IJ) = Mass (JI));
   end Prove_Entry_Symmetry;

   procedure Prove_Row_Entries (Mass : Real_Array; Nv, I : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv) and then I < Nv,
     Post => (for all J in 0 .. Nv - 1 => Mass (I * Nv + J) = Mass (J * Nv + I))
   is
   begin
      for J in 0 .. Nv - 1 loop
         Prove_Entry_Symmetry (Mass, Nv, I, J);
         pragma Loop_Invariant (for all K in 0 .. J =>
           Mass (I * Nv + K) = Mass (K * Nv + I));
      end loop;
   end Prove_Row_Entries;

   function Direct_Row_Symmetric (Mass : Real_Array; Nv, I : Natural) return Boolean is
     (for all J in 0 .. Nv - 1 => Mass (I * Nv + J) = Mass (J * Nv + I))
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv) and then I < Nv,
     Annotate => (GNATprove, Inline_For_Proof);

   procedure Prove_Row_Symmetry (Mass : Real_Array; Nv, I : Natural)
     with Ghost => Static, Global => null,
     Annotate => (GNATprove, Automatic_Instantiation),
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv) and then I < Nv,
     Post => Direct_Row_Symmetric (Mass, Nv, I)
   is
   begin
      Prove_Row_Entries (Mass, Nv, I);
   end Prove_Row_Symmetry;

   procedure Prove_All_Rows (Mass : Real_Array; Nv : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv),
     Post => (for all I in 0 .. Nv - 1 => Direct_Row_Symmetric (Mass, Nv, I))
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
   begin
      null;
   end Prove_All_Rows;

   procedure Prove_Dense_Symmetry (Mass : Real_Array; Nv : Natural)
     with Ghost => Static, Global => null,
     Pre => MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv),
     Post => (for all I in 0 .. Nv - 1 => (for all J in 0 .. Nv - 1 =>
       Mass (I * Nv + J) = Mass (J * Nv + I)))
   is
   begin
      Prove_All_Rows (Mass, Nv);
   end Prove_Dense_Symmetry;

   procedure Publish (D : in out Simulation; Mass : Real_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Prove_Dense_Symmetry (Mass, D.Nv);
      D.Dynamics.Mass.all := Mass;
      D.Cache.Mass_Valid := True;
      D.Cache.Force_Valid := False;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Publish;
   procedure Mark_Ready (D : in out Simulation) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Input_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", State_Image);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Body_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Joint_Bounded);
      Initial_Config : constant Configuration_Snapshot := Configuration (D) with Ghost => Static;
   begin
      Prove_Dense_Symmetry (D.Dynamics.Mass.all, D.Nv);
      D.Cache.Mass_Valid := True;
      D.Cache.Force_Valid := False;
      Prove_Configuration_Equality (Configuration (D), Initial_Config);
   end Mark_Ready;

end MJ.Data.Mass_Publication;
