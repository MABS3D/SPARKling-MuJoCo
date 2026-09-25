package body MJ.Ancestor_Rows with SPARK_Mode is
   procedure Copy_Matrix (P : Pattern; Dense : Real_Array; Target : in out Real_Array) is
   begin
      for I in 0 .. P.N - 1 loop
         for A in P.Starts (I) .. P.Starts (I + 1) - 1 loop
            Target (A) := Dense (MJ.Smooth_Kernels.Matrix_Offset (P.N, I, P.Columns (A)));
            pragma Loop_Invariant (Static => (for all B in 0 .. A => Target (B) in Work_Real));
            pragma Loop_Invariant (Static => (for all B in P.Starts (I) .. A => Target (B) =
              Dense (MJ.Smooth_Kernels.Matrix_Offset (P.N, I, P.Columns (B)))));
         end loop;
         pragma Loop_Invariant (Static => (for all A in 0 .. P.Starts (I + 1) - 1 => Target (A) in Work_Real));
         pragma Loop_Invariant (Static => (for all J in 0 .. I =>
           (for all A in P.Starts (J) .. P.Starts (J + 1) - 1 => Target (A) =
             Dense (MJ.Smooth_Kernels.Matrix_Offset (P.N, J, P.Columns (A))))));
      end loop;
   end Copy_Matrix;

   procedure Copy_Row (P : Pattern; Row : Natural; Dense : Real_Array;
                       Target : in out Real_Array) is
   begin
      if Length (P, Row) = Row + 1 then
         Target := Dense (MJ.Smooth_Kernels.Matrix_Offset (Size (P), Row, 0) ..
                          MJ.Smooth_Kernels.Matrix_Offset (Size (P), Row, Row));
      else
         for A in Target'Range loop
            Target (A) := Dense (MJ.Smooth_Kernels.Matrix_Offset (Size (P), Row, Column (P, Row, A - Target'First)));
            pragma Loop_Invariant (Static => (for all B in Target'First .. A => Target (B) =
              Dense (MJ.Smooth_Kernels.Matrix_Offset (Size (P), Row, Column (P, Row, B - Target'First)))));
         end loop;
      end if;
   end Copy_Row;

   function Offsets_OK (Starts : Int_Array; N : Dof_Count) return Boolean is
     (Starts'First = 0 and then Starts'Last = N and then Starts (0) = 0
      and then (for all I in 0 .. N => Starts (I) in 0 .. I * (I + 1) / 2)
      and then (for all I in 0 .. N - 1 => Starts (I + 1) - Starts (I) in 1 .. I + 1)
      and then (for all I in 0 .. N - 1 =>
        (if Starts (I + 1) - Starts (I) = I + 1 then Starts (I) = I * (I + 1) / 2))
      and then (for all I in 0 .. N =>
        (for all J in I .. N => Starts (I) <= Starts (J))));

   procedure Build_Offsets (Parents : Int_Array; Starts : out Int_Array) with
     Global => null,
     Pre => Valid_Parents (Parents) and then Starts'First = 0
       and then Starts'Last = Parents'Length,
     Post => Offsets_OK (Starts, Parents'Length)
       and then (for all I in Parents'Range => Starts (I + 1) - Starts (I) =
         (if Parents (I) < 0 then 1 else Starts (Parents (I) + 1) - Starts (Parents (I)) + 1))
   is
   begin
      Starts := [others => 0];
      for I in Parents'Range loop
         Starts (I + 1) := Starts (I) +
           (if Parents (I) < 0 then 1 else Starts (Parents (I) + 1) - Starts (Parents (I)) + 1);
         pragma Assert (Static => (if Starts (I + 1) - Starts (I) = I + 1 and then I > 0 then Parents (I) = I - 1));
         pragma Loop_Invariant (Static => (for all J in 0 .. I =>
           (if Starts (J + 1) - Starts (J) = J + 1 then Starts (J) = J * (J + 1) / 2)));
         pragma Loop_Invariant (Static => Starts (0) = 0);
         pragma Loop_Invariant (Static => (for all J in 0 .. I =>
           Starts (J + 1) - Starts (J) in 1 .. J + 1));
         pragma Loop_Invariant (Static => (for all J in 0 .. I + 1 =>
           Starts (J) in 0 .. J * (J + 1) / 2));
         pragma Loop_Invariant (Static => (for all J in 0 .. I + 1 =>
           (for all K in J .. I + 1 => Starts (J) <= Starts (K))));
         pragma Loop_Invariant (Static => (for all J in 0 .. I =>
           Starts (J + 1) - Starts (J) = (if Parents (J) < 0 then 1
             else Starts (Parents (J) + 1) - Starts (Parents (J)) + 1)));
      end loop;
   end Build_Offsets;

   procedure Prove_Row_Frame (Starts, Before, After : Int_Array; I : Natural) with
     Ghost => Static, Global => null,
     Pre => Starts'Length in 1 .. Max_Dofs + 1 and then Offsets_OK (Starts, Starts'Length - 1)
       and then I < Starts'Last and then Before'First = 0 and then After'First = 0
       and then Before'Length <= Max_Entries and then Before'Length = Starts (Starts'Last)
       and then After'Last = Before'Last and then Row_OK (Starts, Before, I)
       and then (for all A in 0 .. Starts (I + 1) - 1 => Before (A) = After (A)),
     Post => Row_OK (Starts, After, I)
   is
   begin
      pragma Assert (Static => (After (Starts (I + 1) - 1) = I));
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 1 => After (A) in 0 .. Integer (I)));
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 1 => Starts (After (A) + 1) - Starts (After (A)) = A - Starts (I) + 1));
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 2 => After (A) < I));
      pragma Assert (Static => (for all A in Starts (I) + 1 .. Starts (I + 1) - 1 => After (A - 1) < After (A)));
      pragma Assert (Static => (if Starts (I + 1) - Starts (I) = I + 1 then (for all A in Starts (I) .. Starts (I + 1) - 1 => After (A) = A - Starts (I))));
      pragma Assert (Static => (if Starts (I + 1) - Starts (I) > 1 then (for all A in Starts (I) .. Starts (I + 1) - 2 => After (A) = After (Starts (After (Starts (I + 1) - 2)) + A - Starts (I)))));
   end Prove_Row_Frame;

   procedure Append_Row (Starts : Int_Array; Columns : in out Int_Array;
                         I : Natural; Par : Integer) with
     Global => null,
     Pre => Starts'Length in 1 .. Max_Dofs + 1 and then Offsets_OK (Starts, Starts'Length - 1)
       and then I < Starts'Last and then Par in -1 .. Integer (I) - 1
       and then Columns'First = 0 and then Columns'Length <= Max_Entries
       and then Columns'Length = Starts (Starts'Last)
       and then Starts (I + 1) - Starts (I) =
         (if Par < 0 then 1 else Starts (Par + 1) - Starts (Par) + 1)
       and then (for all J in 0 .. I - 1 => Row_OK (Starts, Columns, J)),
     Post => Row_OK (Starts, Columns, I)
       and then (for all J in 0 .. I - 1 => Row_OK (Starts, Columns, J))
       and then (for all J in 0 .. I - 1 =>
         (if Starts (J + 1) - Starts (J) > 1 then
           Columns (Starts (J + 1) - 2) = Columns'Old (Starts (J + 1) - 2)))
       and then (for all A in Columns'Range =>
         (if A < Starts (I) or else A >= Starts (I + 1) then Columns (A) = Columns'Old (A)))
       and then (if Par >= 0 then Columns (Starts (I + 1) - 2) = Par)
   is
      Before : constant Int_Array := Columns with Ghost => Static;
   begin
      if Par >= 0 then
         pragma Assert (Static => (if Starts (I + 1) - Starts (I) = I + 1 then Par = I - 1));
         Columns (Starts (I) .. Starts (I + 1) - 2) :=
           Columns (Starts (Par) .. Starts (Par + 1) - 1);
      end if;
      Columns (Starts (I + 1) - 1) := I;
      pragma Assert (Static => (for all A in 0 .. Starts (I) - 1 => Columns (A) = Before (A)));
      pragma Assert (Static => (if Par >= 0 then
        (for all A in Starts (I) .. Starts (I + 1) - 2 =>
          Columns (A) = Before (Starts (Par) + A - Starts (I)))));
      pragma Assert (Static => (if Par >= 0 then Row_OK (Starts, Before, Par)));
      pragma Assert (Static => (if Par >= 0 then Columns (Starts (I + 1) - 2) = Par));
      pragma Assert (Static => (Columns (Starts (I + 1) - 1) = I));
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 1 => Columns (A) in 0 .. Integer (I)));
      if Par >= 0 then
         for A in Starts (I) .. Starts (I + 1) - 2 loop
            pragma Assert (Static => Starts (Par) + A - Starts (I) in Starts (Par) .. Starts (Par + 1) - 1);
            pragma Assert (Static => Columns (A) = Before (Starts (Par) + A - Starts (I)));
            pragma Assert (Static => Starts (Columns (A) + 1) - Starts (Columns (A)) = A - Starts (I) + 1);
            pragma Loop_Invariant (Static => (for all B in Starts (I) .. A =>
              Starts (Columns (B) + 1) - Starts (Columns (B)) = B - Starts (I) + 1));
         end loop;
      end if;
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 1 => Starts (Columns (A) + 1) - Starts (Columns (A)) = A - Starts (I) + 1));
      pragma Assert (Static => (for all A in Starts (I) .. Starts (I + 1) - 2 => Columns (A) < I));
      pragma Assert (Static => (for all A in Starts (I) + 1 .. Starts (I + 1) - 1 => Columns (A - 1) < Columns (A)));
      pragma Assert (Static => (if Starts (I + 1) - Starts (I) = I + 1 then (for all A in Starts (I) .. Starts (I + 1) - 1 => Columns (A) = A - Starts (I))));
      pragma Assert (Static => (if Starts (I + 1) - Starts (I) > 1 then (for all A in Starts (I) .. Starts (I + 1) - 2 => Columns (A) = Columns (Starts (Columns (Starts (I + 1) - 2)) + A - Starts (I)))));
      pragma Assert (Static => Row_OK (Starts, Columns, I));
      for J in 0 .. I - 1 loop
         Prove_Row_Frame (Starts, Before, Columns, J);
         pragma Loop_Invariant (Static => (for all K in 0 .. J => Row_OK (Starts, Columns, K)));
      end loop;
   end Append_Row;

   procedure Build (P : in out Pattern; Parents : Int_Array) is
      N : constant Dof_Count := Parents'Length;
      Starts : Int_Array (0 .. N);
   begin
      Build_Offsets (Parents, Starts);
      P.N := N;
      P.Starts := new Int_Array'(Starts);
      P.Columns := new Int_Array'[0 .. Starts (N) - 1 => 0];
      pragma Assert (Static => (for all J in 0 .. N - 1 =>
        (Starts (J + 1) - Starts (J) = 1) = (Parents (J) = -1)));
      declare
         Final_Length : constant Natural := P.Columns'Length with Ghost => Static;
         Before : Int_Array (0 .. Final_Length - 1) with Ghost => Static;
      begin
         for I in 0 .. N - 1 loop
            Before := P.Columns.all;
            Append_Row (Starts, P.Columns.all, I, Parents (I));
            for J in 0 .. I - 1 loop
               if Parents (J) >= 0 then
                  pragma Assert (Static => Before (Starts (J + 1) - 2) = Parents (J));
                  pragma Assert (Static => P.Columns (Starts (J + 1) - 2) = Before (Starts (J + 1) - 2));
               end if;
               pragma Loop_Invariant (Static => (for all K in 0 .. J =>
                 (if Parents (K) >= 0 then P.Columns (Starts (K + 1) - 2) = Parents (K))));
            end loop;
            pragma Assert (Static => (if Parents (I) >= 0 then
              P.Columns (Starts (I + 1) - 2) = Parents (I)));
            pragma Loop_Invariant (Static => (for all J in 0 .. I => Row_OK (Starts, P.Columns.all, J)));
            pragma Loop_Invariant (Static => (for all J in 0 .. I =>
              (if Parents (J) >= 0 then P.Columns (Starts (J + 1) - 2) = Parents (J))));
         end loop;
         pragma Assert (Static => P.N = N and then P.Starts.all = Starts);
         pragma Assert (Static => (for all J in 0 .. N - 1 => Row_OK (P.Starts.all, P.Columns.all, J)));
         pragma Assert (Static => Valid (P));
      end;
   end Build;

   procedure Free (P : in out Pattern) is
   begin
      Free_Int (P.Starts);
      Free_Int (P.Columns);
      P.N := 0;
   end Free;
end MJ.Ancestor_Rows;
