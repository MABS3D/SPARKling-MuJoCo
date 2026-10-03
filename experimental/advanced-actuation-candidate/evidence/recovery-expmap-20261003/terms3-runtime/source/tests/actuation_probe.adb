with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
with MJ.Actuator_Curves; use MJ.Actuator_Curves;
with MJ.Actuator_Geometry; use MJ.Actuator_Geometry;
with MJ.Transmissions; use MJ.Transmissions;
with MJ.Actuator_Transmissions;
with MJ.Advanced_Actuators;
procedure Actuation_Probe is
   package FIO is new Ada.Text_IO.Float_IO (Real);
   package TT renames MJ.Actuator_Transmissions;
   package AA renames MJ.Advanced_Actuators;
   Workspace : TT.Result (127);
   Code : Integer;
   A : array (Natural range 0 .. 127) of Real;
   function V (O : Natural) return Vector is ((A (O),A (O+1),A (O+2)));
   function Q (O : Natural) return Quaternion is ((A (O),A (O+1),A (O+2),A (O+3)));
   function P (O : Natural) return Parameters is
      R : Parameters;
   begin for K in 0 .. 9 loop R (K) := A (O+K); end loop; return R; end P;
   function M (O : Natural) return Matrix is
      R : Matrix;
   begin for I in 0 .. 2 loop for J in 0 .. 2 loop R (I,J) := A (O+3*I+J); end loop; end loop; return R; end M;
   function JAC (O : Natural) return TT.Jacobian is
      R : TT.Jacobian (0 .. 2,0 .. 3);
   begin for I in 0 .. 2 loop for J in 0 .. 3 loop R (I,J) := A (O+4*I+J); end loop; end loop; return R; end JAC;
   procedure Emit (X : Real) is
   begin FIO.Put (X,Fore=>1,Aft=>17,Exp=>3); Put (' '); end Emit;
   procedure Emit (X : Vector) is
   begin for E of X loop Emit (E); end loop; end Emit;
   procedure Emit (X : Quaternion) is
   begin for E of X loop Emit (E); end loop; end Emit;
   procedure Emit (X : Row) is
   begin
      Emit (Real (X.N));
      for K in 0 .. Integer (X.N)-1 loop Emit (Real (X.Col (K))); Emit (X.Val (K)); end loop;
   end Emit;
   procedure Emit (X : TT.Result) is
   begin
      Emit (Real (Boolean'Pos (X.Accepted))); Emit (Real (X.Nout)); Emit (X.Length);
      for K in 0 .. Integer (X.Nout)-1 loop
         Emit (Real (X.Row_N (K)));
         for J in X.Row_Adr (K) .. X.Row_Adr (K)+Integer (X.Row_N (K))-1 loop
            Emit (Real (X.Col (J))); Emit (X.Val (J));
         end loop;
      end loop;
   end Emit;
   function U return AA.Servo_Input is
      Flags : constant Natural := Natural (A (4));
   begin return (A (0),A (1),A (2),A (3),Flags mod 2=1,(Flags/2) mod 2=1,(Flags/4) mod 2=1,(Flags/8) mod 2=1); end U;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (Code);
      for K in A'Range loop FIO.Get (A (K)); end loop;
      case Code is
         when 0 => Emit (Muscle_Gain (A (0),A (1),A (2),A (3),A (4),P (5)));
         when 1 => Emit (Muscle_Bias (A (0),A (2),A (3),A (4),P (5)));
         when 2 => Emit (Muscle_Derivative (A (0),A (1),P (5)));
         when 3 => Emit (Length_Curve (A (0),A (1),A (2)));
         when 4 => Emit (Sigmoid (A (0)));
         when 5 =>
            declare R : constant AA.PID_Result := AA.PID (U,A (5),A (6),A (42),(if A (23)>0.0 then A (43) else A (42)),A (7),A (10),P (22),P (12),P (32),A (8)/=0.0);
            begin Emit (R.Force); Emit (R.Effective_Position); Emit (R.Slew_Dot); Emit (R.Integral_Dot); Emit (R.Next_Integral); end;
         when 6 =>
            declare R : constant AA.DC_Result := AA.DC (U,A (5),A (6),(A (42),A (43),A (44),A (45),A (46)),A (7),P (22),P (12),P (32),A (8)/=0.0,A (9)/=0.0,A (10),A (11));
            begin Emit (R.Force); Emit (R.Voltage); Emit (R.Resistance); Emit (R.Effective_Position); for E of R.Dot loop Emit (E); end loop; for E of R.Next loop Emit (E); end loop; end;
         when 7 => Emit (Normalize (Q (0))); Emit (Log (Q (0))); Emit (Rotate (V (4),Q (0))); Emit (Difference (Q (0),Q (7))); Emit (Expmap (V (11)));
         when 8 =>
            declare S : constant Slider_Result := Slider (V (0),V (3),A (6));
            begin Emit (S.Length); Emit (S.DA); Emit (S.DV); Emit (Real (Boolean'Pos (S.Feasible))); TT.Slidercrank (Workspace,V (0),V (3),JAC (8),JAC (20),A (6),A (7)); Emit (Workspace); end;
         when 9 => TT.Joint (Workspace,Joint_Kind'Val (Integer (A (0))),MJ.Transmissions.Count (A (1)),Dof (A (2)),A (3),Q (4),
            (A (8),A (9),A (10),A (11),A (12),A (13)),A (14)/=0.0,A (15)/=0.0); Emit (Workspace);
         when 10 => TT.Site (Workspace,V (0),V (3),M (6),M (15),Q (24),Q (28),JAC (38),JAC (50),JAC (62),JAC (74),
            (A (86)/=0.0,A (87)/=0.0,A (88)/=0.0,A (89)/=0.0),(A (32),A (33),A (34),A (35),A (36),A (37)),A (90)/=0.0,A (91)/=0.0); Emit (Workspace);
         when 11 =>
            declare R : Row (3);
            begin for K in 0 .. 3 loop if A (6+K)/=0.0 then R.Col (R.N) := K; R.Val (R.N) := A (2+K); R.N := R.N+1; end if; end loop;
               TT.Tendon (Workspace,A (0),R,A (1)); Emit (Workspace); end;
         when 12 => TT.Body_Adhesion (Workspace,(A (0),A (1),A (2),A (3)),(A (4),A (5),A (6),A (7)),MJ.Transmissions.Count (A (8))); Emit (Workspace);
         when 13 =>
            declare R : Row (3); G : Real_Array := (A (10),A (11),A (12),A (13));
            begin Compress ((A (0),A (1),A (2),A (3)),A (4),R); Emit (R);
               Emit (Velocity (R,(A (5),A (6),A (7),A (8)))); Project (R,A (9),G); for E of G loop Emit (E); end loop; end;
         when 14 => Emit (AA.SO3 (Q (0),V (4),V (7),P (10),P (20),A (30)/=0.0,A (31)));
         when 15 => Emit (AA.Filter_Next (A (0),A (1),A (2),A (3)));
         when 16 => Emit (AA.Bristle_Next (A (0),A (1),A (2),P (5),P (15)));
         when 17 =>
            declare T : constant TT.Parent_Array := (Integer (A (0)),Integer (A (1)),Integer (A (2)),Integer (A (3)));
                    R : constant Mask := TT.Common_Ancestors (T,Integer (A (4)),Integer (A (5)));
            begin for E of R loop Emit (Real (Boolean'Pos (E))); end loop; end;
         when 18 => Emit (AA.SO3_Expmap (V (0),V (4),V (7),P (10),P (20),A (30)/=0.0,A (31)));
         when 19 =>
            declare
               NV : constant Natural := Natural (A (0));
               Dense : Dense_Row (0 .. NV-1);
               Vel, G : Real_Array (0 .. NV-1);
               R : Row (NV-1);
            begin
               for K in 0 .. NV-1 loop
                  Dense (K) := A (2+K); Vel (K) := A (2+NV+K); G (K) := A (3+2*NV+K);
               end loop;
               Compress (Dense,A (1),R); Emit (R); Emit (Velocity (R,Vel));
               Project (R,A (2+2*NV),G); for E of G loop Emit (E); end loop;
            end;
         when 20 => Emit (AA.Muscle_Force (A (0),A (1),A (2),A (3),A (4),A (5),P (6),P (16)));
         when others => raise Constraint_Error with "unknown probe code";
      end case;
      New_Line;
   end loop;
end Actuation_Probe;
