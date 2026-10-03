with Ada.Unchecked_Deallocation;
with MJ.Models.Validity;
with MJ.Data.Kinematics;
with MJ.Data.Forward;
with MJ.Data.Euler;
package body MJ.Data.Sleeping with SPARK_Mode is
   use type SM.Result;
   use type SM.K.Object_State;
   procedure Release_Topology is new Ada.Unchecked_Deallocation (SM.Topology, Topology_Access);
   procedure Release_State is new Ada.Unchecked_Deallocation (SM.State, Sleep_Access);
   procedure Release_Islands is new Ada.Unchecked_Deallocation (SM.Islands, Islands_Access);
   function Ready (E : Engine) return Boolean is
     (E.M /= null and then E.S /= null and then E.I /= null and then MJ.Data.Is_Ready (E.D));
   function State (E : Engine) return Real_Array is (MJ.Data.State_Values (E.D));
   function Tree_Asleep (E : Engine; Tree : Natural) return Integer is
     (if E.S = null or else Tree >= E.S.Nt then -1 else E.S.Tree_Asleep (Tree));
   function Awake_Dofs (E : Engine) return Natural is (if E.S = null then 0 else E.S.Dofs_Awake);
   procedure Free (E : in out Engine) is
   begin
      MJ.Data.Free (E.D); Release_Topology (E.M); Release_State (E.S); Release_Islands (E.I);
      E.Have_Frame := False;
   end Free;
   procedure Capture (E : in out Engine) is
   begin
      for B in 0 .. E.D.Nb-1 loop
         E.Previous_Pos (B) := MJ.Data.Body_Position (E.D, B);
         E.Previous_Quat (B) := MJ.Data.Body_Orientation (E.D, B);
      end loop;
      E.Have_Frame := True;
   end Capture;
   procedure Reset (E : in out Engine; Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      MJ.Data.Reset (E.D, Result); if Result /= Success then return; end if;
      E.S.Tree_Asleep := (others => SM.K.Fully_Awake);
      MJ.Data.Forward.Evaluate (E.D, Result); if Result /= Success then return; end if;
      Capture (E);
      if E.Enabled then
         declare
            V, A, Applied : SM.K.Samples (0 .. E.D.Nv-1) := (others => 0.0);
            External : SM.K.Samples (0 .. 6*E.D.Nb-1) := (others => 0.0);
            N : Natural; R : SM.Result;
         begin
            N := 0;
            for T in E.M.Trees'Range loop
               if E.M.Trees (T).Sleep_Policy = 5 then E.S.Tree_Asleep (T) := -1; end if;
               if E.M.Trees (T).Sleep_Policy = 5 then N := N + 1; end if;
            end loop;
            if N > 0 then
               SM.Sleep (E.M.all, E.S.all, E.I.all, True, False, E.Tolerance, V, A, Applied, External, N, R);
               if R /= SM.Success then Result := Invalid_Model; return; end if;
            end if;
         end;
      end if;
      SM.Update (E.M.all, E.S.all);
   end Reset;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Saved_Flags : constant Integer := M.Opt.Enableflags;
   begin
      if E.M /= null or else not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      Result := Unsupported_Feature;
      --  Admit only independent smooth trees. Constraints/tendons/flex require
      --  their actual island/contact producers, never guessed independent trees.
      if M.S.Ntree > SM.Max_Trees or else M.S.Nbody > Max_Bodies or else M.S.Nv > Max_Dofs
        or else M.S.Ntendon /= 0 or else M.S.Neq /= 0 or else M.S.Nflex /= 0
        or else M.S.Na /= 0 or else M.S.Nplugin /= 0 or else M.S.Nmocap /= 0
        or else Saved_Flags not in 0 | Enbl_Sleep
        or else M.Opt.Sleep_Tolerance not in Nonneg_Tier0 then return; end if;
      E.Enabled := Saved_Flags = Enbl_Sleep; E.Tolerance := M.Opt.Sleep_Tolerance;
      E.M := new SM.Topology (M.S.Ntree-1, M.S.Nbody-1, M.S.Nv-1);
      E.S := new SM.State (M.S.Ntree-1, M.S.Nbody-1, M.S.Nv-1);
      E.I := new SM.Islands (M.S.Ntree-1, -1);
      for T in E.M.Trees'Range loop
         E.M.Trees (T) := (M.Trees.Tree_Bodyadr (T), M.Trees.Tree_Bodynum (T),
           M.Trees.Tree_Dofadr (T), M.Trees.Tree_Dofnum (T), M.Trees.Tree_Sleep_Policy (T));
         E.I.Tree (T) := T;
      end loop;
      for B in E.M.Bodies'Range loop
         E.M.Bodies (B) := (M.Bodies.Body_Treeid (B), M.Bodies.Body_Parentid (B),
           M.Bodies.Body_Mocapid (M.Bodies.Body_Rootid (B)) >= 0);
      end loop;
      for V in E.M.Dof_Body'Range loop
         E.M.Dof_Body (V) := M.Dofs.Dof_Bodyid (V); E.M.Length (V) := M.Dofs.Dof_Length (V);
      end loop;
      if not SM.Valid (E.M.all) then Free (E); Result := Invalid_Model; return; end if;
      M.Opt.Enableflags := 0;
      MJ.Data.Create (M, E.D, Result);
      M.Opt.Enableflags := Saved_Flags;
      if Result /= Success then Free (E); return; end if;
      Reset (E, Result); if Result /= Success then Free (E); end if;
   exception
      when Constraint_Error => M.Opt.Enableflags := Saved_Flags; Free (E); Result := Invalid_Model;
      when others => M.Opt.Enableflags := Saved_Flags; Free (E); raise;
   end Create;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
     New_Time : Nonneg_Tier0; Result : out Status) is
   begin MJ.Data.Set_State (E.D, Qpos, Qvel, New_Time, Result); end Set_State;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin MJ.Data.Set_Control (E.D, Index, Value, Result); end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin MJ.Data.Set_Applied_Force (E.D, Index, Value, Result); end Set_Applied_Force;
   procedure Enable (E : in out Engine; Value : Boolean) is
   begin E.Enabled := Value; end Enable;

   procedure Step (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      if External'Length /= 0 and then (External'First /= 0 or External'Length /= E.D.Nb) then
         Result := Invalid_Size; return;
      end if;
      declare
         Saved_Q : constant Real_Array := E.D.State.Qpos.all;
         Saved_V : constant Real_Array := E.D.State.Qvel.all;
         Saved_Time : constant Nonneg_Tier0 := E.D.Clock;
         Saved_S : constant SM.State := E.S.all;
         V, A, Applied : SM.K.Samples (0 .. E.D.Nv-1);
         Loads : SM.K.Samples (0 .. 6*E.D.Nb-1) := (others => 0.0);
         Changed : SM.Flags (0 .. Integer (E.M.Nt)-1) := (others => False);
         N : Natural; R : SM.Result;
         procedure Rollback is
         begin
            E.D.State.Qpos.all := Saved_Q; E.D.State.Qvel.all := Saved_V;
            E.D.Clock := Saved_Time; E.S.all := Saved_S; Invalidate (E.D.Cache);
         end Rollback;
      begin
         MJ.Data.Kinematics.Update (E.D, Result); if Result /= Success then return; end if;
         if E.Have_Frame then
            for B in 1 .. E.D.Nb-1 loop
               if E.M.Bodies (B).Tree >= 0 and then E.D.Body_Config (B).Joint_Count > 0
                 and then E.S.Body_Awake (B) = SM.K.Asleep
                 and then (E.Previous_Pos (B) /= MJ.Data.Body_Position (E.D, B)
                    or else E.Previous_Quat (B) /= MJ.Data.Body_Orientation (E.D, B)) then
                  Changed (E.M.Bodies (B).Tree) := True;
               end if;
            end loop;
         end if;
         Capture (E);
         for J in V'Range loop V (J) := E.D.State.Qvel (J); Applied (J) := E.D.State.Applied (J); end loop;
         if External'Length > 0 then
            for B in External'Range loop
               for J in 0 .. 2 loop Loads (6*B+J) := External (B).Force (J); Loads (6*B+3+J) := External (B).Torque (J); end loop;
            end loop;
         end if;
         SM.Wake_Perturbations (E.M.all, E.S.all, E.Enabled, Changed, V, Applied, Loads, N, R);
         if R /= SM.Success then Rollback; Result := Invalid_Model; return; end if;
         if N > 0 then SM.Update (E.M.all, E.S.all); end if;
         if E.S.Dofs_Awake = 0 then
            if E.D.Clock > Max_Val-E.D.Timestep then Rollback; Result := Numeric_Limit; return; end if;
            E.D.Clock := E.D.Clock + E.D.Timestep; Result := Success; return;
         end if;
         MJ.Data.Forward.Evaluate (E.D, Result, External);
         if Result /= Success then Rollback; return; end if;
         for J in A'Range loop A (J) := E.D.Dynamics.Acceleration (J); end loop;
         SM.Sleep (E.M.all, E.S.all, E.I.all, E.Enabled, False, E.Tolerance, V, A, Applied, Loads, N, R);
         if R /= SM.Success then Rollback; Result := Invalid_Model; return; end if;
         if N > 0 then
            for J in V'Range loop E.D.State.Qvel (J) := V (J); end loop;
            E.D.Cache.Passive_Valid := False; E.D.Cache.Actuation_Valid := False; E.D.Cache.Force_Valid := False;
            E.D.Cache.Cartesian_Motion_Valid := False;
            SM.Update (E.M.all, E.S.all);
         end if;
         if E.S.Dofs_Awake > 0 then
            MJ.Data.Euler.Step (E.D, Result, External);
            if Result /= Success then Rollback; return; end if;
         else
            if E.D.Clock > Max_Val-E.D.Timestep then Rollback; Result := Numeric_Limit; return; end if;
            E.D.Clock := E.D.Clock + E.D.Timestep;
         end if;
         --  Restore only sleeping joint blocks. Independent trees have no cross
         --  metric/constraint coupling in the admitted domain.
         for J in E.D.Joint_Config'Range loop
            declare P : Joint_Parameters renames E.D.Joint_Config (J); begin
               if P.Component = 0 and then E.S.Tree_Asleep (E.M.Bodies (P.Body_Id).Tree) >= 0 then
                  for Qid in P.Group_Qadr .. P.Group_Qadr+Qpos_Width (P.Group_Type)-1 loop
                     E.D.State.Qpos (Qid) := Saved_Q (Qid);
                  end loop;
                  for Vid in P.Group_Vadr .. P.Group_Vadr+Dof_Width (P.Group_Type)-1 loop
                     E.D.State.Qvel (Vid) := 0.0;
                  end loop;
               end if;
            end;
         end loop;
         Invalidate (E.D.Cache); Result := Success;
      end;
   end Step;
end MJ.Data.Sleeping;
