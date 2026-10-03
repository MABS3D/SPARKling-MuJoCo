with MJ.Types; use MJ.Types;
with MJ.Ray_Kernels; use MJ.Ray_Kernels;
with MJ.Quaternion_Math;
package MJ.Ray_Geometry with SPARK_Mode is
   type Kind is (Plane, Heightfield, Sphere, Capsule, Ellipsoid, Cylinder, Box, Mesh, SDF);
   type Hit is record
      Distance : Real := -1.0;
      Normal : Vector := Zero;
   end record;
   type Face_Hits is array (Integer range 0 .. 5) of Real;
   type Triangle is array (Integer range 0 .. 2) of Vector;
   function Map (R : Matrix; V : Vector) return Vector;
   function Rotate (R : Matrix; V : Vector) return Vector;
   function Normalize (V : Vector) return Vector;
   procedure Basis (Direction : Vector; B0, B1 : out Vector);
   function Discriminant (A, B, C : Real) return Real with Global => null,
     Pre => A in -1.0e100 .. 1.0e100 and then B in -1.0e100 .. 1.0e100 and then C in -1.0e100 .. 1.0e100,
     Post => Discriminant'Result = B*B-A*C and then Discriminant'Result in -5.0e200 .. 5.0e200;
   procedure Quadratic (A, B, C : Real; Low, High : out Real) with Global => null,
     Pre => A in -1.0e100 .. 1.0e100 and then B in -1.0e100 .. 1.0e100 and then C in -1.0e100 .. 1.0e100,
     Post => (if Discriminant (A,B,C)<0.0 or else A<Min_Val then Low=-1.0 and then High=-1.0
       else Low=(-B-MJ.Quaternion_Math.Sqrt (Discriminant (A,B,C)))/A
         and then High=(-B+MJ.Quaternion_Math.Sqrt (Discriminant (A,B,C)))/A)
       and then Low in -1.0e100 .. 1.0e100 and then High in -1.0e100 .. 1.0e100;
   function Intersect (Shape : Kind; Position : Vector; Rotation : Matrix;
                       Size, Point, Direction : Vector) return Hit;
   procedure Box_Faces (Position : Vector; Rotation : Matrix;
                        Size, Point, Direction : Vector; Result : out Hit;
                        Faces : out Face_Hits);
   function Intersect_Triangle (Vertices : Triangle; Point, Direction, B0, B1 : Vector) return Hit;
   function Slab (Center, Half_Size, Point, Direction : Vector) return Boolean;
end MJ.Ray_Geometry;
