package body MJ.Data.Constrained.Test_Export with SPARK_Mode => Off is
   procedure Write_Problem (E : Engine; File : Ada.Text_IO.File_Type) is
      package Numbers is new Ada.Text_IO.Float_IO (Real);
      procedure Put (Value : Real) is
      begin
         Numbers.Put (File, Value, Fore => 1, Aft => 17, Exp => 3);
         Ada.Text_IO.Put (File, ' ');
      end Put;
   begin
      if not E.T.Valid then raise Program_Error with "no prepared problem"; end if;
      Put (Real (E.D.Nv)); Put (Real (E.T.Nrow));
      Put (Real (CS.Method'Pos (E.Settings.Algorithm))); Put (1.0);
      Put (Real (E.Settings.Iterations)); Put (Real (E.Settings.LS_Iterations));
      Put (E.Settings.Tolerance); Put (E.Settings.LS_Tolerance); Put (E.Settings.Scale);
      for X of E.D.Dynamics.Mass.all loop Put (X); end loop;
      for R in 1 .. E.T.Nrow loop
         for V in 1 .. E.D.Nv loop Put (E.T.J (R, V)); end loop;
      end loop;
      for V in 1 .. E.D.Nv loop Put (E.T.A_Free (V)); end loop;
      for R in 1 .. E.T.Nrow loop Put (E.T.Aref (R)); end loop;
      for V in 1 .. E.D.Nv loop Put (E.T.A_Free (V)); end loop;
      for R in 1 .. E.T.Nrow loop Put (0.0); end loop;
      for R in 1 .. E.T.Nrow loop
         declare Row : constant CS.Row := E.Solver_Rows (R); begin
            Put (Real (CS.Kind'Pos (Row.Form))); Put (Real (Row.Dimension));
            Put (Row.R); Put (Row.D); Put (Row.Bound); Put (Row.Mu);
            for X of Row.Friction loop Put (X); end loop;
         end;
      end loop;
      Ada.Text_IO.New_Line (File);
   end Write_Problem;
end MJ.Data.Constrained.Test_Export;
