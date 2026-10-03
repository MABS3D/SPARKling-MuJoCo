package body MJ.Plugin_Runtime with SPARK_Mode is
   procedure Call (P : in out Runtime; I : Instance_Index; H : Hook;
                   Kind : Capability; F : Frame; Accepted : out Boolean) is
      N : constant Natural := P.Config (I).State_Count;
      S : Values (0 .. Integer (N) - 1) := [others => 0.0];
      O : Outputs := P.Output;
   begin
      for K in S'Range loop S (K) := P.State (I) (K); end loop;
      Invoke (H, Kind, I, P.Config (I), F, S, O, Accepted);
      if not Accepted then return; end if;
      for K in S'Range loop
         pragma Loop_Invariant (P.Ready = P.Ready'Loop_Entry and then P.Count = P.Count'Loop_Entry
           and then P.Config = P.Config'Loop_Entry);
         pragma Loop_Invariant (for all J in Instance_Index =>
           (if J /= I then P.State (J) = P.State'Loop_Entry (J)));
         pragma Loop_Invariant (for all J in Natural range 0 .. Max_State - 1 =>
           (if J >= K then P.State (I) (J) = P.State'Loop_Entry (I) (J)));
         P.State (I) (K) := S (K);
      end loop;
      P.Output := O;
   end Call;
   procedure Create (P : in out Runtime; Config : Configurations; F : Frame; Status : out Result) is
      Candidate : Runtime;
      Ok : Boolean;
   begin
      if P.Ready then Status := Already_Initialized; return; end if;
      if Config'First /= 0 or else Config'Length > Max_Instances then Status := Invalid_Config; return; end if;
      Candidate.Count := Config'Length;
      for I in Config'Range loop
         pragma Loop_Invariant (Candidate.Count = Config'Length);
         Candidate.Config (I) := Config (I);
         Call (Candidate, I, Initialize, Passive, F, Ok);
         if not Ok then
            for J in 0 .. I - 1 loop Call (Candidate, J, Destroy, Passive, F, Ok); end loop;
            Status := Callback_Failure; return;
         end if;
      end loop;
      Candidate.Ready := True;
      Reset (Candidate, F, Status);
      if Status /= Success then Free (Candidate, F, Status); Status := Callback_Failure; return; end if;
      P := Candidate;
   end Create;
   procedure Free (P : in out Runtime; F : Frame; Status : out Result) is
      Ok : Boolean;
   begin
      Status := Success;
      if P.Ready then
         for I in 0 .. P.Count - 1 loop
            Call (P, I, Destroy, Passive, F, Ok);
            if not Ok then Status := Callback_Failure; end if;
         end loop;
      end if;
      P := (others => <>);
   end Free;
   procedure Reset (P : in out Runtime; F : Frame; Status : out Result) is
      Candidate : Runtime := P;
      Ok : Boolean;
   begin
      if not P.Ready then Status := Not_Initialized; return; end if;
      Candidate.Output := (others => <>);
      for I in 0 .. P.Count - 1 loop
         pragma Loop_Invariant (Candidate.Ready = P.Ready and then Candidate.Count = P.Count
           and then Candidate.Config = P.Config);
         Call (Candidate, I, MJ.Plugin_Protocol.Reset, Passive, F, Ok);
         if not Ok then Status := Callback_Failure; return; end if;
      end loop;
      P := Candidate; Status := Success;
   end Reset;
   procedure Copy (Source : Runtime; Dest : in out Runtime; F : Frame; Status : out Result) is
      Candidate : Runtime := Source;
      Ok : Boolean;
   begin
      if not Source.Ready then Status := Not_Initialized; return; end if;
      for I in 0 .. Source.Count - 1 loop
         pragma Loop_Invariant (Candidate.Ready = Source.Ready
           and then Candidate.Count = Source.Count
           and then Candidate.Config = Source.Config);
         Call (Candidate, I, MJ.Plugin_Protocol.Copy, Passive, F, Ok);
         if not Ok then Status := Callback_Failure; return; end if;
      end loop;
      Dest := Candidate; Status := Success;
   end Copy;
   procedure Dispatch (P : in out Runtime; H : Hook; Kind : Capability;
                       Requested : Stage; F : Frame; Status : out Result) is
      Candidate : Runtime := P;
      Ok : Boolean;
   begin
      if not P.Ready then Status := Not_Initialized; return; end if;
      for I in 0 .. P.Count - 1 loop
         if Eligible (P.Config (I), H, Kind, Requested) then
            Call (Candidate, I, H, Kind, F, Ok);
            if not Ok then Status := Callback_Failure; return; end if;
         end if;
         pragma Loop_Invariant (Candidate.Ready = P.Ready and then Candidate.Count = P.Count
           and then Candidate.Config = P.Config);
         pragma Loop_Invariant (for all J in Instance_Index =>
           (if J > I or else not Eligible (P.Config (J), H, Kind, Requested)
            then Candidate.State (J) = P.State (J)));
      end loop;
      P := Candidate; Status := Success;
   end Dispatch;
   procedure Query (P : in out Runtime; Instance : Natural; H : Hook; F : Frame; Status : out Result) is
   begin
      if not P.Ready then Status := Not_Initialized;
      elsif Instance >= P.Count then Status := Invalid_Config;
      elsif not Has (P.Config (Instance).Capabilities, SDF) then Status := Unsupported;
      else
         declare
            Ok : Boolean;
         begin
            Call (P, Instance, H, SDF, F, Ok);
            Status := (if Ok then Success else Callback_Failure);
         end;
      end if;
   end Query;
end MJ.Plugin_Runtime;
