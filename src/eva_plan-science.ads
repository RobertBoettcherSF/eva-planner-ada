--  Science goals on POIs and a simple coverage radius. Invented site.
pragma Assertion_Policy (Check);

with Eva_Plan.Geometry;
with Eva_Plan.Model;
with Eva_Plan.Types;

package Eva_Plan.Science is

   Cover_Radius_M : constant := 150;

   type Flag_List is array (Types.Goal_Index) of Boolean;

   type Coverage is record
      Goal_N    : Types.Goal_Count := 0;
      Covered_N : Types.Goal_Count := 0;
      Flags     : Flag_List := (others => False);
   end record;

   function Nearest_Station
     (Of_Mission : Model.Mission; Poi : Types.POI_Index)
      return Types.Station_Index
     with Pre => Of_Mission.Station_N >= 1
                 and then Poi <= Of_Mission.POI_N;

   function Distance_To_Nearest
     (Of_Mission : Model.Mission; Poi : Types.POI_Index)
      return Geometry.Arc_Metres
     with Pre => Of_Mission.Station_N >= 1
                 and then Poi <= Of_Mission.POI_N;

   function Is_Covered
     (Of_Mission : Model.Mission; Id : Types.Goal_Index) return Boolean
     with Pre => Of_Mission.Station_N >= 1
                 and then Id <= Of_Mission.Goal_N;

   function Coverage_Of (Of_Mission : Model.Mission) return Coverage
     with Pre  => Of_Mission.Station_N >= 1,
          Post => Coverage_Of'Result.Goal_N = Of_Mission.Goal_N
                  and then Coverage_Of'Result.Covered_N
                    <= Coverage_Of'Result.Goal_N;

end Eva_Plan.Science;
