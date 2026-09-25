with MJ.Types; use MJ.Types;

--  Owned immutable topology and constant inertial terms. Derived once from the
--  validated scalar-joint model; no pointer to caller-owned model storage escapes.
package MJ.Smooth_Topology with SPARK_Mode is
   Max_Bodies : constant := 4_096;
   Max_Dofs : constant := 256;
   type Cache is limited private;
   function Empty (T : Cache) return Boolean with Global => null;
   function Body_Count (T : Cache) return Natural with Global => null;
   function Dof_Count (T : Cache) return Natural with Global => null;
   function Root (T : Cache; B : Natural) return Natural with
     Global => null, Pre => B < Body_Count (T),
     Post => Root'Result in 0 .. B and then (if B > 0 then Root'Result > 0);
   pragma Inline (Root);
   function Last_Dof (T : Cache; B : Natural) return Integer with
     Global => null, Pre => B < Body_Count (T),
     Post => Last_Dof'Result in -1 .. Dof_Count (T) - 1;
   pragma Inline (Last_Dof);
   function Parent_Dof (T : Cache; V : Natural) return Integer with
     Global => null, Pre => V < Dof_Count (T),
     Post => Parent_Dof'Result in -1 .. V - 1;
   pragma Inline (Parent_Dof);
   function Dof_Body (T : Cache; V : Natural) return Natural with
     Global => null, Pre => V < Dof_Count (T),
     Post => Dof_Body'Result in 1 .. Body_Count (T) - 1;
   pragma Inline (Dof_Body);
   function Dof_Joint (T : Cache; V : Natural) return Natural with
     Global => null, Pre => V < Dof_Count (T),
     Post => Dof_Joint'Result = V;
   pragma Inline (Dof_Joint);
   function Simple_Count (T : Cache; V : Natural) return Natural with
     Global => null, Pre => V < Dof_Count (T),
     Post => Simple_Count'Result <= Dof_Count (T) - V;
   pragma Inline (Simple_Count);
   function Subtree_Mass (T : Cache; B : Natural) return Real with
     Global => null, Pre => B < Body_Count (T),
     Post => Subtree_Mass'Result in 0.0 .. 1.0e14;
   pragma Inline (Subtree_Mass);
   function Armature (T : Cache; V : Natural) return Real with
     Global => null, Pre => V < Dof_Count (T),
     Post => Armature'Result in 0.0 .. 1.0e10;
   pragma Inline (Armature);
   function Fixed_Inertia (T : Cache; V : Natural) return Real with
     Global => null, Pre => V < Dof_Count (T),
     Post => Fixed_Inertia'Result in 0.0 .. 2.0e10;
   pragma Inline (Fixed_Inertia);

   function Valid_Inputs
     (Roots, Last, Parents, Bodies, Joints, Simple : Int_Array;
      Masses, Arms, Fixed : Real_Array) return Boolean is
     (Roots'First = 0 and then Roots'Length in 1 .. Max_Bodies
      and then Last'First = 0 and then Last'Last = Roots'Last
      and then Parents'First = 0 and then Parents'Length <= Max_Dofs
      and then Bodies'First = 0 and then Bodies'Last = Parents'Last
      and then Joints'First = 0 and then Joints'Last = Parents'Last
      and then Simple'First = 0 and then Simple'Last = Parents'Last
      and then Masses'First = 0 and then Masses'Last = Roots'Last
      and then Arms'First = 0 and then Arms'Last = Parents'Last
      and then Fixed'First = 0 and then Fixed'Last = Parents'Last
      and then (for all B in Roots'Range =>
        Roots (B) in 0 .. B and then (if B > 0 then Roots (B) > 0)
        and then Last (B) in -1 .. Parents'Last
        and then Masses (B) in 0.0 .. 1.0e14)
      and then (for all V in Parents'Range =>
        Parents (V) in -1 .. V - 1 and then Bodies (V) in 1 .. Roots'Last
        and then Joints (V) = V and then Simple (V) in 0 .. Parents'Length - V
        and then Arms (V) in 0.0 .. 1.0e10 and then Fixed (V) in 0.0 .. 2.0e10));

   procedure Build (T : in out Cache;
                    Roots, Last, Parents, Bodies, Joints, Simple : Int_Array;
                    Masses, Arms, Fixed : Real_Array) with
     Global => null,
     Pre => Empty (T) and then Valid_Inputs (Roots, Last, Parents, Bodies, Joints, Simple, Masses, Arms, Fixed),
     Post => not Empty (T) and then Body_Count (T) = Roots'Length and then Dof_Count (T) = Parents'Length
       and then (for all B in Roots'Range => Root (T, B) = Roots (B)
         and then Last_Dof (T, B) = Last (B) and then Subtree_Mass (T, B) = Masses (B))
       and then (for all V in Parents'Range => Parent_Dof (T, V) = Parents (V)
         and then Dof_Body (T, V) = Bodies (V) and then Dof_Joint (T, V) = Joints (V)
         and then Simple_Count (T, V) = Simple (V) and then Armature (T, V) = Arms (V)
         and then Fixed_Inertia (T, V) = Fixed (V));
   procedure Free (T : in out Cache) with Global => null,
     Post => Empty (T) and then Body_Count (T) = 0 and then Dof_Count (T) = 0;

   --  Exact single parent accumulation, preserving every other body. The caller
   --  uses reverse body order, just as mj_comPos does at model construction.
   procedure Add_Subtree (Masses : in out Real_Array; Parent, Child : Natural; Ok : out Boolean) with
     Global => null,
     Pre => Parent in Masses'Range and then Child in Masses'Range and then Parent < Child
       and then (for all X of Masses => X in 0.0 .. 1.0e14),
     Post => (for all X of Masses => X in 0.0 .. 1.0e14)
       and then (for all I in Masses'Range =>
         (if Ok and then I = Parent then Masses (I) = Masses'Old (Parent) + Masses'Old (Child)
          else Masses (I) = Masses'Old (I)))
       and then Ok = (Masses'Old (Parent) + Masses'Old (Child) <= 1.0e14);

   function Valid_Body_Links (Parents, First, Counts : Int_Array; Nv : Natural) return Boolean is
     (Nv <= Max_Dofs and then Parents'First = 0 and then Parents'Length in 1 .. Max_Bodies
      and then First'First = 0 and then First'Last = Parents'Last
      and then Counts'First = 0 and then Counts'Last = Parents'Last
      and then Parents (0) = 0 and then Counts (0) = 0
      and then (for all B in 1 .. Parents'Last => Parents (B) in 0 .. B - 1)
      and then (for all B in Counts'Range => Counts (B) in 0 .. Nv
        and then (if Counts (B) > 0 then First (B) in 0 .. Nv - Counts (B))));
   procedure Build_Body_Links (Parents, First, Counts : Int_Array; Nv : Natural;
                               Roots, Last : out Int_Array) with
     Global => null,
     Pre => Valid_Body_Links (Parents, First, Counts, Nv)
       and then Roots'First = 0 and then Roots'Last = Parents'Last
       and then Last'First = 0 and then Last'Last = Parents'Last,
     Post => Roots (0) = 0 and then Last (0) = -1
       and then (for all B in Roots'Range => Roots (B) in 0 .. B
         and then (if B > 0 then Roots (B) > 0) and then Last (B) in -1 .. Nv - 1)
       and then (for all B in 1 .. Roots'Last =>
         Roots (B) = (if Parents (B) = 0 then B else Roots (Parents (B)))
         and then Last (B) = (if Counts (B) = 0 then Last (Parents (B))
                             else First (B) + Counts (B) - 1));

private
   function Valid (T : Cache) return Boolean with Global => null;
   type Cache is limited record
      Nb : Natural range 0 .. Max_Bodies := 0;
      Nv : Natural range 0 .. Max_Dofs := 0;
      Roots, Last, Parents, Bodies, Joints, Simple : Int_Array_Access := null;
      Masses, Arms, Fixed : Real_Array_Access := null;
   end record with Type_Invariant => Valid (Cache);
   function Empty (T : Cache) return Boolean is (T.Roots = null);
   function Body_Count (T : Cache) return Natural is (T.Nb);
   function Dof_Count (T : Cache) return Natural is (T.Nv);
   function Valid (T : Cache) return Boolean is
     (if T.Roots = null then T.Nb = 0 and then T.Nv = 0
        and then T.Last = null and then T.Parents = null and then T.Bodies = null
        and then T.Joints = null and then T.Simple = null and then T.Masses = null
        and then T.Arms = null and then T.Fixed = null
      else T.Last /= null and then T.Parents /= null and then T.Bodies /= null
        and then T.Joints /= null and then T.Simple /= null and then T.Masses /= null
        and then T.Arms /= null and then T.Fixed /= null
        and then Int64 (T.Nb) = Int64 (T.Roots'Length) and then Int64 (T.Nv) = Int64 (T.Parents'Length)
        and then Valid_Inputs (T.Roots.all, T.Last.all, T.Parents.all, T.Bodies.all,
          T.Joints.all, T.Simple.all, T.Masses.all, T.Arms.all, T.Fixed.all));
   function Root (T : Cache; B : Natural) return Natural is (T.Roots (B));
   function Last_Dof (T : Cache; B : Natural) return Integer is (T.Last (B));
   function Parent_Dof (T : Cache; V : Natural) return Integer is (T.Parents (V));
   function Dof_Body (T : Cache; V : Natural) return Natural is (T.Bodies (V));
   --  Scalar joints have one DOF and are stored in DOF order. Valid_Inputs
   --  proves the identity once, so the hot path needs no index-array load.
   function Dof_Joint (T : Cache; V : Natural) return Natural is (V);
   function Simple_Count (T : Cache; V : Natural) return Natural is (T.Simple (V));
   function Subtree_Mass (T : Cache; B : Natural) return Real is (T.Masses (B));
   function Armature (T : Cache; V : Natural) return Real is (T.Arms (V));
   function Fixed_Inertia (T : Cache; V : Natural) return Real is (T.Fixed (V));
end MJ.Smooth_Topology;
