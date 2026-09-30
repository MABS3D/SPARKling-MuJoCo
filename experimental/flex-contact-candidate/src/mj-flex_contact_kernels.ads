with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Contact_Rows;

--  Cartesian flex vertices against one fixed plane, condim=1. The normal
--  points from the plane towards the allowed half-space (mjc_PlaneFlex).
package MJ.Flex_Contact_Kernels with SPARK_Mode is
   subtype Normal_Component is Real range -1.0 .. 1.0;
   type Normal_Vector is array (Axis) of Normal_Component;
   type Configuration is record
      Origin : Input_Vector := [others => 0.0];
      Normal : Normal_Vector := [0.0, 0.0, 1.0];
      Radius : Nonneg_Tier0 := 0.001;
      Margin, Gap : Nonneg_Tier0 := 0.0;
      Solver : MJ.Contact_Rows.Parameters;
   end record;
   function Valid (C : Configuration) return Boolean is
     (((C.Normal (0) ** 2 + C.Normal (1) ** 2) + C.Normal (2) ** 2)
        in 1.0 - 1.0e-12 .. 1.0 + 1.0e-12) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   subtype Height_Value is Real range -7.0e10 .. 7.0e10;
   subtype Distance_Value is Real range -1.0e11 .. 1.0e11;
   subtype Speed_Value is Real range -4.0e10 .. 4.0e10;
   subtype Free_Value is Real range -6.0e95 .. 6.0e95;
   subtype Projected_Value is Real range -2.0e96 .. 2.0e96;
   subtype Residual_Value is Real range -3.0e96 .. 3.0e96;
   subtype Load_Value is Real range 0.0 .. 4.0e111;
   subtype Acceleration_Value is Real range -1.0e128 .. 1.0e128;
   type Acceleration_Vector is array (Axis) of Acceleration_Value;
   type Free_Vector is array (Axis) of Free_Value;
   subtype Next_Velocity is Real range -2.0e128 .. 2.0e128;

   function Height (C : Configuration; X : Input_Vector) return Height_Value is
     (((X (0) - C.Origin (0)) * C.Normal (0)
       + (X (1) - C.Origin (1)) * C.Normal (1))
       + (X (2) - C.Origin (2)) * C.Normal (2)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Distance (C : Configuration; X : Input_Vector) return Distance_Value is
     (Height (C, X) - C.Radius) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Included (C : Configuration; X : Input_Vector) return Boolean is
     (Height (C, X) <= (C.Margin + C.Gap) + C.Radius) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Speed (N : Normal_Vector; V : Input_Vector) return Speed_Value is
     ((N (0) * V (0) + N (1) * V (1)) + N (2) * V (2)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   --  C's ordered passive - bias + applied, followed by inverse mass. The
   --  broad force domain of Elastic_Network is retained, including rejection
   --  only at the final state boundary, rather than a small-force precondition.
   function Free_Acceleration (Mass : Mass_Value; Spring, Damper : Accumulated_Value;
     Applied, Gravity : Tier0_Real) return Free_Value is
     (declare Passive : constant Passive_Value := Spring + Damper;
              Weight : constant Weight_Value := Mass * Gravity;
              Internal : constant Internal_Value := Passive + Weight;
              Total : constant Total_Value := Internal + Applied;
      begin Total * (1.0 / Mass))
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Project (N : Normal_Vector; A : Free_Vector) return Projected_Value is
     ((N (0) * A (0) + N (1) * A (1)) + N (2) * A (2)) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Diagonal_Component (N : Normal_Component; Inv_M : MJ.Contact_Rows.Inverse_Mass)
     return Real with Global => null,
     Post => Diagonal_Component'Result in 0.0 .. 1.0e15
       and then Diagonal_Component'Result = (N * Inv_M) * N;
   function Diagonal (N : Normal_Vector; Inv_M : MJ.Contact_Rows.Inverse_Mass)
     return Real is
     ((Diagonal_Component (N (0), Inv_M) + Diagonal_Component (N (1), Inv_M))
       + Diagonal_Component (N (2), Inv_M))
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body"), Post => Diagonal'Result in 0.0 .. 4.0e15;
   function Reference (K, B : MJ.Contact_Rows.Gain;
     I : MJ.Contact_Rows.Checked_Impedance; D : Distance_Value;
     Margin : Nonneg_Tier0; V : Speed_Value) return MJ.Contact_Rows.Reference_Acceleration is
     ((-B * V) - ((K * I) * (D - Margin))) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Projected_Force (B : Residual_Value; AR : MJ.Contact_Rows.Row_Diagonal)
     return Load_Value is (Real'Max (0.0, 0.0 - B * (1.0 / AR))) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Accelerated (A : Free_Value; F : Load_Value;
     N : Normal_Component; Inv_M : MJ.Contact_Rows.Inverse_Mass) return Acceleration_Value is
     (A + (N * F) * Inv_M) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Velocity_After (V : Tier0_Real; A : Acceleration_Value; H : Time_Step)
     return Next_Velocity is (V + H * A) with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   type Load_Result is record
      Accepted : Boolean;
      Force : Load_Value;
   end record;
   --  Ordered diagonal normal-row solve, including the compliance regularizer.
   function Response (C : Configuration; P : Particle; H : Time_Step;
     A : Free_Vector; I : MJ.Contact_Rows.Checked_Impedance) return Load_Value is
     (declare Inv : constant MJ.Contact_Rows.Inverse_Mass := 1.0 / P.Mass;
              R : constant MJ.Contact_Rows.Regularization := MJ.Contact_Rows.Regularizer (I, Inv);
              AR : constant MJ.Contact_Rows.Row_Diagonal := Diagonal (C.Normal, Inv) + R;
              K : constant MJ.Contact_Rows.Gain := MJ.Contact_Rows.Stiffness (C.Solver, H);
              B : constant MJ.Contact_Rows.Gain := MJ.Contact_Rows.Damping (C.Solver, H);
              Ref : constant MJ.Contact_Rows.Reference_Acceleration :=
                Reference (K, B, I, Distance (C, P.Position), C.Margin, Speed (C.Normal, P.Velocity));
      begin Projected_Force (Project (C.Normal, A) - Ref, AR))
     with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   package Model with Ghost => Static is
      function Load (C : Configuration; P : Particle; H : Time_Step;
        A : Free_Vector) return Load_Result is
        (if P.Pinned or else not Included (C, P.Position)
             or else Distance (C, P.Position) >= C.Margin then (True, 0.0)
         else (declare I : constant MJ.Contact_Rows.Raw_Impedance :=
                 MJ.Contact_Rows.Model.Impedance (C.Solver, Distance (C, P.Position), C.Margin);
           begin (if I not in MJ.Contact_Rows.Checked_Impedance then (False, 0.0)
             else (True, Response (C, P, H, A, I)))))
        with Global => null, Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   end Model;
   function Normal_Load (C : Configuration; P : Particle; H : Time_Step;
     A : Free_Vector) return Load_Result with Global => null,
     Post => (Static => Normal_Load'Result = Model.Load (C, P, H, A));

   subtype Contact_Rank is Natural range 0 .. 50;
   type Evaluation is record
      Accepted, Contact, Active : Boolean;
      Retained_Rank : Contact_Rank;
      Separation : Distance_Value;
      Force : Load_Value;
      Free : Free_Vector;
      Acceleration : Acceleration_Vector;
   end record;
   function Matches (C : Configuration; P : Particle; F : Edge_Force;
     Applied, Gravity : Input_Vector; H : Time_Step; Selected_Rank : Contact_Rank; R : Evaluation) return Boolean is
     (R.Retained_Rank = Selected_Rank
      and then R.Contact = Included (C, P.Position)
      and then R.Active = (Selected_Rank > 0 and then R.Contact and then Distance (C, P.Position) < C.Margin and then not P.Pinned)
      and then R.Separation = Distance (C, P.Position)
      and then (for all K in Axis => R.Free (K) = Free_Acceleration
        (P.Mass, F.Spring (K), F.Damper (K), Applied (K), Gravity (K)))
      and then Load_Result'(R.Accepted, R.Force) = (if Selected_Rank = 0 then Load_Result'(True, 0.0) else Model.Load (C, P, H, R.Free))
      and then (for all K in Axis => R.Acceleration (K) =
        (if P.Pinned then 0.0 else Accelerated (R.Free (K), R.Force, C.Normal (K), 1.0 / P.Mass))))
     with Ghost => Static, Global => null,
     Pre => Bounded (F.Spring, 1.0e80) and then Bounded (F.Damper, 1.0e80),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   procedure Evaluate (C : Configuration; P : Particle; F : Edge_Force;
     Applied, Gravity : Input_Vector; H : Time_Step; Selected_Rank : Contact_Rank; R : out Evaluation)
     with Global => null,
     Pre => Bounded (F.Spring, 1.0e80) and then Bounded (F.Damper, 1.0e80),
     Post => (Static => Matches (C, P, F, Applied, Gravity, H, Selected_Rank, R));
   pragma Postcondition (Static => R.Retained_Rank = Selected_Rank);
   procedure Integrate (P : in out Particle; A : Acceleration_Vector;
     H : Time_Step; Accepted : out Boolean) with Global => null,
     Post => (Static => P.Mass = P'Old.Mass and then P.Pinned = P'Old.Pinned
       and then (if not Accepted or else P.Pinned then P = P'Old)
       and then (if Accepted and then not P.Pinned then (for all K in Axis =>
         P.Velocity (K) = Velocity_After (P'Old.Velocity (K), A (K), H)
         and then P.Position (K) = P'Old.Position (K) + H * P.Velocity (K))));
end MJ.Flex_Contact_Kernels;
