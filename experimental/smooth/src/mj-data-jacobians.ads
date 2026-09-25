--  Internal materialization boundary. Column formulas and stores have exact
--  contracts; the full topology-to-matrix functional refinement remains pending.
private package MJ.Data.Jacobians with SPARK_Mode is
   procedure Column
     (Hinge : Boolean; Center, Anchor, Direction : Vector;
      Linear, Angular : out Vector; Ok : out Boolean)
     with Global => null,
     Pre => Bounded (Center) and then Bounded (Anchor) and then Bounded (Direction, 1.00001),
     Post => Linear = (if Hinge then Cross (Direction, Center - Anchor) else Direction)
       and then Angular = (if Hinge then Direction else Zero)
       and then Ok = (Bounded (Linear) and then Bounded (Angular));

   procedure Store_Column
     (Linear, Angular : in out Real_Array; Base : Natural; L, A : Vector)
     with Global => null,
     Pre => Linear'First = 0 and then Angular'First = 0
       and then Linear'Last = Angular'Last and then Linear'Length <= Max_Size
       and then Int64 (Base) + 2 <= Int64 (Linear'Last)
       and then Bounded (L) and then Bounded (A)
       and then (for all X of Linear => Within_Work (X))
       and then (for all X of Angular => Within_Work (X)),
     Post => (for all I in Linear'Range =>
       Linear (I) = (if I in Base .. Base + 2 then L (I - Base) else Linear'Old (I)))
       and then (for all I in Angular'Range =>
       Angular (I) = (if I in Base .. Base + 2 then A (I - Base) else Angular'Old (I)))
       and then (for all I in 0 .. Base - 1 => Linear (I) = Linear'Old (I)
         and then Angular (I) = Angular'Old (I))
       and then (for all X of Linear => Within_Work (X))
       and then (for all X of Angular => Within_Work (X));

   function Topology (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array) return Boolean is
     ((for all B in Bodies'Range => (if B = 0 then Bodies (B).Parent = 0 else Bodies (B).Parent < B)
       and then Bodies (B).Joint_Count <= Joints'Length
       and then (if Bodies (B).Joint_Count > 0 then Bodies (B).First_Joint >= 0
         and then Bodies (B).First_Joint <= Joints'Length - Bodies (B).Joint_Count))
      and then (for all J of Joints => J.Vadr < Joints'Length))
     with Global => null, Pre => Joints'Length <= Max_Dofs;

   procedure Build
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Linear, Angular : out Real_Array; Ok : out Boolean)
     with Global => null,
     Pre => Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Joints'First = 0 and then Joints'Length <= Max_Dofs
       and then Topology (Bodies, Joints)
       and then Body_Poses'First = 0 and then Body_Poses'Length = Bodies'Length
       and then Joint_Poses'First = 0 and then Joint_Poses'Length = Joints'Length
       and then (for all B of Body_Poses => Bounded (B.Center))
       and then (for all J of Joint_Poses => Joint_Bounded (J))
       and then Linear'First = 0 and then Angular'First = 0
       and then Linear'Last = 3 * Bodies'Length * Joints'Length - 1
       and then Angular'Last = Linear'Last,
     Post => (for all X of Linear => Within_Work (X))
       and then (for all X of Angular => Within_Work (X))
       and then (for all I in Linear'Range => (if I < 3 * Joints'Length then Linear (I) = 0.0 and then Angular (I) = 0.0));
end MJ.Data.Jacobians;
