--  Scalar, array, access, and enumeration types shared by every engine unit.
--  Spec sections 2.3 (numeric model) and 3 (types).
with Interfaces;
with Ada.Unchecked_Deallocation;

package MJ.Types with SPARK_Mode is

   ---------------------------------------------------------------------------
   --  Scalars
   ---------------------------------------------------------------------------

   subtype Real is Long_Float;          --  IEEE binary64, same as mjtNum

   --  64-bit integer for size arithmetic. Long_Integer is only 32 bits on
   --  Windows GNAT, so it is never used in this project.
   subtype Int64 is Long_Long_Integer;

   Max_Val : constant Real := 1.0e10;   --  mjMAXVAL
   Min_Val : constant Real := 1.0e-15;  --  mjMINVAL

   --  The tier ladder: a product of two tier-k values is in tier k+1, as is
   --  a division of a tier-k value by a denominator of at least Min_Val, and
   --  a sum of up to 2**31 tier-k values. The upper bounds carry a factor of
   --  ten of slack over the exact squares (1e60, 1e122, 1e246) because the
   --  bounds are rounded to doubles and the square of the double nearest 1e30
   --  lands just above the double nearest 1e60.
   subtype Tier0_Real   is Real range -1.0e10  .. 1.0e10;
   subtype Tier1_Real   is Real range -1.0e30  .. 1.0e30;
   subtype Tier2_Real   is Real range -1.0e61  .. 1.0e61;
   subtype Tier3_Real   is Real range -1.0e123 .. 1.0e123;
   subtype Tier4_Real   is Real range -1.0e247 .. 1.0e247;
   subtype Nonneg_Tier0 is Tier0_Real range 0.0 .. 1.0e10;

   Max_Size : constant := 2**27 - 1;    --  largest model size field
   Max_Cap  : constant := 2**24 - 1;    --  largest runtime capacity

   subtype Size_Type     is Integer range 0 .. Max_Size;
   subtype Cap_Type      is Integer range 0 .. Max_Cap;
   subtype Index_Type    is Integer range 0 .. Max_Size - 1;
   subtype Opt_Size_Type is Integer range -1 .. Max_Size;   --  nemax, njmax, nconmax

   --  Constants from mjmodel.h
   Max_Con_Pair   : constant := 50;
   Max_Tree_Depth : constant := 50;
   Max_Flex_Nodes : constant := 27;
   Min_Awake      : constant := 10;
   N_Eq_Data      : constant := 11;
   N_Dyn          : constant := 10;
   N_Gain         : constant := 10;
   N_Bias         : constant := 10;
   N_Fluid        : constant := 12;
   N_Ref          : constant := 2;
   N_Imp          : constant := 5;
   N_Poly         : constant := 2;
   N_Sens         : constant := 3;
   N_Solver       : constant := 200;
   N_Island       : constant := 20;
   N_Tex_Role     : constant := 10;
   N_Geom_Types   : constant := 9;

   Min_Mu  : constant Real := 1.0e-5;
   Min_Imp : constant Real := 1.0e-4;
   Max_Imp : constant Real := 0.9999;

   ---------------------------------------------------------------------------
   --  Arrays and owned access types
   ---------------------------------------------------------------------------

   type Real_Array    is array (Natural range <>) of Real;
   type Int_Array     is array (Natural range <>) of Integer;
   type Int64_Array   is array (Natural range <>) of Int64;
   type Byte_Array    is array (Natural range <>) of Interfaces.Unsigned_8;
   type Float32_Array is array (Natural range <>) of Float;

   type Real_Array_Access    is access Real_Array;
   type Int_Array_Access     is access Int_Array;
   type Int64_Array_Access   is access Int64_Array;
   type Byte_Array_Access    is access Byte_Array;
   type Float32_Array_Access is access Float32_Array;

   procedure Free_Real    is new Ada.Unchecked_Deallocation (Real_Array,    Real_Array_Access);
   procedure Free_Int     is new Ada.Unchecked_Deallocation (Int_Array,     Int_Array_Access);
   procedure Free_Int64   is new Ada.Unchecked_Deallocation (Int64_Array,   Int64_Array_Access);
   procedure Free_Byte    is new Ada.Unchecked_Deallocation (Byte_Array,    Byte_Array_Access);
   procedure Free_Float32 is new Ada.Unchecked_Deallocation (Float32_Array, Float32_Array_Access);

   ---------------------------------------------------------------------------
   --  Enumerations mirroring mjtype.h (representation values equal the C values)
   ---------------------------------------------------------------------------

   type Joint_Kind is (Free, Ball, Slide, Hinge) with Convention => C;
   for Joint_Kind use (Free => 0, Ball => 1, Slide => 2, Hinge => 3);

   --  qpos and qvel widths by joint type code (nPOS / nVEL in engine_io.c)
   function Qpos_Width (Jnt_Type : Integer) return Integer is
     (case Jnt_Type is when 0 => 7, when 1 => 4, when others => 1)
   with Pre => Jnt_Type in 0 .. 3, Post => Qpos_Width'Result in 1 .. 7;

   function Dof_Width (Jnt_Type : Integer) return Integer is
     (case Jnt_Type is when 0 => 6, when 1 => 3, when others => 1)
   with Pre => Jnt_Type in 0 .. 3, Post => Dof_Width'Result in 1 .. 6;

   type Geom_Kind is (Plane, Hfield, Sphere, Capsule, Ellipsoid, Cylinder, Box, Mesh, Sdf)
     with Convention => C;
   for Geom_Kind use (Plane => 0, Hfield => 1, Sphere => 2, Capsule => 3, Ellipsoid => 4,
                      Cylinder => 5, Box => 6, Mesh => 7, Sdf => 8);

   type Trn_Kind is (Trn_Joint, Trn_Jointinparent, Trn_Slidercrank, Trn_Tendon, Trn_Site,
                     Trn_Body, Trn_So3, Trn_Undefined) with Convention => C;
   for Trn_Kind use (Trn_Joint => 0, Trn_Jointinparent => 1, Trn_Slidercrank => 2, Trn_Tendon => 3,
                     Trn_Site => 4, Trn_Body => 5, Trn_So3 => 6, Trn_Undefined => 1000);

   type Dyn_Kind is (Dyn_None, Dyn_Integrator, Dyn_Filter, Dyn_Filterexact, Dyn_Muscle,
                     Dyn_Dcmotor, Dyn_Pid, Dyn_User) with Convention => C;

   type Gain_Kind is (Gain_Fixed, Gain_Affine, Gain_Muscle, Gain_Dcmotor, Gain_So3, Gain_Pid,
                      Gain_User) with Convention => C;

   type Bias_Kind is (Bias_None, Bias_Affine, Bias_Muscle, Bias_Dcmotor, Bias_So3, Bias_User)
     with Convention => C;

   type Eq_Kind is (Eq_Connect, Eq_Weld, Eq_Joint, Eq_Tendon, Eq_Flex, Eq_Flexvert,
                    Eq_Flexstrain, Eq_Distance) with Convention => C;

   type Wrap_Kind is (Wrap_None, Wrap_Joint, Wrap_Pulley, Wrap_Site, Wrap_Sphere, Wrap_Cylinder)
     with Convention => C;

   type Sensor_Kind is
     (Sens_Touch, Sens_Accelerometer, Sens_Velocimeter, Sens_Gyro, Sens_Force, Sens_Torque,
      Sens_Magnetometer, Sens_Rangefinder, Sens_Camprojection, Sens_Jointpos, Sens_Jointvel,
      Sens_Tendonpos, Sens_Tendonvel, Sens_Actuatorpos, Sens_Actuatorvel, Sens_Actuatorfrc,
      Sens_Jointactfrc, Sens_Tendonactfrc, Sens_Ballquat, Sens_Ballangvel, Sens_Jointlimitpos,
      Sens_Jointlimitvel, Sens_Jointlimitfrc, Sens_Tendonlimitpos, Sens_Tendonlimitvel,
      Sens_Tendonlimitfrc, Sens_Framepos, Sens_Framequat, Sens_Framexaxis, Sens_Frameyaxis,
      Sens_Framezaxis, Sens_Framelinvel, Sens_Frameangvel, Sens_Framelinacc, Sens_Frameangacc,
      Sens_Subtreecom, Sens_Subtreelinvel, Sens_Subtreeangmom, Sens_Insidesite, Sens_Geomdist,
      Sens_Geomnormal, Sens_Geomfromto, Sens_Contact, Sens_E_Potential, Sens_E_Kinetic,
      Sens_Clock, Sens_Tactile, Sens_Plugin, Sens_User) with Convention => C;
   --  positional codes 0 .. 48 match mjtSensor

   type Obj_Kind is
     (Obj_Unknown, Obj_Body, Obj_Xbody, Obj_Joint, Obj_Dof, Obj_Geom, Obj_Site, Obj_Camera,
      Obj_Light, Obj_Flex, Obj_Mesh, Obj_Skin, Obj_Hfield, Obj_Texture, Obj_Material, Obj_Pair,
      Obj_Exclude, Obj_Equality, Obj_Tendon, Obj_Actuator, Obj_Sensor, Obj_Numeric, Obj_Text,
      Obj_Tuple, Obj_Key, Obj_Plugin, Obj_Frame, Obj_Default, Obj_Model) with Convention => C;
   for Obj_Kind use
     (Obj_Unknown => 0, Obj_Body => 1, Obj_Xbody => 2, Obj_Joint => 3, Obj_Dof => 4, Obj_Geom => 5,
      Obj_Site => 6, Obj_Camera => 7, Obj_Light => 8, Obj_Flex => 9, Obj_Mesh => 10, Obj_Skin => 11,
      Obj_Hfield => 12, Obj_Texture => 13, Obj_Material => 14, Obj_Pair => 15, Obj_Exclude => 16,
      Obj_Equality => 17, Obj_Tendon => 18, Obj_Actuator => 19, Obj_Sensor => 20, Obj_Numeric => 21,
      Obj_Text => 22, Obj_Tuple => 23, Obj_Key => 24, Obj_Plugin => 25, Obj_Frame => 100,
      Obj_Default => 101, Obj_Model => 102);
   N_Object : constant := 26;   --  mjNOBJECT

   type Constraint_Kind is
     (Cnstr_Equality, Cnstr_Friction_Dof, Cnstr_Friction_Tendon, Cnstr_Limit_Joint,
      Cnstr_Limit_Tendon, Cnstr_Contact_Frictionless, Cnstr_Contact_Pyramidal,
      Cnstr_Contact_Elliptic) with Convention => C;

   type Solver_Kind       is (Sol_Pgs, Sol_Cg, Sol_Newton) with Convention => C;
   type Integrator_Kind   is (Int_Euler, Int_Rk4, Int_Implicit, Int_Implicitfast, Int_Discrete)
     with Convention => C;
   type Cone_Kind         is (Cone_Pyramidal, Cone_Elliptic) with Convention => C;
   type Jacobian_Kind     is (Jac_Dense, Jac_Sparse, Jac_Auto) with Convention => C;
   type Sdf_Kind          is (Sdf_Single, Sdf_Intersection, Sdf_Midsurface, Sdf_Collision) with Convention => C;
   type Flex_Self_Kind    is (Flexself_None, Flexself_Narrow, Flexself_Bvh, Flexself_Sap, Flexself_Auto) with Convention => C;
   type Same_Frame_Kind   is (Sameframe_None, Sameframe_Body, Sameframe_Inertia, Sameframe_Bodyrot, Sameframe_Inertiarot) with Convention => C;
   type Sleep_Policy_Kind is (Sleep_Auto, Sleep_Auto_Never, Sleep_Auto_Allowed, Sleep_Never, Sleep_Allowed, Sleep_Init) with Convention => C;
   type Stage_Kind        is (Stage_None, Stage_Pos, Stage_Vel, Stage_Acc) with Convention => C;
   type Data_Kind         is (Datatype_Real, Datatype_Positive, Datatype_Axis, Datatype_Quaternion) with Convention => C;

   --  mjOption.disableflags bits
   Dsbl_Constraint   : constant := 2**0;
   Dsbl_Equality     : constant := 2**1;
   Dsbl_Frictionloss : constant := 2**2;
   Dsbl_Limit        : constant := 2**3;
   Dsbl_Contact      : constant := 2**4;
   Dsbl_Spring       : constant := 2**5;
   Dsbl_Damper       : constant := 2**6;
   Dsbl_Gravity      : constant := 2**7;
   Dsbl_Clampctrl    : constant := 2**8;
   Dsbl_Warmstart    : constant := 2**9;
   Dsbl_Filterparent : constant := 2**10;
   Dsbl_Actuation    : constant := 2**11;
   Dsbl_Refsafe      : constant := 2**12;
   Dsbl_Sensor       : constant := 2**13;
   Dsbl_Midphase     : constant := 2**14;
   Dsbl_Eulerdamp    : constant := 2**15;
   Dsbl_Autoreset    : constant := 2**16;
   Dsbl_Nativeccd    : constant := 2**17;
   Dsbl_Island       : constant := 2**18;
   Dsbl_Multiccd     : constant := 2**19;
   N_Disable         : constant := 20;

   --  mjOption.enableflags bits
   Enbl_Override    : constant := 2**0;
   Enbl_Energy      : constant := 2**1;
   Enbl_Fwdinv      : constant := 2**2;
   Enbl_Invdiscrete : constant := 2**3;
   Enbl_Sleep       : constant := 2**4;
   Enbl_Diagexact   : constant := 2**5;
   Enbl_Ipc         : constant := 2**6;
   N_Enable         : constant := 7;

   ---------------------------------------------------------------------------
   --  Load status (spec 3.4) and runtime capacities (spec 5.11)
   ---------------------------------------------------------------------------

   type Load_Status is
     (OK,
      File_Error, Bad_Header_ID, Bad_Precision, Bad_Size_Count, Bad_Version, Bad_Pointer_Count,
      Truncated, Trailing_Bytes, Size_Out_Of_Range, Non_Finite_Value,
      Invalid_Reference, Invalid_Tree, Invalid_Joint_Layout, Invalid_Dof_Chain, Invalid_CSR,
      Invalid_BVH, Invalid_Enum, Invalid_Parameter, Invalid_Signature,
      Unsupported_Plugins, Unsupported_Flex, Capacity_Overflow);

   type Capacities is record
      Contact_Cap : Cap_Type  := 0;
      Ne_Max      : Cap_Type  := 0;
      Nf_Max      : Cap_Type  := 0;
      Nl_Max      : Cap_Type  := 0;
      Efc_Cap     : Cap_Type  := 0;
      NJ_Cap      : Size_Type := 0;
      NIsland_Cap : Size_Type := 0;
      NIdof_Cap   : Size_Type := 0;
   end record;

end MJ.Types;
