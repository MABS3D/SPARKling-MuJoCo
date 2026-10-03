package body MJ.Pose_Arithmetic with SPARK_Mode is
   function "+" (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Sum_Matches);
   begin
      return MJ.Smooth_Math."+" (A, B);
   end "+";
   function "-" (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Difference_Matches);
   begin
      return MJ.Smooth_Math."-" (A, B);
   end "-";
   function "*" (S : Real; V : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Scale_Matches);
   begin
      return MJ.Smooth_Math."*" (S, V);
   end "*";
   function Cross (A, B : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Cross_Matches);
   begin
      return MJ.Smooth_Math.Cross (A, B);
   end Cross;
   function Apply_Config (R : Matrix; V : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Apply_Matches);
   begin
      return MJ.Smooth_Dynamics.Apply_Config (R, V);
   end Apply_Config;
   subtype Rotation_Middle is Real range -7.0e10 .. 7.0e10;
   subtype Rotation_Result is Real range -1.0e12 .. 1.0e12;
   function Intermediate_Value (A, B, C, X, Y, Z : Real) return Rotation_Middle
     with Ghost => Static, Global => null,
     Pre => A in -2.0 .. 2.0 and then B in -2.0 .. 2.0 and then C in -2.0 .. 2.0
       and then X in -Max_Val .. Max_Val and then Y in -Max_Val .. Max_Val
       and then Z in -Max_Val .. Max_Val,
     Post => Intermediate_Value'Result = (A*X + B*Y) - C*Z
   is
      subtype Product is Real range -2.1e10 .. 2.1e10;
      subtype Pair is Real range -4.3e10 .. 4.3e10;
      AX : constant Product := A*X;
      BY : constant Product := B*Y;
      CZ : constant Product := C*Z;
      Sum : constant Pair := AX+BY;
   begin
      return Sum-CZ;
   end Intermediate_Value;

   function Intermediate_Component (Q : Quaternion; V : Vector; I : Axis)
     return Rotation_Middle with Ghost => Static, Global => null,
     Pre => Bounded (Q, 2.0) and then Bounded (V, Max_Val),
     Post => Intermediate_Component'Result = MJ.Quaternions.Model.Rotation_Intermediate
       (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), I)
   is
   begin
      case I is
         when 0 => return Intermediate_Value (Q (0), Q (2), Q (3), V (0), V (2), V (1));
         when 1 => return Intermediate_Value (Q (0), Q (3), Q (1), V (1), V (0), V (2));
         when 2 => return Intermediate_Value (Q (0), Q (1), Q (2), V (2), V (1), V (0));
      end case;
   end Intermediate_Component;

   function Rotated_Value (V, A, B : Real; X, Y : Rotation_Middle) return Rotation_Result
     with Ghost => Static, Global => null,
     Pre => V in -Max_Val .. Max_Val and then A in -2.0 .. 2.0 and then B in -2.0 .. 2.0,
     Post => Rotated_Value'Result = V + 2.0*(A*X - B*Y)
   is
      subtype Product is Real range -1.5e11 .. 1.5e11;
      subtype Pair is Real range -3.1e11 .. 3.1e11;
      subtype Twice is Real range -6.3e11 .. 6.3e11;
      AX : constant Product := A*X;
      BY : constant Product := B*Y;
      Difference : constant Pair := AX-BY;
      Double : constant Twice := 2.0*Difference;
   begin
      return V+Double;
   end Rotated_Value;

   function Rotated_X (Q : Quaternion; V : Vector) return Rotation_Result
     with Ghost => Static, Global => null,
     Pre => Bounded (Q, 2.0) and then Bounded (V, Max_Val),
     Post => Rotated_X'Result = MJ.Quaternions.Model.Rotated_Component
       (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body",
        MJ.Quaternions.Model.Rotation_Intermediate);
      TA, TB : Rotation_Middle;
      Value : Rotation_Result;
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0) = 0.0);
         return 0.0;
      elsif Q (0) = 1.0 and then Q (1) = 0.0 and then Q (2) = 0.0 and then Q (3) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0) = V (0));
         return V (0);
      end if;
      TA := Intermediate_Component (Q, V, 2);
      TB := Intermediate_Component (Q, V, 1);
      Value := Rotated_Value (V (0), Q (2), Q (3),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1));
      pragma Assert (Static => TA = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2));
      pragma Assert (Static => TB = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1));
      pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0) =
          V (0) + 2.0*(Q (2)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2)
            - Q (3)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1)));
      return Value;
   end Rotated_X;

   function Rotated_Y (Q : Quaternion; V : Vector) return Rotation_Result
     with Ghost => Static, Global => null,
     Pre => Bounded (Q, 2.0) and then Bounded (V, Max_Val),
     Post => Rotated_Y'Result = MJ.Quaternions.Model.Rotated_Component
       (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body",
        MJ.Quaternions.Model.Rotation_Intermediate);
      TA, TB : Rotation_Middle;
      Value : Rotation_Result;
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1) = 0.0);
         return 0.0;
      elsif Q (0) = 1.0 and then Q (1) = 0.0 and then Q (2) = 0.0 and then Q (3) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1) = V (1));
         return V (1);
      end if;
      TA := Intermediate_Component (Q, V, 0);
      TB := Intermediate_Component (Q, V, 2);
      Value := Rotated_Value (V (1), Q (3), Q (1),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2));
      pragma Assert (Static => TA = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0));
      pragma Assert (Static => TB = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2));
      pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1) =
          V (1) + 2.0*(Q (3)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0)
            - Q (1)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2)));
      return Value;
   end Rotated_Y;

   function Rotated_Z (Q : Quaternion; V : Vector) return Rotation_Result
     with Ghost => Static, Global => null,
     Pre => Bounded (Q, 2.0) and then Bounded (V, Max_Val),
     Post => Rotated_Z'Result = MJ.Quaternions.Model.Rotated_Component
       (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body",
        MJ.Quaternions.Model.Rotation_Intermediate);
      TA, TB : Rotation_Middle;
      Value : Rotation_Result;
   begin
      if V (0) = 0.0 and then V (1) = 0.0 and then V (2) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2) = 0.0);
         return 0.0;
      elsif Q (0) = 1.0 and then Q (1) = 0.0 and then Q (2) = 0.0 and then Q (3) = 0.0 then
         pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
           (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2) = V (2));
         return V (2);
      end if;
      TA := Intermediate_Component (Q, V, 1);
      TB := Intermediate_Component (Q, V, 0);
      Value := Rotated_Value (V (2), Q (1), Q (2),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1),
        MJ.Quaternions.Model.Rotation_Intermediate
          (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0));
      pragma Assert (Static => TA = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1));
      pragma Assert (Static => TB = MJ.Quaternions.Model.Rotation_Intermediate
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0));
      pragma Assert (Static => MJ.Quaternions.Model.Rotated_Component
        (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 2) =
          V (2) + 2.0*(Q (1)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 1)
            - Q (2)*MJ.Quaternions.Model.Rotation_Intermediate
            (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), 0)));
      return Value;
   end Rotated_Z;

   function Rotated_Component (Q : Quaternion; V : Vector; I : Axis)
     return Rotation_Result with Ghost => Static, Global => null,
     Pre => Bounded (Q, 2.0) and then Bounded (V, Max_Val),
     Post => Rotated_Component'Result = MJ.Quaternions.Model.Rotated_Component
       (MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V), I)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body",
        MJ.Quaternions.Model.Rotated_Component);
   begin
      case I is
         when 0 => return Rotated_X (Q, V);
         when 1 => return Rotated_Y (Q, V);
         when 2 => return Rotated_Z (Q, V);
      end case;
   end Rotated_Component;

   function Rotate_Config (Q : Quaternion; V : Vector) return Vector is
      R : MJ.Rotations.Vector_3;
      Proof_X : constant Rotation_Result := Rotated_Component (Q, V, 0) with Ghost => Static;
      Proof_Y : constant Rotation_Result := Rotated_Component (Q, V, 1) with Ghost => Static;
      Proof_Z : constant Rotation_Result := Rotated_Component (Q, V, 2) with Ghost => Static;
   begin
      MJ.Rotations.Rotate (R, MJ.Rotations.Quaternion (Q), MJ.Rotations.Vector_3 (V));
      pragma Assert (Static => R (0) = Proof_X and then R (1) = Proof_Y and then R (2) = Proof_Z);
      return Vector (R);
   end Rotate_Config;
end MJ.Pose_Arithmetic;
