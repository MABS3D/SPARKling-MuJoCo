with MJ.Types; use MJ.Types;
package MJ.Ray_Kernels with SPARK_Mode is
   subtype Axis is Integer range 0 .. 2;
   type Vector is array (Axis) of Real;
   type Matrix is array (Axis, Axis) of Real;
   Zero : constant Vector := [others => 0.0];
   Identity : constant Matrix :=
     [[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]];
   function Bounded (V : Vector) return Boolean is
     (V (0) in -1.0e100 .. 1.0e100 and then V (1) in -1.0e100 .. 1.0e100
       and then V (2) in -1.0e100 .. 1.0e100);
   function Matrix_Bounded (R : Matrix) return Boolean is
     (R (0,0) in -16.0 .. 16.0 and then R (0,1) in -16.0 .. 16.0 and then R (0,2) in -16.0 .. 16.0
      and then R (1,0) in -16.0 .. 16.0 and then R (1,1) in -16.0 .. 16.0 and then R (1,2) in -16.0 .. 16.0
      and then R (2,0) in -16.0 .. 16.0 and then R (2,1) in -16.0 .. 16.0 and then R (2,2) in -16.0 .. 16.0);
   function Product (A, B : Real) return Real with Global => null,
     Pre => A in -1.0e100 .. 1.0e100 and then B in -1.0e100 .. 1.0e100,
     Post => Product'Result = A*B and then Product'Result in -2.0e200 .. 2.0e200;
   function Dot (A, B : Vector) return Real with Global => null,
     Pre => Bounded (A) and then Bounded (B),
     Post => Dot'Result in -8.0e200 .. 8.0e200
       and then Dot'Result = (A (0)*B (0) + A (1)*B (1)) + A (2)*B (2);
   function Map_Component (R : Matrix; V : Vector; I : Axis) return Real
     with Global => null,
     Pre => Bounded (V) and then Matrix_Bounded (R),
     Post => Map_Component'Result in -8.0e200 .. 8.0e200
       and then Map_Component'Result =
         (R (0, I)*V (0) + R (1, I)*V (1)) + R (2, I)*V (2);
   function Rotate_Component (R : Matrix; V : Vector; I : Axis) return Real
     with Global => null,
     Pre => Bounded (V) and then Matrix_Bounded (R),
     Post => Rotate_Component'Result in -8.0e200 .. 8.0e200
       and then Rotate_Component'Result =
         (R (I, 0)*V (0) + R (I, 1)*V (1)) + R (I, 2)*V (2);
   function Along (P, V, T : Real) return Real with Global => null,
     Pre => P in -1.0e100 .. 1.0e100 and then V in -1.0e100 .. 1.0e100
       and then T in -1.0e100 .. 1.0e100,
     Post => Along'Result = P + V*T and then Along'Result in -2.0e200 .. 2.0e200;
   function Better (Candidate, Current : Real) return Boolean is
     (Candidate >= 0.0 and then (Current < 0.0 or else Candidate < Current))
     with Global => null;
   function Select_Distance (Candidate, Current : Real) return Real
     with Global => null,
     Post => Select_Distance'Result =
       (if Better (Candidate, Current) then Candidate else Current);
   type Groups is array (Integer range 0 .. 5) of Boolean;
   function Eligible (Body_Id, Weld_Id, Group_Id, Excluded_Body : Integer;
                      Visible, Include_Static, Filter_Groups : Boolean;
                      Mask : Groups) return Boolean with Global => null,
     Post => Eligible'Result = (Body_Id /= Excluded_Body and then Visible
       and then (Include_Static or else Weld_Id /= 0)
       and then (not Filter_Groups or else
         Mask (Integer'Max (0, Integer'Min (5, Group_Id)))));
end MJ.Ray_Kernels;
