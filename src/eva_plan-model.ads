--  Bounded one-mission, one-EVA sample. Invented site, not a NASA map.
pragma Assertion_Policy (Check);

with Eva_Plan.Config;
with Eva_Plan.Geometry;
with Eva_Plan.Types;

package Eva_Plan.Model is

   type Station_List  is array (Types.Station_Index) of Types.Station_Record;
   type POI_List      is array (Types.POI_Index) of Types.POI_Record;
   type Activity_List is array (Types.Activity_Index) of Types.Activity_Record;
   type Goal_List     is array (Types.Goal_Index) of Types.Goal_Record;
   type Crew_List     is array (Types.Crew_Index) of Types.Crew_Record;

   type Mission is record
      Station_N  : Types.Station_Count  := 0;
      POI_N      : Types.POI_Count      := 0;
      Activity_N : Types.Activity_Count := 0;
      Goal_N     : Types.Goal_Count     := 0;
      Crew_N     : Types.Crew_Count     := 0;
      Stations   : Station_List;
      POIs       : POI_List;
      Activities : Activity_List;
      Goals      : Goal_List;
      Crew       : Crew_List;
   end record;

   function Sample return Mission
     with Post =>
       Sample'Result.Station_N = 4
       and then Sample'Result.POI_N = 5
       and then Sample'Result.Activity_N = 8
       and then Sample'Result.Goal_N = 6
       and then Sample'Result.Crew_N = 2
       and then Sample'Result.Stations (1).X_M = 0
       and then Sample'Result.Stations (1).Y_M = 0;

   function Station
     (Of_Mission : Mission; Id : Types.Station_Index)
      return Types.Station_Record
     with Pre  => Id <= Of_Mission.Station_N,
          Post => Station'Result.Id = Id;

   function POI
     (Of_Mission : Mission; Id : Types.POI_Index) return Types.POI_Record
     with Pre  => Id <= Of_Mission.POI_N,
          Post => POI'Result.Id = Id;

   function Activity
     (Of_Mission : Mission; Id : Types.Activity_Index)
      return Types.Activity_Record
     with Pre  => Id <= Of_Mission.Activity_N,
          Post => Activity'Result.Id = Id
                  and then Activity'Result.At_Station <= Of_Mission.Station_N;

   function Goal
     (Of_Mission : Mission; Id : Types.Goal_Index) return Types.Goal_Record
     with Pre  => Id <= Of_Mission.Goal_N,
          Post => Goal'Result.Id = Id
                  and then Goal'Result.At_POI <= Of_Mission.POI_N;

   function Crew_Member
     (Of_Mission : Mission; Id : Types.Crew_Index) return Types.Crew_Record
     with Pre  => Id <= Of_Mission.Crew_N,
          Post => Crew_Member'Result.Id = Id;


   function Home_Walkback_M
     (Of_Mission : Mission; X_M, Y_M : Types.Metres)
      return Geometry.Arc_Metres
     with Pre => Of_Mission.Station_N >= 1;

   function Station_Walkback_M
     (Of_Mission : Mission; Id : Types.Station_Index)
      return Geometry.Arc_Metres
     with Pre => Of_Mission.Station_N >= 1
                 and then Id <= Of_Mission.Station_N,
          Post =>
            (if Id = 1 then Station_Walkback_M'Result = 0);

   function Over_Limit (Distance : Geometry.Arc_Metres) return Boolean
     with Post => Over_Limit'Result = (Distance > Config.Max_Walkback_M);

   function Margin_M (Distance : Geometry.Arc_Metres) return Geometry.Arc_Metres
     with Post =>
       (if Distance >= Config.Max_Walkback_M then Margin_M'Result = 0
        else Margin_M'Result = Config.Max_Walkback_M - Distance);

end Eva_Plan.Model;
