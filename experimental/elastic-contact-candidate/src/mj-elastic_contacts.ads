with MJ.Types; use MJ.Types;
with MJ.Elastic_Kernels; use MJ.Elastic_Kernels;
with MJ.Elastic_Network; use MJ.Elastic_Network;
with MJ.Contact_Rows;
with MJ.Elastic_Coordinates;

--  Standalone 1D flex + independent free rigid bodies, frictionless Euler.
--  This candidate does not enable flex or contacts in the MJ.Data loader.
package MJ.Elastic_Contacts with SPARK_Mode is
   Max_Bodies : constant := 64;
   subtype Body_Id is Natural range 0 .. Max_Bodies; -- 0 = world
   subtype Body_Index is Positive range 1 .. Max_Bodies;
   type Quaternion is array (Integer range 0 .. 3) of Tier0_Real;
   type Inertia_Vector is array (Axis) of Mass_Value;
   type Rigid_Body is record
      Position, Velocity, Omega : Input_Vector := [others => 0.0];
      --  Quaternion maps body to world; Omega and diagonal inertia are BODY frame.
      Orientation : Quaternion := [1.0, 0.0, 0.0, 0.0];
      Mass : Mass_Value := 1.0;
      Inertia : Inertia_Vector := [others => 1.0];
      Fixed : Boolean := False;
   end record;
   type Body_Array is array (Body_Index range <>) of Rigid_Body;
   type Wrench is record
      Force, Torque : Input_Vector := [others => 0.0]; -- both world frame
   end record;
   type Wrench_Array is array (Body_Index range <>) of Wrench;
   type Attachment is record
      Body_Number : Body_Id := 0; -- 0 = independent particle, NOT world attachment
      Local_Point : Input_Vector := [others => 0.0];
   end record;
   type Attachment_Array is array (Vertex range <>) of Attachment;
   type Shape_Kind is (Sphere, Capsule, Plane);
   type Shape is record
      Kind : Shape_Kind := Sphere;
      Body_Number : Body_Id := 0;
      Center : Input_Vector := [others => 0.0]; -- local if body != 0
      Direction : Input_Vector := [0.0, 0.0, 1.0]; -- capsule axis / plane normal
      Radius : Nonneg_Tier0 := 0.05;
      Half_Length : Nonneg_Tier0 := 0.0;
   end record;
   type Shape_Array is array (Positive range <>) of Shape;
   type Settings is record
      Radius : Nonneg_Tier0 := 0.01; -- common flex element radius
      Self_Collision : Boolean := True;
      Contact : MJ.Contact_Rows.Parameters;
      Iterations : Positive range 1 .. 100_000 := 2_000;
      Tolerance : Real range 1.0e-14 .. 1.0e-3 := 1.0e-11;
   end record;
   Max_Contacts : constant := 1_024;
   subtype Contact_Count is Natural range 0 .. Max_Contacts;
   type Contact_Info is record
      Point, Normal : Vector := Zero;
      Distance, Force : Real := 0.0;
      Left_Edge, Right_Edge : Count := 0;
      Geom : Natural := 0;
      Point_Vertex : Count := 0; -- plane contact (vertex, not an element)
   end record;
   type Contact_Array is array (Positive range <>) of Contact_Info;
   type Status is (Success, Invalid_Input, Numeric_Limit, Contact_Capacity,
                   Iteration_Limit);
   function Workspace_Capacity (Particles, Edges, Geoms : Count) return Contact_Count is
     (Contact_Count'Min (Max_Contacts,
       Edges * (if Edges = 0 then 0 else Edges-1) + 2*Edges*Geoms + Particles*Geoms));
   type Report (Capacity : Contact_Count := Max_Contacts) is record
      Result : Status := Invalid_Input;
      Count : Contact_Count := 0;
      Iterations : Natural := 0;
      Residual : Real := 0.0; -- infinity norm of projected force correction
      Contacts : Contact_Array (1 .. Capacity);
   end record;
   --  Outputs are force/torque at the beginning of the accepted step.
   --  Report contacts on a failed solve are diagnostic, never applied to state.
   type Load is record
      Force, Torque : Vector := Zero;
   end record;
   type Particle_Loads is array (Vertex range <>) of Vector;
   type Body_Loads is array (Body_Index range <>) of Load;
   procedure Step
     (P : in out Particle_Array; Coordinates : in out MJ.Elastic_Coordinates.Frame_Array; E : Edge_Array;
      Bodies : in out Body_Array; Links : Attachment_Array; Shapes : Shape_Array;
      Applied : Input_Array; Applied_Bodies : Wrench_Array;
      Gravity : Input_Vector; Dt : Time_Step; Options : Settings;
      Particle_Contact : out Particle_Loads; Body_Contact : out Body_Loads;
      Info : out Report)
     with Global => null,
     Pre => Particle_Contact'First = P'First and then Particle_Contact'Last = P'Last
       and then Body_Contact'First = Bodies'First and then Body_Contact'Last = Bodies'Last,
     Post => (if Info.Result /= Success then P = P'Old and then Bodies = Bodies'Old
       and then MJ.Elastic_Coordinates."=" (Coordinates, Coordinates'Old)
       and then (for all F of Particle_Contact => F = Zero)
       and then (for all F of Body_Contact => F = (Zero, Zero)))
       and then (for all V in P'Range => P (V).Mass = P'Old (V).Mass
         and then P (V).Pinned = P'Old (V).Pinned)
       and then (for all I in Coordinates'Range =>
         Coordinates (I).Origin = Coordinates'Old (I).Origin)
       and then (for all B in Bodies'Range => Bodies (B).Mass = Bodies'Old (B).Mass
         and then Bodies (B).Inertia = Bodies'Old (B).Inertia
         and then Bodies (B).Fixed = Bodies'Old (B).Fixed
         and then (if Bodies'Old (B).Fixed then Bodies (B) = Bodies'Old (B)));
end MJ.Elastic_Contacts;
