--  EVA Planner Ada — C-exported surface for the browser splash page.
pragma Assertion_Policy (Check);
--  SPARK_Mode Off: C Export / Interfaces / System.Address WASM glue.
pragma SPARK_Mode (Off);

with Interfaces;
with System;

package Eva_Plan.Api is

   Version_String : constant String := "0.2.0";

   procedure Init
     with Export, Convention => C, External_Name => "eva_init";

   procedure Viz_Start (Seed : Interfaces.Unsigned_32)
     with Export, Convention => C, External_Name => "eva_viz_start";

   procedure Viz_Tick
     with Export, Convention => C, External_Name => "eva_viz_tick";

   function Viz_Frame return System.Address
     with Export, Convention => C, External_Name => "eva_viz_frame";

   function Viz_Width return Integer
     with Export, Convention => C, External_Name => "eva_viz_width";

   function Viz_Height return Integer
     with Export, Convention => C, External_Name => "eva_viz_height";

   function Version_Length return Integer
     with Export, Convention => C, External_Name => "eva_version_len";

   function Version_Byte (Offset : Integer) return Integer
     with Export, Convention => C, External_Name => "eva_version_byte";

end Eva_Plan.Api;
