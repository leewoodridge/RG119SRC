{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  TOP USERS STATS
  
  [ISSUES]
	- needs better styling, customizable styling-- custo header mid and tail
	- top 20 files: needs more info than just filename? users wont be able to tell
	what they are
}

UNIT STATS;

INTERFACE

USES
  Common;

TYPE
  Top10UserRecordArray = RECORD
    UNum: Integer;
    Info: Real;
  END;

  Top20FileRecordArray = RECORD
    DirNum,
    DirRecNum: Integer;
    Downloaded: LongInt;
  END;

  Top10UserArray = ARRAY [1..10] OF Top10UserRecordArray;
  Top20FileArray = ARRAY [1..20] OF Top20FileRecordArray;

VAR
  Top10User: Top10UserArray;
  Top20File: Top20FileArray;

PROCEDURE GetUserStats(MenuOption: Str50);
FUNCTION Center(S: AStr; Len: Byte; TF: Boolean): AStr; { LeeW: move this to common? }

IMPLEMENTATION

USES
  File0,
  File1,
  File11;

FUNCTION MaxR(R,R1: Real): Real;
BEGIN
  IF (R1 = 0.0) THEN
    MaxR := R
  ELSE
    MaxR := R1;
END;

FUNCTION Center(S: AStr; Len: Byte; TF: Boolean): AStr;
VAR
  Counter,
  StrLength: Byte;
  Which_Way: Boolean;
BEGIN
  Which_Way := TF;
  StrLength := Length(S);
  FOR Counter := (StrLength + 1) TO Len DO
  BEGIN
    IF (Which_Way) THEN
    BEGIN
      S := ' ' + S;
      Which_Way := FALSE;
    END
    ELSE
    BEGIN
      S := S + ' ';
      Which_Way := TRUE;
    END;
  END;
  Center := S;
END;

PROCEDURE InitTop10UserArray(VAR Top10User: Top10UserArray);
VAR
  Counter: Byte;
BEGIN
  FOR Counter := 1 TO 10 DO
  BEGIN
    Top10User[Counter].UNum := -1;
    Top10User[Counter].Info := 0.0;
  END;
END;

PROCEDURE InitTop20FileArray(VAR Top20User: Top20FileArray);
VAR
  Counter: Byte;
BEGIN
  FOR Counter := 1 TO 20 DO
  BEGIN
    Top20File[Counter].DirNum := -1;
    Top20File[Counter].DirRecNum := -1;
    Top20File[Counter].Downloaded := 0;
  END;
END;

PROCEDURE SortUserDecending(VAR Top10User: Top10UserArray; UNum: Integer; Info: Real);
VAR
  Counter,
  Counter1: Byte;
BEGIN
  IF (Info > 0.0) THEN
    FOR Counter := 1 TO 10 DO
      IF (Info >= Top10User[Counter].Info) THEN
      BEGIN
        FOR Counter1 := 10 DOWNTO (Counter + 1) DO
          Top10User[Counter1] := Top10User[Counter1 - 1];
        Top10User[Counter].UNum := UNum;
        Top10User[Counter].Info := Info;
        Counter := 10;
      END;
END;

PROCEDURE SortFileDecending(VAR Top20File: Top20FileArray; DirNum,DirRecNum: Integer; Downloaded: LongInt);
VAR
  Counter,
  Counter1: Byte;
BEGIN
  IF (Downloaded > 0) THEN
    FOR Counter := 1 to 20 DO
      IF (Downloaded >= Top20File[Counter].Downloaded) THEN
      BEGIN
        FOR Counter1 := 20 DOWNTO (Counter + 1) DO
          Top20File[Counter1] := Top20File[Counter1 - 1];
        Top20File[Counter].DirNum := DirNum;
        Top20File[Counter].DirRecNum := DirRecNum;
        Top20File[Counter].Downloaded := Downloaded;
        Counter := 20;
      END;
END;

PROCEDURE SearchTop10User(VAR Top10User: Top10UserArray; Cmd: Char; ExcludeUserNum: Integer);
VAR
  User: UserRecordType;
  UNum: Integer;
  Info: Real;
BEGIN
  InitTop10UserArray(Top10User);
  Abort := FALSE;
  Next := FALSE;
  Reset(UserFile);
  UNum := 1;
  WHILE (UNum <= (FileSize(UserFile) - 1)) AND (NOT Abort) AND (NOT HangUp) DO
  BEGIN
    IF (ExcludeUserNum = 0) OR (UNum <> ExcludeUserNum) THEN
    BEGIN
      Seek(UserFile,UNum);
      Read(UserFile,User);
      IF (NOT (Deleted IN User.SFlags)) AND (NOT (LockedOut IN User.SFlags)) THEN
      BEGIN
        CASE Cmd OF
          'A' : Info := User.TTimeOn;
          'B' : Info := User.UK;
          'C' : Info := User.DK;
          'D' : Info := User.EmailSent;
          'E' : Info := User.MsgPost;
          'F' : Info := User.FeedBack;
          'G' : Info := User.LoggedOn;
          'H' : Info := User.Uploads;
          'I' : Info := User.Downloads;
          'J' : Info := User.FilePoints;
          'K' : Info := (User.UK / MaxR(1.0,User.DK));
          'L' : Info := (User.MsgPost / MaxR(1.0,User.LoggedOn));
        END;
        SortUserDecending(Top10User,UNum,Info);
      END;
    END;
    Inc(UNum);
  END;
  Close(UserFile);
END;

PROCEDURE SearchTop20AreaFileSpec(FArea: Integer; VAR Top20File: Top20FileArray);
VAR
  F: FileInfoRecordType;
  DirFileRecNum: Integer;
BEGIN
  IF (FileArea <> FArea) THEN
    ChangeFileArea(FArea);
  IF (FileArea = FArea) THEN
  BEGIN
    RecNo(F,'*.*',DirFileRecNum);
    IF (BadDownloadPath) THEN
      Exit;
    WHILE (DirFileRecNum <> -1) AND (NOT Abort) AND (NOT HangUp) DO
    BEGIN
      Seek(FileInfoFile,DirFileRecNum);
      Read(FileInfoFile,F);
      IF (CanSee(F)) THEN
        SortFileDecending(Top20File,FileArea,DirFileRecNum,F.Downloaded);
      NRecNo(F,DirFileRecNum);
    END;
    Close(FileInfoFile);
    Close(ExtInfoFile);
  END;
END;

PROCEDURE SearchTop20GlobalFileSpec(VAR Top20File: Top20FileArray);
VAR
  FArea,
  SaveFileArea: Integer;
  SaveConfSystem: Boolean;
BEGIN
  InitTop20FileArray(Top20File);
  SaveFileArea := FileArea;
  SaveConfSystem := ConfSystem;
  ConfSystem := FALSE;
  IF (SaveConfSystem) THEN
    NewCompTables;
  Abort := FALSE;
  Next := FALSE;
  FArea := 1;
  WHILE (FArea >= 1) AND (FArea <= NumFileAreas) AND (NOT Next) AND (NOT Abort) AND (NOT HangUp) DO
  BEGIN
    SearchTop20AreaFileSpec(FArea,Top20File);
    WKey;
    IF (Next) THEN
    BEGIN
      Abort := FALSE;
      Next := FALSE;
    END;
    Inc(FArea);
  END;
  ConfSystem := SaveConfSystem;
  IF (SaveConfSystem) THEN
    NewCompTables;
  FileArea := SaveFileArea;
  LoadFileArea(FileArea);
END;

PROCEDURE DisplayTop10UserArray(Top10User: Top10UserArray; Title,Header: AStr; Decimal,Width: Byte);
VAR
  User: UserRecordType;
  TempStr: AStr;
  Counter,
  Counter1: Byte;
BEGIN
  Abort := FALSE;
  Next := FALSE;
  CLS;
  PrintACR('^1'+Center('Top 10 '+Title,78,TRUE));
  NL;
  PrintACR('^4+----+------------------------------------+-----------------------------------+');
  PrintACR('^4| ^3## ^4| ^3User Name                          ^4| ^3'+PadLeftStr(Header,33)+' ^4|');
  PrintACR('^4+----+------------------------------------+-----------------------------------+');
  NL;
  Counter := 1;
  WHILE (Counter <= 10) AND (NOT Abort) AND (NOT HangUp) DO
  BEGIN
    User.Name := '';
    IF (Top10User[Counter].UNum >= 1) THEN
      LoadURec(User,Top10User[Counter].UNum);
    TempStr :=  '  ^0'+PadLeftInt(Counter,3)+
                '  ^0'+AOnOff(User.Name = ThisUser.Name,'^9','^1')+
					   PadLeftStr(User.Name,34)+' ^0';
  { FOR Counter1 := (Length(User.Name) + 1) TO 34 DO
      TempStr := TempStr + '-'; } { LeeW: That was ugly }
    TempStr := TempStr + '  '+AOnOff((Top10User[Counter].Info > 0.0),'^0'
							 +PadLeftStr(RealToStr(Top10User[Counter].Info,0,Decimal),Width),'');
    PrintACR(TempStr);
    WKey;
    Inc(Counter);
  END;
  NL;
  PauseScr(FALSE);
END;

PROCEDURE DisplayTop20FileArray(Top20File: Top20FileArray);
VAR
  F: FileInfoRecordType;
  TempStr: AStr;
  Counter,
  SaveFileArea: Integer;
  AddBatch: Boolean;
BEGIN
  SaveFileArea := FileArea;
  Abort := FALSE;
  Next := FALSE;
  CLS;
  PrintACR('^1'+Center('Top 20 Files Downloaded',79,TRUE));
  NL;
  PrintACR('^4+----+--------------+------------------+----+---------------------------------+');
  PrintACR('^4| ^3## ^4| ^3FILENAME.EXT ^4| ^3Downloads        ^4| ^3## ^4| ^3FILENAME.EXT ^4| ^3Downloads        ^4|');
  PrintACR('^4+----+--------------+------------------+----+---------------------------------+');
  NL;
  FOR Counter := 1 to 10 DO
  BEGIN
    F.FileName := '';
    IF (Counter <= 10) THEN
    BEGIN
      IF (Top20File[Counter].DirNum > 0) THEN
      BEGIN
        InitFileArea(Top20File[Counter].DirNum);
        IF (BadDownloadPath) THEN
          Exit;
        Seek(FileInfoFile,Top20File[Counter].DirRecNum);
        Read(FileInfoFile,F);
        Close(FileInfoFile);
        Close(ExtInfoFile);
      END;
      TempStr := '  ^0'+PadLeftInt(Counter,3);
      TempStr := TempStr + '  ^1'+PadLeftStr(F.FileName,13);
      {IF (Top20File[Counter].Downloaded > 0) THEN}
        TempStr := TempStr + '  ^0'+PadLeftInt(Top20File[Counter].Downloaded,17)
      (*ELSE
        TempStr := TempStr + '{            }';*)
    END;
    (*TempStr := TempStr + '{               }';*)
    F.FileName := '';
    IF ((Counter + 10) > 10) THEN
    BEGIN
      IF (Top20File[Counter + 10].DirNum > 0) THEN
      BEGIN
        InitFileArea(Top20File[Counter + 10].DirNum);
        IF (BadDownloadPath) THEN
          Exit;
        Seek(FileInfoFile,Top20File[Counter + 10].DirRecNum);
        Read(FileInfoFile,F);
        Close(FileInfoFile);
        Close(ExtInfoFile);
      END;
      TempStr := TempStr + '  ^0'+PadLeftInt(Counter + 10,3);
      TempStr := TempStr + '  ^0'+PadLeftStr(F.FileName,13);
      {IF (Top20File[Counter + 10].Downloaded > 0) THEN}
        TempStr := TempStr + '  ^0'+PadLeftInt(Top20File[Counter + 10].Downloaded,17)
    END;
    PrintACR(TempStr);
  END;
  NL;
  PauseScr(FALSE);
  (*
  IF (PYNQ('Would you like to download one of these files? ',0,FALSE)) THEN
  BEGIN
    Counter := -1;
    NL;
    InputIntegerWOC('Download which file',Counter,1,20);
    IF (Counter <> -1) THEN
      IF (Top20File[Counter].DirNum <> -1) AND (Top20File[Counter].DirRecNum <> -1) THEN
      BEGIN
        InitFileArea(Top20File[Counter].DirNum);
        IF (BadDownloadPath) THEN
          Exit;
        Seek(FileInfoFile,Top20File[Counter].DirRecNum);
        Read(FileInfoFile,F);
        NL;
        DLX(F,Top20File[Counter].DirRecNum,FALSE,Abort);
        Close(FileInfoFile);
        Close(ExtInfoFile);
      END;
  END;
  *)
  FileArea := SaveFileArea;
  LoadFileArea(FileArea);
END;

PROCEDURE GetUserStats(MenuOption: Str50);
VAR
  Title,
  Header: AStr;
  Decimal,
  Width: Byte;
  ExcludeUserNum: Integer;
BEGIN
  MenuOption := ALLCaps(MenuOption);
  IF (MenuOption = '') OR (NOT (MenuOption[1] IN ['A'..'M'])) THEN
  BEGIN
    NL;
    Print('Invalid menu option for user statistics, please inform the SysOp.');
    PauseScr(FALSE);
    SysOpLog('Invalid menu option for user statistics, valid options are A-M.');
  END
  ELSE IF (MenuOption[1] IN ['A'..'L']) THEN
  BEGIN
    ExcludeUserNum := 0;
    IF (Pos(';',MenuOption) <> 0) THEN
      ExcludeUserNum := StrToInt(Copy(MenuOption,(Pos(';',MenuOption) + 1),50));
    SearchTop10User(Top10User,MenuOption[1],ExcludeUserNum);
    CASE UpCase(MenuOption[1]) OF
      'A' : BEGIN
              Title := 'High Time Users';
              Header := 'Minutes Online';
              Decimal := 0;
              Width := 10;
            END;
      'B' : BEGIN
              Title := 'File Kbyte Uploaders';
              Header := 'Kbytes Uploaded';
              Decimal := 0;
              Width := 10;
            END;
      'C' : BEGIN
              Title := 'File Kbyte Downloaders';
              Header := 'Kbytes Downloaded';
              Decimal := 0;
              Width := 10;
            END;
      'D' : BEGIN
              Title := 'Private Message Senders';
              Header := 'Private Messages Sent';
              Decimal := 0;
              Width := 10;
            END;
      'E' : BEGIN
              Title := 'Public Message Posters';
              Header := 'Messages Posted';
              Decimal := 0;
              Width := 10;
            END;
      'F' : BEGIN
              Title := 'SysOp Feedback Senders';
              Header := 'SysOp Feedback Sent';
              Decimal := 0;
              Width := 10;
            END;
      'G' : BEGIN
              Title := 'All Time Callers';
              Header := 'Calls To The System';
              Decimal := 0;
              Width := 10;
            END;
      'H' : BEGIN
              Title := 'File Uploaders';
              Header := 'Files Uploaded';
              Decimal := 0;
              Width := 10;
            END;
      'I' : BEGIN
              Title := 'File Downloaders';
              Header := 'Files Downloaded';
              Decimal := 0;
              Width := 10;
            END;
      'J' : BEGIN
              Title := 'File Points';
              Header := 'File Points On Hand';
              Decimal := 0;
              Width := 10;
            END;
      'K' : BEGIN
              Title := 'Upload/Download Ratios';
              Header := 'KB Uploaded for Each KB Downloaded';
              Decimal := 2;
              Width := 12;
            END;
      'L' : BEGIN
              Title := 'Post/Call Ratios';
              Header := 'Public Messages Posted Each Call';
              Decimal := 2;
              Width := 12;
            END;
    END;
    DisplayTop10UserArray(Top10User,Title,Header,Decimal,Width);
  END
  ELSE IF (MenuOption[1] = 'M') THEN
  BEGIN
    SearchTop20GlobalFileSpec(Top20File);
    DisplayTop20FileArray(Top20File);
  END;
END;

END.