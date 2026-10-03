with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained.Flex;
with MJ.Data.Constrained.Endpoint_Checks;
with MJ.Data.Constrained.Flex.Test_Export;
with SDF_Load_Checks;
with Flex_Load_Checks;
procedure Flex_Constrained_Probe is
   package F renames MJ.Data.Constrained.Flex;
   package IO is new Ada.Text_IO.Float_IO (Real);
   use type MJ.Models.Sizes;
   use type Capacities;
   use type Interfaces.Unsigned_8;
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
   MJ.Data.Constrained.Endpoint_Checks;
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Bytes, Read_OK);
   if not Read_OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all, M, Loaded);
   Free_Byte (Bytes);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   if Ada.Command_Line.Argument_Count > 1 and then
     Ada.Command_Line.Argument (2) = "flex-load-checks" then
      Flex_Load_Checks (M); MJ.Models.Free (M); return;
   end if;
   if Ada.Command_Line.Argument_Count > 1 and then
     Ada.Command_Line.Argument (2) = "load-checks" then
      SDF_Load_Checks (M); MJ.Models.Free (M); return;
   end if;
   declare
      Saved : constant MJ.Models.Sizes := M.S;
      Saved_Pointer : constant Int_Array_Access := M.Flexes.Flex_Vertbodyid;
      Saved_Caps : constant Capacities := M.Caps;
      Saved_Adhesion : constant Boolean := M.Flg_Adhesion;
      Saved_Eq_Pointer : constant Int_Array_Access := M.Equalities.Eq_Type;
      Saved_Eq_Names : constant Int_Array_Access := M.Names.Name_Eqadr;
      Saved_Active : constant Byte_Array := M.Equalities.Eq_Active0.all;
      Saved_Types : constant Int_Array := M.Geoms.Geom_Type.all;
      Saved_Dataids : constant Int_Array := M.Geoms.Geom_Dataid.all;
      Saved_Sizes : constant Real_Array := M.Geoms.Geom_Size.all;
      Q : State_Vector (0 .. M.S.Nq - 1);
      V : State_Vector (0 .. M.S.Nv - 1);
      A : State_Vector (0 .. M.S.Na - 1);
      Nu : constant Natural := M.S.Nu;
      Begin_Time, End_Time : Ada.Real_Time.Time;
   begin
      F.Create (M, E, Result);
      if M.S /= Saved or else M.Flexes.Flex_Vertbodyid /= Saved_Pointer
        or else M.Caps /= Saved_Caps or else M.Flg_Adhesion /= Saved_Adhesion then raise Program_Error with "borrow not restored"; end if;
      if M.Geoms.Geom_Type.all /= Saved_Types or else M.Geoms.Geom_Dataid.all /= Saved_Dataids
        or else M.Geoms.Geom_Size.all /= Saved_Sizes then raise Program_Error with "geom proxy not restored"; end if;
      if M.Equalities.Eq_Type /= Saved_Eq_Pointer or else M.Names.Name_Eqadr /= Saved_Eq_Names then
         raise Program_Error with "equality ownership not restored";
      end if;
      if Result /= Success then Put_Line ("create " & Result'Image); MJ.Models.Free (M); return; end if;
      if F.Equality_Count (E) /= Saved.Neq then raise Program_Error with "equality count"; end if;
      for Id in 0 .. Saved.Neq-1 loop
         if F.Equality_Active (E, Id) /= (Saved_Active (Id) /= 0) then
            raise Program_Error with "equality activity";
         end if;
      end loop;
      F.Create (M, E, Result); if Result /= Already_Allocated then raise Program_Error with "double create"; end if;
      MJ.Models.Free (M);
      declare Before : constant Real_Array := F.Complete_State (E); begin
         F.Set_State (E, State_Vector'(1 .. 0 => 0.0), State_Vector'(1 .. 0 => 0.0), 0.0, Result);
         if Result /= Invalid_Size or else F.Complete_State (E) /= Before then raise Program_Error with "state atomicity"; end if;
         F.Set_Equality_Active (E, F.Equality_Count (E), False, Result);
         if Result /= Invalid_Index or else F.Complete_State (E) /= Before then
            raise Program_Error with "equality invalid index atomicity";
         end if;
      end;
      Ada.Integer_Text_IO.Get (Cases); Ada.Integer_Text_IO.Get (Steps);
      for Sample in 1 .. Cases loop
         IO.Get (T);
         for I in Q'Range loop IO.Get (X); Q (I) := X; end loop;
         for I in V'Range loop IO.Get (X); V (I) := X; end loop;
         F.Set_State (E, Q, V, T, Result); Check;
         if Ada.Command_Line.Argument_Count > 2
           and then Ada.Command_Line.Argument (3) = "toggle" and then F.Equality_Count (E) > 0 then
            F.Set_Equality_Active (E, 0, Sample mod 3 /= 2, Result); Check;
         end if;
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
               Emit ("counts", [Real (D.Ncontact), Real (D.Nrow)]);
               if Ada.Command_Line.Argument_Count > 1
                 and then Ada.Command_Line.Argument (2) = "diagnostic" then
                  for C of F.Contacts (E) loop
                     Emit ("contact", [C.Geometry.Distance, C.Geometry.Position (0), C.Geometry.Position (1),
                       C.Geometry.Position (2), C.Geometry.Normal (0), C.Geometry.Normal (1), C.Geometry.Normal (2)]);
                  end loop;
                  Emit ("aref", Real_Array (D.Aref (1 .. D.Nrow)));
                  Emit ("reg", Real_Array (D.R (1 .. D.Nrow)));
                  Emit ("force", Real_Array (D.Force (1 .. D.Nrow)));
                  declare Ids : constant Int_Array :=
                    MJ.Data.Constrained.Flex.Test_Export.Equality_Ids (E); begin
                     Emit ("eqids", [for K in Ids'Range => Real (Ids (K))]);
                  end;
                  for R in 1 .. D.Nrow loop Emit ("jac", Real_Array'[for V in 1 .. D.Nv => D.J (R, V)]); end loop;
               end if;
               Emit ("passive", F.Passive (E));
               Emit ("free", Real_Array (D.A_Free (1 .. D.Nv)));
               Emit ("acc", Real_Array (D.Acceleration (1 .. D.Nv)));
               Emit ("constraint", Real_Array (D.Constraint_Force (1 .. D.Nv)));
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
end Flex_Constrained_Probe;
