with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Types; use MJ.Types;
with MJ.Models;
with MJ.Tendon_Kernels;
with MJ.Smooth_Dynamics;
with MJ.Spatial_Tendons; use MJ.Spatial_Tendons;

--  Immutable, owned copy of spatial-tendon configuration. No pointer into M
--  survives Load: a caller may release the MJB model after Data.Create.
package MJ.Spatial_Tendon_Models with SPARK_Mode is
   package TK renames MJ.Tendon_Kernels;
   Max_Objects : constant := 4096;
   type Parameters is record
      Fixed : Boolean := False;
      Jacobian_Count : Natural := 0;
      Armature : Nonneg_Tier0 := 0.0;
      First : Natural := 0;
      Count : Natural := 0;
      Lower, Upper, Stiffness, Damping : Real := 0.0;
      Spring_Linear, Spring_Quadratic : Real := 0.0;
      Damper_Linear, Damper_Quadratic : Real := 0.0;
   end record;
   type Parameter_Array is array (Natural range <>) of Parameters;
   type Mass_Term is record
      Index, Mirror : Natural := 0;
      Value : Real := 0.0;
   end record;
   type Mass_Plan is array (Natural range <>) of Mass_Term;
   type Description (Nt, Ns, Ng, Nw, Nm : Natural) is record
      Nb, Nq, Nv : Natural := 0;
      Has_Spatial : Boolean := False;
      Terms, Jacobian : TK.Row (1 .. Nw);
      Mass : Mass_Plan (1 .. Nm);
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
   function Mass_Ready (C : Description; Nv : Natural) return Boolean is
     (Nv <= 256 and then C.Nv = Nv and then C.Nm <= TK.Max_Terms
      and then (if C.Nm > 0 then Nv > 0)
      and then (for all E of C.Mass => E.Index < Nv * Nv
        and then E.Mirror = (E.Index mod Nv) * Nv + E.Index / Nv
        and then E.Value in -1.0e31 .. 1.0e31)) with Global => null;
   function Ready (T : Description_Access; Bodies : Natural) return Boolean is
     (T = null or else (T.Nt in 1 .. Max_Objects and then T.Ns <= Max_Objects
        and then T.Ng <= Max_Objects and then T.Nw <= Max_Objects
        and then T.Nq <= Max_Objects and then Mass_Ready (T.all, T.Nv)
        and then T.Has_Spatial = (for some P of T.Tendons => not P.Fixed)
        and then T.Nb = Bodies and then Bodies in 1 .. Max_Objects
        and then (for all S of T.Sites => S.Body_Id < Bodies
          and then Bounded (S.Position, 1.0e10))
        and then (for all G of T.Geometries => G.Body_Id < Bodies
          and then Bounded (G.Position, 1.0e10) and then Rotation_Bounded (G.Orientation)
          and then G.Radius in 0.0 .. 1.0e10)
        and then (for all P of T.Tendons => P.Count in (if P.Fixed then 1 else 2) .. T.Nw
          and then P.First <= T.Nw - P.Count
          and then P.Jacobian_Count <= P.Count
          and then (if P.Fixed then
            (for all K in P.First + 1 .. P.First + P.Count => T.Terms (K).Dof < T.Nq)
            and then (for all K in P.First + 1 .. P.First + P.Jacobian_Count => T.Jacobian (K).Dof < T.Nv))
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
     Pre => Length in -1.0e30 .. 1.0e30 and then Velocity in -1.0e30 .. 1.0e30
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
   function Mass_Model (C : Description; Initial : Real_Array;
                        Nv, Index, Count : Natural) return TK.Mass_Value is
     (if Count = 0 then Initial (Index)
      elsif C.Mass (Count).Index = Index or else C.Mass (Count).Mirror = Index then
        TK.Accumulate_Mass (Mass_Model (C, Initial, Nv, Index, Count - 1), C.Mass (Count).Value)
      else Mass_Model (C, Initial, Nv, Index, Count - 1))
     with Ghost => Static, Global => null,
     Pre => Nv <= 256 and then Mass_Ready (C, Nv) and then Count <= C.Nm
       and then MJ.Smooth_Dynamics.Square_Layout (Initial, Nv)
       and then Index in Initial'Range
       and then (for all X of Initial => X in TK.Mass_Value),
     Post => (if Count = 0 then Mass_Model'Result = Initial (Index)),
     Subprogram_Variant => (Decreases => Count);
   procedure Unfold_Mass (C : Description; Initial : Real_Array; Nv, Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Nv <= 256 and then Mass_Ready (C, Nv) and then Count in 1 .. C.Nm
       and then MJ.Smooth_Dynamics.Square_Layout (Initial, Nv)
       and then (for all X of Initial => X in TK.Mass_Value),
     Post => (for all I in Initial'Range => Mass_Model (C, Initial, Nv, I, Count) =
       (if C.Mass (Count).Index = I or else C.Mass (Count).Mirror = I then
          TK.Accumulate_Mass (Mass_Model (C, Initial, Nv, I, Count - 1), C.Mass (Count).Value)
        else Mass_Model (C, Initial, Nv, I, Count - 1)));
   procedure Store_Mass_Pair (Mass : in out Real_Array; Nv, Target, Mirror : Natural;
                              Change : TK.Mass_Change)
     with Global => null,
     Pre => Nv in 1 .. 256 and then MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then Target in Mass'Range and then Mirror = (Target mod Nv) * Nv + Target / Nv
       and then (for all X of Mass => X in TK.Mass_Value)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv),
     Post => (for all X of Mass => X in TK.Mass_Value)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
       and then (for all I in Mass'Range => Mass (I) =
         (if I = Target or else I = Mirror then TK.Accumulate_Mass (Mass'Old (I), Change)
          else Mass'Old (I)));
   pragma Inline_Always (Store_Mass_Pair);
   procedure Add_Mass (C : Description; Nv : Natural;
                       Mass : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Nv <= 256 and then Mass'Length <= 65_536 and then Mass_Ready (C, Nv) and then MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
       and then (for all X of Mass => X in -1.0e60 .. 1.0e60),
     Post => Ok and then (for all X of Mass => X in -1.0e60 .. 1.0e60)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv);
   pragma Postcondition (Static => (for all I in Mass'Range =>
     Mass (I) = Mass_Model (C, Mass'Old, Nv, I, C.Nm)));
end MJ.Spatial_Tendon_Models;
