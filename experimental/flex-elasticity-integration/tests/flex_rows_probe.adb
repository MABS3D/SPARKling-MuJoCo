with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Interfaces;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.File_IO;
with MJ.Data; use MJ.Data;
with MJ.Data.Flex_Elasticity;
with MJ.Data.Flex_Elasticity.Equalities;
with MJ.Constraint_Assembly;
procedure Flex_Rows_Probe is
   use type Interfaces.Unsigned_8;
   use type Interfaces.Unsigned_32;
   package F renames MJ.Data.Flex_Elasticity;
   package EQ renames MJ.Data.Flex_Elasticity.Equalities;
   package CA renames MJ.Constraint_Assembly;
   use type CA.Storage;
   use type EQ.Response_Array;
   package IO is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   E : F.Engine;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Bytes : Byte_Array_Access;
   Read_OK : Boolean;
   Cases : Integer;
   Atomic_Checks : Natural := 0;
   X, T : Real;
   Sparse : constant Boolean := Ada.Command_Line.Argument_Count < 2
     or else Ada.Command_Line.Argument (2) /= "dense";
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
   procedure Emit (Name : String; A : Real_Array) is
   begin
      Put (Name);
      for V of A loop Put (' '); IO.Put (V, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end Emit;
begin
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1), Bytes, Read_OK);
   if not Read_OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Bytes.all, M, Loaded); Free_Byte (Bytes);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   declare
      Neq : constant Natural := M.S.Neq;
      Objects : constant Int_Array := M.Equalities.Eq_Obj1id.all;
      Active : constant Byte_Array := M.Equalities.Eq_Active0.all;
      Equality_Disabled : constant Boolean :=
        (Interfaces.Unsigned_32 (M.Opt.Disableflags) and Interfaces.Unsigned_32 (Dsbl_Equality)) /= 0;
      Q : State_Vector (0 .. M.S.Nq-1);
      V : State_Vector (0 .. M.S.Nv-1);
      Rows : CA.Storage (64, 4096);
      Responses : EQ.Response_Array (1 .. 64) := [others => <>];
      Empty : MJ.Models.Equality_Arrays;
      Saved : MJ.Models.Equality_Arrays;
      Empty_Sizes : MJ.Models.Sizes;
      Empty_Name : Int_Array_Access := null;
      Saved_Name : Int_Array_Access;
      procedure Restore is
      begin
         Empty := M.Equalities; Empty_Name := M.Names.Name_Eqadr;
         M.Equalities := Saved; M.S.Neq := Neq; M.Names.Name_Eqadr := Saved_Name;
         Saved := (others => <>); Saved_Name := null;
         MJ.Models.Free_Equality (Empty); Free_Int (Empty_Name);
      end Restore;
   begin
      for Kind of M.Equalities.Eq_Type.all loop
         if Kind /= 4 then raise Program_Error with "isolated FLEX row probe"; end if;
      end loop;
      --  This is an isolated producer test, not a constrained dynamics entry.
      --  The existing smooth factory does not yet admit FLEX equalities. Borrow
      --  an equality-free view for its kinematics, restoring the source model
      --  before freeing it. No equality force is integrated by this probe.
      MJ.Models.Allocate_Equality (Empty_Sizes, Empty);
      Empty_Name := new Int_Array'(0 .. -1 => 0);
      Saved := M.Equalities; Saved_Name := M.Names.Name_Eqadr;
      M.Equalities := Empty; M.Names.Name_Eqadr := Empty_Name; M.S.Neq := 0;
      Empty := (others => <>); Empty_Name := null;
      begin
         F.Create (M, E, Result);
      exception
         when others => Restore; raise;
      end;
      Restore; Check;
      MJ.Models.Free (M);
      Ada.Integer_Text_IO.Get (Cases);
      for Sample in 1 .. Cases loop
         Atomic_Checks := 0;
         IO.Get (T);
         for I in Q'Range loop IO.Get (X); Q (I) := X; end loop;
         for I in V'Range loop IO.Get (X); V (I) := X; end loop;
         F.Set_State (E, Q, V, T, Result); Check;
         F.Evaluate (E, Result); Check;
         CA.Reset (Rows, V'Length);
         if not Equality_Disabled then
            for Id in 0 .. Neq-1 loop
               if Active (Id) /= 0 then
                  EQ.Append_Edges (E, Objects (Id), Id, Rows, Responses, Result, Sparse); Check;
               end if;
            end loop;
         end if;
         --  A one-row buffer must reject a multi-edge equality atomically,
         --  including when its first row alone would fit.
         for Id in 0 .. Neq-1 loop
            declare Count : Natural := 0; begin
               for R in 1 .. Rows.Rows loop
                  if Rows.Descriptors (R).Id = Id then Count := Count+1; end if;
               end loop;
               if Count > 1 then
                  declare
                     Small : CA.Storage (1, 4096);
                     Small_Response : EQ.Response_Array (1 .. 1) := [1 => (123.0, 456.0)];
                  begin
                     CA.Reset (Small, V'Length);
                     declare
                        Before : constant CA.Storage := Small;
                        Before_Response : constant EQ.Response_Array := Small_Response;
                     begin
                        EQ.Append_Edges (E, Objects (Id), Id, Small, Small_Response, Result, Sparse);
                        if Result /= Capacity_Exceeded or else Small /= Before
                          or else Small_Response /= Before_Response then
                           raise Program_Error with "equality capacity rollback";
                        end if;
                        Atomic_Checks := Atomic_Checks+1;
                     end;
                  end;
               end if;
            end;
         end loop;
         Put_Line ("case" & Sample'Image);
         Emit ("atomic_capacity", [Real (Atomic_Checks)]);
         Emit ("ids", [for R in 1 .. Rows.Rows => Real (Rows.Descriptors (R).Id)]);
         Emit ("pos", [for R in 1 .. Rows.Rows => Rows.Descriptors (R).Param.Position]);
         Emit ("weight", [for R in 1 .. Rows.Rows => Responses (R).Weight]);
         Emit ("rowadr", [for R in 1 .. Rows.Rows => Real (Rows.Descriptors (R).Offset)]);
         Emit ("rownnz", [for R in 1 .. Rows.Rows => Real (Rows.Descriptors (R).Nonzeros)]);
         Emit ("columns", [for K in 1 .. Rows.Used => Real (Rows.Columns (K))]);
         Emit ("values", [for V of Rows.Values (1 .. Rows.Used) => Real (V)]);
      end loop;
      F.Free (E, Result); Check;
   end;
exception
   when Error : others =>
      Put_Line (Ada.Exceptions.Exception_Information (Error));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end Flex_Rows_Probe;
