
UNIT MyIO;

INTERFACE

TYPE
  WindowRec = ARRAY[0..8000] OF Byte;
  ScreenType = ARRAY [0..3999] OF Byte;
VAR
  Wind: WindowRec;
  MonitorType: Byte ABSOLUTE $0000:$0449;
  ScreenAddr: ScreenType ABSOLUTE $B800:$0000;
  ScreenSize: Integer;
  MaxDisplayRows,
  MaxDisplayCols: Byte;

PROCEDURE Update_Logo(VAR Addr1, Addr2; BlkLen: Integer);
PROCEDURE CursorOn(B: BOOLEAN);
PROCEDURE SaveScreen(VAR Wind: WindowRec); {LOCAL DISP ONLY}
PROCEDURE RestoreScreen(VAR Wind: WindowRec); {LOCAL DISP ONLY}
(*
PROCEDURE Box(LineType, TLX, TLY, BRX, BRY: Integer);
PROCEDURE SetWindow(VAR Wind: WindowRec; TLX, TLY, BRX, BRY, TColor, BColor, BoxType: Integer);
*)

IMPLEMENTATION

USES
  CRT;

PROCEDURE CursorOn(b: BOOLEAN); ASSEMBLER;
ASM
  cmp b, 1
  je @turnon
  mov ch, 9
  mov cl, 0
  jmp @goforit
  @turnon:
  mov ch, 6
  mov cl, 7
  @goforit:
  mov ah,1
  int 10h
END;

PROCEDURE SaveScreen(VAR Wind: WindowRec);
BEGIN
  Move(ScreenAddr[0],Wind[0],ScreenSize); {local disp only}
END;

PROCEDURE RestoreScreen(VAR Wind: WindowRec);
BEGIN
  Move(Wind[0],ScreenAddr[0],ScreenSize); {local disp only}
END;

(*
PROCEDURE Box(LineType,TLX,TLY,BRX,BRY: Integer);
{
  ÚÄÄÄ¿   ÉÍÍÍ»   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÖÄÄÄ·  ÕÍÍÍ¸
  ³ 1 ³   º 2 º   ° 3 °   ± 4 ±   ² 5 ²   Û 6 Û   º 7 º  ³ 8 ³
  ÀÄÄÄÙ   ÈÍÍÍ¼   °°°°°   ±±±±±   ²²²²²   ÛÛÛÛÛ   ÓÄÄÄ½  ÔÍÍÍ¾
 }
VAR
  TL,TR,BL,BR,HLine,VLine: Char;
  i: Integer;
BEGIN
  Window(1,1,MaxDisplayCols,MaxDisplayRows);
  CASE LineType OF
    1 : BEGIN
          TL := #218;
          TR := #191;
          BL := #192;
          BR := #217;
          VLine := #179;
          HLine := #196;
        END;
    2 : BEGIN
          TL := #201;
          TR := #187;
          BL := #200;
          BR := #188;
          VLine := #186;
          HLine := #205;
        END;
    3 : BEGIN
          TL := #176;
          TR := #176;
          BL := #176;
          BR := #176;
          VLine := #176;
          HLine := #176;
        END;
    4 : BEGIN
          TL := #177;
          TR := #177;
          BL := #177;
          BR := #177;
          VLine := #177;
          HLine := #177;
        END;
    5 : BEGIN
          TL := #178;
          TR := #178;
          BL := #178;
          BR := #178;
          VLine := #178;
          HLine := #178;
        END;
    6 : BEGIN
          TL := #219;
          TR := #219;
          BL := #219;
          BR := #219;
          VLine := #219;
          HLine := #219;
        END;
    7 : BEGIN
          TL := #214;
          TR := #183;
          BL := #211;
          BR := #189;
          VLine := #186;
          HLine := #196;
        END;
    8 : BEGIN
          TL := #213;
          TR := #184;
          BL := #212;
          BR := #190;
          VLine := #179;
          HLine := #205;
        END;
    ELSE
    BEGIN
      TL := #32;
      TR := #32;
      BL := #32;
      BR := #32;
      VLine := #32;
      HLine := #32;
    END;
  END;
  GoToXY(TLX,TLY);
  Write(TL);
  GoToXY(BRX,TLY);
  Write(TR);
  GoToXY(TLX,BRY);
  Write(BL);
  GoToXY(BRX,BRY);
  Write(BR);
  FOR i := (TLX + 1) TO (BRX - 1) DO
  BEGIN
    GoToXY(i,TLY);
    Write(HLine);
  END;
  FOR i := (TLX + 1) TO (BRX - 1) DO
  BEGIN
    GoToXY(i,BRY);
    Write(HLine);
  END;
  FOR i := (TLY + 1) TO (BRY - 1) DO
  BEGIN
    GoToXY(TLX,i);
    Write(VLine);
  END;
  FOR i := (TLY + 1) TO (BRY - 1) DO
  BEGIN
    GoToXY(BRX,I);
    Write(VLine);
  END;
  IF (LineType > 0) THEN
    Window((TLX + 1),(TLY + 1),(BRX - 1),(BRY - 1))
  ELSE
    Window(TLX,TLY,BRX,BRY);
END;

PROCEDURE SetWindow(VAR Wind: WindowRec; TLX, TLY, BRX, BRY, TColor, BColor, BoxType: Integer);
BEGIN
  SaveScreen(Wind);				{ Save Behind Window }
  Window(TLX,TLY,BRX,BRY);		{ Window Size }
  TextColor(TColor);			{ Color Of Text }
  TextBackGround(BColor);		{ Color Of Background }
  ClrScr;						{ Clear Window }
  Box(BoxType,TLX,TLY,BRX,BRY);	{ Border Style }
END;
*)
PROCEDURE Update_Logo(VAR Addr1,Addr2; BlkLen: Integer); {data} {start} {fin}
BEGIN
  INLINE (
	$1E/
    $C5/$B6/ADDR1/
    $C4/$BE/ADDR2/
    $8B/$8E/BLKLEN/
    $E3/$5B/
    $8B/$D7/
    $33/$C0/
    $FC/
    $AC/
    $3C/$20/
    $72/$05/
    $AB/
    $E2/$F8/
    $EB/$4C/
    $3C/$10/
    $73/$07/
    $80/$E4/$F0/
    $0A/$E0/
    $EB/$F1/
    $3C/$18/
    $74/$13/
    $73/$19/
    $2C/$10/
    $02/$C0/
    $02/$C0/
    $02/$C0/
    $02/$C0/
    $80/$E4/$8F/
    $0A/$E0/
    $EB/$DA/
    $81/$C2/$A0/$00/
    $8B/$FA/
    $EB/$D2/
    $3C/$1B/
    $72/$07/
    $75/$CC/
    $80/$F4/$80/
    $EB/$C7/
    $3C/$19/
    $8B/$D9/
    $AC/
    $8A/$C8/
    $B0/$20/
    $74/$02/
    $AC/
    $4B/
    $32/$ED/
    $41/
    $F3/$AB/
    $8B/$CB/
    $49/
    $E0/$AA/
    $1F );
END;

END.
