--  Sphere and local-map distance and bearing. Plain Ada with checked
--  contracts; SPARK proof is a later item.
pragma Assertion_Policy (Check);

with Eva_Plan.Types;

package Eva_Plan.Geometry is

   --  Thousandths of a degree. South pole is -90_000.
   subtype Latitude_Milli  is Integer range -90_000 .. 90_000;
   subtype Longitude_Milli is Integer range -180_000 .. 180_000;

   --  Room for half a lunar great-circle (pi * Moon_Radius_M).
   Max_Arc_M : constant := 6_000_000;
   subtype Arc_Metres is Natural range 0 .. Max_Arc_M;

   function Sphere_Distance_M
     (Lat_1 : Latitude_Milli;
      Lon_1 : Longitude_Milli;
      Lat_2 : Latitude_Milli;
      Lon_2 : Longitude_Milli) return Arc_Metres
     with Post =>
       (if Lat_1 = Lat_2 and then Lon_1 = Lon_2 then
          Sphere_Distance_M'Result = 0);

   function Sphere_Bearing
     (Lat_1 : Latitude_Milli;
      Lon_1 : Longitude_Milli;
      Lat_2 : Latitude_Milli;
      Lon_2 : Longitude_Milli) return Types.Degrees
     with Post =>
       (if Lat_1 = Lat_2 and then Lon_1 = Lon_2 then
          Sphere_Bearing'Result = 0);

   function Planar_Distance_M
     (X_1, Y_1, X_2, Y_2 : Types.Metres) return Arc_Metres
     with Post =>
       (if X_1 = X_2 and then Y_1 = Y_2 then Planar_Distance_M'Result = 0);

   function Planar_Bearing
     (X_1, Y_1, X_2, Y_2 : Types.Metres) return Types.Degrees
     with Post =>
       (if X_1 = X_2 and then Y_1 = Y_2 then Planar_Bearing'Result = 0);

end Eva_Plan.Geometry;
