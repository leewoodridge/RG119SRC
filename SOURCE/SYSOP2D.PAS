{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2D;

INTERFACE

PROCEDURE SystemGeneralVariables;

IMPLEMENTATION

USES
  Common;

PROCEDURE SystemGeneralVariables;
VAR
  Cmd,
  Cmd1: Char;
  TempB,
  MinByte,
  MaxByte: Byte;
  TempI,
  LowNum,
  HiNum,
  TempInt,
  MinInt,
  MaxInt: SmallInt;
  TempL,
  MinLongInt,
  MaxLongInt: LongInt;

  FUNCTION DisplaySwapTo(SwapTo: Byte): Str4;
  BEGIN
    CASE SwapTo OF
      0   : DisplaySwapTo := 'Disk';
      1   : DisplaySwapTo := 'XMS';
      2   : DisplaySwapTo := 'EMS';
      4   : DisplaySwapTo := 'EXT';
      255 : DisplaySwapTo := 'Any';
    END;
  END;

  PROCEDURE DisplayMacroo(CONST S: AStr; MaxLen: Byte);
  VAR
    TempStr: AStr;
    Counter: Byte;
  BEGIN
    TempStr := '';
    Prompt('^1"^1');
    FOR Counter := 1 TO Length(S) DO
      IF (S[Counter] >= ' ') THEN
        TempStr := TempStr + S[Counter]
      ELSE
        TempStr := TempStr +  '^3^'+Chr(Ord(S[Counter]) + 64)+'^1';
    Prompt(PadLeftStr(TempStr,MaxLen)+'^1"');
  END;

  PROCEDURE MMacroo(MacroNum: Byte);
  VAR
    S: AStr;
    C: Char;
    Counter: Byte;
  BEGIN
    Print('%CL^1Enter new F'+IntToStr(MacroNum + 1)+' macro now.');
    Print('^1Enter ^Z to end recording. 100 character limit.%LF');
    S := '';
    Counter := 1;
    REPEAT
      C := Char(GetKey);
      IF (C = ^H) THEN
      BEGIN
        C := #0;
        IF (Counter >= 2) THEN
        BEGIN
          BackSpace;
          Dec(Counter);
          IF (S[Counter] < #32) THEN
            BackSpace;
        END;
      END;
      IF (Counter <= 100) AND (C <> #0) THEN
      BEGIN
        IF (C IN [#32..#255]) THEN
        BEGIN
          OutKey(C);
          S[Counter] := C;
          Inc(Counter);
        END
        ELSE IF (C IN [^A,^B,^C,^D,^E,^F,^G,^H,^I,^J,^K,^L,^M,^N,^P,^Q,^R,^S,^T,^U,^V,^W,^X,^Y,#27,#28,#29,#30,#31]) THEN
        BEGIN
          IF (C = ^M) THEN
            NL
          ELSE
            Prompt('^3^'+Chr(Ord(C) + 64)+'^1');
          S[Counter] := C;
          Inc(Counter);
        END;
      END;
    UNTIL ((C = ^Z) OR (HangUp));
    S[0] := Chr(Counter - 1);
    Print('%LF%LF^3Your F'+IntToStr(MacroNum + 1)+' macro is now:%LF');
    DisplayMacroo(S,160);
    Com_Flush_Recv;
    IF (NOT PYNQ('%LFIs this what you want? ',0,FALSE)) THEN
      Print('%LFMacro not saved.')
    ELSE
    BEGIN
      General.Macro[MacroNum] := S;
      Print('%LFMacro saved.');
    END;
    PauseScr(FALSE);
  END;

BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
	  Cls;
      PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Variables',80));
	  
      PrintACR('^0(^1A^0) Max Private Sent Per Call  : ^1'+PadLeftInt(MaxPrivPost,6)+
               '^0(^1B^0) Max Feedback Sent Per Call : ^1'+PadLeftInt(MaxFBack,6));
      PrintACR('^0(^1C^0) Max Public Posts Per Call  : ^1'+PadLeftInt(MaxPubPost,6)+
               '^0(^1D^0) Max Chat Attempts Per Call : ^1'+PadLeftInt(MaxChat,6));
      PrintACR('^0(^1E^0) Normal Max Mail Waiting    : ^1'+PadLeftInt(MaxWaiting,6)+
               '^0(^1F^0) CoSysOp Max Mail Waiting   : ^1'+PadLeftInt(CSMaxWaiting,6));
      PrintACR('^0(^1G^0) Max Mass Mail List         : ^1'+PadLeftInt(MaxMassMailList,6)+
               '^0(^1H^0) Logins Before BDay Check   : ^1'+PadLeftInt(BirthDateCheck,6));
      PrintACR('^0(^1I^0) Swap shell should use      : ^1'+PadLeftStr(DisplaySwapTo(SwapTo),6)+
               '^0(^1J^0) Number Of Logon Attempts   : ^1'+PadLeftInt(MaxLogonTries,6));
      PrintACR('^0(^1K^0) Password Change In Days    : ^1'+PadLeftInt(PasswordChange,6)+
               '^0(^1L^0) SysOp Chat Color           : ^1'+PadLeftInt(SysOpColor,6));
      PrintACR('^0(^1M^0) User Chat Color            : ^1'+PadLeftInt(UserColor,6)+
               '^0(^1N^0) Min. space for posts       : ^1'+PadLeftInt(MinSpaceForPost,6));
      PrintACR('^0(^1O^0) Min. space for uploads     : ^1'+PadLeftInt(MinSpaceForUpload,6)+
               '^0(^1P^0) Back SysOp Log keep days   : ^1'+PadLeftInt(BackSysOpLogs,6));
      PrintACR('^0(^1R^0) Blank WFC Menu Minutes     : ^1'+PadLeftInt(WFCBlankTime,6)+
               '^0(^1S^0) Alert Beep Delay           : ^1'+PadLeftInt(AlertBeep,6));
      PrintACR('^0(^1T^0) Number Of System Callers   : ^1'+PadLeftInt(CallerNum,6)+
               '^0(^1U^0) Minimum Logon Baud Rate    : ^1'+PadLeftInt(MinimumBaud,6));
      PrintACR('^0(^1V^0) Minimum DL Baud Rate       : ^1'+PadLeftInt(MinimumDLBaud,6)+
               '^0(^1W^0) Sec''s Between Time Slices  : ^1'+PadLeftInt(SliceTimer,6));
      PrintACR('^0(^1X^0) TB Max Time Allowed        : ^1'+PadLeftInt(MaxDepositEver,6)+
               '^0(^1Y^0) TB Max Daily Deposit       : ^1'+PadLeftInt(MaxDepositPerDay,6));
      PrintACR('^0(^1Z^0) TB Max Daily Withdraw      : ^1'+PadLeftInt(MaxWithDrawalPerDay,6)+
	           '^0(^1!^0) New User Message Sent To   : ^1'+AOnOff((NewApp = -1),'Off',PadLeftInt(NewApp,5)));
	  PrintACR('|07(|15@|07) Mins Before Timeout Bell : |15'+AOnOff((TimeOutBell = -1),'Off',PadLeftInt(TimeOutBell,3)));
      PrintACR('|07(|15#|07) Mins Before Timeout      : |15'+AOnOff((TimeOut = -1),'Off',PadLeftInt(TimeOut,3)));
      NL;
      FOR TempB := 0 TO 9 DO
      BEGIN
        Prompt('^0<^1'+IntToStr(TempB)+'^0> F'+IntToStr(TempB + 1)+' Macro : ');
        DisplayMacroo(Macro[TempB],21);
        IF Odd(TempB) THEN
          NL
        ELSE
          Prompt('  ');
      END;
	  Nl;
      Prt('^0Enter Selection or (^1Q^0) to Quit: ^1');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1234567890!@#',TRUE,TRUE);
      CASE Cmd OF
	          '@','#' :
              BEGIN
			  Nl;
                Prt('|07Select (|15E|07)nable (|15D|07)isable or [|15ENTER|07] To Quit: |15');
                OneK(Cmd1,^M'ED',TRUE,TRUE);
                IF (Cmd1 IN ['E','D']) THEN
                BEGIN
                  CASE Cmd1 OF
                    'E' : BEGIN
                            CASE Cmd OF
                              '@' : BEGIN
                                      LowNum := 1;
                                      HiNum := 20;
                                      TempInt := TimeOutBell;
                                    END;
                              '#' : BEGIN
                                      LowNum := 1;
                                      HiNum := 20;
                                      TempInt := TimeOut;
                                    END;
                            END;
                            InputIntegerWOC('^0%LFEnter Value For This Function',TempInt,[NumbersOnly],LowNum,HiNum);
                          END;
                    'D' : TempInt := -1;
                  END;
                  CASE Cmd OF
                    '@' : TimeOutBell := TempInt;
                    '#' : TimeOut := TempInt;
                  END;
                  Cmd := #0;
                END;
          END;
		  { ----- }
	    '!' : BEGIN { LeeW: User to send new user application email to }
			    NL;
                Prt('^0Select (^1E^0)nable, (^1D^0)isable, Or [^1ENTER^0] To Abort: ^1');
                OneK(Cmd1,^M'ED',TRUE,TRUE);
                IF (Cmd1 IN ['E','D']) THEN
                  BEGIN
				    LowNum := 1;
                    HiNum := (MaxUsers - 1);
                    TempInt := NewApp;
                    CASE Cmd1 OF
                      'E' : InputIntegerWOC('%LFEnter value for this function',TempInt,[NumbersOnly],LowNum,HiNum);
                      'D' : TempInt := -1;
                    END;
                    NewApp := TempInt;
                    Cmd1 := #0;
                  END;
				END;
        '0'..'9' :
              MMacroo(Ord(Cmd) - Ord('0'));
        'I' : BEGIN
                Print('^0%LFSwap Locations:%LF');
                Print('^0(^1D^0)isk');
                Print('^0(^1E^0)MS');
                Print('^0(^1X^0)MS');
                Print('^0(^1N^0)on XMS Extended');
                Print('^0(^1A^0)ny');
                lOneK('^0%LFSwap To Which? [<CR>Quit]: ',Cmd,'DEXNA'^M,TRUE,TRUE);
                CASE Pos(Cmd,'DXENA') OF
                  1..3 : SwapTo := (Pos(Cmd,'DXE') - 1);
                     4 : SwapTo := 4;
                     5 : SwapTo := 255;
                END;
                Cmd := #0;
              END;
        'A'..'H','J'..'P','R'..'Z' :
              BEGIN
                CASE Cmd OF
                  'A' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPrivPost;
                        END;
                  'B' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxFBack;
                        END;
                  'C' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPubPost;
                        END;
                  'D' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxChat;
                        END;
                  'E' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxWaiting;
                        END;
                  'F' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := CSMaxWaiting;
                        END;
                  'G' : BEGIN
                          MinByte := 2;
                          MaxByte := 255;
                          TempB := MaxMassMailList;
                        END;
                  'H' : BEGIN
                          MinInt := 0;
                          MaxInt := 365;
                          TempI := BirthDateCheck;
                        END;
                  'J' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxLogonTries;
                        END;
                  'K' : BEGIN
                          MinInt := 0;
                          MaxInt := 32767;
                          TempI := PasswordChange;
                        END;
                  'L' : BEGIN
                          MinByte := 0;
                          MaxByte := 9;
                          TempB := SysOpColor;
                        END;
                  'M' : BEGIN
                          MinByte := 0;
                          MaxByte := 9;
                          TempB := UserColor;
                        END;
                  'N' : BEGIN
                          MinInt := 1;
                          MaxInt := 32767;
                          TempI := MinSpaceForPost;
                        END;
                  'O' : BEGIN
                          MinInt := 1;
                          MaxInt := 32767;
                          TempI := MinSpaceForUpload;
                        END;
                  'P' : BEGIN
                          MinByte := 1;
                          MaxByte := 255;
                          TempB := BackSysOpLogs;
                        END;
                  'R' : BEGIN
                          MinByte := 0;
                          MaxByte := 60;
                          TempB := WFCBlankTime;
                        END;
                  'S' : BEGIN
                          MinByte := 0;
                          MaxByte := 60;
                          TempB := AlertBeep;
                        END;
                  'T' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 2147483647;
                          TempL := CallerNum;
                        END;
                  'U' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 115200;
                          TempL := MinimumBaud;
                        END;
                  'V' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 115200;
                          TempL := MinimumDLBaud;
                        END;
                  'W' : BEGIN
                          MinByte := 1;
                          MaxByte := 255;
                          TempB := SliceTimer;
                        END;
                  'X' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxDepositEver;
                        END;
                  'Y' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxDepositPerDay;
                        END;
                  'Z' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxWithdrawalPerDay
                        END;
                END;
                CASE Cmd OF
                  'H','K','N'..'O' :
                        InputIntegerWOC('^0%LFNew Value',TempI,[NumbersOnly],MinInt,MaxInt);
                  'T'..'V','X'..'Z' :
                        InputLongIntWOC('^0%LFNew Value',TempL,[DisplayValue,NumbersOnly],MinLongInt,MaxLongInt);
                ELSE
                  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
                END;
                CASE Cmd OF
                  'A' : MaxPrivPost := TempB;
                  'B' : MaxFBack := TempB;
                  'C' : MaxPubPost := TempB;
                  'D' : MaxChat := TempB;
                  'E' : MaxWaiting := TempB;
                  'F' : CSMaxWaiting := TempB; (* Not Hooked Up *)
                  'G' : MaxMassMailList := TempB;
                  'H' : BirthDateCheck := TempI;
                  'J' : MaxLogonTries := TempB;
                  'K' : PasswordChange := TempI;
                  'L' : SysOpColor := TempB;
                  'M' : UserColor := TempB;
                  'N' : MinSpaceForPost := TempI;
                  'O' : MinSpaceForUpload := TempI;
                  'P' : BackSysOpLogs := TempB;
                  'R' : WFCBlankTime := TempB;
                  'S' : AlertBeep := TempB;
                  'T' : CallerNum := TempL;
                  'U' : MinimumBaud := TempL;
                  'V' : MinimumDLBaud := TempL;
                  'W' : SliceTimer := TempB;
                  'X' : MaxDepositEver := TempL;
                  'Y' : MaxDepositPerDay := TempL;
                  'Z' : MaxWithDrawalPerDay := TempL;
                END;
              END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
