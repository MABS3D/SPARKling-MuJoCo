with MJ.Types; use MJ.Types;
with MJ.Actuator_Math; use MJ.Actuator_Math;
with MJ.Transmissions; use MJ.Transmissions;
package MJ.Actuator_Transmissions with SPARK_Mode is
   type Gear_Vector is array (Natural range 0 .. 5) of Input;
   type Jacobian is array (Natural range <>, Natural range <>) of Input;
   type Output_Rows is array (Natural range 0 .. 2) of Row;
   type Result is record
      Accepted : Boolean := False;
      Nout : Natural range 0 .. 3 := 0;
      Length : Vector := Zero;
      Moments : Output_Rows := (others => <>);
   end record;
   type Parent_Array is array (Natural range <>) of Integer;
   function Is_Ancestor (Parents : Parent_Array; Ancestor : Dof; Node : Integer) return Boolean is
     (if Node<0 then False elsif Node=Ancestor then True else Is_Ancestor (Parents,Ancestor,Parents (Node)))
     with Ghost => Static,
       Pre => Parents'First=0 and then Parents'Length<=Max_Dof and then Ancestor in Parents'Range
         and then Node in -1 .. Integer (Parents'Length)-1
         and then (for all K in Parents'Range => Parents (K) in -1 .. Integer (K)-1),
       Subprogram_Variant => (Decreases => Node);
   -- Parents must precede children; topology is compiled once, outside hot loops.
   function Common_Ancestors (Parents : Parent_Array; First, Second : Integer) return Mask with
     Pre => Parents'First=0 and then Parents'Length<=Max_Dof
       and then First in -1 .. Integer (Parents'Length)-1 and then Second in -1 .. Integer (Parents'Length)-1
       and then (for all K in Parents'Range => Parents (K) in -1 .. Integer (K)-1),
     Post => Common_Ancestors'Result'First=0 and then Common_Ancestors'Result'Length=Parents'Length;
   pragma Postcondition (Static => (for all K in Parents'Range => Common_Ancestors'Result (K)=
     (Is_Ancestor (Parents,K,First) and then Is_Ancestor (Parents,K,Second))));
   function Joint (Kind : Joint_Kind; NV : Count; Start : Dof; Position : Input;
                   Orientation : Quaternion; Gear : Gear_Vector; In_Parent : Boolean := False;
                   SO3 : Boolean := False) return Result with
     Pre => Bounded (Orientation,1.0e10) and then
       (if Kind=Ball then Start+3<=NV elsif Kind=Free then Start+6<=NV else Start<NV)
       and then (not SO3 or else Kind=Ball),
     Post => (if Joint'Result.Accepted then Joint'Result.Nout=(if SO3 then 3 else 1)
       and then (for all K in 0 .. Integer (Joint'Result.Nout)-1 => Valid (Joint'Result.Moments (K),NV))
       and then (if Kind=Free then Joint'Result.Length=Zero
         elsif Kind=Hinge or else Kind=Slide then Joint'Result.Length=(Position*Gear (0),0.0,0.0)));
   function Tendon (Length : Input; Moment : Row; Gear : Input) return Result with
     Pre => Valid (Moment,Max_Dof) and then (for all K in 0 .. Integer (Moment.N)-1 => Moment.Val (K) in -1.0e60 .. 1.0e60),
     Post => Tendon'Result.Accepted and then Tendon'Result.Nout=1
       and then Tendon'Result.Length=(Length*Gear,0.0,0.0)
       and then Tendon'Result.Moments (0).N=Moment.N and then Tendon'Result.Moments (0).Col=Moment.Col
       and then (for all K in 0 .. Integer (Moment.N)-1 => Tendon'Result.Moments (0).Val (K)=Moment.Val (K)*Gear);
   function Site (Position, Reference_Position : Vector; Orientation, Reference_Orientation : Matrix;
                  World_Quaternion, Reference_Quaternion : Quaternion;
                  JP, JR, RP, RR : Jacobian; Common : Mask; Gear : Gear_Vector;
                  Has_Reference : Boolean := False; SO3 : Boolean := False) return Result with
     Pre => Bounded (Position,1.0e10) and then Bounded (Reference_Position,1.0e10)
       and then Bounded (World_Quaternion,1.0e26) and then Bounded (Reference_Quaternion,1.0e26)
       and then JP'First (1)=0 and then JP'Last (1)=2 and then JR'First (1)=0 and then JR'Last (1)=2
       and then RP'First (1)=0 and then RP'Last (1)=2 and then RR'First (1)=0 and then RR'Last (1)=2
       and then JP'First (2)=0 and then JP'Length (2)<=Max_Dof
       and then JR'First (2)=0 and then RP'First (2)=0 and then RR'First (2)=0
       and then JP'Last (2)=JR'Last (2) and then JP'Last (2)=RP'Last (2) and then JP'Last (2)=RR'Last (2)
       and then Common'First=0 and then Common'Length=JP'Length (2)
       and then (for all I in 0 .. 2 => (for all J in 0 .. 2 => abs Orientation (I,J)<=1.1 and then abs Reference_Orientation (I,J)<=1.1))
       and then (not SO3 or else Has_Reference);
   function Slidercrank (Axis, Displacement : Vector; Axis_Jacobian, Displacement_Jacobian : Jacobian;
                         Rod, Gear : Input) return Result with
     Pre => Bounded (Axis,1.0e10) and then Bounded (Displacement,1.0e10)
       and then Axis_Jacobian'First (1)=0 and then Axis_Jacobian'Last (1)=2
       and then Displacement_Jacobian'First (1)=0 and then Displacement_Jacobian'Last (1)=2
       and then Axis_Jacobian'First (2)=0 and then Axis_Jacobian'Length (2)<=Max_Dof
       and then Displacement_Jacobian'First (2)=0 and then Displacement_Jacobian'Last (2)=Axis_Jacobian'Last (2);
   -- Active=J_active' * efc_weights, Gap=ordered sum of gap normal Jacobians.
   function Body_Adhesion (Active, Gap : Dense_Row; Contacts : Count) return Result with
     Pre => Active'First=0 and then Active'Length<=Max_Dof and then Gap'First=0 and then Gap'Last=Active'Last
       and then (for all X of Active => X in -1.0e60 .. 1.0e60) and then (for all X of Gap => X in -1.0e60 .. 1.0e60);
end MJ.Actuator_Transmissions;
