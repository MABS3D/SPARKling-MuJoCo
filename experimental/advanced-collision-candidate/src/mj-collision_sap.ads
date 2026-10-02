with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.BVH;
package MJ.Collision_SAP with SPARK_Mode is
   type Mask_Array is array (Natural range <>) of Boolean;
   procedure Sweep (B : MJ.BVH.Box_Array; Active : Mask_Array; K : Axis;
                    Pairs : out MJ.BVH.Pair_Array; Count : out Natural; Result : out Status)
     with Global=>null,
       Post=>Count<=Pairs'Length and then (if Result/=Success then Count=0)
         and then (for all I in 0 .. Count-1 => Pairs (Pairs'First+I)'Initialized);
end MJ.Collision_SAP;
