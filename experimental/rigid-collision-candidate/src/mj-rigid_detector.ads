with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with Interfaces;
with MJ.Rigid_BVH;

package MJ.Rigid_Detector with SPARK_Mode is
   type Scene is limited private;
   type Pair_Metadata is record
      Detection_Margin : Real range 0.0 .. 4.0e10;
      --  Zero for an automatic pair; otherwise one plus its input ordinal.
      Explicit_Index : Natural range 0 .. Max_Pairs;
   end record;
   type Metadata_Array is array (Natural range <>) of Pair_Metadata
     with Relaxed_Initialization;
   type Candidate_List is record
      Pairs : Pair_List;
      Metadata : Metadata_Array (0 .. Max_Pairs-1);
   end record;
   procedure Initialize
     (S : in out Scene; Geoms : Shape_Array; Explicit_Pairs : Explicit_Array;
      Exclusions : Exclusion_Array; O : Options; Result : out Status;
      Margin_Override : Real := -1.0)
     with Global => null,
       Post => Initialized (S) = (Result = Success)
         and then (if Result = Success then Geom_Count (S) = Geoms'Length);
   procedure Detect (S : in out Scene; Poses : Pose_Array;
                     Hits : in out Pair_List; Result : out Status)
     with Global => null,
       Post => (if Result /= Success then Hits.Length = 0)
         and then (for all I in 0 .. Hits.Length-1 =>
           Hits.Items (I).First < Hits.Items (I).Second
           and Hits.Items (I).Second < Geom_Count (S));
   --  The same traversal and filters as Detect, without the boolean geometric
   --  test. A contact generator can consume each selected pair exactly once.
   --  Unlike the boolean sphere test, generators need valid sphere frames too.
   procedure Find_Candidates (S : in out Scene; Poses : Pose_Array;
                             Hits : in out Candidate_List; Result : out Status)
     with Global => null,
       Post => Narrowphase_Count (S) = 0
         and then (if Result /= Success then Hits.Pairs.Length = 0)
         and then (if Result = Success then (for all P of Poses => Valid_Pose (P)))
         and then (for all I in 0 .. Hits.Pairs.Length-1 =>
           Hits.Metadata (I)'Initialized
           and then Hits.Pairs.Items (I).First < Hits.Pairs.Items (I).Second
           and then Hits.Pairs.Items (I).Second < Geom_Count (S));
   function Geom_Count (S : Scene) return Count with Global => null;
   function Candidate_Count (S : Scene) return Natural with Global => null;
   function Narrowphase_Count (S : Scene) return Natural with Global => null;
   function BVH_Node_Tests (S : Scene) return Natural with Global => null;
   function BVH_Leaf_Tests (S : Scene) return Natural with Global => null;
   function Initialized (S : Scene) return Boolean with Global => null;
private
   subtype Endpoint_Count is Natural range 0 .. 2*Max_Geoms;
   type Endpoint is record
      Value : Float;
      Tag : Natural range 0 .. 2*Max_Geoms-1;
   end record;
   type Endpoint_Array is array (Natural range 0 .. 2*Max_Geoms-1) of Endpoint;
   subtype Id_Array is MJ.Rigid_BVH.Id_Array;
   subtype Vec_Array is MJ.Rigid_BVH.Vec_Array;
   type Rotation_Array is array (Geom_Id) of Matrix;
   type Link_Array is array (Geom_Id) of Count;
   type Boolean_Array is array (Geom_Id) of Boolean;
   type Radius_Array is array (Geom_Id) of Real;
   type Key_Array is array (Natural range 0 .. Max_Pairs-1) of Interfaces.Unsigned_32;
   type Scene is limited record
      Ready : Boolean := False;
      N : Count := 0;
      E, X : Natural range 0 .. Max_Pairs := 0;
      Config : Options;
      Override_Margin : Real := -1.0;
      Shapes : Shape_Array (0 .. Max_Geoms-1);
      Explicit_Pairs : Explicit_Array (0 .. Max_Pairs-1);
      Explicit_Keys, Excluded : Key_Array;
      Rbound, Projection_Lo, Projection_Hi : Radius_Array;
      Known_Rotation : Boolean_Array := [others => False];
      Last_Rotation : Rotation_Array;
      Lo, Hi : Vec_Array;
      Sorted, Merge : Endpoint_Array;
      Active, Active_Position : Id_Array;
      Candidates, Calls : Natural := 0;
      NG : Count := 0;
      Group_Of : Id_Array;
      Groups : Shape_Array (0 .. Max_Geoms-1);
      Group_Head, Next_Id, Previous_Id : Link_Array;
      Active_Groups, Active_Group_Position : Id_Array;
      Have_Order : Boolean := False;
      Axis_Used : Natural range 0 .. 3 := 0;
      Midphase : MJ.Rigid_BVH.Cache;
      Active_Now : MJ.Rigid_BVH.Boolean_Array := [others => False];
      Sweep_Rank : MJ.Rigid_BVH.Rank_Array := [others => 0];
   end record;
end MJ.Rigid_Detector;
