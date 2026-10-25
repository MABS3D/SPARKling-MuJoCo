with MJ.Spatial_Kernels;
with MJ.Spatial_Storage;
with MJ.Smooth_Dynamics;
with MJ.Compact_Inertia;
with MJ.Data.Composite_Assembly;
--  Direct compact CRB construction. Inputs are independent borrowed fields;
--  no whole Simulation formal aliases the writable cache.
private package MJ.Data.Compact_Assembly with SPARK_Mode is
   package AR renames MJ.Ancestor_Rows;
   package T renames MJ.Smooth_Topology;
   package CI renames MJ.Compact_Inertia;
   package CA renames MJ.Data.Composite_Assembly;
   package SK renames MJ.Spatial_Kernels;
   function Valid_Inputs
     (Rows : AR.Pattern; Topology : T.Cache; Composite : CA.Composite_Array;
      Motions : Real_Array) return Boolean is
     (AR.Size (Rows) = T.Dof_Count (Topology)
      and then Composite'First = 0 and then Composite'Length in 1 .. Max_Bodies
      and then Composite'Length = T.Body_Count (Topology)
      and then (for all X of Composite => SK.Bounded (X, 1.0e40))
      and then Motions'First = 0 and then Motions'Last = 6 * AR.Size (Rows) - 1
      and then (for all X of Motions => X in -1.0e12 .. 1.0e12));
   function Row_Value
     (Rows : AR.Pattern; Topology : T.Cache; Composite : CA.Composite_Array;
      Motions : Real_Array; Row, A : Natural) return Real is
     (if T.Simple_Count (Topology, Row) > 0 then
        (if A = AR.Length (Rows, Row) - 1 then T.Fixed_Inertia (Topology, Row) else 0.0)
      else CI.Projected
        (MJ.Spatial_Storage.Load_Motion (Motions, 6 * AR.Column (Rows, Row, A)),
         SK.Multiply (Composite (T.Dof_Body (Topology, Row)),
           MJ.Spatial_Storage.Load_Motion (Motions, 6 * Row)),
         T.Armature (Topology, Row), A = AR.Length (Rows, Row) - 1))
     with Ghost => Static, Global => null,
     Pre => Valid_Inputs (Rows, Topology, Composite, Motions)
       and then Row < AR.Size (Rows) and then A < AR.Length (Rows, Row);
   procedure Fill
     (Rows : AR.Pattern; Topology : T.Cache; Composite : CA.Composite_Array;
      Motions : Real_Array; Mass : out Real_Array; Ok : out Boolean) with
     Global => null,
     Pre => Valid_Inputs (Rows, Topology, Composite, Motions)
       and then Mass'First = 0 and then Mass'Last = AR.Count (Rows) - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Mass);
   pragma Postcondition (Static => (if Ok then
     (for all R in 0 .. AR.Size (Rows) - 1 =>
       (for all A in 0 .. AR.Length (Rows, R) - 1 =>
         Mass (AR.Start (Rows, R) + A) = Row_Value (Rows, Topology, Composite, Motions, R, A)))));
   procedure Build
     (Rows : AR.Pattern; Topology : T.Cache; Bodies : Body_Parameter_Array;
      Inertias, Motions : Real_Array; Mass : out Real_Array; Ok : out Boolean) with
     Global => null,
     Pre => AR.Size (Rows) = T.Dof_Count (Topology)
       and then Bodies'First = 0 and then Bodies'Length in 1 .. Max_Bodies
       and then Bodies'Length = T.Body_Count (Topology)
       and then (for all B in 1 .. Bodies'Last => Bodies (B).Parent < B)
       and then Inertias'First = 0 and then Inertias'Last = 10 * Bodies'Length - 1
       and then (for all X of Inertias => X in -1.0e36 .. 1.0e36)
       and then Motions'First = 0 and then Motions'Last = 6 * AR.Size (Rows) - 1
       and then (for all X of Motions => X in -1.0e12 .. 1.0e12)
       and then Mass'First = 0 and then Mass'Last = AR.Count (Rows) - 1,
     Post => MJ.Smooth_Dynamics.Work_Array (Mass);
end MJ.Data.Compact_Assembly;
