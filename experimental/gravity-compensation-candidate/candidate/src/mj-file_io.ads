--  Whole-file input for the loader. The body is not SPARK; the spec is, so
--  that Load in MJ.MJB can call it (spec 6.2). A sibling of MJ.MJB, not a
--  child, because a parent spec cannot with its own child.
with MJ.Types; use MJ.Types;

package MJ.File_IO with
  SPARK_Mode,
  Abstract_State => (File_System with External),
  Initializes    => File_System   --  the file system exists before the program runs
is
   --  Reads the whole file into a fresh 0-based buffer. On failure B is null.
   procedure Read_File (Path : String; B : out Byte_Array_Access; OK : out Boolean) with
     Global => (In_Out => File_System),
     Post   => (if OK then B /= null and then B'First = 0
                  and then Int64 (B'Length) <= Int64 (Natural'Last) else B = null);

   procedure Write_File (Path : String; B : Byte_Array; OK : out Boolean) with
     Global => (In_Out => File_System);

end MJ.File_IO;
