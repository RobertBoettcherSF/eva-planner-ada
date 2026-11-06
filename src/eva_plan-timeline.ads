--  Walk and dwell timing for one EVA. Walk seconds include slope stretch.
pragma Assertion_Policy (Check);

with Eva_Plan.Config;
with Eva_Plan.Geometry;
with Eva_Plan.Model;
with Eva_Plan.Types;

package Eva_Plan.Timeline is

   Max_Events : constant := Config.Max_Activities * 2;
   subtype Event_Index is Positive range 1 .. Max_Events;
   subtype Event_Count is Natural range 0 .. Max_Events;

   type Event_Kind is (Walk_Event, Dwell_Event);

   type Event is record
      Kind          : Event_Kind := Dwell_Event;
      From_Station  : Types.Station_Index := Types.Station_Index'First;
      To_Station    : Types.Station_Index := Types.Station_Index'First;
      Activity      : Types.Activity_Index := Types.Activity_Index'First;
      Distance_M    : Geometry.Arc_Metres := 0;
      Duration_S    : Types.Seconds := 0;
      Wall_Advance_S : Types.Seconds := 0;
      Parallel      : Boolean := False;
   end record;

   type Event_List is array (Event_Index) of Event;

   type Schedule is record
      Count   : Event_Count := 0;
      Total_S : Types.Seconds := 0;
      Events  : Event_List;
   end record;

   function Walk_Seconds (Distance : Geometry.Arc_Metres) return Types.Seconds
     with Post => (if Distance = 0 then Walk_Seconds'Result = 0);

   function Plan_Of (Of_Mission : Model.Mission) return Schedule
     with Pre => Of_Mission.Activity_N >= 1
                 and then Of_Mission.Station_N >= 1;

   function Event_At
     (Of_Schedule : Schedule; Id : Event_Index) return Event
     with Pre => Id <= Of_Schedule.Count;

end Eva_Plan.Timeline;
