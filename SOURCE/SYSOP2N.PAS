{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  --------------
  LOGIN SEQUENCE 
  --------------
  
  TO-DO:
	cfg what sl can log on from shuttle mnu
  (* LeeW: Maybe "force batch ul/dl" should be with logon secq *)
  }

  
  
UNIT SysOp2N;

INTERFACE

PROCEDURE LoginSequence;

IMPLEMENTATION

USES
  Common;

PROCEDURE LoginSequence;
VAR
  Cmd: Char;
  MinInt,
  MaxInt,
  TempI: Integer;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      CLS;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Login Sequence Configuration',80));
      {NL;}
	  
	  PrintACR('^0(^1A^0) Shuttle Logon             : ^1'+PadLeftStr(ShowOnOff(ShuttleLog),7));
	  PrintACR('^0(^1B^0) SL To Log On From Shuttle : ^1'+PadLeftStr(ShowYesNo(ShuttleUnvalLogin),7));
	  PrintACR('^0(^1C^0) AutoMessage During Logon  : ^1'+PadLeftStr(ShowOnOff(AutoMInLogon),7));
	  PrintACR('^0(^1D^0) Bulletins    "      "     : ^1'+PadLeftStr(ShowOnOff(BullInLogon),7));
	  PrintACR('^0(^1E^0) Random Quote "      "     : ^1'+PadLeftStr(ShowOnOff(LogonQuote),7));
	  PrintACR('^0(^1F^0) Add Quote    "      "     : ^1'+PadLeftStr(ShowOnOff(UserAddQuote),7));
	  PrintACR('^0(^1G^0) User Info    "      "     : ^1'+PadLeftStr(ShowOnOff(YourInfoInLogon),7));
	  PrintACR('^0(^1H^0) Last Callers "      "     : ^1'+PadLeftStr(ShowOnOff(LastCallersInLogon),7));
	  PrintACR('^0(^1I^0) OneLiners    "      "     : ^1'+PadLeftStr(ShowOnOff(OneLinersInLogon),7));
	  PrintACR('^0(^1J^0) Voting       "      "     : ^1'+PadLeftStr(ShowOnOff(VoteInLogon),7));
	  PrintACR('^0(^1K^0) Use IEMSI Handshakes      : ^1'+PadLeftStr(ShowOnOff(UseIEMSI),7));
	  PrintACR('^0(^1L^0) Offhook In Local Logon    : ^1'+PadLeftStr(ShowOnOff(OffHookLocalLogon),7));
(* LeeW: Maybe "force batch ul/dl" should be with logon secq *)		  
      NL;
      Prt('^0Login Sequence Configuration: ');
      OneK(Cmd,'QABCDEFGHIJKL',TRUE,TRUE);
      CASE Cmd OF
			'A' : ShuttleLog := NOT ShuttleLog;
			'B' : ShuttleUnvalLogin := NOT ShuttleUnvalLogin;
			'C' : AutoMInLogon := NOT AutoMInLogon;
			'D' : BullInLogon := NOT BullInLogon;
			'E' : LogonQuote := NOT LogonQuote;
			'F' : UserAddQuote := NOT UserAddQuote;
			'G' : YourInfoInLogon := NOT YourInfoInLogon;
			'H' : LastCallersInLogon := NOT LastCallersInLogon;
			'I' : OneLinersInLogon := NOT OneLinersInLogon;
			'J' : VoteInLogon := NOT VoteInLogon;
			'K' : UseIEMSI := NOT UseIEMSI;
			'L' : OffHookLocalLogon := NOT OffHookLocalLogon;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.