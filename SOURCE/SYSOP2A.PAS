UNIT SysOp2A;

(*
	multiple cmds with same cmdkey
	onek choices not all there
	*)

INTERFACE

PROCEDURE MainBBSConfiguration;

IMPLEMENTATION

USES
  Crt,
  Common,
  SysOp7,
  TimeFunc;

Function ConnType : String;
Begin      
	If (General.ConnectionType[1] = True) And (General.ConnectionType[2] = False) Then
		ConnType := '^0M: ^1'+General.BBSPhone; { Modem }
	If (General.ConnectionType[1] = False) And (General.ConnectionType[2] = True) Then
		ConnType := '^0T: ^1'+Liner.NodeTelnetURL; { Telnet }
	If (General.ConnectionType[1] = False) And (General.ConnectionType[2] = False) Then
		ConnType := 'None'; { None }
	If (General.ConnectionType[1] = True) And (General.ConnectionType[2] = True) Then
		ConnType := '^0M: ^1'+General.BBSPhone+'^0 T: ^1'+Liner.NodeTelnetURL; { Both }
End;
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
PROCEDURE MainBBSConfiguration;
VAR
  LineFile: FILE OF LineRec;
  Cmd: Char;
  Changed: Boolean;
  MinLongInt, { LeeW: Added }
  MaxLongInt, {}
  TempL: LongInt; {}
  	MinByte,
	MaxByte,
	TempB,
	TempB2: Byte;

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
          CLS;
          Print(PadLeftStr('^2 '#240' Renegade BBS : Main Configuration',80));	
		  PrintACR('^0(^1A^0) BBS Name        : ^1'+BBSName);
          PrintACR('^0(^1B^0) Connection Type : ^1'+ConnType);
          PrintACR('^0(^1C^0) SysOp`s Name    : ^1'+PadLeftStr(SysOpName,14));
		  NL;
          PrintACR('^0(^1M^0) Multi-Node Operation : ^1'+PadLeftStr(ShowOnOff(MultiNode),13)+
				   '^0(^1E^0) Log Global Activity  : ^1'+PadLeftStr(ShowOnOff(GlobalTrap),12));
		  PrintACR('^0(^1!^0) Local Security       : ^1'+PadLeftStr(ShowOnOff(LocalSec),13)+
				   '^0(^1F^0) Log Chat             : ^1'+PadLeftStr(ShowOnOff(AutoChatOpen),12));
		  PrintACR('^0(^1N^0) Network Mode         : ^1'+PadLeftStr('%NM',13)+ { LeeW: This shouldn't be a MCI! }
				   '^0(^1G^0) Log TeleConferencing : ^1'+PadLeftStr(ShowOnOff(TrapTeleConf),12));
		  PrintACR('^0(^1D^0) Use EMS For Overlay  : ^1'+PadLeftStr(ShowOnOff(UseEMS),13)+
				   '^0(^1P^0) SysOp Log Length     : ^1'+PadLeftStr(IntToStr(BackSysOpLogs)+'^0 '+
														Plural('Day',BackSysOpLogs),12));
		  PrintACR('^0(^1R^0) Swap Shell Function  : ^1'+PadLeftStr(AOnOff((SwapShell = TRUE),ShowOnOff(SwapShell)+
															'^0 > ^1'+DisplaySwapTo(SwapTo),'Off'),13)+
				   '^0(^1J^0) SysOp Log Color      : ^1'+PadLeftStr(ShowOnOff(StripCLog),12));
		  PrintACR('^0(^1K^0) Use BIOS For Video   : ^1'+PadLeftStr(ShowOnOff(UseBIOS),13)+
				   '^0(^1T^0) Alert If Chat Attempt: ^1'+PadLeftStr(ShowOnOff(ChatCall),12));
		  PrintACR('^0(^1@^0) Blank WFC Menu       : ^1'+PadLeftStr(AOnOff((WFCBlankTime = 0),'Never',
														IntToStr(WFCBlankTime)+'^0 '+Plural('Minute',WFCBlankTime)),13)+
				   '^0(^1#^0) Alert Delay          : ^1'+PadLeftStr(IntToStr(AlertBeep)+'^0 '+Plural('Second',AlertBeep),12));
		  PrintACR('^0(^1$^0) Time Slice Interval  : ^1'+PadLeftStr(IntToStr(SliceTimer)+'^0 '+
															Plural('Second',SliceTimer),13)+
				   '^0(^1L^0) Bulletin Prefix      : ^1'+BulletPrefix);
		  NL;
          PrintACR('^0(^1I^0) System Passwords ...'+'');
		  PrintACR('^0(^1&^0) System Directories ...'+'');
          NL;
          Prt('^0Main Configuration [^1A^0-^1N^0,^10^0-^18^0,(^1Q^0)uit]: ^1');

      OneK(Cmd,'Q!ABCDEFGHIJKLMNOPRSTUVWXYZ0123456789!@#$%^&*',TRUE,TRUE);
      CASE Cmd OF
			'T' : ChatCall := NOT ChatCall;
			'P' : BEGIN
					MinByte := 1;
					MaxByte := 255;
					TempB := BackSysOpLogs;
					InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
					BackSysOpLogs := TempB;
				  END;
			'#' : BEGIN
					MinByte := 0;
					MaxByte := 60;
					TempB := AlertBeep;
					InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
					AlertBeep := TempB;
				  END;
			'E' : GlobalTrap := NOT GlobalTrap;
			'F' : AutoChatOpen := NOT AutoChatOpen;
			'J' : StripCLog := NOT StripCLog;
			'G' : TrapTeleConf := NOT TrapTeleConf;
			'@' : BEGIN
					MinByte := 0;
					MaxByte := 60;
					TempB := WFCBlankTime;
					InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
					WFCBlankTime := TempB;
				  END;
			'$' : BEGIN
					MinByte := 1;
					MaxByte := 255;
					TempB := SliceTimer;
					InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
					SliceTimer := TempB;
				  END;
			'D' : BEGIN
					UseEMS := NOT UseEMS;
					IF (UseEMS) THEN
					  OvrUseEMS := TRUE
					ELSE
					  OvrUseEMS := FALSE;
				  END;
			'K' : BEGIN
					UseBIOS := NOT UseBIOS;
					DirectVideo := NOT UseBIOS;
				  END;
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
{---}
	  	'!' : LocalSec := NOT LocalSec;
        'A' : InputWNWC(RGSysCfgStr(2,TRUE),BBSName,(SizeOf(BBSName) - 1),Changed);
        'B' : Begin
				Repeat
				ClrScr;
				PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Connection Type',80));
				PrintACR('^1Please select the method(s) that users will be able to connect to your BBS');
				PrintACR('through.');
				Nl;
				PrintACR('^0(^1A^0) Modem');
				PrintACR('^0(^1B^0) Telnet');
				PrintACR('^0(^1C^0) Both');
				{PrintACR('^0(^1D^0) None');} { Don't think we need this as an option }
				NL;
				Prt('^0Connection Type [^1A^0-^1C^0,(^1Q^0)uit]: ');
				OneK(Cmd,'QABC',TRUE,TRUE);
						  Case Cmd Of
							'A' : Begin { Modem }
									InputFormatted(RGSysCfgStr(3,TRUE),BBSPhone,'###-###-####',FALSE);
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
									{ LeeW: Would be nice if phone number was remembered like telnet url }
									InputFormatted(RGSysCfgStr(3,TRUE),BBSPhone,'###-###-####',FALSE);
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
        'D' : BEGIN
			    {RGNoteStr(0,FALSE);}
			    NL;
			    Print('Renegade BBS V'+Version+' '#196#196' http://www.website.com/');
				PauseScr(FALSE);
		      END;
        'I' : BEGIN
                REPEAT
					CLS;
					PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Passwords',80));
					PrintACR('^0(^1A^0) SysOp PW             : ^1'+SysOpPW);
				    PrintACR('^0(^1B^0) New User PW          : ^1'+NewUserPW);
					PrintACR('^0(^1C^0) Min Baud Override PW : ^1'+MinBaudOverride);
					NL;
					Prt('^0System Passwords [^1A^0-^1C^0,(^1Q^0)uit]: ');				  
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
        '&' : BEGIN
                REPEAT
					CLS;
					PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Directories',80));
          PrintACR('^0(^10^0) Data Files          : ^1'+DataPath);
          PrintACR('^0(^11^0) Miscellaneous Files : ^1'+MiscPath);
          PrintACR('^0(^12^0) Message Storage     : ^1'+MsgPath);
          PrintACR('^0(^13^0) Nodelist (V7)       : ^1'+NodePath);
          PrintACR('^0(^14^0) Log/Trap Files      : ^1'+LogsPath);
          PrintACR('^0(^15^0) Temporary Files     : ^1'+TempPath);
          PrintACR('^0(^16^0) Protocols           : ^1'+ProtPath);
          PrintACR('^0(^17^0) Archivers           : ^1'+ArcsPath);
          PrintACR('^0(^18^0) File Attachments    : ^1'+FileAttachPath);
					NL;
					Prt('^0System Directories [^10^0-^18^0,(^1Q^0)uit]: ');				  
                  OneK(Cmd,'Q012345678',TRUE,TRUE);
                  CASE Cmd OF
        '0' : InputPath(RGSysCfgStr(24,TRUE),DataPath,TRUE,FALSE,Changed);
        '1' : InputPath(RGSysCfgStr(25,TRUE),MiscPath,TRUE,FALSE,Changed);
        '2' : InputPath(RGSysCfgStr(26,TRUE),MsgPath,TRUE,FALSE,Changed);
        '3' : InputPath(RGSysCfgStr(27,TRUE),NodePath,TRUE,FALSE,Changed);
        '4' : InputPath(RGSysCfgStr(28,TRUE),LogsPath,TRUE,FALSE,Changed);
        '5' : InputPath(RGSysCfgStr(29,TRUE),TempPath,FALSE,FALSE,Changed);
        '6' : InputPath(RGSysCfgStr(30,TRUE),ProtPath,TRUE,FALSE,Changed);
        '7' : InputPath(RGSysCfgStr(31,TRUE),ArcsPath,TRUE,FALSE,Changed);
        '8' : InputPath(RGSysCfgStr(32,TRUE),FileAttachPath,TRUE,FALSE,Changed);
        {'9' : InputPath(RGSysCfgStr(33,TRUE),lMultPath,TRUE,FALSE,Changed);} { LeeW: no longer used }
                  END;
                UNTIL (Cmd IN ['Q']) OR (HangUp);
                Cmd := #0;
              END;
		{        'J' : InputByteWOC(RGSysCfgStr(14,TRUE),EventWarningTime,[DisplayValue,NumbersOnly],0,255);}
        'K' : BEGIN
                REPEAT
				  ClrScr;
				  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Menus',80));
				  
				PrintACR('^0(^11^0) Global        : ^1'+IntToStr(GlobalMenu)+'');
				{ Menu commands here appear on all other menus unless global display is toggled off }
				PrintACR('^0(^12^0) Start         : ^1'+IntToStr(AllStartMenu)+'');
				{ First menu users are sent to after default login sequence }
				PrintACR('^0(^13^0) Shuttle Logon : ^1'+IntToStr(ShuttleLogonMenu));
				{ Shuttle Logon Menu }
				PrintACR('^0(^14^0) New User Info : ^1'+IntToStr(NewUserInformationMenu));
				{ New user information review before user saves/abandons profile }
				PrintACR('^0(^15^0) Message Read  : ^1'+IntToStr(MessageReadMenu));
				{ Prompt while listing files }
				PrintACR('^0(^16^0) File List     : ^1'+IntToStr(FileListingMenu));
				{ Prompt while reading messages }
				Nl;
				PrintACR('^0(^1Q^0) Quit');
				NL;
				Prt('^0Choice?: ^1');				  
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
                RGNoteStr(1,FALSE) {"This can only be changed locally"}
              ELSE
                BEGIN
				  NL;
				  IF (PYNQ('^0You must restart Renegade to '+AOnOff(MultiNode,'disable','enable')+
				  ' multi-node support, continue? ^1',0,FALSE)) THEN
				    BEGIN 
					  MultiNode := (NOT MultiNode);
		  			  SaveGeneral(FALSE);
			  		  ClrScr;
					  NL;
				 	  Print('^0Multi-node support '+AOnOff(MultiNode,'enabled','disabled')+'. Please restart Renegade ...');
					  NL;
					  Halt;
				    END
				  ELSE
				    BEGIN
					  { LeeW: Do nothing }
				    END;
              END;
        'N' : BEGIN
                NetworkMode := (NOT NetworkMode);
                IF (NetworkMode) THEN
                  LocalSec := TRUE
                ELSE
                  LocalSec := PYNQ(RGSysCfgStr(23,TRUE),0,FALSE);
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