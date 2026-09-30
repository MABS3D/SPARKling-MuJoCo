with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Spatial_Tendons; use MJ.Spatial_Tendons;

--  Immutable, owned copy of spatial-tendon configuration. No pointer into M
--  survives Load: a caller may release the MJB model after Data.Create.
package MJ.Spatial_Tendon_Models with SPARK_Mode is
   Max_Objects : constant := 4096;
   type Parameters is record
      First : Natural := 0;
      Count : Natural := 0;
      Lower, Upper, Stiffness, Damping : Real := 0.0;
      Spring_Linear, Spring_Quadratic : Real := 0.0;
      Damper_Linear, Damper_Quadratic : Real := 0.0;
   end record;
   type Parameter_Array is array (Natural range <>) of Parameters;
   type Description (Nt, Ns, Ng, Nw : Natural) is record
      Nb : Natural := 0;
      Tendons : Parameter_Array (1 .. Nt);
      Sites : Site_Array (1 .. Ns);
      Geometries : Geometry_Array (1 .. Ng);
      Nodes : Route_Array (1 .. Nw);
   end record;
   type Description_Access is access Description;
   function Count (T : Description_Access) return Natural is
     (if T = null then 0 else T.Nt);
   function Image (T : Description_Access) return Description is
     (if T = null then (0, 0, 0, 0, 0, others => <>) else T.all)
     with Ghost => Static;
   function Ready (T : Description_Access; Bodies : Natural) return Boolean is
     (T = null or else (T.Nt in 1 .. Max_Objects and then T.Ns <= Max_Objects
        and then T.Ng <= Max_Objects and then T.Nw <= Max_Objects
        and then T.Nb = Bodies and then Bodies in 1 .. Max_Objects
        and then (for all S of T.Sites => S.Body_Id < Bodies
          and then Bounded (S.Position, 1.0e10))
        and then (for all G of T.Geometries => G.Body_Id < Bodies
          and then Bounded (G.Position, 1.0e10) and then Rotation_Bounded (G.Orientation)
          and then G.Radius in 0.0 .. 1.0e10)
        and then (for all P of T.Tendons => P.Count in 2 .. T.Nw
          and then P.First <= T.Nw - P.Count
          and then P.Lower in -1.0e10 .. 1.0e10 and then P.Upper in -1.0e10 .. 1.0e10
          and then P.Lower <= P.Upper and then P.Stiffness in 0.0 .. 1.0e10
          and then P.Damping in 0.0 .. 1.0e10
          and then P.Spring_Linear in -1.0e10 .. 1.0e10
          and then P.Spring_Quadratic in -1.0e10 .. 1.0e10
          and then P.Damper_Linear in -1.0e10 .. 1.0e10
          and then P.Damper_Quadratic in -1.0e10 .. 1.0e10)));
   procedure Load (M : MJ.Models.Model; T : in out Description_Access;
                   Accepted : out Boolean) with
     Global => null, Pre => T = null,
     Post => (if Accepted then Ready (T, M.S.Nbody) and then Count (T) = M.S.Ntendon
                and then (if T /= null then M.S.Nq = M.S.Nv)
              else T = null);
   procedure Free (T : in out Description_Access) with
     Global => null, Post => T = null;

   --  Separate spring/damper channels preserve upstream accumulation order.
   subtype Displacement_Real is Real range -2.0e30 .. 2.0e30;
   subtype Coefficient_Real is Real range -1.0e72 .. 1.0e72;
   function Displacement (Length, Lower, Upper : Real) return Displacement_Real is
     (if Length > Upper then Length - Upper
      elsif Length < Lower then Length - Lower else 0.0) with
     Pre => Length in -1.0e30 .. 1.0e30 and then Lower in -1.0e10 .. 1.0e10
       and then Upper in -1.0e10 .. 1.0e10 and then Lower <= Upper;
   subtype Square_Real is Real range 0.0 .. 5.0e60;
   subtype Linear_Term_Real is Real range -3.0e40 .. 3.0e40;
   subtype Quadratic_Term_Real is Real range -6.0e70 .. 6.0e70;
   subtype Partial_Real is Real range -4.0e40 .. 4.0e40;
   function Polynomial (Linear, P1, P2, X : Real; Absolute : Boolean) return Coefficient_Real is
     (declare
        Square : constant Square_Real := X * X;
        Linear_Term : constant Linear_Term_Real := P1 * (if Absolute then abs X else X);
        Quadratic_Term : constant Quadratic_Term_Real := P2 * Square;
        First : constant Partial_Real := Linear + Linear_Term;
      begin First + Quadratic_Term) with
     Pre => Linear in 0.0 .. 1.0e10 and then P1 in -1.0e10 .. 1.0e10
       and then P2 in -1.0e10 .. 1.0e10 and then X in -2.0e30 .. 2.0e30;
   procedure Spring_Damper (P : Parameters; Length, Velocity : Real;
                            Spring_Enabled, Damper_Enabled : Boolean;
                            Spring, Damper : out Real) with
     Global => null,
     Pre => Length in 0.0 .. 1.0e30 and then Velocity in -1.0e30 .. 1.0e30
       and then P.Lower in -1.0e10 .. 1.0e10 and then P.Upper in -1.0e10 .. 1.0e10
       and then P.Lower <= P.Upper and then P.Stiffness in 0.0 .. 1.0e10
       and then P.Damping in 0.0 .. 1.0e10
       and then P.Spring_Linear in -1.0e10 .. 1.0e10
       and then P.Spring_Quadratic in -1.0e10 .. 1.0e10
       and then P.Damper_Linear in -1.0e10 .. 1.0e10
       and then P.Damper_Quadratic in -1.0e10 .. 1.0e10,
     Post => Spring in -1.0e103 .. 1.0e103 and then Damper in -1.0e103 .. 1.0e103
       and then Spring = (if Spring_Enabled then
         -Displacement (Length, P.Lower, P.Upper) * Polynomial (P.Stiffness,
           P.Spring_Linear, P.Spring_Quadratic, Displacement (Length, P.Lower, P.Upper), False)
         else 0.0)
       and then Damper = (if Damper_Enabled then
         -Velocity * Polynomial (P.Damping, P.Damper_Linear, P.Damper_Quadratic, Velocity, True)
         else 0.0);
end MJ.Spatial_Tendon_Models;
