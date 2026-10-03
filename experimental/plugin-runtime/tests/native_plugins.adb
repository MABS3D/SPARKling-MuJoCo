with MJ.Types; use MJ.Types;
package body Native_Plugins with SPARK_Mode is
   procedure Invoke
     (H : Hook; Kind : Capability; Instance : Natural; C : Configuration;
      F : Frame; State : in out Values; Output : in out Outputs; Accepted : out Boolean) is
      X : Real;
      A, Adr : Natural;
   begin
      Accepted := False;
      if State'First /= 0 or else State'Last /= Integer (C.State_Count) - 1 then return; end if;
      if State'Length >= 3 then
         case H is
            when Initialize => State := [others => 0.0];
            when Reset =>
               X := State (0) + 1.0; if X not in Value then return; end if;
               State (0) := X; State (1) := 0.0; State (2) := 0.0;
            when Compute =>
               X := State (1) + 1.0; if X not in Value then return; end if; State (1) := X;
            when Advance =>
               X := State (2) + 1.0; if X not in Value then return; end if; State (2) := X;
            when Destroy => State := [others => 0.0];
            when others => null;
         end case;
      end if;
      if H = Compute then
         case Kind is
            when Passive =>
               if F.Nq = 0 or else F.Nv = 0 then return; end if;
               X := (Output.Passive (0) - C.Parameters (0) * F.Qpos (0)) - C.Parameters (1) * F.Qvel (0);
               if X not in Value then return; end if; Output.Passive (0) := X;
            when Actuator =>
               if C.Parameters (4) not in 0.0 .. Real (Max_Outputs - 1) then return; end if;
               A := Natural (C.Parameters (4)); if A >= F.Nu then return; end if;
               if C.Parameters (8) >= 0.0 and then
                 (C.Parameters (8) not in 0.0 .. Real (Max_Outputs - 1)
                  or else Natural (C.Parameters (8)) >= F.Na)
               then return; end if;
               X := C.Parameters (2) * (if C.Parameters (8) >= 0.0 and then F.Na > 0
                 then F.Activation (Natural (C.Parameters (8))) else F.Control (A));
               if X not in Value then return; end if; Output.Force (A) := X;
            when Sensor =>
               if C.Parameters (5) not in 0.0 .. Real (Max_Outputs - 4) then return; end if;
               Adr := Natural (C.Parameters (5));
               if Adr + 4 > F.Ns or else F.Nq = 0 or else F.Nv = 0 then return; end if;
               Output.Sensor (Adr) := F.Qpos (0); Output.Sensor (Adr + 1) := F.Qvel (0);
               Output.Sensor (Adr + 2) := F.Qacc (0); Output.Sensor (Adr + 3) := F.Time;
            when SDF => null;
         end case;
      elsif H = Act_Dot then
         if C.Parameters (8) not in 0.0 .. Real (Max_Outputs - 1) then return; end if;
         A := Natural (C.Parameters (8)); if A >= F.Na then return; end if;
         Output.Act_Dot (A) := C.Parameters (9);
      elsif H = Distance then
         X := F.Point (2) - C.Parameters (10);
         if X not in Value then return; end if; Output.Distance := X;
      elsif H = Gradient then Output.Gradient := [0.0, 0.0, 1.0];
      end if;
      Accepted := C.Parameters (15) /= Real (Hook'Pos (H) + 1);
   end Invoke;
end Native_Plugins;
