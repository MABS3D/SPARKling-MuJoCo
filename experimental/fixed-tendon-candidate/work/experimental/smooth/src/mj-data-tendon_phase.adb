with MJ.Smooth_Dynamics;
package body MJ.Data.Tendon_Phase with SPARK_Mode is
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Smooth_Dynamics.Symmetric);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Pattern_Ready);
   pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Layout_Ready);
   procedure Passive (D : in out Simulation; Result : out Status) is
      Nv : constant Natural := D.Nv;
      Springs, Dampers : Real_Array (0 .. Nv - 1) with Relaxed_Initialization;
      Ok : Boolean;
      Value : Real;
   begin
      Result := Numeric_Limit;
      for J in 0 .. D.Nj - 1 loop
         Springs (J) := MJ.Smooth_Kernels.Passive_Force
           (D.State.Qpos (J), D.Joint_Config (J).Spring_Reference, D.State.Qvel (J),
            D.Joint_Config (J).Stiffness, D.Joint_Config (J).Damping, D.Spring_Enabled, False);
         Dampers (J) := MJ.Smooth_Kernels.Passive_Force
           (D.State.Qpos (J), D.Joint_Config (J).Spring_Reference, D.State.Qvel (J),
            D.Joint_Config (J).Stiffness, D.Joint_Config (J).Damping, False, D.Damper_Enabled);
         pragma Loop_Invariant (for all I in 0 .. J => Springs (I)'Initialized and then Dampers (I)'Initialized);
         pragma Loop_Invariant (for all I in 0 .. J => Springs (I) in -1.0e60 .. 1.0e60
           and then Dampers (I) in -1.0e60 .. 1.0e60);
      end loop;
      MJ.Fixed_Tendons.Add_Passive
        (D.Tendon_Config.all, D.State.Qpos.all, D.State.Qvel.all,
         D.Spring_Enabled, D.Damper_Enabled, Springs, Dampers, Ok);
      if not Ok then return; end if;
      for J in 0 .. D.Nv - 1 loop
         Value := Springs (J) + Dampers (J);
         if not Within_Work (Value) then return; end if;
         D.Dynamics.Passive (J) := Value;
      end loop;
      Result := Success;
   end Passive;

   procedure Inertia (D : in out Simulation; Result : out Status) is
      Ok : Boolean;
   begin
      Result := Success;
      if D.Tendon_Config = null then return; end if;
      MJ.Fixed_Tendons.Add_Mass (D.Tendon_Config.all, D.Nv, D.Dynamics.Mass.all, Ok);
      pragma Assert (Static => Ok);
   end Inertia;
end MJ.Data.Tendon_Phase;
