
{ Lee Woodridge } { New User Options Menu }

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
      Print(PadLeftStr('|17|15 þ Renegade BBS Configuration : New User Application Toggles',80));
      Print('Here you can configure which questions and options you`d like new users to be');
      Print('prompted on during their application.');
      Nl;
      PrintACR('|07(|15A|07) Real Name       : |15'+ShowYesNo(NewUserToggles[2])+
       '  |08³  |07(|15S|07) Hotkeys         : |15'+ShowYesNo(NewUserToggles[19]));
      PrintACR('|07(|15B|07) Country         : |15'+ShowYesNo(NewUserToggles[3])+
       '  |08³  |07(|15T|07) QWK             : |15'+ShowYesNo(NewUserToggles[20]));
      PrintACR('|07(|15C|07) City, State     : |15'+ShowYesNo(NewUserToggles[4])+
       '  |08³  |07(|15U|07) Expert Mode     : |15'+ShowYesNo(NewUserToggles[21]));
      PrintACR('|07(|15D|07) Address         : |15'+ShowYesNo(NewUserToggles[5])+
       '  |08³  |07(|15V|07) Forgot Password : |15'+ShowYesNo(NewUserToggles[23]){+' |07(|15^5'+ForgotPWQuestion+'|07)'});
      PrintACR('|07(|15E|07) Zip Code        : |15'+ShowYesNo(NewUserToggles[6])+
	   '  |08³  |07---------------------------');
      PrintACR('|07(|15F|07) Phone Number    : |15'+ShowYesNo(NewUserToggles[7])+
	   '  |08³  |07(|15W|07) Allow Aliases   : |15'+ShowOnOff(AllowAlias));
      PrintACR('|07(|15G|07) Birthdate       : |15'+ShowYesNo(NewUserToggles[8])+
	   '  |08³  |07(|15X|07) Refuse New Users: |15'+ShowOnOff(ClosedSystem));
      PrintACR('|07(|15H|07) Gender Identity : |15'+ShowYesNo(NewUserToggles[9])+
	   '  |08³  |07(|15Y|07) New User Message Sent To : |15'+AOnOff((NewApp = -1),'Off',PadLeftInt(NewApp,5)));
	   { Display Username Next To Number }
      PrintACR('|07(|15I|07) Question #1     : |15'+ShowYesNo(NewUserToggles[10]){+' |07(|15^5'+lRGLngStr(38,True)+'|07)'}+
	   '  |08³  |07(|15Z|07) New User PW     : |15'+NewUserPW);
      PrintACR('|07(|15J|07) Question #2     : |15'+ShowYesNo(NewUserToggles[11]){+' |07(|15^5'+lRGLngStr(39,True)+'|07)'}+
	   '  |08³  |07(|151|07) Can Unval''d Users Log In From Shuttle: |15'+ShowOnOff(ShuttleUnvalLogin));
      PrintACR('|07(|15K|07) Question #3     : |15'+ShowYesNo(NewUserToggles[12]){+' |07(|15^5'+lRGLngStr(40,True)+'|07)'});
      PrintACR('|07(|15L|07) Term Emulation  : |15'+ShowYesNo(NewUserToggles[13]));
      PrintACR('|07(|15M|07) ANSI Colors     : |15'+ShowYesNo(NewUserToggles[14]));
      PrintACR('|07(|15N|07) Color Scheme    : |15'+ShowYesNo(NewUserToggles[15]));
      PrintACR('|07(|15O|07) Screen Size     : |15'+ShowYesNo(NewUserToggles[16]));
      PrintACR('|07(|15P|07) Screen Clearing : |15'+ShowYesNo(NewUserToggles[17]));
      PrintACR('|07(|15R|07) Screen Pause    : |15'+ShowYesNo(NewUserToggles[18]));  
    END;
    MCIAllowed := TRUE;
    Nl;
    Prt('|07Enter Selection Or (|15Q|07)uit: |15');
    OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ1',TRUE,TRUE);
    WITH General DO
      CASE Cmd OF
        'A' : NewUserToggles[02] := NOT NewUserToggles[02];
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
	   'W' : BEGIN
	           AllowAlias := NOT AllowAlias;
			   If AllowAlias = False Then
			   Begin
			     NewUserToggles[02] := False;
			     PrintACR('Also disabling Real Name field for new user application.'); { No need to ask twice }
			     PauseScr(False);
			   End;
	         END;
	   'X' : ClosedSystem := NOT ClosedSystem;
	   'Y' : BEGIN
			  Nl;
                Prt('|07Select (|15E|07)nable, (|15D|07)isable, Or [|15ENTER|07] To Abort: |15');
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
	   '1' : ShuttleUnvalLogin := NOT ShuttleUnvalLogin;
      END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.