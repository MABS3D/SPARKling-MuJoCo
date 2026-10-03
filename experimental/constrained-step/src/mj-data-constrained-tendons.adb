with Interfaces;
with MJ.Tendon_Constraint_Kernels;
with MJ.Spatial_Tendons;
with MJ.Tendon_Vectors;
with MJ.Data.Pipeline;

package body MJ.Data.Constrained.Tendons with SPARK_Mode is
   package TC renames MJ.Tendon_Constraint_Kernels;
   package ST renames MJ.Spatial_Tendons;
   package TV renames MJ.Tendon_Vectors;
   use type ST.Evaluation_Status, CA.Result, CA.Limit_Side;
   use type Interfaces.Unsigned_8;

   function Enabled (E : Engine; P : Tendon_Description) return Boolean is
     (not Disabled (E.Flags, Dsbl_Constraint) and then
       ((P.Loss > 0.0 and then not Disabled (E.Flags, Dsbl_Frictionloss))
        or else (P.Is_Limited and then not Disabled (E.Flags, Dsbl_Limit))
        or else (P.Required_By_Equality and then not Disabled (E.Flags, Dsbl_Equality))));

   procedure Initialize (M : MJ.Models.Model; E : in out Engine; Result : out Status) is
      Column : Integer;
   begin
      Result := Invalid_Model;
      E.Nt := 0; E.Tendon_Entries := 0;
      if M.S.Ntendon > Max_T then Result := Capacity_Exceeded; return; end if;
      for T in 0 .. M.S.Ntendon - 1 loop
         declare
            First : constant Integer := M.Tendons.Ten_J_Rowadr (T);
            Width : constant Integer := M.Tendons.Ten_J_Rownnz (T);
            Previous : Integer := -1;
            P : Tendon_Description renames E.Tendons (T);
         begin
            if M.Tendons.Tendon_Range (2*T) not in Tier0_Real
              or else M.Tendons.Tendon_Range (2*T+1) not in Tier0_Real
              or else M.Tendons.Tendon_Margin (T) not in Tier0_Real
              or else M.Tendons.Tendon_Frictionloss (T) not in Nonneg_Tier0
              or else M.Tendons.Tendon_Invweight0 (T) not in Nonneg_Tier0
              or else First < 0 or else Width < 0
              or else First > M.S.Njten - Width then return; end if;
            P := (First => E.Tendon_Entries, Width => 0,
              Is_Limited => M.Tendons.Tendon_Limited (T) /= 0,
              Required_By_Equality => (for some Eq in 0 .. M.S.Neq - 1 =>
                M.Equalities.Eq_Type (Eq) = 3 and then
                  (M.Equalities.Eq_Obj1id (Eq) = T or else M.Equalities.Eq_Obj2id (Eq) = T)),
              Low => M.Tendons.Tendon_Range (2*T), High => M.Tendons.Tendon_Range (2*T+1),
              Margin => M.Tendons.Tendon_Margin (T),
              Loss => M.Tendons.Tendon_Frictionloss (T), Weight => M.Tendons.Tendon_Invweight0 (T),
              Limit_Params => (if M.Tendons.Tendon_Limited (T) /= 0
                and then not Disabled (M.Opt.Disableflags, Dsbl_Constraint)
                and then not Disabled (M.Opt.Disableflags, Dsbl_Limit)
                then Parameters (M.Tendons.Tendon_Solref_Lim.all, M.Tendons.Tendon_Solimp_Lim.all, T) else (others => <>)),
              Friction_Params => (if M.Tendons.Tendon_Frictionloss (T) > 0.0
                and then not Disabled (M.Opt.Disableflags, Dsbl_Constraint)
                and then not Disabled (M.Opt.Disableflags, Dsbl_Frictionloss)
                then Parameters (M.Tendons.Tendon_Solref_Fri.all, M.Tendons.Tendon_Solimp_Fri.all, T) else (others => <>)));
            if P.Is_Limited and then P.Low > P.High then return; end if;
            --  The CSR assembler and dense solver require unique columns.
            --  C's duplicate-column sparse solver path is not equivalent to
            --  canonicalization across a complete trajectory. Reject enabled
            --  constraint rows explicitly; repeated passive-only tendons stay
            --  in the existing smooth scope.
            for K in 0 .. Width - 1 loop
               Column := M.Tendons.Ten_J_Colind (First + K);
               if Column < Previous or else Column not in 0 .. M.S.Nv - 1 then return; end if;
               if Column = Previous
                 and then not Disabled (M.Opt.Disableflags, Dsbl_Constraint)
                 and then ((P.Is_Limited and then not Disabled (M.Opt.Disableflags, Dsbl_Limit))
                   or else (P.Loss > 0.0 and then not Disabled (M.Opt.Disableflags, Dsbl_Frictionloss))
                   or else (P.Required_By_Equality and then not Disabled (M.Opt.Disableflags, Dsbl_Equality))) then
                  Result := Unsupported_Feature; return;
               end if;
               if Column /= Previous then
                  if E.Tendon_Entries = Max_T_Entries then Result := Capacity_Exceeded; return; end if;
                  E.Tendon_Entries := E.Tendon_Entries + 1;
                  E.Tendon_Columns (E.Tendon_Entries) := Column;
                  P.Width := P.Width + 1;
               end if;
               Previous := Column;
            end loop;
         end;
      end loop;
      E.Nt := M.S.Ntendon; Result := Success;
   end Initialize;

   procedure Update (E : in out Engine; Result : out Status) is
      Nv : constant Natural := E.D.Nv;
      Nb : constant Natural := E.D.Nb;
   begin
      Result := Success;
      if E.Nt = 0 or else not (for some P of E.Tendons (0 .. E.Nt - 1) => Enabled (E, P)) then return; end if;
      if E.D.Tendons = null then Result := Invalid_Model; return; end if;
      if E.D.Tendons.Has_Spatial then
         Pipeline.Ensure_Jacobians (E.D, Result);
         if Result /= Success then return; end if;
      end if;
      Result := Numeric_Limit;
      declare
         Sites : ST.Site_Array (0 .. E.D.Tendons.Ns - 1) := E.D.Tendons.Sites;
         Geoms : ST.Geometry_Array (0 .. E.D.Tendons.Ng - 1) := E.D.Tendons.Geometries;
         Origins : ST.Vector_Array (0 .. Nb - 1);
         Rotation : TV.Matrix;
         Position, V : TV.Vector;
         B : Natural;
      begin
         if E.D.Tendons.Has_Spatial then
            for Body_Id in Origins'Range loop
               Origins (Body_Id) := TV.Vector (E.D.Kinematic.Bodies (Body_Id).Center);
            end loop;
            for I in Sites'Range loop
               B := Sites (I).Body_Id;
               Position := TV.Vector (E.D.Kinematic.Bodies (B).Position);
               for A in 1 .. 3 loop
                  for C in 1 .. 3 loop Rotation (A,C) := E.D.Kinematic.Bodies (B).Rotation (A-1,C-1); end loop;
               end loop;
               if not TV.Rotation_Bounded (Rotation) or else not TV.Bounded (Position, 1.0e10) then return; end if;
               Sites (I).Position := TV.Add (Position, TV.Multiply (Rotation, Sites (I).Position));
            end loop;
            for I in Geoms'Range loop
               B := Geoms (I).Body_Id;
               Position := TV.Vector (E.D.Kinematic.Bodies (B).Position);
               for A in 1 .. 3 loop
                  for C in 1 .. 3 loop Rotation (A,C) := E.D.Kinematic.Bodies (B).Rotation (A-1,C-1); end loop;
               end loop;
               if not TV.Rotation_Bounded (Rotation) or else not TV.Bounded (Position, 1.0e10) then return; end if;
               Geoms (I).Position := TV.Add (Position, TV.Multiply (Rotation, Geoms (I).Position));
               for C in 1 .. 3 loop
                  V := TV.Multiply (Rotation, (Geoms (I).Orientation (1,C), Geoms (I).Orientation (2,C), Geoms (I).Orientation (3,C)));
                  for A in 1 .. 3 loop Geoms (I).Orientation (A,C) := V (A); end loop;
               end loop;
            end loop;
            if not ST.Valid_Flat_Kinematics (Sites, Geoms, Origins,
              E.D.Kinematic.Linear_Jacobian.all, E.D.Kinematic.Angular_Jacobian.all, Nv) then return; end if;
         end if;
         for T in 0 .. E.Nt - 1 loop
            if Enabled (E, E.Tendons (T)) then
               declare
                  P : constant MJ.Spatial_Tendon_Models.Parameters := E.D.Tendons.Tendons (T+1);
                  C : constant Tendon_Description := E.Tendons (T);
                  Row : Real_Array (0 .. Nv - 1) := [others => 0.0];
                  Length : Real;
                  Points : ST.Point_Array (0 .. 3*P.Count - 1);
                  Count : Natural;
                  Eval : ST.Evaluation_Status;
                  Route : constant ST.Route_Array (0 .. P.Count - 1) := E.D.Tendons.Nodes (P.First+1 .. P.First+P.Count);
               begin
                  if P.Fixed then
                     for Term of E.D.Tendons.Jacobian (P.First+1 .. P.First+P.Jacobian_Count) loop
                        Row (Term.Dof) := Row (Term.Dof) + Term.Coefficient;
                     end loop;
                  else
                     if not ST.Valid_Path (Route, Sites, Geoms) then return; end if;
                     ST.Evaluate_Flat (Route, Sites, Geoms, Origins,
                       E.D.Kinematic.Linear_Jacobian.all, E.D.Kinematic.Angular_Jacobian.all,
                       Eval, Length, Row, Points, Count);
                     if Eval /= ST.Success then return; end if;
                  end if;
                  for K in 1 .. C.Width loop
                     if Row (E.Tendon_Columns (C.First+K)) not in Tier2_Real then return; end if;
                     E.Tendon_J (C.First+K) := Row (E.Tendon_Columns (C.First+K));
                  end loop;
                  if Tendon_Value (E.D, T, 0) not in Tier0_Real then return; end if;
               end;
            end if;
         end loop;
      end;
      Result := Success;
   end Update;

   procedure Add_Friction (E : in out Engine; Result : out Status) is
      S : CA.Result;
   begin
      Result := Success;
      if Disabled (E.Flags, Dsbl_Frictionloss) then return; end if;
      for T in 0 .. E.Nt - 1 loop
         if E.Tendons (T).Loss > 0.0 then
         declare
            P : constant Tendon_Description := E.Tendons (T);
            Chain : constant CA.Column_Array (1 .. P.Width) := E.Tendon_Columns (P.First+1 .. P.First+P.Width);
            Values : constant CA.Value_Array (1 .. P.Width) := E.Tendon_J (P.First+1 .. P.First+P.Width);
         begin
            TC.Add_Friction (E.Rows, T, Chain, Values, P.Loss, S);
            if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
         end;
         end if;
      end loop;
   end Add_Friction;

   procedure Add_Limits (E : in out Engine; Result : out Status) is
      S : CA.Result;
   begin
      Result := Success;
      if Disabled (E.Flags, Dsbl_Limit) then return; end if;
      for T in 0 .. E.Nt - 1 loop
         if E.Tendons (T).Is_Limited then
            declare
               P : constant Tendon_Description := E.Tendons (T);
               Chain : constant CA.Column_Array (1 .. P.Width) := E.Tendon_Columns (P.First+1 .. P.First+P.Width);
               Values : constant CA.Value_Array (1 .. P.Width) := E.Tendon_J (P.First+1 .. P.First+P.Width);
               Length : constant Tier0_Real := Tendon_Value (E.D, T, 0);
            begin
               for Side in CA.Limit_Side loop
                  TC.Add_Limit (E.Rows, T, Chain, Values, Length,
                    (if Side = CA.Lower then P.Low else P.High), P.Margin, Side, S);
                  if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
               end loop;
            end;
         end if;
      end loop;
   end Add_Limits;
end MJ.Data.Constrained.Tendons;
