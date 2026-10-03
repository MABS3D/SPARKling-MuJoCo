with MJ.Adhesion;
with MJ.Constrained_Kernels;
with MJ.Data.Inertia_Phase;
with MJ.Data.Manifold_Actuation;

package body MJ.Data.Constrained.Body_Adhesion with SPARK_Mode is
   use type CA.Cone_Kind;
   package A renames MJ.Adhesion;
   package CK renames MJ.Constrained_Kernels;

   function Gap_Normal (E : Engine; C : MJ.Full_Contacts.Full_Contact)
     return A.Moment_Array is
      B1 : constant Natural := E.Geoms (C.Geoms.First).Body_Id;
      B2 : constant Natural := E.Geoms (C.Geoms.Second).Body_Id;
      R1 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B1).Center;
      R2 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B2).Center;
      Out_J : A.Moment_Array (0 .. E.D.Nv - 1);
   begin
      for V in Out_J'Range loop
         declare
            O1 : constant Natural := Jacobian_Offset (E.D, B1, V);
            O2 : constant Natural := Jacobian_Offset (E.D, B2, V);
            W1 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O1);
            W2 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O2);
            L1 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O1);
            L2 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O2);
            Linear : Vector;
         begin
            for X in 0 .. 2 loop
               Linear (X) := CK.Point_Component
                 (L2 (X), W2 ((X+1) mod 3), W2 ((X+2) mod 3),
                  R2 ((X+1) mod 3), R2 ((X+2) mod 3))
                 - CK.Point_Component
                 (L1 (X), W1 ((X+1) mod 3), W1 ((X+2) mod 3),
                  R1 ((X+1) mod 3), R1 ((X+2) mod 3));
            end loop;
            Out_J (V) := CK.Frame_Component
              (Linear (0), Linear (1), Linear (2), C.Frame (0), C.Frame (1), C.Frame (2));
         end;
      end loop;
      return Out_J;
   end Gap_Normal;

   -- C compresses zero moment entries before its four-lane sparse dot.
   function Sparse_Velocity (Moment : A.Moment_Array; Velocity : Real_Array) return Real is
      Terms : Real_Array (0 .. Moment'Length - 1);
      N : Natural := 0;
      R0, R1, R2, R3 : Real := 0.0;
      K : Natural := 0;
   begin
      for V in Moment'Range loop
         if Moment (V) /= 0.0 then
            Terms (N) := Moment (V) * Velocity (V);
            N := N + 1;
         end if;
      end loop;
      while K + 3 < N loop
         R0 := R0 + Terms (K); R1 := R1 + Terms (K+1);
         R2 := R2 + Terms (K+2); R3 := R3 + Terms (K+3);
         K := K + 4;
      end loop;
      R0 := ((R0 + R1) + R2) + R3;
      while K < N loop R0 := R0 + Terms (K); K := K + 1; end loop;
      return R0;
   end Sparse_Velocity;

   procedure Apply
     (E : in out Engine; Result : out Status;
      External : MJ.External_Forces.Wrench_Array) is
      Nv : constant Natural := E.D.Nv;
      Nr : constant Natural := E.Rows.Rows;
      Nc : constant Natural := E.T.Ncontact;
      Contacts : A.Contact_Array (0 .. Nc - 1);
      J : A.Jacobian (0 .. Nr - 1, 0 .. Nv - 1) := [others => [others => 0.0]];
      Gap_J : A.Jacobian (0 .. Nc - 1, 0 .. Nv - 1) := [others => [others => 0.0]];
      Moment : A.Moment_Array (0 .. Nv - 1);
      Force : A.Force_Array (0 .. Nv - 1);
      Combined : Real_Array (0 .. Nv - 1) := [others => 0.0];
      Cone : constant A.Cone := (if E.Cone = CA.Pyramidal then A.Pyramidal else A.Elliptic);
      Speed : Real;
   begin
      Result := Numeric_Limit;
      E.T.Adhesion_Force (1 .. Nv) := [others => 0.0];
      for R in 1 .. Nr loop
         for K in E.Rows.Descriptors (R).Offset + 1 ..
           E.Rows.Descriptors (R).Offset + E.Rows.Descriptors (R).Nonzeros loop
            if E.Rows.Values (K) not in Tier0_Real then return; end if;
            J (R-1, E.Rows.Columns (K)) := E.Rows.Values (K);
         end loop;
      end loop;
      for Id in Contacts'Range loop
         declare
            C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
         begin
            Contacts (Id) :=
              (Rigid_Geoms => E.Endpoints (Id).Geom0 >= 0 and then E.Endpoints (Id).Geom1 >= 0,
               Body1 => E.Endpoints (Id).Body0,
               Body2 => E.Endpoints (Id).Body1,
               Exclude => (if C.Excluded then 1 elsif C.Efc_Address < 0 then 3 else 0),
               Dim => C.Dim, Address => Integer'Max (0, C.Efc_Address));
            if Contacts (Id).Rigid_Geoms and then C.Excluded then
               Moment := Gap_Normal (E, C);
               for V in Moment'Range loop
                  if Moment (V) not in Tier0_Real then return; end if;
                  Gap_J (Id, V) := Moment (V);
               end loop;
            end if;
         end;
      end loop;
      for Id in E.D.Actuator_Config'Range loop
         declare
            C : Actuator_Parameters renames E.D.Actuator_Config (Id);
            F : constant Real := E.D.Actuators.Force (Id);
         begin
            if C.Body_Transmission then
               A.Project (Contacts, C.Body_Id, Cone, J, Gap_J, Moment);
               for V in Moment'Range loop E.Body_Moments (Id+1, V+1) := Moment (V); end loop;
               Speed := Sparse_Velocity (Moment, E.D.State.Qvel.all);
               if Speed not in Tier0_Real or else F not in Tier0_Real then return; end if;
               E.D.Actuators.Length (Id) := 0.0;
               E.D.Actuators.Velocity (Id) := (if E.D.Actuation_Enabled then Speed else 0.0);
               A.Apply_Force (Moment, F, Force);
               for V in Force'Range loop
                  Combined (V) := Combined (V) + Force (V);
                  E.T.Adhesion_Force (V+1) := E.T.Adhesion_Force (V+1) + Force (V);
               end loop;
            else
               -- Keep the C actuator-row order when ordinary and adhesive
               -- transmissions are interleaved: do not regroup all body
               -- forces after a separately reduced motor force vector.
               declare
                  M : constant MJ.Data.Manifold_Actuation.Moment :=
                    MJ.Data.Manifold_Actuation.Transmission_Moment (C, E.D.State.Qpos.all);
                  Width : constant Natural :=
                    (if C.Joint_Type = 0 then 6 elsif C.Joint_Type = 1 then 3 else 1);
               begin
                  for K in 0 .. Width - 1 loop
                     Combined (C.Joint_Id+K) := Combined (C.Joint_Id+K) + M (K) * F;
                  end loop;
               end;
            end if;
         end;
      end loop;
      if (for some X of Combined => abs X > 1.0e50) then return; end if;
      E.D.Dynamics.Actuator.all := Combined;
      E.D.Cache.Force_Valid := False;
      -- Rebuild the complete smooth RHS, preserving external body loads and
      -- passive/motor contributions; solve before the constraint response.
      MJ.Data.Inertia_Phase.Solve_Acceleration (E.D, Result, External);
   end Apply;
end MJ.Data.Constrained.Body_Adhesion;
