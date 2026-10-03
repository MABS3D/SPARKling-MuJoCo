with Ada.Command_Line;
with Ada.Calendar;
with Ada.Integer_Text_IO;
with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Sleeping;
with MJ.External_Forces;
procedure Sleeping_Probe is
   use type Ada.Calendar.Time;
   package Sleep renames MJ.Data.Sleeping;
   package Float_IO is new Ada.Text_IO.Float_IO (Real);
   function Int return Integer is X : Integer; begin Ada.Integer_Text_IO.Get (X); return X; end;
   function Float return Real is X : Real; begin Float_IO.Get (X); return X; end;
   M : MJ.Models.Model; Load : MJ.Fields.Load_Result; R : Status;
   type Engine_Access is access Sleep.Engine; E : Engine_Access := new Sleep.Engine;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Load);
   if Load.Status /= OK then Put_Line ("load " & Load.Status'Image); return; end if;
   declare
      Nt : constant Natural := M.S.Ntree; Nq : constant Natural := M.S.Nq;
      Nv : constant Natural := M.S.Nv; Nb : constant Natural := M.S.Nbody;
      Saved : constant Integer := M.Opt.Enableflags;
      External : MJ.External_Forces.Wrench_Array (0 .. Nb-1) := (others => <>);
      Q : State_Vector (0 .. Nq-1); V : State_Vector (0 .. Nv-1);
      Count : Natural;
      procedure Dump is
      begin
         Put (" " & Integer'Image (Status'Pos (R))); Put (" " & Integer'Image (Sleep.Awake_Dofs (E.all)));
         for X of Sleep.State (E.all) loop Put (" " & Real'Image (X)); end loop;
         for I in 0 .. Nt-1 loop Put (" " & Integer'Image (Sleep.Tree_Asleep (E.all, I))); end loop;
         New_Line;
      end Dump;
   begin
      Sleep.Create (M, E.all, R);
      if M.Opt.Enableflags /= Saved then raise Program_Error with "flags"; end if;
      MJ.Models.Free (M);
      if R /= Success then Put_Line ("create " & R'Image); return; end if;
      Count := Int;
      for I in 1 .. Count loop
         declare Kind : constant Integer := Int; J : Integer; X : Real; begin
            case Kind is
               when 0 => Sleep.Step (E.all, R, External);
               when 1 => X := Float;
                  for J in Q'Range loop Q (J) := Float; end loop;
                  for J in V'Range loop V (J) := Float; end loop;
                  Sleep.Set_State (E.all, Q, V, X, R);
               when 2 => J := Int; X := Float; Sleep.Set_Applied_Force (E.all, J, X, R);
               when 3 => J := Int; X := Float; Sleep.Set_Control (E.all, J, X, R);
               when 4 => J := Int;
                  for C in 0 .. 2 loop External (J).Force (C) := Float; end loop;
                  for C in 0 .. 2 loop External (J).Torque (C) := Float; end loop;
                  R := Success;
               when 5 => Sleep.Enable (E.all, Int /= 0); R := Success;
               when 6 => Sleep.Reset (E.all, R);
               when 7 => declare
                  Repeats : constant Natural := Int;
                  Start : constant Ada.Calendar.Time := Ada.Calendar.Clock;
               begin
                  for J in 1 .. Repeats loop
                     Sleep.Step (E.all, R, External);
                     if R /= Success then exit; end if;
                  end loop;
                  Put_Line ("PERF " & Duration'Image (Ada.Calendar.Clock-Start));
               end;
               when others => raise Program_Error;
            end case;
            Dump;
         end;
      end loop;
      Sleep.Free (E.all); Sleep.Free (E.all);
   end;
end Sleeping_Probe;
