with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;
with MJ.Compact_Inertia;
with MJ.Smooth_Dynamics;
with MJ.Spatial_Kernels;
procedure Compact_CRB_Rows_Probe is
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package AR renames MJ.Ancestor_Rows;
   Cases : Natural;
begin
   Ada.Integer_Text_IO.Get (Cases);
   for Case_Number in 1 .. Cases loop
      declare
         N, Row, Origin, Simple_Int : Natural;
      begin
         Ada.Integer_Text_IO.Get (N);
         Ada.Integer_Text_IO.Get (Row);
         Ada.Integer_Text_IO.Get (Origin);
         Ada.Integer_Text_IO.Get (Simple_Int);
         declare
            Parents : Int_Array (0 .. N - 1);
            Motions : Real_Array (0 .. 6 * N - 1);
            Composite : MJ.Spatial_Kernels.Inertia;
            Armature, Fixed : Real;
            P : AR.Pattern;
         begin
            for I in Parents'Range loop Ada.Integer_Text_IO.Get (Parents (I)); end loop;
            for I in Motions'Range loop RIO.Get (Motions (I)); end loop;
            for I in Composite'Range loop RIO.Get (Composite (I)); end loop;
            RIO.Get (Armature); RIO.Get (Fixed);
            AR.Build (P, Parents);
            declare
               Width : constant Natural := AR.Length (P, Row);
               Target : Real_Array (Origin .. Origin + (Width - 1)) := [others => -0.125];
               Mass : Real_Array (0 .. AR.Count (P) - 1) := [others => -0.125];
               Ok, Slab_Ok : Boolean;
            begin
               MJ.Compact_Inertia.Assemble_Row
                 (P, Row, Motions, Composite, Armature, Fixed, Simple_Int = 1, Target, Ok);
               MJ.Compact_Inertia.Assemble_Into_Row
                 (P, Row, Motions, Composite, Armature, Fixed, Simple_Int = 1, Mass, Slab_Ok);
               if Ok /= Slab_Ok or else not MJ.Smooth_Dynamics.Work_Array (Mass)
                 or else not MJ.Smooth_Dynamics.Work_Array (Target)
               then raise Program_Error with "row/slab acceptance or bounds"; end if;
               for A in 0 .. Width - 1 loop
                  if Target (Origin + A) /= Mass (AR.Start (P, Row) + A) then
                     raise Program_Error with "row/slab values";
                  end if;
               end loop;
               for K in Mass'Range loop
                  if (K < AR.Start (P, Row) or else K >= AR.Start (P, Row) + Width)
                    and then Mass (K) /= -0.125
                  then raise Program_Error with "untouched frame"; end if;
               end loop;
               Put ("row " & Boolean'Image (Ok));
               for X of Target loop
                  Put (' '); RIO.Put (X, Fore => 1, Aft => 17, Exp => 3);
               end loop;
               New_Line;
            end;
            AR.Free (P);
         end;
      end;
   end loop;
end Compact_CRB_Rows_Probe;
