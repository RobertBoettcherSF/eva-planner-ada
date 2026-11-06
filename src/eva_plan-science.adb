pragma Assertion_Policy (Check);

package body Eva_Plan.Science is

   function Nearest_Station
     (Of_Mission : Model.Mission; Poi : Types.POI_Index)
      return Types.Station_Index
   is
      P      : constant Types.POI_Record := Model.POI (Of_Mission, Poi);
      Best   : Types.Station_Index := 1;
      Best_D : Geometry.Arc_Metres := Geometry.Arc_Metres'Last;
      St     : Types.Station_Record;
      Dist   : Geometry.Arc_Metres;
   begin
      for Id in 1 .. Of_Mission.Station_N loop
         St := Model.Station (Of_Mission, Id);
         Dist := Geometry.Planar_Distance_M (P.X_M, P.Y_M, St.X_M, St.Y_M);
         if Dist < Best_D then
            Best_D := Dist;
            Best   := Id;
         end if;
      end loop;
      return Best;
   end Nearest_Station;

   function Distance_To_Nearest
     (Of_Mission : Model.Mission; Poi : Types.POI_Index)
      return Geometry.Arc_Metres
   is
      P  : constant Types.POI_Record := Model.POI (Of_Mission, Poi);
      St : constant Types.Station_Record :=
        Model.Station (Of_Mission, Nearest_Station (Of_Mission, Poi));
   begin
      return Geometry.Planar_Distance_M (P.X_M, P.Y_M, St.X_M, St.Y_M);
   end Distance_To_Nearest;

   function Is_Covered
     (Of_Mission : Model.Mission; Id : Types.Goal_Index) return Boolean
   is
      G : constant Types.Goal_Record := Model.Goal (Of_Mission, Id);
   begin
      return Distance_To_Nearest (Of_Mission, G.At_POI) <= Cover_Radius_M;
   end Is_Covered;

   function Coverage_Of (Of_Mission : Model.Mission) return Coverage is
      Result : Coverage;
   begin
      Result.Goal_N := Of_Mission.Goal_N;
      for Id in 1 .. Of_Mission.Goal_N loop
         Result.Flags (Id) := Is_Covered (Of_Mission, Id);
         if Result.Flags (Id) then
            Result.Covered_N := Result.Covered_N + 1;
         end if;
      end loop;
      return Result;
   end Coverage_Of;

end Eva_Plan.Science;
