{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  EVENT EDITOR
  
  testing new lonekx cmd
}

UNIT SysOp6;

INTERFACE

PROCEDURE EventEditor;

IMPLEMENTATION

USES
  Common,
  Common0,
  TimeFunc;

PROCEDURE EventEditor;
VAR
  TempEvent: EventRecordType;
  Cmd: Char;
  RecNumToList: Integer;
  SaveTempPause: Boolean;

  FUNCTION DaysEventActive(EventDays: EventDaysType; C1,C2: Char): AStr;
  CONST
    Days: Str7 = 'SMTWTFS';
  VAR
    TempStr: AStr;
    Counter: Byte;
  BEGIN
    TempStr := '';
    FOR Counter := 0 TO 6 DO
     IF (Counter IN EventDays) THEN
       TempStr := TempStr + '^'+C1+Days[Counter + 1]
     ELSE
       TempStr := TempStr + '^'+C2+'-';
    DaysEventActive := TempStr;
  END;

  FUNCTION NextDay(Date: Str10): LongInt;
  VAR
    Day,
    Month,
    Year: Word;
  BEGIN
    Month := StrToInt(Copy(Date,1,2));
    Day := StrToInt(Copy(Date,4,2));
    Year := StrToInt(Copy(Date,7,4));
    IF (Day = 31) AND (Month = 12) THEN
      BEGIN
		Inc(Year);
		Month := 1;
		Day := 1;
      END
    ELSE
      BEGIN
		IF (Day < Days(Month,Year)) THEN
		  Inc(Day)
		ELSE IF (Month < 12) THEN
		  BEGIN
			Inc(Month);
			Day := 1;
		  END;
	  END;
    NextDay := Date2PD(ZeroPad(IntToStr(Month))+'/'+ZeroPad(IntToStr(Day))+'/'+IntToStr(Year));
  END;

  FUNCTION ShowTime(W: Word): Str5;
  BEGIN
    ShowTime := ZeroPad(IntToStr(W DIV 60))+':'+ZeroPad(IntToStr(W MOD 60));
  END;

  PROCEDURE ToggleEFlag(EFlagT: EventFlagType; VAR EFlags: EFlagSet);
  BEGIN
    IF (EFlagT IN EFlags) THEN
      Exclude(EFlags,EFlagT)
    ELSE
      Include(EFlags,EFlagT);
  END;

  PROCEDURE ToggleEFlags(C: Char; VAR EFlags: EFlagSet; VAR Changed: Boolean);
  VAR
    SaveEFlags: EFlagSet;
  BEGIN
    SaveEFlags := EFlags;
    CASE C OF
      'A' : ToggleEFlag(EventIsExternal,EFlags);
      'B' : ToggleEFlag(EventIsActive,EFlags);
      'C' : ToggleEFlag(EventIsShell,EFlags);
      'D' : ToggleEFlag(EventIsOffhook,EFlags);
      'E' : ToggleEFlag(EventIsMonthly,EFlags);
      'F' : ToggleEFlag(EventIsPermission,EFlags);
      'G' : ToggleEFlag(EventIsLogon,EFlags);
      'H' : ToggleEFlag(EventIsChat,EFlags);
      'I' : ToggleEFlag(EventIsPackMsgAreas,EFlags);
      'J' : ToggleEFlag(EventIsSortFiles,EFlags);
      'K' : ToggleEFlag(EventIsSoft,EFlags);
      'L' : ToggleEFlag(EventIsMissed,EFlags);
      'M' : ToggleEFlag(BaudIsActive,EFlags);
      'N' : ToggleEFlag(AcsIsActive,EFlags);
      'O' : ToggleEFlag(TimeIsActive,EFlags);
      'P' : ToggleEFlag(ARisActive,EFlags);
      'Q' : ToggleEFlag(SetARisActive,EFlags);
      'R' : ToggleEFlag(ClearARisActive,EFlags);
      'S' : ToggleEFlag(InRatioIsActive,EFlags);
    END;
    IF (EFlags <> SaveEFlags) THEN
      Changed := TRUE;
  END;

  PROCEDURE InitEventVars(VAR Event: EventRecordType);
  BEGIN
	FillChar(Event,SizeOf(Event),0);
	WITH Event DO
	  BEGIN
		EventDescription := '<< New Event >>';
		EventDayOfMonth := 0;
		EventDays := [];
		EventStartTime := 0;
		EventFinishTime := 0;
		EventQualMsg := '';
		EventNotQualMsg := '';
		EventPreTime := 0;
		EventNode := 0;
		EventLastDate := 0;
		EventErrorLevel := 0;
		EventShellPath := '';
		LoBaud := 300;
		HiBaud := 19200;
		EventACS := 's10';
		MaxTimeAllowed := 60;
		SetARflag := '@';
		ClearARflag := '@';
		EFlags := [EventIsExternal,EventIsShell];
	  END;
  END;

  PROCEDURE DeleteEvent(TempEvent1: EventRecordType; RecNumToDelete: Integer);
  VAR
    RecNum: Integer;
  BEGIN
    IF (NumEvents = 0) THEN
      Messages(4,0,'events')
    ELSE
	  BEGIN
		RecNumToDelete := -1;
		InputIntegerWOC('%LFEvent to delete?',RecNumToDelete,[NumbersOnly],1,NumEvents);
		IF (RecNumToDelete >= 1) AND (RecNumToDelete <= NumEvents) THEN
		  BEGIN
			Reset(EventFile);
			Seek(EventFile,(RecNumToDelete - 1));
			Read(EventFile,TempEvent1);
			Close(EventFile);
			LastError := IOResult;
			Print('%LFEvent: ^5'+TempEvent1.EventDescription);
			IF PYNQ('%LFAre you sure you want to delete it? ',0,FALSE) THEN
			  BEGIN
				Print('%LF[> Deleting event record ...');
				Dec(RecNumToDelete);
				Reset(EventFile);
				IF (RecNumToDelete >= 0) AND (RecNumToDelete <= (FileSize(EventFile) - 2)) THEN
				  FOR RecNum := RecNumToDelete TO (FileSize(EventFile) - 2) DO
					BEGIN
					  Seek(EventFile,(RecNum + 1));
					  Read(EventFile,Event);
					  Seek(EventFile,RecNum);
					  Write(EventFile,Event);
					END;
				  Seek(EventFile,(FileSize(EventFile) - 1));
				  Truncate(EventFile);
				  Close(EventFile);
				  LastError := IOResult;
				  Dec(NumEvents);
				  SysOpLog('* Deleted event: ^5'+TempEvent1.EventDescription);
			  END;
		  END;
	  END;
  END;

  (*
  PROCEDURE CheckEvent(Event: EventRecordType; StartErrMsg,EndErrMsg: Byte; VAR Ok: Boolean);
  VAR
    Counter: Byte;
  BEGIN
    FOR Counter := StartErrMsg TO EndErrMsg DO
      CASE Counter OF
        1 : ;
      END;
  END;
  *)
  
{ ------------------ formatting done to here ------------------- }

  PROCEDURE EditEvent(TempEvent1: EventRecordType; VAR Event: EventRecordType; VAR Cmd1: Char;
			VAR RecNumToEdit: Integer; VAR Changed: Boolean; Editing: Boolean);
  CONST
    BaudRates: ARRAY [1..20] OF LongInt = (300,600,1200,2400,4800,7200,9600,12000,14400,16800,19200,
										  21600,24000,26400,28800,31200,33600,38400,57600,115200);
  VAR
    OneKCmds,
    TempStr: AStr;
    Counter: Byte;
  BEGIN
    WITH Event DO
      REPEAT
        IF (Cmd1 <> '?') THEN
		  BEGIN
			Abort := FALSE;
			Next := FALSE;
			CLS;
			IF (Editing) THEN
			  ConfigHeader('Editing Event #'+IntToStr(RecNumToEdit)+' Of '+IntToStr(NumEvents))
			ELSE
			  ConfigHeader('Inserting Event #'+IntToStr(RecNumToEdit)+' Of '+IntToStr(NumEvents + 1));
			
		  PrintACR('^0(^1A^0) Internal/External      : ^1'+AOnOff(EventIsExternal IN EFlags,'External','Internal'));
		  PrintACR('^0(^1B^0) Description            : ^1'+EventDescription);
		  PrintACR('^0(^1C^0) Active                 : ^1'+AOnOff(EventIsActive IN EFlags,'Active','Inactive'));
		  PrintACR('^0(^1D^0) Scheduled Day(s)       : ^1'+AOnOff(EventIsMonthly IN EFlags,
													   {Monthly} IntToStr(EventDayOfMonth)+DateSuffix(EventDayOfMonth)+'^0 Of Each Month',
													   {Daily} DaysEventActive(EventDays,'1','0')));
		  
		  IF NOT (EventIsExternal IN EFlags) THEN
		    BEGIN
			  PrintACR('^0(^1E^0) Scheduled Time         : ^1'+ShowTime(EventStartTime)+' To '+ShowTime(EventFinishTime));
			END
		  ELSE
		    BEGIN
			  PrintACR('^0(^1E^0) Scheduled Time         : ^1'+ShowTime(EventStartTime));
			END;
		  PrintACR('^0^0^0     - Next Execution      : ^1'+AOnOff(EventIsActive IN EFlags,PD2Date(EventLastDate)+' ^0At^1 '
														  +ShowTime(EventStartTime),'Never'));
		  PrintACR('^0^0^0     - Executed Today      : ^1'+ShowYesNo(PD2Date(EventLastDate) = DateStr));
          PrintACR('^0(^1F^0) Run If Missed          : ^1'+ShowYesNo(EventIsMissed IN EFlags));
		  PrintACR('^0(^1G^0) Node Number            : ^1'+IntToStr(EventNode));
		  IF (EventIsExternal IN EFlags) THEN
			BEGIN
              IF (EventIsErrorLevel IN EFlags) THEN
				TempStr := 'Error Level: '+IntToStr(EventErrorLevel)
              ELSE IF (EventIsShell IN EFlags) THEN
				TempStr := 'Shell: "'+EventShellPath+'"'
              ELSE IF (EventIsSortFiles IN EFlags) THEN
				TempStr := 'Sort File Areas'
              ELSE IF (EventIsPackMsgAreas IN EFlags) THEN
				TempStr := 'Pack Message Areas'
              ELSE IF (EventIsFilesBBS IN EFlags) THEN
				TempStr := 'Check Files.BBS';
				
              PrintACR('^0(^1H^0) Type                   : ^1'+TempStr);
			  PrintACR('^0(^1I^0) Hard/Soft Execution    : ^1'+AOnOff(EventIsSoft IN EFlags,'Soft','Hard'));
              PrintACR('^0(^1J^0) Phone Status           : ^1'+AOnOff(EventIsOffHook IN EFlags,
															'^0Take offline ^1'+IntToStr(EventPreTime)+'^0 minute(s) prior to the event',
															'Remain online'));
              
			END
          ELSE
			BEGIN
		      PrintACR('^0(^1H^0) Type                   : ^1'+AOnOff(EventIsChat IN EFlags,'Chat','Logon'));
              PrintACR('^0(^1I^0) Permission/Restriction : ^1'+AOnOff(EventIsPermission IN EFlags,
															'Permission','Restriction'));
              PrintACR('^0(^1J^0) Affected Message       : "^1'+EventQualMsg+'^1"');
              PrintACR('^0(^1K^0) Unaffected Message     : "^1'+EventNotQualMsg+'^1"');
			END;

		  IF (NOT (EventIsExternal IN EFlags)) THEN
          BEGIN
            NL;
			(*
            PrintACR('       ^0 --- ^1 Qualifiers ^0---');
            NL;
			*)
            PrintACR('^0(^11^0) Baud Rate Range        : ^1'+AOnOff(BaudIsActive IN EFlags,
														IntToStr(LoBaud)+'^0 - ^1'+IntToStr(HiBaud),
														'Inactive'));
            PrintACR('^0(^12^0) ACS                    : ^1'+AOnOff(ACSIsActive IN EFlags,EventACS,'Inactive'));
            IF (EventIsPermission IN EFlags) THEN
              BEGIN
				PrintACR('^0(^13^0) Maximum Time           : ^1'+AOnOff(TimeIsActive IN EFlags,
															IntToStr(MaxTimeAllowed),
															'Inactive'));
				PrintACR('^0(^14^0) Set AR Flag            : ^1'+AOnOff(SetArIsActive IN EFlags,
															SetArFlag,
															'Inactive'));
				PrintACR('^0(^15^0) Clear AR Flag          : ^1'+AOnOff(ClearArIsActive IN EFlags,
															ClearArFlag,
															'Inactive'));
              END;
            PrintACR('^0(^16^0) UL/DL Ratio Check      : ^1'+AOnOff(InRatioIsActive IN EFlags,
														  'Active',
														  'Inactive'));
          END;
        END;
        IF NOT (EventIsExternal IN EFlags) THEN
		  BEGIN
			OneKCmds := 'K';
			IF (EventIsPermission IN EFlags) THEN
			  OneKCmds := 'K123456'
			ELSE
			  OneKCmds := 'K126';
		  END
		ELSE
		  OneKCmds := '';
		
        lOneKX('^0Modify '+AOnOff(EventIsExternal IN EFlags,'External','Internal')+' Event',
              Cmd1,'ABCDEFGHIJ'+OneKCmds+'[]<>/?Q'^M,TRUE,TRUE,TRUE,TRUE);
        CASE Cmd1 OF
          'A' : ToggleEFlagS('A',EFlags,Changed); { Internal / External }
		  
          'B' : InputWN1('%LFNew description: ',EventDescription,30,[InterActiveEdit],Changed); { Description }
		  
          'C' : ToggleEFlags('B',EFlags,Changed); { Active / Inactive }

          'D' : BEGIN { Daily / Monthly }
				  lOneKX('^0Execute Event (^1D^0)aily, Or (^1M^0)onthly? [<^1CR^0>Quit]: ',
				  Cmd1,'DM'^M,FALSE,TRUE,TRUE,TRUE);
				  CASE Cmd1 OF
					'D' : BEGIN
							BEGIN
							  Exclude(EFlags,EventIsMonthly);
							  EventDayOfMonth := 0;
							  Changed := TRUE;
							END;
							REPEAT
							  NL;
							  Print('^0Active Day(s): ^1'+DaysEventActive(EventDays,'1','0'));
							  NL;
							  LCmds(20,1,'1 Sunday','');
							  LCmds(20,1,'2 Monday','');
							  LCmds(20,1,'3 Tuesday','');
							  LCmds(20,1,'4 Wednesday','');
							  LCmds(20,1,'5 Thursday','');
							  LCmds(20,1,'6 Friday','');
							  LCmds(20,1,'7 Saturday','');
							  lOneKX('^0Select Active Days',Cmd1,^M'1234567',TRUE,TRUE,TRUE,TRUE);
							  IF (Cmd1 <> ^M) THEN
								BEGIN
								  IF ((StrToInt(Cmd1) - 1) IN EventDays) THEN
									Exclude(EventDays,(StrToInt(Cmd1) - 1))
								  ELSE
									Include(EventDays,(StrToInt(Cmd1) - 1));
								  Changed := TRUE;
								END;
							UNTIL (Cmd1 = ^M) OR (HangUp);
							Cmd1 := #0;
						  END;
					'M' : BEGIN
							IF (NOT (EventIsMonthly IN EFlags)) THEN
							  BEGIN
								Include(EFlags,EventIsMonthly);
								EventDays := [];
								Changed := TRUE;
							  END;
							NL;
							InputByteWC('^0Execute Event On Which Day Of The Month?',EventDayOfMonth,[],1,31,Changed);
						  END;
				  END;
				  Cmd1 := #0;
				END;
		  'E' : IF (EventIsExternal IN EFlags) THEN { Start / Finish Time }
                BEGIN
                  Prt('%LFNew event start time? (24 Hour Format) Hour: (0-23), Minute: (0-59): ');
                  InputFormatted('',TempStr,'##:##',TRUE);
                  IF (TempStr <> '') AND (Length(TempStr) = 5) AND (Pos(':',TempStr) = 3) THEN
                  BEGIN
                    IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
                    BEGIN
                      EventStartTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)));
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
                      Print('%LF^5Invalid time - Format is HH:MM (24 hour military)');
                      PauseScr(FALSE);
                    END;
                  END;
                END
                ELSE
				BEGIN
                  Prt('%LFNew event start time? (24 Hour Format) Hour: (0-23), Minute: (0-59): ');
                  InputFormatted('',TempStr,'##:##',TRUE);
                  IF (TempStr <> '') AND (Length(TempStr) = 5) AND (Pos(':',TempStr) = 3) THEN
                  BEGIN
                    IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
                    BEGIN
                      EventStartTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)));
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
					  NL;
                      Print('^0Invalid time - Format is HH:MM (24 hour military)');
                      PauseScr(FALSE);
                    END;
                  END;
                  Prt('%LFNew event finish time? (24 Hour Format) Hour: (0-23), Minute: (0-59): ');
                  InputFormatted('',TempStr,'##:##',TRUE);
                  IF (TempStr <> '') AND (Length(TempStr) = 5) AND (Pos(':',TempStr) = 3) THEN
                  BEGIN
                    IF (StrToInt(Copy(TempStr,1,2)) IN [0..23]) AND (StrToInt(Copy(TempStr,4,2)) IN [0..59]) THEN
                    BEGIN
                      EventFinishTime := ((StrToInt(Copy(TempStr,1,2)) * 60) + StrToInt(Copy(TempStr,4,2)));
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
                      Print('%LF^5Invalid time - Format is HH:MM (24 hour military)');
                      PauseScr(FALSE);
                    END;
                  END;
                END;
				
          'F' : BEGIN { Run Event If Missed? }
			  IF PYNQ('%LFRun this event later if the event time is missed? ',0,FALSE) THEN
                    Include(EFlags,EventIsMissed)
                  ELSE
                    Exclude(EFlags,EventIsMissed);
                  Changed := TRUE;
                END;
          'G' : InputByteWC('%LFNode number to execute event from (0=All)',EventNode, { Node }
                            [DisplayValue,NumbersOnly],0,MaxNodes,Changed);				
          'H' : IF (EventIsExternal IN EFlags) THEN { Event Type }
                BEGIN
				  NL;
                  Print('^0External Event Types: ');
                  NL;
                  LCmds(20,1,'1 Errorlevel','');
                  LCmds(20,1,'2 Shell','');
                  LCmds(20,1,'3 Sort Files','');
                  LCmds(20,1,'4 Pack Message Areas','');
                  LCmds(20,1,'5 Check Files.BBS','');
				  {NL;}
                  lOneKX('^0Select Event Type',Cmd1,'12345'^M,TRUE,TRUE,TRUE,TRUE);
                  IF (Cmd1 <> ^M) THEN
                  BEGIN
                    CASE Cmd1 OF
                      '1' : BEGIN
                              IF (EventIsShell IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsShell);
                                EventShellPath := '';
                              END;
                              IF (EventIsSortFiles IN EFlags) THEN
                                Exclude(EFlags,EventIsSortFiles);
                              IF (EventIsPackMsgAreas IN EFlags) THEN
                                Exclude(EFlags,EventIsPackMsgAreas);
                              IF (EventIsFilesBBS IN EFlags) THEN
                                Exclude(EFlags,EventIsFilesBBS);
                              Include(EFlags,EventIsErrorLevel);
                              InputByteWC('%LFError Level',EventErrorLevel,[],0,255,Changed);
                            END;
                      '2' : BEGIN
                              IF (EventIsErrorLevel IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsErrorLevel);
                                EventErrorLevel := 0;
                              END;
                              IF (EventIsSortFiles IN EFlags) THEN
                                Exclude(EFlags,EventIsSortFiles);
                              IF (EventIsPackMsgAreas IN EFlags) THEN
                                Exclude(EFlags,EventIsPackMsgAreas);
                              IF (EventIsFilesBBS IN EFlags) THEN
                                Exclude(EFlags,EventIsFilesBBS);
                              Include(EFlags,EventIsShell);
                              InputWN1('%LFShell file: ',EventShellPath,8,[UpperOnly],Changed);
                            END;
                      '3' : BEGIN
                              IF (EventIsShell IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsShell);
                                EventShellPath := '';
                              END;
                              IF (EventIsErrorLevel IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsErrorLevel);
                                EventErrorLevel := 0;
                              END;
                              IF (EventIsPackMsgAreas IN EFlags) THEN
                                Exclude(EFlags,EventIsPackMsgAreas);
                              IF (EventIsFilesBBS IN EFlags) THEN
                                Exclude(EFlags,EventIsFilesBBS);
                              Include(EFlags,EventIsSortFiles);
                            END;
                      '4' : BEGIN
                              IF (EventIsShell IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsShell);
                                EventShellPath := '';
                              END;
                              IF (EventIsErrorLevel IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsErrorLevel);
                                EventErrorLevel := 0;
                              END;
                              IF (EventIsSortFiles IN EFlags) THEN
                                Exclude(EFlags,EventIsSortFiles);
                              IF (EventIsFilesBBS IN EFlags) THEN
                                Exclude(EFlags,EventIsFilesBBS);
                              Include(EFlags,EventIsPackMsgAreas);
                            END;
                      '5' : BEGIN
                              IF (EventIsShell IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsShell);
                                EventShellPath := '';
                              END;
                              IF (EventIsErrorLevel IN EFlags) THEN
                              BEGIN
                                Exclude(EFlags,EventIsErrorLevel);
                                EventErrorLevel := 0;
                              END;
                              IF (EventIsSortFiles IN EFlags) THEN
                                Exclude(EFlags,EventIsSortFiles);
                              IF (EventIsPackMsgAreas IN EFlags) THEN
                                Exclude(EFlags,EventIsPackMsgAreas);
                              Include(EFlags,EventIsFilesBBS);
                            END;
                    END;
                    Changed := TRUE;
                  END;
                  Cmd1 := #0;
                END
				else
				BEGIN
				  NL;
                  Print('^0Internal Event Types:');
                  NL;
                  LCmds(7,3,'1 Logon','');
                  LCmds(7,3,'2 Chat','');
                  lOneKX('Select Event Type',Cmd1,'12'^M,TRUE,TRUE,TRUE,TRUE);
                  IF (Cmd1 <> ^M) THEN
                  BEGIN
                    CASE Cmd1 OF
                      '1' : BEGIN
                              IF (EventIsChat IN EFlags) THEN
                                Exclude(EFlags,EventIsChat);
                              Include(EFlags,EventIsLogon);
                            END;
                      '2' : BEGIN
                              IF (EventIsLogon IN EFlags) THEN
                                Exclude(EFlags,EventIsLogon);
                              Include(EFlags,EventIsChat);
                            END;
                    END;
                    Changed := TRUE;
                  END;
                  Cmd1 := #0;
                END;
		  'I' : IF (EventIsExternal IN EFlags) THEN { Soft / Hard }
				  ToggleEFlags('K',EFlags,Changed)
				ELSE
				  BEGIN
					ToggleEFlag(EventIsPermission,EFlags);
					Changed := TRUE;
				  END;
		  'J' : IF (EventIsExternal IN EFlags) THEN {}
                BEGIN
                  IF (EventIsOffHook IN EFlags) THEN
                  BEGIN
                    Exclude(EFlags,EventIsOffHook);
                    EventPreTime := 0;
                    Changed := TRUE;
                  END
                  ELSE
                  BEGIN
                    Include(EFlags,EventIsOffHook);
                    InputByteWC('%LFMinutes before event to take phone offhook',EventPreTime,[],0,255,Changed);
                  END;
                END
                ELSE
				  BEGIN
					NL;
					InputWN1('^0Message/@File For Users Affected By Event:%LF',EventQualMsg,64,[],Changed);
				  END;
(*
	{ IMPLEMENT THIS -- was under last day execd }
				IF (EventIsExternal IN EFlags) THEN
                BEGIN
                  IF (PD2Date(EventLastDate) = DateStr) THEN
                    EventLastDate := NextDay(PD2Date(EventLastDate))
                  ELSE
                    EventLastDate := Date2PD(DateStr);
                  Changed := TRUE;
                END
                ELSE
*)
		  'K' : BEGIN
				  NL;
				  InputWN1('^0Message/@File For Users Unaffected By Event:%LF',EventNotQualMsg,64,[],Changed);
				END;
          '1' : IF (NOT (EventIsExternal IN EFlags)) THEN
                  IF (BaudIsActive IN EFlags) THEN
                  BEGIN
                    Exclude(EFlags,BaudIsActive);
                    LoBaud := 300;
                    HiBaud := 115200;
                    Changed := TRUE;
                  END
                  ELSE
                  BEGIN
                    Include(EFlags,BaudIsActive);
                    Print('%LF^5Baud lower limit:^1%LF');
                    Counter := 1;
                    WHILE (Counter <= 20) AND (NOT Abort) AND (NOT HangUp) DO
                    BEGIN
                      PrintACR(Char(Counter + 64)+'. '+IntToStr(BaudRates[Counter]));
                      Inc(Counter);
                    END;
                    lOneKX('%LFWhich? (^5A^4-^5T^4): ',Cmd1,'ABCDEFGHIJKLMNOPQRST',TRUE,TRUE,TRUE,TRUE);
                    LoBaud := BaudRates[Ord(Cmd1) - 64];
                    Print('%LF^5Baud upper limit:^1%LF');
                    Counter := 1;
                    WHILE (Counter <= 20) AND (NOT Abort) AND (NOT HangUp) DO
                    BEGIN
                      PrintACR(Char(Counter + 64)+'. '+IntToStr(BaudRates[Counter]));
                      Inc(Counter);
                    END;
                    lOneKX('%LFWhich? (^5A^4-^5T^4): ',Cmd1,'ABCDEFGHIJKLMNOPQRST',TRUE,TRUE,TRUE,TRUE);
                    HiBaud := BaudRates[Ord(Cmd1) - 64];
                    Changed := TRUE;
                    Cmd1 := #0;
                  END;
          '2' : IF (NOT (EventIsExternal IN EFlags)) THEN
                  IF (ACSIsActive IN EFlags) THEN
                  BEGIN
                    Exclude(EFlags,ACSIsActive);
                    EventACS := 's10';
                    Changed := TRUE;
                  END
                  ELSE
                  BEGIN
                    Include(EFlags,ACSIsActive);
                    InputWN1('%LFSL ACS: ',EventACS,(SizeOf(EventACS) - 1),[InterActiveEdit],Changed);
                  END;
          '3' : IF (NOT (EventIsExternal IN EFlags)) THEN
                  IF (EventIsPermission IN EFlags) THEN
                  BEGIN
                    IF (TimeIsActive IN EFlags) THEN
                    BEGIN
                      Exclude(EFlags,TimeIsActive);
                      MaxTimeAllowed := 60;
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
                      Include(EFlags,TimeIsActive);
                      InputWordWoc('%LFMaximum time allowed on-line (minutes)',MaxTimeAllowed,
                                   [DisplayValue,NumbersOnly],0,65535);
                    END;
                  END;
          '4' : IF NOT (EventIsExternal IN EFlags) THEN
                  IF (EventIsPermission IN EFlags) THEN
                  BEGIN
                    IF (SetArIsActive IN EFlags) THEN
                    BEGIN
                      Exclude(EFlags,SetArIsActive);
                      SetArFlag := '@';
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
                      Include(EFlags,SetArIsActive);
                      lOneKX('%LFAR flag to set (^5A^4-^5Z^4): ',Cmd1,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',TRUE,TRUE,TRUE,TRUE);
                      SetArFlag := Cmd1;
                      Cmd1 := #0;
                    END;
                  END;
          '5' : IF NOT (EventIsExternal IN EFlags) THEN
                  IF (EventIsPermission IN EFlags) THEN
                  BEGIN
                    IF (ClearArIsActive IN EFlags) THEN
                    BEGIN
                      Exclude(EFlags,ClearArIsActive);
                      ClearArFlag := '@';
                      Changed := TRUE;
                    END
                    ELSE
                    BEGIN
                      Include(EFlags,ClearArIsActive);
                      lOneKX('%LFAR flag to clear (^5A^4-^5Z^4): ',Cmd1,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',TRUE,TRUE,TRUE,TRUE);
                      ClearArFlag := Cmd1;
                      Cmd1 := #0;
                    END;
                  END;
          '6' : IF (NOT (EventIsExternal IN EFlags)) THEN
                  ToggleEFlags('S',EFlags,Changed);
          '[' : IF (RecNumToEdit > 1) THEN
                  Dec(RecNumToEdit)
                ELSE
                BEGIN
                  Messages(2,0,'');
                  Cmd1 := #0;
                END;
          ']' : IF (RecNumToEdit < NumEvents) THEN
                  Inc(RecNumToEdit)
                ELSE
                BEGIN
                  Messages(3,0,'');
                  Cmd1 := #0;
                END;
		  '<' : IF (RecNumToEdit <> 1) THEN
                  RecNumToEdit := 1
                ELSE
                BEGIN
                  Messages(2,0,'');
                  Cmd1 := #0;
                END;
          '/' : BEGIN
                  InputIntegerWOC('%LFJump to entry?',RecNumToEdit,[NumbersOnly],1,NumEvents);
                  IF (RecNumToEdit < 1) OR (RecNumToEdit > NumEvents) THEN
                    Cmd1 := #0;
                END;
          '>' : IF (RecNumToEdit <> NumEvents) THEN
                  RecNumToEdit := NumEvents
                ELSE
                BEGIN
                  Messages(3,0,'');
                  Cmd1 := #0;
                END;
          '?' : BEGIN
				  NL;
                  Print('^0<^1CR^0> Redisplay Screen');
                  {Print('^3<Fill Me in:Modify item');}
                  LCmds(22,1,'[ Previous Entry','] Next Entry');
                  LCmds(22,1,'< First Entry','> Last Entry');
                  LCmds(22,1,'/ Jump To Entry','Q Quit And Save');
                END;
        END;
      UNTIL (Pos(Cmd1,'Q[]FJL') <> 0) OR (HangUp);
  END;

  PROCEDURE InsertEvent(TempEvent1: EventRecordType; Cmd1: Char; RecNumToInsertBefore: Integer);
  VAR
    RecNum,
    RecNumToEdit: Integer;
    Ok,
    Changed: Boolean;
  BEGIN
    IF (NumEvents = MaxEvents) THEN
      Messages(5,MaxEvents,'events')
    ELSE
    BEGIN
      RecNumToInsertBefore := -1;
      InputIntegerWOC('%LFEvent to insert before?',RecNumToInsertBefore,[NumbersOnly],1,(NumEvents + 1));
      IF (RecNumToInsertBefore >= 1) AND (RecNumToInsertBefore <= (NumEvents + 1)) THEN
      BEGIN
        Reset(EventFile);
        InitEventVars(TempEvent1);
        IF (RecNumToInsertBefore = 1) THEN
          RecNumToEdit := 1
        ELSE IF (RecNumToInsertBefore = (NumEvents + 1)) THEN
          RecNumToEdit := (NumEvents + 1)
        ELSE
          RecNumToEdit := RecNumToInsertBefore;
        REPEAT
          OK := TRUE;
          EditEvent(TempEvent1,TempEvent1,Cmd1,RecNumToEdit,Changed,FALSE);
          (*CheckEvent(TempEvent1,1,1,Ok); { Not implemented? } *)
          IF (NOT OK) THEN
            IF (NOT PYNQ('%LFContinue inserting event? ',0,TRUE)) THEN
              Abort := TRUE;
        UNTIL (OK) OR (Abort) OR (HangUp);
        IF (NOT Abort) AND (PYNQ('%LFIs this what you want? ',0,FALSE)) THEN
        BEGIN
          Print('%LF[> Inserting event record ...');
          Seek(EventFile,FileSize(EventFile));
          Write(EventFile,Event);
          Dec(RecNumToInsertBefore);
          FOR RecNum := ((FileSize(EventFile) - 1) - 1) DOWNTO RecNumToInsertBefore DO
          BEGIN
            Seek(EventFile,RecNum);
            Read(EventFile,Event);
            Seek(EventFile,(RecNum + 1));
            Write(EventFile,Event);
          END;
          FOR RecNum := RecNumToInsertBefore TO ((RecNumToInsertBefore + 1) - 1) DO
          BEGIN
            Seek(EventFile,RecNum);
            Write(EventFile,TempEvent1);
            Inc(NumEvents);
            SysOpLog('* Inserted event: ^5'+TempEvent1.EventDescription);
          END;
        END;
        Close(EventFile);
        LastError := IOResult;
      END;
    END;
  END;

  PROCEDURE ModifyEvent(TempEvent1: EventRecordType; Cmd1: Char; RecNumToEdit: Integer);
  VAR
    SaveRecNumToEdit: Integer;
    Ok,
    Changed: Boolean;
  BEGIN
    IF (NumEvents = 0) THEN
      Messages(4,0,'events')
    ELSE
    BEGIN
      RecNumToEdit := -1;
      InputIntegerWOC('%LFModify which event?',RecNumToEdit,[NumbersOnly],1,NumEvents);
      IF (RecNumToEdit >= 1) AND (RecNumToEdit <= NumEvents) THEN
      BEGIN
        SaveRecNumToEdit := -1;
        Cmd1 := #0;
        Reset(EventFile);
        WHILE (Cmd1 <> 'Q') AND (NOT HangUp) DO
        BEGIN
          IF (SaveRecNumToEdit <> RecNumToEdit) THEN
          BEGIN
            Seek(EventFile,(RecNumToEdit - 1));
            Read(EventFile,Event);
            SaveRecNumToEdit := RecNumToEdit;
            Changed := FALSE;
          END;
          REPEAT
            Ok := TRUE;
            EditEvent(TempEvent1,Event,Cmd1,RecNumToEdit,Changed,TRUE);
            (*CheckEvent(Event,1,1,Ok); { Not implemented? } *)
            IF (NOT OK) THEN
            BEGIN
              PauseScr(FALSE);
              IF (RecNumToEdit <> SaveRecNumToEdit) THEN
                RecNumToEdit := SaveRecNumToEdit;
            END;
          UNTIL (Ok) OR (HangUp);
          IF (Changed) THEN
          BEGIN
            Seek(EventFile,(SaveRecNumToEdit - 1));
            Write(EventFile,Event);
            Changed := FALSE;
            SysOpLog('* Modified event: ^5'+Event.EventDescription);
          END;
        END;
        Close(EventFile);
        LastError := IOResult;
      END;
    END;
  END;

  PROCEDURE PositionEvent(TempEvent1: EventRecordType; RecNumToPosition: Integer);
  VAR
    RecNumToPositionBefore,
    RecNum1,
    RecNum2: Integer;
  BEGIN
    IF (NumEvents = 0) THEN
      Messages(4,0,'events')
    ELSE IF (NumEvents = 1) THEN
      Messages(6,0,'events')
    ELSE
    BEGIN
      InputIntegerWOC('%LFPosition which event?',RecNumToPosition,[NumbersOnly],1,NumEvents);
      IF (RecNumToPosition >= 1) AND (RecNumToPosition <= NumEvents) THEN
      BEGIN
        Print('%LFAccording to the current numbering system.');
        InputIntegerWOC('%LFPosition before which event?',RecNumToPositionBefore,[Numbersonly],1,(NumEvents + 1));
        IF (RecNumToPositionBefore >= 1) AND (RecNumToPositionBefore <= (NumEvents + 1)) AND
           (RecNumToPositionBefore <> RecNumToPosition) AND (RecNumToPositionBefore <> (RecNumToPosition + 1)) THEN
        BEGIN
          Print('%LF[> Positioning event.');
          Reset(EventFile);
          IF (RecNumToPositionBefore > RecNumToPosition) THEN
            Dec(RecNumToPositionBefore);
          Dec(RecNumToPosition);
          Dec(RecNumToPositionBefore);
          Seek(EventFile,RecNumToPosition);
          Read(EventFile,TempEvent1);
          RecNum1 := RecNumToPosition;
          IF (RecNumToPosition > RecNumToPositionBefore) THEN
            RecNum2 := -1
          ELSE
            RecNum2 := 1;
          WHILE (RecNum1 <> RecNumToPositionBefore) DO
          BEGIN
            IF ((RecNum1 + RecNum2) < FileSize(EventFile)) THEN
            BEGIN
              Seek(EventFile,(RecNum1 + RecNum2));
              Read(EventFile,Event);
              Seek(EventFile,RecNum1);
              Write(EventFile,Event);
            END;
            Inc(RecNum1,RecNum2);
          END;
          Seek(EventFile,RecNumToPositionBefore);
          Write(EventFile,TempEvent1);
          Close(EventFile);
          LastError := IOResult;
        END;
      END;
    END;
  END;

  PROCEDURE ListEvents(VAR RecNumToList1: Integer);
  VAR
    NumDone: Integer;
	Sched: String;
  BEGIN
    IF (RecNumToList1 < 1) OR (RecNumToList1 > NumFileAreas) THEN
      RecNumToList1 := 1;
    Abort := FALSE;
    Next := FALSE;
    CLS;
	ConfigHeader('Event Editor');
	PrintACR('^4+---+----+-------------------------------------------+----------+-------+-----+');
	PrintACR('^4| ^3A ^4| ^3## ^4| ^3Description                               ^4| ^3Schedule ^4| ^3Time  ^4| ^3Wrn ^4|');
	PrintACR('^4+---+----+-------------------------------------------+----------+-------+-----+');
	
    Reset(EventFile);
    NumDone := 0;
    WHILE (NumDone < (PageLength - 5)) AND (RecNumToList1 >= 1) AND (RecNumToList1 <= NumEvents)
          AND (NOT Abort) AND (NOT HangUp) DO
    BEGIN
      Seek(EventFile,(RecNumToList1 - 1));
      Read(EventFile,Event);
				
      WITH Event DO
	   BEGIN
	   
   		IF EventDayOfMonth <> 0 THEN 
		  Sched := IntToStr(EventDayOfMonth)+DateSuffix(EventDayOfMonth)
		ELSE
		  Sched := +DaysEventActive(EventDays,'3','1');
	   
        PrintACR('  ^0'+PadLeftStr(AOnOff(EventIsActive IN EFlags,'^9'+#251,'^4-'),2)+
                 '  ^0'+PadLeftInt(RecNumToList1,3)+
                 '  ^1'+PadLeftStr(EventDescription,42)+               
				 '  ^0'+PadLeftStr(Sched,9)+
				 '  ^0'+PadLeftStr(Copy(CTim(EventStartTime),4,5),6)+
                 '  ^0'+PadLeftInt(EventPreTime,3));
      Inc(RecNumToList1);
      Inc(NumDone);
	 END
    END;
    Close(EventFile);
    LastError := IOResult;
    IF (NumEvents = 0) THEN
      Print('*** No events defined ***');
  END;

BEGIN
  IF (MemEventArray[Numevents] <> NIL) THEN
    FOR RecNumToList := 1 TO NumEvents DO
      IF (MemEventArray[RecNumToList] <> NIL) THEN
        Dispose(MemEventArray[RecNumToList]);
  SaveTempPause := TempPause;
  TempPause := FALSE;
  RecNumToList := 1;
  Cmd := #0;
  REPEAT
    IF (Cmd <> '?') THEN
      ListEvents(RecNumToList);
	{NL;}
    lOneKX('^0Event Editor',Cmd,'QDIMP?'^M,TRUE,TRUE,TRUE,TRUE);
    CASE Cmd OF
      ^M  : IF (RecNumToList < 1) OR (RecNumToList > NumEvents) THEN
              RecNumToList := 1;
      'D' : DeleteEvent(TempEvent,RecNumToList);
      'I' : InsertEvent(TempEvent,Cmd,RecNumToList);
      'M' : ModifyEvent(TempEvent,Cmd,RecNumToList);
      'P' : PositionEvent(TempEvent,RecNumToList);
      '?' : BEGIN
              Print('^0%LF^0<^1CR^0> Next Page / Refresh');
              {Print('^1(^3?^1)Help/First event');} {LeeW: useless }
              LCmds(15,1,'D Delete Event','I Insert Event');
              LCmds(15,1,'M Modify Event','P Position Event');
              LCmds(15,1,'Q Quit','');
            END;
    END;
    IF (Cmd <> ^M) THEN
      RecNumToList := 1;
  UNTIL (Cmd = 'Q') OR (HangUp);
  TempPause := SaveTempPause;
  NumEvents := 0;
  Reset(EventFile);
  WHILE NOT EOF(EventFile) DO
  BEGIN
    Inc(NumEvents);
    New(MemEventArray[NumEvents]);
    Read(EventFile,MemEventArray[NumEvents]^);
  END;
  Close(EventFile);
  LastError := IOResult;
END;

END.
