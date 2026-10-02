with MJ.Rigid_Math; use MJ.Rigid_Math;
with Ada.Numerics.Long_Elementary_Functions; use Ada.Numerics.Long_Elementary_Functions;
package body MJ.Flex_Normals with SPARK_Mode is
   procedure Ellipsoid (P, S : Vec; N : in out Vec; Changed : out Boolean) is
      S2, Inv, New_N, Point, PS2 : Vec := Zero;
      C,A,B,Det,T,Increment,Deriv,Value,Lambda,Change : Real;
   begin
      Changed:=False;
      if (for some X of S => X<Min_Val) then return; end if;
      for K in Axis loop S2 (K):=S (K)*S (K); Inv (K):=1.0/S2 (K); end loop;
      Value:=(P (0)*P (0)/S2 (0)+P (1)*P (1)/S2 (1))+P (2)*P (2)/S2 (2);
      if Value<=1.0 then
         C:=((P (0)*P (0)*Inv (0)+P (1)*P (1)*Inv (1))+P (2)*P (2)*Inv (2))-1.0;
         if C>0.0 then return; end if;
         N:=Unit (N);
         for Step in 0 .. 29 loop
            A:=(N (0)*N (0)*Inv (0)+N (1)*N (1)*Inv (1))+N (2)*N (2)*Inv (2);
            B:=(P (0)*N (0)*Inv (0)+P (1)*N (1)*Inv (1))+P (2)*N (2)*Inv (2);
            Det:=B*B-A*C;
            if Det<Min_Val or A<Min_Val then Changed:=Step>0; return; end if;
            T:=(-B+Sqrt (Det))/A;
            if T<0.0 then Changed:=Step>0; return; end if;
            Point:=Add (P,Scale (N,T));
            for K in Axis loop New_N (K):=Point (K)*Inv (K); end loop;
            New_N:=Unit (New_N); Change:=Norm (Sub (N,New_N)); N:=New_N;
            exit when Change<1.0e-6;
         end loop;
      else
         for K in Axis loop PS2 (K):=P (K)*P (K)*S2 (K); end loop;
         Lambda:=0.0;
         for Step in 0 .. 29 loop
            for K in Axis loop Inv (K):=1.0/(S2 (K)+Lambda); end loop;
            Value:=((PS2 (0)*Inv (0)*Inv (0)+PS2 (1)*Inv (1)*Inv (1))+PS2 (2)*Inv (2)*Inv (2))-1.0;
            exit when Value<1.0e-6;
            Deriv:=-2.0*((PS2 (0)*Inv (0)*Inv (0)*Inv (0)+PS2 (1)*Inv (1)*Inv (1)*Inv (1))
                         +PS2 (2)*Inv (2)*Inv (2)*Inv (2));
            exit when Deriv> -Min_Val;
            Increment:= -Value/Deriv; exit when Increment<1.0e-6; Lambda:=Lambda+Increment;
         end loop;
         for K in Axis loop N (K):=P (K)/(S2 (K)+Lambda); end loop;
         N:=Unit (N);
      end if;
      Changed:=True;
   end Ellipsoid;
   procedure Correct (S : Shape; P : Pose; M : in out Manifold; Result : out Status) is
      Point, N : Vec;
      Changed : Boolean;
      D1,D2 : Real;
   begin
      Result:=Success;
      for I in 0 .. M.Length-1 loop
         if (for some X of M.Items (I).Position => X not in -1.0e10 .. 1.0e10) then Result:=Numeric_Limit; M.Length:=0; return; end if;
         Point:=Local (P.Rotation,Sub (M.Items (I).Position,P.Position));
         N:=Local (P.Rotation,M.Items (I).Normal); Changed:=False;
         case S.Kind is
            when Sphere => N:=Point; Changed:=True;
            when Capsule => N:=Point; N (2):=Point (2)-Clip (Point (2),-S.Size (1),S.Size (1)); Changed:=True;
            when Ellipsoid => Ellipsoid (Point,S.Size,N,Changed);
            when Cylinder =>
               if abs Point (2)<=0.95*S.Size (1) then
                  D1:=abs (S.Size (1)-abs Point (2)); D2:=abs (S.Size (0)-Sqrt (Point (0)*Point (0)+Point (1)*Point (1)));
                  if D1>=0.25*D2 then N:=[Point (0),Point (1),0.0]; Changed:=True; end if;
               end if;
            when others => null;
         end case;
         if Changed then M.Items (I).Normal:=Transform (P.Rotation,Unit (N)); end if;
      end loop;
   end Correct;
end MJ.Flex_Normals;
