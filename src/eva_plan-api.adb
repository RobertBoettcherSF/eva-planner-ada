--  EVA Planner Ada — browser API body.
pragma Assertion_Policy (Check);
pragma SPARK_Mode (Off);

with Eva_Plan.Viz;

package body Eva_Plan.Api is

   procedure Init is
   begin
      Eva_Plan.Viz.Start (1);
   end Init;

   procedure Viz_Start (Seed : Interfaces.Unsigned_32) is
   begin
      Eva_Plan.Viz.Start (Seed);
   end Viz_Start;

   procedure Viz_Tick is
   begin
      Eva_Plan.Viz.Tick;
   end Viz_Tick;

   function Viz_Frame return System.Address is
   begin
      return Eva_Plan.Viz.Frame_Address;
   end Viz_Frame;

   function Viz_Width return Integer is
   begin
      return Eva_Plan.Viz.Frame_Width;
   end Viz_Width;

   function Viz_Height return Integer is
   begin
      return Eva_Plan.Viz.Frame_Height;
   end Viz_Height;

   function Version_Length return Integer is
   begin
      return Version_String'Length;
   end Version_Length;

   function Version_Byte (Offset : Integer) return Integer is
   begin
      if Offset < 1 or else Offset > Version_String'Length then
         return 0;
      end if;
      return Character'Pos (Version_String (Offset));
   end Version_Byte;

end Eva_Plan.Api;
