with Check;    use Check;
with MJ.Types; use MJ.Types;

procedure Test_Types is
begin
   Assert_Eq (Qpos_Width (0), 7, "free joint qpos width");
   Assert_Eq (Dof_Width (0), 6, "free joint dof width");
   Assert_Eq (Qpos_Width (1), 4, "ball joint qpos width");
   Assert_Eq (Dof_Width (1), 3, "ball joint dof width");
   Assert_Eq (Qpos_Width (2), 1, "slide joint qpos width");
   Assert_Eq (Dof_Width (3), 1, "hinge joint dof width");

   Assert_Eq (Integer'(Trn_Kind'Enum_Rep (Trn_Undefined)), 1000, "mjTRN_UNDEFINED code");
   Assert_Eq (Integer'(Obj_Kind'Enum_Rep (Obj_Frame)), 100, "mjOBJ_FRAME code");
   Assert_Eq (Integer'(Obj_Kind'Enum_Rep (Obj_Plugin)), 25, "mjOBJ_PLUGIN code");
   Assert_Eq (Sensor_Kind'Pos (Sens_User), 48, "49 sensor kinds");
   Assert_Eq (Integer'(Geom_Kind'Enum_Rep (Sdf)), 8, "mjGEOM_SDF code");

   Assert (Tier0_Real'Last = Max_Val, "tier 0 bound is mjMAXVAL");
   Assert (Tier0_Real'Last * Tier0_Real'Last <= Tier1_Real'Last
           and Tier1_Real'Last * Tier1_Real'Last <= Tier2_Real'Last
           and Tier2_Real'Last * Tier2_Real'Last <= Tier3_Real'Last
           and Tier3_Real'Last * Tier3_Real'Last <= Tier4_Real'Last,
           "a product of two tier-k values fits tier k+1");
   Assert (Tier0_Real'Last / Min_Val <= Tier1_Real'Last, "division by Min_Val moves up one tier");
   Assert (Int64 (Max_Size) * 11 <= Int64 (Integer'Last), "11 * Max_Size fits Integer");
   Assert (Int64 (Max_Cap) * 36 <= Int64 (Integer'Last), "36 * Max_Cap fits Integer");
   Assert (Int64 (Max_Size) * Int64 (Max_Size) > 0, "Max_Size squared fits Int64");

   Report_And_Exit;
end Test_Types;
