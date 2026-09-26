with Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;
with MJ.Compact_Inertia;
with MJ.Spatial_Kernels;

procedure Compact_Inertia_Test is
   package AR renames MJ.Ancestor_Rows;
   package CI renames MJ.Compact_Inertia;
   package SK renames MJ.Spatial_Kernels;

   procedure Check (Parents : Int_Array) is
      P : AR.Pattern;
      N : constant Natural := Parents'Length;
   begin
      AR.Build (P, Parents);
      declare
         Packed : Real_Array (0 .. AR.Count (P) - 1);
         Dense : Real_Array (13 .. 12 + N * N);
         Motions : Real_Array (0 .. 6 * N - 1) := [others => 1.0];
         Product : SK.Motion := [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
         Expected : Real;
         Ancestor : Integer;
         Ok : Boolean;
      begin
         for I in 0 .. N - 1 loop
            for A in 0 .. AR.Length (P, I) - 1 loop
               Packed (AR.Start (P, I) + A) := Real (1000 * I + AR.Column (P, I, A) + 1);
            end loop;
         end loop;
         CI.Expand (P, Packed, Dense);
         --  Independent expected sparsity: walk the supplied parents,
         --  without consulting the pattern's columns or packed offsets.
         for I in 0 .. N - 1 loop
            for J in 0 .. N - 1 loop
               Ancestor := Natural'Max (I, J);
               while Ancestor >= 0 and then Ancestor /= Natural'Min (I, J) loop
                  Ancestor := Parents (Ancestor);
               end loop;
               Expected := (if Ancestor < 0 then 0.0
                 else Real (1000 * Natural'Max (I, J) + Natural'Min (I, J) + 1));
               if Dense (13 + I * N + J) /= Expected
                 or else CI.Value_At (P, Packed, I, J) /= Expected
               then
                  raise Program_Error with "expanded ancestor pattern";
               end if;
            end loop;
            declare
               Row : Real_Array (7 .. 6 + AR.Length (P, I)) := [others => 99.0];
            begin
               CI.Project_Row (P, I, Motions, Product, 3.0, Row, Ok);
               if not Ok or else Row (Row'Last) /= 24.0
                 or else (for some K in Row'First .. Row'Last - 1 => Row (K) /= 21.0)
               then
                  raise Program_Error with "projected row";
               end if;
               Row := [others => 99.0];
               CI.Project_Row (P, I, Real_Array'(Motions'Range => 1.0e12),
                               SK.Motion'[others => 1.0e54], 3.0, Row, Ok);
               if Ok or else (for some X of Row => X /= 99.0) then
                  raise Program_Error with "rejected diagonal modified row";
               end if;
            end;
         end loop;
      end;
      AR.Free (P);
   end Check;
begin
   Check ([0 .. -1 => -1]);
   Check ([-1]);
   Check ([-1, 0, 1, 2, 3, 4]);
   Check ([-1, 0, 0, 0, 0, 0]);
   Check ([-1, 0, -1, 2, 2, 1, -1, 6]);
   Check ([0 .. 255 => -1]);
   Ada.Text_IO.Put_Line ("PASS: empty, singleton, chain, star, forest, 256 independent DOFs; projection/rejection");
end Compact_Inertia_Test;
