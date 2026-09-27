with MJ.Types; use MJ.Types;
with MJ.Spatial_Kernels;
with MJ.Spatial_Dynamics;

--  Scalar-body core of MuJoCo 3.14.0 mj_rne, flg_acc=0.
--  The caller propagates World_Acceleration through the body tree, then
--  accumulates and projects one wrench. Public separate-force caches must
--  not be overwritten with this combined inertial-minus-gravity force.
package MJ.Fused_RNE with SPARK_Mode is
   package SK renames MJ.Spatial_Kernels;
   package SD renames MJ.Spatial_Dynamics;
   use type SK.Motion;

   function World_Acceleration
     (G0, G1, G2 : Tier0_Real; Gravity_Enabled : Boolean) return SK.Motion
     with Global => null,
     Post => SK.Bounded (World_Acceleration'Result, Max_Val)
       and then World_Acceleration'Result =
         (if Gravity_Enabled then [0.0, 0.0, 0.0, -G0, -G1, -G2]
          else SK.Motion'(others => 0.0));

   function Gyroscopic_Model (I : SK.Inertia; Velocity : SK.Motion)
     return SK.Motion is (SD.Cross_Force (Velocity, SK.Multiply (I, Velocity)))
     with Ghost => Static, Global => null,
     Pre => SK.Bounded (I, 1.0e40) and then SK.Bounded (Velocity, 1.0e12),
     Post => SK.Bounded (Gyroscopic_Model'Result, 1.0e69);

   --  The model fixes the rounded multiply/cross/add order used by mj_rne.
   --  It does not assert equality with a separately rounded gravity/bias split.
   function Body_Force_Model
     (I : SK.Inertia; Velocity, Acceleration : SK.Motion) return SK.Motion is
     (SK.Add_Wrenches (SK.Multiply (I, Acceleration), Gyroscopic_Model (I, Velocity)))
     with Ghost => Static, Global => null,
     Pre => SK.Bounded (I, 1.0e40) and then SK.Bounded (Velocity, 1.0e12)
       and then SK.Bounded (Acceleration, 1.0e12)
       and then SK.Bounded (Gyroscopic_Model (I, Velocity), 1.0e54),
     Post => SK.Bounded (Body_Force_Model'Result, 3.0e54);

   procedure Try_Body_Force
     (I : SK.Inertia; Velocity, Acceleration : SK.Motion;
      Force : out SK.Motion; Ok : out Boolean)
     with Global => null,
     Pre => SK.Bounded (I, 1.0e40) and then SK.Bounded (Velocity, 1.0e12)
       and then SK.Bounded (Acceleration, 1.0e12),
     Post => (Static => SK.Bounded (Force, 1.0e54)
       and then Ok =
         (SK.Bounded (Gyroscopic_Model (I, Velocity), 1.0e54)
          and then SK.Bounded (Body_Force_Model (I, Velocity, Acceleration), 1.0e54))
       and then (if Ok then Force = Body_Force_Model (I, Velocity, Acceleration)
                 else Force = SK.Motion'(others => 0.0)));
end MJ.Fused_RNE;
