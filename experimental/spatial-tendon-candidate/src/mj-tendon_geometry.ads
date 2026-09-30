with Ada.Numerics.Long_Elementary_Functions;
with MJ.Types; use MJ.Types;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;

--  Translation of MuJoCo 3.14.0 engine_util_misc.c wrapping routines.
--  Apache-2.0; original algorithm copyright Google DeepMind and contributors.
package MJ.Tendon_Geometry with SPARK_Mode is
   type Geometry_Kind is (Sphere, Cylinder);
   type Wrap_Status is (No_Wrap, Wrapped, Numeric_Limit);
   type Wrap_Result is record
      Status : Wrap_Status := No_Wrap;
      First, Last : Vector := Zero;
      Arc_Length : Real := 0.0;
   end record;

   function Norm (V : Vector) return Real with
     Pre => Bounded (V, 1.0e100), Post => Norm'Result >= 0.0
       and then Norm'Result = Ada.Numerics.Long_Elementary_Functions.Sqrt (Dot (V, V));
   --  Same tiny-vector convention as mju_normalize3: (1, 0, 0).
   function Unit (V : Vector) return Vector with
     Pre => Bounded (V, 1.0e100),
     Post => Bounded (Unit'Result, 2.0e115)
       and then (if Bounded (V, 1.0e40) then Bounded (Unit'Result, 2.0e55))
       and then Unit'Result = (if Norm (V) < 1.0e-15 then (1.0, 0.0, 0.0)
       else Scale (V, 1.0 / Norm (V)));

   function Wrap
     (Start, Finish, Center : Vector; Orientation : Matrix; Radius : Real;
      Kind : Geometry_Kind; Has_Side : Boolean := False; Side : Vector := Zero)
      return Wrap_Result with
     Pre => Bounded (Start, 1.0e10) and then Bounded (Finish, 1.0e10)
       and then Bounded (Center, 1.0e10) and then Bounded (Side, 1.0e10)
       and then Rotation_Bounded (Orientation) and then Radius in 0.0 .. 1.0e10,
     Post => (if Wrap'Result.Status = Wrapped then
                Wrap'Result.Arc_Length in 0.0 .. 1.0e100
                and then Bounded (Wrap'Result.First, 1.0e100)
                and then Bounded (Wrap'Result.Last, 1.0e100)
              else Wrap'Result.First = Zero and then Wrap'Result.Last = Zero
                and then Wrap'Result.Arc_Length = 0.0);
   --  Orientation must be an actual local-to-world rotation supplied by
   --  kinematics. Component bounds alone do not establish orthogonality.
   --  Arc_Length excludes the two straight legs. Cylinder uses the infinite
   --  lateral surface (no end caps), exactly as upstream.
end MJ.Tendon_Geometry;
