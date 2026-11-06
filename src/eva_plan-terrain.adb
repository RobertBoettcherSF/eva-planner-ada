pragma Assertion_Policy (Check);

package body Eva_Plan.Terrain is

   function Clamp_X (Cell : Integer) return Grid_X is
   begin
      if Cell < Grid_X'First then
         return Grid_X'First;
      elsif Cell > Grid_X'Last then
         return Grid_X'Last;
      else
         return Cell;
      end if;
   end Clamp_X;

   function Clamp_Y (Cell : Integer) return Grid_Y is
   begin
      if Cell < Grid_Y'First then
         return Grid_Y'First;
      elsif Cell > Grid_Y'Last then
         return Grid_Y'Last;
      else
         return Cell;
      end if;
   end Clamp_Y;

   function Nearest_X (X_M : Types.Metres) return Grid_X is
   begin
      return Clamp_X (Integer (Float (X_M) / Float (Cell_M)));
   end Nearest_X;

   function Nearest_Y (Y_M : Types.Metres) return Grid_Y is
   begin
      return Clamp_Y (Integer (Float (Y_M) / Float (Cell_M)));
   end Nearest_Y;

   function Height_At (X_M, Y_M : Types.Metres) return Height_M is
      GX : constant Grid_X := Nearest_X (X_M);
      GY : constant Grid_Y := Nearest_Y (Y_M);
   begin
      return 100 + 5 * GX + 3 * GY;
   end Height_At;

   function Grade_Milli
     (X_1, Y_1, X_2, Y_2 : Types.Metres;
      Distance           : Geometry.Arc_Metres) return Natural
   is
      Dh : Integer;
   begin
      if Distance = 0 then
         return 0;
      end if;
      Dh := abs (Height_At (X_2, Y_2) - Height_At (X_1, Y_1));
      return Natural (Dh * 1000 / Integer (Distance));
   end Grade_Milli;

   function Adjust_Seconds
     (Flat_S : Types.Seconds; Grade : Natural) return Types.Seconds
   is
      Stretch : constant Long_Integer :=
        1000 + 2 * Long_Integer (Grade);
   begin
      return Types.Seconds
        (Long_Integer (Flat_S) * Stretch / 1000);
   end Adjust_Seconds;

end Eva_Plan.Terrain;
