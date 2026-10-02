--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see the repository LICENSE.
--  Modified: Ada/SPARK translation, bounded storage and formal contracts.
with MJ.Types; use MJ.Types;

--  Sparse row assembly from engine_core_constraint.c, MuJoCo 3.14.0.
--  Geometry/kinematics supply ordered column chains and contact-frame Jacobians.
package MJ.Constraint_Assembly with SPARK_Mode is
   Max_Dofs : constant := 4096;
   Max_Rows : constant := 8192;
   Max_Entries : constant := 1048576;
   Max_Block : constant := 10;
   subtype Dof_Count is Natural range 0 .. Max_Dofs;
   subtype Column is Natural range 0 .. Max_Dofs - 1;
   subtype Row_Count is Natural range 0 .. Max_Rows;
   subtype Entry_Count is Natural range 0 .. Max_Entries;
   subtype Row_Capacity is Positive range 1 .. Max_Rows;
   subtype Entry_Capacity is Positive range 1 .. Max_Entries;
   subtype Contact_Dimension is Positive range 1 .. 6
     with Static_Predicate => Contact_Dimension in 1 | 3 | 4 | 6;
   type Constraint_Kind is (Equality, Friction_Dof, Friction_Tendon,
     Limit_Joint, Limit_Tendon, Contact_Frictionless, Contact_Pyramidal, Contact_Elliptic);
   type Cone_Kind is (Pyramidal, Elliptic);
   type Limit_Side is (Lower, Upper);
   type Result is (Success, Skipped, Capacity_Limit);
   type Column_Array is array (Positive range <>) of Column;
   type Value_Array is array (Positive range <>) of Tier2_Real;
   type Matrix is array (Positive range <>, Positive range <>) of Tier2_Real;
   type Friction_Array is array (Positive range 1 .. 5) of Nonneg_Tier0;
   type Parameters is record
      Position : Tier1_Real := 0.0;
      Margin : Tier1_Real := 0.0;
   end record;
   type Parameter_Array is array (Positive range <>) of Parameters;
   function Parameter_Is (P, Expected : Parameters) return Boolean is
     (P.Position = Expected.Position and then P.Margin = Expected.Margin)
     with Ghost => Static;
   type Row is record
      Offset : Entry_Count := 0;  --  zero-based CSR address, as in C
      Nonzeros : Dof_Count := 0;  --  includes structural zero values
      Param : Parameters;
      Loss : Nonneg_Tier0 := 0.0;
      Kind : Constraint_Kind := Equality;
      Id : Natural := 0;
   end record;
   type Row_Array is array (Positive range <>) of Row;
   function Row_Is
     (D : Row; Offset : Entry_Count; Width : Dof_Count; Pos : Parameters;
      Loss : Nonneg_Tier0; Kind : Constraint_Kind; Id : Natural) return Boolean is
     (D.Offset = Offset and then D.Nonzeros = Width
      and then D.Param.Position = Pos.Position and then D.Param.Margin = Pos.Margin
      and then D.Loss = Loss and then D.Kind = Kind and then D.Id = Id)
     with Ghost => Static;
   type Storage (Row_Cap : Row_Capacity; Entry_Cap : Entry_Capacity) is record
      Dofs : Dof_Count := 0;
      Rows : Row_Count := 0;
      Used : Entry_Count := 0;
      Ne, Nf, Nl : Row_Count := 0;
      Descriptors : Row_Array (1 .. Row_Cap);
      Columns : Column_Array (1 .. Entry_Cap) := (others => 0);
      Values : Value_Array (1 .. Entry_Cap) := (others => 0.0);
   end record;

   function Valid (B : Storage) return Boolean is
     (B.Rows <= B.Row_Cap and then B.Used <= B.Entry_Cap
      and then (B.Ne + B.Nf) + B.Nl <= B.Rows);
   --  Cursor/count invariant. Reset + successful Append additionally establish
   --  contiguous CSR addresses through the exact append/frame contracts.

   function Valid_Chain (Chain : Column_Array; Dofs : Dof_Count) return Boolean is
     (Chain'First = 1 and then Chain'Length <= Dofs
      and then (for all C of Chain => C < Dofs)
      and then (for all K in 2 .. Chain'Last => Chain (K - 1) < Chain (K)));

   function Is_Contact (Kind : Constraint_Kind) return Boolean is
     (Kind in Contact_Frictionless | Contact_Pyramidal | Contact_Elliptic);

   procedure Reset (B : in out Storage; Dofs : Dof_Count) with
     Global => null,
     Post => (Static => Valid (B) and then B.Dofs = Dofs
       and then B.Rows = 0 and then B.Used = 0
       and then B.Ne = 0 and then B.Nf = 0 and then B.Nl = 0
       and then B.Descriptors = B.Descriptors'Old
       and then B.Columns = B.Columns'Old and then B.Values = B.Values'Old);

   function Fits (B : Storage; Rows : Positive; Width : Dof_Count) return Boolean is
     (Rows <= B.Row_Cap - B.Rows
      and then Rows * Width <= B.Entry_Cap - B.Used)
     with Pre => Valid (B) and then Rows <= Max_Block;

   --  Same sparse empty-row rule as mj_addConstraint: an empty chain skips
   --  noncontact groups, but a nonempty chain retains numeric zero entries.
   procedure Append
     (B : in out Storage; Kind : Constraint_Kind; Id : Natural;
      Chain : Column_Array; J : Matrix; Pos : Parameter_Array;
      Loss : Nonneg_Tier0; Status : out Result) with
     Global => null,
     Pre => Valid (B) and then Valid_Chain (Chain, B.Dofs)
       and then Pos'First = 1 and then Pos'Length in 1 .. Max_Block
       and then J'First (1) = 1 and then J'Length (1) = Pos'Length
       and then J'First (2) = 1 and then J'Length (2) = Chain'Length,
     Post => (Static => Valid (B) and then B.Dofs = B.Dofs'Old
       and then (if Chain'Length = 0 and then not Is_Contact (Kind) then Status = Skipped
         elsif not Fits (B'Old, Pos'Length, Chain'Length) then Status = Capacity_Limit
         else Status = Success)
       and then (if Status /= Success then B = B'Old else
         B.Rows = B.Rows'Old + Pos'Length
         and then B.Used = B.Used'Old + Pos'Length * Chain'Length
         and then B.Ne = B.Ne'Old + (if Kind = Equality then Pos'Length else 0)
         and then B.Nf = B.Nf'Old + (if Kind in Friction_Dof | Friction_Tendon then Pos'Length else 0)
         and then B.Nl = B.Nl'Old + (if Kind in Limit_Joint | Limit_Tendon then Pos'Length else 0)
         and then (for all R in 1 .. Pos'Length =>
           Row_Is (B.Descriptors (B.Rows'Old + R),
             B.Used'Old + (R - 1) * Chain'Length, Chain'Length, Pos (R), Loss, Kind, Id))
         and then (for all R in 1 .. Pos'Length => (for all C in Chain'Range =>
           B.Values ((B.Used'Old + (R - 1) * Chain'Length) + C) = J (R, C)))
         and then (for all R in 1 .. Pos'Length => (for all C in Chain'Range =>
           B.Columns ((B.Used'Old + (R - 1) * Chain'Length) + C) = Chain (C)))
         and then (for all R in B.Descriptors'Range =>
           (if R <= B.Rows'Old or else R > B.Rows then B.Descriptors (R) = B.Descriptors'Old (R)))
         and then (for all C in B.Values'Range =>
           (if C <= B.Used'Old or else C > B.Used then
             B.Values (C) = B.Values'Old (C) and then B.Columns (C) = B.Columns'Old (C)))));

   function Edge_Value (Normal, Tangent : Real; Mu : Tier0_Real) return Tier2_Real is
     (Normal + Mu * Tangent) with
     Pre => Normal in -1.0e20 .. 1.0e20 and then Tangent in -1.0e20 .. 1.0e20,
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   function Contact_Rows (Dim : Contact_Dimension; Cone : Cone_Kind) return Positive is
     (if Dim = 1 then 1 elsif Cone = Pyramidal then 2 * (Dim - 1) else Dim)
     with Post => Contact_Rows'Result <= Max_Block;
   function Contact_Type (Dim : Contact_Dimension; Cone : Cone_Kind) return Constraint_Kind is
     (if Dim = 1 then Contact_Frictionless
      elsif Cone = Pyramidal then Contact_Pyramidal else Contact_Elliptic);

   function Contact_Parameter
     (Dim : Contact_Dimension; Cone : Cone_Kind; R : Positive;
      Distance, Margin : Tier1_Real) return Parameters is
     (if R = 1 or else (Dim > 1 and then Cone = Pyramidal)
      then (Distance, Margin) else (0.0, 0.0));

   function Contact_Value
     (Dim : Contact_Dimension; Cone : Cone_Kind; J : Matrix;
      Mu : Friction_Array; R, C : Positive) return Tier2_Real is
     (if Dim = 1 or else Cone = Elliptic then J (R, C)
      else Edge_Value (J (1, C), J (1 + (R + 1) / 2, C),
             (if R mod 2 = 1 then Mu ((R + 1) / 2) else -Mu ((R + 1) / 2)))) with
     Ghost => Static,
     Pre => J'First (1) = 1 and then J'Length (1) = Dim
       and then J'First (2) = 1 and then C in J'Range (2)
       and then R <= Contact_Rows (Dim, Cone)
       and then (for all JR in J'Range (1) => (for all JC in J'Range (2) => J (JR, JC) in -1.0e20 .. 1.0e20));

   procedure Build_Contact
     (Dim : Contact_Dimension; Cone : Cone_Kind; J : Matrix;
      Mu : Friction_Array; Distance, Margin : Tier1_Real;
      Values : out Matrix; Pos : out Parameter_Array) with
     Global => null,
     Relaxed_Initialization => (Values, Pos),
     Pre => J'First (1) = 1 and then J'Length (1) = Dim
       and then J'First (2) = 1 and then J'Length (2) <= Max_Dofs
       and then (for all JR in J'Range (1) => (for all JC in J'Range (2) => J (JR, JC) in -1.0e20 .. 1.0e20))
       and then Values'First (1) = 1 and then Values'Length (1) = Contact_Rows (Dim, Cone)
       and then Values'First (2) = 1 and then Values'Length (2) = J'Length (2)
       and then Pos'First = 1 and then Pos'Length = Values'Length (1),
     Post => (Static => Values'Initialized and then Pos'Initialized and then
       (for all R in Values'Range (1) =>
         Parameter_Is (Pos (R), Contact_Parameter (Dim, Cone, R, Distance, Margin)))
       and then (for all R in Values'Range (1) => (for all C in Values'Range (2) =>
         Values (R, C) = Contact_Value (Dim, Cone, J, Mu, R, C))));

   procedure Add_Contact
     (B : in out Storage; Id : Natural; Dim : Contact_Dimension; Cone : Cone_Kind;
      Chain : Column_Array; J : Matrix; Mu : Friction_Array;
      Distance, Margin : Tier1_Real; Status : out Result) with
     Global => null,
     Pre => Valid (B) and then Valid_Chain (Chain, B.Dofs)
       and then J'First (1) = 1 and then J'Length (1) = Dim
       and then J'First (2) = 1 and then J'Length (2) = Chain'Length
       and then (for all JR in J'Range (1) => (for all JC in J'Range (2) => J (JR, JC) in -1.0e20 .. 1.0e20)),
     Post => (Static => Valid (B) and then
       (if Chain'Length = 0 then Status = Skipped
        elsif not Fits (B'Old, Contact_Rows (Dim, Cone), Chain'Length) then Status = Capacity_Limit
        else Status = Success)
       and then (if Status /= Success then B = B'Old else
         B.Rows = B.Rows'Old + Contact_Rows (Dim, Cone)
         and then B.Used = B.Used'Old + Contact_Rows (Dim, Cone) * Chain'Length
         and then B.Dofs = B.Dofs'Old
         and then B.Ne = B.Ne'Old and then B.Nf = B.Nf'Old and then B.Nl = B.Nl'Old
         and then (for all R in 1 .. Contact_Rows (Dim, Cone) =>
           Row_Is (B.Descriptors (B.Rows'Old + R),
             B.Used'Old + (R - 1) * Chain'Length, Chain'Length,
             Contact_Parameter (Dim, Cone, R, Distance, Margin),
             0.0, Contact_Type (Dim, Cone), Id))
         and then (for all R in 1 .. Contact_Rows (Dim, Cone) => (for all C in Chain'Range =>
           B.Values ((B.Used'Old + (R - 1) * Chain'Length) + C) =
             Contact_Value (Dim, Cone, J, Mu, R, C)))
         and then (for all R in 1 .. Contact_Rows (Dim, Cone) => (for all C in Chain'Range =>
           B.Columns ((B.Used'Old + (R - 1) * Chain'Length) + C) = Chain (C)))
         and then (for all R in B.Descriptors'Range =>
           (if R <= B.Rows'Old or else R > B.Rows then B.Descriptors (R) = B.Descriptors'Old (R)))
         and then (for all C in B.Values'Range =>
           (if C <= B.Used'Old or else C > B.Used then
             B.Values (C) = B.Values'Old (C) and then B.Columns (C) = B.Columns'Old (C)))));

   function Limit_Distance (Value, Bound : Tier0_Real; Side : Limit_Side) return Tier1_Real is
     ((if Side = Lower then -1.0 else 1.0) * (Bound - Value));

   procedure Add_Dof_Friction
     (B : in out Storage; Dof : Column; Loss : Nonneg_Tier0; Status : out Result) with
     Global => null, Pre => Valid (B) and then Dof < B.Dofs,
     Post => (Static => Valid (B) and then
       (if Loss = 0.0 then Status = Skipped
        elsif not Fits (B'Old, 1, 1) then Status = Capacity_Limit else Status = Success)
       and then (if Status /= Success then B = B'Old else
         B.Rows = B.Rows'Old + 1 and then B.Used = B.Used'Old + 1
         and then B.Nf = B.Nf'Old + 1 and then B.Ne = B.Ne'Old and then B.Nl = B.Nl'Old
         and then B.Descriptors (B.Rows) = (B.Used'Old, 1, (0.0, 0.0), Loss, Friction_Dof, Dof)
         and then B.Columns (B.Used) = Dof and then B.Values (B.Used) = 1.0
         and then B.Dofs = B.Dofs'Old
         and then (for all R in B.Descriptors'Range =>
           (if R /= B.Rows then B.Descriptors (R) = B.Descriptors'Old (R)))
         and then (for all C in B.Values'Range =>
           (if C /= B.Used then B.Values (C) = B.Values'Old (C)
             and then B.Columns (C) = B.Columns'Old (C)))));

   procedure Add_Scalar_Limit
     (B : in out Storage; Id : Natural; Dof : Column; Side : Limit_Side;
      Value, Bound, Margin : Tier0_Real; Status : out Result) with
     Global => null, Pre => Valid (B) and then Dof < B.Dofs,
     Post => (Static => Valid (B) and then
       (if Limit_Distance (Value, Bound, Side) >= Margin then Status = Skipped
        elsif not Fits (B'Old, 1, 1) then Status = Capacity_Limit else Status = Success)
       and then (if Status /= Success then B = B'Old else
         B.Rows = B.Rows'Old + 1 and then B.Used = B.Used'Old + 1
         and then B.Nl = B.Nl'Old + 1 and then B.Ne = B.Ne'Old and then B.Nf = B.Nf'Old
         and then B.Descriptors (B.Rows) =
           (B.Used'Old, 1, (Limit_Distance (Value, Bound, Side), Margin), 0.0, Limit_Joint, Id)
         and then B.Columns (B.Used) = Dof
         and then B.Values (B.Used) = (if Side = Lower then 1.0 else -1.0)
         and then B.Dofs = B.Dofs'Old
         and then (for all R in B.Descriptors'Range =>
           (if R /= B.Rows then B.Descriptors (R) = B.Descriptors'Old (R)))
         and then (for all C in B.Values'Range =>
           (if C /= B.Used then B.Values (C) = B.Values'Old (C)
             and then B.Columns (C) = B.Columns'Old (C)))));
end MJ.Constraint_Assembly;
