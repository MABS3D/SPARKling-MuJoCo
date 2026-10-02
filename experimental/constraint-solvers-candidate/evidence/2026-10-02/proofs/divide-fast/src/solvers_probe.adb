with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
procedure Solvers_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, K, Algorithm, Repeats, Int_Value : Integer;
   Opt : Options;
   Info : Report;
   procedure Get (V : out Integer) is begin Ada.Integer_Text_IO.Get (V); end Get;
   procedure Get (V : out Real) is begin IO.Get (V); end Get;
   procedure Put (V : Real) is
   begin IO.Put (V, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put;
begin
   while not End_Of_File loop
      Get (N); Get (K); Get (Algorithm); Get (Repeats);
      Opt.Algorithm := Method'Val (Algorithm);
      Get (Int_Value); Opt.Iterations := Int_Value;
      Get (Int_Value); Opt.LS_Iterations := Int_Value;
      Get (Opt.Tolerance); Get (Opt.LS_Tolerance); Get (Opt.Scale);
      declare
         M : Matrix (1 .. N, 1 .. N);
         J : Matrix (1 .. K, 1 .. N);
         Free, A0, A : Vector (1 .. N);
         Aref, F0, F : Vector (1 .. K);
         C : Rows (1 .. K);
      begin
         for P in 1 .. N loop for Q in 1 .. N loop Get (M (P, Q)); end loop; end loop;
         for P in 1 .. K loop for Q in 1 .. N loop Get (J (P, Q)); end loop; end loop;
         for X of Free loop Get (X); end loop;
         for X of Aref loop Get (X); end loop;
         for X of A0 loop Get (X); end loop;
         for X of F0 loop Get (X); end loop;
         for R of C loop
            Get (Int_Value); R.Form := Kind'Val (Int_Value);
            Get (Int_Value); R.Dimension := Int_Value;
            Get (R.R); Get (R.D); Get (R.Bound); Get (R.Mu);
            for X of R.Friction loop Get (X); end loop;
         end loop;
         for Repeat in 1 .. Repeats loop
            A := A0; F := F0;
            Solve (M, J, Free, Aref, C, Opt, A, F, Info);
         end loop;
         Put (Status'Image (Info.Outcome));
         Put (Natural'Image (Info.Iterations)); Put (Natural'Image (Info.Evaluations));
         Put (Natural'Image (Info.Restarts));
         Put (Natural'Image (Info.Line_Search_Limits));
         Put (Natural'Image (Info.Curvature_Repairs)); Put (' ');
         Put (Info.Cost); Put (Info.Gradient); Put (Info.Improvement);
         for X of A loop Put (X); end loop;
         for X of F loop Put (X); end loop;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Solvers_Probe;
