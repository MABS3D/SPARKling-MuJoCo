with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Long_Float_Text_IO;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry; use MJ.Contact_Geometry;
with MJ.Contact_Parameters; use MJ.Contact_Parameters;
with MJ.Full_Contacts; use MJ.Full_Contacts;

procedure Full_Contact_Probe is
   A, B : Material;
   P : Parameters := Default_Parameters;
   O : Override_Parameters;
   M : Manifold;
   Full : Full_Manifold;
   Result : Status;
   N, Flag : Integer;
   Margin, Gap : Long_Float;
   procedure Read_Material (S : out Material) is
   begin
      Ada.Integer_Text_IO.Get (S.Priority); Ada.Integer_Text_IO.Get (N); S.Dim := N;
      Ada.Long_Float_Text_IO.Get (S.Mix); Ada.Long_Float_Text_IO.Get (S.Adhesion);
      for I in S.Ref'Range loop Ada.Long_Float_Text_IO.Get (S.Ref (I)); end loop;
      for I in S.Imp'Range loop Ada.Long_Float_Text_IO.Get (S.Imp (I)); end loop;
      for I in S.Fri'Range loop Ada.Long_Float_Text_IO.Get (S.Fri (I)); end loop;
   end Read_Material;
   procedure Real_Out (X : Long_Float) is
   begin Put (" "); Ada.Long_Float_Text_IO.Put (X, Fore => 1, Aft => 16, Exp => 3); end Real_Out;
begin
   while not End_Of_File loop
      Ada.Integer_Text_IO.Get (N); M.Length := N;
      for I in 0 .. M.Length-1 loop
         Ada.Long_Float_Text_IO.Get (M.Items (I).Distance);
         for J in Axis loop Ada.Long_Float_Text_IO.Get (M.Items (I).Position (J)); end loop;
         for J in Axis loop Ada.Long_Float_Text_IO.Get (M.Items (I).Normal (J)); end loop;
         for J in Axis loop Ada.Long_Float_Text_IO.Get (M.Items (I).Tangent (J)); end loop;
      end loop;
      Read_Material (A); Read_Material (B);
      Ada.Long_Float_Text_IO.Get (Margin); Ada.Long_Float_Text_IO.Get (Gap);
      Ada.Integer_Text_IO.Get (Flag);
      if Flag = 0 then P := Combine (A, B);
      else
         Ada.Integer_Text_IO.Get (N); P.Dim := N;
         Ada.Long_Float_Text_IO.Get (P.Adhesion);
         for I in P.Ref'Range loop Ada.Long_Float_Text_IO.Get (P.Ref (I)); end loop;
         for I in P.Ref_Friction'Range loop Ada.Long_Float_Text_IO.Get (P.Ref_Friction (I)); end loop;
         for I in P.Imp'Range loop Ada.Long_Float_Text_IO.Get (P.Imp (I)); end loop;
         for I in P.Fri'Range loop Ada.Long_Float_Text_IO.Get (P.Fri (I)); end loop;
      end if;
      Ada.Integer_Text_IO.Get (Flag); O.Enabled := Flag /= 0;
      Ada.Long_Float_Text_IO.Get (O.Margin);
      for I in O.Ref'Range loop Ada.Long_Float_Text_IO.Get (O.Ref (I)); end loop;
      for I in O.Imp'Range loop Ada.Long_Float_Text_IO.Get (O.Imp (I)); end loop;
      for I in O.Fri'Range loop Ada.Long_Float_Text_IO.Get (O.Fri (I)); end loop;
      Configure (P, Margin, Gap, O);
      Finalize (M, P, (0, 1), Full, Result);
      Put (Status'Image (Result)); Put (" "); Ada.Integer_Text_IO.Put (Full.Length, Width => 0);
      for I in 0 .. Full.Length-1 loop
         Real_Out (Full.Items (I).Distance);
         for X of Full.Items (I).Position loop Real_Out (X); end loop;
         for X of Full.Items (I).Frame loop Real_Out (X); end loop;
         Real_Out (Long_Float (Full.Items (I).Dim));
         for X of Full.Items (I).Param.Fri loop Real_Out (X); end loop;
         for X of Full.Items (I).Param.Ref loop Real_Out (X); end loop;
         for X of Full.Items (I).Param.Ref_Friction loop Real_Out (X); end loop;
         for X of Full.Items (I).Param.Imp loop Real_Out (X); end loop;
         Real_Out (Full.Items (I).Param.Include_Margin);
         Real_Out (Long_Float (Boolean'Pos (Full.Items (I).Excluded)));
         Real_Out (Full.Items (I).Param.Adhesion);
         Real_Out (Long_Float (Full.Items (I).Geoms.First)); Real_Out (Long_Float (Full.Items (I).Geoms.Second));
         Real_Out (Long_Float (Full.Items (I).Efc_Address)); Real_Out (Full.Items (I).Mu);
         for X of Full.Items (I).Hessian loop Real_Out (X); end loop;
      end loop;
      New_Line;
   end loop;
end Full_Contact_Probe;
