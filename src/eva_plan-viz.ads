--  EVA Planner Ada — splash walk (Ada-drawn surface map; JS only blits).
--  Invented site. Not a NASA product. No NASA marks or copied maps.
pragma Assertion_Policy (Check);
--  SPARK_Mode Off: exposes System.Address frame pointer for WASM blit.
pragma SPARK_Mode (Off);

with Interfaces;
with System;

package Eva_Plan.Viz is

   Max_W : constant := 640;
   Max_H : constant := 400;

   subtype Pixel is Interfaces.Unsigned_32;  --  AABBGGRR canvas order
   type Pixel_Array is array (0 .. Max_W * Max_H - 1) of Pixel;

   Frame  : Pixel_Array := (others => 16#FF181410#);
   Width  : Natural := Max_W;
   Height : Natural := Max_H;

   procedure Start (Seed : Interfaces.Unsigned_32);
   procedure Tick;

   function Frame_Address return System.Address;
   function Frame_Width return Integer;
   function Frame_Height return Integer;

end Eva_Plan.Viz;
