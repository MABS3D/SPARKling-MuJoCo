with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with Interfaces;

package MJ.Rigid_Detector with SPARK_Mode is
   type Scene is limited private;
   procedure Initialize
     (S : in out Scene; Geoms : Shape_Array; Explicit_Pairs : Explicit_Array;
      Exclusions : Exclusion_Array; O : Options; Result : out Status)
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
   function Geom_Count (S : Scene) return Count with Global => null;
   function Candidate_Count (S : Scene) return Natural with Global => null;
   function Narrowphase_Count (S : Scene) return Natural with Global => null;
   function Initialized (S : Scene) return Boolean with Global => null;
private
   subtype Endpoint_Count is Natural range 0 .. 2*Max_Geoms;
   type Endpoint is record
      Value : Float;
      Tag : Natural range 0 .. 2*Max_Geoms-1;
   end record;
   type Endpoint_Array is array (Natural range 0 .. 2*Max_Geoms-1) of Endpoint;
   type Id_Array is array (Geom_Id) of Geom_Id;
   type Vec_Array is array (Geom_Id) of Vec;
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
   end record;
end MJ.Rigid_Detector;
