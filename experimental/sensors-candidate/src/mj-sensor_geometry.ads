with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
package MJ.Sensor_Geometry with SPARK_Mode is
   function Inside (Kind : Integer; Size, Point : Vector) return Boolean;
   function Distance (Kind : Integer; Size, Point : Vector) return Real;
   -- Point/direction already expressed in the primitive's own frame.
   -- Negative result means no intersection; domain failures set Ok=False.
   procedure Ray (Kind : Integer; Size, Point, Direction : Vector;
                  Distance : out Real; Ok : out Boolean);
end MJ.Sensor_Geometry;
