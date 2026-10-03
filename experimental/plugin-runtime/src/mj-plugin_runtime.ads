with MJ.Plugin_Protocol; use MJ.Plugin_Protocol;
generic
   with procedure Invoke
     (H : Hook; Kind : Capability; Instance : Natural; C : Configuration;
      F : Frame; State : in out Values; Output : in out Outputs; Accepted : out Boolean);
package MJ.Plugin_Runtime with SPARK_Mode is
   subtype Instance_Index is Natural range 0 .. Max_Instances - 1;
   type State_Row is array (Natural range 0 .. Max_State - 1) of Value;
   type State_Matrix is array (Instance_Index) of State_Row;
   type Config_Buffer is array (Instance_Index) of Configuration;
   type Runtime is record
      Ready : Boolean := False;
      Count : Natural range 0 .. Max_Instances := 0;
      Config : Config_Buffer := [others => (others => <>)];
      State : State_Matrix := [others => [others => 0.0]];
      Output : Outputs;
   end record;
   procedure Create (P : in out Runtime; Config : Configurations; F : Frame; Status : out Result)
     with Global => null,
     Post => (if Status /= Success then P = P'Old
              else P.Ready and then P.Count = Config'Length);
   procedure Free (P : in out Runtime; F : Frame; Status : out Result)
     with Global => null, Post => not P.Ready and then P.Count = 0;
   procedure Reset (P : in out Runtime; F : Frame; Status : out Result)
     with Global => null,
     Post => P.Ready = P.Ready'Old and then P.Count = P.Count'Old
       and then P.Config = P.Config'Old
       and then (if Status /= Success then P = P'Old);
   procedure Copy (Source : Runtime; Dest : in out Runtime; F : Frame; Status : out Result)
     with Global => null,
     Post => (if Status /= Success then Dest = Dest'Old
              else Dest.Ready = Source.Ready and then Dest.Count = Source.Count
                and then Dest.Config = Source.Config);
   procedure Dispatch (P : in out Runtime; H : Hook; Kind : Capability;
                       Requested : Stage; F : Frame; Status : out Result)
     with Global => null,
     Pre => H in Compute | Act_Dot | Advance,
     Post => P.Ready = P.Ready'Old and then P.Count = P.Count'Old
       and then P.Config = P.Config'Old
       and then (if Status /= Success then P = P'Old)
       and then (for all I in Instance_Index =>
         (if I >= P.Count or else not Eligible (P.Config (I), H, Kind, Requested)
          then P.State (I) = P.State'Old (I)));
   procedure Query (P : in out Runtime; Instance : Natural; H : Hook; F : Frame; Status : out Result)
     with Global => null, Pre => H in Distance | Gradient,
     Post => P.Ready = P.Ready'Old and then P.Count = P.Count'Old
       and then P.Config = P.Config'Old
       and then (if Status /= Success then P = P'Old)
       and then (for all I in Instance_Index =>
         (if I /= Instance then P.State (I) = P.State'Old (I)));
private
   procedure Call (P : in out Runtime; I : Instance_Index; H : Hook;
                   Kind : Capability; F : Frame; Accepted : out Boolean)
     with Global => null,
     Post => P.Ready = P.Ready'Old and then P.Count = P.Count'Old
       and then P.Config = P.Config'Old
       and then (if not Accepted then P = P'Old)
       and then (for all J in Instance_Index =>
         (if I /= J then P.State (J) = P.State'Old (J)))
       and then (for all K in Natural range 0 .. Max_State - 1 =>
         (if K >= P.Config (I).State_Count then P.State (I) (K) = P.State'Old (I) (K)));
end MJ.Plugin_Runtime;
