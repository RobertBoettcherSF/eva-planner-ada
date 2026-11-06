pragma Assertion_Policy (Check);

with Ada.Numerics;
with Ada.Numerics.Elementary_Functions;
with Eva_Plan.Config;

package body Eva_Plan.Geometry is

   use Ada.Numerics;
   use Ada.Numerics.Elementary_Functions;

   function To_Radians (Milli : Integer) return Float is
   begin
      return Float (Milli) * Pi / 180_000.0;
   end To_Radians;

   function Clamp_Arc (Metres_F : Float) return Arc_Metres is
   begin
      if Metres_F <= 0.0 then
         return 0;
      elsif Metres_F >= Float (Max_Arc_M) then
         return Max_Arc_M;
      else
         return Arc_Metres (Integer (Metres_F));
      end if;
   end Clamp_Arc;

   function To_Compass (Radians : Float) return Types.Degrees is
      Deg : Float := Radians * 180.0 / Pi;
      N   : Integer;
   begin
      if Deg < 0.0 then
         Deg := Deg + 360.0;
      end if;
      if Deg >= 360.0 then
         Deg := Deg - 360.0;
      end if;
      N := Integer (Deg);
      if N = 360 then
         N := 0;
      end if;
      return Types.Degrees (N);
   end To_Compass;

   function Sphere_Distance_M
     (Lat_1 : Latitude_Milli;
      Lon_1 : Longitude_Milli;
      Lat_2 : Latitude_Milli;
      Lon_2 : Longitude_Milli) return Arc_Metres
   is
      Lat1  : constant Float := To_Radians (Lat_1);
      Lon1  : constant Float := To_Radians (Lon_1);
      Lat2  : constant Float := To_Radians (Lat_2);
      Lon2  : constant Float := To_Radians (Lon_2);
      D_Lat : constant Float := Lat2 - Lat1;
      D_Lon : constant Float := Lon2 - Lon1;
      A     : Float;
      Chord : Float;
   begin
      if Lat_1 = Lat_2 and then Lon_1 = Lon_2 then
         return 0;
      end if;

      A := Sin (D_Lat / 2.0) ** 2
        + Cos (Lat1) * Cos (Lat2) * (Sin (D_Lon / 2.0) ** 2);
      if A < 0.0 then
         A := 0.0;
      elsif A > 1.0 then
         A := 1.0;
      end if;

      Chord := 2.0 * Arctan (Sqrt (A), Sqrt (1.0 - A));
      return Clamp_Arc (Float (Config.Moon_Radius_M) * Chord);
   end Sphere_Distance_M;

   function Sphere_Bearing
     (Lat_1 : Latitude_Milli;
      Lon_1 : Longitude_Milli;
      Lat_2 : Latitude_Milli;
      Lon_2 : Longitude_Milli) return Types.Degrees
   is
      Lat1  : constant Float := To_Radians (Lat_1);
      Lat2  : constant Float := To_Radians (Lat_2);
      D_Lon : constant Float := To_Radians (Lon_2) - To_Radians (Lon_1);
      Y     : constant Float := Sin (D_Lon) * Cos (Lat2);
      X     : constant Float :=
        Cos (Lat1) * Sin (Lat2)
        - Sin (Lat1) * Cos (Lat2) * Cos (D_Lon);
   begin
      if Lat_1 = Lat_2 and then Lon_1 = Lon_2 then
         return 0;
      end if;
      return To_Compass (Arctan (Y, X));
   end Sphere_Bearing;

   function Planar_Distance_M
     (X_1, Y_1, X_2, Y_2 : Types.Metres) return Arc_Metres
   is
      DX : constant Float := Float (X_2 - X_1);
      DY : constant Float := Float (Y_2 - Y_1);
   begin
      if X_1 = X_2 and then Y_1 = Y_2 then
         return 0;
      end if;
      return Clamp_Arc (Sqrt (DX * DX + DY * DY));
   end Planar_Distance_M;

   function Planar_Bearing
     (X_1, Y_1, X_2, Y_2 : Types.Metres) return Types.Degrees
   is
      DX : constant Float := Float (X_2 - X_1);
      DY : constant Float := Float (Y_2 - Y_1);
   begin
      if X_1 = X_2 and then Y_1 = Y_2 then
         return 0;
      end if;
      --  0 = north (+Y), clockwise, so atan2(east, north).
      return To_Compass (Arctan (DX, DY));
   end Planar_Bearing;

end Eva_Plan.Geometry;
