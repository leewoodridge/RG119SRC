{$A+,B-,D+,E-,L+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

}

UNIT SysOp2B; { Modem / Node Configuration }

INTERFACE

PROCEDURE ModemConfiguration;

IMPLEMENTATION

USES
  CRT,
  Common;

PROCEDURE ModemConfiguration;
VAR
  LineFile: FILE OF LineRec;
  Cmd: Char;
  TempB: Byte;
  Changed: Boolean;

  PROCEDURE ToggleMFlag(MFlagT: ModemFlagType; VAR MFlags: MFlagSet);
  BEGIN
    IF (MFlagT IN MFlags) THEN
      Exclude(MFlags,MFlagT)
    ELSE
      Include(MFlags,MFlagT);
  END;

  PROCEDURE ToggleMFlags(C: Char; VAR MFlags: MFlagSet; VAR Changed: Boolean);
  VAR
    SaveMFlags: MFlagSet;
  BEGIN
    SaveMFlags := MFlags;
    CASE C OF
      '7' : ToggleMFlag(LockedPort,MFlags);
      '8' : ToggleMFlag(XONXOFF,MFlags);
      '9' : ToggleMFlag(CTSRTS,MFlags);
    END;
    IF (MFlags <> SaveMFlags) THEN
      Changed := TRUE;
  END;

  PROCEDURE NewModemString(CONST DisplayStr: AStr; VAR InputStr: AStr; Len: Byte);
  VAR
    Changed: Boolean;
  BEGIN
	NL;
    Print('^0Current modem '+DisplayStr+' string: "^1'+InputStr+'^0"');
	NL;
    Print('Use "|" for a carriage return');
    Print('    "~" for a half-second delay');
    Print('    "^" to toggle DTR off for a quarter-second');
	NL;
    InputWN1('^0Enter New Modem '+DisplayStr+' String: ',InputStr,Len,[InterActiveEdit],Changed);
  END;

  FUNCTION WhichBaud(B: Byte): AStr;
  BEGIN
    CASE B OF
      1 : WhichBaud := 'CONNECT 300';
      2 : WhichBaud := 'CONNECT 600';
      3 : WhichBaud := 'CONNECT 1200';
      4 : WhichBaud := 'CONNECT 2400';
      5 : WhichBaud := 'CONNECT 4800';
      6 : WhichBaud := 'CONNECT 7200';
      7 : WhichBaud := 'CONNECT 9600';
      8 : WhichBaud := 'CONNECT 12000';
      9 : WhichBaud := 'CONNECT 14400';
     10 : WhichBaud := 'CONNECT 16800';
     11 : WhichBaud := 'CONNECT 19200';
     12 : WhichBaud := 'CONNECT 21600';
     13 : WhichBaud := 'CONNECT 24000';
     14 : WhichBaud := 'CONNECT 26400';
     15 : WhichBaud := 'CONNECT 28800';
     16 : WhichBaud := 'CONNECT 31200';
     17 : WhichBaud := 'CONNECT 33600';
     18 : WhichBaud := 'CONNECT 38400';
     19 : WhichBaud := 'CONNECT 57600';
     20 : WhichBaud := 'CONNECT 115200';
    END;
 END;

BEGIN
  Assign(LineFile,General.DataPath+'NODE'+IntToStr(ThisNode)+'.DAT');
  Reset(LineFile);
  Read(LineFile,Liner);
  REPEAT
    WITH Liner DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      ClrScr;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS : Modem / Node #'+IntToStr(ThisNode)+' Configuration',80));
	  Print('Here you can configure...');
      NL;
      
	  PrintACR('^0(^1A^0) Com Port Number  : ^1'+PadLeftStr(IntToStr(ComPort),6)+
			   '^0(^1G^0) Max Baud Rate    : ^1'+PadLeftInt(InitBaud,27));
	  PrintACR('^0(^1B^0) I/O Address      : ^1'+PadLeftStr(Address,6)+
			   '^0(^1H^0) Modem Init       : ^1'+PadLeftStr(Init,27));
	  PrintACR('^0(^1C^0) IRQ Number       : ^1'+PadLeftStr(IRQ,6)+
			   '^0(^1I^0) Modem Answer     : ^1'+PadLeftStr(Answer,27));
      PrintACR('^0(^1D^0) Com Port Locking : ^1'+PadLeftStr(ShowOnOff(LockedPort IN MFlags),6)+
			   '^0(^1J^0) Modem Hangup     : ^1'+PadLeftStr(HangUp,27));
      PrintACR('^0(^1E^0) XON/XOFF (SW)    : ^1'+PadLeftStr(ShowOnOff(XONXOFF IN MFlags),6)+
			   '^0(^1K^0) Modem Offhook    : ^1'+PadLeftStr(Offhook,27));
      PrintACR('^0(^1F^0) CTS/RTS (HW)     : ^1'+PadLeftStr(ShowOnOff(CTSRTS IN MFlags),6)+
			   '^0(^1L^0) Modem Result Codes ...');
	  NL;
	  PrintACR('^0(^1M^0) Answer On Ring   : ^1'+PadLeftStr(IntToStr(AnswerOnRing),10));
	  PrintACR('^0(^1N^0) Multi-Ring Only  : ^1'+PadLeftStr(ShowYesNo(MultiRing),10));
	  PrintACR('^0(^1O^0) Node ACS         : ^1'+PadLeftStr(LogonACS,20));
	  PrintACR('^0(^1P^0) Drop File Path   : ^1'+PadLeftStr(DoorPath,50));
	  PrintACR('^0(^1R^0) TeleConf Normal  : ^1'+PadLeftStr(TeleConfNormal,50));
	  PrintACR('^0(^1S^0) TeleConf Anon    : ^1'+PadLeftStr(TeleConfAnon,50));
	  PrintACR('^0(^1T^0) TeleConf Global  : ^1'+PadLeftStr(TeleConfGlobal,50));
	  PrintACR('^0(^1U^0) TeleConf Private : ^1'+PadLeftStr(TeleConfPrivate,50));

      Prt('^0%LFModem/Node #'+IntToStr(ThisNode)+' Configuration [^1A^0-^1U^0,(^1Q^0)uit]: ');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTU'^M,TRUE,TRUE);
      CASE Cmd OF
        'G' : IF (InCom) THEN
              BEGIN
				NL;
                Print('^8This can only be changed locally.'); {leew:rgnote1}
                PauseScr(FALSE);
              END
              ELSE
              BEGIN
				CLS;
				PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Maximum Baud Rate',80));
                {Print('^0Modem maximum baud rates:');}
				Print('^0Select the maximum baud rate of your modem for this node.');
				NL;
                Print('^0<^1A^0> 2400');
                Print('^0<^1B^0> 9600');
                Print('^0<^1C^0> 19200');
                Print('^0<^1D^0> 38400');
                Print('^0<^1E^0> 57600');
                Print('^0<^1F^0> 115200');
				NL;
                LOneK('^0Modem Speed? [^1A^0-^1F^0,<^1CR^0>Quit]: ',Cmd,^M'ABCDEF',TRUE,TRUE);
                CASE Cmd OF
                  'A' : InitBaud := 2400;
                  'B' : InitBaud := 9600;
                  'C' : InitBaud := 19200;
                  'D' : InitBaud := 38400;
                  'E' : InitBaud := 57600;
                  'F' : InitBaud := 115200;
                END;
                Cmd := #0;
              END;
        'A' : IF (InCom) THEN
              BEGIN
				NL;
                Print('^8This can only be changed locally.');
                PauseScr(FALSE);
              END
              ELSE
              BEGIN
                TempB := ComPort;
				NL;
                InputByteWC('^0Enter Com Port Number',TempB,[DisplayValue,NumbersOnly],0,64,Changed);
                IF (Changed) THEN
                  IF PYNQ('^0%LFAre you sure this is what you want? ',0,FALSE) THEN
                  BEGIN
                    Com_DeInstall;
                    ComPort := TempB;
                    Com_Install;
                  END;
                IF (NOT LocalIOOnly) AND (ComPort = 0) THEN
                  LocalIOOnly := TRUE;
              END;
        'B' : InputWN1('%LF^0Enter I/O Address (For %C MCI Code): ',Address,(SizeOf(Address) - 1),[InterActiveEdit],Changed);
		'C' : InputWN1('%LF^0Enter IRQ Number (For %E MCI Code): ',IRQ,(SizeOf(IRQ) - 1),[InterActiveEdit],Changed);
        'H' : NewModemString('Init',Init,(SizeOf(Init) - 1));
        'I' : NewModemString('Answer',Answer,(SizeOf(Answer) - 1));
        'J' : NewModemString('Hangup',HangUp,(SizeOf(HangUp) - 1));
        'K' : NewModemString('Offhook',Offhook,(SizeOf(Offhook) - 1));
        'D' : ToggleMFlags('7',MFlags,Changed);
        'E' : ToggleMFlags('8',MFlags,Changed);
        'F' : ToggleMFlags('9',MFlags,Changed);
        'O' : InputWN1('^0%LFEnter ACS Required For Node '+IntToStr(ThisNode)+': ',LogonACS,(SizeOf(LogonACS) - 1),
			  [InterActiveEdit],Changed);
        'P' : InputPath('^0%LF^1Enter Path For Dropfiles : ',
                        DoorPath,TRUE,FALSE,Changed);
        'M' : InputByteWOC('^0%LFAnswer after ring number',AnswerOnRing,[DisplayValue,NumbersOnly],0,255);
        'N' : MultiRing := NOT MultiRing;
        'R' : InputWN1('^0%LFEnter new teleconference string:%LF: ',TeleConfNormal,(SizeOf(TeleConfNormal) - 1),
                       [ColorsAllowed,InterActiveEdit],Changed);
        'S' : InputWN1('^0%LFEnter new teleconference string:%LF: ',TeleConfAnon,(SizeOf(TeleConfAnon) - 1),
                       [ColorsAllowed,InterActiveEdit],Changed);
        'T' : InputWN1('^0%LFEnter new teleconference string:%LF: ',TeleConfGlobal,(SizeOf(TeleConfGlobal) - 1),
                       [ColorsAllowed,InterActiveEdit],Changed);
        'U' : InputWN1('^0%LFEnter new teleconference string:%LF: ',TeleConfPrivate,(SizeOf(TeleConfPrivate) - 1),
                                [ColorsAllowed,InterActiveEdit],Changed);
        'L' : BEGIN
                REPEAT
                  Abort := FALSE;
                  Next := FALSE;
				  ClrScr;
				  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Modem Result Codes',80));
                  PrintACR('^1A^0> NO CARRIER    : ^1'+PadLeftStr(NOCARRIER,21)+'^1B^0> RELIABLE      : ^1'+RELIABLE);
                  PrintACR('^1C^0> OK            : ^1'+PadLeftStr(OK,21)+'^1D^0> RING          : ^1'+RING);
                  PrintACR('^1E^0> CALLER ID     : ^1'+PadLeftStr(CALLERID,21)+
                           '^1F^0> ID/User Note  : ^1'+ShowOnOff(UseCallerID));
                  FOR TempB := 1 TO MaxResultCodes DO
                    IF (NOT Odd(TempB)) THEN
                      Print('^1'+Chr(TempB + 70)+'^0> '+PadLeftStr(WhichBaud(TempB),14)+': ^1'+Connect[TempB])
                    ELSE
                      Prompt(PadLeftStr('^1'+Chr(TempB + 70)+'^0> '+PadLeftStr(WhichBaud(TempB),14)+': ^1'+Connect[TempB],40));
				  NL;
                  LOneK('^0Enter Selection [^1A^0-^1Z^0,<^1CR^0>Quit]: ',Cmd,^M'ABCDEFGHIJKLMNOPQRSTUVWXYZ',TRUE,TRUE);
                  CASE Cmd OF
                    'A' : InputWN1('%LFEnter NO CARRIER string: ',NOCARRIER,(SizeOf(NOCARRIER) - 1),
                                   [InterActiveEdit,UpperOnly],Changed);
                    'B' : InputWN1('%LFEnter RELIABLE string: ',RELIABLE,(SizeOf(RELIABLE) - 1),
                                   [InterActiveEdit,UpperOnly],Changed);
                    'C' : InputWN1('%LFEnter OK string: ',OK,(SizeOf(OK) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'D' : InputWN1('%LFEnter RING string: ',RING,(SizeOf(RING) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'E' : InputWN1('%LFEnter Caller ID string: ',CALLERID,(SizeOf(CALLERID) - 1),
                                   [InterActiveEdit,UpperOnly],Changed);
                    'F' : UseCallerID := NOT UseCallerID;
                    'G'..'Z' :
                          BEGIN
                            TempB := (Ord(Cmd) - 70);
                            IF (TempB IN [1..MaxResultCodes]) THEN
                              InputWN1('%LFEnter '+WhichBaud(TempB)+' string: ',Connect[TempB],(SizeOf(Connect[1]) - 1),
                                       [InterActiveEdit,UpperOnly],Changed);
                          END;
                  END;
                UNTIL (Cmd = ^M);
                Cmd := #0;
              END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
  Seek(LineFile,0);
  Write(LineFile,Liner);
  Close(LineFile);
  LastError := IOResult;
END;

END.
