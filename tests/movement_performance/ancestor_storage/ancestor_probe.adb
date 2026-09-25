with Ada.Text_IO; use Ada.Text_IO;
with MJ.Types; use MJ.Types;
with MJ.Ancestor_Rows;

procedure Ancestor_Probe is
   package AR renames MJ.Ancestor_Rows;
   Cases : Natural := 0;
   procedure Require (Ok : Boolean; Context : String) is
   begin
      if not Ok then raise Program_Error with Context; end if;
   end Require;
   procedure Check (Parents : Int_Array) is
      P : AR.Pattern;
      N : constant Natural := Parents'Length;
      Expected_Count, Node, Depth : Integer;
      Dense : Real_Array (0 .. N * N - 1);
   begin
      Require (AR.Empty (P) and AR.Size (P) = 0 and AR.Count (P) = 0, "default state");
      for I in Dense'Range loop Dense (I) := Real (I) + 0.125; end loop;
      for Reuse in 1 .. 2 loop
         AR.Build (P, Parents);
         Require (not AR.Empty (P) and AR.Size (P) = N, "built shape");
         declare
            Packed : Real_Array (0 .. AR.Count (P) - 1) := [others => -1.0e130];
         begin
            AR.Copy_Matrix (P, Dense, Packed);
            for I in Parents'Range loop
               for A in 0 .. AR.Length (P, I) - 1 loop
                  Require (Packed (AR.Start (P, I) + A) = Dense (I * N + AR.Column (P, I, A)),
                    "complete matrix packing");
               end loop;
            end loop;
         end;
         Expected_Count := 0;
         for I in Parents'Range loop
            Node := I; Depth := 0;
            while Node >= 0 loop Depth := Depth + 1; Node := Parents (Node); end loop;
            Require (AR.Start (P, I) = Expected_Count and AR.Length (P, I) = Depth,
              "row address or ancestor count");
            Require (AR.Parent (P, I) = Parents (I), "parent map");
            if AR.Length (P, I) = I + 1 then
               Require (AR.Dense_Prefix_Start (P, I) = AR.Start (P, I), "dense prefix address");
            end if;
            Expected_Count := Expected_Count + Depth;
            Node := I;
            for A in reverse 0 .. Depth - 1 loop
               Require (AR.Column (P, I, A) = Node, "ancestor walk");
               Require (AR.Length (P, Node) = A + 1, "ancestor prefix length");
               for B in 0 .. A loop
                  if N <= 7 or else B = 0 or else B = A then
                  Require (AR.Column (P, Node, B) = AR.Column (P, I, B), "ancestor prefix values");
                  end if;
               end loop;
               Node := Parents (Node);
            end loop;
            declare
               --  Nonzero lower bounds exercise copy offsets, also in SIMD builds.
               Packed : Real_Array (11 .. 10 + Depth) := [others => -1.0];
            begin
               AR.Copy_Row (P, I, Dense, Packed);
               for A in 0 .. Depth - 1 loop
                  Require (Packed (11 + A) = Dense (I * N + AR.Column (P, I, A)), "packed entry");
               end loop;
            end;
         end loop;
         Require (AR.Count (P) = Expected_Count, "total storage");
         AR.Free (P);
         Require (AR.Empty (P) and AR.Size (P) = 0 and AR.Count (P) = 0, "free state");
         AR.Free (P);
      end loop;
      Cases := Cases + 1;
   end Check;
begin
   --  Every ordered parent map through seven DOFs, including every forest.
   for N in 0 .. 7 loop
      declare
         Parents : Int_Array (0 .. N - 1) := [others => -1];
         Carry : Natural;
      begin
         loop
            Check (Parents);
            Carry := 0;
            while Carry < N and then Parents (Carry) = Integer (Carry) - 1 loop
               Parents (Carry) := -1;
               Carry := Carry + 1;
            end loop;
            exit when Carry = N;
            Parents (Carry) := Parents (Carry) + 1;
         end loop;
      end;
   end loop;
   for N in 8 .. AR.Max_Dofs loop
      if N in 8 | 15 | 16 | 17 | 24 | 31 | 32 | 33 | 64 | 128 | 255 | 256 then
      declare
         Parents : Int_Array (0 .. N - 1);
      begin
         for Shape in 0 .. 3 loop
            for I in Parents'Range loop
               Parents (I) := (case Shape is
                 when 0 => Integer (I) - 1,
                 when 1 => -1,
                 when 2 => (if I = 0 then -1 else 0),
                 when others => (if I mod 7 = 0 then -1 else Integer (I) - 1));
            end loop;
            Check (Parents);
         end loop;
      end;
      end if;
   end loop;
   Require (not AR.Valid_Parents ([0 => 0]), "self parent");
   Require (not AR.Valid_Parents ([0 => -2]), "invalid root");
   Require (not AR.Valid_Parents ([1 => -1]), "nonzero parent origin");
   Put_Line (Natural'Image (Cases) & " ancestor patterns passed, each built/freed twice");
end Ancestor_Probe;
