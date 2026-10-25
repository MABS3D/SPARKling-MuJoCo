with MJ.Model_Structures;
package body MJ.Native_Mass_Models with SPARK_Mode is
   procedure Reveal_Layout (M : MJ.Models.Model) with
     Ghost => Static, Global => null, Pre => MJ.Models.Valid_Layout (M),
     Post => MJ.Models.Sizes_In_Range (M.S)
       and then MJ.Models.Dof_Layout_OK (M.S, M.Dofs)
       and then MJ.Models.Sparse_Layout_OK (M.S, M.Sparse)
   is
   begin
      null;
   end Reveal_Layout;

   procedure Reveal_Row (M : MJ.Models.Model; R : Natural) with
     Ghost => Static, Global => null,
     Pre => MJ.Models.Valid_Layout (M) and then R < M.S.Nv
       and then MJ.Models.Validity.M_Row_At (M, R),
     Post => M.Sparse.M_Rownnz (R) in 1 .. M.S.Nc
       and then M.Sparse.M_Rowadr (R) in 0 .. M.S.Nc - M.Sparse.M_Rownnz (R)
   is
   begin
      null;
   end Reveal_Row;

   procedure Reveal_Input_Layout (M : MJ.Models.Model) with
     Ghost => Static, Global => null,
     Pre => MJ.Models.Valid_Layout (M) and then M.S.Nv in 1 .. NP.Max_Dofs
       and then M.S.Nc in 1 .. NP.Max_Entries,
     Post => Source_Layout (M)
   is
   begin
      null;
   end Reveal_Input_Layout;

   procedure Reveal_Source (M : MJ.Models.Model) with
     Ghost => Static, Global => null,
     Pre => MJ.Models.Valid_Layout (M) and then MJ.Models.Validity.Sparse_M_OK (M)
       and then MJ.Models.Validity.M_Rows_OK (M)
       and then MJ.Models.Sizes_In_Range (M.S)
       and then MJ.Models.Dof_Layout_OK (M.S, M.Dofs)
       and then MJ.Models.Sparse_Layout_OK (M.S, M.Sparse)
       and then M.S.Nv in 1 .. NP.Max_Dofs
       and then M.S.Nc <= NP.Max_Entries,
     Post => Source_Ready (M)
   is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.M_Row_At);
   begin
      Reveal_Row (M, 0);
      Reveal_Input_Layout (M);
      for R in 0 .. M.S.Nv - 1 loop
         Reveal_Row (M, R);
         for H in M.Sparse.M_Rowadr (R) .. (M.Sparse.M_Rowadr (R) + M.Sparse.M_Rownnz (R)) - 1 loop
            MJ.Model_Structures.Row_Entry (M.Sparse.M_Colind.all,
              M.Sparse.M_Rowadr (R), M.Sparse.M_Rownnz (R), M.S.Nv, H - M.Sparse.M_Rowadr (R));
            pragma Loop_Invariant (Static => (for all J in M.Sparse.M_Rowadr (R) .. H =>
               M.Sparse.M_Colind (J) in 0 .. M.S.Nv - 1));
         end loop;
         pragma Loop_Invariant (Static => (for all I in 0 .. R =>
           M.Sparse.M_Rownnz (I) in 1 .. M.S.Nc
           and then M.Sparse.M_Rowadr (I) in 0 .. M.S.Nc - M.Sparse.M_Rownnz (I)
           and then (for all H in M.Sparse.M_Rowadr (I) ..
             (M.Sparse.M_Rowadr (I) + M.Sparse.M_Rownnz (I)) - 1 =>
               M.Sparse.M_Colind (H) in 0 .. M.S.Nv - 1)));
      end loop;
   end Reveal_Source;

   procedure Capture (M : MJ.Models.Model; P : out NP.Pattern; Result : out Capture_Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sizes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Parents_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Roots_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Welds_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Joints_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Dofs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Geoms_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Trees_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tree_Dofs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Trees_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Adrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Joints_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Parents_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Parent_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Madr_Range_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Madrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Simplenums_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_M_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_B_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_D_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_Ten_J_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.M_Rownnz_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.M_Rows_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.D_Diags_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Maps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Site_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sameframes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Meshes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Hfields_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Textures_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Texids_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Bvhs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Octs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Pairs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Excludes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Eq_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Eq_Objs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Wraps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tendons_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Trnids_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Acts_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Objs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Dims_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Adrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tuples_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Names_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Paths_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Option_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Stat_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tendon_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Caps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Adhesion_OK);
   begin
      if not MJ.Models.Valid_Layout (M)
        or else not MJ.Models.Validity.Is_Valid (M)
      then P := (others => <>); Result := Invalid_Model; return; end if;
      Capture_Validated (M, P, Result);
   end Capture;

   procedure Capture_Validated (M : MJ.Models.Model; P : out NP.Pattern; Result : out Capture_Status) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Valid_Layout);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sizes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Parents_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Roots_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Welds_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Joints_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Dofs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Geoms_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Trees_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tree_Dofs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Trees_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Adrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Joints_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Parents_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Parent_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Madr_Range_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Madrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Simplenums_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_M_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_B_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_D_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sparse_Ten_J_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.M_Rownnz_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.M_Rows_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.D_Diags_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Maps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Site_Datas_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sameframes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Meshes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Hfields_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Textures_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Texids_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Bvhs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Octs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Pairs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Excludes_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Eq_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Eq_Objs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Wraps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tendons_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Trnids_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Acts_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Ranges_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Types_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Objs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Dims_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Sensor_Adrs_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tuples_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Names_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Paths_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Option_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Stat_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Body_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Jnt_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Geom_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Dof_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Tendon_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Actuator_Params_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Caps_OK);
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", MJ.Models.Validity.Adhesion_OK);
   begin
      if M.S.Nv not in 1 .. NP.Max_Dofs or else M.S.Nc > NP.Max_Entries then
         P := (others => <>); Result := Capacity_Exceeded; return;
      end if;
      Reveal_Layout (M);
      Reveal_Source (M);
      NP.Copy (M.Sparse.M_Rownnz.all, M.Sparse.M_Rowadr.all,
        M.Sparse.M_Colind.all, M.Dofs.Dof_Simplenum.all, M.Dofs.Dof_M0.all,
        M.Dofs.Dof_Armature.all, M.S.Nv, M.S.Nc, P);
      Result := Success;
   end Capture_Validated;

end MJ.Native_Mass_Models;
