with MJ.Types; use MJ.Types;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Spatial_Tendons;

package MJ.Tendon_Adapters with SPARK_Mode is
   function Column (Flat : Real_Array; Body_Index, Dof, Dofs : Natural) return Vector is
     ((Flat (3 * (Body_Index * Dofs + Dof)),
       Flat (3 * (Body_Index * Dofs + Dof) + 1),
       Flat (3 * (Body_Index * Dofs + Dof) + 2))) with
     Global => null,
     Pre => Body_Index < 4096 and then Dofs <= 256 and then Dof < Dofs
       and then Flat'First = 0 and then Flat'Last >= 3 * (Body_Index * Dofs + Dof) + 2;

   function Jacobian (Flat : Real_Array; Bodies, Dofs : Natural)
     return MJ.Spatial_Tendons.Body_Jacobian is
     ([for B in 0 .. Bodies - 1 => [for K in 0 .. Dofs - 1 => Column (Flat, B, K, Dofs)]]) with
     Global => null,
     Pre => Bodies in 1 .. 4096 and then Dofs <= 256 and then Flat'First = 0
       and then Int64 (Flat'Length) = 3 * Int64 (Bodies) * Int64 (Dofs),
     Post => Jacobian'Result'First (1) = 0 and then Jacobian'Result'Last (1) = Bodies - 1
       and then Jacobian'Result'First (2) = 0 and then Jacobian'Result'Last (2) = Dofs - 1;
end MJ.Tendon_Adapters;
