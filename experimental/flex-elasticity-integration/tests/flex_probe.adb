with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Data; use MJ.Data;
with MJ.Data.Flex_Elasticity;
procedure Flex_Probe is
   package F renames MJ.Data.Flex_Elasticity;
   package IO is new Ada.Text_IO.Float_IO (Real);
   use type MJ.Models.Sizes;
   use type Capacities;
   M : MJ.Models.Model;
   E : F.Engine;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Cases, Steps : Integer;
   X, T : Real;
   Benchmark : constant Boolean := Ada.Command_Line.Argument_Count > 1 and then Ada.Command_Line.Argument (2) = "benchmark";
   Bytes : Byte_Array_Access;
   Read_OK : Boolean;
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
   procedure Emit (Name : String; A : Real_Array) is
   begin
      Put (Name); for V of A loop Put (' '); IO.Put (V, Fore => 1, Aft => 17, Exp => 3); end loop; New_Line;
   end Emit;
begin
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Bytes, Read_OK);
   if not Read_OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all, M, Loaded);
   Free_Byte (Bytes);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   declare
      Saved : constant MJ.Models.Sizes := M.S;
      Saved_Pointer : constant Int_Array_Access := M.Flexes.Flex_Vertbodyid;
      Saved_Caps : constant Capacities := M.Caps;
      Saved_Adhesion : constant Boolean := M.Flg_Adhesion;
      Q : State_Vector (0 .. M.S.Nq - 1);
      V : State_Vector (0 .. M.S.Nv - 1);
      A : State_Vector (0 .. M.S.Na - 1);
      Nu : constant Natural := M.S.Nu;
      Begin_Time, End_Time : Ada.Real_Time.Time;
   begin
      F.Create (M, E, Result);
      if M.S /= Saved or else M.Flexes.Flex_Vertbodyid /= Saved_Pointer
        or else M.Caps /= Saved_Caps or else M.Flg_Adhesion /= Saved_Adhesion then raise Program_Error with "borrow not restored"; end if;
      if Result /= Success then Put_Line ("create " & Result'Image); MJ.Models.Free (M); return; end if;
      F.Create (M, E, Result); if Result /= Already_Allocated then raise Program_Error with "double create"; end if;
      MJ.Models.Free (M);
      declare Before : constant Real_Array := F.Complete_State (E); begin
         F.Set_State (E, State_Vector'(1 .. 0 => 0.0), State_Vector'(1 .. 0 => 0.0), 0.0, Result);
         if Result /= Invalid_Size or else F.Complete_State (E) /= Before then raise Program_Error with "state atomicity"; end if;
      end;
      Ada.Integer_Text_IO.Get (Cases); Ada.Integer_Text_IO.Get (Steps);
      for Sample in 1 .. Cases loop
         IO.Get (T);
         for I in Q'Range loop IO.Get (X); Q (I) := X; end loop;
         for I in V'Range loop IO.Get (X); V (I) := X; end loop;
         F.Set_State (E, Q, V, T, Result); Check;
         for I in V'Range loop IO.Get (X); F.Set_Applied_Force (E, I, X, Result); Check; end loop;
         for I in 0 .. Nu - 1 loop IO.Get (X); F.Set_Control (E, I, X, Result); Check; end loop;
         for I in A'Range loop IO.Get (X); A (I) := X; end loop;
         if A'Length > 0 then F.Set_Activation (E, A, Result); Check; end if;
         F.Evaluate (E, Result); Check;
         declare
            Before : constant Real_Array := F.Passive (E);
            D : constant F.Trace := F.Diagnostics (E);
         begin
            F.Evaluate (E, Result); Check;
            if F.Passive (E) /= Before then raise Program_Error with "duplicate elastic forces"; end if;
            if not Benchmark then
               Put_Line ("case" & Sample'Image);
               Emit ("pos", D.Position); Emit ("length", D.Length); Emit ("velocity", D.Velocity);
               Emit ("spring", D.Spring); Emit ("damper", D.Damper);
               Emit ("passive", F.Passive (E)); Emit ("acc", F.Acceleration (E));
            end if;
         end;
         Begin_Time := Clock;
         for I in 1 .. Steps loop F.Step (E, Result); Check; end loop;
         End_Time := Clock;
         if Benchmark then Emit ("seconds", [Real (To_Duration (End_Time - Begin_Time))]); end if;
         Emit ("state", F.Complete_State (E));
      end loop;
      F.Free (E, Result); Check; F.Free (E, Result); Check;
      if F.Ready (E) then raise Program_Error with "free"; end if;
   end;
exception
   when Error : others => Put_Line (Ada.Exceptions.Exception_Information (Error)); Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Flex_Probe;
