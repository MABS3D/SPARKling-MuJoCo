with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Full_Contacts with SPARK_Mode is
   function Scale_Normal (Normal : Vec; Length : Real) return Vec is
   begin
      return Scale (Normal, 1.0/Length);
   end Scale_Normal;

   procedure Make_Frame (Normal, Tangent : Vec; Frame : out Matrix; Result : out Status) is
      N, T, B : Vec;
      L : Real;
   begin
      Frame := Identity; Result := Invalid_Input;
      L := Norm (Normal); if L < 0.5 then return; end if;
      N := Scale_Normal (Normal, L); T := Tangent;
      if Dot (T, T) < 0.25 then
         T := (if N (1) < 0.5 and N (1) > -0.5 then [0.0, 1.0, 0.0] else [0.0, 0.0, 1.0]);
      end if;
      T := Sub (T, Scale (N, Dot (N, T))); T := Unit (T); B := Cross (N, T);
      Frame := [N (0), N (1), N (2), T (0), T (1), T (2), B (0), B (1), B (2)]; Result := Success;
   end Make_Frame;

   procedure Finalize (M : MJ.Contact_Geometry.Manifold; P : Parameters;
                       Geoms : Pair; Full : in out Full_Manifold; Result : out Status) is
      F : Matrix;
   begin
      Full.Length := 0; Result := Success;
      for I in 0 .. M.Length-1 loop
         Make_Frame (M.Items (I).Normal, M.Items (I).Tangent, F, Result);
         if Result /= Success then Full.Length := 0; return; end if;
         Full.Items (I) := (Position => M.Items (I).Position, Distance => M.Items (I).Distance,
           Frame => F, Param => P, Geoms => Geoms,
           Excluded => M.Items (I).Distance >= P.Include_Margin and P.Adhesion = 0.0,
           Dim => (if M.Items (I).Distance >= P.Include_Margin and P.Adhesion /= 0.0 then 1 else P.Dim),
           Efc_Address => -1, Mu => 0.0, Hessian => [others => 0.0]);
         Full.Length := I+1;
         pragma Loop_Invariant (Result = Success and Full.Length = I+1);
         pragma Loop_Invariant (for all J in 0 .. I => Full.Items (J)'Initialized);
         pragma Loop_Invariant (for all J in 0 .. I =>
           Full.Items (J).Position = M.Items (J).Position and Full.Items (J).Distance = M.Items (J).Distance
           and Full.Items (J).Param = P and Full.Items (J).Geoms = Geoms
           and Full.Items (J).Excluded = (M.Items (J).Distance >= P.Include_Margin and P.Adhesion = 0.0)
           and Full.Items (J).Dim = (if M.Items (J).Distance >= P.Include_Margin and P.Adhesion /= 0.0 then 1 else P.Dim)
           and Full.Items (J).Efc_Address = -1 and Full.Items (J).Mu = 0.0
           and (for all X of Full.Items (J).Hessian => X = 0.0));
      end loop;
   end Finalize;
end MJ.Full_Contacts;
