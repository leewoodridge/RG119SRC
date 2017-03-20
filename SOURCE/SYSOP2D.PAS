{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2D;

INTERFACE

PROCEDURE SystemGeneralVariables;

IMPLEMENTATION

USES
  Common;

PROCEDURE SystemGeneralVariables;
VAR
  Cmd: Char;
  TempB,
  MinByte,
  MaxByte: Byte;
  TempI,
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
    Prompt('|15"|15');
    FOR Counter := 1 TO Length(S) DO
      IF (S[Counter] >= ' ') THEN
        TempStr := TempStr + S[Counter]
      ELSE
        TempStr := TempStr +  '^3^'+Chr(Ord(S[Counter]) + 64)+'|15';
    Prompt(PadLeftStr(TempStr,MaxLen)+'|15"');
  END;

  PROCEDURE MMacroo(MacroNum: Byte);
  VAR
    S: AStr;
    C: Char;
    Counter: Byte;
  BEGIN
    Print('%CL|15Enter new F'+IntToStr(MacroNum + 1)+' macro now.');
    Print('|15Enter ^Z to end recording. 100 character limit.%LF');
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
            Prompt('^3^'+Chr(Ord(C) + 64)+'|15');
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
      PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : System Variables',80));
	  
      PrintACR('|07(|15A|07) Max Private Sent Per Call  : |15'+PadLeftInt(MaxPrivPost,6)+
               '|07(|15B|07) Max Feedback Sent Per Call : |15'+PadLeftInt(MaxFBack,6));
      PrintACR('|07(|15C|07) Max Public Posts Per Call  : |15'+PadLeftInt(MaxPubPost,6)+
               '|07(|15D|07) Max Chat Attempts Per Call : |15'+PadLeftInt(MaxChat,6));
      PrintACR('|07(|15E|07) Normal Max Mail Waiting    : |15'+PadLeftInt(MaxWaiting,6)+
               '|07(|15F|07) CoSysOp Max Mail Waiting   : |15'+PadLeftInt(CSMaxWaiting,6));
      PrintACR('|07(|15G|07) Max Mass Mail List         : |15'+PadLeftInt(MaxMassMailList,6)+
               '|07(|15H|07) Logins Before BDay Check   : |15'+PadLeftInt(BirthDateCheck,6));
      PrintACR('|07(|15I|07) Swap shell should use      : |15'+PadLeftStr(DisplaySwapTo(SwapTo),6)+
               '|07(|15J|07) Number Of Logon Attempts   : |15'+PadLeftInt(MaxLogonTries,6));
      PrintACR('|07(|15K|07) Password Change In Days    : |15'+PadLeftInt(PasswordChange,6)+
               '|07(|15L|07) SysOp Chat Color           : |15'+PadLeftInt(SysOpColor,6));
      PrintACR('|07(|15M|07) User Chat Color            : |15'+PadLeftInt(UserColor,6)+
               '|07(|15N|07) Min. space for posts       : |15'+PadLeftInt(MinSpaceForPost,6));
      PrintACR('|07(|15O|07) Min. space for uploads     : |15'+PadLeftInt(MinSpaceForUpload,6)+
               '|07(|15P|07) Back SysOp Log keep days   : |15'+PadLeftInt(BackSysOpLogs,6));
      PrintACR('|07(|15R|07) Blank WFC Menu Minutes     : |15'+PadLeftInt(WFCBlankTime,6)+
               '|07(|15S|07) Alert Beep Delay           : |15'+PadLeftInt(AlertBeep,6));
      PrintACR('|07(|15T|07) Number Of System Callers   : |15'+PadLeftInt(CallerNum,6)+
               '|07(|15U|07) Minimum Logon Baud Rate    : |15'+PadLeftInt(MinimumBaud,6));
      PrintACR('|07(|15V|07) Minimum DL Baud Rate       : |15'+PadLeftInt(MinimumDLBaud,6)+
               '|07(|15W|07) Sec''s Between Time Slices  : |15'+PadLeftInt(SliceTimer,6));
      PrintACR('|07(|15X|07) TB Max Time Allowed        : |15'+PadLeftInt(MaxDepositEver,6)+
               '|07(|15Y|07) TB Max Daily Deposit       : |15'+PadLeftInt(MaxDepositPerDay,6));
      PrintACR('|07(|15Z|07) TB Max Daily Withdraw      : |15'+PadLeftInt(MaxWithDrawalPerDay,6));
      NL;
      FOR TempB := 0 TO 9 DO
      BEGIN
        Prompt('|15'+IntToStr(TempB)+'. F'+IntToStr(TempB + 1)+' Macro :|15');
        DisplayMacroo(Macro[TempB],21);
        IF Odd(TempB) THEN
          NL
        ELSE
          Prompt('   ');
      END;
	  Nl;
      Prt('|07Enter Selection or (|15Q|07) to Quit: |15');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1234567890',TRUE,TRUE);
      CASE Cmd OF
        '0'..'9' :
              MMacroo(Ord(Cmd) - Ord('0'));
        'I' : BEGIN
                Print('%LF|15Swap locations:|15');
                Print('%LF|15(^3D|15)isk');
                Print('|15(^3E|15)MS');
                Print('|15(^3X|15)MS');
                Print('|15(^3N|15)on XMS Extended');
                Print('|15(^3A|15)ny');
                lOneK('%LFSwap to which? [|15D^4,|15E^4,|15X^4,|15N^4,|15A^4,|15<CR>^4=|15Quit^4]: ',Cmd,'DEXNA'^M,TRUE,TRUE);
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
                        InputIntegerWOC('%LFNew value',TempI,[NumbersOnly],MinInt,MaxInt);
                  'T'..'V','X'..'Z' :
                        InputLongIntWOC('%LFNew value',TempL,[DisplayValue,NumbersOnly],MinLongInt,MaxLongInt);
                ELSE
                  InputByteWOC('%LFNew value',TempB,[NumbersOnly],MinByte,MaxByte);
                END;
                CASE Cmd OF
                  'A' : MaxPrivPost := TempB;
                  'B' : MaxFBack := TempB;
                  'C' : MaxPubPost := TempB;
                  'D' : MaxChat := TempB;
                  'E' : MaxWaiting := TempB;
                  'F' : CSMaxWaiting := TempB; (* Not Hooked Up *)
                  'G' : MaxMassMailList := TempB;
                  'H' : BEGIN
                          BirthDateCheck := TempI;
                          (*
                          IF (BirthDateCheck = 0) THEN
                            NewUserToggles[9] := 0
                          ELSE
                            NewUserToggles[9] := 2;
                          *)
                        END;
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
