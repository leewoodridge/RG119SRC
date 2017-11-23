
{ System Toggles }

(*  1.  Add checking for deleted users or forwarded mail to option 1 *)
{
	implement lastcallersinlogon and onelinersinlogon in login procedure
	}

UNIT SysOp2E;

INTERFACE

PROCEDURE SystemFlaggedFunctions;

IMPLEMENTATION

USES
  Crt,
  Common,
  MiscUser;

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

  
  
PROCEDURE SystemFlaggedFunctions;
  VAR
	Cmd,
	Cmd1: Char;
	LowNum,
	HiNum,
	TempInt: SmallInt;
  BEGIN
	REPEAT
	  WITH General DO
		BEGIN
		  Abort := FALSE;
		  Next := FALSE;
		  ClrScr;
		  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Toggles',80));
		  
		  PrintACR('^0(^1C^0) Local Security Protection : ^1'+PadLeftStr(ShowOnOff(LocalSec),7)+
				   '- Login Procedure -');
		  PrintACR('^0(^1D^0) Use EMS For Overlay File  : ^1'+PadLeftStr(ShowOnOff(UseEMS),7)+
				   '^0(^1B^0) Phone Number In Logon     : ^1'+PadLeftStr(ShowOnOff(PhonePW),7));
		  PrintACR('^0(^1E^0) Global Activity Trapping  : ^1'+PadLeftStr(ShowOnOff(GlobalTrap),7)+
				   '^0(^1G^0) AutoMessage In Logon      : ^1'+PadLeftStr(ShowOnOff(AutoMInLogon),7));
		  PrintACR('^0(^1F^0) Auto Chat Buffer Open     : ^1'+PadLeftStr(ShowOnOff(AutoChatOpen),7)+
				   '^0(^1H^0) Bulletins In Logon        : ^1'+PadLeftStr(ShowOnOff(BullInLogon),7));
		  PrintACR('^0(^1J^0) Strip Color Off SysOp Log : ^1'+PadLeftStr(ShowOnOff(StripCLog),7)+
				   '^0(^1I^0) User Info In Logon        : ^1'+PadLeftStr(ShowOnOff(YourInfoInLogon),7));
		  PrintACR('^0(^1K^0) Offhook In Local Logon    : ^1'+PadLeftStr(ShowOnOff(OffHookLocalLogon),7)+
				   '^0(^1W^0) Random Quote In Logon     : ^1'+PadLeftStr(ShowOnOff(LogonQuote),7));
		  PrintACR('^0(^1L^0) Trap Teleconferencing     : ^1'+PadLeftStr(ShowOnOff(TrapTeleConf),7)+
				   '^0(^1X^0) User Add Quote In Logon   : ^1'+PadLeftStr(ShowOnOff(UserAddQuote),7));
		  PrintACR('^0(^1M^0) Compress File/Msg Numbers : ^1'+PadLeftStr(ShowOnOff(CompressBases),7)+
				   '^0(^1S^0) Use Shuttle Logon         : ^1'+PadLeftStr(ShowOnOff(ShuttleLog),7));
		  PrintACR('^0(^1N^0) Use BIOS For Video Output : ^1'+PadLeftStr(ShowOnOff(UseBIOS),7)+
				   '^0(^1Z^0) Unval Log In From Shuttle : ^1'+PadLeftStr(ShowYesNo(ShuttleUnvalLogin),7));
		  PrintACR('^0(^1O^0) Use IEMSI Handshakes      : ^1'+PadLeftStr(ShowOnOff(UseIEMSI),7)+
				   '^0(^1!^0) Last Callers In Logon     : ^1'+PadLeftStr(ShowOnOff(LastCallersInLogon),7));
		  PrintACR('^0(^1R^0) Swap Shell Function       : ^1'+PadLeftStr(ShowOnOff(SwapShell)+'^0 > ^1'+
															 DisplaySwapTo(SwapTo),10)+
				   '');
(* LeeW: Don't display "swap to" location if disabled ^ *)
(* LeeW: Maybe "force batch ul/dl" should be with logon secq *)
		  PrintACR('^0(^1T^0) Chat Call Paging          : ^1'+PadLeftStr(ShowOnOff(ChatCall),7)+
				   '^0(^1@^0) OneLiners In Logon        : ^1'+PadLeftStr(ShowOnOff(OneLinersInLogon),7));
		  PrintACR('^0(^1U^0) Time Limits Are Per Call  : ^1'+PadLeftStr(ShowOnOff(PerCall),7)+
				   '^0(^1#^0) Vote In Logon             : ^1'+PadLeftStr(ShowOnOff(VoteInLogon),7));
		  PrintACR('^0(^1V^0) SysOp Password Checking   : ^1'+PadLeftStr(ShowOnOff(SysOpPWord),7)+
				   '');
		  PrintACR('^0(^1Y^0) Use Lightbars             : ^1'+PadLeftStr(ShowOnOff(UseLightBars),7)+
				   '');
		  NL;
		  Prt('^0Enter Selection Or (^1Q^0) To Quit: ^1');
		  OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ!@#',TRUE,TRUE);
		  CASE Cmd OF
			'!' : LastCallersInLogon := NOT LastCallersInLogon;
			'@' : OneLinersInLogon := NOT OneLinersInLogon;
			'#' : VoteInLogon := NOT VoteInLogon;
			'A' : PauseScr(FALSE);
			'B' : BEGIN
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
			'C' : LocalSec := NOT LocalSec;
			'D' : BEGIN
					UseEMS := NOT UseEMS;
					IF (UseEMS) THEN
					  OvrUseEMS := TRUE
					ELSE
					  OvrUseEMS := FALSE;
				  END;
			'E' : GlobalTrap := NOT GlobalTrap;
			'F' : AutoChatOpen := NOT AutoChatOpen;
			'G' : AutoMInLogon := NOT AutoMInLogon;
			'H' : BullInLogon := NOT BullInLogon;
			'I' : YourInfoInLogon := NOT YourInfoInLogon;
			'J' : StripCLog := NOT StripCLog;
			'K' : OffHookLocalLogon := NOT OffHookLocalLogon;
			'L' : TrapTeleConf := NOT TrapTeleConf;
			'M' : BEGIN
					CompressBases := NOT CompressBases;
					IF (CompressBases) THEN
					  Print('^0%LFCompressing File & Message Areas ...')
					ELSE
					  Print('^0%LFDe-Compressing File & Message Areas ...');
					NewCompTables;
					PauseScr(FALSE);
				  END;
			'N' : BEGIN
					UseBIOS := NOT UseBIOS;
					DirectVideo := NOT UseBIOS;
				  END;
			'O' : UseIEMSI := NOT UseIEMSI;
			'P' : ClosedSystem := NOT ClosedSystem;
			'R' : BEGIN
					IF PYNQ('Swap Shell? ',0,FALSE) THEN
					  BEGIN
						SwapShell := TRUE;
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
					  END
					ELSE
					  SwapShell := FALSE;
				  END;
			'S' : ShuttleLog := NOT ShuttleLog;
			'T' : ChatCall := NOT ChatCall;
			'U' : PerCall := NOT PerCall;
			'V' : SysOpPWord := NOT SysOpPWord;
			'W' : LogonQuote := NOT LogonQuote;
			'X' : UserAddQuote := NOT UserAddQuote;
			'Y' : UseLightBars := NOT UseLightBars;
			'Z' : ShuttleUnvalLogin := NOT ShuttleUnvalLogin;
		  END;
		END;
	UNTIL (Cmd = 'Q') OR (HangUp);
  END;

END.
(* LeeW: Indenting done! *)