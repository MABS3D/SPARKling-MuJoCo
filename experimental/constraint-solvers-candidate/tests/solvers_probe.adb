with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Command_Line;
with MJ.Types; use MJ.Types;
with MJ.Constraint_Solvers; use MJ.Constraint_Solvers;
procedure Solvers_Probe is
   package IO is new Ada.Text_IO.Float_IO (Real);
   N, K, Algorithm, Repeats, Int_Value : Integer;
   Opt : Options;
   Info : Report;
   With_Force : constant Boolean := Ada.Command_Line.Argument_Count > 0
     and then Ada.Command_Line.Argument (1) = "--with-force";
   With_Smooth : constant Boolean := Ada.Command_Line.Argument_Count >= 2
     and then Ada.Command_Line.Argument (2) = "--smooth-force";
   With_Native : constant Boolean := Ada.Command_Line.Argument_Count >= 3
     and then Ada.Command_Line.Argument (3) = "--native-mass";
   procedure Get (V : out Integer) is begin Ada.Integer_Text_IO.Get (V); end Get;
   procedure Get (V : out Real) is begin IO.Get (V); end Get;
   procedure Put (V : Real) is
   begin IO.Put (V, Fore => 1, Aft => 17, Exp => 3); Put (' '); end Put;
begin
   while not End_Of_File loop
      Get (N); Get (K); Get (Algorithm); Get (Repeats);
      Opt.Sparse := Algorithm >= 3;
      Opt.Algorithm := Method'Val (Algorithm mod 3);
      Get (Int_Value); Opt.Iterations := Int_Value;
      Get (Int_Value); Opt.LS_Iterations := Int_Value;
      Get (Opt.Tolerance); Get (Opt.LS_Tolerance); Get (Opt.Scale);
      declare
         M : Matrix (1 .. N, 1 .. N);
         J : Matrix (1 .. K, 1 .. N);
         Free, A0, A : Vector (1 .. N);
         Original_Smooth : Vector (1 .. (if With_Smooth then N else 0));
         Mass_Lower : Sparse_Jacobian ((if With_Native then N else 0), (if With_Native then N*N else 0));
         Mass_Inverse : Vector (1 .. (if With_Native then N else 0));
         Generalized : Vector (1 .. N) := (others => 0.375);
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
         declare
            Stored : Natural := 0;
         begin
            if Algorithm >= 6 then Get (Int_Value); Stored := Int_Value; end if;
            declare
               Native : Sparse_Jacobian ((if Algorithm >= 6 then K else 0), Stored);
            begin
               for R in 1 .. Native.Row_Count loop
                  Get (Int_Value); Native.Offsets (R) := Int_Value;
                  Get (Int_Value); Native.Widths (R) := Int_Value;
               end loop;
               for V of Native.Columns loop Get (Int_Value); V := Int_Value; end loop;
               for V of Native.Values loop Get (V); end loop;
               for X of Original_Smooth loop Get (X); end loop;
               if With_Native then
                  declare Entries : Natural; begin
                     Mass_Lower.Columns := (others => 1); Mass_Lower.Values := (others => 0.0);
                     Get (Int_Value); Entries := Int_Value;
                     for R in 1 .. N loop
                        Get (Int_Value); Mass_Lower.Offsets (R) := Int_Value;
                        Get (Int_Value); Mass_Lower.Widths (R) := Int_Value-1;
                     end loop;
                     for K in 1 .. Entries loop Get (Int_Value); Mass_Lower.Columns (K) := Int_Value+1; end loop;
                     for K in 1 .. Entries loop Get (Mass_Lower.Values (K)); end loop;
                     for K in 1 .. N loop Get (Mass_Inverse (K)); end loop;
                  end;
               end if;
               for Repeat in 1 .. Repeats loop
                  A := A0; F := F0;
                  if With_Force then
                     Generalized := (others => 0.375);
                     Solve_With_Force (M, J, Free, Aref, C, Opt, A, F,
                       Generalized, Info, Ordered_Jacobian => Native, Smooth_Force => Original_Smooth,
                       Native_Factor => Mass_Lower, Native_Inverse => Mass_Inverse);
                  else
                     Solve (M, J, Free, Aref, C, Opt, A, F, Info,
                            Ordered_Jacobian => Native, Smooth_Force => Original_Smooth,
                       Native_Factor => Mass_Lower, Native_Inverse => Mass_Inverse);
                  end if;
               end loop;
               if With_Smooth then
                  declare
                     Saved_A : constant Vector := A;
                     Saved_F : constant Vector := F;
                     Saved_G : constant Vector := Generalized;
                     Bad_Origin : constant Vector (2 .. N+1) := (others => 0.0);
                     Bad_Size : constant Vector (1 .. N+1) := (others => 0.0);
                     Bad_Value : Vector (1 .. N) := (others => 0.0);
                     procedure Check_Rejected (Bad : Vector) is
                        Rejected : Report;
                     begin
                        Solve_With_Force (M, J, Free, Aref, C, Opt, A, F,
                          Generalized, Rejected, Ordered_Jacobian => Native, Smooth_Force => Bad,
                          Native_Factor => Mass_Lower, Native_Inverse => Mass_Inverse);
                        if Rejected.Outcome /= Invalid_Input or A /= Saved_A
                          or F /= Saved_F or Generalized /= Saved_G
                        then raise Program_Error with "smooth force rejection was not atomic";
                        end if;
                     end Check_Rejected;
                  begin
                     Bad_Value (1) := 1.0e101;
                     Check_Rejected (Bad_Origin);
                     Check_Rejected (Bad_Size);
                     Check_Rejected (Bad_Value);
                  end;
               end if;
               if With_Force then
                  declare
                     Saved_A : constant Vector := A;
                     Saved_F : constant Vector := F;
                     Bad_Force : Vector (2 .. N+1) := (others => 0.625);
                     Rejected : Report;
                  begin
                     Solve_With_Force (M, J, Free, Aref, C, Opt, A, F,
                       Bad_Force, Rejected, Ordered_Jacobian => Native, Smooth_Force => Original_Smooth,
                       Native_Factor => Mass_Lower, Native_Inverse => Mass_Inverse);
                     if Rejected.Outcome /= Invalid_Input or A /= Saved_A
                       or F /= Saved_F or (for some X of Bad_Force => X /= 0.625)
                     then raise Program_Error with "force shape rejection was not atomic";
                     end if;
                  end;
               end if;
            end;
         end;
         Put (Status'Image (Info.Outcome));
         Put (Natural'Image (Info.Iterations)); Put (Natural'Image (Info.Evaluations));
         Put (Natural'Image (Info.Restarts));
         Put (Natural'Image (Info.Line_Search_Limits));
         Put (Natural'Image (Info.Curvature_Repairs)); Put (' ');
         Put (Info.Cost); Put (Info.Gradient); Put (Info.Improvement);
         for X of A loop Put (X); end loop;
         for X of F loop Put (X); end loop;
         if With_Force then for X of Generalized loop Put (X); end loop; end if;
         New_Line;
      end;
      if not End_Of_File then Skip_Line; end if;
   end loop;
end Solvers_Probe;
