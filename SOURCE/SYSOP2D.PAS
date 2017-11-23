{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

(* RENEGADE BBS: SYSTEM VARIABLES *)

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

(*  FUNCTION DisplaySwapTo(SwapTo: Byte): Str4;
	BEGIN
	  CASE SwapTo OF
		0   : DisplaySwapTo := 'Disk';
		1   : DisplaySwapTo := 'XMS';
		2   : DisplaySwapTo := 'EMS';
		4   : DisplaySwapTo := 'EXT';
		255 : DisplaySwapTo := 'Any';
	  END;
	END;
*)
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
			Abort := FALSE;
			Next := FALSE;
			CLS;
			PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Variables',80));
			
			PrintACR('^0(^1C^0) Max Public Posts   : ^1'+PadLeftStr(AOnOff((MaxPubPost = 0),'Unlimited',
														IntToStr(MaxPubPost)+'^0 Per Day'),14)+
					 '^0(^1X^0) TBank Max Time     : ^1'+PadLeftStr(AOnOff((MaxDepositEver = 0),'Unlimited',
														IntToStr(MaxDepositEver)+'^0 '+Plural('Minute',MaxDepositEver)),14));
			PrintACR('^0(^1A^0) Max Private Msgs   : ^1'+PadLeftStr(IntToStr(MaxPrivPost)+'^0 Per Day',14)+
					 '^0(^1Y^0) TBank Max Deposit  : ^1'+PadLeftStr(AOnOff((MaxDepositPerDay = 0),'Unlimited',
														IntToStr(MaxDepositPerDay)+'^0 '+Plural('Minute',MaxDepositPerDay)),14));
			PrintACR('^0(^1B^0) Max Feedback       : ^1'+PadLeftStr(IntToStr(MaxFBack)+'^0 Per Day',14)+
					 '^0(^1Z^0) TBank Max Withdraw : ^1'+PadLeftStr(AOnOff((MaxWithdrawalPerDay = 0),'Unlimited',
														IntToStr(MaxWithdrawalPerDay)+'^0 '+Plural('Minute',MaxWithdrawalPerDay)),14));
			PrintACR('^0(^1E^0) Max Mail Waiting   : ^1'+PadLeftInt(MaxWaiting,14)+
					 '');
			PrintACR('^0(^1G^0) Max Mass Mail List : ^1'+PadLeftStr(IntToStr(MaxMassMailList)+'^0 Users',14)+
					 '');
			PrintACR('^0(^1D^0) Max Chat Attempts  : ^1'+PadLeftStr(IntToStr(MaxChat)+'^0 Per Day',14)+
					 '');
			PrintACR('^0(^1K^0) PW Change Interval : ^1'+PadLeftStr(AOnOff((PasswordChange = 0),'Never',
														IntToStr(PasswordChange)+'^0 '+Plural('Day',PasswordChange)),14)+
					 '');
			PrintACR('^0(^1H^0) BD Check Interval  : ^1'+PadLeftStr(AOnOff((BirthDateCheck = 0),'Never',
														IntToStr(BirthDateCheck)+'^0 '+Plural('Login',BirthDateCheck)),14)+
					 '');
			PrintACR('^0(^1J^0) Max Login Attempts : ^1'+PadLeftInt(MaxLogonTries,14)+
					 '');
			PrintACR('^0(^1@^0) Idle Warn/Timeout  : ^1'+PadLeftStr(AOnOff((TimeOutBell = -1),'Never',IntToStr(TimeOutBell))+
														'^0/^1'+AOnOff((TimeOut = -1),'Never',IntToStr(TimeOut)+
														'^0 Mins'),14)+ {LeeW: This isn't right! }
					 '');
			PrintACR('^0(^1F^0) Pre-Event Warning  : ^1'+PadLeftStr(AOnOff((EventWarningTime = 0),'None',IntToStr(EventWarningTime)+
														'^0 '+Plural('Second',EventWarningTime)),14)+
					 '');

(*	'^0(^1P^0) SysOp Log Length   : ^1'+PadLeftStr(IntToStr(BackSysOpLogs)+'^0 '+Plural('Day',BackSysOpLogs),14));  
	'^0(^1R^0) Blank WFC Menu     : ^1'+PadLeftStr(AOnOff((WFCBlankTime = 0),'Never',
									IntToStr(WFCBlankTime)+'^0 Min(s)'),14));
	PrintACR('^0(^1N^0) Min Free For Posts : ^1'+PadLeftStr(IntToStr(MinSpaceForPost)+'^0 kB',14)+
	PrintACR('^0(^1S^0) Alert Delay        : ^1'+PadLeftStr(IntToStr(AlertBeep)+'^0 Sec(s)',14)+ 
	PrintACR('^0(^1W^0) Sec Btwen Tm Slcs  : ^1'+PadLeftInt(SliceTimer,14));	  
	PrintACR('^0(^1L^0) Chat Colors        : ^1'+PadLeftInt(SysOpColor,1)+'^0/^1'+PadLeftInt(UserColor,1));*)

	(*'^0(^1F^0) Max Mail Waiting (CoSysOp+): ^1'+PadLeftInt(CSMaxWaiting,7) { LeeW: Is this even implemented? }*)

	(*
	  alert delay, time slice, swap loc should be in main cfg
	  chat colors should be in color config
	*)

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
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1234567890!@#',TRUE,TRUE);
      CASE Cmd OF
	  'F' : InputByteWOC(RGSysCfgStr(14,TRUE),EventWarningTime,[DisplayValue,NumbersOnly],0,255);
		'@' : BEGIN
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
        '0'..'9' :
              MMacroo(Ord(Cmd) - Ord('0'));
        'I' : BEGIN
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
                  (*'F' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := CSMaxWaiting;
				  END;*)
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
                          MinByte := 1;
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
						  TempB2 := UserColor;
                        END;
                  'M' : BEGIN
                          PauseScr(FALSE);
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
				  'L' : BEGIN
						  InputByteWOC('^0%LFSysOp Chat Color',TempB,[NumbersOnly],MinByte,MaxByte);
						  InputByteWOC('^0%LFUser Chat Color',TempB2,[NumbersOnly],MinByte,MaxByte);
						END						
                ELSE
                  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
                END;
                CASE Cmd OF
                  'A' : MaxPrivPost := TempB;
                  'B' : MaxFBack := TempB;
                  'C' : MaxPubPost := TempB;
                  'D' : MaxChat := TempB;
                  'E' : MaxWaiting := TempB;
                  {'F' : CSMaxWaiting := TempB; (* Not Hooked Up *)}
                  'G' : MaxMassMailList := TempB;
                  'H' : BirthDateCheck := TempI;
                  'J' : MaxLogonTries := TempB;
                  'K' : PasswordChange := TempI;
                  'L' : BEGIN
					      SysOpColor := TempB;
						  UserColor := TempB2;
						END;
                  'M' : PauseScr(FALSE);
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
