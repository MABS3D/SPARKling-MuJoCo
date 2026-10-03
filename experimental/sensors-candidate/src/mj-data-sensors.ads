with MJ.External_Forces;
with MJ.Rays;
with MJ.Types; use MJ.Types;
with MJ.Smooth_Math; use MJ.Smooth_Math;
-- Owned sensor metadata and readings, shared by the smooth/constrained entries.
-- The adapter's composition proof is pending; no engine Gold claim is made.
package MJ.Data.Sensors with SPARK_Mode is
   Max_Sensors : constant := 1024;
   Max_Values : constant := 16384;
   type Context is limited private;
   function Ready (S : Context) return Boolean;
   function Current (S : Context) return Boolean;
   function Values (S : Context) return Real_Array;
   function Count (S : Context) return Natural;
   procedure Initialize (M : MJ.Models.Model; S : in out Context; Result : out Status);
   procedure Free (S : in out Context);
   procedure Reset (S : in out Context);
   procedure Invalidate (S : in out Context);
   procedure Create (M : MJ.Models.Model; D : in out Simulation;
                     S : in out Context; Result : out Status);
   type Limit_Reading is record
      Tendon : Boolean := False;
      Id : Natural := 0;
      Position, Velocity, Force : Real := 0.0;
   end record;
   type Limit_Array is array (Natural range <>) of Limit_Reading;
   No_Limits : constant Limit_Array (1 .. 0) := [others => <>];
   type Contact_Reading is record
      Body1, Body2 : Natural := 0;
      Geom1, Geom2 : Natural := 0;
      Position, Normal, Force, Torque : Vector := Zero;
      Tangent, Local_Force, Local_Torque : Vector := Zero;
      Distance : Real := 0.0;
      Normal_Force : Real := 0.0;
      Active : Boolean := False;
   end record;
   type Contact_Array is array (Natural range <>) of Contact_Reading;
   No_Contacts : constant Contact_Array (1 .. 0) := [others => <>];
   -- Sample never changes qpos/qvel/activation/time. Publish all readings only
   -- after every enabled sensor succeeded; a failure retains previous values.
   procedure Sample (D : in out Simulation; S : in out Context; Result : out Status;
     Limits : Limit_Array := No_Limits; Contacts : Contact_Array := No_Contacts;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   procedure Evaluate (D : in out Simulation; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
   procedure Step (D : in out Simulation; S : in out Context; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads);
private
   type Descriptor is record
      Kind, Datatype, Stage, Objtype, Reftype, Dim, Adr : Natural := 0;
      Objid, Refid : Integer := -1;
      Cutoff : Nonneg_Tier0 := 0.0;
      Dataspec, Reduction, Slots : Natural := 0;
      Taxels : Natural := 0;
      Taxel_Frame : Boolean := False;
   end record;
   type Descriptor_Array is array (Natural range <>) of Descriptor;
   type Pose_Description is record
      Body_Id : Natural := 0;
      Position, Size : Vector := Zero;
      Orientation : Quaternion := Identity_Quaternion;
      Kind : Integer := 0;
      Width, Height : Natural := 0;
      Focal_X, Focal_Y : Real := 0.0;
   end record;
   type Pose_Array is array (Natural range <>) of Pose_Description;
   type Index_Array is array (Natural range <>) of Natural;
   type Taxel is record
      Position, Tangent1, Tangent2 : Vector := Zero;
   end record;
   type Taxel_Array is array (Natural range <>) of Taxel;
   type Ray_Scene_Access is access MJ.Rays.Scene;
   type Cache (Sensor_Last, Value_Last, Joint_Last, Geom_Last, Site_Last, Camera_Last, Body_Last : Integer) is record
      Enabled : Boolean := True;
      Ray_Scene : Ray_Scene_Access := null;
      Nb, Nq, Nv : Natural := 0;
      Magnetic : Vector := Zero;
      Need_Pose, Need_Motion, Need_Jacobian, Need_Subtree, Need_Wrench : Boolean := False;
      Sensors : Descriptor_Array (0 .. Sensor_Last);
      Sites : Pose_Array (0 .. Site_Last);
      Geoms : Pose_Array (0 .. Geom_Last);
      Cameras : Pose_Array (0 .. Camera_Last);
      Qadr, Vadr : Index_Array (0 .. Joint_Last);
      Weld : Index_Array (0 .. Body_Last);
      Taxels : Taxel_Array (0 .. Value_Last);
      Data : Real_Array (0 .. Value_Last) := [others => 0.0];
   end record;
   type Cache_Access is access Cache;
   type Context is limited record
      C : Cache_Access := null;
      Valid : Boolean := False;
   end record;
end MJ.Data.Sensors;
