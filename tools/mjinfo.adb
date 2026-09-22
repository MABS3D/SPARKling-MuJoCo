with Ada.Command_Line; use Ada.Command_Line;
with Ada.Text_IO;      use Ada.Text_IO;
with MJ.Types;         use MJ.Types;
with MJ.Fields;        use MJ.Fields;
with MJ.Models;        use MJ.Models;
with MJ.MJB;

--  mjinfo <model.mjb>: load, validate, and print sizes and capacities.
--  Exit status 0 on OK, 1 on rejection, 2 on usage error.
procedure Mjinfo is
   M : Model;
   R : Load_Result;
begin
   if Argument_Count /= 1 then
      Put_Line ("usage: mjinfo <model.mjb>");
      Set_Exit_Status (2);
      return;
   end if;
   MJ.MJB.Load (Argument (1), (Contact_Cap => 0), M, R);
   Put ("status: " & R.Status'Image);
   if R.Status /= OK then
      Put_Line ("  field: " & R.Field'Image & "  index:" & R.Index'Image);
      Set_Exit_Status (1);
      return;
   end if;
   New_Line;
   Put_Line ("nbody" & M.S.Nbody'Image & "  njnt" & M.S.Njnt'Image & "  nq" & M.S.Nq'Image
             & "  nv" & M.S.Nv'Image & "  nu" & M.S.Nu'Image & "  na" & M.S.Na'Image);
   Put_Line ("ngeom" & M.S.Ngeom'Image & "  nsite" & M.S.Nsite'Image & "  nmesh" & M.S.Nmesh'Image
             & "  nhfield" & M.S.Nhfield'Image & "  ntex" & M.S.Ntex'Image & "  nmat" & M.S.Nmat'Image);
   Put_Line ("ntendon" & M.S.Ntendon'Image & "  nwrap" & M.S.Nwrap'Image & "  neq" & M.S.Neq'Image
             & "  npair" & M.S.Npair'Image & "  nexclude" & M.S.Nexclude'Image
             & "  nsensor" & M.S.Nsensor'Image & "  nkey" & M.S.Nkey'Image);
   Put_Line ("ntree" & M.S.Ntree'Image & "  nM" & M.S.Nm'Image & "  nB" & M.S.Nb'Image
             & "  nC" & M.S.Nc'Image & "  nD" & M.S.Nd'Image & "  nbvh" & M.S.Nbvh'Image);
   Put_Line ("caps: contact" & M.Caps.Contact_Cap'Image & "  ne" & M.Caps.Ne_Max'Image
             & "  nf" & M.Caps.Nf_Max'Image & "  nl" & M.Caps.Nl_Max'Image
             & "  efc" & M.Caps.Efc_Cap'Image & "  nJ" & M.Caps.NJ_Cap'Image);
   Put_Line ("flags: gravcomp " & M.Flg_Gravcomp'Image & "  surfacevel " & M.Flg_Surfacevel'Image
             & "  adhesion " & M.Flg_Adhesion'Image);
   Free (M);
end Mjinfo;
