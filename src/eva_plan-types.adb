pragma Assertion_Policy (Check);
pragma SPARK_Mode (On);

package body Eva_Plan.Types is

   function Name_Of (Buffer : Name_Buffer; Length : Name_Length) return String is
      Result : String (1 .. Length);
   begin
      for I in 1 .. Length loop
         Result (I) := Buffer (I);
      end loop;
      return Result;
   end Name_Of;

end Eva_Plan.Types;
