with Ada.Command_Line;
with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Euler;
procedure Manifold_Capacity is
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error; end if;
   Create (M, D, Result); Check;
   if Position_Count (D) /= 280 or else Velocity_Count (D) /= 210 then raise Program_Error; end if;
   declare
      Q : State_Vector (0 .. Position_Count (D) - 1);
      V : State_Vector (0 .. Velocity_Count (D) - 1) := [others => 0.0];
      Qout : Real_Array (Q'Range);
      Vout : Real_Array (V'Range);
      T : Real;
   begin
      Get_State (D, Qout, Vout, T, Result); Check;
      for I in Q'Range loop Q (I) := Tier0_Real (Qout (I)); end loop;
      Set_State (D, Q, V, 0.0, Result); Check;
      MJ.Data.Euler.Step (D, Result); Check;
      Get_State (D, Qout, Vout, T, Result); Check;
      if Qout /= As_Reals (Q) or else (for some X of Vout => X /= 0.0)
        or else T /= Step_Size (D) then raise Program_Error; end if;
   end;
   MJ.Models.Free (M);
   Free (D);
   Ada.Text_IO.Put_Line ("capacity PASS: nq=280 nv=210");
end Manifold_Capacity;
