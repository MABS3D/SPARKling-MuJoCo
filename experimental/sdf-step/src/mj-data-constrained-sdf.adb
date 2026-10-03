with MJ.Data.Forward;
with MJ.Data.Pipeline;
with MJ.SDF_Kernels;
package body MJ.Data.Constrained.SDF with SPARK_Mode is
   use type RG.Status;
   function Ready (E : Engine) return Boolean is
     (Constrained.Ready (E.Base) and then MJ.SDF_Scene.Initialized (E.Scene));
   function State (E : Engine) return Real_Array is (Constrained.State (E.Base));
   function Complete_State (E : Engine) return Real_Array is (Constrained.Complete_State (E.Base));
   function Diagnostics (E : Engine) return Trace is (Constrained.Diagnostics (E.Base));
   function Contacts (E : Engine) return MJ.Full_Contacts.Full_Array is
     (E.Base.Contacts (0 .. Integer (E.Base.T.Ncontact) - 1));
   function Activation_Count (E : Engine) return Natural is (Constrained.Activation_Count (E.Base));
   function Activation_Values (E : Engine) return Real_Array is (Constrained.Activation_Values (E.Base));
   function Activation_Rates (E : Engine) return Real_Array is (Constrained.Activation_Rates (E.Base));
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Types, Dataids : Int_Array (0 .. Max_G - 1) := [others => 0];
      Sizes : Real_Array (0 .. 3 * Max_G - 1) := [others => 0.0];
      Changed : Natural := 0;
      Ng : constant Natural := M.S.Ngeom;
      S : RG.Status;
      Has_SDF : Boolean := False;
      procedure Restore is
      begin
         for G in 0 .. Integer (Changed) - 1 loop
            M.Geoms.Geom_Type (G) := Types (G);
            M.Geoms.Geom_Dataid (G) := Dataids (G);
            for K in 0 .. 2 loop M.Geoms.Geom_Size (3 * G + K) := Sizes (3 * G + K); end loop;
         end loop;
         Changed := 0;
      end Restore;
   begin
      if Constrained.Ready (E.Base) then Result := Already_Allocated; return; end if;
      if Ng > Max_G then Result := Capacity_Exceeded; return; end if;
      if M.S.Npair /= 0 or M.S.Nexclude /= 0 or M.Flg_Adhesion
        or M.Opt.Noslip_Iterations /= 0 then
         Result := Unsupported_Feature; return;
      end if;
      MJ.SDF_Scene.Load (M, E.Scene, S);
      if S /= RG.Success then
         Result := (if S = RG.Capacity_Limit then Capacity_Exceeded else Invalid_Model); return;
      end if;
      for G in 0 .. Integer (Ng) - 1 loop
         Has_SDF := Has_SDF or M.Geoms.Geom_Type (G) = 8;
      end loop;
      -- The free-dynamics subengine only needs body inertia and poses. Its
      -- temporary broad-phase proxy is never used to generate SDF contacts.
      -- Fluid geometry would depend on this replacement, so reject that mix.
      if Has_SDF and then (M.Opt.Density /= 0.0 or M.Opt.Viscosity /= 0.0) then
         MJ.SDF_Scene.Release (E.Scene); Result := Unsupported_Feature; return;
      end if;
      for G in 0 .. Integer (Ng) - 1 loop
         Types (G) := M.Geoms.Geom_Type (G); Dataids (G) := M.Geoms.Geom_Dataid (G);
         for K in 0 .. 2 loop Sizes (3 * G + K) := M.Geoms.Geom_Size (3 * G + K); end loop;
         Changed := G + 1;
         if Types (G) = 8 then
            M.Geoms.Geom_Type (G) := 6; M.Geoms.Geom_Dataid (G) := -1;
            for K in 0 .. 2 loop
               M.Geoms.Geom_Size (3 * G + K) := MJ.SDF_Kernels.Proxy_Extent
                 (M.Geoms.Geom_Aabb (6 * G + K), M.Geoms.Geom_Aabb (6 * G + 3 + K));
            end loop;
         end if;
      end loop;
      Constrained.Create (M, E.Base, Result);
      Restore;
      if Result /= Success then MJ.SDF_Scene.Release (E.Scene); end if;
   exception
      when Constraint_Error =>
         Restore; MJ.SDF_Scene.Release (E.Scene);
         Constrained.Free (E.Base, Result); Result := Invalid_Model;
      when others => Restore; MJ.SDF_Scene.Release (E.Scene); raise;
   end Create;
   procedure Free (E : in out Engine; Result : out Status) is
   begin
      Constrained.Free (E.Base, Result); MJ.SDF_Scene.Release (E.Scene);
   end Free;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status) is
   begin Constrained.Set_State (E.Base, Qpos, Qvel, New_Time, Result); end Set_State;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin Constrained.Set_Activation (E.Base, Values, Result); end Set_Activation;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Constrained.Set_Control (E.Base, Index, Value, Result); end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Constrained.Set_Applied_Force (E.Base, Index, Value, Result); end Set_Applied_Force;
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Ng : constant Natural := E.Base.Ng;
      Poses : RG.Pose_Array (0 .. Integer (Ng) - 1);
      S : RG.Status;
   begin
      E.Base.T.Valid := False; E.Base.T.Ncontact := 0;
      Result := Not_Allocated;
      if not Ready (E) then return; end if;
      MJ.Data.Forward.Evaluate (E.Base.D, Result, External);
      if Result /= Success then return; end if;
      Generate_Geom_Poses (E.Base, Poses, Result);
      if Result /= Success then return; end if;
      MJ.SDF_Scene.Generate (E.Scene, Poses, E.Base.Contacts, E.Base.T.Ncontact, S);
      if S /= RG.Success then
         Result := (if S = RG.Capacity_Limit then Capacity_Exceeded else Numeric_Limit); return;
      end if;
      Set_Rigid_Contact_Endpoints (E.Base, Result);
      if Result /= Success then return; end if;
      if E.Base.T.Ncontact > 0 then
         MJ.Data.Pipeline.Ensure_Jacobians (E.Base.D, Result);
         if Result /= Success then return; end if;
      end if;
      Constrained.Assemble (E.Base, Result);
      if Result = Success then Constrained.Prepare_And_Solve (E.Base, Result); end if;
   exception
      when Constraint_Error => E.Base.T.Valid := False; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (E, Result, External);
      if Result = Success then Constrained.Advance (E.Base, Result); end if;
   end Step;
end MJ.Data.Constrained.SDF;
