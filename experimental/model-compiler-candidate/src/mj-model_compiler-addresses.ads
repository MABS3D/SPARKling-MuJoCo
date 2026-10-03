--  Copyright 2021 DeepMind Technologies Limited.
--  Licensed under the Apache License, Version 2.0; see ../../../LICENSE.
--  Modified: native Ada/SPARK translation and exact integer contracts.
with MJ.Types; use MJ.Types;

--  SaveDofOffsets, user_model.cc, MuJoCo 3.14.0. These are compiler passes,
--  not an XML parser or a completed model compiler.
package MJ.Model_Compiler.Addresses with SPARK_Mode is
   Max_Elements : constant := 131_072;
   subtype Element_Count is Natural range 0 .. Max_Elements;
   type Joint_Array is array (Natural range <>) of Joint_Kind;
   type Actuator_Block is record
      --  Resolved widths, after actuator type/plugin compilation. In particular
      --  an explicit actdim wins over the dyntype-derived default upstream.
      Controls, Outputs, Activations : Size_Type := 0;
   end record;
   type Actuator_Array is array (Natural range <>) of Actuator_Block;
   type Actuator_Address is record
      Control, Activation : Opt_Size_Type := -1;
      Output : Size_Type := 0;
   end record;
   type Actuator_Address_Array is array (Natural range <>) of Actuator_Address;
   type Totals is record
      Control, Output, Activation : Size_Type := 0;
   end record;
   type Result is (Success, Invalid_Shape, Capacity_Limit);
   type Flag_Array is array (Natural range <>) of Boolean;

   function Resolve_Activation
     (Computed, Declared : Opt_Size_Type; Has_Dynamics : Boolean) return Size_Type is
     (if Computed > 0 then Computed elsif Declared > 0 then Declared
      elsif Has_Dynamics then 1 else 0)
     with Global => null,
     Post => Resolve_Activation'Result =
       (if Computed > 0 then Computed elsif Declared > 0 then Declared
        elsif Has_Dynamics then 1 else 0);

   function Flag_Count (Flags : Flag_Array; Count : Natural) return Natural is
     (if Count = 0 then 0 else Flag_Count (Flags, Count - 1)
       + (if Flags (Count - 1) then 1 else 0))
     with Ghost => Static, Global => null,
     Pre => Flags'First = 0 and then Flags'Length <= Max_Elements
       and then Count <= Flags'Length,
     Post => Flag_Count'Result <= Count,
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");
   procedure Reveal_Flag_Count (Flags : Flag_Array; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Flags'First = 0 and then Flags'Length <= Max_Elements
       and then Count <= Flags'Length,
     Post => Flag_Count (Flags, Count) =
       (if Count = 0 then 0 else Flag_Count (Flags, Count - 1)
         + (if Flags (Count - 1) then 1 else 0));

   procedure Compile_Mocap
     (Flags : Flag_Array; Ids : in out Int_Array;
      Count : in out Size_Type; Status : out Result)
     with Global => null,
     Post => (Static =>
       (if Status = Success then Flags'First = 0 and then Flags'Length <= Max_Elements
         and then Ids'First = 0 and then Ids'Length = Flags'Length
         and then Count = Flag_Count (Flags, Flags'Length)
         and then (for all I in Flags'Range =>
           Ids (I) = (if Flags (I) then Flag_Count (Flags, I) else -1))
        else Ids = Ids'Old and then Count = Count'Old));

   --  Both bodyadr_ and eqadr_ are the element's ordinal in its resolved list.
   procedure Compile_Ordinals (Ids : in out Int_Array; Status : out Result)
     with Global => null,
     Post => (Static =>
       (if Status = Success then Ids'First = 0 and then Ids'Length <= Max_Elements
         and then (for all I in Ids'Range => Ids (I) = I)
        else Ids = Ids'Old));

   function Position_Width (Kind : Joint_Kind) return Positive is
     (case Kind is when Free => 7, when Ball => 4, when Slide | Hinge => 1)
     with Global => null, Post => Position_Width'Result in 1 .. 7;
   function Velocity_Width (Kind : Joint_Kind) return Positive is
     (case Kind is when Free => 6, when Ball => 3, when Slide | Hinge => 1)
     with Global => null, Post => Velocity_Width'Result in 1 .. 6;

   function Joint_Layout
     (Kinds : Joint_Array; Position, Velocity : Int_Array;
      Nq, Nv : Size_Type) return Boolean is
     (Kinds'First = 0 and then Position'First = 0 and then Velocity'First = 0
      and then Position'Length = Kinds'Length and then Velocity'Length = Kinds'Length
      and then (if Kinds'Length = 0 then Nq = 0 and then Nv = 0 else
        Position (0) = 0 and then Velocity (0) = 0
        and then (for all I in Kinds'Range =>
          Position (I) in Size_Type and then Velocity (I) in Size_Type
          and then (if I > 0 then
            Int64 (Position (I)) = Int64 (Position (I - 1)) + Int64 (Position_Width (Kinds (I - 1)))
            and then Int64 (Velocity (I)) = Int64 (Velocity (I - 1)) + Int64 (Velocity_Width (Kinds (I - 1)))))
        and then Nq = Position (Kinds'Last) + Position_Width (Kinds (Kinds'Last))
        and then Nv = Velocity (Kinds'Last) + Velocity_Width (Kinds (Kinds'Last))))
     with Ghost => Static;

   procedure Compile_Joints
     (Kinds : Joint_Array; Position, Velocity : in out Int_Array;
      Nq, Nv : in out Size_Type; Status : out Result)
     with Global => null,
     Post => (Static =>
       (if Status = Success then Joint_Layout (Kinds, Position, Velocity, Nq, Nv)
        else Position = Position'Old and then Velocity = Velocity'Old
          and then Nq = Nq'Old and then Nv = Nv'Old));

   --  A prefix sum is exact in the integer model; it also provides a functional
   --  specification for zero-width blocks and the -1 address sentinel.
   type Wide_Totals is record
      Control, Output, Activation : Int64 := 0;
   end record;
   function Prefix (Blocks : Actuator_Array; Count : Natural) return Wide_Totals is
     (if Count = 0 then (0, 0, 0) else
       (Prefix (Blocks, Count - 1).Control + Int64 (Blocks (Count - 1).Controls),
        Prefix (Blocks, Count - 1).Output + Int64 (Blocks (Count - 1).Outputs),
        Prefix (Blocks, Count - 1).Activation + Int64 (Blocks (Count - 1).Activations)))
     with Ghost => Static, Global => null,
     Pre => Blocks'First = 0 and then Blocks'Length <= Max_Elements
       and then Count <= Blocks'Length,
     Post => Prefix'Result.Control in 0 .. Int64 (Count) * Int64 (Max_Size)
       and then Prefix'Result.Output in 0 .. Int64 (Count) * Int64 (Max_Size)
       and then Prefix'Result.Activation in 0 .. Int64 (Count) * Int64 (Max_Size),
     Subprogram_Variant => (Decreases => Count),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   procedure Reveal_Prefix (Blocks : Actuator_Array; Count : Natural)
     with Ghost => Static, Global => null,
     Pre => Blocks'First = 0 and then Blocks'Length <= Max_Elements
       and then Count <= Blocks'Length,
     Post => (if Count = 0 then Prefix (Blocks, Count) = (0, 0, 0) else
       Prefix (Blocks, Count).Control = Prefix (Blocks, Count - 1).Control + Int64 (Blocks (Count - 1).Controls)
       and then Prefix (Blocks, Count).Output = Prefix (Blocks, Count - 1).Output + Int64 (Blocks (Count - 1).Outputs)
       and then Prefix (Blocks, Count).Activation = Prefix (Blocks, Count - 1).Activation + Int64 (Blocks (Count - 1).Activations));

   procedure Prefix_Monotonic (Blocks : Actuator_Array; First, Last : Natural)
     with Ghost => Static, Global => null,
     Pre => Blocks'First = 0 and then Blocks'Length <= Max_Elements
       and then First <= Last and then Last <= Blocks'Length,
     Post => Prefix (Blocks, First).Control <= Prefix (Blocks, Last).Control
       and then Prefix (Blocks, First).Output <= Prefix (Blocks, Last).Output
       and then Prefix (Blocks, First).Activation <= Prefix (Blocks, Last).Activation,
     Subprogram_Variant => (Decreases => Last - First);

   function Actuator_Layout
     (Blocks : Actuator_Array; Addresses : Actuator_Address_Array;
      Counts : Totals) return Boolean is
     (Blocks'First = 0 and then Blocks'Length <= Max_Elements
      and then Addresses'First = 0 and then Addresses'Length = Blocks'Length
      and then (for all I in Blocks'Range =>
        Int64 (Addresses (I).Control) =
          (if Blocks (I).Controls = 0 then -1 else Prefix (Blocks, I).Control)
        and then Int64 (Addresses (I).Output) = Prefix (Blocks, I).Output
        and then Int64 (Addresses (I).Activation) =
          (if Blocks (I).Activations = 0 then -1 else Prefix (Blocks, I).Activation))
      and then Int64 (Counts.Control) = Prefix (Blocks, Blocks'Length).Control
      and then Int64 (Counts.Output) = Prefix (Blocks, Blocks'Length).Output
      and then Int64 (Counts.Activation) = Prefix (Blocks, Blocks'Length).Activation)
     with Ghost => Static;

   procedure Compile_Actuators
     (Blocks : Actuator_Array; Addresses : in out Actuator_Address_Array;
      Counts : in out Totals; Status : out Result)
     with Global => null,
     Post => (Static =>
       (if Status = Success then Actuator_Layout (Blocks, Addresses, Counts)
        else Addresses = Addresses'Old and then Counts = Counts'Old));
end MJ.Model_Compiler.Addresses;
