with MJ.Types; use MJ.Types;
with MJ.Tendon_Kernels;
with MJ.Models;
with MJ.Smooth_Dynamics;
with Ada.Unchecked_Deallocation;

package MJ.Fixed_Tendons with SPARK_Mode is
   pragma Unevaluated_Use_Of_Old (Allow);
   package TK renames MJ.Tendon_Kernels;
   Max_Tendons : constant := 1024;
   Max_Terms : constant := TK.Max_Terms;
   type Segment is record
      First, Count : Natural := 0;
   end record;
   type Tendon is record
      Law : TK.Parameters;
      Terms, Jacobian : Segment;
   end record;
   type Tendon_Array is array (Natural range <>) of Tendon;
   type Mass_Term is record
      Index, Mirror : Natural := 0;
      Value : Real := 0.0;
   end record;
   type Mass_Plan is array (Natural range <>) of Mass_Term;
   type Description (Nt, Nw, Nz, Nm : Natural) is record
      Tendons : Tendon_Array (1 .. Nt);
      Terms : TK.Row (1 .. Nw);
      Jacobian : TK.Row (1 .. Nz);
      Mass : Mass_Plan (1 .. Nm);
   end record;
   type Description_Access is access Description;
   procedure Free is new Ada.Unchecked_Deallocation (Description, Description_Access);
   function Image (C : Description_Access) return Description is
     (if C = null then Description'(0, 0, 0, 0, others => <>) else C.all)
     with Ghost => Static, Global => null;
   function Count (C : Description_Access) return Natural is
     (if C = null then 0 else C.Nt) with Global => null;
   function Valid_Segment (S : Segment; N : Natural) return Boolean is
     (N <= Max_Terms and then S.First in 1 .. N + 1 and then S.Count <= N + 1 - S.First) with Global => null;
   function Kinematic_Layout (C : Description; Nv : Natural) return Boolean is
     (Nv <= 256 and then C.Nt <= Max_Tendons and then C.Nw <= Max_Terms
      and then C.Nz <= Max_Terms
      and then (for all T of C.Tendons => T.Law.Lower <= T.Law.Upper
        and then Valid_Segment (T.Terms, C.Nw)
        and then Valid_Segment (T.Jacobian, C.Nz))
      and then (for all E of C.Terms => E.Dof < Nv)
      and then (for all E of C.Jacobian => E.Dof < Nv)) with Global => null;
   function Valid (C : Description; Nv : Natural) return Boolean is
     (Kinematic_Layout (C, Nv) and then C.Nm <= Max_Terms
      and then (if C.Nm > 0 then Nv > 0)
      and then (for all E of C.Mass => E.Index < Nv * Nv
        and then E.Mirror = (E.Index mod Nv) * Nv + E.Index / Nv
        and then E.Value in -1.0e31 .. 1.0e31)) with Global => null;
   function Ready (C : Description_Access; Nv : Natural) return Boolean is
     (C = null or else Valid (C.all, Nv)) with Global => null;
   type Load_Status is (Success, Unsupported, Invalid, Capacity);
   procedure Load (M : MJ.Models.Model; C : in out Description_Access;
                   Result : out Load_Status)
     with Global => null, Pre => C = null and then MJ.Models.Valid_Layout (M),
     Post => (if Result = Success then Ready (C, M.S.Nv) else C = null);

   procedure Kinematics (C : Description; I : Natural; Q, V : Real_Array;
                         Length, Velocity : out TK.Coordinate)
     with Global => null,
     Pre => Q'Length <= 256 and then Kinematic_Layout (C, Q'Length) and then I in C.Tendons'Range
       and then Q'First = 0 and then V'First = 0 and then V'Length = Q'Length
       and then (for all X of Q => X in Tier0_Real)
       and then (for all X of V => X in Tier0_Real),
     Post => Length in -5.0e29 .. 5.0e29;
   pragma Postcondition (Static => Length = TK.Reduction
     (C.Terms (C.Tendons (I).Terms.First .. C.Tendons (I).Terms.First + C.Tendons (I).Terms.Count - 1),
      Q, C.Tendons (I).Terms.Count)
     and then Velocity = TK.Sparse_Model
     (C.Jacobian (C.Tendons (I).Jacobian.First .. C.Tendons (I).Jacobian.First + C.Tendons (I).Jacobian.Count - 1),
      V, C.Tendons (I).Jacobian.Count mod 4));
   --  Keep springs and dampers separate until all tendons have been projected,
   --  as mj_passive does. Both arrays may already contain joint contributions.
   procedure Project_Pair
     (Spring, Damper : in out Real_Array; Index : Natural; J : Tier0_Real;
      Fs, Fd : TK.Tendon_Force; Ok : out Boolean)
     with Global => null,
     Pre => Index in Spring'Range and then Index in Damper'Range
       and then (for all X of Spring => X in TK.Mass_Value)
       and then (for all X of Damper => X in TK.Mass_Value),
     Post => (for all X of Spring => X in TK.Mass_Value)
       and then (for all X of Damper => X in TK.Mass_Value)
       and then Ok = (TK.Project (Spring'Old (Index), J, Fs) in TK.Mass_Value
         and then TK.Project (Damper'Old (Index), J, Fd) in TK.Mass_Value)
       and then (for all I in Spring'Range => Spring (I) =
         (if Ok and then I = Index then TK.Project (Spring'Old (I), J, Fs) else Spring'Old (I)))
       and then (for all I in Damper'Range => Damper (I) =
         (if Ok and then I = Index then TK.Project (Damper'Old (I), J, Fd) else Damper'Old (I)));
   pragma Inline_Always (Project_Pair);
   procedure Project_Small_Pair
     (Spring, Damper : in out Real_Array; Index : Natural; J : Tier0_Real;
      Fs, Fd : TK.Small_Force)
     with Global => null,
     Pre => Index in Spring'Range and then Index in Damper'Range
       and then (for all X of Spring => X in TK.Mass_Value)
       and then (for all X of Damper => X in TK.Mass_Value),
     Post => (for all X of Spring => X in TK.Mass_Value)
       and then (for all X of Damper => X in TK.Mass_Value)
       and then (for all I in Spring'Range => Spring (I) =
         (if I = Index then TK.Project_Small (Spring'Old (I), J, Fs) else Spring'Old (I)))
       and then (for all I in Damper'Range => Damper (I) =
         (if I = Index then TK.Project_Small (Damper'Old (I), J, Fd) else Damper'Old (I)));
   pragma Inline_Always (Project_Small_Pair);
   procedure Add_Passive
     (C : Description; Q, V : Real_Array; Spring_Enabled, Damper_Enabled : Boolean;
      Spring, Damper : in out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Q'Length <= 256 and then Kinematic_Layout (C, Q'Length) and then Q'First = 0 and then V'First = 0
       and then V'Length = Q'Length and then Spring'First = 0 and then Damper'First = 0
       and then Spring'Length = Q'Length and then Damper'Length = Q'Length
       and then (for all X of Q => X in Tier0_Real)
       and then (for all X of V => X in Tier0_Real)
       and then (for all X of Spring => X in -1.0e60 .. 1.0e60)
       and then (for all X of Damper => X in -1.0e60 .. 1.0e60),
     Post => (for all X of Spring => X in -1.0e60 .. 1.0e60)
       and then (for all X of Damper => X in -1.0e60 .. 1.0e60);
   function Mass_Model (C : Description; Initial : Real_Array;
                        Nv, Index, Count : Natural) return TK.Mass_Value is
     (if Count = 0 then Initial (Index)
      elsif C.Mass (Count).Index = Index or else C.Mass (Count).Mirror = Index then
        TK.Accumulate_Mass (Mass_Model (C, Initial, Nv, Index, Count - 1), C.Mass (Count).Value)
      else Mass_Model (C, Initial, Nv, Index, Count - 1))
     with Ghost => Static, Global => null,
     Pre => Nv <= 256 and then Valid (C, Nv) and then Count <= C.Nm
       and then MJ.Smooth_Dynamics.Square_Layout (Initial, Nv)
       and then Index in Initial'Range
       and then (for all X of Initial => X in TK.Mass_Value),
     Post => (if Count = 0 then Mass_Model'Result = Initial (Index)),
     Subprogram_Variant => (Decreases => Count);
   procedure Unfold_Mass (C : Description; Initial : Real_Array; Nv, Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Nv <= 256 and then Valid (C, Nv) and then Count in 1 .. C.Nm
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
     Pre => Nv <= 256 and then Mass'Length <= 65_536 and then Valid (C, Nv) and then MJ.Smooth_Dynamics.Square_Layout (Mass, Nv)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv)
       and then (for all X of Mass => X in -1.0e60 .. 1.0e60),
     Post => Ok and then (for all X of Mass => X in -1.0e60 .. 1.0e60)
       and then MJ.Smooth_Dynamics.Symmetric (Mass, Nv);
   pragma Postcondition (Static => (for all I in Mass'Range =>
     Mass (I) = Mass_Model (C, Mass'Old, Nv, I, C.Nm)));
end MJ.Fixed_Tendons;
