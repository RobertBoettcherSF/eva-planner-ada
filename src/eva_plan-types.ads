--  Range-bounded IDs, units, and fixed records for the first slice.
pragma Assertion_Policy (Check);
pragma SPARK_Mode (On);

with Eva_Plan.Config;

package Eva_Plan.Types is

   subtype Station_Index   is Positive range 1 .. Config.Max_Stations;
   subtype POI_Index       is Positive range 1 .. Config.Max_POIs;
   subtype Activity_Index  is Positive range 1 .. Config.Max_Activities;
   subtype Goal_Index      is Positive range 1 .. Config.Max_Goals;
   subtype Crew_Index      is Positive range 1 .. Config.Max_Crew;

   subtype Station_Count   is Natural range 0 .. Config.Max_Stations;
   subtype POI_Count       is Natural range 0 .. Config.Max_POIs;
   subtype Activity_Count  is Natural range 0 .. Config.Max_Activities;
   subtype Goal_Count      is Natural range 0 .. Config.Max_Goals;
   subtype Crew_Count      is Natural range 0 .. Config.Max_Crew;

   --  Local-map and sphere lengths in whole metres.
   subtype Metres is Integer range -1_000_000 .. 1_000_000;
   subtype Metres_0 is Metres range 0 .. Metres'Last;

   --  Durations in whole seconds.
   subtype Seconds is Natural;

   --  Compass bearing, 0 .. 359, 0 = north, clockwise.
   subtype Degrees is Natural range 0 .. 359;

   subtype Name_Length is Natural range 0 .. Config.Max_Name;
   type Name_Buffer is array (Positive range 1 .. Config.Max_Name) of Character;

   type Crew_Mask is array (Crew_Index) of Boolean;

   type Station_Record is record
      Id     : Station_Index := Station_Index'First;
      X_M    : Metres := 0;
      Y_M    : Metres := 0;
      Name   : Name_Buffer := (others => ' ');
      Length : Name_Length := 0;
   end record;

   type POI_Record is record
      Id     : POI_Index := POI_Index'First;
      X_M    : Metres := 0;
      Y_M    : Metres := 0;
      Name   : Name_Buffer := (others => ' ');
      Length : Name_Length := 0;
   end record;

   type Activity_Record is record
      Id          : Activity_Index := Activity_Index'First;
      At_Station  : Station_Index := Station_Index'First;
      Dwell_S     : Seconds := 0;
      Assigned    : Crew_Mask := (others => True);
      Name        : Name_Buffer := (others => ' ');
      Length      : Name_Length := 0;
   end record;

   type Goal_Record is record
      Id     : Goal_Index := Goal_Index'First;
      At_POI : POI_Index := POI_Index'First;
      Name   : Name_Buffer := (others => ' ');
      Length : Name_Length := 0;
   end record;

   type Crew_Record is record
      Id     : Crew_Index := Crew_Index'First;
      Name   : Name_Buffer := (others => ' ');
      Length : Name_Length := 0;
   end record;

   function Name_Of (Buffer : Name_Buffer; Length : Name_Length) return String
     with Pre => Length <= Buffer'Length,
          Post => Name_Of'Result'Length = Length;

end Eva_Plan.Types;
