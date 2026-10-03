with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Real_Time; use Ada.Real_Time;
with MJ.Types; use MJ.Types;
with MJ.Fields;
with MJ.Models;
with MJ.MJB;
with MJ.Data; use MJ.Data;
with MJ.Data.Constrained.SDF;
with MJ.External_Forces;

procedure SDF_Probe is
   package C renames MJ.Data.Constrained.SDF;
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   type Engine_Access is access C.Engine;
   E : Engine_Access := new C.Engine;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Original_Flags : Integer;
   Original_Types, Original_Dataids : Int_Array (0 .. 255);
   Original_Sizes : Real_Array (0 .. 767);
   Ng : Natural;
   Cases, Steps : Integer;
   With_Loads : constant Boolean := Ada.Command_Line.Argument_Count >= 2
     and then Ada.Command_Line.Argument (2) = "loads";
   Benchmark : constant Boolean := Ada.Command_Line.Argument_Count >= 2
     and then Ada.Command_Line.Argument (2) = "benchmark";
   Dump_Contacts : constant Boolean := Ada.Command_Line.Argument_Count >= 3
     and then Ada.Command_Line.Argument (3) = "contacts";
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
   procedure Emit (Name : String; Values : Real_Array) is
   begin
      Put (Name);
      for V of Values loop Put (' '); Numbers.Put (V, Fore => 1, Aft => 17, Exp => 3); end loop;
      New_Line;
   end Emit;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= OK then raise Program_Error with Loaded.Status'Image; end if;
   Original_Flags := M.Opt.Disableflags;
   Ng := M.S.Ngeom;
   for G in 0 .. Integer (Ng) - 1 loop
      Original_Types (G) := M.Geoms.Geom_Type (G);
      Original_Dataids (G) := M.Geoms.Geom_Dataid (G);
      for K in 0 .. 2 loop Original_Sizes (3 * G + K) := M.Geoms.Geom_Size (3 * G + K); end loop;
   end loop;
   C.Create (M, E.all, Result);
   if M.Opt.Disableflags /= Original_Flags then raise Program_Error with "model flags changed"; end if;
   for G in 0 .. Integer (Ng) - 1 loop
      if M.Geoms.Geom_Type (G) /= Original_Types (G) or M.Geoms.Geom_Dataid (G) /= Original_Dataids (G) then
         raise Program_Error with "source geometry changed";
      end if;
      for K in 0 .. 2 loop
         if M.Geoms.Geom_Size (3 * G + K) /= Original_Sizes (3 * G + K) then raise Program_Error with "source size changed"; end if;
      end loop;
   end loop;
   if Result /= Success then Put_Line ("create " & Result'Image); MJ.Models.Free (M); return; end if;
   declare
      Nq : constant Natural := M.S.Nq;
      Nv : constant Natural := M.S.Nv;
      Nu : constant Natural := M.S.Nu;
      Na : constant Natural := M.S.Na;
      Loads : MJ.External_Forces.Wrench_Array
        (0 .. (if With_Loads then Integer (M.S.Nbody) - 1 else -1));
      Q : State_Vector (0 .. Nq - 1);
      V : State_Vector (0 .. Nv - 1);
      Act : State_Vector (0 .. Na - 1);
      X, T : Real;
      D : C.Trace;
   begin
      C.Create (M, E.all, Result);
      if Result /= Already_Allocated then raise Program_Error with "double create"; end if;
      MJ.Models.Free (M);
      declare
         Before : constant Real_Array := C.State (E.all);
         Empty : State_Vector (1 .. 0);
         Bad_Loads : MJ.External_Forces.Wrench_Array (1 .. 1);
      begin
         C.Set_State (E.all, Empty, Empty, 0.0, Result);
         if Result /= Invalid_Size or else C.State (E.all) /= Before then
            raise Program_Error with "invalid state atomicity";
         end if;
         C.Set_Applied_Force (E.all, Nv, 1.0, Result);
         if Result /= Invalid_Index then raise Program_Error with "invalid force index"; end if;
         C.Step (E.all, Result, Bad_Loads);
         if Result /= Invalid_Size or else C.State (E.all) /= Before then
            raise Program_Error with "invalid external load atomicity";
         end if;
      end;
      Ada.Integer_Text_IO.Get (Cases); Ada.Integer_Text_IO.Get (Steps);
      for Sample in 1 .. Cases loop
         Numbers.Get (T);
         for I in Q'Range loop Numbers.Get (X); Q (I) := X; end loop;
         for I in V'Range loop Numbers.Get (X); V (I) := X; end loop;
         C.Set_State (E.all, Q, V, T, Result); Check;
         for I in 0 .. Nv - 1 loop
            Numbers.Get (X); C.Set_Applied_Force (E.all, I, X, Result); Check;
         end loop;
         for I in 0 .. Nu - 1 loop
            Numbers.Get (X); C.Set_Control (E.all, I, X, Result); Check;
         end loop;
         for I in Act'Range loop Numbers.Get (X); Act (I) := X; end loop;
         C.Set_Activation (E.all, Act, Result); Check;
         for L of Loads loop
            for I in 0 .. 2 loop Numbers.Get (X); L.Force (I) := X; end loop;
            for I in 0 .. 2 loop Numbers.Get (X); L.Torque (I) := X; end loop;
         end loop;
         if Benchmark then
            declare
               Start : constant Ada.Real_Time.Time := Clock;
            begin
               for K in 1 .. Steps loop C.Step (E.all, Result, Loads); Check; end loop;
               Emit ("seconds", [Real (To_Duration (Clock - Start))]);
            end;
         else
            C.Evaluate (E.all, Result, Loads); Check;
            D := C.Diagnostics (E.all);
            if Dump_Contacts then
               for Contact of C.Contacts (E.all) loop
                  Emit ("contact", [Contact.Distance,
                    Contact.Position (0), Contact.Position (1), Contact.Position (2),
                    Contact.Frame (0), Contact.Frame (1), Contact.Frame (2),
                    Contact.Frame (3), Contact.Frame (4), Contact.Frame (5),
                    Contact.Frame (6), Contact.Frame (7), Contact.Frame (8),
                    Real (Contact.Geoms.First), Real (Contact.Geoms.Second), Real (Contact.Dim)]);
               end loop;
            end if;
            Emit ("counts", [Real (D.Ncontact), Real (D.Nrow)]);
            Emit ("free", Real_Array (D.A_Free (1 .. Nv)));
            Emit ("acc", Real_Array (D.Acceleration (1 .. Nv)));
            Emit ("qfrc", Real_Array (D.Constraint_Force (1 .. Nv)));
            Emit ("aref", Real_Array (D.Aref (1 .. D.Nrow)));
            Emit ("reg", Real_Array (D.R (1 .. D.Nrow)));
            Emit ("force", Real_Array (D.Force (1 .. D.Nrow)));
            for R in 1 .. D.Nrow loop Emit ("jac", [for I in 1 .. Nv => D.J (R, I)]); end loop;
            if Na > 0 then Emit ("act_dot", C.Activation_Rates (E.all)); end if;
            for K in 1 .. Steps loop C.Step (E.all, Result, Loads); Check; end loop;
         end if;
         Emit ("state", C.State (E.all));
         if Na > 0 then Emit ("activation", C.Activation_Values (E.all)); end if;
      end loop;
   end;
   C.Free (E.all, Result); Check;
exception
   when Error : others =>
      Put_Line (Ada.Exceptions.Exception_Information (Error));
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
end SDF_Probe;
