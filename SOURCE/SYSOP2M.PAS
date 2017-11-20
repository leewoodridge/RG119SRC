(*	 ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
	| |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
	|_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
	----------------------------------------------------------------------
	NEW USER APPLICATION TOGGLES
	----------------------------------------------------------------------
*)
UNIT SysOp2M;

INTERFACE

PROCEDURE NewUserTogglesConfiguration;

IMPLEMENTATION

USES
  Crt,
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
      Print(PadLeftStr('^2 '#240' Renegade BBS Configuration : New User Application Toggles',80));
      Print('^0Here you can configure which questions and options you`d like new users to be');
      Print('^0prompted on during their application.');
      NL; 
	  PrintACR('^0(^1W^0) Handle/Alias    : ^1'+ShowYesNo(AllowAlias));
      PrintACR('^0(^1A^0) Real Name       : ^1'+ShowYesNo(NewUserToggles[2])+' |08³ '+
			   '^0(^1S^0) Hotkeys         : ^1'+ShowYesNo(NewUserToggles[19]));
      PrintACR('^0(^1B^0) Country         : ^1'+ShowYesNo(NewUserToggles[3])+' |08³ '+
			   '^0(^1T^0) QWK             : ^1'+ShowYesNo(NewUserToggles[20]));
      PrintACR('^0(^1C^0) City, State     : ^1'+ShowYesNo(NewUserToggles[4])+' |08³ '+
			   '^0(^1U^0) Expert Mode     : ^1'+ShowYesNo(NewUserToggles[21]));
      PrintACR('^0(^1D^0) Address         : ^1'+ShowYesNo(NewUserToggles[5])+' |08³ '+
			   '^0(^1V^0) Forgot Password : ^1'+ShowYesNo(NewUserToggles[23]));
      PrintACR('^0(^1E^0) Zip Code        : ^1'+ShowYesNo(NewUserToggles[6])+' |08³ ');
      PrintACR('^0(^1F^0) Phone Number    : ^1'+ShowYesNo(NewUserToggles[7])+' |08³ '+
			   '');
      PrintACR('^0(^1G^0) Birthdate       : ^1'+ShowYesNo(NewUserToggles[8])+' |08³ '+
	  '');
      PrintACR('^0(^1H^0) Gender Identity : ^1'+ShowYesNo(NewUserToggles[9])+' |08³ ');
      PrintACR('^0(^1I^0) Question #1     : ^1'+ShowYesNo(NewUserToggles[10])+' |08³ ');
      PrintACR('^0(^1J^0) Question #2     : ^1'+ShowYesNo(NewUserToggles[11])+' |08³ ');
      PrintACR('^0(^1K^0) Question #3     : ^1'+ShowYesNo(NewUserToggles[12])+' |08³ ');
      PrintACR('^0(^1L^0) Term Emulation  : ^1'+ShowYesNo(NewUserToggles[13])+' |08³ ');
      PrintACR('^0(^1M^0) ANSI Colors     : ^1'+ShowYesNo(NewUserToggles[14])+' |08³ ');
      PrintACR('^0(^1N^0) Color Scheme    : ^1'+ShowYesNo(NewUserToggles[15])+' |08³ ');
      PrintACR('^0(^1O^0) Screen Size     : ^1'+ShowYesNo(NewUserToggles[16])+' |08³ ');
      PrintACR('^0(^1P^0) Screen Clearing : ^1'+ShowYesNo(NewUserToggles[17])+' |08³ ');
      PrintACR('^0(^1R^0) Screen Pause    : ^1'+ShowYesNo(NewUserToggles[18])+' |08³ ');  
    END;
    MCIAllowed := TRUE;
    Nl;
    Prt('^0Enter Selection Or (^1Q^0)uit: ^1');
    OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1!',TRUE,TRUE);
    WITH General DO
      CASE Cmd OF
	   'W' : BEGIN
		   AllowAlias := NOT AllowAlias;
			   IF AllowAlias = False THEN
			     BEGIN
			       NewUserToggles[02] := True;
			       (*PrintACR('Also disabling Real Name field for new user application.'); { No need to ask twice }
			       PauseScr(False);*)
			     END;
	         END;

    	'A' : BEGIN
			    NewUserToggles[02] := NOT NewUserToggles[02];
				IF NewUserToggles[02] = False THEN
			      AllowAlias := True;
			  END;
        'B' : NewUserToggles[03] := NOT NewUserToggles[03];
        'C' : NewUserToggles[04] := NOT NewUserToggles[04];
        'D' : NewUserToggles[05] := NOT NewUserToggles[05];
        'E' : NewUserToggles[06] := NOT NewUserToggles[06];
        'F' : Begin
                If (NewUserToggles[7])
                Then
                  Begin
                    NewUserToggles[7] := False;
					Nl;
                    Print('Also Disabling Phone Number In Login'); { Can`t verify something we don`t have }
                    PauseScr(False);
                    General.PhonePW := False;
                  End
                Else NewUserToggles[7] := True;
             End;
       'G' : NewUserToggles[08] := NOT NewUserToggles[08];
       'H' : NewUserToggles[09] := NOT NewUserToggles[09];
       'I' : NewUserToggles[10] := NOT NewUserToggles[10];
       'J' : NewUserToggles[11] := NOT NewUserToggles[11];
       'K' : NewUserToggles[12] := NOT NewUserToggles[12];
       'L' : NewUserToggles[13] := NOT NewUserToggles[13];
       'M' : NewUserToggles[14] := NOT NewUserToggles[14];
       'N' : NewUserToggles[15] := NOT NewUserToggles[15];
       'O' : NewUserToggles[16] := NOT NewUserToggles[16];
       'P' : NewUserToggles[17] := NOT NewUserToggles[17];
       'R' : NewUserToggles[18] := NOT NewUserToggles[18];
       'S' : NewUserToggles[19] := NOT NewUserToggles[19];
       'T' : NewUserToggles[20] := NOT NewUserToggles[20];
       'U' : NewUserToggles[21] := NOT NewUserToggles[21];
       'V' : NewUserToggles[23] := NOT NewUserToggles[23];
	   'Y' : BEGIN
			  Nl;
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
	   'Z' : InputWN1(RGSysCfgStr(12,TRUE),NewUserPW,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed);
	   '!' : Begin { LeeW: for my testing, remove after }
			   NewUserToggles[01] := True;
			   NewUserToggles[22] := True;
			   Print('Username And Password Reset To True');
			   PauseScr(False);
			 End;
      END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.