{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

UNIT Maint;

INTERFACE

PROCEDURE LogonMaint;
PROCEDURE LogoffMaint;
PROCEDURE DailyMaint;
PROCEDURE UpdateGeneral;

IMPLEMENTATION

USES
  Automsg,
  Bulletin,
  Common,
  Common0, {NewYN}
  CUser,
  Email,
  Events,
  File6,
  File12,
  Mail1,
  Mail4,
  ShortMsg,
  TimeFunc,
  Vote,
  CRT,
  OneLiner;

PROCEDURE LogonMaint;
VAR
  LastCallerFile: FILE OF LastCallerRec;
  LastCaller: LastCallerRec;
  TempStr,
  TempStr1: AStr;
  Cmd: Char;
  Counter,
  Counter1: Integer;
  RecNum: LongInt;
  BSince: Boolean;

{  PROCEDURE UpdateUserInformation;
  VAR
    UpdateArray: ARRAY [0..10] OF Integer;
    Counter,
    Counter1: Integer;
  BEGIN
    FOR Counter := 0 TO 10 DO
      UpdateArray[Counter] := 0;
    Counter := 0;
    IF (ThisUser.RealName = User_String_Ask) THEN
    BEGIN
      UpdateArray[1] := 10;
      Inc(Counter);
    END;
    IF (ThisUser.Street = User_String_Ask) THEN
    BEGIN
      UpdateArray[2] := 1;
      Inc(Counter);
    END;
    IF (ThisUser.CityState = User_String_Ask) THEN
    BEGIN
      UpdateArray[0] := 23;
      UpdateArray[3] := 4;
      Inc(Counter);
    END;
    IF (ThisUser.ZipCode = User_String_Ask) THEN
    BEGIN
      UpdateArray[0] := 23;
      UpdateArray[4] := 14;
      Inc(Counter);
    END;
    IF (ThisUser.BirthDate = User_Date_Ask) THEN
    BEGIN
      UpdateArray[5] := 2;
      Inc(Counter);
    END;
    IF (ThisUser.Ph = User_Phone_Ask) THEN
    BEGIN
      UpdateArray[6] := 8;
      Inc(Counter);
    END;
    IF (ThisUser.UsrDefStr[1] = User_String_Ask) THEN
    BEGIN
      UpdateArray[7] := 5;
      Inc(Counter);
    END;
    IF (ThisUser.UsrDefStr[2] = User_String_Ask) THEN
    BEGIN
      UpdateArray[8] := 6;
      Inc(Counter);
    END;
    IF (ThisUser.UsrDefStr[3] = User_String_Ask) THEN
    BEGIN
      UpdateArray[9] := 13;
      Inc(Counter);
    END;
    IF (ThisUser.ForgotPWAnswer = User_String_Ask) THEN
    BEGIN
      UpdateArray[10] := 30;
      Inc(Counter);
    END;
    IF (Counter <> 0) THEN
    BEGIN
      CLS;
      NL;
      Print('Please update the following information:');
      Counter := 0;
      WHILE (Counter <= 10) AND (NOT HangUp) DO
      BEGIN
        IF (UpDateArray[Counter] <> 0) THEN
        BEGIN
          Update_Screen;
          CStuff(UpdateArray[Counter],1,ThisUser);
        END;
        Inc(Counter);
      END;
      NL;
      Print('Thank you!');
      NL;
      PauseScr(FALSE);
    END;
  END;
 }
  FUNCTION CheckBirthday: Boolean;
  VAR
    BDate: LongInt;
  BEGIN
    BSince := FALSE;
    BDate := Date2PD(Copy(PD2Date(ThisUser.BirthDate),1,6) + Copy(DateStr,7,4));
    IF (BDate > ThisUser.LastOn) AND (BDate <= Date2PD(DateStr)) THEN
    BEGIN
      CheckBirthday := TRUE;
      BSince := (BDate < Date2PD(DateStr));
    END
    ELSE
      CheckBirthday := FALSE;
  END;

  PROCEDURE ShowBDay(CONST UserNumber: AStr);
  BEGIN
    IF (BSince) THEN
      PrintF('BDYS'+UserNumber);
    IF (NoFile) THEN
      PrintF('BDAY'+UserNumber);
  END;

  PROCEDURE FindChopTime;
  VAR
    LNG,
    LNG2,
    LNG3: LongInt;
    EventNum: Byte;

    PROCEDURE OnlineTime;
    BEGIN
      PrintF('REVENT'+IntToStr(EventNum));
      IF (NoFile) THEN
      BEGIN
        Print(^G);
        NL;
        Print('^8Note: System event approaching.');
        Print('System will be shut down in '+FormattedTime(NSL));
        NL;
        Print(^G);
        PauseScr(FALSE);
      END;
    END;

  BEGIN
    IF (ExtEventTime <> 0) THEN
    BEGIN
      LNG := ExtEventTime;
      IF (LNG < (NSL DIV 60)) THEN
      BEGIN
        ChopTime := (NSL - (LNG * 60)) + 120;
        OnlineTime;
        Exit;
      END;
    END;

    LNG := 1;
    LNG2 := (NSL DIV 60);
    IF (LNG2 > 180) THEN
      LNG2 := 180;
    WHILE (LNG <= LNG2) DO
    BEGIN
      LNG3 := (LNG * 60);
      EventNum := CheckEvents(LNG3);
      IF (EventNum <> 0) THEN
      BEGIN
        ChopTime := (NSL - (LNG * 60)) + 60;
        OnlineTime;
        Exit;
      END;
      Inc(LNG,2);
    END;
  END;

BEGIN
  IF (General.MultiNode) THEN
  BEGIN
    LoadNode(ThisNode);
    (*IF AACS(General.Invisible) AND PYNQ(lRGLngStr(45,TRUE){FString.AskInvisibleLoginStr},0,FALSE) THEN
    BEGIN
      IsInvisible := TRUE;
      Include(NodeR.Status,NInvisible);
      SysOpLog('Selected invisible mode.');
    END
    ELSE*)
      IsInvisible := FALSE;
    FillChar(NodeR.Invited,SizeOf(NodeR.Invited),0);
    FillChar(NodeR.Booted,SizeOf(NodeR.Booted),0);
    FillChar(NodeR.Forget,SizeOf(NodeR.Forget),0);
    Include(NodeR.Status,NAvail);
    SaveNode(ThisNode);
    Update_Node(RGNoteStr(37,TRUE),TRUE);
    FOR Counter := 1 TO MaxNodes DO
    BEGIN
      LoadNode(Counter);
      NodeR.Forget[ThisNode DIV 8] := NodeR.Forget[ThisNode DIV 8] - [ThisNode MOD 8];
      SaveNode(Counter);
    END;
  END;

  ConfSystem := TRUE;

  IF (ThisUser.LastConf IN ConfKeys) THEN
    CurrentConf := ThisUser.LastConf
  ELSE
  BEGIN
    CurrentConf := '@';
    ThisUser.LastConf := CurrentConf;
  END;

  PublicReadThisCall := 0;
  ExtraTime := 0;
  FreeTime := 0;
  CreditTime := 0;
  TimeOn := GetPackDateTime;
  UserOn := TRUE;

  Com_Flush_Recv;

  lStatus_Screen(100,'Cleaning up work areas...',FALSE,TempStr);
  PurgeDir(TempDir+'ARC\',FALSE);
  PurgeDir(TempDir+'QWK\',FALSE);
  PurgeDir(TempDir+'UP\',FALSE);
  PurgeDir(TempDir+'CD\',FALSE);

  DailyMaint;

  IF (ComPortSpeed > 0) AND (NOT LocalIOOnly) THEN
    Inc(TodayCallers);

  IF (SLogSeparate IN ThisUser.SFlags) THEN
  BEGIN
    Assign(SysOpLogFile1,General.LogsPath+'SLOG'+IntToStr(UserNum)+'.LOG');
    Append(SysOpLogFile1);
    IF (IOResult = 2) THEN
    BEGIN
      ReWrite(SysOpLogFile1);
      Append(SysOpLogFile1);
      TempStr := '';
      TempStr1 := '';
      FOR Counter := 1 TO (25 + Length(ThisUser.Name)) DO
      BEGIN
        TempStr := TempStr + '-';
        TempStr1 := TempStr1 + ' ';
      END;
      WriteLn(SysOpLogFile1,'');
      WriteLn(SysOpLogFile1,'+'+TempStr+'+');
      WriteLn(SysOpLogFile1,'| Renegade SysOp Log for '+Caps(ThisUser.Name)+' |');
      WriteLn(SysOpLogFile1,'+'+TempStr+'+');
    END;
    WriteLn(SysOpLogFile1);

    TempStr := 'Logon ['+Dat+'] (';

    IF (ComPortSpeed > 0) THEN
    BEGIN
      TempStr := TempStr + IntToStr(ActualSpeed)+' baud';

      IF (Reliable) THEN
        TempStr := TempStr + '/Reliable)'
      ELSE
        TempStr := TempStr + ')';

      IF (CallerIDNumber > '') THEN
      BEGIN
        IF (NOT Telnet) THEN
          TempStr := TempStr + ' Number: '+CallerIDNumber
        ELSE
          TempStr := TempStr + ' IP Number: '+CallerIDNumber;
      END;
    END
    ELSE
      TempStr := TempStr + 'Keyboard)';

    IF (General.StripCLog) THEN
      TempStr := StripColor(TempStr);

    WriteLn(SysOpLogFile1,TempStr);

    Close(SysOpLogFile1);
  END;

  (*TempStr := ''+IntToStr(General.CallerNum)+' -- '+Caps(ThisUser.Name)+' -- '+'Today '+IntToStr(ThisUser.OnToday);*)
  TempStr := '^0Caller Num: ^1'+IntToStr(General.CallerNum)+' ^4| ^0User: ^1'+Caps(ThisUser.Name)+
	' ^0(Call # ^1'+IntToStr(ThisUser.OnToday)+'^0)';
  IF (Trapping) THEN
    TempStr := TempStr + ' ^8[TRAPPING]^0';
  SL1(TempStr);
  SaveGeneral(FALSE);
  LastError := IOResult;
  IF ((CoSysOp) AND (NOT FastLogon) AND (ComPortSpeed > 0)) THEN
  BEGIN
    IF NewYN(lRGLngStr(57,TRUE),FALSE) THEN { "Quick Logon?" }
      FastLogon := TRUE;
    NL;
  END;
  Assign(LastCallerFile,General.DataPath+'LASTON.DAT');
  IF Exist(General.DataPath+'LASTON.DAT') THEN
    Reset(LastCallerFile)
  ELSE
    ReWrite(LastCallerFile);
  FillChar(LastCaller,SizeOf(LastCaller),0);
  WITH LastCaller DO
  BEGIN
    Node := ThisNode;
    Caller := General.CallerNum;
    UserName := Caps(ThisUser.Name);
    UserID := UserNum;
    Location := ThisUser.CityState;
    IF (ComPortSpeed <> 0) THEN
      Speed := ActualSpeed
    ELSE
      Speed := 0;
    LogonTime := TimeOn;
    LogoffTime := 0;
    NewUser := WasNewUser;
    Invisible := IsInvisible;
  END;
  IF AACS(General.LastOnDatACS) THEN
  BEGIN
    Seek(LastCallerFile,FileSize(LastCallerFile));
    Write(LastCallerFile,LastCaller);
  END;
  Close(LastCallerFile);
  LastError := IOResult;

  SaveGeneral(TRUE);

  IF (NOT FastLogon) AND (NOT HangUp) THEN
  BEGIN

    PrintF('LOGON');
    Counter := 0;
    REPEAT
      Inc(Counter);
      PrintF('LOGON'+IntToStr(Counter));
    UNTIL (Counter = 9) OR (NoFile) OR (HangUp);

    PrintF('SL'+IntToStr(ThisUser.SL));

    PrintF('DSL'+IntToStr(ThisUser.DSL));

    FOR Cmd := 'A' TO 'Z' DO
      IF (Cmd IN ThisUser.AR) THEN
        PrintF('ARLEVEL'+Cmd);

    PrintF('USER'+IntToStr(UserNum));

    IF (FindOnlyOnce) THEN
      PrintF('ONCEONLY');

    {UpdateUserInformation;}
	
    IF (General.LogonQuote) THEN
      RGQuote('LGNQUOTE');

    IF (CheckBirthday) THEN
    BEGIN
      ShowBDay(IntToStr(UserNum));
      IF (NoFile) THEN
        ShowBDay(''); { LeeW: What's with this? }
      IF (NoFile) THEN
        IF (BSince) THEN
        BEGIN
          NL;
          Print('^0Happy Birthday ^1'+Caps(ThisUser.Name)+'^0!');
          Print('^0(a little late, but it''s the thought that counts!)');
          NL;
        END
        ELSE
        BEGIN
          NL;
          Print('^0Happy Birthday ^1'+Caps(ThisUser.Name)+'^0!');
          Print('^0You turned ^1'+IntToStr(AgeUser(ThisUser.BirthDate))+'^0 today!');
          NL;
        END;
      PauseScr(FALSE);
      CLS;
    END;
    
    IF (General.AutoMInLogon) THEN
	  BEGIN
	    NL;
        ReadAutoMsg;
	    NL;
	  END;
	  
    IF (General.YourInfoInLogon) THEN
    BEGIN
      PrintF('YOURINFO');
      NL;
    END;

    LIL := 0;

    IF (General.BullInLogon) AND (NewBulletins) THEN
    BEGIN
      NL;
      IF PYNQ(lRGLngStr(56,TRUE){FString.ShowBulletins},0,FALSE) THEN
        Bulletins('');
	  NL;    
    END;

	IF (General.LastCallersInLogon) THEN { LeeW: Added }
	  BEGIN
		TodaysCallers(0);
	  END;

	IF (General.OneLinersInLogon) THEN { LeeW: Added }
	  BEGIN
		DoOneLiners('Default'); {LeeW: fix this param}
		CLS;
	  END;
	
    IF (NOT (RVoting IN ThisUser.Flags)) AND (General.VoteInLogon) THEN
    BEGIN
      Counter := UnVotedTopics;
      IF (Counter > 0) THEN
      BEGIN
        NL;
        Prompt('^0You have not voted on ^1'+IntToStr(Counter)+'^0 voting '+Plural('question',Counter)+'...');
		NL;
		NL;
		IF NewYN('^0Would you like to vote now? ',FALSE) THEN { LeeW: Added }
		  BEGIN
		    VoteAll;
		  END;
        NL;
      END;
    END;

	{ LeeW: Some kind of delay/pause here -- investigate }
	{ it's the lil down further... }
	
    IF Exist(General.DataPath+'BATCHDL.DAT') THEN
    BEGIN
      Assign(BatchDLFile,General.DataPath+'BATCHDL.DAT');
      Reset(BatchDLFile);
      RecNum := 1;
      WHILE (RecNum <= FileSize(BatchDLFile)) DO
      BEGIN
        Seek(BatchDLFile,(RecNum - 1));
        Read(BatchDLFile,BatchDL);
        IF (BatchDL.BDLUserNum = UserNum) THEN
        BEGIN
          Inc(NumBatchDLFiles);
          Inc(BatchDLTime,BatchDL.BDLTime);
          Inc(BatchDLSize,BatchDL.BDLFSize);
          Inc(BatchDLPoints,BatchDL.BDLPoints);
        END;
        Inc(RecNum);
      END;
      Close(BatchDLFile);
      LastError := IOResult;
    END;

    IF Exist(General.DataPath+'BATCHUL.DAT') THEN
    BEGIN
      Assign(BatchULFile,General.DataPath+'BATCHUL.DAT');
      Reset(BatchULFile);
      RecNum := 1;
      WHILE (RecNum <= FileSize(BatchULFile)) DO
      BEGIN
        Seek(BatchULFile,(RecNum - 1));
        Read(BatchULFile,BatchUL);
        IF (BatchUL.BULUserNum = UserNum) THEN
          Inc(NumBatchULFiles);
        Inc(RecNum);
      END;
      Close(BatchULFile);
      LastError := IOResult;
    END;

    IF (NumBatchDLFiles > 0) AND (General.ForceBatchDL) THEN
      REPEAT
        NL;
        Print('^0You must (^1D^0)ownload, (^1R^0)emove, or (^1C^0)lear your batch queued files.');
        NL;
        Prt('^0Select Option: ');
        OneK(Cmd,'DRC',TRUE,TRUE);
        CASE Cmd OF
          'D' : BatchDownload;
          'R' : RemoveBatchDLFiles;
          'C' : ClearBatchDLQueue;
        END;
      UNTIL (NumBatchDLFiles = 0) OR (FileSysOp) OR (HangUp);

    IF (NumBatchULFiles > 0) AND (General.ForceBatchUL) THEN
      REPEAT
        NL;
        Print('^0You must (^1U^0)pload, (^1R^0)emove, or (^1C^0)lear your batch queued files.');
        NL;
        Prt('^0Select Option: ');
        OneK(Cmd,'URC',TRUE,TRUE);
        CASE Cmd OF
          'U' : BatchUpload(FALSE,0);
          'R' : RemoveBatchULFiles;
          'C' : ClearBatchULQueue;
        END;
      UNTIL (NumBatchULFiles = 0) OR (FileSysOp) OR (HangUp);

    BatchDLULInfo;

(*    IF (LIL <> 0) THEN
PauseScr(FALSE); *) { LeeW: testing... }

    Update_Screen;
  END;

  FindChopTime;

  IF (SMW IN ThisUser.Flags) THEN
  BEGIN
    ReadShortMessage;
    NL;
    PauseScr(FALSE);
  END;

  IF ((Alert IN ThisUser.SFlags) AND (SysOpAvailable)) THEN
    ChatCall := TRUE;

  IF (ThisUser.Waiting > 0) THEN
    IF (RMsg IN ThisUser.Flags) THEN
      ReadMail
    ELSE
    BEGIN
      IF NewYN('^0Read Your Private Messages? ',TRUE) THEN
        ReadMail;
    END;

  IF (General.PasswordChange > 0) THEN
    IF ((DayNum(DateStr) - ThisUser.PasswordChanged) >= General.PasswordChange) THEN
    BEGIN
      PrintF('PWCHANGE');
      IF (NoFile) THEN
      BEGIN
        NL;
        Print('^0You must select a new password every ^1'+IntToStr(General.PasswordChange)+'^0 days.'); { LeeW: plural }
        NL;
      END;
      CStuff(22,3,ThisUser);
    END;

  FastLogon := FALSE;
  {PauseScr(False);}
END;

PROCEDURE LogoffMaint;
VAR
  HistoryFile: FILE OF HistoryRecordType;
  LastCallerFile: FILE OF LastCallerRec;
  History: HistoryRecordType;
  LastCaller: LastCallerRec;
  Counter: Integer;
  TotTimeOn: LongInt;
BEGIN
  Com_Flush_Send;

  LoadNode(ThisNode);
  WITH NodeR DO
  BEGIN
    User := 0;
    UserName := '';
    CityState := '';
    Sex := 'M';
    Age := 0;
    LogonTime := 0;
    GroupChat := FALSE;
    ActivityDesc := '';
    Status := [NActive];
    Room := 0;
    Channel := 0;
    FillChar(Invited,SizeOf(Invited),0);
    FillChar(Booted,SizeOf(Booted),0);
    FillChar(Forget,SizeOf(Forget),0);
  END;
  SaveNode(ThisNode);

  IF (UserNum > 0) THEN
  BEGIN
    PurgeDir(TempDir+'ARC\',FALSE);
    PurgeDir(TempDir+'QWK\',FALSE);
    PurgeDir(TempDir+'UP\',FALSE);
    PurgeDir(TempDir+'CD\',FALSE);

    SLogging := TRUE;

    IF (Trapping) THEN
    BEGIN
      IF (HungUp) THEN
      BEGIN
        WriteLn(TrapFile);
        WriteLn(TrapFile,'NO CARRIER');
      END;
      Close(TrapFile);
      Trapping := FALSE;
    END;

    TotTimeOn := ((GetPackDateTime - TimeOn) DIV 60);

    ThisUser.LastOn := GetPackDateTime;
    Inc(ThisUser.LoggedOn);

    ThisUser.Illegal := 0;
    ThisUser.TTimeOn := (ThisUser.TTimeOn + TotTimeOn);
    ThisUser.TLToday := (NSL DIV 60);

    IF (ChopTime <> 0) THEN
      Inc(ThisUser.TLToday,(ChopTime DIV 60));

    ThisUser.LastMsgArea := MsgArea;
    ThisUser.LastFileArea := FileArea;

    IF ((UserNum >= 1) AND (UserNum <= (MaxUsers - 1))) THEN
      SaveURec(ThisUser,UserNum);

    IF (HungUp) THEN
      SL1('^0 Hung Up ');

	  (* stats after logoff *)
	SL1('Downloads: '+IntToStr(DownloadsToday)+' ('+IntToStr(DownloadKBytesToday)+' KB)');
	SL1('Uploads: '+IntToStr(UploadsToday)+' ('+IntToStr(UploadKBytesToday)+' KB)');
	SL1('Pub Posts:'+IntToStr(PublicPostsToday)+' / Read: '+IntToStr(PublicReadThisCall));
	SL1('Time On: '+IntToStr(TotTimeOn));	

  END;
  LastError := IOResult;

  SL1('^0Logoff node ^1'+IntToStr(ThisNode)+' '+'['+Dat+']');

  Assign(HistoryFile,General.DataPath+'HISTORY.DAT');
  Reset(HistoryFile);
  IF (IOResult = 2) THEN
  BEGIN
    ReWrite(HistoryFile);
    FillChar(History,SizeOf(History),0);
    History.Date := Date2PD(DateStr);
  END
  ELSE
  BEGIN
    Seek(HistoryFile,(FileSize(HistoryFile) - 1));
    Read(HistoryFile,History);
  END;
  Inc(History.Active,(GetPackDateTime - TimeOn) DIV 60);
  IF (NOT LocalIOOnly) THEN
    Inc(History.Callers);
  IF (WasNewUser) THEN
    Inc(History.NewUsers);

  IF ((History.Posts + PublicPostsToday) < 2147483647) THEN
    Inc(History.Posts,PublicPostsToday)
  ELSE
    History.Posts := 2147483647;

  IF ((History.Email + PrivatePostsToday) < 2147483647) THEN
    Inc(History.Email,PrivatePostsToday)
  ELSE
    History.Email := 2147483647;

  IF ((History.FeedBack + FeedbackPostsToday) < 2147483647) THEN
    Inc(History.FeedBack,FeedbackPostsToday)
  ELSE
    History.FeedBack := 2147483647;

  IF ((History.Uploads + UploadsToday) < 2147483647) THEN
    Inc(History.Uploads,UploadsToday)
  ELSE
    History.Uploads := 2147483647;

  IF ((History.Downloads + DownloadsToday) < 2147483647) THEN
    Inc(History.Downloads,DownloadsToday)
  ELSE
    History.Downloads := 2147483647;

  IF ((History.UK + UploadKBytesToday) < 2147483647) THEN
    Inc(History.UK,UploadKBytesToday)
  ELSE
    History.UK := 2147483647;

  IF ((History.DK + DownloadKBytesToday) < 2147483647) THEN
    Inc(History.DK,DownloadKBytesToday)
  ELSE
    History.DK := 2147483647;

  IF (Exist(StartDir+'\CRITICAL.ERR')) THEN
  BEGIN
    Inc(History.Errors);
    Kill(StartDir+'\CRITICAL.ERR');
  END;

  IF (ComPortSpeed <> 0) THEN
  BEGIN
    IF (ComportSpeed = 300) THEN
      Inc(History.UserBaud[1])
    ELSE IF (ComportSpeed = 600) THEN
      Inc(History.UserBaud[2])
    ELSE IF (ComportSpeed = 1200) THEN
      Inc(History.UserBaud[3])
    ELSE IF (ComportSpeed = 2400) THEN
      Inc(History.UserBaud[4])
    ELSE IF (ComportSpeed = 4800) THEN
      Inc(History.UserBaud[5])
    ELSE IF (ComportSpeed = 7200) THEN
      Inc(History.UserBaud[6])
    ELSE IF (ComportSpeed = 9600) THEN
      Inc(History.UserBaud[7])
    ELSE IF (ComportSpeed = 12000) THEN
      Inc(History.UserBaud[8])
    ELSE IF (ComportSpeed = 14400) THEN
      Inc(History.UserBaud[9])
    ELSE IF (ComportSpeed = 16800) THEN
      Inc(History.UserBaud[10])
    ELSE IF (ComportSpeed = 19200) THEN
      Inc(History.UserBaud[11])
    ELSE IF (ComportSpeed = 21600) THEN
      Inc(History.UserBaud[12])
    ELSE IF (ComportSpeed = 24000) THEN
      Inc(History.UserBaud[13])
    ELSE IF (ComportSpeed = 26400) THEN
      Inc(History.UserBaud[14])
    ELSE IF (ComportSpeed = 28800) THEN
      Inc(History.UserBaud[15])
    ELSE IF (ComportSpeed = 31200) THEN
      Inc(History.UserBaud[16])
    ELSE IF (ComportSpeed = 33600) THEN
      Inc(History.UserBaud[17])
    ELSE IF (ComportSpeed = 38400) THEN
      Inc(History.UserBaud[18])
    ELSE IF (ComportSpeed = 57600) THEN
      Inc(History.UserBaud[19])
    ELSE IF (ComportSpeed = 115200) THEN
      Inc(History.UserBaud[20])
    ELSE
      Inc(History.UserBaud[0]);
  END;
  Seek(HistoryFile,(FileSize(HistoryFile) - 1));
  Write(Historyfile,History);
  Close(HistoryFile);
  LastError := IOResult;

  Assign(LastCallerFile,General.DataPath+'LASTON.DAT');
  Reset(LastCallerFile);
  IF (IOResult  = 2) THEN
    ReWrite(LastCallerFile);
  FOR Counter := (FileSize(LastCallerFile) - 1) DOWNTO 0 DO
  BEGIN
    Seek(LastCallerFile,Counter);
    Read(LastCallerFile,LastCaller);
    IF (LastCaller.Node = ThisNode) AND (LastCaller.UserID = UserNum) THEN
      WITH LastCaller DO
      BEGIN
        LogOffTime := GetPackDateTime;
        Uploads := UploadsToday;
        Downloads := DownloadsToday;
        UK := UploadKBytesToday;
        DK := DownloadKBytesToday;
        MsgRead := PublicReadThisCall;
        MsgPost := PublicPostsToday;
        EmailSent := PrivatePostsToday;
        FeedbackSent := FeedbackPostsToday;
        Seek(LastCallerFile,Counter);
        Write(LastCallerFile,LastCaller);
        Break;
      END;
  END;
  Close(LastCallerFile);
  LastError := IOResult;
END;

PROCEDURE DailyMaint;
VAR
  LastCallerFile: FILE OF LastCallerRec;
  HistoryFile: FILE OF HistoryRecordType;
  ShortMsgFile: FILE OF ShortMessageRecordType;
  F: Text;
  History: HistoryRecordType;
  ShortMsg: ShortMessageRecordType;
  TempStr: AStr;
  Counter,
  Counter1: Integer;
BEGIN

  IF (Date2PD(General.LastDate) <> Date2PD(DateStr)) THEN
  BEGIN

    General.LastDate := DateStr;

    SaveGeneral(FALSE);

    (* Test code only *)
    IF (NOT InWFCMenu) THEN
      SysOpLog('Daily maintenance ran from Caller Logon.')
    ELSE
      SysOpLog('Daily maintenance ran from Waiting For Caller.');
    (* End test code *)

    IF (NOT InWFCMenu) THEN
      lStatus_Screen(100,'Updating data files ...',FALSE,TempStr);

    (* Test *)
    IF Exist(General.DataPath+'LASTON.DAT') THEN
      Kill(General.DataPath+'LASTON.DAT');

    Assign(LastCallerFile,General.DataPath+'LASTON.DAT');
    ReWrite(LastCallerFile);
    Close(LastCallerFile);

    Assign(ShortMsgFile,General.DataPath+'SHORTMSG.DAT');
    Reset(ShortMsgFile);
    IF (IOResult = 0) THEN
    BEGIN
      IF (FileSize(ShortMsgFile) >= 1) THEN
      BEGIN
        Counter := 0;
        Counter1 := 0;
        WHILE (Counter <= (FileSize(ShortMsgFile) - 1)) DO
        BEGIN
          Seek(ShortMsgFile,Counter);
          Read(ShortMsgFile,ShortMsg);
          IF (ShortMsg.Destin <> -1) THEN
            IF (Counter = Counter1) THEN
              Inc(Counter1)
            ELSE
            BEGIN
              Seek(ShortMsgFile,Counter1);
              Write(ShortMsgFile,ShortMsg);
              Inc(Counter1);
            END;
          Inc(Counter);
        END;
        Seek(ShortMsgFile,Counter1);
        Truncate(ShortMsgFile);
      END;
      Close(ShortMsgFile);
    END;
    LastError := IOResult;

    Assign(HistoryFile,General.DataPath+'HISTORY.DAT');
    IF NOT Exist(General.DataPath+'HISTORY.DAT') THEN
      ReWrite(HistoryFile)
    ELSE
    BEGIN
      Reset(HistoryFile);
      Seek(HistoryFile,(FileSize(HistoryFile) - 1));
      Read(HistoryFile,History);
      Inc(General.DaysOnline);
      Inc(General.TotalCalls,History.Callers);
      Inc(General.TotalUsage,History.Active);
      Inc(General.TotalPosts,History.Posts);
      Inc(General.TotalDloads,History.Downloads);
      Inc(General.TotalUloads,History.Uploads);
    END;

    IF (History.Date <> Date2PD(DateStr)) THEN
    BEGIN
      IF Exist(General.LogsPath+'SYSOP'+IntToStr(General.BackSysOpLogs)+'.LOG') THEN
        Kill(General.LogsPath+'SYSOP'+IntToStr(General.BackSysOpLogs)+'.LOG');

      FOR Counter := (General.BackSysOpLogs - 1) DOWNTO 1 DO
        IF (Exist(General.LogsPath+'SYSOP'+IntToStr(Counter)+'.LOG')) THEN
        BEGIN
          Assign(F,General.LogsPath+'SYSOP'+IntToStr(Counter)+'.LOG');
          Rename(F,General.LogsPath+'SYSOP'+IntToStr(Counter + 1)+'.LOG');
        END;
	  SL1('');
	  SL1('+---------------+');
      SL1('| DAILY SUMMARY |');
	  SL1('+---------------+');
	  SL1('');
      SL1('Active Time      : '+IntToStr(History.Active)+' Minutes');
      SL1('Active Percent   : '+SQOutSp(CTP(History.Active,1440))+'% ('+IntToStr(History.Callers)+' Calls)');
      SL1('New Users        : '+IntToStr(History.NewUsers));
      SL1('Public Posts     : '+IntToStr(History.Posts));
      SL1('Private Messages : '+IntToStr(History.Email));
      SL1('Feedback Sent    : '+IntToStr(History.FeedBack));
      SL1('Critical Errors  : '+IntToStr(History.Errors));
      SL1('Downloads        : '+IntToStr(History.Downloads)+' ('+ConvertKB(History.DK,FALSE)+')');
      SL1('Uploads          : '+IntToStr(History.Uploads)+' ('+ConvertKB(History.UK,FALSE)+')');
	  SL1('');

      FillChar(History,SizeOf(History),0);
      History.Date := Date2PD(DateStr);

      Seek(HistoryFile,FileSize(HistoryFile));
      Write(HistoryFile,History);
      Close(HistoryFile);

      IF (General.MultiNode) AND Exist(TempDir+'TEMPLOG.'+IntToStr(ThisNode)) THEN
      BEGIN
        Assign(F,General.LogsPath+'SYSOP.LOG');
        Append(F);
        IF (IOResult = 2) THEN
          ReWrite(F);
        Reset(SysOpLogFile);
        WHILE NOT EOF(SysOpLogFile) DO
        BEGIN
          ReadLn(SysOpLogFile,TempStr);
          WriteLn(F,TempStr);
        END;
        Close(SysOpLogFile);
        Close(F);
        Erase(SysOpLogFile);
      END;

      Assign(SysOpLogFile,General.LogsPath+'SYSOP.LOG');
      Rename(SysOpLogFile,General.LogsPath+'SYSOP1.LOG');

      Assign(SysOpLogFile,General.LogsPath+'SYSOP.LOG');
      ReWrite(SysOpLogFile);
      Close(SysOpLogFile);

      SL1(^M^J'              Renegade SysOp Log for '+DateStr+^M^J);

      IF (General.MultiNode) THEN
        Assign(SysOpLogFile,TempDir+'TEMPLOG.'+IntToStr(ThisNode))
      ELSE
        Assign(SysOpLogFile,General.LogsPath+'SYSOP.LOG');
      Append(SysOpLogFile);
      IF (IOResult = 2) THEN
        ReWrite(SysOpLogFile);
      Close(SysOpLogFile);
    END
    ELSE
      Close(HistoryFile);
  END;
END;

PROCEDURE UpdateGeneral;
VAR
  HistoryFile: FILE OF HistoryRecordType;
  History: HistoryRecordType;
  Counter: LongInt;
BEGIN
  Assign(HistoryFile,General.DataPath+'HISTORY.DAT');
  Reset(HistoryFile);
  IF (IOResult = 2) THEN
    ReWrite(HistoryFile);
  WITH General DO
  BEGIN
    DaysOnline := FileSize(HistoryFile);
    TotalCalls := 0;
    TotalUsage := 0;
    TotalPosts := 0;
    TotalDloads := 0;
    TotalUloads := 0;
    FOR Counter := 1 TO (FileSize(HistoryFile) - 1) DO
    BEGIN
      Read(HistoryFile,History);
      Inc(TotalCalls,History.Callers);
      Inc(TotalUsage,History.Active);
      Inc(TotalPosts,History.Posts);
      Inc(TotalDloads,History.Downloads);
      Inc(TotalUloads,History.Uploads);
    END;
    IF (TotalUsage < 1) THEN
      TotalUsage := 1;
    IF (DaysOnline < 1) THEN
      DaysOnline := 1;
  END;
  Close(HistoryFile);
  LastError := IOResult;
  SaveGeneral(FALSE);
  IF (NOT InWFCMenu) THEN
  BEGIN
    NL;
    Print('System averages have been updated.');
    PauseScr(FALSE);
  END;
  { LeeW: Should display something... no? }
  PauseScr(FALSE);
END;

END.
