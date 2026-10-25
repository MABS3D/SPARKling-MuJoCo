package body MJ.Data.Compact_Assembly with SPARK_Mode is
   procedure Separate_Rows (Rows : AR.Pattern; Current : Natural) with
     Ghost => Static, Global => null, Pre => Current < AR.Size (Rows),
     Post => (for all R in 0 .. Current - 1 =>
       AR.Start (Rows, R) + AR.Length (Rows, R) <= AR.Start (Rows, Current))
   is
   begin
      for R in 0 .. Current - 1 loop
         AR.Rows_Disjoint (Rows, R, Current);
         pragma Loop_Invariant (Static => (for all K in 0 .. R =>
           AR.Start (Rows, K) + AR.Length (Rows, K) <= AR.Start (Rows, Current)));
      end loop;
   end Separate_Rows;
   procedure Join_Rows
     (Rows : AR.Pattern; Topology : T.Cache; Composite : CA.Composite_Array;
      Motions, Mass : Real_Array; Through : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid_Inputs (Rows, Topology, Composite, Motions)
       and then Through < AR.Size (Rows)
       and then Mass'First = 0 and then Mass'Last = AR.Count (Rows) - 1
       and then (for all R in 0 .. Through - 1 =>
         (for all A in 0 .. AR.Length (Rows, R) - 1 =>
           Mass (AR.Start (Rows, R) + A) = Row_Value (Rows, Topology, Composite, Motions, R, A)))
       and then (for all A in 0 .. AR.Length (Rows, Through) - 1 =>
         Mass (AR.Start (Rows, Through) + A) = Row_Value (Rows, Topology, Composite, Motions, Through, A)),
     Post => (for all R in 0 .. Through =>
       (for all A in 0 .. AR.Length (Rows, R) - 1 =>
         Mass (AR.Start (Rows, R) + A) = Row_Value (Rows, Topology, Composite, Motions, R, A)))
   is
   begin
      null;
   end Join_Rows;

   procedure Fill
     (Rows : AR.Pattern; Topology : T.Cache; Composite : CA.Composite_Array;
      Motions : Real_Array; Mass : out Real_Array; Ok : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Work_Array);
      Before : Real_Array (Mass'Range) with Ghost => Static;
      Accepted : Boolean;
   begin
      CI.Clear (Mass);
      Ok := False;
      for I in 0 .. AR.Size (Rows) - 1 loop
         Before := Mass;
         Separate_Rows (Rows, I);
         CI.Assemble_Into_Row (Rows, I, Motions, Composite (T.Dof_Body (Topology, I)),
           T.Armature (Topology, I), T.Fixed_Inertia (Topology, I),
           T.Simple_Count (Topology, I) > 0, Mass, Accepted);
         if not Accepted then return; end if;
         pragma Assert (Static => (for all R in 0 .. I - 1 =>
           (for all A in 0 .. AR.Length (Rows, R) - 1 =>
             Mass (AR.Start (Rows, R) + A) = Before (AR.Start (Rows, R) + A))));
         pragma Assert (Static => (for all R in 0 .. I - 1 =>
           (for all A in 0 .. AR.Length (Rows, R) - 1 =>
             Mass (AR.Start (Rows, R) + A) = Row_Value (Rows, Topology, Composite, Motions, R, A))));
         pragma Assert (Static => (for all A in 0 .. AR.Length (Rows, I) - 1 =>
           Mass (AR.Start (Rows, I) + A) = Row_Value (Rows, Topology, Composite, Motions, I, A)));
         Join_Rows (Rows, Topology, Composite, Motions, Mass, I);
         pragma Loop_Invariant (Static => MJ.Smooth_Dynamics.Work_Array (Mass));
         pragma Loop_Invariant (Static => (for all R in 0 .. I =>
           (for all A in 0 .. AR.Length (Rows, R) - 1 =>
             Mass (AR.Start (Rows, R) + A) = Row_Value (Rows, Topology, Composite, Motions, R, A))));
      end loop;
      Ok := True;
   end Fill;

   procedure Build
     (Rows : AR.Pattern; Topology : T.Cache; Bodies : Body_Parameter_Array;
      Inertias, Motions : Real_Array; Mass : out Real_Array; Ok : out Boolean) is
      Composite : CA.Composite_Array (0 .. Bodies'Last) with Relaxed_Initialization;
   begin
      CA.Load_Composite (Inertias, Composite);
      CA.Accumulate_Composite (Bodies, Composite);
      Fill (Rows, Topology, Composite, Motions, Mass, Ok);
   end Build;
end MJ.Data.Compact_Assembly;
