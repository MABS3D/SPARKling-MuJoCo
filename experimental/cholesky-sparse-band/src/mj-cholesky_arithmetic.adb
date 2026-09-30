package body MJ.Cholesky_Arithmetic with SPARK_Mode is
   procedure Store (X : MJ.Types.Real; R : out Scalar; Status : out Outcome) is
   begin
      R := 0.0;
      if X in Scalar then R := X; Status := Success;
      else Status := Numeric_Limit; end if;
   end Store;

   procedure Add_Product (A, B, C : Scalar; R : out Scalar; Status : out Outcome) is
   begin Store (A + B * C, R, Status); end Add_Product;
   procedure Multiply (A, B : Scalar; R : out Scalar; Status : out Outcome) is
   begin Store (A * B, R, Status); end Multiply;
   procedure Divide (A, B : Scalar; R : out Scalar; Status : out Outcome) is
   begin Store (A / B, R, Status); end Divide;
   procedure Root (A : Scalar; R : out Scalar; Status : out Outcome) is
      X : constant MJ.Types.Real := Elementary.Sqrt (A);
   begin
      R := 0.0;
      if X in Scalar and then X >= Min_Diag then R := X; Status := Success;
      else Status := Numeric_Limit; end if;
   end Root;

   procedure Factor_Pivot (Value, Minimum : Scalar; R : out Scalar;
                           Clamped : out Boolean; Status : out Outcome) is
   begin
      Clamped := Value < Minimum;
      Root ((if Clamped then Minimum else Value), R, Status);
   end Factor_Pivot;

   procedure Copy (Source : Values; Source_At : Offset;
                   Destination : in out Values; Destination_At : Offset; Count : Size) is
   begin
      for I in 0 .. Integer (Count) - 1 loop
         Destination (Destination_At + I) := Source (Source_At + I);
         pragma Loop_Invariant
           (for all K in Destination'Range =>
              (if K >= Destination_At and then K - Destination_At <= I then
                 Destination (K) = Source (Source_At + (K - Destination_At))
               else Destination (K) = Destination'Loop_Entry (K)));
      end loop;
   end Copy;

   procedure Reduce (Lane : Values; R : out Scalar; Status : out Outcome) is
      X, Y : Scalar;
   begin
      Add_Product (Lane (0), 1.0, Lane (2), X, Status);
      if Status /= Success then R := 0.0; return; end if;
      Add_Product (Lane (1), 1.0, Lane (3), Y, Status);
      if Status /= Success then R := 0.0; return; end if;
      Add_Product (X, 1.0, Y, R, Status);
   end Reduce;

   procedure Dot (A, B : Values; A0, B0 : Offset; Count : Size;
                  R : out Scalar; Status : out Outcome) is
      Lane : Values (0 .. 3) := (others => 0.0);
      K : Size := 0;
      X, Tail : Scalar;
   begin
      R := 0.0;
      while Count - K >= 4 loop
         pragma Loop_Invariant (K <= Count);
         for J in 0 .. 3 loop
            Add_Product (Lane (J), A (A0 + K + J), B (B0 + K + J), X, Status);
            if Status /= Success then return; end if;
            Lane (J) := X;
         end loop;
         K := K + 4;
      end loop;
      Reduce (Lane, R, Status);
      if Status /= Success then return; end if;
      if K < Count then
         Multiply (A (A0 + K), B (B0 + K), Tail, Status);
         if Status /= Success then return; end if;
         K := K + 1;
         while K < Count loop
            pragma Loop_Invariant (K <= Count);
            Add_Product (Tail, A (A0 + K), B (B0 + K), X, Status);
            if Status /= Success then return; end if;
            Tail := X; K := K + 1;
         end loop;
         Add_Product (R, 1.0, Tail, X, Status); R := X;
      end if;
   end Dot;

   procedure Dot_Sparse (A, B : Values; Col : Indices; A0 : Offset;
                         Count : Size; R : out Scalar; Status : out Outcome) is
      Lane : Values (0 .. 3) := (others => 0.0);
      K : Size := 0;
      X : Scalar;
   begin
      R := 0.0;
      while Count - K >= 4 loop
         pragma Loop_Invariant (K <= Count);
         for J in 0 .. 3 loop
            Add_Product (Lane (J), A (A0 + K + J), B (Col (A0 + K + J)), X, Status);
            if Status /= Success then return; end if;
            Lane (J) := X;
         end loop;
         K := K + 4;
      end loop;
      Reduce (Lane, R, Status);
      if Status /= Success then return; end if;
      while K < Count loop
         pragma Loop_Invariant (K <= Count);
         Add_Product (R, A (A0 + K), B (Col (A0 + K)), X, Status);
         if Status /= Success then return; end if;
         R := X; K := K + 1;
      end loop;
   end Dot_Sparse;
end MJ.Cholesky_Arithmetic;
