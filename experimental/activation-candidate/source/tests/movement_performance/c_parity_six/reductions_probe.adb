with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Dynamics; use MJ.Smooth_Dynamics;
with MJ.Smooth_Math; use MJ.Smooth_Math;
with MJ.Ancestor_Rows;
with MJ.Solver_Reductions;

procedure Reductions_Probe is
   package AR renames MJ.Ancestor_Rows;
   package SR renames MJ.Solver_Reductions;
   P : AR.Pattern;
   Parents : Int_Array (0 .. 255);
   Factor : Real_Array_Access;
   Values : Real_Array (0 .. 255) := [others => 0.0];
   Cases : Natural := 0;
   Current_Row, Current_Bad : Natural := 0;
   procedure Require (Condition : Boolean) is
   begin
      if not Condition then
         raise Program_Error with "row" & Current_Row'Image & " bad" & Current_Bad'Image
           & " cases" & Cases'Image;
      end if;
   end Require;

   procedure Check (Row : Natural; Previous : Work_Real) is
      N : constant Natural := AR.Length (P, Row) - 1;
      Lanes : array (0 .. 3) of Real := [others => 0.0];
      Reference, Old_Sum, Term, Candidate : Real := 0.0;
      Expected_Fast, Old_Ok, Expected_Ok : Boolean := True;
      Dot : SR.Reduction_Real;
      Value, Ordered : Work_Real;
      Fast, Ok : Boolean;
   begin
      for B in 0 .. N / 4 - 1 loop
         for L in 0 .. 3 loop
            Term := Factor (AR.Start (P, Row) + 4 * B + L)
              * Values (AR.Column (P, Row, 4 * B + L));
            if B = 0 then Lanes (L) := Term; else Lanes (L) := Lanes (L) + Term; end if;
         end loop;
      end loop;
      Reference := (Lanes (0) + Lanes (2)) + (Lanes (1) + Lanes (3));
      for A in 4 * (N / 4) .. N - 1 loop
         Reference := Reference + Factor (AR.Start (P, Row) + A) * Values (AR.Column (P, Row, A));
      end loop;
      for A in 0 .. N - 1 loop
         Term := Factor (AR.Start (P, Row) + A) * Values (AR.Column (P, Row, A));
         if abs Term > SR.Fast_Product_Limit then Expected_Fast := False; end if;
         if Old_Ok then
            Old_Sum := Old_Sum + Term;
            if Old_Sum not in Work_Real then Old_Ok := False; end if;
         end if;
      end loop;
      SR.Dot_Four (P, Row, Factor.all, Values, Dot, Fast);
      Require (Dot = Reference and then Fast = Expected_Fast);
      SR.Dot_Ordered (P, Row, Factor.all, Values, Ordered, Ok);
      Require (Ok = Old_Ok and then (if Ok then Ordered = Old_Sum));
      Candidate := Previous - Reference;
      if not (Expected_Fast and then abs Previous <= SR.Fast_Previous_Limit
        and then Candidate in Work_Real)
      then
         Candidate := Previous - Old_Sum;
         Expected_Ok := Old_Ok and then Candidate in Work_Real;
      end if;
      SR.Forward_Value (P, Row, Factor.all, Values, Previous, Value, Ok);
      Require (Ok = Expected_Ok);
      Require (if Ok then Value = Candidate else Value = 0.0);
      --  The SIMD domain preserves the old acceptance status, although its
      --  rounded value deliberately follows the C lane order.
      Require (Ok = (Old_Ok and then Previous - Old_Sum in Work_Real));
      Cases := Cases + 1;
   end Check;

   procedure Populate (Row : Natural) is
   begin
      Factor.all := [others => 0.0];
      for I in Values'Range loop Values (I) := Real ((I * 19) mod 37 - 18) / 8.0; end loop;
      for A in 0 .. AR.Length (P, Row) - 2 loop
         Factor (AR.Start (P, Row) + A) := Real ((A * 13) mod 41 - 20) / 16.0;
      end loop;
   end Populate;
begin
   for Shape in 0 .. 1 loop
      for I in Parents'Range loop
         Parents (I) := (if I < Shape + 1 then -1 else I - (Shape + 1));
      end loop;
      AR.Build (P, Parents);
      Factor := new Real_Array'(0 .. AR.Count (P) - 1 => 0.0);
      for Row in 0 .. 255 loop
         Current_Row := Row;
         Populate (Row);
         Check (Row, 0.375);
         Check (Row, SR.Fast_Previous_Limit);
         Check (Row, Real'Adjacent (SR.Fast_Previous_Limit, Real'Last));
         Check (Row, Work_Limit);
         Check (Row, -Work_Limit);
         for A in 0 .. AR.Length (P, Row) - 2 loop
            if AR.Length (P, Row) > 33
              and then AR.Length (P, Row) not in 63 .. 66
              and then AR.Length (P, Row) not in 127 .. 130
              and then AR.Length (P, Row) not in 255 .. 256
            then exit; end if;
            Current_Bad := A;
            for Sign in -1 .. 1 loop
               if Sign /= 0 then
                  for Boundary in 0 .. 3 loop
                     Factor.all := [others => 0.0];
                     Values := [others => 1.0];
                     Factor (AR.Start (P, Row) + A) := Real (Sign)
                       * (case Boundary is
                            when 0 => SR.Fast_Product_Limit,
                            when 1 => Real'Adjacent (SR.Fast_Product_Limit, Real'Last),
                            when others => Work_Limit);
                     Values (AR.Column (P, Row, A)) := (case Boundary is
                       when 2 => 2.0, when 3 => Work_Limit, when others => 1.0);
                     Check (Row, 0.0);
                  end loop;
               end if;
            end loop;
         end loop;
         if AR.Length (P, Row) >= 4 then
            Factor.all := [others => 0.0]; Values := [others => 1.0];
            Factor (AR.Start (P, Row)) := Work_Limit;
            Factor (AR.Start (P, Row) + 1) := Work_Limit;
            Factor (AR.Start (P, Row) + 2) := -Work_Limit;
            Check (Row, 0.0); -- Finite final cancellation must still reject the second prefix.
         end if;
      end loop;
      Free_Real (Factor);
      AR.Free (P);
   end loop;
   Put_Line ("passed" & Cases'Image & " reduction cases");
end Reductions_Probe;
