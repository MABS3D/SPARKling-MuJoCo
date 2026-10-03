with Ada.Command_Line;
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;
with Ada.Unchecked_Conversion;
with Ada.Unchecked_Deallocation;
with Interfaces;
with MJ.Fields;
with MJ.MJB;
with MJ.File_IO;
with MJ.Validation;
with MJ.Data.Pipeline;
with MJ.Data.Constrained.Signed_Contacts;
with MJ.Flex_State;
with MJ.Flex_State.Response_Contacts;
procedure MJ.Data.Constrained.Signed_Probe is
   package F renames MJ.Flex_State;
   package RC renames F.Response_Contacts;
   package SC renames MJ.Data.Constrained.Signed_Contacts;
   use type F.Status;
   package RIO is new Ada.Text_IO.Float_IO (Real);
   package UIO is new Ada.Text_IO.Modular_IO (Interfaces.Unsigned_64);
   function Bits is new Ada.Unchecked_Conversion (Real, Interfaces.Unsigned_64);
   procedure Release_Int is new Ada.Unchecked_Deallocation (Int_Array, Int_Array_Access);
   type Engine_Access is access Engine;
   type State_Access is access F.State;
   E : Engine_Access := new Engine;
   Scene : State_Access := new F.State;
   M : MJ.Models.Model;
   Data : Byte_Array_Access;
   Loaded : MJ.Fields.Load_Result;
   OK : Boolean;
   Result : Status;
   FS_Result : F.Status;
   Cases, Sparse, Dim : Natural;
   X : Real;
   procedure Check is
   begin if Result /= Success then raise Program_Error with Result'Image; end if; end Check;
   -- Harness-only rigid factory: all flex geometry is owned separately. This
   -- creates no production admission policy and never simulates stripped data.
   procedure Create_Rigid_State is
      Saved_Sizes : constant MJ.Models.Sizes := M.S;
      Saved_Caps : constant Capacities := M.Caps;
      Saved_Flex : MJ.Models.Flex_Arrays := M.Flexes;
      Saved_Names : Int_Array_Access := M.Names.Name_Flexadr;
      Empty : MJ.Models.Flex_Arrays;
      Empty_Sizes : MJ.Models.Sizes;
   begin
      if M.S.Neq /= 0 then raise Program_Error with "probe requires no equality"; end if;
      MJ.Models.Allocate_Flex (Empty_Sizes, Empty);
      M.Flexes := Empty; M.Names.Name_Flexadr := new Int_Array'(0 .. -1 => 0);
      M.S.Nflex := 0; M.S.Nflexnode := 0; M.S.Nflexvert := 0; M.S.Nflexedge := 0;
      M.S.Nflexelem := 0; M.S.Nflexelemdata := 0; M.S.Nflexstiffness := 0;
      M.S.Nflexbending := 0; M.S.Nflexelemedge := 0; M.S.Nflexshelldata := 0;
      M.S.Nflexevpair := 0; M.S.Nflextexcoord := 0; M.S.NJfe := 0; M.S.NJfv := 0;
      M.S.Nefm0dof := 0; M.S.Nefm0L := 0;
      MJ.Validation.Validate (M, (Contact_Cap=>Max_C), Loaded);
      if Loaded.Status /= MJ.Types.OK then raise Program_Error with "proxy validation"; end if;
      Constrained.Create (M, E.all, Result);
      Empty := M.Flexes; Release_Int (M.Names.Name_Flexadr);
      M.S := Saved_Sizes; M.Caps := Saved_Caps; M.Flexes := Saved_Flex; M.Names.Name_Flexadr := Saved_Names;
      Saved_Flex := (others => <>); Saved_Names := null; MJ.Models.Free_Flex (Empty);
      Check;
   end Create_Rigid_State;
begin
   MJ.File_IO.Read_File (Ada.Command_Line.Argument (1),Data,OK);
   if not OK then raise Program_Error with "file"; end if;
   MJ.MJB.Parse_Raw (Data.all,M,Loaded); Free_Byte (Data);
   if Loaded.Status /= MJ.Types.OK then raise Program_Error with "parse"; end if;
   F.Create (M,Scene.all,FS_Result);
   if FS_Result /= F.Success then raise Program_Error with "FS create"; end if;
   Create_Rigid_State; MJ.Models.Free (M);
   declare Q : State_Vector (0 .. E.D.Nq-1); V : State_Vector (0 .. E.D.Nv-1); begin
      for I in Q'Range loop RIO.Get (X); Q (I) := X; end loop;
      for I in V'Range loop RIO.Get (X); V (I) := X; end loop;
      Constrained.Set_State (E.all,Q,V,0.0,Result); Check;
   end;
   Pipeline.Update_Poses (E.D,Result); Check;
   Pipeline.Ensure_Jacobians (E.D,Result); Check;
   declare
      Contact : MJ.Full_Contacts.Full_Contact;
      Weights : SC.Input;
      Value : SC.Response;
      procedure Reject (Expected : Status) is
      begin
         Value := (Width=>Max_V, Columns=>[others=>7], J=>[others=>[others=>3.0]],
                   Translation=>2.0,Rotation=>4.0);
         SC.Build (E.all,Contact,Weights,Value,Result);
         if Result /= Expected or else Value /= SC.Response'(others=><>) then
            raise Program_Error with "rejection must clear response";
         end if;
      end Reject;
      use type SC.Response;
   begin
      Reject (Invalid_Index);
      Weights.Jacobian0 := (Count=>1, Items=>[0=>(E.D.Nb,1.0),others=><>]);
      Reject (Invalid_Index);
      Weights.Jacobian0.Items (0) := (0,50001.0); Reject (Invalid_Index);
      Weights.Jacobian0.Items (0) := (0,-1.0);
      Weights.Diagonal1 := (Count=>1,Items=>[0=>(E.D.Nb,1.0),others=><>]); Reject (Invalid_Index);
      Weights.Diagonal1 := (others=><>);
      Contact.Frame (0) := 3.0; Reject (Numeric_Limit); Contact.Frame (0) := 1.0;
      Contact.Position (0) := 1.0e11; Reject (Numeric_Limit); Contact.Position (0) := 0.0;
      E.D.Cache.Jacobian_Valid := False; Reject (Invalid_Index); E.D.Cache.Jacobian_Valid := True;
   end;
   declare Poses : RG.Pose_Array (0 .. E.D.Nb-1); begin
      for B in Poses'Range loop
         Poses (B).Position := RG.Vec (E.D.Kinematic.Bodies (B).Position);
         for I in RG.Axis loop
            for J in RG.Axis loop Poses (B).Rotation (3*I+J) := E.D.Kinematic.Bodies (B).Rotation (I,J); end loop;
         end loop;
      end loop;
      F.Update (Scene.all,Poses,FS_Result);
      if FS_Result /= F.Success then raise Program_Error with "FS update"; end if;
   end;
   Ada.Integer_Text_IO.Get (Cases);
   for I in 1 .. Cases loop
      declare
         Contact : MJ.Full_Contacts.Full_Contact;
         Weights : SC.Input;
         Value : SC.Response;
         procedure Read_Side (Negative : Boolean; J, D : out SC.SW.Endpoint) is
            Flex, Element, Vertex, Opposite, Body_Id : Integer;
         begin
            Ada.Integer_Text_IO.Get (Flex); Ada.Integer_Text_IO.Get (Element);
            Ada.Integer_Text_IO.Get (Vertex); Ada.Integer_Text_IO.Get (Opposite); Ada.Integer_Text_IO.Get (Body_Id);
            if Flex < 0 then
               J := (Count=>1, Items=>[0=>(Body_Id,(if Negative then -1.0 else 1.0)),others=><>]);
               D := (Count=>1, Items=>[0=>(Body_Id,1.0),others=><>]);
            else
               RC.Side (Scene.all,Flex,Element,Vertex,Opposite,Contact.Position,Negative,J,FS_Result);
               if FS_Result /= F.Success then raise Program_Error with "J side" & FS_Result'Image; end if;
               RC.Side (Scene.all,Flex,Element,Vertex,Opposite,Contact.Position,False,D,FS_Result);
               if FS_Result /= F.Success then raise Program_Error with "D side" & FS_Result'Image; end if;
            end if;
         end Read_Side;
      begin
         Ada.Integer_Text_IO.Get (Sparse); Ada.Integer_Text_IO.Get (Dim);
         Contact.Dim := Dim; E.Settings.Sparse := Sparse /= 0;
         for K in Contact.Position'Range loop RIO.Get (X); Contact.Position (K) := X; end loop;
         for K in Contact.Frame'Range loop RIO.Get (X); Contact.Frame (K) := X; end loop;
         Read_Side (True,Weights.Jacobian0,Weights.Diagonal0);
         Read_Side (False,Weights.Jacobian1,Weights.Diagonal1);
         SC.Build (E.all,Contact,Weights,Value,Result);
         Put_Line ("case " & Result'Image & Value.Width'Image);
         Put ("columns");for K in 1 .. Value.Width loop Put (Value.Columns (K)'Image);end loop;New_Line;
         Put ("diagonal ");UIO.Put (Bits (Value.Translation),Width=>0);Put (' ');UIO.Put (Bits (Value.Rotation),Width=>0);New_Line;
         for R in 1 .. Contact.Dim loop
            Put ("row");for K in 1 .. Value.Width loop Put (' ');UIO.Put (Bits (Value.J (R,K)),Width=>0);end loop;New_Line;
         end loop;
      end;
   end loop;
   F.Free (Scene.all); Constrained.Free (E.all,Result);
exception
   when others => F.Free (Scene.all); Constrained.Free (E.all,Result); MJ.Models.Free (M); raise;
end MJ.Data.Constrained.Signed_Probe;
