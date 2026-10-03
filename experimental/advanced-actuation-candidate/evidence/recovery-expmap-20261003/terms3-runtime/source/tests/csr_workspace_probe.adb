with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
with MJ.Transmissions; use MJ.Transmissions;
with MJ.Actuator_Transmissions;
procedure CSR_Workspace_Probe is
   package TT renames MJ.Actuator_Transmissions;
   use type TT.Row_Counts;
   use type TT.Row_Addresses;
   Checks : Natural := 0;
   procedure Check (Condition : Boolean) is
   begin
      if not Condition then raise Program_Error with "CSR workspace regression"; end if;
      Checks := Checks+1;
   end Check;
begin
   -- Offset slices must preserve their unoccupied tail and the enclosing buffer.
   declare
      Col : Columns (0 .. 15) := (others => 13);
      Val : Values (0 .. 15) := (others => 42.0);
      N : MJ.Transmissions.Count;
      Speed : constant Real_Array := (2.0,3.0,5.0,7.0);
      G : Real_Array := (1.0,2.0,3.0,4.0);
   begin
      Compress_Into ((0.0,2.0,0.0,-3.0),2.0,Col (5 .. 12),Val (5 .. 12),N);
      Check (N=2 and then Col (5)=1 and then Col (6)=3);
      Check (Val (5)=4.0 and then Val (6)=-6.0);
      Check (for all J in Col'Range => (if J<5 or else J>6 then Col (J)=13 and then Val (J)=42.0));
      Check (Velocity (Col (5 .. 6),Val (5 .. 6),Speed)=-30.0);
      Project (Col (5 .. 6),Val (5 .. 6),2.0,G);
      Check (G=(1.0,10.0,3.0,-8.0));
      -- Empty reuse must not clear or read old payload, even with a nonzero force.
      Compress_Into ((0.0,0.0,0.0,0.0),1.0,Col (5 .. 12),Val (5 .. 12),N);
      Check (N=0 and then Val (5)=4.0 and then Val (6)=-6.0);
      Check (Velocity (Col (5 .. 4),Val (5 .. 4),Speed)=0.0);
      Project (Col (5 .. 4),Val (5 .. 4),2.0,G);
      Check (G=(1.0,10.0,3.0,-8.0));
      -- A zero gear retains the schema selected before multiplication, as C does.
      Compress_Into ((0.0,2.0,0.0,-3.0),0.0,Col (5 .. 12),Val (5 .. 12),N);
      Check (N=2 and then Col (5)=1 and then Col (6)=3 and then Val (5)=0.0 and then Val (6)=0.0);
   end;
   -- Maximum DOF extent, all four lanes plus a tail, followed by empty reuse.
   declare
      Dense : Dense_Row (0 .. Max_Dof-1) := (others => 0.0);
      R : Row (Max_Dof-1);
      V : Real_Array (0 .. Max_Dof-1) := (others => 1.0);
      G : Real_Array (0 .. Max_Dof-1) := (others => 0.0);
   begin
      for K in Max_Dof-7 .. Max_Dof-1 loop Dense (K) := 2.0; end loop;
      Compress (Dense,1.0,R);
      Check (R.N=7 and then R.Col (6)=Max_Dof-1);
      Check (Velocity (R,V)=14.0);
      Project (R,3.0,G); Check (for all K in G'Range => G (K)=(if K>=Max_Dof-7 then 6.0 else 0.0));
      Dense := (others => 0.0); Compress (Dense,1.0,R);
      Check (R.N=0 and then Velocity (R,V)=0.0);
      Project (R,3.0,G); Check (for all K in G'Range => G (K)=(if K>=Max_Dof-7 then 6.0 else 0.0));
   end;
   -- One workspace changes both transmission type and row count on each call.
   declare
      R : TT.Result (11);
      T : Row (3);
      Identity_M : constant Matrix := ((1.0,0.0,0.0),(0.0,1.0,0.0),(0.0,0.0,1.0));
      J : TT.Jacobian (0 .. 2,0 .. 3) := (others => (others => 0.0));
      Z : constant TT.Jacobian := J;
   begin
      R.Col := (others => 9); R.Val := (others => 42.0);
      TT.Joint (R,Free,6,0,0.0,Identity,(1.0,2.0,3.0,4.0,5.0,6.0));
      Check (R.Accepted and then R.Nout=1 and then R.Row_N (0)=6);
      TT.Joint (R,Hinge,6,2,0.5,Identity,(2.0,0.0,0.0,0.0,0.0,0.0));
      Check (R.Accepted and then R.Length=(1.0,0.0,0.0) and then R.Row_N=(1,0,0));
      Check (R.Col (0)=2 and then R.Val (0)=2.0 and then R.Val (5)=6.0 and then R.Val (6)=42.0);
      TT.Joint (R,Ball,6,1,0.0,Identity,(others => 0.0),SO3=>True);
      Check (R.Nout=3 and then R.Row_N=(1,1,1) and then R.Row_Adr=(0,1,2));
      Check (for all K in 0 .. 2 => R.Col (K)=K+1 and then R.Val (K)=1.0);
      T.N := 2; T.Col (0) := 0; T.Col (1) := 3; T.Val (0) := 0.0; T.Val (1) := 5.0;
      TT.Tendon (R,0.5,T,0.0);
      Check (R.Nout=1 and then R.Row_N=(2,0,0) and then R.Col (0)=0 and then R.Col (1)=3);
      Check (R.Val (0)=0.0 and then R.Val (1)=0.0);
      TT.Body_Adhesion (R,(1.0,2.0,3.0,4.0),(1.0,2.0,3.0,4.0),0);
      Check (R.Accepted and then R.Row_N=(0,0,0) and then R.Length=Zero);
      J (0,0) := 2.0; J (1,1) := 3.0; J (2,3) := 4.0;
      TT.Site (R,Zero,Zero,Identity_M,Identity_M,Identity,Identity,Z,J,Z,Z,
               (False,False,False,False),(others => 0.0),True,True);
      Check (R.Accepted and then R.Nout=3 and then R.Row_N=(1,1,1) and then R.Row_Adr=(0,1,2));
      Check (R.Col (0)=0 and then R.Col (1)=1 and then R.Col (2)=3);
      Check (R.Val (0)=2.0 and then R.Val (1)=3.0 and then R.Val (2)=4.0 and then R.Val (6)=42.0);
      TT.Reset (R);
      Check (not R.Accepted and then R.Nout=0 and then R.Row_N=(0,0,0) and then R.Length=Zero);
      Check (R.Val (0)=2.0 and then R.Val (6)=42.0);
   end;
   Put_Line ("CSR workspace checks passed:" & Natural'Image (Checks));
end CSR_Workspace_Probe;
