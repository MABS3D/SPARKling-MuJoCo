with MJ.Types; use MJ.Types;
with MJ.Rigid_Geometry; use MJ.Rigid_Geometry;
with MJ.Contact_Geometry;
with MJ.Contact_Parameters; use MJ.Contact_Parameters;

package MJ.Full_Contacts with SPARK_Mode is
   type Contact_Hessian is array (Natural range 0 .. 35) of Real;
   type Full_Contact is record
      Position : Vec;
      Distance : Real;
      Frame : Matrix;
      Param : Parameters;
      Geoms : Pair;
      Excluded : Boolean;
      Dim : Dimension;
      Efc_Address : Integer;
      Mu : Real;
      Hessian : Contact_Hessian;
   end record;
   type Full_Array is array (Natural range <>) of Full_Contact with Relaxed_Initialization;
   type Full_Manifold is record
      Length : Natural range 0 .. MJ.Contact_Geometry.Max_Manifold := 0;
      Items : Full_Array (0 .. MJ.Contact_Geometry.Max_Manifold-1);
   end record;
   --  Normalize the supplied normal with an already computed length.  This
   --  bound uses Length >= 0.5 and the component bounds, not sqrt accuracy.
   function Scale_Normal (Normal : Vec; Length : Real) return Vec
     with Inline, Global => null,
       Pre => (for all X of Normal => X in -2.0 .. 2.0) and Length >= 0.5,
       Post => (for all I in Axis => Scale_Normal'Result (I) in -4.0 .. 4.0
         and Scale_Normal'Result (I) = Normal (I)*(1.0/Length));
   procedure Make_Frame (Normal, Tangent : Vec; Frame : out Matrix; Result : out Status)
     with Global => null,
       Pre => (for all X of Normal => X in -2.0 .. 2.0)
         and (for all X of Tangent => X in -2.0 .. 2.0);
   procedure Finalize (M : MJ.Contact_Geometry.Manifold; P : Parameters;
                       Geoms : Pair; Full : in out Full_Manifold; Result : out Status)
     with Global => null,
       Pre => MJ.Contact_Geometry.Active_Initialized (M)
         and then (for all I in 0 .. M.Length-1 => MJ.Contact_Geometry.Finite (M.Items (I))),
       Post => (if Result /= Success then Full.Length = 0)
         and then (if Result = Success then Full.Length = M.Length
           and then (for all I in 0 .. Full.Length-1 => Full.Items (I)'Initialized
             and then (Full.Items (I).Position = M.Items (I).Position
             and Full.Items (I).Distance = M.Items (I).Distance
             and Full.Items (I).Param = P and Full.Items (I).Geoms = Geoms
             and Full.Items (I).Excluded = (M.Items (I).Distance >= P.Include_Margin and P.Adhesion = 0.0)
             and Full.Items (I).Dim = (if M.Items (I).Distance >= P.Include_Margin and P.Adhesion /= 0.0 then 1 else P.Dim)
             and Full.Items (I).Efc_Address = -1 and Full.Items (I).Mu = 0.0
             and (for all X of Full.Items (I).Hessian => X = 0.0))));
end MJ.Full_Contacts;
