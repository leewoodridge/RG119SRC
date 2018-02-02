
{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
}

UNIT Common0;

INTERFACE

USES
  Common;

PROCEDURE LOneKX(DisplayStr: STRING; VAR C: Char; ValidKeys: STRING; DisplayKeys, DisplayInput, LineFeedB, LineFeedA: Boolean);
{ LeeW: New prompt for single-key input }
FUNCTION DateSuffix(DateNumber: Byte): STRING; { LeeW: Output 'st', 'nd', 'rd', etc to input number }
FUNCTION NewYN(CONST Q: AStr; YN: Boolean): Boolean; { LeeW: New Y/N Question Prompt }
FUNCTION ToLower(S: STRING): STRING; { was in oneliner }
PROCEDURE Clear_EOL; { was in splitchat }

IMPLEMENTATION

USES
  CRT;
  
PROCEDURE LOneKX(DisplayStr: STRING; VAR C: Char; ValidKeys: STRING; DisplayKeys, DisplayInput, LineFeedB, LineFeedA: Boolean);
(*
	- Adds compressed validkeys (ie. 'ABCDEFGQXYZ1345' to 'A-G,Q,X-Z,1,3-5') to prompt
	- Adds '(Q)uit', '(?)Help', and '<CR>' to prompt if available
	*ISSUES*
	- I'm sure this is super-inefficient, someone please help!
	- How to handle <CR>? Could be refresh, or abort
*)
VAR
  TempKeys1,
  TempKeys2: STRING;
  i: Integer;
BEGIN  
  IF (LineFeedB) THEN
	NL;
  
  Prt(DisplayStr);
  
  IF (DisplayKeys) THEN
	BEGIN
	  TempKeys1 := ValidKeys;
	  
	  IF (Pos('Q',TempKeys1) > 0) THEN
		Delete(Tempkeys1,Pos('Q',TempKeys1),1); { Remove "Q" }
	  IF (Pos('?',TempKeys1) > 0) THEN
		Delete(Tempkeys1,Pos('?',TempKeys1),1); { Remove "?" }
	  IF (Pos(^M,TempKeys1) > 0) THEN
		Delete(Tempkeys1,Pos(^M,TempKeys1),2); { Remove "^M" }
		
	  TempKeys2 := TempKeys1;
	  
	  i := 1;
	  
	  WHILE i <= Length(TempKeys1) DO
		BEGIN { If more than 3 subsequent letters in a row, replace letters in middle with "-" }
		  IF (Ord(TempKeys1[i])+1 = Ord(TempKeys1[i+1])) THEN
			IF (Ord(TempKeys1[i+1])+1 = Ord(TempKeys1[i+2])) THEN
			  TempKeys2[i+1] := '-'; 
		  Inc(i);
		END;
		
	  REPEAT
		Delete(TempKeys2,Pos('--',TempKeys2),1); { Remove one "-" if there are two in a row }
	  UNTIL Pos('--',TempKeys2) = 0;

	  TempKeys1 := '';
	  
	  i := 1;
	  
	  WHILE i <= Length(TempKeys2) DO
		BEGIN
		  IF (TempKeys2[i] = '-') OR (TempKeys2[i+1] = '-') THEN
			TempKeys1 := TempKeys1+Copy(TempKeys2,i,1)
		  ELSE
			TempKeys1 := TempKeys1+Copy(TempKeys2,i,1)+',';
		  Inc(i);
		END;
		
	  IF Tempkeys1[Length(TempKeys1)] = ',' THEN
		Delete(TempKeys1,Length(TempKeys1),1); { Remove last comma }
	   
	  Prt(' ^0[');
	  Prt('^1'+TempKeys1);
	  IF (Pos('Q',ValidKeys) > 0) THEN
		Prt('^0,(^1Q^0)uit');
	  IF (Pos('?',ValidKeys) > 0) THEN
		Prt('^0,(^1?^0)Help');
	  IF (Pos(^M,ValidKeys) > 0) THEN
		Prt('^0,<^1CR^0>!?');
	  Prt(']: ');
	END;  
  
  MPL(1);
  TempPause := (Pause IN ThisUser.Flags);
  
  REPEAT
    C := UpCase(Char(GetKey));
  UNTIL (Pos(C,ValidKeys) > 0) OR (HangUp);
  
  IF (HangUp) THEN
    C := ValidKeys[1];
  IF (DisplayInput) THEN
    OutKey(C);
  IF (Trapping) THEN
    OutTrap(C);
	
  UserColor(0); {?}
  
  IF (LineFeedA) THEN
    NL;
END;

FUNCTION DateSuffix(DateNumber: Byte): STRING;
(*
	LeeW: Returns appropriate suffix (ie. 'st', 'nd', 'rd') for number provided
*)
BEGIN
  CASE DateNumber OF
	1, 21, 31 : DateSuffix := 'st';
	2, 22 : DateSuffix := 'nd';
	3, 23 : DateSuffix := 'rd';
	4..20, 24..30 : DateSuffix := 'th';
  ELSE
	DateSuffix := '*';
  END
END;

FUNCTION NewYN(CONST Q: AStr; YN: Boolean): Boolean; { LeeW: New Yes/No Question Prompt }

(*
	ISSUES:
	  - F's up if prompt is on bottom line of screen. moves yes/no options up 1 line ONLY REMOTELY
	  STATUS BAR INTERFERES WITH WHEREX/Y
	  could dobackspace instead
*)

VAR
  W: Word; { Keyboard Input }
  YesX, { X&Y Positions }
  YesY,
  NoX,
  NoY: Integer;
BEGIN
  IF NOT (OkANSI) OR NOT ((General.UseLightBars) AND (UseLightBars IN ThisUser.Flags)) THEN
	BEGIN { Basic prompt for no ANSI or lightbars disabled }
	  NewYN := PYNQ(Q,0,YN);
	  EXIT;
	END
  ELSE
    BEGIN
	  Prt('^0'+Q);
	  YesX := WhereX;
	  YesY := WhereY;
	  IF YN = TRUE THEN 
		Prt(lRGLngStr(96,TRUE))
	  ELSE
		Prt(lRGLngStr(95,TRUE));
	  Prt(' ');
	  NoX := WhereX;
	  NoY := WhereY;
	  IF YN = FALSE THEN
		Prt(lRGLngStr(98,TRUE))
	  ELSE
		Prt(lRGLngStr(97,TRUE));
	  REPEAT
		W := GetKey;
		IF ((W = F_LEFT) AND (YN = FALSE)) OR ((W = F_RIGHT) AND (YN = TRUE)) THEN {LEFT/RIGHT ARROWS}
		  BEGIN
			ANSIG(YesX,YesY);
			IF YN = TRUE THEN
			  Prt(lRGLngStr(95,TRUE))
			ELSE
			  Prt(lRGLngStr(96,TRUE));
			ANSIG(NoX,NoY);
			IF YN = TRUE THEN
			  Prt(lRGLngStr(98,TRUE))
			ELSE
			  Prt(lRGLngStr(97,TRUE));
			YN := NOT YN;
		  END;
		IF (W = 89) OR (W = 121) THEN {89/121=Y}
		  BEGIN
			IF YN = FALSE THEN 
			  BEGIN
				YN := TRUE;
				ANSIG(YesX,YesY);
				Prt(lRGLngStr(96,TRUE));
				ANSIG(NoX,NoY);
				Prt(lRGLngStr(97,TRUE));
			  END;
			Break;
		  END;
		IF (W = 78) OR (W = 110) THEN {78/110=N}
		  BEGIN
			IF YN = TRUE THEN 
			  BEGIN
				YN := FALSE;
				ANSIG(YesX,YesY);
				Prt(lRGLngStr(95,TRUE));
				ANSIG(NoX,NoY);
				Prt(lRGLngStr(98,TRUE));
			  END;
			Break;
		  END;
	  UNTIL (W = 13) OR (HangUp); {13=ENTER}
	  NewYN := YN;
	END;
	NL; { LeeW: Testing }
END;

FUNCTION ToLower(S: STRING): STRING;
VAR
  i : BYTE;
BEGIN
 FOR i := 1 TO Length(S) DO
  BEGIN
   IF S[i] IN ['A'..'Z'] THEN
   S[i] := Chr(Ord(S[i]) + 32);
  END;
  ToLower := S;
END;

PROCEDURE Clear_EOL;
BEGIN
  IF (NOT OkAvatar) THEN
    SerialOut(#27'[K')
  ELSE
    SerialOut(^V^G);
  IF (WantOut) THEN
    ClrEOL;
END;

END.
