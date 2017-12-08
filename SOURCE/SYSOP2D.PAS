{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

(* RENEGADE BBS: SYSTEM VARIABLES *)
	(*
	  chat colors should be in color config
	*)

UNIT SysOp2D;

INTERFACE

PROCEDURE SystemGeneralVariables;

IMPLEMENTATION

USES
  Common;

PROCEDURE GetTimeRange(CONST RGStrNum: LongInt; VAR LoTime,HiTime: SmallInt);
  VAR
    TempStr: Str5;
    LowTime,
    HighTime: Integer;
  BEGIN
    IF (NOT (PYNQ(RGSysCfgStr(RGStrNum,TRUE),0,FALSE))) THEN
    BEGIN
      LowTime := 0;
      HighTime := 0;
    END
    ELSE
    BEGIN
      NL;
      Print('All entries in 24 hour time.  Hour: (0-23), Minute: (0-59)');
      NL;
      Prt('Starting time: ');
      MPL(5);
      InputFormatted('',TempStr,'##:##',TRUE);
      IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
        LowTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)))
      ELSE
        LowTime := 0;
      NL;
      Prt('Ending time: ');
      MPL(5);
      InputFormatted('',TempStr,'##:##',TRUE);
      IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
        HighTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)))
      ELSE
        HighTime := 0;
    END;
    NL;
    Print('Hours: '+PHours('Always allowed',LowTime,HighTime));
    NL;
    IF PYNQ('Are you sure this is what you want? ',0,FALSE) THEN
    BEGIN
      LoTime := LowTime;
      HiTime := HighTime;
    END;
  END;
  
PROCEDURE SystemGeneralVariables;
  VAR
	Cmd,
	Cmd1: Char;
	TempIdle: String;
	TempB,
	TempB2, { LeeW: Added }
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

  PROCEDURE DisplayMacroo(CONST S: AStr; MaxLen: Byte);
	VAR
	  TempStr: AStr;
	  Counter: Byte;
	BEGIN
	  TempStr := '';
	  Prompt('^0"^1');
	  FOR Counter := 1 TO Length(S) DO
		IF (S[Counter] >= ' ') THEN
		  TempStr := TempStr + S[Counter]
		ELSE
		  TempStr := TempStr +  '^'+Chr(Ord(S[Counter]) + 64);
		Prompt(PadLeftStr(TempStr,MaxLen)+'^0"');
	END;

  PROCEDURE MMacroo(MacroNum: Byte);
	VAR
	  S: AStr;
	  C: Char;
	  Counter: Byte;
	BEGIN
	  CLS;
	  Print('^0Recording F'+IntToStr(MacroNum + 1)+' macro, press Ctrl+Z when finished. (100 character limit)');
	  NL;
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
	  NL;
	  NL;
	  Print('^0Your F'+IntToStr(MacroNum + 1)+' macro is now:');
	  NL;
	  DisplayMacroo(S,160);
	  Com_Flush_Recv;
	  IF (NOT PYNQ('^0%LFIs this what you want? ',0,FALSE)) THEN
		Print('^0%LFMacro aborted')
	  ELSE
		BEGIN
		  General.Macro[MacroNum] := S;
		  Print('^0%LFYour F'+IntToStr(MacroNum + 1)+' Macro has been saved'); { LeeW: Check this }
		END;
	  PauseScr(FALSE);
	END;
(* LeeW: Indenting done! *)
	BEGIN
	  REPEAT
		WITH General DO		
		  BEGIN
			IF (TimeOutBell = -1) AND (TimeOut = -1) THEN
			  TempIdle := '^1Never'
			ELSE IF (TimeOutBell = -1) AND (TimeOut > 0) THEN
			  TempIdle := '^1Never^0/^1'+IntToStr(TimeOut)+' ^0Minutes'
			ELSE IF (TimeOutBell > 0) AND (TimeOut = -1) THEN
			  TempIdle := '^1'+IntToStr(TimeOutBell)+'^0 Mins/^1Never'
			ELSE IF (TimeOutBell > 0) AND (TimeOut > 0) THEN
			  TempIdle := '^1'+IntToStr(TimeOutBell)+'^0/^1'+IntToStr(TimeOut)+' ^0Minutes';
			
			Abort := FALSE;
			Next := FALSE;
			CLS;
			PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Variables',80));
			
			PrintACR('^0(^1A^0) Max Public Posts   : ^1'+PadLeftStr(AOnOff((MaxPubPost = 0),'Unlimited',
														IntToStr(MaxPubPost)+'^0 Per Day'),14)+
					 '^0(^1N^0) TBank Max Time     : ^1'+PadLeftStr(AOnOff((MaxDepositEver = 0),'Unlimited',
														IntToStr(MaxDepositEver)+'^0 '+Plural('Minute',MaxDepositEver)),14));
			PrintACR('^0(^1B^0) Max Private Msgs   : ^1'+PadLeftStr(IntToStr(MaxPrivPost)+'^0 Per Day',14)+
					 '^0(^1O^0) TBank Max Deposit  : ^1'+PadLeftStr(AOnOff((MaxDepositPerDay = 0),'Unlimited',
														IntToStr(MaxDepositPerDay)+'^0 '+Plural('Minute',MaxDepositPerDay)),14));
			PrintACR('^0(^1C^0) Max Feedback       : ^1'+PadLeftStr(IntToStr(MaxFBack)+'^0 Per Day',14)+
					 '^0(^1P^0) TBank Max Withdraw : ^1'+PadLeftStr(AOnOff((MaxWithdrawalPerDay = 0),'Unlimited',
														IntToStr(MaxWithdrawalPerDay)+'^0 '+Plural('Minute',MaxWithdrawalPerDay)),14));
			PrintACR('^0(^1D^0) Max Mail Waiting   : ^1'+PadLeftInt(MaxWaiting,14)+
					 '^0(^1R^0) Time Limits Are    : ^1'+PadLeftStr(AOnOff((PerCall = FALSE),'Per Day','Per Call'),14));
			PrintACR('^0(^1E^0) Max Mass Mail List : ^1'+PadLeftStr(IntToStr(MaxMassMailList)+'^0 Users',14)+
					 '^0(^1S^0) Lightbars          : ^1'+PadLeftStr(AOnOff((UseLightBars),'Enabled','Disabled'),14));
			PrintACR('^0(^1F^0) Max Chat Attempts  : ^1'+PadLeftStr(IntToStr(MaxChat)+'^0 Per Day',14)+
					 '^0(^1T^0) SysOp Chat Hours   : ^1'+PadLeftStr(PHours('Any Time',lLowTime,HiTime),14));
			PrintACR('^0(^1G^0) PW Change Interval : ^1'+PadLeftStr(AOnOff((PasswordChange = 0),'Never',
														IntToStr(PasswordChange)+'^0 '+Plural('Day',PasswordChange)),14)+
					 '^0(^1U^0) Download Hours     : ^1'+PadLeftStr(PHours('Any Time',DLLowTime,DLHiTime),14));
			PrintACR('^0(^1H^0) BD Check Interval  : ^1'+PadLeftStr(AOnOff((BirthDateCheck = 0),'Never',
														IntToStr(BirthDateCheck)+'^0 '+Plural('Login',BirthDateCheck)),14)+
					 '^0(^1V^0) Minimum Baud       : ^1'+PadLeftStr(IntToStr(MinimumBaud),14));
			PrintACR('^0(^1I^0) PH Check           : ^1'+PadLeftStr(ShowOnOff(PhonePW),14)+
					 '^0    Hours For Less     : ^1'+PadLeftStr(PHours('Any Time',MinBaudLowTime,MinBaudHiTime),14)); { min baud hours }
			PrintACR('^0(^1J^0) SysOp PW Check     : ^1'+PadLeftStr(ShowOnOff(SysOpPWord),14)+
					 '^0(^1W^0) Minimum Baud To DL : ^1'+PadLeftStr(IntToStr(MinimumDLBaud),14));
			PrintACR('^0(^1K^0) Max Login Attempts : ^1'+PadLeftInt(MaxLogonTries,14)+
					 '^0    Hours For Less     : ^1'+PadLeftStr(PHours('Any Time',MinBaudDLLowTime,MinBaudDLHiTime),14));
			PrintACR('^0(^1L^0) Idle Warn/Timeout  : ^1'+PadLeftStr(TempIdle,14)+
					 '^0(^1X^0) Min Free For Posts : ^1'+PadLeftStr(IntToStr(MinSpaceForPost)+'^0 KB',14));
			PrintACR('^0(^1M^0) Pre-Event Warning  : ^1'+PadLeftStr(AOnOff((EventWarningTime = 0),'None',IntToStr(EventWarningTime)+
														'^0 '+Plural('Second',EventWarningTime)),14)+
					 '');
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
	  NL;
      Prt('^0Enter Selection or (^1Q^0) to Quit: ^1');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1234567890',TRUE,TRUE);
      CASE Cmd OF
		'X' : BEGIN
				MinInt := 1;
				MaxInt := 32767;
				TempI := MinSpaceForPost;
				InputIntegerWOC('^0%LFNew Value',TempI,[NumbersOnly],MinInt,MaxInt);
				MinSpaceForPost := TempI;
			  END;
		'T' : IF (InCom) THEN
                RGNoteStr(1,FALSE)
              ELSE
                GetTimeRange(6,lLowTime,HiTime);
        'V' : begin
				MinLongInt := 0;
                MaxLongInt := 115200;
                TempL := MinimumBaud;
				InputLongIntWOC('^0%LFNew Value',TempL,[DisplayValue,NumbersOnly],MinLongInt,MaxLongInt);
				MinimumBaud := TempL;
			    GetTimeRange(7,MinBaudLowTime,MinBaudHiTime);
			  end;
        'U' : GetTimeRange(8,DLLowTime,DLHiTime);
        'W' : BEGIN
				MinLongInt := 0;
                MaxLongInt := 115200;
                TempL := MinimumDLBaud;
				InputLongIntWOC('^0%LFNew Value',TempL,[DisplayValue,NumbersOnly],MinLongInt,MaxLongInt);
				MinimumDLBaud := TempL;
				GetTimeRange(9,MinBaudDLLowTime,MinBaudDLHiTime);
			  END;
	  
	  
	  
	  {-=-=}
	  
	  'M' : InputByteWOC(RGSysCfgStr(14,TRUE),EventWarningTime,[DisplayValue,NumbersOnly],0,255);
		'L' : BEGIN
			    { LeeW: Set the timeout warning time }
			    Cmd := #0;
			    Cmd1 := #0;
				LowNum := 1;
                HiNum := 20;
				NL;
				Prt('^0Idle Timeout Warning: (^1E^0)nable, (^1D^0)isable, <^1CR^0> Abort: ^1');
				OneK(Cmd1,^M'ED',TRUE,TRUE);
				IF (Cmd1 IN ['E','D']) THEN
				  BEGIN
				    CASE Cmd1 OF
					  'E' : InputIntegerWOC('^0%LFHow many minutes idle before timeout warning?',TempInt,[NumbersOnly],LowNum,HiNum);
					  'D' : TempInt := -1;
					END;
				  TimeOutBell := TempInt;
				END;
				{ LeeW: Set the timeout time }
				Cmd := #0;
			    Cmd1 := #0;
				NL;
				Prt('^0Idle Timeout: (^1E^0)nable, (^1D^0)isable, <^1CR^0> Abort ^1');
				OneK(Cmd1,^M'ED',TRUE,TRUE);
				IF (Cmd1 IN ['E','D']) THEN
				  BEGIN
				    CASE Cmd1 OF
					  'E' : InputIntegerWOC('^0%LFHow many minutes idle before timeout?',TempInt,[NumbersOnly],LowNum,HiNum);
					  'D' : TempInt := -1;
					END;
				  TimeOut := TempInt;
			  END;
		  END;
			'I' : BEGIN
					PhonePW := NOT PhonePW;
					IF (PhonePW) THEN
					  BEGIN
						{ If we`re going to verify phone numbers, users will need to provide them, so we`ll also ask
						  for phone numbers in new user application. }
						NewUserToggles[7] := True;
						Print('Also Enabling Phone Number In New User Application.');
						PauseScr(False);
					  END
				  END;
			'R' : PerCall := NOT PerCall;
			'J' : SysOpPWord := NOT SysOpPWord;
			'S' : UseLightBars := NOT UseLightBars;
        '0'..'9' :
              MMacroo(Ord(Cmd) - Ord('0'));
        'T' : BEGIN
				NL;
                Print('^0Swap Locations:');
				NL;
                Print('^0(^1D^0)isk');
                Print('^0(^1E^0)MS');
                Print('^0(^1X^0)MS');
                Print('^0(^1N^0)on XMS Extended');
                Print('^0(^1A^0)ny');
				NL;
                lOneK('^0Swap To Which? [<CR>Quit]: ',Cmd,'DEXNA'^M,TRUE,TRUE);
                CASE Pos(Cmd,'DXENA') OF
                  1..3 : SwapTo := (Pos(Cmd,'DXE') - 1);
                     4 : SwapTo := 4;
                     5 : SwapTo := 255;
                END;
                Cmd := #0;
              END;
        'A'..'F','m','h'{},'g','k','u','v','w'{},'N'..'P' :
              BEGIN
                CASE Cmd OF
                  'B' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPrivPost;
                        END;
                  'C' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxFBack;
                        END;
                  'A' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPubPost;
                        END;
                  'F' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxChat;
                        END;
                  'D' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxWaiting;
                        END;
                  (*'F' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := CSMaxWaiting;
				  END;*)
                  'E' : BEGIN
                          MinByte := 2;
                          MaxByte := 255;
                          TempB := MaxMassMailList;
                        END;
                  'H' : BEGIN
                          MinInt := 0;
                          MaxInt := 365;
                          TempI := BirthDateCheck;
                        END;
                  'K' : BEGIN
                          MinByte := 1;
                          MaxByte := 255;
                          TempB := MaxLogonTries;
                        END;
                  'G' : BEGIN
                          MinInt := 0;
                          MaxInt := 32767;
                          TempI := PasswordChange;
                        END;

                  'V' : BEGIN
                          PauseScr(FALSE);
						END;

                 {'O' : BEGIN
                          MinInt := 1;
                          MaxInt := 32767;
                          TempI := MinSpaceForUpload;
				 END;}
                { 'P' : BEGIN
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
				END;}
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
                  'N' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxDepositEver;
                        END;
                  'O' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxDepositPerDay;
                        END;
                  'P' : BEGIN
                          MinLongInt := 0;
                          MaxLongInt := 6000;
                          TempL := MaxWithdrawalPerDay
                        END;
                END;
                CASE Cmd OF
                  'G','H','W' :
                        InputIntegerWOC('^0%LFNew Value',TempI,[NumbersOnly],MinInt,MaxInt);
                  'N'..'P' :
                        InputLongIntWOC('^0%LFNew Value',TempL,[DisplayValue,NumbersOnly],MinLongInt,MaxLongInt);
				  'U' : BEGIN
						  InputByteWOC('^0%LFSysOp Chat Color',TempB,[NumbersOnly],MinByte,MaxByte);
						  InputByteWOC('^0%LFUser Chat Color',TempB2,[NumbersOnly],MinByte,MaxByte);
						END						
                ELSE
                  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
                END;
                CASE Cmd OF
                  'B' : MaxPrivPost := TempB;
                  'C' : MaxFBack := TempB;
                  'A' : MaxPubPost := TempB;
                  'F' : MaxChat := TempB;
                  'D' : MaxWaiting := TempB;
                  {'F' : CSMaxWaiting := TempB; (* Not Hooked Up *)}
                  'E' : MaxMassMailList := TempB;
                  'H' : BirthDateCheck := TempI;
                  'K' : MaxLogonTries := TempB;
                  'G' : PasswordChange := TempI;
                  'U' : BEGIN
					      SysOpColor := TempB;
						  UserColor := TempB2;
						END;
                  {'V' : PauseScr(FALSE);}
                  'W' : MinSpaceForPost := TempI;
                  {'O' : MinSpaceForUpload := TempI;
                  'P' : BackSysOpLogs := TempB;
                  'R' : WFCBlankTime := TempB;
                  'S' : AlertBeep := TempB;
                  'T' : CallerNum := TempL;}
                  'U' : MinimumBaud := TempL;
                  'V' : MinimumDLBaud := TempL;
                  {'W' : SliceTimer := TempB;}
                  'N' : MaxDepositEver := TempL;
                  'O' : MaxDepositPerDay := TempL;
                  'P' : MaxWithDrawalPerDay := TempL;
                END;
              END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
