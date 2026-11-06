--  Cyclic one-second clock comparing as-flown time with the plan.
pragma Assertion_Policy (Check);

with Eva_Plan.Model;
with Eva_Plan.Timeline;
with Eva_Plan.Types;

package Eva_Plan.Execution is

   --  Invented extra time on activity 3 (Ridge photos) in the sample.
   Default_Slip_S     : constant := 120;
   Slipped_Activity   : constant Types.Activity_Index := 3;

   type Outcome is (On_Time, Late);

   type Compare_Row is record
      Kind               : Timeline.Event_Kind := Timeline.Dwell_Event;
      Activity           : Types.Activity_Index := Types.Activity_Index'First;
      Planned_Duration_S : Types.Seconds := 0;
      Flown_Duration_S   : Types.Seconds := 0;
      Planned_End_S      : Types.Seconds := 0;
      Flown_End_S        : Types.Seconds := 0;
      Slip_S             : Integer := 0;
   end record;

   type Compare_List is array (Timeline.Event_Index) of Compare_Row;

   type Run is record
      Count           : Timeline.Event_Count := 0;
      Planned_Total_S : Types.Seconds := 0;
      Flown_Total_S   : Types.Seconds := 0;
      Slip_S          : Integer := 0;
      Tick_N          : Natural := 0;
      Status          : Outcome := On_Time;
      Rows            : Compare_List;
   end record;

   function Simulate
     (Of_Mission : Model.Mission;
      Extra_Slip : Types.Seconds := Default_Slip_S) return Run
     with Pre => Of_Mission.Activity_N >= 1
                 and then Of_Mission.Station_N >= 1;

end Eva_Plan.Execution;
