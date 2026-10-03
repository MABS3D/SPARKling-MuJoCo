package body MJ.Ray_Kernels with SPARK_Mode is
   function Product (A, B : Real) return Real is
   begin return A*B; end Product;
   function Dot (A, B : Vector) return Real is
      Partial : constant Real := Product (A (0),B (0)) + Product (A (1),B (1));
   begin
      pragma Assert (Static => Partial in -5.0e200 .. 5.0e200);
      return Partial + Product (A (2),B (2));
   end Dot;
   function Map_Component (R : Matrix; V : Vector; I : Axis) return Real is
      Partial : constant Real := Product (R (0,I),V (0)) + Product (R (1,I),V (1));
   begin
      pragma Assert (Static => Partial in -5.0e200 .. 5.0e200);
      return Partial + Product (R (2,I),V (2));
   end Map_Component;
   function Rotate_Component (R : Matrix; V : Vector; I : Axis) return Real is
      Partial : constant Real := Product (R (I,0),V (0)) + Product (R (I,1),V (1));
   begin
      pragma Assert (Static => Partial in -5.0e200 .. 5.0e200);
      return Partial + Product (R (I,2),V (2));
   end Rotate_Component;
   function Along (P, V, T : Real) return Real is
   begin return P + V*T; end Along;
   function Select_Distance (Candidate, Current : Real) return Real is
   begin
      if Better (Candidate, Current) then return Candidate; else return Current; end if;
   end Select_Distance;
   function Eligible (Body_Id, Weld_Id, Group_Id, Excluded_Body : Integer;
                      Visible, Include_Static, Filter_Groups : Boolean;
                      Mask : Groups) return Boolean is
   begin
      return Body_Id /= Excluded_Body and then Visible
        and then (Include_Static or else Weld_Id /= 0)
        and then (not Filter_Groups or else
          Mask (Integer'Max (0, Integer'Min (5, Group_Id))));
   end Eligible;
end MJ.Ray_Kernels;
