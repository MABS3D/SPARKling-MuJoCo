with MJ.Data.Inertia_Phase;
with MJ.Owned_Step_Publication;
with MJ.Constrained_Kernels;
with MJ.Manifold_Math;
package body MJ.Data.Constrained.Sensors with SPARK_Mode is
   use type CA.Constraint_Kind;
   package DS renames MJ.Data.Sensors;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine;
                     S : in out Context; Result : out Status) is
      Flags : constant Integer := M.Opt.Disableflags;
   begin
      if Ready (E) or else DS.Ready (S) then Result := Already_Allocated; return; end if;
      DS.Initialize (M, S, Result); if Result /= Success then return; end if;
      if (Flags / Dsbl_Sensor) mod 2 = 0 then M.Opt.Disableflags := Flags + Dsbl_Sensor; end if;
      MJ.Data.Constrained.Create (M, E, Result);
      M.Opt.Disableflags := Flags;
      if Result /= Success then DS.Free (S); end if;
   exception when others => M.Opt.Disableflags := Flags; DS.Free (S); raise;
   end Create;
   procedure Evaluate (E : in out Engine; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Limits : DS.Limit_Array (0 .. Max_R - 1);
      Contacts : DS.Contact_Array (0 .. Max_C - 1);
      N : Natural := 0;
   begin
      DS.Invalidate (S); if not DS.Ready (S) then Result := Not_Allocated; return; end if;
      MJ.Data.Constrained.Evaluate (E, Result, External); if Result /= Success then return; end if;
      for R in 1 .. E.Rows.Rows loop
         declare H : CA.Row renames E.Rows.Descriptors (R); V : Real := 0.0; begin
            if H.Kind in CA.Limit_Joint | CA.Limit_Tendon then
               for K in H.Offset + 1 .. H.Offset + H.Nonzeros loop
                  V := V + E.Rows.Values (K) * E.D.State.Qvel (E.Rows.Columns (K));
               end loop;
               Limits (N) := (H.Kind = CA.Limit_Tendon, H.Id,
                 H.Param.Position - H.Param.Margin, V, E.T.Force (R)); N := N + 1;
            end if;
         end;
      end loop;
      for Id in 0 .. E.T.Ncontact - 1 loop
         declare
            C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
            Local : array (Natural range 0 .. 5) of Real := [others => 0.0];
            First : constant Integer := C.Efc_Address + 1;
         begin
            Contacts (Id).Body1 := E.Geoms (C.Geoms.First).Body_Id;
            Contacts (Id).Body2 := E.Geoms (C.Geoms.Second).Body_Id;
            Contacts (Id).Geom1 := C.Geoms.First; Contacts (Id).Geom2 := C.Geoms.Second;
            Contacts (Id).Position := Vector (C.Position);
            Contacts (Id).Distance := C.Distance;
            for A in 0 .. 2 loop
               Contacts (Id).Normal (A) := C.Frame (A);
               Contacts (Id).Tangent (A) := C.Frame (3 + A);
            end loop;
            Contacts (Id).Active := First > 0;
            if First > 0 then
               if C.Dim = 1 or else E.Rows.Descriptors (First).Kind = CA.Contact_Elliptic then
                  for I in 0 .. C.Dim - 1 loop Local (I) := E.T.Force (First + I); end loop;
               else
                  for I in 0 .. 2 * (C.Dim - 1) - 1 loop Local (0) := Local (0) + E.T.Force (First + I); end loop;
                  for I in 1 .. C.Dim - 1 loop
                     Local (I) := (E.T.Force (First + 2 * (I - 1)) - E.T.Force (First + 2 * (I - 1) + 1)) * C.Param.Fri (I - 1);
                  end loop;
               end if;
               Contacts (Id).Normal_Force := Local (0);
               for A in 0 .. 2 loop
                  Contacts (Id).Local_Force (A) := Local (A); Contacts (Id).Local_Torque (A) := Local (A + 3);
                  Contacts (Id).Force (A) := (C.Frame (A) * Local (0) + C.Frame (3 + A) * Local (1)) + C.Frame (6 + A) * Local (2);
                  Contacts (Id).Torque (A) := (C.Frame (A) * Local (3) + C.Frame (3 + A) * Local (4)) + C.Frame (6 + A) * Local (5);
               end loop;
            end if;
         end;
      end loop;
      DS.Sample (E.D, S, Result, Limits (0 .. N - 1), Contacts (0 .. E.T.Ncontact - 1), External);
   exception when Constraint_Error => DS.Invalidate (S); Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Next_Time, Value : Real;
      Q : Quaternion;
   begin
      Evaluate (E, S, Result, External); if Result /= Success then return; end if;
      -- Integrate the result already solved and sampled. Calling the ordinary
      -- Step here would solve contacts twice and could change a finite iterate.
      if not E.D.Activation_Can_Advance then Result := Numeric_Limit; DS.Invalidate (S); return; end if;
      MJ.Data.Inertia_Phase.Solve_Euler (E.D, Result);
      if Result /= Success then DS.Invalidate (S); return; end if;
      Result := Numeric_Limit;
      Next_Time := E.D.Clock + E.D.Timestep;
      if Next_Time not in Nonneg_Tier0 then DS.Invalidate (S); return; end if;
      for V in 0 .. E.D.Nv - 1 loop
         Value := MJ.Constrained_Kernels.Velocity_Update (E.D.State.Qvel (V), E.D.Scratch.Solution (V), E.D.Timestep);
         if Value not in Tier0_Real then DS.Invalidate (S); return; end if;
         E.D.Scratch.Next_Qvel (V) := Value;
      end loop;
      E.D.Scratch.Next_Qpos.all := E.D.State.Qpos.all;
      for P of E.D.Joint_Config.all loop
         if P.Group_Type in 2 .. 3 or else (P.Group_Type = 0 and then P.Component < 3) then
            Value := E.D.State.Qpos (P.Qadr) + E.D.Timestep * E.D.Scratch.Next_Qvel (P.Vadr);
            if Value not in Tier0_Real then DS.Invalidate (S); return; end if;
            E.D.Scratch.Next_Qpos (P.Qadr) := Value;
         elsif (P.Group_Type = 1 and then P.Component = 0) or else (P.Group_Type = 0 and then P.Component = 3) then
            Q := MJ.Manifold_Math.Integrated (Read_Quaternion (E.D.State.Qpos.all, P.Qadr),
              Read_Vector (E.D.Scratch.Next_Qvel.all, P.Vadr), E.D.Timestep);
            for K in 0 .. 3 loop
               if Q (K) not in Tier0_Real then DS.Invalidate (S); return; end if;
               E.D.Scratch.Next_Qpos (P.Qadr + K) := Q (K);
            end loop;
         end if;
      end loop;
      MJ.Owned_Step_Publication.Publish (E.D.State.Qpos.all, E.D.State.Qvel.all,
        E.D.Activation (0 .. Integer (E.D.Nactivation) - 1), E.D.Clock,
        E.D.Scratch.Next_Qpos.all, E.D.Scratch.Next_Qvel.all,
        E.D.Next_Activation (0 .. Integer (E.D.Nactivation) - 1), Next_Time);
      Invalidate (E.D.Cache); Result := Success;
   exception when Constraint_Error => DS.Invalidate (S); Result := Numeric_Limit;
   end Step;
end MJ.Data.Constrained.Sensors;
