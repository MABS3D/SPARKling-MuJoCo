with Ada.Streams;
with Ada.Streams.Stream_IO;
with Interfaces;

package body MJ.File_IO with SPARK_Mode => Off is

   use Ada.Streams;
   use Ada.Streams.Stream_IO;

   procedure Read_File (Path : String; B : out Byte_Array_Access; OK : out Boolean) is
      F     : File_Type;
      Chunk : Stream_Element_Array (1 .. 65536);
      Last  : Stream_Element_Offset;
      Pos   : Natural := 0;
   begin
      B := null;
      OK := False;
      Open (F, In_File, Path);
      declare
         Total : constant Count := Size (F);
      begin
         if Total > Count (Natural'Last) then
            Close (F);
            return;
         end if;
         B := new Byte_Array (0 .. Natural (Total) - 1);
      end;
      while Pos < B'Length loop
         Read (F, Chunk, Last);
         exit when Last < Chunk'First;
         for K in Chunk'First .. Last loop
            exit when Pos >= B'Length;
            B (Pos) := Interfaces.Unsigned_8 (Chunk (K));
            Pos := Pos + 1;
         end loop;
      end loop;
      Close (F);
      OK := Pos = B'Length;
      if not OK then
         Free_Byte (B);
      end if;
   exception
      when others =>
         if Is_Open (F) then
            Close (F);
         end if;
         if B /= null then
            Free_Byte (B);
         end if;
         OK := False;
   end Read_File;

   procedure Write_File (Path : String; B : Byte_Array; OK : out Boolean) is
      F     : File_Type;
      Chunk : Stream_Element_Array (1 .. 65536);
      Pos   : Natural := B'First;
      N     : Stream_Element_Offset;
   begin
      OK := False;
      Create (F, Out_File, Path);
      while Pos <= B'Last loop
         N := 0;
         while N < Chunk'Length and then Pos <= B'Last loop
            N := N + 1;
            Chunk (N) := Stream_Element (B (Pos));
            Pos := Pos + 1;
         end loop;
         Write (F, Chunk (1 .. N));
      end loop;
      Close (F);
      OK := True;
   exception
      when others =>
         if Is_Open (F) then
            Close (F);
         end if;
         OK := False;
   end Write_File;

end MJ.File_IO;
