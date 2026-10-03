--  MuJoCo 3.14.0 analytic and octree SDF queries, Apache-2.0.
with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.BVH;
package MJ.SDF_Fields with SPARK_Mode is
   type Corner_Values is array (Natural range 0 .. 7) of Real;
   type Corner_Gradients is array (Natural range 0 .. 7) of Vec;
   type Children is array (Natural range 0 .. 7) of Integer;
   type Octant is record
      Bounds : MJ.BVH.Box;
      Child : Children := [others => -1];
      Coeff : Corner_Values := [others => 0.0];
   end record;
   type Octree is array (Natural range <>) of Octant;
   Empty_Octree : constant Octree (1 .. 0) := [others => <>];
   type Field_Kind is (Analytic, Sampled, Custom);
   type Field is record
      Kind : Field_Kind := Analytic;
      Geometry : Shape;
      First, Length, Key : Natural := 0;
      Bounds : MJ.BVH.Box := (Center => Zero, Half => [1.0, 1.0, 1.0]);
   end record;
   function Valid (F : Field; T : Octree) return Boolean with Global => null;
   function Combine_Value (A, B : Real; Mode : Natural) return Real is
     (case Mode is
        when 0 => A,
        when 1 => Real'Max (A, B),
        when 2 => A - B,
        when others => A + B + abs (Real'Max (A, B)))
     with Global => null, Pre => A in -1.0e100 .. 1.0e100 and B in -1.0e100 .. 1.0e100;
   --  Ordered eight-term trilinear interpolation, matching C's accumulation.
   function Interpolate (W, C : Corner_Values) return Real
     with Global => null,
       Pre => (for all X of W => X in -1.0e20 .. 1.0e20)
         and (for all X of C => X in -1.0e20 .. 1.0e20),
       Post => Interpolate'Result =
         (((((((0.0 + W (0)*C (0)) + W (1)*C (1)) + W (2)*C (2)) + W (3)*C (3))
              + W (4)*C (4)) + W (5)*C (5)) + W (6)*C (6)) + W (7)*C (7);
   procedure Project (X : in out Vec; B : MJ.BVH.Box; Distance : out Real)
     with Global => null, Pre => MJ.BVH.Valid (B)
       and (for all Q of X => Q in -1.0e10 .. 1.0e10);
   procedure Locate (F : Field; T : Octree; X : Vec;
                     Leaf : out Natural; W : out Corner_Values;
                     DW : out Corner_Gradients; Result : out Status)
     with Global => null, Pre => F.Kind = Sampled and Valid (F, T)
       and (for all Q of X => Q in -1.0e10 .. 1.0e10);
   procedure Locate_Admitted (F : Field; T : Octree; X : Vec;
                             Leaf : out Natural; W : out Corner_Values;
                             DW : out Corner_Gradients; Result : out Status)
     with Global => null, Pre => (Static => F.Kind = Sampled and Valid (F, T)
       and (for all Q of X => Q in -1.0e10 .. 1.0e10));
   --  Custom fields are serviced by the generic collision provider, not by C.
   procedure Evaluate (F : Field; T : Octree; X : Vec; Need_Gradient : Boolean;
                       Value : out Real; Gradient : out Vec; Result : out Status)
     with Global => null, Pre => Valid (F, T),
       Post => (if Result = Success then Value in -1.0e100 .. 1.0e100
         and (for all Q of Gradient => Q in -1.0e100 .. 1.0e100));
   -- Same arithmetic; immutable engine assets are admitted once at loading.
   procedure Evaluate_Admitted (F : Field; T : Octree; X : Vec; Need_Gradient : Boolean;
                                Value : out Real; Gradient : out Vec; Result : out Status)
     with Global => null, Pre => (Static => Valid (F, T)),
       Post => (if Result = Success then Value in -1.0e100 .. 1.0e100
         and (for all Q of Gradient => Q in -1.0e100 .. 1.0e100));
end MJ.SDF_Fields;
