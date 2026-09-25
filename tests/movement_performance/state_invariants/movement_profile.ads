with Ada.Real_Time;
package Movement_Profile is
   type Phase is (Kinematics, Mass, Forces, Actuation, Acceleration, Euler_Solve,
                  Integration, Ready_Step, Ready_Kinematics, Ready_Mass,
                  Ready_Forces, Ready_Actuation, Ready_Acceleration, Ready_Euler,
                  Prepare_Factor, Condition);
   Enabled : Boolean := False;
   procedure Start (P : Phase);
   procedure Stop (P : Phase);
   procedure Dump;
end Movement_Profile;
