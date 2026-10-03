with MJ.Flex_Contact_Weights;
with MJ.Flex_Node_Weights;
with MJ.Flex_State.Nodal_Contacts;
with MJ.Flex_State.Shell_Contacts;
package body MJ.Flex_State.Response_Contacts with SPARK_Mode is
   package CW renames MJ.Flex_Contact_Weights;
   package NW renames MJ.Flex_Node_Weights;

   function Signed (Value : NW.Vertex_Weight; Negative : Boolean) return NW.Vertex_Weight
     with Global => null, Inline,
       Post => Signed'Result = (if Negative then -1.0 * Value else Value);
   function Signed (Value : NW.Vertex_Weight; Negative : Boolean) return NW.Vertex_Weight is
     (if Negative then -1.0 * Value else Value);

   procedure Side (S : State; F : Natural; Element, Vertex, Opposite : Integer;
     Point : RG.Vec; Negative : Boolean; Value : out SW.Endpoint; Result : out Status) is
      Vertices : Nodal_Contacts.Vertex_Ids := [others => 0];
      Coefficients : NW.Vertex_Weights := [others => 0.0];
      Raw : CW.Weights := [others => 0.0];
      Count : NW.Vertex_Count;
      Remove : Natural := 0;
      Normalized : Boolean;
      Candidate : SW.Endpoint := (others => <>);
   begin
      Value := (others => <>);
      if not Ready (S) then Result := Not_Allocated; return; end if;
      if not Current (S) then Result := Stale_State; return; end if;
      Result := Invalid_Input;
      if F >= S.Nf or else F not in S.Flexes'Range then return; end if;
      if Vertex < -1 or else (for some X of Point => X not in RG.Coordinate) then return; end if;
      declare B : Flex_Block renames S.Flexes (F); begin
         if B.Nv > Max_Vertices or else S.Nb = 0 then Result := Invalid_Model; return; end if;
         if Vertex >= 0 then
            if Vertex >= B.Nv then return; end if;
            Count := 1; Vertices (0) := Vertex; Coefficients (0) := Signed (1.0, Negative);
         else
            if Element < 0 or else Element >= B.Ne or else Element not in B.Elements'Range then return; end if;
            Count := B.Description.Dimension + 1;
            for K in 1 .. Count loop
               declare V : constant Natural := B.Elements (Element).Vertices (K-1); begin
                  if V >= B.Nv then return; end if;
                  Vertices (K-1) := V;
                  if (for some X of B.World (V) => X not in RG.Coordinate) then
                     Result := Numeric_Limit; return;
                  end if;
                  Raw (K) := CW.Inverse_Distance (CW.Point (Point), CW.Point (B.World (V)));
                  if V = Opposite then Remove := K; end if;
               end;
               pragma Loop_Invariant (Static => (for all W of Raw => W in 0.0 .. 1.0e15));
               pragma Loop_Invariant (Static => Remove <= K);
            end loop;
            if Remove > 0 then
               for K in Remove .. Count - 1 loop
                  Raw (K) := Raw (K+1); Vertices (K-1) := Vertices (K);
                  pragma Loop_Invariant (Static => (for all W of Raw => W in 0.0 .. 1.0e15));
               end loop;
               Count := Count - 1;
            end if;
            CW.Normalize (Raw, Count, Normalized);
            if not Normalized then Result := Numeric_Limit; return; end if;
            for K in 1 .. Count loop
               if Raw (K) not in 0.0 .. 1.0 then Result := Numeric_Limit; return; end if;
               Coefficients (K-1) := Signed (Raw (K), Negative);
            end loop;
         end if;
         if B.Interp = 0 then
            Candidate.Count := Count;
            for K in 0 .. Integer (Count)-1 loop
               if Vertices (K) >= B.Nv then Result := Invalid_Model; return; end if;
               declare Id : constant Integer := B.Bodies (Vertices (K)); begin
                  if Id < 0 or else Id >= S.Nb then Result := Invalid_Model; return; end if;
                  Candidate.Items (K) := (Id, Coefficients (K));
               end;
            end loop;
         elsif B.Interp > 0 then
            declare Nodal : NW.Endpoint; begin
               Nodal_Contacts.Weights (S, F, Vertices, Coefficients, Count, Nodal, Result);
               if Result /= Success then return; end if;
               Candidate.Count := Nodal.Count;
               for K in 0 .. Integer (Nodal.Count)-1 loop
                  Candidate.Items (K) := (Nodal.Items (K).Body_Id, Nodal.Items (K).Weight);
               end loop;
            end;
         else
            Shell_Contacts.Weights (S, F, Shell_Contacts.Vertex_Ids (Vertices),
              Coefficients, Count, Candidate, Result);
            if Result /= Success then return; end if;
         end if;
      end;
      for K in 0 .. Integer (Candidate.Count)-1 loop
         if Candidate.Items (K).Body_Id >= S.Nb then Result := Invalid_Model; return; end if;
         pragma Loop_Invariant (for all J in 0 .. K => Candidate.Items (J).Body_Id < S.Nb);
      end loop;
      Value := Candidate; Result := Success;
   end Side;
end MJ.Flex_State.Response_Contacts;
