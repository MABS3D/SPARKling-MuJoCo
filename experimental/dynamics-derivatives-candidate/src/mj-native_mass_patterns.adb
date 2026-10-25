package body MJ.Native_Mass_Patterns with SPARK_Mode is
   function Has_Sharing (Rows : Row_Array; Count : Natural) return Boolean is
   begin
      for I in 0 .. Count - 1 loop
         for J in 0 .. I - 1 loop
            if Overlap (Rows (I), Rows (J)) then return True; end if;
            pragma Loop_Invariant (for all K in 0 .. J => not Overlap (Rows (I), Rows (K)));
         end loop;
         pragma Loop_Invariant (for all R in 0 .. I =>
           (for all K in 0 .. R - 1 => not Overlap (Rows (R), Rows (K))));
      end loop;
      return False;
   end Has_Sharing;

   procedure Copy
     (Widths, Addresses, Columns, Simple : Int_Array; Fixed, Arms : Real_Array;
      Nv, Nc : Natural; P : out Pattern) is
   begin
      P := (others => <>);
      for R in 0 .. Nv - 1 loop
         P.Rows (R) := (Addresses (R), Widths (R), Simple (R) > 0, Fixed (R), Arms (R));
         pragma Loop_Invariant (for all I in 0 .. R =>
           P.Rows (I) = Row_Descriptor'(Addresses (I), Widths (I), Simple (I) > 0, Fixed (I), Arms (I)));
      end loop;
      for H in 0 .. Nc - 1 loop
         P.Columns (H) := Columns (H);
         pragma Loop_Invariant (for all K in 0 .. H => P.Columns (K) = Columns (K));
      end loop;
      P.Nv := Nv; P.Nc := Nc; P.Shared := Has_Sharing (P.Rows, Nv);
   end Copy;

   procedure Disjoint_Prefix (P : Pattern; Row : Natural) is
   begin
      null;
   end Disjoint_Prefix;

   procedure Gather (P : Pattern; Dense : Real_Array; Mass : out Real_Array) is
      package K renames MJ.Native_Mass_Kernels;
   begin
      K.Zero (Mass);
      for R in 0 .. P.Nv - 1 loop
         Disjoint_Prefix (P, R);
         K.Gather_Row (Dense, P.Columns, P.Nv, R, P.Rows (R).First, P.Rows (R).Width, Mass);
         pragma Loop_Invariant (for all I in 0 .. R => (for all H in P.Rows (I).First ..
           (P.Rows (I).First + P.Rows (I).Width) - 1 => Mass (H) = Dense (Dense_Offset (P.Nv, I, P.Columns (H)))));
         pragma Loop_Invariant (Static => (for all H in Mass'Range =>
           (if not Used (P, R + 1, H) then Mass (H) = 0.0)));
      end loop;
   end Gather;
end MJ.Native_Mass_Patterns;
