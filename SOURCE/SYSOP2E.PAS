
{ System Toggles }

(*  1.  Add checking for deleted users or forwarded mail to option 1 *)

UNIT SysOp2E;

INTERFACE

PROCEDURE SystemFlaggedFunctions;

IMPLEMENTATION

USES
  Crt,
  Common,
  MiscUser;

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
      PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : System Toggles',80));
     
      PrintACR('|07(|15C|07) Local Security Protection : |15'+ShowOnOff(LocalSec)+
	   '  |08³  - Login Procedure -');
      PrintACR('|07(|15D|07) Use EMS For Overlay File  : |15'+ShowOnOff(UseEMS)+
	   '  |08³  |07(|15B|07) Phone Number In Logon     : |15'+ShowOnOff(PhonePW));
      PrintACR('|07(|15E|07) Global Activity Trapping  : |15'+ShowOnOff(GlobalTrap)+
	   '  |08³  |07(|15G|07) AutoMessage In Logon      : |15'+ShowOnOff(AutoMInLogon));
      PrintACR('|07(|15F|07) Auto Chat Buffer Open     : |15'+ShowOnOff(AutoChatOpen)+
	   '  |08³  |07(|15H|07) Bulletins In Logon        : |15'+ShowOnOff(BullInLogon));
      PrintACR('|07(|15J|07) Strip Color Off SysOp Log : |15'+ShowOnOff(StripCLog)+
	   '  |08³  |07(|15I|07) User Info In Logon        : |15'+ShowOnOff(YourInfoInLogon));
      PrintACR('|07(|15K|07) Offhook In Local Logon    : |15'+ShowOnOff(OffHookLocalLogon)+
	   '  |08³  |07(|15W|07) Random Quote In Logon     : |15'+ShowOnOff(LogonQuote));
      PrintACR('|07(|15L|07) Trap Teleconferencing     : |15'+ShowOnOff(TrapTeleConf)+
	   '  |08³  |07(|15X|07) User Add Quote In Logon   : |15'+ShowOnOff(UserAddQuote));
      PrintACR('|07(|15M|07) Compress File/Msg Numbers : |15'+ShowOnOff(CompressBases)+
	   '  |08³  |07(|15S|07) Use Shuttle Logon         : |15'+ShowOnOff(ShuttleLog));
      PrintACR('|07(|15N|07) Use BIOS For Video Output : |15'+ShowOnOff(UseBIOS));
      PrintACR('|07(|15O|07) Use IEMSI Handshakes      : |15'+ShowOnOff(UseIEMSI));
      PrintACR('|07(|15R|07) Swap Shell Function       : |15'+ShowOnOff(SwapShell));
      PrintACR('|07(|15T|07) Chat Call Paging          : |15'+ShowOnOff(ChatCall));
      PrintACR('|07(|15U|07) Time Limits Are Per Call  : |15'+ShowOnOff(PerCall));
      PrintACR('|07(|15V|07) SysOp Password Checking   : |15'+ShowOnOff(SysOpPWord));
      PrintACR('|07(|15Y|07) Use Message Area Lightbar : |15'+ShowOnOff(UseMsgAreaLightBar));
      PrintACR('|07(|15Z|07) Use File Area Lightbar    : |15'+ShowOnOff(UseFileAreaLightBar));
	  Nl;	  
      PrintACR('|07(|152|07) Mins Before Timeout Bell : |15'+AOnOff((TimeOutBell = -1),'Off',PadLeftInt(TimeOutBell,3)));
      PrintACR('|07(|153|07) Mins Before Timeout      : |15'+AOnOff((TimeOut = -1),'Off',PadLeftInt(TimeOut,3)));
      Nl;
      Prt('|07Enter Selection Or (|15Q|07) To Quit: |15');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ123',TRUE,TRUE);
      CASE Cmd OF
        'A' : AllowAlias := NOT AllowAlias;
        'B' : BEGIN
                PhonePW := NOT PhonePW;
                IF (PhonePW) THEN
                 Begin
                 { If we`re going to verify phone numbers, users will need to provide them, so we`ll also ask
                                   for phone numbers in new user application. }
                  NewUserToggles[7] := True;
                  Print('Also Enabling Phone Number In New User Application.');
                  PauseScr(False);
                 End
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
                  Print('%LFCompressing file/message areas ...')
                ELSE
                  Print('%LFDe-compressing file/message areas ...');
                NewCompTables;
              END;
        'N' : BEGIN
                UseBIOS := NOT UseBIOS;
                DirectVideo := NOT UseBIOS;
              END;
        'O' : UseIEMSI := NOT UseIEMSI;
        'P' : ClosedSystem := NOT ClosedSystem;
        'R' : SwapShell := NOT SwapShell;
        'S' : ShuttleLog := NOT ShuttleLog;
        'T' : ChatCall := NOT ChatCall;
        'U' : PerCall := NOT PerCall;
        'V' : SysOpPWord := NOT SysOpPWord;
        'W' : LogonQuote := NOT LogonQuote;
        'X' : UserAddQuote := NOT UserAddQuote;
        'Y' : UseMsgAreaLightBar := NOT UseMsgAreaLightBar;
        'Z' : UseFileAreaLightBar := NOT UseFileAreaLightBar;
        '1'..'3' :
              BEGIN
			  Nl;
                Prt('|07Select (|15E|07)nable (|15D|07)isable or [|15ENTER|07] To Quit: |15');
                OneK(Cmd1,^M'ED',TRUE,TRUE);
                IF (Cmd1 IN ['E','D']) THEN
                BEGIN
                  CASE Cmd1 OF
                    'E' : BEGIN
                            CASE Cmd OF
                              '1' : BEGIN
                                      LowNum := 1;
                                      HiNum := (MaxUsers - 1);
                                      TempInt := NewApp;
                                    END;
                              '2' : BEGIN
                                      LowNum := 1;
                                      HiNum := 20;
                                      TempInt := TimeOutBell;
                                    END;
                              '3' : BEGIN
                                      LowNum := 1;
                                      HiNum := 20;
                                      TempInt := TimeOut;
                                    END;
                            END;
                            InputIntegerWOC('%LFEnter value for this function',TempInt,[NumbersOnly],LowNum,HiNum);
                          END;
                    'D' : TempInt := -1;
                  END;
                  CASE Cmd OF
                    '1' : NewApp := TempInt;
                    '2' : TimeOutBell := TempInt;
                    '3' : TimeOut := TempInt;
                  END;
                  Cmd := #0;
                END;
          END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
