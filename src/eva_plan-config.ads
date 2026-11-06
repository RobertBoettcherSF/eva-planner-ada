--  First-slice named bounds. Raise these later; do not hard-code the numbers
--  elsewhere.
pragma Assertion_Policy (Check);
pragma SPARK_Mode (On);

package Eva_Plan.Config is

   Max_Stations    : constant := 4;
   Max_POIs        : constant := 8;
   Max_Activities  : constant := 16;
   Max_Goals       : constant := 6;
   Max_Crew        : constant := 2;

   --  About 1.4 km/h.
   Walking_Speed_Mm_S : constant := 400;

   Max_Walkback_M : constant := 2000;

   --  Mean lunar radius used for sphere distance and bearing (Item 3).
   Moon_Radius_M : constant := 1_737_400;

   Max_Name : constant := 24;

end Eva_Plan.Config;
