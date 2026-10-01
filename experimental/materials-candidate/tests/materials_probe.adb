with Ada.Text_IO; use Ada.Text_IO;
with Ada.Float_Text_IO;
with Ada.Assertions;
with MJ.Types; use MJ.Types;
with MJ.Elastic_Materials;
with MJ.Contact_Materials;

procedure Materials_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   package E renames MJ.Elastic_Materials;
   package C renames MJ.Contact_Materials;
   procedure Put (X : Real) is
   begin
      IO.Put (X, Fore => 1, Aft => 17, Exp => 3); Put (' ');
   end Put;
   procedure Put (P : C.Parameters) is
   begin
      Put (Real (P.Condim));
      for X of P.Solref loop Put (X); end loop;
      for X of P.Solref_Friction loop Put (X); end loop;
      for X of P.Solimp loop Put (X); end loop;
      for X of P.Friction loop Put (X); end loop;
      Put (P.Adhesion);
   end Put;
begin
   while not End_Of_File loop
      declare
         Line : constant String := Get_Line;
         Pos : Positive := Line'First;
         function Read return Real is
            V : Real; Last : Positive;
         begin
            IO.Get (Line (Pos .. Line'Last), V, Last); Pos := Last + 1;
            return V;
         end Read;
         function Read_Surface return C.Surface is
            S : C.Surface;
         begin
            S.Kind := C.Surface_Kind'Val (Integer (Read));
            S.Priority := Integer (Read); S.Condim := Integer (Read);
            S.Solmix := Read;
            for X of S.Solref loop X := Read; end loop;
            for X of S.Solimp loop X := Read; end loop;
            for X of S.Friction loop X := Read; end loop;
            S.Adhesion := Read; S.Margin := Read; S.Gap := Read;
            return S;
         end Read_Surface;
         Op : constant Integer := Integer (Read);
      begin
         if Op = 1 then
            declare
               Kind : constant E.Element_Kind := E.Element_Kind'Val (Integer (Read));
               M : E.Material;
               Measure : E.Measure_Value;
               H : E.Step_Value;
               Length, Rest : Nonneg_Tier0;
               Velocity : Tier0_Real;
               Damp, Spring : Boolean;
               Basis : E.Element_Basis;
               Metric : E.Element_Metric;
            begin
               M.Young := Read; M.Poisson := Read; M.Thickness := Read;
               M.Rayleigh_Damping := Read; Measure := Read; H := Read;
               Length := Read; Rest := Read; Velocity := Read;
               Damp := Read /= 0.0; Spring := Read /= 0.0;
               for B of Basis loop for X of B loop X := Read; end loop; end loop;
               if H > 0.0 and then H < Min_Val then
                  raise Constraint_Error;
               end if;
               E.Compile_Metric (M, Kind, Measure, Basis, Metric);
               Put (E.Shear (M)); Put (E.Lame_Simplex (M));
               Put (E.Lame_Interpolated (M)); Put (E.Lame_Plane_Stress (M));
               Put (E.Bending_Modulus (M));
               Put (E.Weighted_Shear (M, Kind, Measure));
               Put (E.Weighted_Lame (M, Kind, Measure));
               Put (E.Damping_Scale (M, H, Damp));
               Put (E.Spring_Elongation (Length, Rest, Spring));
               Put (E.Damper_Elongation (M, Length, Velocity, H, Damp));
               for X of Metric loop Put (X); end loop;
               New_Line;
            end;
         elsif Op = 2 then
            declare
               A : constant C.Surface := Read_Surface;
               B : constant C.Surface := Read_Surface;
               Pair : C.Explicit_Pair;
               Override : C.Override_Options;
               Distance : C.Wide_Value;
               Self : Boolean;
               R : C.Prepared_Contact;
            begin
               Pair.Enabled := Read /= 0.0; Pair.Condim := Integer (Read);
               for X of Pair.Solref loop X := Read; end loop;
               for X of Pair.Solref_Friction loop X := Read; end loop;
               for X of Pair.Solimp loop X := Read; end loop;
               for X of Pair.Friction loop X := Read; end loop;
               Pair.Adhesion := Read; Pair.Margin := Read; Pair.Gap := Read;
               Override.Enabled := Read /= 0.0;
               for X of Override.Solref loop X := Read; end loop;
               for X of Override.Solimp loop X := Read; end loop;
               for X of Override.Friction loop X := Read; end loop;
               Override.Margin := Read; Distance := Read; Self := Read /= 0.0;
               R := C.Prepare (A, B, Pair, Override, Distance, Self);
               Put (C.Mix (A, B)); Put (R.Values);
               Put (R.Include_Margin); Put (R.Detection_Gap);
               Put (Real (Boolean'Pos (R.Excluded))); New_Line;
            end;
         else
            Put_Line ("REJECTED");
         end if;
      exception
         when Constraint_Error | Ada.Text_IO.Data_Error | Ada.Assertions.Assertion_Error =>
            Put_Line ("REJECTED");
      end;
   end loop;
end Materials_Probe;
