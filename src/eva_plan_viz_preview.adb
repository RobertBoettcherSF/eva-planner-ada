--  Native smoke: tick Viz and write one PPM frame (converted to PNG later).
with Ada.Streams.Stream_IO;
with Ada.Text_IO;
with Eva_Plan.Api;
with Eva_Plan.Viz;
with Interfaces; use Interfaces;

procedure Eva_Plan_Viz_Preview is
   package SIO renames Ada.Streams.Stream_IO;

   Path : constant String :=
     "/workspace/eva-planner-ada/dist/splash-preview.ppm";
   F    : SIO.File_Type;
   S    : SIO.Stream_Access;
   W    : constant Natural := Eva_Plan.Viz.Max_W;
   H    : constant Natural := Eva_Plan.Viz.Max_H;
   Pix  : Unsigned_32;
   R, G, B : Unsigned_8;
   Hdr  : constant String :=
     "P6" & ASCII.LF
     & Natural'Image (W) (2 .. Natural'Image (W)'Last) & " "
     & Natural'Image (H) (2 .. Natural'Image (H)'Last) & ASCII.LF
     & "255" & ASCII.LF;

   procedure Put_Byte (V : Unsigned_8) is
   begin
      Ada.Streams.Stream_Element'Write
        (S, Ada.Streams.Stream_Element (V));
   end Put_Byte;
begin
   Eva_Plan.Api.Init;
   Eva_Plan.Api.Viz_Start (42);
   for K in 1 .. 90 loop
      Eva_Plan.Api.Viz_Tick;
   end loop;

   SIO.Create (F, SIO.Out_File, Path);
   S := SIO.Stream (F);
   for I in Hdr'Range loop
      Put_Byte (Character'Pos (Hdr (I)));
   end loop;

   for Y in 0 .. H - 1 loop
      for X in 0 .. W - 1 loop
         Pix := Eva_Plan.Viz.Frame (Y * Eva_Plan.Viz.Max_W + X);
         --  AABBGGRR → RGB
         R := Unsigned_8 (Pix and 16#FF#);
         G := Unsigned_8 (Shift_Right (Pix, 8) and 16#FF#);
         B := Unsigned_8 (Shift_Right (Pix, 16) and 16#FF#);
         Put_Byte (R);
         Put_Byte (G);
         Put_Byte (B);
      end loop;
   end loop;
   SIO.Close (F);
   Ada.Text_IO.Put_Line ("wrote " & Path);
end Eva_Plan_Viz_Preview;
