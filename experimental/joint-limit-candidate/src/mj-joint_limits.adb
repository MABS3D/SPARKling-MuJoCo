package body MJ.Joint_Limits with SPARK_Mode is
   function Scaled_Component (X : Tier0_Real; N : Real) return Tier1_Real is
      Inv : constant Real range 0.0 .. 1.0e15 := 1.0/N;
   begin
      return X * Inv;
   end Scaled_Component;
   function Rotation_Vector (Axis : Vector; Speed : Real) return Vector is
   begin
      return [Axis (0)*Speed, Axis (1)*Speed, Axis (2)*Speed];
   end Rotation_Vector;
   function Normalize3 (V : Vector) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized3);
      N : constant Real := Norm3 (V);
   begin
      pragma Assert (MJ.BLAS.In_Tier1 (V));
      if N < Min_Val then return [1.0, 0.0, 0.0]; end if;
      return [Scaled_Component (V (0), N), Scaled_Component (V (1), N), Scaled_Component (V (2), N)];
   end Normalize3;
   function Normalize4 (Q : Quaternion) return Quaternion is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized4);
      N : constant Real := Norm4 (Q);
   begin
      pragma Assert (MJ.BLAS.In_Tier1 (Q));
      if N < Min_Val then return [1.0, 0.0, 0.0, 0.0];
      elsif abs (N - 1.0) <= Min_Val then return Q; end if;
      return [Scaled_Component (Q (0), N), Scaled_Component (Q (1), N),
              Scaled_Component (Q (2), N), Scaled_Component (Q (3), N)];
   end Normalize4;
   function Short_Angle (Sin_Half, Cos_Half : Real) return Angle_Result is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Short_Angle);
      T : constant Real := MJ.Joint_Limit_Math.Atan2 (Sin_Half, Cos_Half);
      A : Real;
   begin
      if T not in -5.0 .. 5.0 then return (others => <>); end if;
      A := 2.0*T;
      if A > Ada.Numerics.Pi then A := A - 2.0 * Ada.Numerics.Pi; end if;
      return (Success, A);
   end Short_Angle;
   function Build_Scalar (Joint, Dof : Index_Type; Position, Low, High : Tier0_Real;
                          Margin : Tier0_Real; Enabled : Boolean := True) return Batch is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Scalar);
      R : Batch := Empty;
      L : constant Distance := -1.0 * (Low - Position);
      U : constant Distance := High - Position;
   begin
      if not Enabled then return R; end if;
      if L < Margin then
         R.Count := 1;
         R.Rows (1) := (Joint, Dof, 1, Lower, L, Margin, [1.0, 0.0, 0.0]);
      end if;
      if U < Margin then
         R.Count := R.Count + 1;
         R.Rows (R.Count) := (Joint, Dof, 1, Upper, U, Margin, [-1.0, 0.0, 0.0]);
      end if;
      return R;
   end Build_Scalar;
   function Build_Ball_Row (Joint, Dof : Index_Type; Angle : Nonneg_Tier0; Axis : Vector;
                           Low, High : Tier0_Real; Margin : Tier0_Real) return Batch is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Ball_Row);
      Dist : constant Distance := Real'Max (Low, High) - Angle;
   begin
      if Dist < Margin then
         return (Success, 1, [(Joint, Dof, 3, Angular, Dist, Margin,
           [-Axis (0), -Axis (1), -Axis (2)]), (others => <>)]);
      end if;
      return Empty;
   end Build_Ball_Row;
   function Build_Ball (Joint, Dof : Index_Type; Q : Quaternion; Low, High : Tier0_Real;
                       Margin : Tier0_Real; Enabled : Boolean := True) return Batch is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Ball);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized3);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Normalized4);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Short_Angle);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Ball_Row);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Norm3);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Norm4);
      NQ : Quaternion;
      V, Axis, Rotation : Vector;
      N, Angle : Real;
      Speed : Angle_Result;
   begin
      if not Enabled then return Empty; end if;
      NQ := Normalize4 (Q);
      if not MJ.BLAS.In_Tier0 (NQ) then return Rejected; end if;
      V := [NQ (1), NQ (2), NQ (3)];
      N := Norm3 (V);
      if N < 0.0 or else (N = 0.0 and then NQ (0) = 0.0) then return Rejected; end if;
      Axis := Normalize3 (V);
      if not MJ.BLAS.In_Tier0 (Axis) then return Rejected; end if;
      Speed := Short_Angle (N, NQ (0));
      if Speed.Result /= Success then return Rejected; end if;
      Rotation := Rotation_Vector (Axis, Speed.Value);
      if not MJ.BLAS.In_Tier0 (Rotation) then return Rejected; end if;
      Angle := Norm3 (Rotation);
      if Angle not in Nonneg_Tier0 then return Rejected; end if;
      Axis := Normalize3 (Rotation);
      if not MJ.BLAS.In_Tier0 (Axis) then return Rejected; end if;
      return Build_Ball_Row (Joint, Dof, Angle, Axis, Low, High, Margin);
   end Build_Ball;
   function Build (Kind : Joint_Kind; Joint, Dof : Index_Type; Position : Tier0_Real;
                   Q : Quaternion; Low, High : Tier0_Real; Margin : Tier0_Real;
                   Enabled : Boolean := True) return Batch is
   begin
      case Kind is
         when Free => return Empty;
         when Ball => return Build_Ball (Joint, Dof, Q, Low, High, Margin, Enabled);
         when Slide | Hinge => return Build_Scalar (Joint, Dof, Position, Low, High, Margin, Enabled);
      end case;
   end Build;
   function Project_Forces (B : Batch; F : Forces) return Vector is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Projected_Component);
      function Component (A : Natural) return Tier3_Real with
        Pre => A <= 2 and then Well_Formed (B),
        Post => (Static => Component'Result = Model.Projected_Component (B, F, A))
      is
         pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Model.Projected_Component);
         First, Second : Real range -1.0e69 .. 1.0e69 := 0.0;
      begin
         if B.Result /= Success or else B.Count = 0 then return 0.0; end if;
         if B.Rows (1).Width = 3 or else A = 0 then First := B.Rows (1).Jacobian (A)*F (1); end if;
         if B.Count = 2 and then (B.Rows (2).Width = 3 or else A = 0) then
            Second := B.Rows (2).Jacobian (A)*F (2);
         end if;
         return First + Second;
      end Component;
   begin
      return [Component (0), Component (1), Component (2)];
   end Project_Forces;
end MJ.Joint_Limits;
