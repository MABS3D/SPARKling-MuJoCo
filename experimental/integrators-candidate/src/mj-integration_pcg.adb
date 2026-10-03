package body MJ.Integration_PCG with SPARK_Mode is
   function Dot (A, B : Real_Array) return Real is
      S0, S1, S2, S3 : Real := 0.0;
      I : Natural := 0;
      Value : Real;
   begin
      while I + 3 < A'Length loop
         S0 := S0 + A (I)*B (I); S1 := S1 + A (I+1)*B (I+1);
         S2 := S2 + A (I+2)*B (I+2); S3 := S3 + A (I+3)*B (I+3);
         I := I+4;
      end loop;
      Value := (S0+S2)+(S1+S3);
      case A'Length - I is
         when 3 => Value := Value + ((A (I)*B (I) + A (I+1)*B (I+1)) + A (I+2)*B (I+2));
         when 2 => Value := Value + (A (I)*B (I) + A (I+1)*B (I+1));
         when 1 => Value := Value + A (I)*B (I);
         when others => null;
      end case;
      return Value;
   end Dot;

   procedure Solve
     (Matrix, Backbone, Right : Real_Array; N, Iterations : Natural;
      Tolerance : Nonneg_Tier0; X : out Real_Array;
      Ok, Converged : out Boolean)
   is
      Factor : Real_Array := Backbone;
      R, Z, Direction, Product : Real_Array (0 .. Integer (N)-1);
      Pivot, Multiplier, Value, BN, Threshold, RZ, Next_RZ, PAP, Alpha, Beta : Real;
      procedure Precondition is
      begin
         Z := R;
         for I in 0 .. Integer (N)-1 loop
            for J in I+1 .. Integer (N)-1 loop
               Z (J) := Z (J)-Factor (J*N+I)*Z (I);
            end loop;
         end loop;
         for I in reverse 0 .. Integer (N)-1 loop
            Value := Z (I);
            for J in I+1 .. Integer (N)-1 loop Value := Value-Factor (I*N+J)*Z (J); end loop;
            Z (I) := Value/Factor (I*N+I);
         end loop;
      end Precondition;
   begin
      Ok := False; Converged := False; X := [others => 0.0];
      -- Factor the supported backbone once; iteration never rebuilds the matrix.
      for I in 0 .. Integer (N)-1 loop
         Pivot := Factor (I*N+I);
         if abs Pivot < Min_Val then return; end if;
         for Row in I+1 .. Integer (N)-1 loop
            Multiplier := Factor (Row*N+I)/Pivot;
            Factor (Row*N+I) := Multiplier;
            for Col in I+1 .. Integer (N)-1 loop
               Factor (Row*N+Col) := Factor (Row*N+Col)-Multiplier*Factor (I*N+Col);
            end loop;
         end loop;
      end loop;
      R := Right; BN := Dot (R,R);
      if BN <= Min_Val then Ok := True; Converged := True; return; end if;
      Threshold := (Tolerance*Tolerance)*BN;
      Precondition; Direction := Z; RZ := Dot (R,Z);
      for Iteration in 1 .. Iterations loop
         for Row in 0 .. Integer (N)-1 loop
            Value := 0.0;
            for Col in 0 .. Integer (N)-1 loop Value := Value+Matrix (Row*N+Col)*Direction (Col); end loop;
            Product (Row) := Value;
         end loop;
         PAP := Dot (Direction,Product);
         if PAP <= 0.0 then Ok := True; Converged := True; return; end if;
         Alpha := RZ/PAP;
         for I in R'Range loop
            X (I) := X (I)+Alpha*Direction (I);
            R (I) := R (I)+(-Alpha)*Product (I);
         end loop;
         if Dot (R,R) < Threshold then Ok := True; Converged := True; return; end if;
         Precondition; Next_RZ := Dot (R,Z); Beta := Next_RZ/RZ;
         for I in R'Range loop Direction (I) := Z (I)+Beta*Direction (I); end loop;
         RZ := Next_RZ;
      end loop;
      -- C returns the current iterate on an iteration cap, rather than replacing
      -- it by an exact solve. The caller can report Converged separately.
      Ok := True;
   exception
      when Constraint_Error => Ok := False;
   end Solve;
end MJ.Integration_PCG;
