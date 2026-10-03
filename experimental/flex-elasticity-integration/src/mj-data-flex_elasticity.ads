with MJ.External_Forces;
with MJ.Flex_Elastic_Kernels;

-- Explicit contact-free flex entry. Owns compiled topology and material data;
-- uses the existing rigid Model/Data dynamics, actuators, fluids and Euler.
package MJ.Data.Flex_Elasticity with SPARK_Mode is
   Max_Flexes : constant := 64;
   Max_Vertices : constant := 4096;
   Max_Edges : constant := 4096;
   Max_Elements : constant := 4096;
   type Engine is limited private;
   --  The force model owns only compiled flex data. A constrained child can
   --  evaluate it on the Simulation created from the same compiled model.
   type Force_Model is limited private;
   function Ready (Model : Force_Model) return Boolean with Global => null;
   procedure Create_Forces (M : MJ.Models.Model; Model : in out Force_Model;
                            Result : out Status)
     with Post => (if Result = Success then Ready (Model));
   procedure Free_Forces (Model : in out Force_Model)
     with Post => not Ready (Model);
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate_Forces
     (D : in out Simulation; Model : in out Force_Model; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Complete_State_Values (D) = Complete_State_Values (D)'Old);
   type Trace (Nv, Npos, Nedge : Natural) is record
      Valid : Boolean := False;
      Spring, Damper : Real_Array (1 .. Nv);
      Position : Real_Array (1 .. Npos);
      Length, Velocity : Real_Array (1 .. Nedge);
   end record;
   function Ready (E : Engine) return Boolean with Global => null;
   function State (E : Engine) return Real_Array with Global => null;
   function Complete_State (E : Engine) return Real_Array with Global => null;
   function Acceleration (E : Engine) return Real_Array with Global => null;
   function Passive (E : Engine) return Real_Array with Global => null;
   function Diagnostics (E : Engine) return Trace with Global => null;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status);
   procedure Free (E : in out Engine; Result : out Status);
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector; New_Time : Nonneg_Tier0; Result : out Status);
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status);
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status);
   pragma Unevaluated_Use_Of_Old (Allow);
   procedure Evaluate (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => Complete_State (E) = Complete_State (E)'Old);
   procedure Step (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Post => (Static => (if Result /= Success then Complete_State (E) = Complete_State (E)'Old));
private
   package K renames MJ.Flex_Elastic_Kernels;
   subtype Index is Natural range 0 .. Max_Vertices - 1;
   type Columns is array (Natural range 0 .. Max_Dofs - 1) of Natural;
   type Chain is record
      Count : Natural range 0 .. Max_Dofs := 0;
      Col : Columns := [others => 0];
   end record;
   type Vertex is record
      Body_Id, Dofadr, Dofnum : Natural := 0;
      Simple : Boolean := False;
      Offset : Vector := Zero;
      Ancestors : Chain;
   end record;
   type Four_Indices is array (Natural range 0 .. 3) of Integer;
   type Bending_Metric is array (Natural range 0 .. 16) of K.Coefficient;
   type Edge is record
      Vert : Four_Indices := [0, 0, -1, -1];
      Rest : Nonneg_Tier0 := 0.0;
      Rigid, Bending : Boolean := False;
      B : Bending_Metric := [others => 0.0];
      Ancestors : Chain;
   end record;
   type Six_Indices is array (Natural range 0 .. 5) of Natural;
   type Element is record
      Vert : Four_Indices := [others => 0];
      Edges : Six_Indices := [others => 0];
      M : K.Metric := [others => [others => 0.0]];
   end record;
   type Flex is record
      Dim : Natural range 1 .. 3 := 1;
      First_Vertex, Nvert, First_Edge, Nedge, First_Element, Nelem : Natural := 0;
      Stretch, Rigid : Boolean := False;
      Damping, Edge_Stiffness, Edge_Damping : Nonneg_Tier0 := 0.0;
   end record;
   type Vertex_Array is array (Integer range <>) of Vertex;
   type Edge_Array is array (Integer range <>) of Edge;
   type Element_Array is array (Integer range <>) of Element;
   type Flex_Array is array (Integer range <>) of Flex;
   type Vector_Array is array (Integer range <>) of Vector;
   type Storage (Last_Flex, Last_Vertex, Last_Edge, Last_Element, Last_Dof : Integer) is record
      Nb : Natural := 0;
      Nf : Natural := Last_Flex + 1;
      Nvert : Natural := Last_Vertex + 1;
      Nedge : Natural := Last_Edge + 1;
      Nelem : Natural := Last_Element + 1;
      Nv : Natural := Last_Dof + 1;
      Flexes : Flex_Array (0 .. Last_Flex) := [others => <>];
      Vertices : Vertex_Array (0 .. Last_Vertex) := [others => <>];
      Edges : Edge_Array (0 .. Last_Edge) := [others => <>];
      Elements : Element_Array (0 .. Last_Element) := [others => <>];
      Positions, Offsets, Spring_Vertex, Damper_Vertex : Vector_Array (0 .. Last_Vertex) := [others => Zero];
      Length, Velocity : Real_Array (0 .. Last_Edge) := [others => 0.0];
      Spring, Damper : Real_Array (0 .. Last_Dof) := [others => 0.0];
      Valid : Boolean := False;
   end record;
   type Storage_Access is access Storage;
   type Force_Model is limited record
      S : Storage_Access := null;
   end record;
   procedure Evaluate_Model
     (D : in out Simulation; S : in out Storage; Result : out Status;
      External : MJ.External_Forces.Wrench_Array);
   type Engine is limited record
      D : Simulation;
      S : Storage_Access := null;
   end record;
end MJ.Data.Flex_Elasticity;
