with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Smooth_Kernels; use MJ.Smooth_Kernels;
package MJ.Smooth_Actuation with SPARK_Mode is
   type Parameters is record
      Joint_Id, Control_Id, Output_Id : Natural := 0;
      Gear, Gain : Tier0_Real := 0.0;
      Bias : Vector := Zero;
      Control_Limited, Force_Limited : Boolean := False;
      Control_Lower, Control_Upper, Force_Lower, Force_Upper : Tier0_Real := 0.0;
   end record;
   type Parameter_Array is array (Natural range <>) of Parameters;
   function Valid_Parameter (C : Parameters) return Boolean is
     (Bounded (C.Bias, Max_Val)
      and then (if C.Control_Limited then C.Control_Lower <= C.Control_Upper)
      and then (if C.Force_Limited then C.Force_Lower <= C.Force_Upper)) with Global => null;
   function Valid_Inputs (C : Parameter_Array; Q, V, U : Real_Array) return Boolean is
     (C'First = 0 and then C'Length <= 1024 and then C'Last = C'Length - 1 and then Q'First = 0
      and then Same_Bounds (Q, V) and then U'First = 0 and then U'Length = C'Length
      and then All_Tier0 (Q) and then All_Tier0 (V) and then All_Tier0 (U)
      and then (for all I in C'Range => C (I).Joint_Id in Q'Range
        and then C (I).Control_Id = I and then C (I).Output_Id = I
        and then Valid_Parameter (C (I)))) with Global => null;
   function Force_Law
     (C : Parameters; Q, V, U : Tier0_Real; Enabled, Clamp_Control : Boolean) return Actuator_Force_Real is
       (if not Enabled then 0.0 else
         (if C.Force_Limited then Clamp
           (Affine_Force (C.Gain, Control_Value (U, C.Control_Lower, C.Control_Upper,
              Clamp_Control and then C.Control_Limited), C.Bias, Transmission (C.Gear, Q), Transmission (C.Gear, V)),
            C.Force_Lower, C.Force_Upper)
          else Affine_Force (C.Gain, Control_Value (U, C.Control_Lower, C.Control_Upper,
            Clamp_Control and then C.Control_Limited), C.Bias, Transmission (C.Gear, Q), Transmission (C.Gear, V)))) with Global => null, Pre => Valid_Parameter (C);
   function Force_For
     (C : Parameters; Q, V, U : Tier0_Real; Enabled, Clamp_Control : Boolean) return Actuator_Force_Real with
     Global => null, Pre => Valid_Parameter (C),
     Post => Force_For'Result = Force_Law (C, Q, V, U, Enabled, Clamp_Control);
   Step_Bound : constant Real := 2.0 ** 140;
   subtype Accumulated_Real is Real range -1.0e50 .. 1.0e50;
   function Accumulate (Acc : Accumulated_Real; Term : Actuator_Torque_Real; Count : Natural) return Accumulated_Real with
     Global => null, Pre => Count < 1024 and then abs Acc <= Real (Count) * Step_Bound,
     Post => Accumulate'Result = Acc + Term
       and then abs Accumulate'Result <= Real (Count + 1) * Step_Bound;
   function Valid_Forces (C : Parameter_Array; F : Real_Array) return Boolean is
     (C'First = 0 and then C'Length <= 1024 and then C'Last = C'Length - 1 and then F'First = 0
      and then F'Last = C'Last and then (for all X of F => X in Actuator_Force_Real)) with Global => null;
   function Reduced_Force (C : Parameter_Array; F : Real_Array; Joint, Count : Natural)
     return Accumulated_Real is
     (if Count = 0 then 0.0
      elsif C (Count - 1).Joint_Id = Joint then
        Accumulate (Reduced_Force (C, F, Joint, Count - 1),
          Project_Force (C (Count - 1).Gear, F (Count - 1)), Count - 1)
      else Reduced_Force (C, F, Joint, Count - 1)) with
     Ghost => Static, Global => null,
     Pre => Valid_Forces (C, F) and then Count <= C'Length and then Count <= 1024,
     Post => abs Reduced_Force'Result <= Real (Count) * Step_Bound
       and then (if Count = 0 then Reduced_Force'Result = 0.0),
     Subprogram_Variant => (Decreases => Count);
   procedure Unfold_Forces (C : Parameter_Array; F : Real_Array; Count : Natural) with
     Ghost => Static, Global => null,
     Pre => Valid_Forces (C, F) and then Count < C'Length and then Count < 1024,
     Post => (for all Joint in Natural => Reduced_Force (C, F, Joint, Count + 1) =
       (if C (Count).Joint_Id = Joint then
          Accumulate (Reduced_Force (C, F, Joint, Count), Project_Force (C (Count).Gear, F (Count)), Count)
        else Reduced_Force (C, F, Joint, Count)));
   procedure Project_All (C : Parameter_Array; F : Real_Array; Generalized : out Real_Array) with
     Global => null,
     Pre => Valid_Forces (C, F) and then (for all X of C => X.Joint_Id in Generalized'Range),
     Post => (for all X of Generalized => X in Accumulated_Real);
   pragma Postcondition (Static => (for all J in Generalized'Range =>
     Generalized (J) = Reduced_Force (C, F, J, C'Length)));

   procedure Accumulate_At (A : in out Real_Array; Index, Count : Natural; Term : Actuator_Torque_Real) with
     Global => null, Pre => Index in A'Range and then Count < 1024
       and then (for all X of A => X in Accumulated_Real and then abs X <= Real (Count) * Step_Bound),
     Post => (for all X of A => X in Accumulated_Real and then abs X <= Real (Count + 1) * Step_Bound)
       and then (for all I in A'Range => A (I) = (if I = Index then A'Old (I) + Term else A'Old (I)));

   procedure Compute
     (C : Parameter_Array; Q, V, U : Real_Array; Enabled, Clamp_Control : Boolean;
      Lengths, Velocities, Forces, Generalized : out Real_Array) with
     Global => null,
     Pre => Valid_Inputs (C, Q, V, U)
       and then Lengths'First = 0 and then Lengths'Last = C'Length - 1
       and then Velocities'First = 0 and then Velocities'Last = C'Length - 1
       and then Forces'First = 0 and then Forces'Last = C'Length - 1
       and then Generalized'First = Q'First and then Generalized'Last = Q'Last,
     Post => (for all I in C'Range => Lengths (I) = Transmission (C (I).Gear, Q (C (I).Joint_Id)))
       and then (for all I in C'Range => Velocities (I) =
         (if Enabled then Transmission (C (I).Gear, V (C (I).Joint_Id)) else 0.0))
       and then (for all I in C'Range => Forces (I) =
         Force_For (C (I), Q (C (I).Joint_Id), V (C (I).Joint_Id), U (I), Enabled, Clamp_Control))
       and then (for all X of Lengths => X in Transmission_Real)
       and then (for all X of Velocities => X in Transmission_Real)
       and then (for all X of Forces => X in Actuator_Force_Real)
       and then (for all X of Generalized => X in Accumulated_Real);
   pragma Postcondition (Static => (for all J in Q'Range =>
     Generalized (J) = Reduced_Force (C, Forces, J, C'Length)));
end MJ.Smooth_Actuation;
