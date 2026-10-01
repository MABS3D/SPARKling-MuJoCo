--  Legacy four perturbations used by native MuJoCo for curved manifolds.
with MJ.Rigid_Math; use MJ.Rigid_Math;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
package body MJ.Contact_Perturbations with SPARK_Mode is
   procedure Expand (A, B : Object; PA, PB : Pose; V : Vertex_Array;
                     Margin, Radius1, Radius2 : Real; O : Options;
                     W : in out MJ.Convex_Contacts.Workspace;
                     M : in out Manifold; Result : out Status; Graphs : Graph_Array := Empty_Graph) is
      N : constant Vec := Unit (M.Items (0).Normal);
      Origin : constant Vec := M.Items (0).Position;
      Initial_Distance : constant Real := M.Items (0).Distance;
      T : Vec := (if N (1) > -0.5 and N (1) < 0.5 then [0.0, 1.0, 0.0] else [0.0, 0.0, 1.0]);
      Z, Axis_V, Q : Vec;
      R, Inverse_R : Matrix;
      P1, P2 : Pose;
      C, S, Q00, Q01, Q02, Q03, Q11, Q12, Q13, Q22, Q23, Q33 : Real;
      Tolerance : constant Real := 1.0e-3*Real'Min (Radius1, Radius2);
      Trial : Manifold;
      Distinct : Boolean;
      procedure Rotate (Original : Pose; Rotation : Matrix; P : out Pose) is
         Row, Relative, Displacement : Vec;
      begin
         P := Original;
         Relative := Sub (Origin, Original.Position);
         Displacement := Sub (Transform (Rotation, Relative), Relative);
         P.Position := Sub (Original.Position, Displacement);
         for I in Axis loop
            Row := [Rotation (3*I), Rotation (3*I+1), Rotation (3*I+2)];
            for J in Axis loop P.Rotation (3*I+J) := Dot (Row, Column (Original.Rotation, J)); end loop;
         end loop;
      end Rotate;
   begin
      Result := Success; T := Unit (Sub (T, Scale (N, Dot (N, T)))); Z := Cross (N, T);
      for AX in 0 .. 1 loop
         Axis_V := (if AX = 0 then T else Z);
         for Sign in -1 .. 1 loop
            if Sign /= 0 then
               C := Cos (Real (Sign)*0.0005); S := Sin (Real (Sign)*0.0005); Q := Scale (Axis_V, S);
               Q00 := C*C; Q01 := C*Q (0); Q02 := C*Q (1); Q03 := C*Q (2);
               Q11 := Q (0)*Q (0); Q12 := Q (0)*Q (1); Q13 := Q (0)*Q (2);
               Q22 := Q (1)*Q (1); Q23 := Q (1)*Q (2); Q33 := Q (2)*Q (2);
               R := [((Q00+Q11)-Q22)-Q33, 2.0*(Q12-Q03), 2.0*(Q13+Q02),
                     2.0*(Q12+Q03), ((Q00-Q11)+Q22)-Q33, 2.0*(Q23-Q01),
                     2.0*(Q13-Q02), 2.0*(Q23+Q01), ((Q00-Q11)-Q22)+Q33];
               Inverse_R := [R (0), R (3), R (6), R (1), R (4), R (7), R (2), R (5), R (8)];
               Rotate (PA, R, P1); Rotate (PB, Inverse_R, P2);
               MJ.Convex_Contacts.Generate (A, B, P1, P2, V, Margin, O, W, Trial, Result, Graphs => Graphs);
               if Result /= Success then M.Length := 0; return; end if;
               if Trial.Length > 0 then
                  Distinct := True;
                  for I in 0 .. M.Length-1 loop
                     if Norm (Sub (M.Items (I).Position, Trial.Items (0).Position)) <= Tolerance then Distinct := False; exit; end if;
                  end loop;
                  if Distinct then Trial.Items (0).Distance := Initial_Distance; M.Items (M.Length) := Trial.Items (0); M.Length := M.Length+1; end if;
               end if;
            end if;
         end loop;
      end loop;
   end Expand;
end MJ.Contact_Perturbations;
