--  Invented height grid and slope stretch for walk time. Not a NASA DEM.
pragma Assertion_Policy (Check);

with Eva_Plan.Geometry;
with Eva_Plan.Types;

package Eva_Plan.Terrain is

   Cell_M : constant := 100;

   subtype Grid_X is Integer range -5 .. 5;
   subtype Grid_Y is Integer range -6 .. 2;

   --  Height in metres: 100 + 5 * cell_x + 3 * cell_y.
   subtype Height_M is Integer range 0 .. 200;

   function Height_At (X_M, Y_M : Types.Metres) return Height_M;

   --  |Δh| / planar distance as thousandths (1000 = 100% grade).
   function Grade_Milli
     (X_1, Y_1, X_2, Y_2 : Types.Metres;
      Distance           : Geometry.Arc_Metres) return Natural
     with Post => (if Distance = 0 then Grade_Milli'Result = 0);

   --  Each 10% grade adds 20% to the flat walk time.
   function Adjust_Seconds
     (Flat_S : Types.Seconds; Grade : Natural) return Types.Seconds
     with Post => (if Grade = 0 then Adjust_Seconds'Result = Flat_S);

end Eva_Plan.Terrain;
