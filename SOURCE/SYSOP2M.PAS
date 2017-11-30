
(*	RENEGADE BBS: NEW USER TOGGLES *)

UNIT SysOp2M;

INTERFACE

PROCEDURE NewUserTogglesConfiguration;

IMPLEMENTATION

USES
  CRT,
  Common,
  MiscUser;

PROCEDURE NewUserTogglesConfiguration;
  VAR
    Cmd: Char;
    Cmd1: Char;
    LowNum,
    HiNum,
    TempInt: SmallInt;
    Changed: Boolean;
  BEGIN
	REPEAT
	  Abort := FALSE;
	  Next := FALSE;
	  MCIAllowed := FALSE;
	  WITH General DO
		BEGIN
		  Cls;
		  Print(PadLeftStr('^2 '#240' Renegade BBS Configuration : New User Toggles',80));
		  Print('^0Here you can configure which questions and options you`d like new users to be');
		  Print('^0prompted on during their application');
		  NL;
		  PrintACR('^0(^1!^0) Refuse New Users : ^1'+PadLeftStr(ShowYesNo(ClosedSystem),3));
		  NL;
		  PrintACR('^0(^1A^0) Handle/Alias     : ^1'+PadLeftStr(ShowYesNo(AllowAlias),3)+'   '+
				   '^0(^1N^0) ANSI Colors      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[14]),3));
		  PrintACR('^0(^1B^0) Real Name        : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[2]),3)+'   '+
				   '^0(^1O^0) Color Scheme     : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[15]),3));
		  PrintACR('^0(^1C^0) Country          : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[3]),3)+'   '+
				   '^0(^1P^0) Screen Size      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[16]),3));
		  PrintACR('^0(^1D^0) City, State      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[4]),3)+'   '+
				   '^0(^1R^0) Screen Clearing  : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[17]),3));
		  PrintACR('^0(^1E^0) Address          : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[5]),3)+'   '+
				   '^0(^1S^0) Screen Pause     : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[18]),3));
		  PrintACR('^0(^1F^0) Zip Code         : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[6]),3)+'   '+
				   '^0(^1T^0) Hotkeys          : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[19]),3));
		  PrintACR('^0(^1G^0) Phone Number     : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[7]),3)+'   '+
				   '^0(^1U^0) QWK              : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[20]),3));
		  PrintACR('^0(^1H^0) Birthdate        : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[8]),3)+'   '+
				   '^0(^1V^0) Expert Mode      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[21]),3));
		  PrintACR('^0(^1I^0) Gender Identity  : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[9]),3)+'   '+
				   '^0(^1W^0) Forgot Password  : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[23]),3));
		  PrintACR('^0(^1J^0) Question #1      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[10]),3)+'   '+
				   '^0(^1X^0) New User Letter  : ^1'+PadLeftStr(AOnOff((NewApp = -1),'No','Yes^0 > #^1'+IntToStr(NewApp)+''),12));
		  PrintACR('^0(^1K^0) Question #2      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[11]),3)+'   '(*+
				   '^0(^1Y^0) UNUSED           : ^1'*));
		  PrintACR('^0(^1L^0) Question #3      : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[12]),3)+'   '(*+
				   '^0(^1Z^0) UNUSED           : ^1'*));
		  PrintACR('^0(^1M^0) Term Emulation   : ^1'+PadLeftStr(ShowYesNo(NewUserToggles[13]),3)+'   ');
		END;
	  MCIAllowed := TRUE;
	  NL;
	  Prt('^0New User Application Toggles [^1!^0,^1A^0-^1X^0,(^1Q^0)uit]: ^1');
	  OneK(Cmd,'!ABCDEFGHIJKLMNOPQRSTUVWX^',TRUE,TRUE);
	  WITH General DO
		CASE Cmd OF
		  '!' : ClosedSystem := NOT ClosedSystem;
		  'A' : BEGIN
				  AllowAlias := NOT AllowAlias;
				  IF AllowAlias = False THEN
					BEGIN
					  NewUserToggles[02] := True;
					  (*PrintACR('Also disabling Real Name field for new user application.'); { No need to ask twice }
					  PauseScr(False);*)
					END;
				END;
		  'B' : BEGIN
				  NewUserToggles[02] := NOT NewUserToggles[02];
				  IF NewUserToggles[02] = False THEN
					AllowAlias := True;
				END;
		  'C' : NewUserToggles[03] := NOT NewUserToggles[03];
		  'D' : NewUserToggles[04] := NOT NewUserToggles[04];
		  'E' : NewUserToggles[05] := NOT NewUserToggles[05];
		  'F' : NewUserToggles[06] := NOT NewUserToggles[06];
		  'G' : BEGIN
				  IF (NewUserToggles[7]) THEN
					BEGIN
					  NewUserToggles[7] := False;
					  NL;
					  Print('Also Disabling Phone Number In Login'); { Can`t verify something we don`t have }
					  PauseScr(False);
					  General.PhonePW := False;
					END
				  ELSE NewUserToggles[7] := True;
				END;
		  'H' : NewUserToggles[08] := NOT NewUserToggles[08];
		  'I' : NewUserToggles[09] := NOT NewUserToggles[09];
		  'J' : NewUserToggles[10] := NOT NewUserToggles[10];
		  'K' : NewUserToggles[11] := NOT NewUserToggles[11];
		  'L' : NewUserToggles[12] := NOT NewUserToggles[12];
		  'M' : NewUserToggles[13] := NOT NewUserToggles[13];
		  'N' : NewUserToggles[14] := NOT NewUserToggles[14];
		  'O' : NewUserToggles[15] := NOT NewUserToggles[15];
		  'P' : NewUserToggles[16] := NOT NewUserToggles[16];
		  'R' : NewUserToggles[17] := NOT NewUserToggles[17];
		  'S' : NewUserToggles[18] := NOT NewUserToggles[18];
		  'T' : NewUserToggles[19] := NOT NewUserToggles[19];
		  'U' : NewUserToggles[20] := NOT NewUserToggles[20];
		  'V' : NewUserToggles[21] := NOT NewUserToggles[21];
		  'W' : NewUserToggles[23] := NOT NewUserToggles[23];
		  'X' : BEGIN
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
					  Cmd := #0;
					END;
				END;
		  'Y' : PauseScr(FALSE);
		  'Z' : InputWN1(RGSysCfgStr(12,TRUE),NewUserPW,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed); {LW: ?}
		  '^' : BEGIN { LeeW: For my testing, remove later... }
				  NewUserToggles[01] := True;
				  NewUserToggles[22] := True;
				  Print('Username And Password Reset To True');
				  PauseScr(FALSE);
				END;
		END;
	  UNTIL (Cmd = 'Q') OR (HangUp);
  END;
END.

(* LeeW: Indenting done! *)