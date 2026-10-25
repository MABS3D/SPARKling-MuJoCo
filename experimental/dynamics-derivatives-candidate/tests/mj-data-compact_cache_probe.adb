with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Fields;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.MJB;
with MJ.Data.Forward;
with MJ.Data.Inertia;
--  Test-only child: observes actual cache selection and untouched dense storage.
--  No production code calls this probe or relies on its observations as axioms.
procedure MJ.Data.Compact_Cache_Probe with SPARK_Mode => Off is
   package Numbers is new Ada.Text_IO.Float_IO (Real);
   M : MJ.Models.Model;
   D : Simulation;
   Loaded : MJ.Fields.Load_Result;
   Result : Status;
   Cases : Natural;
   Selected : constant Inertia_Policy :=
     (if Ada.Command_Line.Argument (2) = "strict" then Strict else Compatible);
   procedure Check is
   begin
      if Result /= Success then raise Program_Error with Result'Image; end if;
   end Check;
begin
   MJ.MJB.Load (Ada.Command_Line.Argument (1), (Contact_Cap => 0), M, Loaded);
   if Loaded.Status /= MJ.Types.OK then raise Program_Error with Loaded.Status'Image; end if;
   Create (M, D, Result, Solver_Policy => Selected); Check;
   MJ.Models.Free (M);
   Ada.Integer_Text_IO.Get (Cases);
   declare
      Q : State_Vector (0 .. D.Nq - 1);
      V : State_Vector (0 .. D.Nv - 1);
      Dense : Real_Array (0 .. D.Nv * D.Nv - 1);
      X : Real;
      Expected_Compact : constant Boolean := D.Nv >= 3;
   begin
      for Sample in 1 .. Cases loop
         Reset (D, Result); Check;
         if D.Cache.Mass_Compact or else Mass_Current (D) then
            raise Program_Error with "reset cache flags";
         end if;
         for Y of Q loop Numbers.Get (X); Y := X; end loop;
         for Y of V loop Numbers.Get (X); Y := X; end loop;
         Set_State (D, Q, V, 0.125, Result); Check;
         MJ.Data.Forward.Evaluate (D, Result); Check;
         if D.Cache.Mass_Compact /= Expected_Compact or else not Mass_Current (D) then
            raise Program_Error with "expected compact route not executed";
         end if;
         if Expected_Compact and then (for some Y of D.Dynamics.Mass.all => Y /= 0.0) then
            raise Program_Error with "normal compact route wrote the legacy dense slab";
         end if;
         declare
            Saved : constant Real_Array := D.Dynamics.Compact_Mass.all;
         begin
            MJ.Data.Inertia.Solve_Euler (D, Result); Check;
            if Saved /= D.Dynamics.Compact_Mass.all then
               raise Program_Error with "factorization modified the published compact mass";
            end if;
         end;
         Get_Mass_Matrix (D, Dense, Result); Check;
         Put ("mass");
         for Y of Dense loop Put (' '); Numbers.Put (Y, Fore => 1, Aft => 17, Exp => 3); end loop;
         New_Line;
         --  Solve_Euler leaves its damped acceleration in the integration scratch.
         Put ("euler_velocity");
         for I in D.Scratch.Solution'Range loop
            Put (' ');
            Numbers.Put (V (I) + D.Timestep * D.Scratch.Solution (I), Fore => 1, Aft => 17, Exp => 3);
         end loop;
         New_Line;
         Set_State (D, Q, V, 0.125, Result); Check;
         Get_Mass_Matrix (D, Dense, Result);
         if Result /= Stale_Results or else (for some Y of Dense => Y /= 0.0) then
            raise Program_Error with "stale cache exposure";
         end if;
      end loop;
   end;
   Free (D);
   if not Is_Empty (D) or else D.Dynamics.Compact_Mass /= null then
      raise Program_Error with "compact storage lifetime";
   end if;
end MJ.Data.Compact_Cache_Probe;
