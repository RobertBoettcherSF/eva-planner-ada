pragma Assertion_Policy (Check);

with Eva_Plan.Terrain;

package body Eva_Plan.Timeline is

   function Walk_Seconds (Distance : Geometry.Arc_Metres) return Types.Seconds is
      Num : constant Long_Integer :=
        Long_Integer (Distance) * 1000;
   begin
      return Types.Seconds (Num / Long_Integer (Config.Walking_Speed_Mm_S));
   end Walk_Seconds;

   function Shares
     (Left, Right : Types.Crew_Mask) return Boolean
   is
   begin
      for Who in Types.Crew_Index loop
         if Left (Who) and then Right (Who) then
            return True;
         end if;
      end loop;
      return False;
   end Shares;

   function Plan_Of (Of_Mission : Model.Mission) return Schedule is
      Result   : Schedule;
      Clock_S  : Types.Seconds := 0;
      Prev_Act : Types.Activity_Record;
      Act      : Types.Activity_Record;
      From_St  : Types.Station_Record;
      To_St    : Types.Station_Record;
      Dist     : Geometry.Arc_Metres;
      Walk_S   : Types.Seconds;
      Item     : Event;
   begin
      for Id in 1 .. Of_Mission.Activity_N loop
         Act := Model.Activity (Of_Mission, Id);

         if Id > 1 then
            Prev_Act := Model.Activity (Of_Mission, Id - 1);
            if Act.At_Station /= Prev_Act.At_Station then
               From_St := Model.Station (Of_Mission, Prev_Act.At_Station);
               To_St   := Model.Station (Of_Mission, Act.At_Station);
               Dist    := Geometry.Planar_Distance_M
                 (From_St.X_M, From_St.Y_M, To_St.X_M, To_St.Y_M);
               Walk_S  := Terrain.Adjust_Seconds
                 (Walk_Seconds (Dist),
                  Terrain.Grade_Milli
                    (From_St.X_M, From_St.Y_M, To_St.X_M, To_St.Y_M, Dist));
               Result.Count := Result.Count + 1;
               Result.Events (Result.Count) :=
                 (Kind           => Walk_Event,
                  From_Station   => Prev_Act.At_Station,
                  To_Station     => Act.At_Station,
                  Activity       => Act.Id,
                  Distance_M     => Dist,
                  Duration_S     => Walk_S,
                  Wall_Advance_S => Walk_S,
                  Parallel       => False);
               Clock_S := Clock_S + Walk_S;
            end if;
         end if;

         Item :=
           (Kind           => Dwell_Event,
            From_Station   => Act.At_Station,
            To_Station     => Act.At_Station,
            Activity       => Act.Id,
            Distance_M     => 0,
            Duration_S     => Act.Dwell_S,
            Wall_Advance_S => Act.Dwell_S,
            Parallel       => False);

         if Id > 1 then
            Prev_Act := Model.Activity (Of_Mission, Id - 1);
            if Act.At_Station = Prev_Act.At_Station
              and then not Shares (Act.Assigned, Prev_Act.Assigned)
            then
               Item.Parallel := True;
               if Act.Dwell_S > Prev_Act.Dwell_S then
                  Item.Wall_Advance_S := Act.Dwell_S - Prev_Act.Dwell_S;
               else
                  Item.Wall_Advance_S := 0;
               end if;
            end if;
         end if;

         Result.Count := Result.Count + 1;
         Result.Events (Result.Count) := Item;
         Clock_S := Clock_S + Item.Wall_Advance_S;
      end loop;

      Result.Total_S := Clock_S;
      return Result;
   end Plan_Of;

   function Event_At
     (Of_Schedule : Schedule; Id : Event_Index) return Event
   is
   begin
      return Of_Schedule.Events (Id);
   end Event_At;

end Eva_Plan.Timeline;
