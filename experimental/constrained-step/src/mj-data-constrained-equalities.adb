--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see repository LICENSE.
--  Modified: owned connect/weld integration, MuJoCo 3.14.0.
with Interfaces;
with MJ.Equality_Geometry;
with MJ.Equality_Scalar;
with MJ.Constrained_Kernels;
with MJ.Data.Pipeline;
with MJ.Joint_Limit_Math;
with MJ.Pose_Arithmetic;
package body MJ.Data.Constrained.Equalities with SPARK_Mode is
   package G renames MJ.Equality_Geometry;
   package Scalar renames MJ.Equality_Scalar;
   package CK renames MJ.Constrained_Kernels;
   use type Interfaces.Unsigned_8, CA.Result;

   function Derivative (Q : G.Quaternion; W : Vector) return G.Quaternion is
     ([0.5*((-W (0)*Q (1) - W (1)*Q (2)) - W (2)*Q (3)),
       0.5*((W (0)*Q (0) + W (1)*Q (3)) - W (2)*Q (2)),
       0.5*((-W (0)*Q (3) + W (1)*Q (0)) + W (2)*Q (1)),
       0.5*((W (0)*Q (2) - W (1)*Q (1)) + W (2)*Q (0))]);

   function Conjugate (Q : G.Quaternion) return G.Quaternion is
     ([Q (0), -Q (1), -Q (2), -Q (3)]);

   procedure Bias (P : in out Equality_Description; B0, B1 : Body_State;
                   Point0, Point1 : G.Vector; A, B : G.Quaternion) is
      V0 : constant Vector := MJ.Pose_Arithmetic.Anchor_Bias
        (B0.Linear_Bias, B0.Angular_Bias, B0.Angular_Velocity, Vector (Point0)-B0.Position);
      V1 : constant Vector := MJ.Pose_Arithmetic.Anchor_Bias
        (B1.Linear_Bias, B1.Angular_Bias, B1.Angular_Velocity, Vector (Point1)-B1.Position);
      W : constant Vector := B0.Angular_Velocity-B1.Angular_Velocity;
      D : constant Vector := B0.Angular_Bias-B1.Angular_Bias;
      Qdot0, Qdot1, T1, T2, T3 : G.Quaternion;
   begin
      for I in 0 .. 2 loop P.Jdot_V (I+1) := V0 (I)-V1 (I); end loop;
      if P.Weld then
         Qdot0 := (if P.Site then Derivative (A, B0.Angular_Velocity)
           else G.Multiply (Derivative (G.Quaternion (B0.Orientation), B0.Angular_Velocity), G.Quaternion (P.Local0)));
         Qdot1 := Conjugate (Derivative (B, B1.Angular_Velocity));
         T1 := G.Multiply (G.Multiply (Qdot1, [0.0, W (0), W (1), W (2)]), A);
         T2 := G.Multiply (G.Multiply (Conjugate (B), [0.0, D (0), D (1), D (2)]), A);
         T3 := G.Multiply (G.Multiply (Conjugate (B), [0.0, W (0), W (1), W (2)]), Qdot0);
         for I in 1 .. 3 loop
            P.Jdot_V (I+3) := (0.5*((T1 (I)+T2 (I))+T3 (I)))*P.Torque;
         end loop;
      end if;
   end Bias;

   procedure Initialize_Scalar
     (M : MJ.Models.Model; E : in out Engine; Id : Natural; Result : out Status) is
      P : Equality_Description renames E.Equalities (Id);
      Q0, Q1, V0, V1 : Natural;
   begin
      Result := Unsupported_Feature;
      P.Object0 := M.Equalities.Eq_Obj1id (Id);
      P.Object1 := M.Equalities.Eq_Obj2id (Id);
      P.Reference1 := 0.0;
      for K in P.Polynomial'Range loop
         if M.Equalities.Eq_Data (11*Id+K) not in Tier0_Real then return; end if;
         P.Polynomial (K) := M.Equalities.Eq_Data (11*Id+K);
      end loop;
      if P.Kind = 2 then
         if E.Joints (P.Object0).Kind not in Slide | Hinge
           or else (P.Object1 >= 0 and then E.Joints (P.Object1).Kind not in Slide | Hinge)
         then return; end if;
         Q0 := E.Joints (P.Object0).Qadr;
         V0 := E.Joints (P.Object0).Vadr;
         if M.Qpos.Qpos0 (Q0) not in Tier0_Real then return; end if;
         P.Reference0 := M.Qpos.Qpos0 (Q0);
         P.Scalar_Weight := E.Dofs (V0).Weight;
         P.Width := 1;
         P.Columns (1) := V0;
         if P.Object1 >= 0 then
            Q1 := E.Joints (P.Object1).Qadr;
            V1 := E.Joints (P.Object1).Vadr;
            if M.Qpos.Qpos0 (Q1) not in Tier0_Real then return; end if;
            P.Reference1 := M.Qpos.Qpos0 (Q1);
            P.Scalar_Weight := P.Scalar_Weight + E.Dofs (V1).Weight;
            if V0 /= V1 then
               P.Width := 2;
               P.Columns (1) := Natural'Min (V0, V1);
               P.Columns (2) := Natural'Max (V0, V1);
            end if;
         end if;
      else
         if M.Tendons.Tendon_Length0 (P.Object0) not in Tier0_Real then return; end if;
         P.Reference0 := M.Tendons.Tendon_Length0 (P.Object0);
         P.Scalar_Weight := E.Tendons (P.Object0).Weight;
         if P.Object1 >= 0 then
            if M.Tendons.Tendon_Length0 (P.Object1) not in Tier0_Real then return; end if;
            P.Reference1 := M.Tendons.Tendon_Length0 (P.Object1);
            P.Scalar_Weight := P.Scalar_Weight + E.Tendons (P.Object1).Weight;
         end if;
         declare
            T0 : Tendon_Description renames E.Tendons (P.Object0);
            First1 : constant Natural := (if P.Object1 >= 0 then E.Tendons (P.Object1).First else 0);
            Width1 : constant Natural := (if P.Object1 >= 0 then E.Tendons (P.Object1).Width else 0);
            K0, K1 : Natural := 0;
            C0, C1, Column : Natural;
         begin
            --  Merge the immutable CSR structure once. The maps retain shared
            --  columns and structural zeros; each step only reads cached J.
            P.Width := 0;
            while K0 < T0.Width or else K1 < Width1 loop
               C0 := (if K0 < T0.Width then E.Tendon_Columns (T0.First+K0+1) else Max_V);
               C1 := (if K1 < Width1 then E.Tendon_Columns (First1+K1+1) else Max_V);
               Column := Natural'Min (C0, C1);
               if P.Width = Max_V then Result := Capacity_Exceeded; return; end if;
               P.Width := P.Width+1;
               P.Columns (P.Width) := Column;
               P.Map0 (P.Width) := (if C0 = Column then T0.First+K0+1 else 0);
               P.Map1 (P.Width) := (if C1 = Column then First1+K1+1 else 0);
               if C0 = Column then K0 := K0+1; end if;
               if C1 = Column then K1 := K1+1; end if;
            end loop;
         end;
      end if;
      Result := Success;
   end Initialize_Scalar;

   procedure Initialize
     (M : MJ.Models.Model; E : in out Engine; Result : out Status;
      Allow_Flex : Boolean := False) is
   begin
      E.Ne := 0;
      Result := Capacity_Exceeded;
      if M.S.Neq > Max_R then return; end if;
      Result := Unsupported_Feature;
      for Id in 0 .. M.S.Neq - 1 loop
         declare
            P : Equality_Description renames E.Equalities (Id);
            Obj0 : constant Integer := M.Equalities.Eq_Obj1id (Id);
            Obj1 : constant Integer := M.Equalities.Eq_Obj2id (Id);
            A, B : Integer;
            Reverse_Chain : CA.Column_Array (1 .. Max_V);
         begin
            Result := Unsupported_Feature;
            if M.Equalities.Eq_Type (Id) not in 0 .. 6
              or else (M.Equalities.Eq_Type (Id) >= 4 and then not Allow_Flex)
            then return; end if;
            P.Kind := M.Equalities.Eq_Type (Id);
            P.Weld := M.Equalities.Eq_Type (Id) = 1;
            P.Site := M.Equalities.Eq_Objtype (Id) = 6;
            P.Active := M.Equalities.Eq_Active0 (Id) /= 0;
            P.Params := Parameters (M.Equalities.Eq_Solref.all, M.Equalities.Eq_Solimp.all, Id);
            P.Width := 0; P.First_Row := 0; P.Position_Norm := 0.0;
            P.Jdot_V := [others => 0.0];
            if P.Kind >= 4 then
               if Obj0 not in 0 .. M.S.Nflex-1 then
                  Result := Invalid_Model; return;
               end if;
               --  Keep the original source ID and activity. The specialized
               --  producer owns the rows; no rigid body chain is fabricated.
               P.Object0 := Obj0; P.Object1 := Obj1;
            elsif P.Kind in 2 .. 3 then
               Initialize_Scalar (M, E, Id, Result);
               if Result /= Success then return; end if;
            else
            if M.Equalities.Eq_Objtype (Id) not in 1 | 6 then return; end if;
            if M.Equalities.Eq_Data (11*Id+10) not in Tier0_Real then return; end if;
            P.Torque := M.Equalities.Eq_Data (11*Id+10);
            if P.Site then
               P.Body0 := M.Sites.Site_Bodyid (Obj0);
               P.Body1 := M.Sites.Site_Bodyid (Obj1);
               P.Anchor0 := Read_Vector (M.Sites.Site_Pos.all, 3*Obj0);
               P.Anchor1 := Read_Vector (M.Sites.Site_Pos.all, 3*Obj1);
               P.Local0 := Read_Quaternion (M.Sites.Site_Quat.all, 4*Obj0);
               P.Local1 := Read_Quaternion (M.Sites.Site_Quat.all, 4*Obj1);
            else
               P.Body0 := Obj0; P.Body1 := Obj1;
               P.Anchor0 := Read_Vector (M.Equalities.Eq_Data.all, 11*Id + (if P.Weld then 3 else 0));
               P.Anchor1 := Read_Vector (M.Equalities.Eq_Data.all, 11*Id + (if P.Weld then 0 else 3));
               P.Local0 := (if P.Weld then Read_Quaternion (M.Equalities.Eq_Data.all, 11*Id+6)
                            else Identity_Quaternion);
               P.Local1 := Identity_Quaternion;
            end if;
            --  Equality chains include common ancestors (mj_jacDifPair skipcommon=0).
            --  The topology is immutable, so compute its union only at creation.
            P.Width := 0; P.First_Row := 0; P.Position_Norm := 0.0;
            A := E.Bodies (P.Body0).Leaf; B := E.Bodies (P.Body1).Leaf;
            while A >= 0 or else B >= 0 loop
               P.Width := P.Width + 1;
               if A = B then
                  Reverse_Chain (P.Width) := A;
                  A := E.Dofs (A).Parent; B := A;
               elsif A > B then
                  Reverse_Chain (P.Width) := A; A := E.Dofs (A).Parent;
               else
                  Reverse_Chain (P.Width) := B; B := E.Dofs (B).Parent;
               end if;
            end loop;
            for K in 1 .. P.Width loop P.Columns (K) := Reverse_Chain (P.Width-K+1); end loop;
            end if;
         end;
      end loop;
      E.Ne := M.S.Neq; Result := Success;
   end Initialize;

   procedure Assemble_Scalar (E : in out Engine; Id : Natural; Result : out Status) is
      P : Equality_Description renames E.Equalities (Id);
      P0, P1 : Real;
      Values : Scalar.Geometry;
      J : CA.Matrix (1 .. 1, 1 .. P.Width);
      Pos : CA.Parameter_Array (1 .. 1);
      J0, J1, Combined : Real;
      S : CA.Result;
   begin
      Result := Numeric_Limit;
      P0 := (if P.Kind = 2 then E.D.State.Qpos (E.Joints (P.Object0).Qadr)
             else Tendon_Value (E.D, P.Object0, 0));
      P1 := (if P.Object1 < 0 then 0.0
             elsif P.Kind = 2 then E.D.State.Qpos (E.Joints (P.Object1).Qadr)
             else Tendon_Value (E.D, P.Object1, 0));
      if P0 not in Tier0_Real or else P1 not in Tier0_Real then return; end if;
      Values := Scalar.Evaluate (P0, P.Reference0, P1, P.Reference1,
                                 P.Polynomial, P.Object1 >= 0);
      if Values.Position not in Tier1_Real then return; end if;
      Pos (1) := (Values.Position, 0.0);
      for K in 1 .. P.Width loop
         if P.Kind = 2 then
            J0 := (if P.Columns (K) = E.Joints (P.Object0).Vadr then 1.0 else 0.0);
            J1 := (if P.Object1 >= 0 and then P.Columns (K) = E.Joints (P.Object1).Vadr then 1.0 else 0.0);
         else
            J0 := (if P.Map0 (K) = 0 then 0.0 else E.Tendon_J (P.Map0 (K)));
            J1 := (if P.Map1 (K) = 0 then 0.0 else E.Tendon_J (P.Map1 (K)));
         end if;
         Combined := (if P.Object1 >= 0 then Scalar.Jacobian (J0, J1, Values.Derivative) else J0);
         if Combined not in Tier2_Real then return; end if;
         J (1, K) := Combined;
      end loop;
      --  C uses the signed scalar error here; response takes its magnitude.
      --  It does not add a Jdot*v correction for joint/tendon equality rows.
      P.Position_Norm := Values.Position;
      P.First_Row := E.Rows.Rows+1;
      CA.Append (E.Rows, CA.Equality, Id, P.Columns (1 .. P.Width), J, Pos, 0.0, S);
      Result := (if S = CA.Success then Success else Capacity_Exceeded);
   end Assemble_Scalar;

   procedure Prepare (E : in out Engine; Result : out Status) is
   begin
      Result := Success;
      if E.Ne = 0 or else Disabled (E.Flags, Dsbl_Equality) then return; end if;
      if (for some P of E.Equalities (0 .. E.Ne-1) =>
        P.Active and then P.Width > 0 and then P.Kind in 0 .. 1)
      then
         Pipeline.Ensure_Jacobians (E.D, Result);
         if Result /= Success then return; end if;
         Pipeline.Ensure_Cartesian_Motion (E.D, Result);
         if Result /= Success then return; end if;
      end if;
   end Prepare;

   procedure Assemble_One (E : in out Engine; Id : Natural; Result : out Status) is
   begin
      Result := Invalid_Index;
      if Id >= E.Ne then return; end if;
      Result := Success;
      if Disabled (E.Flags, Dsbl_Constraint) or else Disabled (E.Flags, Dsbl_Equality)
        or else not E.Equalities (Id).Active then return; end if;
      --  Never silently omit an active flex equality on the ordinary path,
      --  including after a runtime activation of an initially inactive row.
      if E.Equalities (Id).Kind >= 4 then Result := Unsupported_Feature; return; end if;
      if E.Equalities (Id).Width = 0 then return; end if;
      if E.Equalities (Id).Kind in 2 .. 3 then
         Assemble_Scalar (E, Id, Result);
         return;
      end if;
      declare
         P : Equality_Description renames E.Equalities (Id);
         B0 : Body_State renames E.D.Kinematic.Bodies (P.Body0);
         B1 : Body_State renames E.D.Kinematic.Bodies (P.Body1);
         Rows : constant Positive := (if P.Weld then 6 else 3);
         Point0 : constant G.Vector := G.Anchor (G.Rotation (B0.Rotation), G.Vector (P.Anchor0), G.Vector (B0.Position));
         Point1 : constant G.Vector := G.Anchor (G.Rotation (B1.Rotation), G.Vector (P.Anchor1), G.Vector (B1.Position));
         Offset0 : constant Vector := Vector (Point0) - B0.Center;
         Offset1 : constant Vector := Vector (Point1) - B1.Center;
         J0, J1, J : CA.Matrix (1 .. Rows, 1 .. P.Width);
         Pos : CA.Parameter_Array (1 .. Rows);
         A, B : G.Quaternion := G.Identity;
         Sum : Real;
         S : CA.Result;
      begin
         for K in 1 .. P.Width loop
            declare
               O0 : constant Natural := Jacobian_Offset (E.D, P.Body0, P.Columns (K));
               O1 : constant Natural := Jacobian_Offset (E.D, P.Body1, P.Columns (K));
               L0 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O0);
               L1 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O1);
               W0 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O0);
               W1 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O1);
            begin
               for X in 0 .. 2 loop
                  J0 (X+1, K) := CK.Point_Component (L0 (X), W0 ((X+1) mod 3), W0 ((X+2) mod 3),
                    Offset0 ((X+1) mod 3), Offset0 ((X+2) mod 3));
                  J1 (X+1, K) := CK.Point_Component (L1 (X), W1 ((X+1) mod 3), W1 ((X+2) mod 3),
                    Offset1 ((X+1) mod 3), Offset1 ((X+2) mod 3));
                  if P.Weld then J0 (X+4, K) := W0 (X); J1 (X+4, K) := W1 (X); end if;
               end loop;
            end;
         end loop;
         if P.Weld then
            A := G.Multiply (G.Quaternion (B0.Orientation), G.Quaternion (P.Local0));
            B := (if P.Site then G.Multiply (G.Quaternion (B1.Orientation), G.Quaternion (P.Local1))
                  else G.Quaternion (B1.Orientation));
            G.Weld (Point0, Point1, A, B, P.Torque, J0, J1, J, Pos);
            --  mju_norm: four lanes, horizontal reduction, then two-element tail.
            Sum := ((Pos (1).Position**2 + Pos (3).Position**2)
                    + (Pos (2).Position**2 + Pos (4).Position**2))
                   + (Pos (5).Position**2 + Pos (6).Position**2);
         else
            G.Connect (Point0, Point1, J0, J1, J, Pos);
            Sum := (Pos (1).Position**2 + Pos (2).Position**2) + Pos (3).Position**2;
         end if;
         --  C computes one impedance from the norm of the entire block.
         P.Position_Norm := MJ.Joint_Limit_Math.Sqrt (Sum);
         Bias (P, B0, B1, Point0, Point1, A, B);
         P.First_Row := E.Rows.Rows+1;
         CA.Append (E.Rows, CA.Equality, Id, P.Columns (1 .. P.Width), J, Pos, 0.0, S);
         if S /= CA.Success then Result := Capacity_Exceeded; return; end if;
      end;
      Result := Success;
   end Assemble_One;

   procedure Assemble (E : in out Engine; Result : out Status) is
   begin
      Result := Success;
      if Disabled (E.Flags, Dsbl_Constraint) then return; end if;
      Prepare (E, Result);
      if Result /= Success then return; end if;
      for Id in 0 .. E.Ne-1 loop
         Assemble_One (E, Id, Result);
         if Result /= Success then return; end if;
      end loop;
   end Assemble;
end MJ.Data.Constrained.Equalities;
