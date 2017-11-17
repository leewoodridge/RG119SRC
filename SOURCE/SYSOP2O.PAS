{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  ----------------------------------------------------------------------
  MAX TIME DAILY / MAX CALLS DAILY / FILE RATIO / KB RATIO / 
  POST/CALL RATIO / MAX # DL DAILY / MAX KB DL DAILY
  ----------------------------------------------------------------------
}

UNIT SysOp2O;

INTERFACE

USES
  Common;

PROCEDURE GetSecRange(CONST DisplayType: LongInt; VAR Sec: SecurityRangeType);

IMPLEMENTATION

PROCEDURE GetSecRange(CONST DisplayType: LongInt; VAR Sec: SecurityRangeType);
VAR
  Cmd: Char;
  Counter: Byte;
  DisplayValue,
  FromValue,
  ToValue: SmallInt;
  NewValue: LongInt;

  PROCEDURE ShowSecRange(Start: Byte);
  VAR
    TempStr: AStr;
    LineNum,
    Counter1: Byte;
    SecNum: Integer;
  BEGIN
    Abort := FALSE;
    Next := FALSE;
    LineNum := 0;
	
	PrintACR('^4+-----+--------+-----+--------+-----+--------+-----+--------+-----+-----------+');
	PrintACR('^4| ^3SL  ^4| ^3Value  ^4| ^3SL  ^4| ^3Value  ^4|'+
				' ^3SL  ^4| ^3Value  ^4| ^3SL  ^4| ^3Value  ^4| ^3SL  ^4| ^3Value     ^4|');
	PrintACR('^4+-----+--------+-----+--------+-----+--------+-----+--------+-----+-----------+');
	
    REPEAT
      TempStr := '';
      FOR Counter1 := 0 TO 4 DO
      BEGIN
        SecNum := Start + LineNum + Counter1 * 17;
        IF (SecNum <= 255) THEN
        BEGIN
          TempStr := TempStr + '  ^1'+PadLeftInt(SecNum,5)+' ^0'+PadLeftInt(Sec[SecNum],6);
          IF (Counter1 <> 7) THEN
            TempStr := TempStr + ' ';
        END;
      END;
      PrintACR(TempStr);
      Inc(LineNum);
    UNTIL (LineNum > 16) OR (Abort) OR (HangUp); { LeeW: Should use PAGELEN, no? }
  END;

BEGIN
  Abort := FALSE;
  Next := FALSE;
  DisplayValue := 0;
  REPEAT
    CLS;
    CASE DisplayType OF
      1 : Print('^1Daily Time Limit');
      2 : Print('^1Daily Call Limit');
      3 : Print('^1UL/DL Ratio (Number Of Files Can DL Per 1 File UL)');
      4 : Print('^1UL/DL Ratio (Number Of Kb Can DL Per 1Kb UL)');
      5 : Print('^1Post/Call Ratio (Posts Per 100 Calls To Have Z ACS Flag Set)');
      6 : Print('^1Daily Download Limit (Number Of Files)');
      7 : Print('^1Daily Download Limit (Kb)');
    END;
    NL;
    ShowSecRange(DisplayValue);
	NL;
    LOneK('^0[(^1?^0)Help]: ',Cmd,'QS?'^M,TRUE,TRUE);
    CASE Cmd OF
      'S' : BEGIN
              FromValue := 0;
              InputIntegerWOC('^0%LFFrom?',FromValue,[InteractiveEdit,NumbersOnly],0,255);
              IF (FromValue >= 0) AND (FromValue <= 255) THEN
              BEGIN
                ToValue := 255;
                InputIntegerWOC('^0%LFTo?',ToValue,[InteractiveEdit,NumbersOnly],0,255);
                IF (ToValue >= 0) AND (ToValue <= 255) THEN
                BEGIN
                  NewValue := -1;
                  InputLongIntWOC('^0%LFValue?',NewValue,[NumbersOnly],0,32767);
                  IF (NewValue >= 0) AND (NewValue <= 32767) THEN
                    FOR Counter := FromValue TO ToValue DO
                      Sec[Counter] := NewValue;
                END;
              END;
            END;
      ^M : BEGIN
				IF (DisplayValue = 0) THEN DisplayValue := 85
				ELSE IF (DisplayValue = 85) THEN DisplayValue := 170
			    ELSE IF (DisplayValue = 170) THEN DisplayValue := 255
				ELSE DisplayValue := 0
			END;
      '?' : BEGIN
              Print('^0%LF<^1CR^0> Next Page / Refresh');
              LCmds(19,1,'S Set New Values','Q Quit');
			  NL;
			  PauseScr(False);
            END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
