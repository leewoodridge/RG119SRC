{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2; { System Configuration Menu }

INTERFACE

PROCEDURE SystemConfigurationEditor;

IMPLEMENTATION

USES
  Common,
  SysOp2A,
  SysOp2B,
  SysOp2C,
  SysOp2D,
 {SysOp2E,}
  SysOp2F,
  SysOp2G,
  SysOp2H,
  SysOp2I,
  SysOp2J,
  SysOp2K,
  SysOp2L,
  SysOp2M,
  SysOp2N,
  SysOp2X,
  SysOp2O,
  SysOp2P,
  Maint;

PROCEDURE SystemConfigurationEditor;
VAR
  Cmd: Char;
BEGIN
  REPEAT
    SetC(7);
    SaveGeneral(TRUE);
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
	  CLS;
	  Print(PadLeftStr('^2 '#240' Renegade BBS Configuration',70)+PadRightStr('V'+Version+' ',10)+'^0');
	  PrintACR('^0(^1A^0) System Configuration #1                ^0(^1B^0) Modem/Node Configuration');
	  PrintACR('^0(^1C^0) System ACS Settings                    ^0(^1D^0) System Configuration #2');
	  PrintACR('^0(^1P^0) Message System                         ^0(^1F^0) File System Configuration');
	  PrintACR('^0(^1G^0) Subscription/Validation System         ^0(^1H^0) Net/Echo Mail');
	  PrintACR('^0(^1I^0) Offline Mail                           ^0(^1J^0) Color Schemes');
	  PrintACR('^0(^1K^0) Archivers                              ^0(^1L^0) Credit System Configuration');
	  PrintACR('^0(^1M^0) New User Application                   ^0(^1N^0) Login Sequence');
	  NL;
	  PrintACR('^0(^1!^0) TEST MENU');
	  NL;
	  PrintACR('^0(^11^0) Time Allowed Per '+PadLeftStr(AOnOff((PerCall = FALSE),'Day','Call'),4)+
											  '                  ^0(^12^0) Max Calls Per Day');
	  PrintACR('^0(^13^0) UL/DL # Files Ratio                    ^0(^14^0) UL/DL Kbytes Ratio');
	  PrintACR('^0(^15^0) Post/Call Ratio                        ^0(^16^0) Max Downloads Per Day');
	  PrintACR('^0(^17^0) Max Download Kbytes Per Day            ^0(^18^0) Update System Averages');
	  NL;
	  Prompt('^0Renegade BBS Configuration (^1A^0-^1P^0,^11^0-^18^0,^1Q^0)uit: ^1');
      OneK(Cmd,'QABCDFGHIJKLMNP12345678!',TRUE,TRUE);
      CASE Cmd OF
        'A' : MainBBSConfiguration;
        'B' : ModemConfiguration;
        'C' : SystemACSSettings;
        'D' : SystemGeneralVariables;
        {'E' : SystemFlaggedFunctions;}
        'F' : FileSystemConfiguration;
        'G' : ValidationEditor;
        'H' : NetworkConfiguration;
        'I' : OffLineMailConfiguration;
        'J' : ColorConfiguration;
        'K' : ArchiveConfiguration;
        'L' : CreditConfiguration;
        'M' : NewUserTogglesConfiguration;
		'N' : LoginSequence;
		'P' : MessageSystemConfiguration;
		'!' : TestMenu;
        '1' : GetSecRange(1,TimeAllow);
        '2' : GetSecRange(2,CallAllow);
        '3' : GetSecRange(3,DLRatio);
        '4' : GetSecRange(4,DLKratio);
        '5' : GetSecRange(5,PostRatio);
        '6' : GetSecRange(6,DLOneDay);
        '7' : GetSecRange(7,DLKOneDay);
        '8' : UpdateGeneral;
      END;
    END;
    SaveGeneral(FALSE);
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
