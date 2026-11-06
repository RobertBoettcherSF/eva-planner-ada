--  EVA Planner Ada — one splash scene: two walkers on the invented traverse.
pragma Assertion_Policy (Check);
pragma SPARK_Mode (Off);

with Interfaces; use Interfaces;

package body Eva_Plan.Viz is

   Progress : Float := 0.0;
   Phase    : Natural := 0;

   --  Sample path in local metres (+X east, +Y north). Invented site.
   type Point is record
      X, Y : Float;
   end record;

   Waypoint_N : constant := 5;
   type Waypoint_Arr is array (0 .. Waypoint_N - 1) of Point;
   Waypoints : constant Waypoint_Arr :=
     ((0.0, 0.0),       --  Lander Pad
      (420.0, 90.0),    --  East Ridge
      (80.0, -560.0),   --  South Bench
      (-380.0, 40.0),   --  West Notch
      (0.0, 0.0));      --  home

   type POI_Arr is array (0 .. 4) of Point;
   POIs : constant POI_Arr :=
     ((380.0, 140.0),   --  Split Boulder
      (150.0, -480.0),  --  Rim Shelf
      (-280.0, 120.0),  --  Dark Hollow
      (40.0, -200.0),   --  Fine Soil
      (-90.0, -40.0));  --  Shallow Pit

   --  Map fit: centre near (20, -210), scale ~0.45 px/m, north up.
   Map_CX : constant Float := 20.0;
   Map_CY : constant Float := -210.0;
   Scale  : constant Float := 0.45;

   function To_Screen (M : Point) return Point is
   begin
      return
        (Float (Width) * 0.5 + (M.X - Map_CX) * Scale,
         Float (Height) * 0.52 - (M.Y - Map_CY) * Scale);
   end To_Screen;

   procedure Clear (C : Pixel) is
   begin
      for I in Frame'Range loop
         Frame (I) := C;
      end loop;
   end Clear;

   procedure Put (X, Y : Integer; C : Pixel) is
   begin
      if X >= 0 and then Y >= 0
        and then X < Width and then Y < Height
      then
         Frame (Y * Max_W + X) := C;
      end if;
   end Put;

   procedure Fill_Disk (CX, CY : Integer; R : Natural; C : Pixel) is
      R2 : constant Integer := Integer (R * R);
   begin
      for DY in -Integer (R) .. Integer (R) loop
         for DX in -Integer (R) .. Integer (R) loop
            if DX * DX + DY * DY <= R2 then
               Put (CX + DX, CY + DY, C);
            end if;
         end loop;
      end loop;
   end Fill_Disk;

   procedure Stroke_Disk (CX, CY : Integer; R : Natural; C : Pixel) is
      R2  : constant Integer := Integer (R * R);
      Inn : constant Natural := (if R > 1 then R - 1 else 0);
      Ri2 : constant Integer := Integer (Inn * Inn);
   begin
      for DY in -Integer (R) .. Integer (R) loop
         for DX in -Integer (R) .. Integer (R) loop
            declare
               D2 : constant Integer := DX * DX + DY * DY;
            begin
               if D2 <= R2 and then D2 >= Ri2 then
                  Put (CX + DX, CY + DY, C);
               end if;
            end;
         end loop;
      end loop;
   end Stroke_Disk;

   procedure Line (X0, Y0, X1, Y1 : Integer; C : Pixel; Thick : Natural := 1) is
      DX  : constant Integer := abs (X1 - X0);
      DY  : constant Integer := abs (Y1 - Y0);
      SX  : constant Integer := (if X0 < X1 then 1 else -1);
      SY  : constant Integer := (if Y0 < Y1 then 1 else -1);
      Err : Integer := DX - DY;
      X   : Integer := X0;
      Y   : Integer := Y0;
      E2  : Integer;
   begin
      loop
         if Thick <= 1 then
            Put (X, Y, C);
         else
            Fill_Disk (X, Y, Thick, C);
         end if;
         exit when X = X1 and then Y = Y1;
         E2 := 2 * Err;
         if E2 > -DY then
            Err := Err - DY;
            X := X + SX;
         end if;
         if E2 < DX then
            Err := Err + DX;
            Y := Y + SY;
         end if;
      end loop;
   end Line;

   --  Tiny 5x7 glyphs for the labels we draw.
   type Glyph is array (0 .. 6) of Unsigned_8;
   Blank : constant Glyph := (others => 0);

   function Glyph_Of (Ch : Character) return Glyph is
   begin
      case Ch is
         when 'A' | 'a' =>
            return (16#0E#, 16#11#, 16#11#, 16#1F#, 16#11#, 16#11#, 16#11#);
         when 'B' | 'b' =>
            return (16#1E#, 16#11#, 16#11#, 16#1E#, 16#11#, 16#11#, 16#1E#);
         when 'C' | 'c' =>
            return (16#0E#, 16#11#, 16#10#, 16#10#, 16#10#, 16#11#, 16#0E#);
         when 'D' | 'd' =>
            return (16#1E#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#1E#);
         when 'E' | 'e' =>
            return (16#1F#, 16#10#, 16#10#, 16#1E#, 16#10#, 16#10#, 16#1F#);
         when 'F' | 'f' =>
            return (16#1F#, 16#10#, 16#10#, 16#1E#, 16#10#, 16#10#, 16#10#);
         when 'G' | 'g' =>
            return (16#0E#, 16#11#, 16#10#, 16#17#, 16#11#, 16#11#, 16#0F#);
         when 'H' | 'h' =>
            return (16#11#, 16#11#, 16#11#, 16#1F#, 16#11#, 16#11#, 16#11#);
         when 'I' | 'i' =>
            return (16#0E#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#, 16#0E#);
         when 'K' | 'k' =>
            return (16#11#, 16#12#, 16#14#, 16#18#, 16#14#, 16#12#, 16#11#);
         when 'L' | 'l' =>
            return (16#10#, 16#10#, 16#10#, 16#10#, 16#10#, 16#10#, 16#1F#);
         when 'M' | 'm' =>
            return (16#11#, 16#1B#, 16#15#, 16#15#, 16#11#, 16#11#, 16#11#);
         when 'N' | 'n' =>
            return (16#11#, 16#19#, 16#15#, 16#13#, 16#11#, 16#11#, 16#11#);
         when 'O' | 'o' =>
            return (16#0E#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0E#);
         when 'P' | 'p' =>
            return (16#1E#, 16#11#, 16#11#, 16#1E#, 16#10#, 16#10#, 16#10#);
         when 'R' | 'r' =>
            return (16#1E#, 16#11#, 16#11#, 16#1E#, 16#14#, 16#12#, 16#11#);
         when 'S' | 's' =>
            return (16#0F#, 16#10#, 16#10#, 16#0E#, 16#01#, 16#01#, 16#1E#);
         when 'T' | 't' =>
            return (16#1F#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#, 16#04#);
         when 'U' | 'u' =>
            return (16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0E#);
         when 'V' | 'v' =>
            return (16#11#, 16#11#, 16#11#, 16#11#, 16#11#, 16#0A#, 16#04#);
         when 'W' | 'w' =>
            return (16#11#, 16#11#, 16#11#, 16#15#, 16#15#, 16#15#, 16#0A#);
         when 'Y' | 'y' =>
            return (16#11#, 16#11#, 16#0A#, 16#04#, 16#04#, 16#04#, 16#04#);
         when others =>
            return Blank;
      end case;
   end Glyph_Of;

   procedure Draw_Char (X, Y : Integer; Ch : Character; C : Pixel) is
      G   : constant Glyph := Glyph_Of (Ch);
      Row : Unsigned_8;
   begin
      for RY in 0 .. 6 loop
         Row := G (RY);
         for RX in 0 .. 4 loop
            if (Row and Shift_Left (1, 4 - RX)) /= 0 then
               Put (X + RX, Y + RY, C);
            end if;
         end loop;
      end loop;
   end Draw_Char;

   procedure Draw_Text (X, Y : Integer; S : String; C : Pixel) is
      CX : Integer := X;
   begin
      for I in S'Range loop
         if S (I) /= ' ' then
            Draw_Char (CX, Y, S (I), C);
         end if;
         CX := CX + 6;
      end loop;
   end Draw_Text;

   procedure Draw_Background is
      Crater : constant array (1 .. 8) of Point :=
        ((120.0, 80.0), (480.0, 140.0), (200.0, 300.0), (520.0, 280.0),
         (80.0, 240.0), (360.0, 60.0), (580.0, 220.0), (300.0, 340.0));
   begin
      Clear (16#FF2A2E34#);
      for Y in 0 .. 28 loop
         for X in 0 .. Width - 1 loop
            Put (X, Y, 16#FF1A1C22#);
         end loop;
      end loop;
      for K in Crater'Range loop
         Fill_Disk
           (Integer (Crater (K).X), Integer (Crater (K).Y),
            6 + (K mod 4), 16#FF23262C#);
         Stroke_Disk
           (Integer (Crater (K).X), Integer (Crater (K).Y),
            6 + (K mod 4), 16#FF3A4048#);
      end loop;
   end Draw_Background;

   procedure Draw_Path is
      SA, SB : Point;
   begin
      for I in 0 .. Waypoint_N - 2 loop
         SA := To_Screen (Waypoints (I));
         SB := To_Screen (Waypoints (I + 1));
         Line
           (Integer (SA.X), Integer (SA.Y),
            Integer (SB.X), Integer (SB.Y),
            16#FF6EC8E8#, 2);
      end loop;
   end Draw_Path;

   procedure Draw_Stations is
      S   : Point;
      Col : Pixel;
   begin
      for I in 0 .. 3 loop
         S := To_Screen (Waypoints (I));
         if I = 0 then
            Col := 16#FFE8D080#;
            for DY in -6 .. 6 loop
               for DX in -6 .. 6 loop
                  if abs (DX) = 6 or else abs (DY) = 6
                    or else (abs (DX) <= 2 and then abs (DY) <= 2)
                  then
                     Put (Integer (S.X) + DX, Integer (S.Y) + DY, Col);
                  end if;
               end loop;
            end loop;
            Line
              (Integer (S.X), Integer (S.Y) - 6,
               Integer (S.X), Integer (S.Y) - 16, Col, 1);
            Fill_Disk (Integer (S.X), Integer (S.Y) - 18, 2, 16#FF80E0FF#);
            Draw_Text (Integer (S.X) + 10, Integer (S.Y) - 4,
                       "LANDER", 16#FFD0D8E0#);
         else
            Col := 16#FF70B0FF#;
            Fill_Disk (Integer (S.X), Integer (S.Y), 5, Col);
            Stroke_Disk (Integer (S.X), Integer (S.Y), 7, 16#FFD0E8FF#);
            case I is
               when 1 =>
                  Draw_Text (Integer (S.X) + 10, Integer (S.Y) - 4,
                             "EAST RIDGE", 16#FFD0D8E0#);
               when 2 =>
                  Draw_Text (Integer (S.X) + 10, Integer (S.Y) - 4,
                             "SOUTH BENCH", 16#FFD0D8E0#);
               when others =>
                  Draw_Text (Integer (S.X) + 10, Integer (S.Y) - 4,
                             "WEST NOTCH", 16#FFD0D8E0#);
            end case;
         end if;
      end loop;
   end Draw_Stations;

   procedure Draw_POIs is
      S : Point;
   begin
      for I in POIs'Range loop
         S := To_Screen (POIs (I));
         Put (Integer (S.X),     Integer (S.Y) - 3, 16#FF90E090#);
         Put (Integer (S.X) - 1, Integer (S.Y) - 2, 16#FF90E090#);
         Put (Integer (S.X) + 1, Integer (S.Y) - 2, 16#FF90E090#);
         Put (Integer (S.X) - 2, Integer (S.Y) - 1, 16#FF90E090#);
         Put (Integer (S.X) + 2, Integer (S.Y) - 1, 16#FF90E090#);
         Put (Integer (S.X) - 3, Integer (S.Y),     16#FF90E090#);
         Put (Integer (S.X) + 3, Integer (S.Y),     16#FF90E090#);
         Put (Integer (S.X) - 2, Integer (S.Y) + 1, 16#FF90E090#);
         Put (Integer (S.X) + 2, Integer (S.Y) + 1, 16#FF90E090#);
         Put (Integer (S.X) - 1, Integer (S.Y) + 2, 16#FF90E090#);
         Put (Integer (S.X) + 1, Integer (S.Y) + 2, 16#FF90E090#);
         Put (Integer (S.X),     Integer (S.Y) + 3, 16#FF90E090#);
      end loop;
   end Draw_POIs;

   procedure Path_At
     (T : Float; Pos : out Point; Dir_X, Dir_Y : out Float)
   is
      Clamped : Float := T;
      Leg_F   : Float;
      Leg     : Integer;
      Frac    : Float;
      A, B    : Point;
      Len     : Float;
   begin
      if Clamped < 0.0 then
         Clamped := 0.0;
      elsif Clamped >= 1.0 then
         Clamped := 0.999;
      end if;
      Leg_F := Clamped * 4.0;
      --  Floor without Float'Floor (WASM has no that runtime symbol).
      --  Integer (Float) rounds to nearest, which jumped legs at halfway
      --  and drew the walkers off the map.
      Leg := 0;
      for Candidate in reverse 0 .. 3 loop
         if Leg_F >= Float (Candidate) then
            Leg := Candidate;
            exit;
         end if;
      end loop;
      Frac := Leg_F - Float (Leg);
      A := Waypoints (Leg);
      B := Waypoints (Leg + 1);
      Pos := (A.X + Frac * (B.X - A.X), A.Y + Frac * (B.Y - A.Y));
      Dir_X := B.X - A.X;
      Dir_Y := B.Y - A.Y;
      Len := abs (Dir_X) + abs (Dir_Y);
      if Len < 0.001 then
         Len := 0.001;
      end if;
      Dir_X := Dir_X / Len;
      Dir_Y := Dir_Y / Len;
   end Path_At;

   procedure Draw_One_Walker (Side : Float; Suit : Pixel) is
      Base : Point;
      DX, DY : Float;
      P : Point;
      S : Point;
      Head_X, Head_Y, Body_Y : Integer;
      Kick : Integer;
   begin
      Path_At (Progress, Base, DX, DY);
      P := (Base.X - DY * Side * 22.0, Base.Y + DX * Side * 22.0);
      S := To_Screen (P);
      Head_X := Integer (S.X);
      Head_Y := Integer (S.Y) - 10;
      Body_Y := Integer (S.Y) - 1;
      Kick := (if (Phase / 3) mod 2 = 0 then 3 else -3);
      if Side < 0.0 then
         Kick := -Kick;
      end if;
      Line (Head_X - 2, Body_Y + 3, Head_X - 2 + Kick, Body_Y + 11,
            16#FFD0C8B8#, 1);
      Line (Head_X + 2, Body_Y + 3, Head_X + 2 - Kick, Body_Y + 11,
            16#FFD0C8B8#, 1);
      Fill_Disk (Head_X, Body_Y, 4, Suit);
      Fill_Disk
        (Head_X + (if Side < 0.0 then -3 else 3), Body_Y, 3, 16#FF9098A0#);
      Fill_Disk (Head_X, Head_Y, 4, 16#FFF0F4F8#);
      Stroke_Disk (Head_X, Head_Y, 4, Suit);
      Put (Head_X - 1, Head_Y, 16#FF305898#);
      Put (Head_X, Head_Y, 16#FF4070B0#);
      Put (Head_X + 1, Head_Y, 16#FF305898#);
   end Draw_One_Walker;

   procedure Draw_Walkers is
   begin
      Draw_One_Walker (-1.0, 16#FFE09040#);  --  Walker A orange
      Draw_One_Walker (1.0, 16#FF40C8C0#);   --  Walker B teal
   end Draw_Walkers;

   procedure Draw_Title_Bar is
   begin
      for Y in 8 .. 26 loop
         for X in 160 .. 480 loop
            Put (X, Y, 16#FF141820#);
         end loop;
      end loop;
      Draw_Text (214, 12, "EVA PLANNER ADA", 16#FFE8F0FF#);
   end Draw_Title_Bar;

   procedure Start (Seed : Unsigned_32) is
      pragma Unreferenced (Seed);
   begin
      Width := Max_W;
      Height := Max_H;
      Progress := 0.0;
      Phase := 0;
      Clear (16#FF2A2E34#);
   end Start;

   procedure Tick is
   begin
      Phase := Phase + 1;
      Progress := Progress + 0.0035;
      if Progress >= 1.0 then
         Progress := Progress - 1.0;
      end if;
      Draw_Background;
      Draw_Path;
      Draw_POIs;
      Draw_Stations;
      Draw_Walkers;
      Draw_Title_Bar;
   end Tick;

   function Frame_Address return System.Address is
   begin
      return Frame (Frame'First)'Address;
   end Frame_Address;

   function Frame_Width return Integer is (Integer (Width));
   function Frame_Height return Integer is (Integer (Height));

end Eva_Plan.Viz;
