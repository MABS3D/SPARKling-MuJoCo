with MJ.Types; use MJ.Types;

--  Material part of user_mesh.cc and engine_passive.c (MuJoCo 3.14.0).
--  Geometry supplies signed area/volume and the ordered edge strain bases.
package MJ.Elastic_Materials with SPARK_Mode is
   subtype Young_Modulus is Real range 0.0 .. 1.0e15;
   subtype Poisson_Ratio is Real range 0.0 .. 0.49999999999999994;
   subtype Thickness_Value is Real range 0.0 .. 1.0e10;
   subtype Measure_Value is Real range -1.0e30 .. 1.0e30;
   subtype Modulus_Value is Real range 0.0 .. 1.0e35;
   subtype Weighted_Value is Real range 0.0 .. 1.0e76;
   subtype Bending_Value is Real range 0.0 .. 1.0e50;
   subtype Basis_Value is Real range -1.0e10 .. 1.0e10;
   subtype Metric_Value is Real range -1.0e100 .. 1.0e100;
   type Material is record
      Young : Young_Modulus := 0.0;
      Poisson : Poisson_Ratio := 0.0;
      Thickness : Thickness_Value := 0.0;
      Rayleigh_Damping : Nonneg_Tier0 := 0.0;
   end record;
   type Element_Kind is (Triangle, Tetrahedron);
   subtype Edge_Index is Integer range 0 .. 5;
   subtype Tensor_Index is Integer range 0 .. 8;
   subtype Packed_Index is Integer range 0 .. 20;
   type Strain_Basis is array (Tensor_Index) of Basis_Value;
   type Element_Basis is array (Edge_Index) of Strain_Basis;
   type Element_Metric is array (Packed_Index) of Metric_Value;

   function Shear (M : Material) return Modulus_Value is
     (M.Young / (2.0 * (1.0 + M.Poisson))) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   --  Association deliberately differs between the two upstream routines.
   function Lame_Simplex (M : Material) return Modulus_Value is
     ((M.Young * M.Poisson) /
       ((1.0 + M.Poisson) * (1.0 - 2.0 * M.Poisson))) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Lame_Interpolated (M : Material) return Modulus_Value is
     (((M.Young * M.Poisson) / (1.0 + M.Poisson)) /
       (1.0 - 2.0 * M.Poisson)) with Global => null;
   function Lame_Plane_Stress (M : Material) return Modulus_Value is
     ((M.Young * M.Poisson) / (1.0 - M.Poisson * M.Poisson))
     with Global => null;
   function Bending_Modulus (M : Material) return Bending_Value is
     ((((M.Young * M.Thickness) * M.Thickness) * M.Thickness) /
       (12.0 * (1.0 - M.Poisson * M.Poisson))) with Global => null;
   function Weighted_Shear
     (M : Material; Kind : Element_Kind; Measure : Measure_Value)
     return Weighted_Value is
     (((Shear (M) * abs Measure) / 4.0) *
       (if Kind = Triangle then M.Thickness else 4.0)) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Weighted_Lame
     (M : Material; Kind : Element_Kind; Measure : Measure_Value)
     return Weighted_Value is
     (((Lame_Simplex (M) * abs Measure) / 4.0) *
       (if Kind = Triangle then M.Thickness else 4.0)) with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   function Trace (B : Strain_Basis) return Real is
     (((0.0 + B (0)) + B (4)) + B (8))
     with Global => null, Post => Trace'Result in -4.0e10 .. 4.0e10,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   subtype Basis_Product is Real range -2.0e20 .. 2.0e20;
   function Product (A, B : Basis_Value) return Basis_Product is (A * B)
     with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   --  Ordered 3x3 contraction: sum B1[i,j]*B2[j,i], starting at zero.
   function Trace_Product (A, B : Strain_Basis) return Real is
     (((((((((0.0 + Product (A (0), B (0))) + Product (A (1), B (3)))
          + Product (A (2), B (6))) + Product (A (3), B (1))) + Product (A (4), B (4)))
          + Product (A (5), B (7))) + Product (A (6), B (2))) + Product (A (7), B (5)))
          + Product (A (8), B (8)))
     with Global => null, Post => Trace_Product'Result in -2.0e21 .. 2.0e21,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Metric_Entry (Mu, Lambda : Weighted_Value; A, B : Strain_Basis)
     return Metric_Value is
     (Mu * Trace_Product (A, B) + (Lambda * Trace (B)) * Trace (A))
     with Global => null,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Count (Kind : Element_Kind) return Positive is
     (if Kind = Triangle then 6 else 21) with Global => null;
   function Row (Kind : Element_Kind; K : Packed_Index) return Edge_Index
     with Global => null,
     Post => Row'Result =
       (if Kind = Triangle then
          (if K < 3 then 0 elsif K < 5 then 1 elsif K < 6 then 2 else 0)
        else (if K < 6 then 0 elsif K < 11 then 1 elsif K < 15 then 2
          elsif K < 18 then 3 elsif K < 20 then 4 else 5));
   function Column (Kind : Element_Kind; K : Packed_Index) return Edge_Index
     with Global => null,
     Post => Column'Result =
       (if Kind = Triangle then
          (if K < 3 then K elsif K < 5 then K - 2 elsif K < 6 then 2 else 0)
        else (if K < 6 then K elsif K < 11 then K - 5
          elsif K < 15 then K - 9 elsif K < 18 then K - 12
          elsif K < 20 then K - 14 else 5));
   procedure Compile_Metric
     (M : Material; Kind : Element_Kind; Measure : Measure_Value;
      Basis : Element_Basis; Result : out Element_Metric)
     with Global => null, Inline_Always,
     Post => (Static => (for all K in Packed_Index => Result (K) =
       (if K < Count (Kind) then Metric_Entry
         (Weighted_Shear (M, Kind, Measure), Weighted_Lame (M, Kind, Measure),
          Basis (Row (Kind, K)), Basis (Column (Kind, K))) else 0.0)));

   subtype Step_Value is Real range 0.0 .. 1.0;
   function Damping_Scale
     (M : Material; H : Step_Value; Enabled : Boolean) return Real is
     (if Enabled and then H > 0.0 then M.Rayleigh_Damping / H else 0.0)
     with Global => null, Pre => H = 0.0 or else H >= Min_Val,
     Post => Damping_Scale'Result in 0.0 .. 2.0e25,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Spring_Elongation (Length, Rest : Nonneg_Tier0; Enabled : Boolean)
     return Real is
     (if Enabled then Length * Length - Rest * Rest else 0.0)
     with Global => null, Post => Spring_Elongation'Result in -2.0e20 .. 2.0e20;
   function Damper_Elongation
     (M : Material; Length : Nonneg_Tier0; Velocity : Tier0_Real;
      H : Step_Value; Enabled : Boolean) return Real is
     (if Damping_Scale (M, H, Enabled) = 0.0 then 0.0 else
       (declare DL : constant Real := Velocity * H;
        begin (DL * (2.0 * Length - DL)) * Damping_Scale (M, H, Enabled)))
     with Global => null, Pre => H = 0.0 or else H >= Min_Val,
     Post => Damper_Elongation'Result in -1.0e47 .. 1.0e47;
end MJ.Elastic_Materials;
