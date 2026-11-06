pragma Assertion_Policy (Check);


package body Eva_Plan.Model is

   procedure Set_Name
     (Buffer : out Types.Name_Buffer;
      Length : out Types.Name_Length;
      Text   : String)
   is
   begin
      pragma Assert (Text'Length <= Config.Max_Name);
      Buffer := (others => ' ');
      Length := Text'Length;
      for I in 1 .. Text'Length loop
         Buffer (I) := Text (Text'First + I - 1);
      end loop;
   end Set_Name;

   function Both return Types.Crew_Mask is
   begin
      return (True, True);
   end Both;

   function Only (Who : Types.Crew_Index) return Types.Crew_Mask is
      Mask : Types.Crew_Mask := (others => False);
   begin
      Mask (Who) := True;
      return Mask;
   end Only;

   function Sample return Mission is
      M : Mission;
   begin
      M.Station_N  := 4;
      M.POI_N      := 5;
      M.Activity_N := 8;
      M.Goal_N     := 6;
      M.Crew_N     := 2;

      M.Stations (1).Id := 1;
      M.Stations (1).X_M := 0;
      M.Stations (1).Y_M := 0;
      Set_Name (M.Stations (1).Name, M.Stations (1).Length, "Lander Pad");

      M.Stations (2).Id := 2;
      M.Stations (2).X_M := 420;
      M.Stations (2).Y_M := 90;
      Set_Name (M.Stations (2).Name, M.Stations (2).Length, "East Ridge");

      M.Stations (3).Id := 3;
      M.Stations (3).X_M := 80;
      M.Stations (3).Y_M := -560;
      Set_Name (M.Stations (3).Name, M.Stations (3).Length, "South Bench");

      M.Stations (4).Id := 4;
      M.Stations (4).X_M := -380;
      M.Stations (4).Y_M := 40;
      Set_Name (M.Stations (4).Name, M.Stations (4).Length, "West Notch");

      M.POIs (1).Id := 1;
      M.POIs (1).X_M := 380;
      M.POIs (1).Y_M := 140;
      Set_Name (M.POIs (1).Name, M.POIs (1).Length, "Split Boulder");

      M.POIs (2).Id := 2;
      M.POIs (2).X_M := 150;
      M.POIs (2).Y_M := -480;
      Set_Name (M.POIs (2).Name, M.POIs (2).Length, "Rim Shelf");

      M.POIs (3).Id := 3;
      M.POIs (3).X_M := -280;
      M.POIs (3).Y_M := 120;
      Set_Name (M.POIs (3).Name, M.POIs (3).Length, "Dark Hollow");

      M.POIs (4).Id := 4;
      M.POIs (4).X_M := 40;
      M.POIs (4).Y_M := -200;
      Set_Name (M.POIs (4).Name, M.POIs (4).Length, "Fine Soil");

      M.POIs (5).Id := 5;
      M.POIs (5).X_M := -90;
      M.POIs (5).Y_M := -40;
      Set_Name (M.POIs (5).Name, M.POIs (5).Length, "Shallow Pit");

      M.Crew (1).Id := 1;
      Set_Name (M.Crew (1).Name, M.Crew (1).Length, "Walker A");
      M.Crew (2).Id := 2;
      Set_Name (M.Crew (2).Name, M.Crew (2).Length, "Walker B");


      M.Goals (1).Id := 1;
      M.Goals (1).At_POI := 1;
      Set_Name (M.Goals (1).Name, M.Goals (1).Length, "Document boulder");

      M.Goals (2).Id := 2;
      M.Goals (2).At_POI := 2;
      Set_Name (M.Goals (2).Name, M.Goals (2).Length, "Sample rim");

      M.Goals (3).Id := 3;
      M.Goals (3).At_POI := 3;
      Set_Name (M.Goals (3).Name, M.Goals (3).Length, "Inspect hollow");

      M.Goals (4).Id := 4;
      M.Goals (4).At_POI := 4;
      Set_Name (M.Goals (4).Name, M.Goals (4).Length, "Collect fines");

      M.Goals (5).Id := 5;
      M.Goals (5).At_POI := 5;
      Set_Name (M.Goals (5).Name, M.Goals (5).Length, "Photo pit");

      M.Goals (6).Id := 6;
      M.Goals (6).At_POI := 1;
      Set_Name (M.Goals (6).Name, M.Goals (6).Length, "Boulder context");

      M.Activities (1).Id := 1;
      M.Activities (1).At_Station := 1;
      M.Activities (1).Dwell_S := 600;
      M.Activities (1).Assigned := Both;
      Set_Name (M.Activities (1).Name, M.Activities (1).Length, "Egress");

      M.Activities (2).Id := 2;
      M.Activities (2).At_Station := 1;
      M.Activities (2).Dwell_S := 180;
      M.Activities (2).Assigned := Both;
      Set_Name (M.Activities (2).Name, M.Activities (2).Length, "Site brief");

      M.Activities (3).Id := 3;
      M.Activities (3).At_Station := 2;
      M.Activities (3).Dwell_S := 900;
      M.Activities (3).Assigned := Both;
      Set_Name (M.Activities (3).Name, M.Activities (3).Length, "Ridge photos");

      M.Activities (4).Id := 4;
      M.Activities (4).At_Station := 2;
      M.Activities (4).Dwell_S := 1200;
      M.Activities (4).Assigned := Only (1);
      Set_Name (M.Activities (4).Name, M.Activities (4).Length, "Ridge rake");

      M.Activities (5).Id := 5;
      M.Activities (5).At_Station := 2;
      M.Activities (5).Dwell_S := 480;
      M.Activities (5).Assigned := Only (2);
      Set_Name (M.Activities (5).Name, M.Activities (5).Length, "Ridge context");

      M.Activities (6).Id := 6;
      M.Activities (6).At_Station := 3;
      M.Activities (6).Dwell_S := 1500;
      M.Activities (6).Assigned := Both;
      Set_Name (M.Activities (6).Name, M.Activities (6).Length, "Bench sample");

      M.Activities (7).Id := 7;
      M.Activities (7).At_Station := 4;
      M.Activities (7).Dwell_S := 900;
      M.Activities (7).Assigned := Both;
      Set_Name (M.Activities (7).Name, M.Activities (7).Length, "Notch inspect");

      M.Activities (8).Id := 8;
      M.Activities (8).At_Station := 1;
      M.Activities (8).Dwell_S := 480;
      M.Activities (8).Assigned := Both;
      Set_Name (M.Activities (8).Name, M.Activities (8).Length, "Closeout");

      return M;
   end Sample;

   function Station
     (Of_Mission : Mission; Id : Types.Station_Index)
      return Types.Station_Record
   is
   begin
      return Of_Mission.Stations (Id);
   end Station;

   function POI
     (Of_Mission : Mission; Id : Types.POI_Index) return Types.POI_Record
   is
   begin
      return Of_Mission.POIs (Id);
   end POI;

   function Activity
     (Of_Mission : Mission; Id : Types.Activity_Index)
      return Types.Activity_Record
   is
   begin
      return Of_Mission.Activities (Id);
   end Activity;

   function Goal
     (Of_Mission : Mission; Id : Types.Goal_Index) return Types.Goal_Record
   is
   begin
      return Of_Mission.Goals (Id);
   end Goal;

   function Crew_Member
     (Of_Mission : Mission; Id : Types.Crew_Index) return Types.Crew_Record
   is
   begin
      return Of_Mission.Crew (Id);
   end Crew_Member;


   function Home_Walkback_M
     (Of_Mission : Mission; X_M, Y_M : Types.Metres)
      return Geometry.Arc_Metres
   is
      Home : constant Types.Station_Record := Station (Of_Mission, 1);
   begin
      return Geometry.Planar_Distance_M (X_M, Y_M, Home.X_M, Home.Y_M);
   end Home_Walkback_M;

   function Station_Walkback_M
     (Of_Mission : Mission; Id : Types.Station_Index)
      return Geometry.Arc_Metres
   is
      St : constant Types.Station_Record := Station (Of_Mission, Id);
   begin
      return Home_Walkback_M (Of_Mission, St.X_M, St.Y_M);
   end Station_Walkback_M;

   function Over_Limit (Distance : Geometry.Arc_Metres) return Boolean is
   begin
      return Distance > Config.Max_Walkback_M;
   end Over_Limit;

   function Margin_M (Distance : Geometry.Arc_Metres) return Geometry.Arc_Metres is
   begin
      if Distance >= Config.Max_Walkback_M then
         return 0;
      else
         return Config.Max_Walkback_M - Distance;
      end if;
   end Margin_M;

end Eva_Plan.Model;
