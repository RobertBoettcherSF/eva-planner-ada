pragma Assertion_Policy (Check);

package body Eva_Plan.Execution is

   use type Timeline.Event_Kind;

   function Simulate
     (Of_Mission : Model.Mission;
      Extra_Slip : Types.Seconds := Default_Slip_S) return Run
   is
      Plan     : constant Timeline.Schedule := Timeline.Plan_Of (Of_Mission);
      Result   : Run;
      Ev       : Timeline.Event;
      Planned  : Types.Seconds := 0;
      Flown    : Types.Seconds := 0;
      F_Dur    : Types.Seconds;
      F_Wall   : Types.Seconds;
      Row      : Compare_Row;
   begin
      Result.Count := Plan.Count;
      Result.Planned_Total_S := Plan.Total_S;

      for Id in 1 .. Plan.Count loop
         Ev := Timeline.Event_At (Plan, Id);
         F_Dur := Ev.Duration_S;
         F_Wall := Ev.Wall_Advance_S;

         if Ev.Kind = Timeline.Dwell_Event
           and then Ev.Activity = Slipped_Activity
         then
            F_Dur := Ev.Duration_S + Extra_Slip;
            F_Wall := Ev.Wall_Advance_S + Extra_Slip;
         end if;

         Planned := Planned + Ev.Wall_Advance_S;
         Flown   := Flown + F_Wall;

         for Tick in 1 .. F_Wall loop
            Result.Tick_N := Result.Tick_N + 1;
         end loop;

         Row :=
           (Kind               => Ev.Kind,
            Activity           => Ev.Activity,
            Planned_Duration_S => Ev.Duration_S,
            Flown_Duration_S   => F_Dur,
            Planned_End_S      => Planned,
            Flown_End_S        => Flown,
            Slip_S             => Integer (Flown) - Integer (Planned));
         Result.Rows (Id) := Row;
      end loop;

      Result.Flown_Total_S := Flown;
      Result.Slip_S := Integer (Flown) - Integer (Plan.Total_S);
      if Result.Flown_Total_S > Result.Planned_Total_S then
         Result.Status := Late;
      else
         Result.Status := On_Time;
      end if;
      return Result;
   end Simulate;

end Eva_Plan.Execution;
