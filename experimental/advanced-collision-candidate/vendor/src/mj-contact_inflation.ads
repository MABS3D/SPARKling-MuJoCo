with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Rigid_Math;

package MJ.Contact_Inflation with SPARK_Mode is
   --  Native CCD's inflate step: recover a unit direction from the witnesses,
   --  then offset only the object whose radius/margin is nonzero.  The GJK
   --  distance has a different rounded reduction and is not this length.
   procedure Inflate (First, Second : Vec; Margin1, Margin2 : Real;
                      First_Out, Second_Out : out Vec)
     with Inline, Global => null,
       Pre => (for all X of First => X in -1.0e22 .. 1.0e22)
         and (for all X of Second => X in -1.0e22 .. 1.0e22)
         and Margin1 in 0.0 .. 1.0e12 and Margin2 in 0.0 .. 1.0e12,
       Post => First_Out = (if Margin1 = 0.0 then First else
           MJ.Rigid_Math.Add (First, MJ.Rigid_Math.Scale
             (MJ.Rigid_Math.Unit (MJ.Rigid_Math.Sub (Second, First)), Margin1)))
         and then Second_Out = (if Margin2 = 0.0 then Second else
           MJ.Rigid_Math.Sub (Second, MJ.Rigid_Math.Scale
             (MJ.Rigid_Math.Unit (MJ.Rigid_Math.Sub (Second, First)), Margin2)));
end MJ.Contact_Inflation;
