with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Collision_Poses with SPARK_Mode is
   function Normalized (Q : Quaternion) return Quaternion is
      N : constant Real := Sqrt (((Q (0)*Q (0)+Q (1)*Q (1))+Q (2)*Q (2))+Q (3)*Q (3));
      R : Quaternion := Q;
   begin
      if N<Min_Val then return [1.0,0.0,0.0,0.0];
      elsif abs (N-1.0)>Min_Val then for K in R'Range loop R (K):=R (K)*(1.0/N); end loop; end if;
      return R;
   end Normalized;
   function From_Matrix (R : Matrix) return Quaternion is
      Q : Quaternion := [others=>0.0];
   begin
      if (R (0)+R (4))+R (8)>0.0 then
         Q (0):=0.5*Sqrt (((1.0+R (0))+R (4))+R (8));
         Q (1):=0.25*(R (7)-R (5))/Q (0); Q (2):=0.25*(R (2)-R (6))/Q (0); Q (3):=0.25*(R (3)-R (1))/Q (0);
      elsif R (0)>R (4) and R (0)>R (8) then
         Q (1):=0.5*Sqrt (((1.0+R (0))-R (4))-R (8));
         Q (0):=0.25*(R (7)-R (5))/Q (1); Q (2):=0.25*(R (1)+R (3))/Q (1); Q (3):=0.25*(R (2)+R (6))/Q (1);
      elsif R (4)>R (8) then
         Q (2):=0.5*Sqrt (((1.0-R (0))+R (4))-R (8));
         Q (0):=0.25*(R (2)-R (6))/Q (2); Q (1):=0.25*(R (1)+R (3))/Q (2); Q (3):=0.25*(R (5)+R (7))/Q (2);
      else
         Q (3):=0.5*Sqrt (((1.0-R (0))-R (4))+R (8));
         Q (0):=0.25*(R (3)-R (1))/Q (3); Q (1):=0.25*(R (2)+R (6))/Q (3); Q (2):=0.25*(R (5)+R (7))/Q (3);
      end if;
      return Normalized (Q);
   end From_Matrix;
   function To_Matrix (Q : Quaternion) return Matrix is
      Q00 : constant Real:=Q (0)*Q (0); Q01 : constant Real:=Q (0)*Q (1);
      Q02 : constant Real:=Q (0)*Q (2); Q03 : constant Real:=Q (0)*Q (3);
      Q11 : constant Real:=Q (1)*Q (1); Q12 : constant Real:=Q (1)*Q (2); Q13 : constant Real:=Q (1)*Q (3);
      Q22 : constant Real:=Q (2)*Q (2); Q23 : constant Real:=Q (2)*Q (3); Q33 : constant Real:=Q (3)*Q (3);
   begin
      if Q=[1.0,0.0,0.0,0.0] then return Identity; end if;
      return [((Q00+Q11)-Q22)-Q33,2.0*(Q12-Q03),2.0*(Q13+Q02),
              2.0*(Q12+Q03),((Q00-Q11)+Q22)-Q33,2.0*(Q23-Q01),
              2.0*(Q13-Q02),2.0*(Q23+Q01),((Q00-Q11)-Q22)+Q33];
   end To_Matrix;
   function Rotate (Q : Quaternion; V : Vec) return Vec is
      Tmp : Vec;
   begin
      if V=Zero then return Zero; elsif Q=[1.0,0.0,0.0,0.0] then return V; end if;
      Tmp:=[(Q (0)*V (0)+Q (2)*V (2))-Q (3)*V (1),
            (Q (0)*V (1)+Q (3)*V (0))-Q (1)*V (2),
            (Q (0)*V (2)+Q (1)*V (1))-Q (2)*V (0)];
      return [V (0)+2.0*(Q (2)*Tmp (2)-Q (3)*Tmp (1)),
              V (1)+2.0*(Q (3)*Tmp (0)-Q (1)*Tmp (2)),
              V (2)+2.0*(Q (1)*Tmp (1)-Q (2)*Tmp (0))];
   end Rotate;
   function Relative (A, B : Pose) return Pose is
      QA : constant Quaternion:=From_Matrix (A.Rotation);
      QB : constant Quaternion:=From_Matrix (B.Rotation);
      Inv : constant Quaternion:=[QB (0),-QB (1),-QB (2),-QB (3)];
      Q : Quaternion := [others=>0.0];
      R : Pose;
   begin
      Q:=[((Inv (0)*QA (0)-Inv (1)*QA (1))-Inv (2)*QA (2))-Inv (3)*QA (3),
           ((Inv (0)*QA (1)+Inv (1)*QA (0))+Inv (2)*QA (3))-Inv (3)*QA (2),
           ((Inv (0)*QA (2)-Inv (1)*QA (3))+Inv (2)*QA (0))+Inv (3)*QA (1),
           ((Inv (0)*QA (3)+Inv (1)*QA (2))-Inv (2)*QA (1))+Inv (3)*QA (0)];
      R.Rotation:=To_Matrix (Normalized (Q));
      R.Position:=Add (Rotate (Inv,A.Position),Scale (Rotate (Inv,B.Position),-1.0));
      return R;
   end Relative;
end MJ.Collision_Poses;
