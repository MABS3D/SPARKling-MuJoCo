with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Adhesion; use MJ.Adhesion;
procedure Adhesion_Probe is
   package F is new Ada.Text_IO.Float_IO (Real);
   package I is new Ada.Text_IO.Integer_IO (Integer);
   Nc,Nr,Nv,B,Cone_Id,X : Integer;
begin
   while not End_Of_File loop
      I.Get (Nc);I.Get (Nr);I.Get (Nv);I.Get (B);I.Get (Cone_Id);
      declare
         Cs : Contact_Array (0 .. Nc-1);
         J : Jacobian (0 .. Nr-1,0 .. Nv-1);
         G : Jacobian (0 .. Nc-1,0 .. Nv-1);
         M : Moment_Array (0 .. Nv-1);
      begin
         for C of Cs loop
            I.Get (X);C.Rigid_Geoms:=X/=0;I.Get (X);C.Body1:=X;I.Get (X);C.Body2:=X;
            I.Get (X);C.Exclude:=X;I.Get (X);C.Dim:=X;I.Get (X);C.Address:=X;
         end loop;
         for R in J'Range (1) loop for K in J'Range (2) loop F.Get (J(R,K));end loop;end loop;
         for R in G'Range (1) loop for K in G'Range (2) loop F.Get (G(R,K));end loop;end loop;
         Project (Cs,B,Cone'Val(Cone_Id),J,G,M);
         for V of M loop F.Put (V,Fore=>1,Aft=>17,Exp=>3);Put (" ");end loop;New_Line;
      end;
   end loop;
end Adhesion_Probe;
