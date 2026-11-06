--  Native checks for geometry, sample mission, timing, and terrain.
with Ada.Numerics;
with Ada.Text_IO; use Ada.Text_IO;
with Eva_Plan.Config;
with Eva_Plan.Execution;
with Eva_Plan.Geometry;
with Eva_Plan.Model;
with Eva_Plan.Science;
with Eva_Plan.Terrain;
with Eva_Plan.Timeline;
with Eva_Plan.Types;

procedure Eva_Plan_Driver is
   package C renames Eva_Plan.Config;
   package Ex  renames Eva_Plan.Execution;
   package G renames Eva_Plan.Geometry;
   package Mdl renames Eva_Plan.Model;
   package Sc  renames Eva_Plan.Science;
   package Tn renames Eva_Plan.Terrain;
   package Tl renames Eva_Plan.Timeline;
   package T renames Eva_Plan.Types;
   use type Tl.Event_Kind;
   use type Ex.Outcome;

   Expected_1_Deg : constant Integer :=
     Integer (2.0 * Ada.Numerics.Pi * Float (C.Moon_Radius_M) / 360.0);

   Sample : constant Mdl.Mission := Mdl.Sample;
   Plan   : constant Tl.Schedule := Tl.Plan_Of (Sample);
   Ev     : Tl.Event;
   Act    : T.Activity_Record;
   St     : T.Station_Record;
   From_S : T.Station_Record;
   To_S   : T.Station_Record;
   Grade  : Natural;
   Flat_S : T.Seconds;
   Walk_N : Natural := 0;

   function Img (N : Integer) return String is
      S : constant String := Integer'Image (N);
   begin
      return (if N < 0 then S else S (S'First + 1 .. S'Last));
   end Img;

   function Pad (S : String; W : Positive) return String is
     (if S'Length >= W then S (S'First .. S'First + W - 2) & " "
      else S & (1 .. W - S'Length => ' '));

   function LPad (S : String; W : Positive) return String is
     (if S'Length >= W then S else (1 .. W - S'Length => ' ') & S);

   function Pct (Milli : Natural) return String is
     (Img (Milli / 10) & "." & Img (Milli mod 10) & "%");
begin
   Put_Line ("EVA Planner Ada");
   pragma Assert
     (abs (Integer (G.Sphere_Distance_M (0, 0, 0, 1_000)) - Expected_1_Deg)
      <= 2);
   pragma Assert (G.Planar_Distance_M (0, 0, 3, 4) = 5);
   pragma Assert (Tl.Walk_Seconds (0) = 0);
   pragma Assert (Tl.Walk_Seconds (400) = 1000);
   pragma Assert (Tn.Height_At (0, 0) = 100);
   pragma Assert (Tn.Height_At (420, 90) = 123);
   pragma Assert (Tn.Height_At (80, -560) = 87);
   pragma Assert (Tn.Height_At (-380, 40) = 80);
   pragma Assert (Tn.Grade_Milli (0, 0, 0, 0, 0) = 0);
   pragma Assert (Tn.Adjust_Seconds (1000, 0) = 1000);
   pragma Assert (Tn.Adjust_Seconds (1000, 100) = 1200);

   --  Console tables (Item 11). All numbers come from Model, Terrain,
   --  Timeline, and Science. Lines between the markers feed the web page.
   Put_Line ("=== CONSOLE BEGIN ===");
   Put_Line ("TIMELINE  (walk 400 mm/s, slope-adjusted)");
   Put_Line (Pad ("Event", 26) & Pad ("Station", 14) & LPad ("m", 6)
             & LPad ("grade", 7) & LPad ("flat s", 8) & LPad ("dur s", 7)
             & LPad ("wall s", 8) & LPad ("end s", 8));
   declare
      Clock : Natural := 0;
   begin
      for Id in 1 .. Plan.Count loop
         Ev := Tl.Event_At (Plan, Id);
         Clock := Clock + Natural (Ev.Wall_Advance_S);
         if Ev.Kind = Tl.Walk_Event then
            Walk_N := Walk_N + 1;
            From_S := Mdl.Station (Sample, Ev.From_Station);
            To_S   := Mdl.Station (Sample, Ev.To_Station);
            Grade  := Tn.Grade_Milli
              (From_S.X_M, From_S.Y_M, To_S.X_M, To_S.Y_M, Ev.Distance_M);
            Flat_S := Tl.Walk_Seconds (Ev.Distance_M);
            Put_Line (Pad ("Walk to "
                           & T.Name_Of (To_S.Name, To_S.Length), 26)
                      & Pad ("-", 14)
                      & LPad (Img (Integer (Ev.Distance_M)), 6)
                      & LPad (Pct (Grade), 7)
                      & LPad (Img (Integer (Flat_S)), 8)
                      & LPad (Img (Integer (Ev.Duration_S)), 7)
                      & LPad (Img (Integer (Ev.Wall_Advance_S)), 8)
                      & LPad (Img (Clock), 8));
         else
            Act := Mdl.Activity (Sample, Ev.Activity);
            St  := Mdl.Station (Sample, Act.At_Station);
            Put_Line (Pad ("Dwell " & T.Name_Of (Act.Name, Act.Length)
                           & (if Ev.Parallel then " (par)" else ""), 26)
                      & Pad (T.Name_Of (St.Name, St.Length), 14)
                      & LPad ("-", 6) & LPad ("-", 7) & LPad ("-", 8)
                      & LPad (Img (Integer (Ev.Duration_S)), 7)
                      & LPad (Img (Integer (Ev.Wall_Advance_S)), 8)
                      & LPad (Img (Clock), 8));
         end if;
      end loop;
      pragma Assert (Clock = Natural (Plan.Total_S));
   end;
   Put_Line ("TOTAL EVA " & Img (Integer (Plan.Total_S)) & " s");
   pragma Assert (Walk_N = 4);
   pragma Assert (Plan.Total_S = 11_940);
   New_Line;

   declare
      Cov  : constant Sc.Coverage := Sc.Coverage_Of (Sample);
      Gl   : T.Goal_Record;
      Near : T.Station_Record;
      Dist : G.Arc_Metres;
      P    : T.POI_Record;
   begin
      Put_Line ("COVERAGE  (radius " & Img (Sc.Cover_Radius_M) & " m)");
      Put_Line (Pad ("Goal", 18) & Pad ("POI", 15) & Pad ("Nearest", 14)
                & LPad ("m", 5) & "  Status");
      for Id in 1 .. Sample.Goal_N loop
         Gl := Mdl.Goal (Sample, Id);
         P := Mdl.POI (Sample, Gl.At_POI);
         Near := Mdl.Station (Sample, Sc.Nearest_Station (Sample, Gl.At_POI));
         Dist := Sc.Distance_To_Nearest (Sample, Gl.At_POI);
         Put_Line (Pad (T.Name_Of (Gl.Name, Gl.Length), 18)
                   & Pad (T.Name_Of (P.Name, P.Length), 15)
                   & Pad (T.Name_Of (Near.Name, Near.Length), 14)
                   & LPad (Img (Integer (Dist)), 5) & "  "
                   & (if Sc.Is_Covered (Sample, Id) then "Covered"
                      else "Missed"));
      end loop;
      Put_Line ("COVERED " & Img (Integer (Cov.Covered_N)) & " of "
                & Img (Integer (Cov.Goal_N)));
      pragma Assert (Sample.Goal_N = 6);
      pragma Assert (Cov.Covered_N = 5);
      pragma Assert (Sc.Is_Covered (Sample, 1));
      pragma Assert (not Sc.Is_Covered (Sample, 4));
      pragma Assert (Sc.Distance_To_Nearest (Sample, 4) = 204);
   end;
   New_Line;

   declare
      Dist : G.Arc_Metres;
      Far  : constant G.Arc_Metres := Mdl.Home_Walkback_M (Sample, 2_500, 0);
   begin
      Put_Line ("WALKBACK  (limit " & Img (C.Max_Walkback_M) & " m to lander)");
      Put_Line (Pad ("Station", 14) & LPad ("h m", 5) & LPad ("home m", 8)
                & LPad ("margin", 8) & "  Flag");
      for Id in 1 .. Sample.Station_N loop
         St := Mdl.Station (Sample, Id);
         Dist := Mdl.Station_Walkback_M (Sample, Id);
         Put_Line (Pad (T.Name_Of (St.Name, St.Length), 14)
                   & LPad (Img (Tn.Height_At (St.X_M, St.Y_M)), 5)
                   & LPad (Img (Integer (Dist)), 8)
                   & LPad (Img (Integer (Mdl.Margin_M (Dist))), 8) & "  "
                   & (if Mdl.Over_Limit (Dist) then "OVER" else "OK"));
         pragma Assert (not Mdl.Over_Limit (Dist));
      end loop;
      Put_Line (Pad ("(test 2500 E)", 14) & LPad ("-", 5)
                & LPad (Img (Integer (Far)), 8)
                & LPad (Img (Integer (Mdl.Margin_M (Far))), 8) & "  "
                & (if Mdl.Over_Limit (Far) then "OVER" else "OK"));
      pragma Assert (Mdl.Station_Walkback_M (Sample, 1) = 0);
      pragma Assert (not Mdl.Over_Limit (0));
      pragma Assert (Far = 2_500);
      pragma Assert (Mdl.Over_Limit (Far));
      pragma Assert (Mdl.Margin_M (Far) = 0);
      pragma Assert (Mdl.Margin_M (430) = C.Max_Walkback_M - 430);
   end;
   Put_Line ("=== CONSOLE END ===");
   New_Line;

   declare
      Flown    : constant Ex.Run := Ex.Simulate (Sample);
      Nominal  : constant Ex.Run := Ex.Simulate (Sample, 0);
      Row      : Ex.Compare_Row;
      Label    : String (1 .. 24);
   begin
      for Id in 1 .. Flown.Count loop
         Row := Flown.Rows (Id);
         if Row.Kind = Tl.Walk_Event then
            Label := "walk                    ";
         else
            Act := Mdl.Activity (Sample, Row.Activity);
            declare
               N : constant String := T.Name_Of (Act.Name, Act.Length);
            begin
               Label := (others => ' ');
               Label (1 .. N'Length) := N;
            end;
         end if;
         Put_Line ("as-flown " & Label
                   & "  plan="
                   & Integer'Image (Integer (Row.Planned_Duration_S))
                   & "  flown="
                   & Integer'Image (Integer (Row.Flown_Duration_S))
                   & "  end_plan="
                   & Integer'Image (Integer (Row.Planned_End_S))
                   & "  end_flown="
                   & Integer'Image (Integer (Row.Flown_End_S))
                   & "  slip="
                   & Integer'Image (Row.Slip_S));
      end loop;
      Put_Line ("flown_total_s  ="
                & Integer'Image (Integer (Flown.Flown_Total_S))
                & "  slip="
                & Integer'Image (Flown.Slip_S)
                & "  ticks="
                & Integer'Image (Flown.Tick_N)
                & "  "
                & (if Flown.Status = Ex.Late then "Late" else "On_Time"));
      pragma Assert (Flown.Slip_S = 120);
      pragma Assert (Flown.Flown_Total_S = 12_060);
      pragma Assert (Flown.Tick_N = 12_060);
      pragma Assert (Flown.Status = Ex.Late);
      pragma Assert (Nominal.Slip_S = 0);
      pragma Assert (Nominal.Flown_Total_S = Nominal.Planned_Total_S);
      pragma Assert (Nominal.Status = Ex.On_Time);
      pragma Assert (Nominal.Tick_N = Integer (Nominal.Flown_Total_S));
   end;
end Eva_Plan_Driver;
