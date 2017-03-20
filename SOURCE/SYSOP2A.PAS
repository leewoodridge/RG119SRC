UNIT SysOp2A;

INTERFACE

PROCEDURE MainBBSConfiguration;

IMPLEMENTATION

USES
  Crt,
  Common,
  SysOp7,
  TimeFunc;

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

Function ConnType : String;
Begin      
	If (General.ConnectionType[1] = True) And (General.ConnectionType[2] = False) Then
		ConnType := '|07M: |15'+General.BBSPhone; { Modem }
	If (General.ConnectionType[1] = False) And (General.ConnectionType[2] = True) Then
		ConnType := '|07T: |15'+Liner.NodeTelnetURL; { Telnet }
	If (General.ConnectionType[1] = False) And (General.ConnectionType[2] = False) Then
		ConnType := 'None'; { None }
	If General.ConnectionType[1] And General.ConnectionType[2] Then
		ConnType := '|07M: |15'+General.BBSPhone+'|07 T: |15'+Liner.NodeTelnetURL; { Both }
End; 
  
PROCEDURE MainBBSConfiguration;
VAR
  LineFile: FILE OF LineRec;
  Cmd: Char;
  Changed: Boolean;
BEGIN
  Assign(LineFile,General.DataPath+'NODE'+IntToStr(ThisNode)+'.DAT');
  Reset(LineFile);
  Seek(LineFile,0);
  Read(LineFile,Liner);
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
          Cls;
          Print(PadLeftStr('|17|15 þ Renegade BBS Configuration : Main BBS Configuration',80));	
		  PrintACR('|07(|15A|07) BBS Name          : |15'+BBSName);
          PrintACR('|07(|15B|07) Connection Type   : |15'+ConnType);
          PrintACR('|07(|15C|07) SysOp`s Name      : |15'+PadLeftStr(SysOpName,14)+
			      ' |07(|15D|07) Renegade Version  : |15'+Version);
          PrintACR('|07(|15E|07) SysOp`s Chat Hrs  : |15'+PadLeftStr(PHours('Any',lLowTime,HiTime),14)+
			      ' |07(|15F|07) Minimum Baud Hrs  : |15'+PadLeftStr(PHours('Any',MinBaudLowTime,MinBaudHiTime),14));
          PrintACR('|07(|15G|07) Regular DL Hrs    : |15'+PadLeftStr(PHours('Any',DLLowTime,DLHiTime),14)+
			      ' |07(|15H|07) Min Baud DL Hrs   : |15'+PHours('Any',MinBaudDLLowTime,MinBaudDLHiTime));
          PrintACR('|07(|15I|07) System Passwords                   '+
			       '|07(|15J|07) Pre-Event Warning : |15'+IntToStr(EventWarningTime)+' |07Second(s)');
          PrintACR('|07(|15K|07) System Menus                       '+
		           '|07(|15L|07) Bulletin Prefix   : |15'+BulletPrefix+'');
          PrintACR('|07(|15M|07) MultiNode Support : |15'+PadLeftStr(ShowOnOff(MultiNode),14)+
			      ' |07(|15N|07) Network Mode      : |15%NM');
          Nl;
          PrintACR('|07(|150|07) Data Files          : |15'+DataPath);
          PrintACR('|07(|151|07) Miscellaneous Files : |15'+MiscPath);
          PrintACR('|07(|152|07) Message Storage     : |15'+MsgPath);
          PrintACR('|07(|153|07) Nodelist (V7)       : |15'+NodePath);
          PrintACR('|07(|154|07) Log/Trap Files      : |15'+LogsPath);
          PrintACR('|07(|155|07) Temporary Files     : |15'+TempPath);
          PrintACR('|07(|156|07) Protocols           : |15'+ProtPath);
          PrintACR('|07(|157|07) Archivers           : |15'+ArcsPath);
          PrintACR('|07(|158|07) File Attachments    : |15'+FileAttachPath);
         {PrintACR('|07(|159|07) Strings             : |15'+DataPath);} { Strings & data files are combined now }
          Nl;
          Prt('|07Enter Selection Or (|15Q|07)uit: |15');

      OneK(Cmd,'QABCDEFGHIJKLMN0123456789',TRUE,TRUE);
      CASE Cmd OF
        'A' : InputWNWC(RGSysCfgStr(2,TRUE),BBSName,(SizeOf(BBSName) - 1),Changed);
        'B' : Begin
				Repeat
				ClrScr;
				PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : Connection Type',80));
				PrintACR('|15Please select the method(s) that users will be able to connect to your BBS');
				PrintACR('through.');
				Nl;
				PrintACR('|07(|15A|07) Modem');
				PrintACR('|07(|15B|07) Telnet');
				PrintACR('|07(|15C|07) Both');
				{PrintACR('|07(|15D|07) None');} { Don't think we need this as an option }
				Nl;
				Prt('|07Enter Selection or (|15Q|07) to Quit: |15');
				OneK(Cmd,'QABC',TRUE,TRUE);
						  Case Cmd Of
							'A' : Begin { Modem }
									InputFormatted(RGSysCfgStr(3,TRUE),BBSPhone,'(###)###-####',FALSE);
									General.ConnectionType[1] := True;
									General.ConnectionType[2] := False;
									Cmd := 'Q';
								  End;
							'B' : Begin { Telnet }
									InputWN1(RGSysCfgStr(4,TRUE),Liner.NodeTelnetURL,(SizeOf(Liner.NodeTelnetURL) - 1),[InteractiveEdit],Changed);
									General.ConnectionType[2] := True;
									General.ConnectionType[1] := False;
									Cmd := 'Q';
								  End;
							'C' : Begin { Both }
									{ Would be nice if phone number was remembered like telnet url }
									InputFormatted(RGSysCfgStr(3,TRUE),BBSPhone,'(###)###-####',FALSE);
									InputWN1(RGSysCfgStr(4,TRUE),Liner.NodeTelnetURL,(SizeOf(Liner.NodeTelnetURL) - 1),[InteractiveEdit],Changed);
									General.ConnectionType[2] := True;
									General.ConnectionType[1] := True;
									Cmd := 'Q';
								  End;
							'D' : Begin { None, Not Used }
									General.ConnectionType[2] := False;
									General.ConnectionType[1] := False;
									Cmd := 'Q';
								  End;
						End;
			  UNTIL (Cmd IN ['Q']) OR (HangUp);
			  Cmd := #0;
	  End;
        'C' : InputWN1(RGSysCfgStr(5,TRUE),SysOpName,(SizeOf(SysOpName) - 1),[InterActiveEdit],Changed);
        'D' : RGNoteStr(0,FALSE);
        'E' : IF (InCom) THEN
                RGNoteStr(1,FALSE)
              ELSE
                GetTimeRange(6,lLowTime,HiTime);
        'F' : GetTimeRange(7,MinBaudLowTime,MinBaudHiTime);
        'G' : GetTimeRange(8,DLLowTime,DLHiTime);
        'H' : GetTimeRange(9,MinBaudDLLowTime,MinBaudDLHiTime);
        'I' : BEGIN
                REPEAT
					ClrScr;
					PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : System Passwords',80));
					PrintACR('|07(|15A|07) SysOp Password         : |15'+SysOpPW);
				   {PrintACR('|07(|15B|07) New User Password      : |15'+NewUserPW);}
					PrintACR('|07(|15C|07) Baud Override Password : |15'+MinBaudOverride);
					Nl;
					Prt('|07Enter Selection Or (|15Q|07) to Quit: |15');				  
                  OneK(Cmd,'QABC',TRUE,TRUE);
                  CASE Cmd OF
                    'A' : InputWN1(RGSysCfgStr(11,TRUE),SysOpPw,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'B' : InputWN1(RGSysCfgStr(12,TRUE),NewUserPW,(SizeOf(SysOpPW) - 1),[InterActiveEdit,UpperOnly],Changed);
                    'C' : InputWN1(RGSysCfgStr(13,TRUE),MinBaudOverride,(SizeOf(SysOpPW) - 1),
					      [InterActiveEdit,UpperOnly],Changed);
                  END;
                UNTIL (Cmd IN ['Q']) OR (HangUp);
                Cmd := #0;
              END;
        'J' : InputByteWOC(RGSysCfgStr(14,TRUE),EventWarningTime,[DisplayValue,NumbersOnly],0,255);
        'K' : BEGIN
                REPEAT
				  ClrScr;
				  PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : System Menus',80));
				  
				PrintACR('|07(|151|07) Global        : |15'+IntToStr(GlobalMenu)+'');
				{ Menu commands here appear on other menus unless global display is toggled off }
				PrintACR('|07(|152|07) Start         : |15'+IntToStr(AllStartMenu)+'');
				{ First menu users are sent to after default login sequence }
				PrintACR('|07(|153|07) Shuttle Logon : |15'+IntToStr(ShuttleLogonMenu));
				{ Shuttle Logon Menu }
				PrintACR('|07(|154|07) New User Info : |15'+IntToStr(NewUserInformationMenu));
				{ New user information review before user saves profile }
				PrintACR('|07(|155|07) Message Read  : |15'+IntToStr(MessageReadMenu));
				{ Prompt while listing files }
				PrintACR('|07(|156|07) File List     : |15'+IntToStr(FileListingMenu));
				{ Prompt while reading messages }
				Nl;
				Prt('|07Enter Selection Or (|15Q|07) to Quit: |15');				  
                  OneK(Cmd,'123456Q',TRUE,TRUE);
                  CASE Cmd OF
                    '1' : FindMenu(RGSysCfgStr(16,TRUE),GlobalMenu,0,NumMenus,Changed);
                    '2' : FindMenu(RGSysCfgStr(17,TRUE),AllStartMenu,1,NumMenus,Changed);
                    '3' : FindMenu(RGSysCfgStr(18,TRUE),ShuttleLogonMenu,0,NumMenus,Changed);
                    '4' : FindMenu(RGSysCfgStr(19,TRUE),NewUserInformationMenu,1,NumMenus,Changed);
                    '5' : FindMenu(RGSysCfgStr(20,TRUE),MessageReadMenu,1,NumMenus,Changed);
                    '6' : FindMenu(RGSysCfgStr(21,TRUE),FileListingMenu,1,NumMenus,Changed);
                  END;
                UNTIL (Cmd IN ['Q']) OR (HangUp);
                Cmd := #0;
              END;
        'L' : InputWN1(RGSysCfgStr(22,TRUE),BulletPrefix,(SizeOf(BulletPrefix) - 1),[InterActiveEdit,UpperOnly],Changed);
        'M' : IF (InCom) THEN
                RGNoteStr(1,FALSE)
              ELSE
              BEGIN
                MultiNode := (NOT MultiNode);
                SaveGeneral(FALSE);
                ClrScr;
                Writeln('Please restart Renegade.');
                Halt;
              END;
        'N' : BEGIN
                NetworkMode := (NOT NetworkMode);
                IF (NetworkMode) THEN
                  LocalSec := TRUE
                ELSE
                  LocalSec := PYNQ(RGSysCfgStr(23,TRUE),0,FALSE);
              END;
        '0' : InputPath(RGSysCfgStr(24,TRUE),DataPath,TRUE,FALSE,Changed);
        '1' : InputPath(RGSysCfgStr(25,TRUE),MiscPath,TRUE,FALSE,Changed);
        '2' : InputPath(RGSysCfgStr(26,TRUE),MsgPath,TRUE,FALSE,Changed);
        '3' : InputPath(RGSysCfgStr(27,TRUE),NodePath,TRUE,FALSE,Changed);
        '4' : InputPath(RGSysCfgStr(28,TRUE),LogsPath,TRUE,FALSE,Changed);
        '5' : InputPath(RGSysCfgStr(29,TRUE),TempPath,FALSE,FALSE,Changed);
        '6' : InputPath(RGSysCfgStr(30,TRUE),ProtPath,TRUE,FALSE,Changed);
        '7' : InputPath(RGSysCfgStr(31,TRUE),ArcsPath,TRUE,FALSE,Changed);
        '8' : InputPath(RGSysCfgStr(32,TRUE),FileAttachPath,TRUE,FALSE,Changed);
        '9' : InputPath(RGSysCfgStr(33,TRUE),lMultPath,TRUE,FALSE,Changed);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
  Seek(LineFile,0);
  Write(LineFile,Liner);
  Close(LineFile);
  LastError := IOResult;
END;
END.