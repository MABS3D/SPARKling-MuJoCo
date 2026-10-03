package body MJ.Flex_State.Nodal_Contacts with SPARK_Mode is
   package FI renames MJ.Flex_Interpolation;
   use type MJ.Types.Int64;

   procedure Local_Bounds (Coord : RG.Vec; Cells : FI.Grid; Local : RG.Vec)
     with Ghost => Static, Global => null,
       Pre => (for all X of Coord => X in FI.Parametric)
         and then (for all K in RG.Axis => Local (K) = FI.Local_Of (Coord (K), Cells (K))),
       Post => (for all X of Local => X in FI.Local_Value);
   procedure Local_Bounds (Coord : RG.Vec; Cells : FI.Grid; Local : RG.Vec) is
   begin
      for K in RG.Axis loop
         declare Expected : constant FI.Local_Value := FI.Local_Of (Coord (K), Cells (K)); begin
            pragma Assert (Local (K) = Expected);
         end;
         pragma Loop_Invariant (for all J in RG.Axis'First .. K => Local (J) in FI.Local_Value);
      end loop;
   end Local_Bounds;

   procedure Weights (S : State; F : Natural; Vertices : Vertex_Ids;
     Coefficients : NW.Vertex_Weights; Count : NW.Vertex_Count;
     Value : out NW.Endpoint; Result : out Status) is
      Coord, Local : RG.Vec;
      Points : NW.Coordinates := [others => [others => 0.0]];
      Indices : FI.Node_Indices;
      Basis : FI.Basis_Array;
      Bodies : NW.Cell_Bodies := [others => 0];
      Candidate : NW.Endpoint;
   begin
      Value := (others => <>);
      if not Ready (S) then Result := Not_Allocated; return; end if;
      if F >= S.Nf or else F not in S.Flexes'Range then
         Result := Invalid_Input; return;
      end if;
      declare B : Flex_Block renames S.Flexes (F); begin
         if B.Interp not in FI.Order then
            Result := Unsupported_Feature; return;
         end if;
         if S.Nb = 0 or else B.Nn = 0 or else B.Nv > Max_Vertices
           or else FI.Node_Count (B.Cells, B.Interp) /= Int64 (B.Nn)
         then Result := Invalid_Model; return; end if;
         if Count = 0 then Result := Success; return; end if;
         for J in 0 .. Integer (Count) - 1 loop
            if Vertices (J) >= B.Nv then
               Result := Invalid_Input; return;
            end if;
            Points (J) := B.Local (Vertices (J));
            if (for some X of Points (J) => X not in FI.Parametric) then
               Result := Numeric_Limit; return;
            end if;
            pragma Loop_Invariant (Static =>
              (for all P of Points => (for all X of P => X in FI.Parametric)));
         end loop;
         for K in RG.Axis loop
            Coord (K) := NW.Coordinate (Points, Coefficients, Count, K);
         end loop;
         if (for some X of Coord => X not in FI.Parametric) then
            Result := Numeric_Limit; return;
         end if;
         FI.Lookup (Coord, B.Cells, B.Interp, Local, Indices);
         Local_Bounds (Coord, B.Cells, Local);
         for J in 0 .. FI.Nodes_Per_Cell (B.Interp) - 1 loop
            if Indices (J) >= B.Nn then Result := Invalid_Model; return; end if;
            declare Id : constant Integer := B.Node_Bodies (Indices (J)); begin
               if Id < 0 or else Id >= S.Nb then Result := Invalid_Model; return; end if;
               Bodies (J) := Id;
            end;
         end loop;
         FI.Basis (Local, B.Interp, Basis);
         NW.Build (Basis, FI.Nodes_Per_Cell (B.Interp), Bodies,
           NW.Sign (Coefficients), Candidate);
      end;
      --  Keep the admission boundary explicit even when the kernel's support
      --  theorem is strengthened independently of this caller.
      for J in 0 .. Integer (Candidate.Count) - 1 loop
         if Candidate.Items (J).Body_Id >= S.Nb then
            Result := Invalid_Model; return;
         end if;
         pragma Loop_Invariant
           (for all K in 0 .. J => Candidate.Items (K).Body_Id < S.Nb);
      end loop;
      Value := Candidate;
      Result := Success;
   end Weights;
end MJ.Flex_State.Nodal_Contacts;
