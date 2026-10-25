with MJ.Data.Composite_Assembly;
with MJ.Models.Validity;
with MJ.Native_Mass_Kernels;
with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Smooth_Topology;

package body MJ.Data.Native_Mass with SPARK_Mode is
   package K renames MJ.Native_Mass_Kernels;
   package SK renames MJ.Spatial_Kernels;
   package T renames MJ.Smooth_Topology;
   package CA renames MJ.Data.Composite_Assembly;
   use type MJ.Spatial_Tendon_Models.Description_Access;

   function As_Status (R : NM.Capture_Status) return Status is
     (case R is when NM.Success => Success, when NM.Invalid_Model => Invalid_Model,
       when NM.Capacity_Exceeded => Capacity_Exceeded);
   procedure Capture (M : MJ.Models.Model; P : out Pattern; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Consistent);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Matches_Model);
      Item : NM.Capture_Status;
   begin
      NM.Capture (M, P.Value, Item); Result := As_Status (Item);
   end Capture;
   procedure Capture_Validated (M : MJ.Models.Model; P : out Pattern; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Is_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Consistent);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Matches_Model);
      Item : NM.Capture_Status;
   begin
      NM.Capture_Validated (M, P.Value, Item); Result := As_Status (Item);
   end Capture_Validated;

   -- Only the published mass slab is needed by this projection. Keep the
   -- numeric and configuration predicates abstract in this layout lemma.
   procedure Reveal_Mass_Layout (D : Simulation) with
     Ghost => Static, Global => null, Pre => Is_Ready (D),
     Post => D.Nv <= Max_Dofs
       and then Has_Real_Layout (D.Dynamics.Mass, D.Nv * D.Nv);
   procedure Reveal_Mass_Layout (D : Simulation) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Caches_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Valid);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Storage_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Topology_Storage_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Activation_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Spatial_Tendon_Models.Ready);
   begin
      null;
   end Reveal_Mass_Layout;

   -- Exact projection of the current dense mass cache into disjoint native
   -- rows. No dense copy or additional runtime scan is introduced here.
   procedure Gather_Current (D : Simulation; P : Pattern; Mass : out Real_Array) with
     Global => null,
     Pre => (Static => Is_Ready (D) and then Mass_Current (D)
       and then NP.Valid (P.Value) and then P.Value.Nv = Velocity_Count (D)
       and then not P.Value.Shared and then Mass'First = 0
       and then Int64 (Mass'Length) = Int64 (P.Value.Nc)),
     Post => (Static =>
       (for all R in 0 .. P.Value.Nv - 1 =>
         (for all H in P.Value.Rows (R).First ..
           (P.Value.Rows (R).First + P.Value.Rows (R).Width) - 1 =>
             Mass (H) = Mass_Entry (D, R, P.Value.Columns (H))))
       and then (for all H in Mass'Range =>
         (if not NP.Used (P.Value, P.Value.Nv, H) then Mass (H) = 0.0)));
   pragma Precondition (Static => not NP.Sharing_Model (P.Value.Rows, P.Value.Nv));
   procedure Gather_Current (D : Simulation; P : Pattern; Mass : out Real_Array) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Consistent);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Matches_Model);
   begin
      Reveal_Mass_Layout (D);
      if D.Cache.Mass_Compact then
         Mass := [others => 0.0];
         for R in 0 .. P.Value.Nv - 1 loop
            NP.Disjoint_Prefix (P.Value, R);
            for H in P.Value.Rows (R).First ..
              (P.Value.Rows (R).First + P.Value.Rows (R).Width) - 1
            loop
               Mass (H) := Mass_Entry (D, R, P.Value.Columns (H));
               pragma Loop_Invariant (Static => (for all K in Mass'Range =>
                 Mass (K) = (if K in P.Value.Rows (R).First .. H then
                   Mass_Entry (D, R, P.Value.Columns (K))
                   else Mass'Loop_Entry (K))));
            end loop;
            pragma Loop_Invariant (Static => (for all I in 0 .. R =>
              (for all H in P.Value.Rows (I).First ..
                (P.Value.Rows (I).First + P.Value.Rows (I).Width) - 1 =>
                  Mass (H) = Mass_Entry (D, I, P.Value.Columns (H)))));
            pragma Loop_Invariant (Static => (for all H in Mass'Range =>
              (if not NP.Used (P.Value, R + 1, H) then Mass (H) = 0.0)));
         end loop;
      else
         NP.Gather (P.Value, D.Dynamics.Mass.all, Mass);
      end if;
   end Gather_Current;

   procedure Reveal_Pattern (P : Pattern) with
     Ghost => Static, Global => null, Pre => Consistent (P) and then P.Value.Nv > 0,
     Post => NP.Valid (P.Value)
       and then P.Value.Shared = NP.Sharing_Model (P.Value.Rows, P.Value.Nv);
   procedure Reveal_Pattern (P : Pattern) is
   begin
      null;
   end Reveal_Pattern;

   -- Total shape/status boundary for the disjoint path, including empty or
   -- otherwise incompatible output shapes. Evaluate retains its public domain.
   procedure Gather_Disjoint
     (D : Simulation; P : Pattern; Mass : out Real_Array; Result : out Status) with
     Global => null,
     Pre => (Static => Is_Ready (D) and then Mass_Current (D)
       and then Consistent (P) and then not P.Value.Shared),
     Post => (Static =>
       (if P.Value.Nv in 1 .. Max_Dofs and then P.Value.Nv = Velocity_Count (D)
          and then Mass'First = 0 and then Int64 (Mass'Length) = Int64 (P.Value.Nc)
        then Result = Success and then NP.Valid (P.Value)
          and then (for all R in 0 .. P.Value.Nv - 1 =>
            (for all H in P.Value.Rows (R).First ..
              (P.Value.Rows (R).First + P.Value.Rows (R).Width) - 1 =>
                Mass (H) = Mass_Entry (D, R, P.Value.Columns (H))))
          and then (for all H in Mass'Range =>
            (if not NP.Used (P.Value, P.Value.Nv, H) then Mass (H) = 0.0))
        else Result = Invalid_Size and then (for all X of Mass => X = 0.0)));
   procedure Gather_Disjoint
     (D : Simulation; P : Pattern; Mass : out Real_Array; Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Consistent);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Matches_Model);
   begin
      if P.Value.Nv not in 1 .. Max_Dofs or else P.Value.Nv /= D.Nv
        or else Mass'First /= 0 or else Int64 (Mass'Length) /= Int64 (P.Value.Nc)
      then
         K.Zero (Mass);
         Result := Invalid_Size;
      else
         Reveal_Pattern (P);
         Gather_Current (D, P, Mass);
         Result := Success;
      end if;
   end Gather_Disjoint;

   procedure Reveal_Shared_Inputs (D : Simulation) with
     Ghost => Static, Global => null,
     Pre => Is_Ready (D) and then D.Cache.Spatial_Valid,
     Post => D.Nb in 1 .. Max_Bodies and then D.Nv <= Max_Dofs
       and then D.Body_Config /= null and then D.Body_Config'First = 0
       and then D.Body_Config'Last = D.Nb - 1
       and then (for all B in 1 .. D.Nb - 1 => D.Body_Config (B).Parent < B)
       and then Has_Real_Layout (D.Kinematic.Spatial_Inertias, 10 * D.Nb)
       and then (for all X of D.Kinematic.Spatial_Inertias.all => X in -1.0e36 .. 1.0e36)
       and then Has_Real_Layout (D.Kinematic.Spatial_Motions, 6 * D.Nv)
       and then (for all X of D.Kinematic.Spatial_Motions.all => X in -1.0e12 .. 1.0e12)
       and then not T.Empty (D.Topology)
       and then T.Body_Count (D.Topology) = D.Nb and then T.Dof_Count (D.Topology) = D.Nv;
   procedure Reveal_Shared_Inputs (D : Simulation) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Inputs_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Configuration_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ancestor_Storage_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Position_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Actuator_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Activation_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Spatial_Tendon_Models.Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Quaternion);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Unit_Vector);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Poses_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Jacobians_Bounded);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Array_Bounded);
   begin
      null;
   end Reveal_Shared_Inputs;

   -- This follows mj_crb then mj_tendonArmature in C 3.17.0. In particular,
   -- shared slots are not a gather from the final dense matrix: diagonal
   -- assignments reset earlier contributions, off-diagonals accumulate, and
   -- tendon armature is added only after every rigid-body row has been written.
   procedure Gather_Shared
     (D : Simulation; P : Pattern; Mass : out Real_Array; Result : out Status) with
     Global => null,
     Pre => (Static => Is_Ready (D) and then Mass_Current (D)
       and then Consistent (P) and then P.Value.Shared)
   is
      subtype Composite_Array is CA.Composite_Array;
      Composite : Composite_Array (0 .. D.Nb - 1);
      Product : SK.Motion;
      Value : Real;
      J, Cursor : Integer;
      Has_General : Boolean := False;
      procedure Write (Slot : Natural; X : Real; Assign : Boolean) with
        Global => (In_Out => (Mass, Result)),
        Pre => (Static => Slot in Mass'Range and then K.Bounded (Mass) and then Result = Success),
        Post => (Static => K.Bounded (Mass)
          and then Result =
            (if X not in K.Value then Numeric_Limit
             elsif (if Assign then X else Mass'Old (Slot) + X) not in K.Value
             then Numeric_Limit else Success)
          and then (for all H in Mass'Range => Mass (H) =
            (if X in K.Value and then Result = Success and then H = Slot
             then (if Assign then X else Mass'Old (H) + X) else Mass'Old (H))))
      is
         Accepted : Boolean;
      begin
         if X not in K.Value then Result := Numeric_Limit; return; end if;
         K.Update (Mass, Slot, X, Assign, Accepted);
         if not Accepted then Result := Numeric_Limit; end if;
      end Write;
   begin
      Result := Invalid_Size;
      if P.Value.Nv not in 1 .. Max_Dofs or else P.Value.Nv /= D.Nv
        or else Mass'First /= 0 or else Int64 (Mass'Length) /= Int64 (P.Value.Nc)
      then K.Zero (Mass); return; end if;
      Reveal_Pattern (P);
      K.Zero (Mass);
      for I in 0 .. P.Value.Nv - 1 loop
         Has_General := Has_General or else not P.Value.Rows (I).Simple;
         pragma Loop_Invariant (Static => Has_General =
           (for some R in 0 .. I => not P.Value.Rows (R).Simple));
      end loop;
      if Has_General then
         Result := Stale_Results;
         if not D.Cache.Pose_Valid or else not D.Cache.Spatial_Valid then return; end if;
         Result := Numeric_Limit;
         Reveal_Shared_Inputs (D);
         CA.Load_Composite (D.Kinematic.Spatial_Inertias.all, Composite);
         CA.Accumulate_Composite (D.Body_Config.all, Composite);
      end if;
      Result := Success;
      for I in 0 .. P.Value.Nv - 1 loop
         pragma Loop_Invariant (Static => K.Bounded (Mass) and then Result = Success);
         if P.Value.Rows (I).Simple then
            Write (P.Value.Rows (I).First, P.Value.Rows (I).Fixed, True);
            if Result /= Success then return; end if;
         else
            Cursor := P.Value.Rows (I).First + P.Value.Rows (I).Width - 1;
            Write (Cursor, P.Value.Rows (I).Armature, True);
            if Result /= Success then return; end if;
            Product := SK.Multiply (Composite (T.Dof_Body (D.Topology, I)),
               MJ.Spatial_Storage.Load_Motion (D.Kinematic.Spatial_Motions.all, 6 * I));
            J := I;
            while J >= 0 loop
               pragma Loop_Invariant (Static => J in -1 .. Integer (I));
               pragma Loop_Invariant (Static => Cursor in Integer (P.Value.Rows (I).First) - 1 ..
                 Integer (P.Value.Rows (I).First + P.Value.Rows (I).Width) - 1);
               pragma Loop_Invariant (Static => K.Bounded (Mass) and then Result = Success);
               if Cursor < P.Value.Rows (I).First then Result := Invalid_Model; return; end if;
               Value := SK.Dot (MJ.Spatial_Storage.Load_Motion
                 (D.Kinematic.Spatial_Motions.all, 6 * J), Product);
               Write (Cursor, Value, False);
               if Result /= Success then return; end if;
               Cursor := Cursor - 1; J := T.Parent_Dof (D.Topology, J);
            end loop;
         end if;
      end loop;
      if D.Tendons /= null then
         for Term of D.Tendons.Mass loop
            pragma Loop_Invariant (Static => K.Bounded (Mass) and then Result = Success);
            declare
               Row : constant Natural := Term.Index / D.Nv;
               Col : constant Natural := Term.Index mod D.Nv;
            begin
               for H in P.Value.Rows (Row).First .. P.Value.Rows (Row).First + P.Value.Rows (Row).Width - 1 loop
                  pragma Loop_Invariant (Static => K.Bounded (Mass) and then Result = Success);
                  if P.Value.Columns (H) = Col then
                     Write (H, Term.Value, False);
                     if Result /= Success then return; end if;
                     exit;
                  end if;
               end loop;
            end;
         end loop;
      end if;
   end Gather_Shared;

   procedure Evaluate (D : Simulation; P : Pattern; Mass : out Real_Array;
                       Result : out Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Is_Ready);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Current);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Velocity_Count);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Mass_Entry);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Consistent);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", NM.Matches_Model);
   begin
      if P.Value.Shared then
         Gather_Shared (D, P, Mass, Result);
      else
         Gather_Disjoint (D, P, Mass, Result);
      end if;
   end Evaluate;
end MJ.Data.Native_Mass;
