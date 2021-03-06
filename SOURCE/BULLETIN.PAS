{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}
UNIT Bulletin;

INTERFACE

USES
  Common;

FUNCTION FindOnlyOnce: Boolean;
FUNCTION NewBulletins: Boolean;
PROCEDURE Bulletins(MenuOption: Str50);
PROCEDURE UList(MenuOption: Str50);
PROCEDURE TodaysCallers(NumToList: Integer);
PROCEDURE RGQuote(MenuOption: Str50);

IMPLEMENTATION

USES
  CRT,
  DOS,
  Mail1,
  ShortMsg,
  TimeFunc;

TYPE
  LastCallerPtrType = ^LastCallerRec;
  UserPtrType = ^UserRecordType;

PROCEDURE Bulletins(MenuOption: Str50);
VAR
  Main,
  Subs,
  InputStr: ASTR;
BEGIN
  NL;
  IF (MenuOption = '') THEN
    IF (General.BulletPrefix = '') THEN
      MenuOption := 'BULLETIN;BULLET'
    ELSE
      MenuOption := 'BULLETIN;'+General.BulletPrefix;
  IF (Pos(';',MenuOption) <> 0) THEN
  BEGIN
    Main := Copy(MenuOption,1,(Pos(';',MenuOption) - 1));
    Subs := Copy(MenuOption,(Pos(';',MenuOption) + 1),(Length(MenuOption) - Pos(';',MenuOption)));
  END
  ELSE
  BEGIN
    Main := MenuOption;
    Subs := MenuOption;
  END;
  PrintF(Main);
  IF (NOT NoFile) THEN
    REPEAT
      NL;
      { Prt(FString.BulletinLine); }
      lRGLngStr(16,FALSE);
      ScanInput(InputStr,'ABCDEFGHIJKLMNOPQRSTUVWXYZ?');
      IF (NOT HangUp) THEN
      BEGIN
        IF (InputStr = '?') THEN
          PrintF(Main);
        IF (InputStr <> '') AND NOT (InputStr[1] IN ['Q','?']) THEN
          PrintF(Subs+InputStr);
      END;
    UNTIL (InputStr = 'Q') OR (HangUp);
END;

FUNCTION FindOnlyOnce: Boolean;
VAR
  (*
  DirInfo: SearchRec;
  *)
  DT: DateTime;
BEGIN
  FindOnlyOnce := FALSE;
  FindFirst(General.MiscPath+'ONLYONCE.*',AnyFile - Directory - VolumeID- DOS.Hidden,DirInfo);
  IF (DosError = 0) THEN
  BEGIN
    UnPackTime(DirInfo.Time,DT);
    IF (DateToPack(DT) > ThisUser.LastOn) THEN
      FindOnlyOnce := TRUE;
  END;
END;

FUNCTION NewBulletins: Boolean;
TYPE
  BulletinType = ARRAY [0..255] OF Byte;
VAR
  BulletinArray: ^BulletinType;
  DT: DateTime;
  (*
  DirInfo: SearchRec;
  *)
  BullCount,
  Biggest,
  LenOfBullPrefix,
  LenToCopy: Byte;
  Found: Boolean;

  PROCEDURE ShowBulls;
  VAR
    Counter,
    Counter1,
    Counter2: Byte;
  BEGIN
    FOR Counter := 0 TO BullCount DO
    BEGIN
      FOR Counter1 := 0 TO BullCount DO
        IF (BulletinArray^[Counter] < BulletinArray^[Counter1]) THEN
        BEGIN
          Counter2 := BulletinArray^[Counter];
          BulletinArray^[Counter] := BulletinArray^[Counter1];
          BulletinArray^[Counter1] := Counter2;
        END;
    END;
    Counter1 := 1;
    Prt('|01[ |11');
    FOR Counter2 := 0 TO (BullCount) DO
    BEGIN
      IF (Counter1 = 15) THEN
      BEGIN
        Prt(PadRightInt(BulletinArray^[Counter2],2));
        IF (Counter2 < BullCount) THEN
          Prt(' |01]'+^M^J+'|01[ |11')
        ELSE
          Prt(' |01]');
        Counter1 := 0;
      END
      ELSE
      BEGIN
        Prt(PadRightInt(BulletinArray^[Counter2],2));
        IF (Counter2 < BullCount) THEN
          Prt('|07,|11 ')
        ELSE
          Prt(' |01]');
      END;
      Inc(Counter1);
    END;
    NL;
 END;

BEGIN
  New(BulletinArray);
  FOR BullCount := 0 TO 255 DO
    BulletinArray^[BullCount] := 0;
  Found := FALSE;
  Biggest := 0;
  BullCount := 0;
  LenOfBullPrefix := (Length(General.BulletPrefix) + 1);
  FindFirst(General.MiscPath+General.BulletPrefix+'*.ASC',AnyFile - Directory - VolumeID - DOS.Hidden,DirInfo);
  WHILE (DosError = 0) DO
  BEGIN
    IF (((Pos(General.BulletPrefix,General.MiscPath+General.BulletPrefix+'*.ASC') > 0) AND
       (Pos('BULLETIN',AllCaps(DirInfo.Name)) = 0)) AND
       (Pos('~',DirInfo.Name) = 0)) THEN
    BEGIN
      UnPackTime(DirInfo.Time,DT);
      IF (DateToPack(DT) > ThisUser.LastOn) THEN
      BEGIN
        Found := TRUE;
        LenToCopy := (Pos('.',DirInfo.Name) - 1) - Length(General.BulletPrefix);
        BulletinArray^[BullCount] := StrToInt(Copy(DirInfo.Name,LenOfBullPrefix,LenToCopy));
        IF (BulletinArray^[BullCount] > Biggest) THEN
          Biggest := BulletinArray^[BullCount];
        Inc(BullCount);
      END;
    END;
    IF (BullCount > 254) THEN
      Exit;
    FindNext(DirInfo);
  END;
  IF (Found) THEN
  BEGIN
    Dec(BullCount);
    ShowBulls;
  END;
  Dispose(BulletinArray);
  NewBulletins := Found;
END;

FUNCTION UlistMCI(CONST S: ASTR; Data1,Data2: Pointer): STRING;
VAR
  UserPtr: UserPtrType;
BEGIN
  UlistMCI := S;
  UserPtr := Data1;
  CASE S[1] OF
    'A' : CASE S[2] OF
            'G' : UListMCI := IntToStr(AgeUser(UserPtr^.BirthDate));
          END;
    'D' : CASE S[2] OF
            'K' : UListMCI := IntToStr(UserPtr^.DK);
            'L' : UListMCI := IntToStr(UserPtr^.Downloads);
          END;
    'L' : CASE S[2] OF
            'C' : UListMCI := UserPtr^.CityState;
            'O' : UListMCI := ToDate8(PD2Date(UserPtr^.LastOn));
          END;
    'M' : CASE S[2] OF
            'P' : UListMCI := IntToStr(UserPtr^.MsgPost);
          END;
    'N' : CASE S[2] OF
            'O' : UListMCI := Userptr^.Note;
          END;
    'R' : CASE S[2] OF
            'N' : UListMCI := UserPtr^.RealName;
          END;
    'S' : CASE S[2] OF
            'X' : UListMCI := UserPtr^.Sex;
          END;
    'U' : CASE S[2] OF
            'K' : UListMCI := IntToStr(UserPtr^.UK);
            'L' : UListMCI := IntToStr(UserPtr^.Uploads);
            'N' : UListMCI := Caps(UserPtr^.Name);
            '1' : UListMCI := UserPtr^.UsrDefStr[1];
            '2' : UListMCI := UserPtr^.UsrDefStr[2];
            '3' : UListMCI := UserPtr^.UsrDefStr[3];
          END;
  END;
END;

PROCEDURE UList(MenuOption: Str50);
VAR
  Junk: Pointer;
  User: UserRecordType;
  Cmd: Char;
  TempStr: ASTR;
  Gender: Str1;
  State,
  UState: Str2;
  Age: Str3;
  DateLastOn: Str8;
  City,
  UCity: Str30;
  RName,
  UName: Str36;
  FN: Str50;
  RecNum: Integer;

  PROCEDURE Option(c1: Char; s1,s2: Str160);
  BEGIN
    Prompt('^0(^1'+c1+'^0)'+s1+': ');
    IF (s2 <> '') THEN
      Print('^0"^1'+s2+'^0"')
    ELSE
      Print('^8[INACTIVE]');
  END;

BEGIN
  IF (RUserList IN ThisUser.Flags) THEN
  BEGIN
    Print('You are restricted from listing users.');
    Exit;
  END;
  Age := '';
  City := '';
  DateLastOn := '';
  Gender := '';
  RName := '';
  State := '';
  UName := '';
  REPEAT
    ClrScr;
    Print('^0User List Search Options');
    NL;
    Option('U','ser Name        ',UName);
    Option('R','eal Name        ',RName);
    Option('A','ge              ',Age);
    Option('G','ender           ',Gender);
    Option('C','ity             ',City);
    Option('S','tate            ',State);
    Option('D','ate Last Online ',DateLastOn);
    NL;
    Prompt('^0Enter Command [(^1Enter^0/^1L^0)ist,(^1Q^0)uit]: ');
    OneK(Cmd,'QACDGLRSU'^M,TRUE,TRUE);
    NL;
    IF (Cmd IN ['A','C','D','G','R','S','U']) THEN
    BEGIN
      TempStr := 'Enter New Match String For ';
      CASE Cmd OF
        'A' : TempStr := TempStr + 'Age';
        'C' : TempStr := TempStr + 'City';
        'D' : TempStr := TempStr + 'Date Last Online';
        'G' : TempStr := TempStr + 'Gender';
        'R' : TempStr := TempStr + 'Real Name';
        'S' : TempStr := TempStr + 'State';
        'U' : TempStr := TempStr + 'User Name';
      END;
      TempStr := TempStr + ' [(^1ENTER^0)None]: ';
	  Print('^0'+TempStr);
      Prompt('');
    END;
    CASE Cmd OF
      'A' : BEGIN
              Mpl(3);
              Input(Age,3);
            END;
      'C' : BEGIN
              Mpl(30);
              Input(City,30);
            END;
      'D' : BEGIN
              Mpl(8);
              InputFormatted('',DateLastOn,'##/##/##',TRUE);
              IF (DayNum(DateLastOn) <> 0) AND (DayNum(DateLastOn) <= DayNum(DateStr)) THEN
              BEGIN
                Delete(DateLastOn,3,1);
                Insert('-',DateLastOn,3);
                Delete(DateLastOn,6,1);
                Insert('-',DateLastOn,6);
              END;
            END;
      'G' : BEGIN
              Mpl(1);
              Input(Gender,1);
            END;
      'R' : BEGIN
              Mpl(36);
              Input(RName,36);
            END;
      'S' : BEGIN
              Mpl(2);
              Input(State,2);
            END;
      'U' : BEGIN
              Mpl(36);
              Input(UName,36);
            END;
    END;
  UNTIL (Cmd IN ['L','Q',^M]) OR (HangUp);
  IF (Cmd IN ['L',^M]) THEN
  BEGIN
    Abort := FALSE;
    Next := FALSE;
    AllowContinue := TRUE;
    IF (Pos(';',MenuOption) > 0) THEN
    BEGIN
      FN := Copy(MenuOption,(Pos(';',MenuOption) + 1),255);
      MenuOption := Copy(MenuOption,1,(Pos(';',MenuOption) - 1));
    END
    ELSE
      FN := 'USER';
    IF (NOT ReadBuffer(FN+'M')) THEN
      Exit;
    PrintF(FN+'H');
    Reset(UserFile);
    RecNum := 1;
    WHILE (RecNum <= (FileSize(UserFile) - 1)) AND (NOT Abort) AND (NOT HangUp) DO
    BEGIN
      LoadURec(User,RecNum);
      UCity := (Copy(User.CityState,1,(Pos(',',User.CityState) - 1)));
      UState := SQOutSP((Copy(User.CityState,(Pos(',',User.CityState) + 2),(Length(User.CityState)))));
      IF (AACS1(User,RecNum,MenuOption)) AND NOT (Deleted IN User.SFlags) THEN
        IF (Age = '') OR (Pos(Age,IntToStr(AgeUser(User.BirthDate))) > 0) THEN
          IF (City = '') OR (Pos(City,AllCaps(UCity)) > 0) THEN
            IF (DateLastOn = '') OR (Pos(DateLastOn,ToDate8(PD2Date(User.LastOn))) > 0) THEN
              IF (Gender = '') OR (Pos(Gender,User.Sex) > 0) THEN
                IF (RName = '') OR (Pos(RName,AllCaps(User.RealName)) > 0) THEN
                  IF (State = '') OR (Pos(State,AllCaps(UState)) > 0) THEN
                     IF (UName = '') OR (Pos(UName,User.Name) > 0) THEN
                        DisplayBuffer(UlistMCI,@User,Junk);
      Inc(RecNum);
    END;
    Close(UserFile);
    IF (NOT Abort) AND (NOT HangUp) THEN
      PrintF(FN+'T');
    AllowContinue := FALSE;
  END;
  SysOpLog('Viewed User Listing.');
  LastError := IOResult;
END;

FUNCTION TodaysCallerMCI(CONST S: ASTR; Data1,Data2: Pointer): STRING;
VAR
  LastCallerPtr: LastCallerPtrType;
  s1: STRING[100];
  AMPM: STRING[2];
  DT: DateTime;
BEGIN
  LastCallerPtr := Data1;
  TodaysCallerMCI := S;
  CASE S[1] OF
    'C' : CASE S[2] OF
            'A' : TodaysCallerMCI := FormatNumber(LastCallerPtr^.Caller);
          END;
    'D' : CASE S[2] OF
            'K' : TodaysCallerMCI := IntToStr(LastCallerPtr^.DK);
            'L' : TodaysCallerMCI := IntToStr(LastCallerPtr^.Downloads);
          END;
    'E' : CASE S[2] OF
            'S' : TodaysCallerMCI := IntToStr(LastCallerPtr^.EmailSent);
          END;
    'F' : CASE S[2] OF
            'S' : TodaysCallerMCI := IntToStr(LastCallerPtr^.FeedbackSent);
          END;
    'L' : CASE S[2] OF
            'C' : TodaysCallerMCI := LastCallerPtr^.Location;
            'O' : TodaysCallerMCI := PDToTime(LastCallerPtr^.LogonTime); { LeeW: Fix'd }
            'T' : BEGIN
                    IF (LastCallerPtr^.LogoffTime = 0) THEN
                      S1 := 'Online'
                    ELSE
                    BEGIN
                      S1 := PDToTime(LastCallerPtr^.LogoffTime); { LeeW: Fix'd }
                    END;
                    TodaysCallerMCI := s1;
                  END;
          END;
    'M' : CASE S[2] OF
            'P' : TodaysCallerMCI := IntToStr(LastCallerPtr^.MsgPost);
            'R' : TodaysCallerMCI := IntToStr(LastCallerPtr^.MsgRead);
          END;
    'N' : CASE S[2] OF
            'D' : TodaysCallerMCI := IntToStr(LastCallerPtr^.Node);
            'U' : IF (LastCallerPtr^.NewUser) THEN
                    TodaysCallerMCI := '*'
                  ELSE
                    TodaysCallerMCI := ' ';
          END;
    'S' : CASE S[2] OF
            'P' : IF (LastCallerPtr^.Speed = 0) THEN
                    TodaysCallerMCI := 'Local'
                  ELSE IF (Telnet) THEN
                    TodaysCallerMCI := 'Telnet'
                  ELSE
                    TodaysCallerMCI := IntToStr(LastCallerPtr^.Speed);
          END;
    'T' : CASE S[2] OF
            'O' : WITH LastCallerPtr^ DO
                    TodaysCallerMCI := IntToStr((LogoffTime - LogonTime) DIV 60);
          END;
    'U' : CASE S[2] OF
            'K' : TodaysCallerMCI := IntToStr(LastCallerPtr^.UK);
            'L' : TodaysCallerMCI := IntToStr(LastCallerPtr^.Uploads);
            'N' : TodaysCallerMCI := LastCallerPtr^.UserName;
          END;
  END;
END;

PROCEDURE TodaysCallers(NumToList: Integer);
VAR
  Junk: Pointer;
  LastCallerFile: FILE OF LastCallerRec;
  LastCaller: LastCallerRec;
  RecNum: Integer;
BEGIN
  Abort := FALSE;
  Next := FALSE;
  AllowContinue := TRUE;
  IF (NOT ReadBuffer('LASTM')) THEN
    Exit;
  Assign(LastCallerFile,General.DataPath+'LASTON.DAT');
  Reset(LastCallerFile);
  IF (IOResult <> 0) THEN
    Exit;
  RecNum := 0;
  IF (NumToList > 0) AND (NumToList <= FileSize(LastCallerFile)) THEN
    RecNum := (FileSize(LastCallerFile) - NumToList);
  PrintF('LASTH');
  Seek(LastCallerFile,RecNum);
  WHILE (NOT EOF(LastCallerFile)) AND (NOT Abort) AND (NOT HangUp) DO
  BEGIN
    Read(LastCallerFile,LastCaller);
    IF (((LastCaller.LogonTime DIV 86400) <> (GetPackDateTime DIV 86400))) OR
       (((LastCaller.LogonTime DIV 86400) = (GetPackDateTime DIV 86400))) THEN
	   BEGIN
	   DisplayBuffer(TodaysCallerMCI,@LastCaller,Junk);
	   END;
  END;
  Close(LastCallerFile);
  IF (NOT Abort) THEN
    PrintF('LASTT');
  AllowContinue := FALSE;
  SysOpLog('Viewed Todays Callers.');
  LastError := IOResult;
END;

PROCEDURE RGQuote(MenuOption: Str50);
VAR
  StrPointerFile: FILE OF StrPointerRec;
  StrPointer: StrPointerRec;
  RGStrFile: FILE;
  F,
  F1: Text;
  MHeader: MHeaderRec;
  S: STRING;
  StrNum: Word;
  TotLoad: LongInt;
BEGIN
  IF (MenuOption = '') THEN
    Exit;
  Assign(StrPointerFile,General.DataPath+MenuOption+'.PTR');
  Reset(StrPointerFile);
  TotLoad := FileSize(StrPointerFile);
  IF (TotLoad < 1) THEN
    Exit;
  IF (TotLoad > 65535) THEN
    Totload := 65535
  ELSE
    Dec(TotLoad);
  Randomize;
  StrNum := Random(Totload);
  Seek(StrPointerFile,StrNum);
  Read(StrPointerFile,StrPointer);
  Close(StrPointerFile);
  LastError := IOResult;
  IF (Exist(General.MiscPath+'QUOTEHDR.*')) THEN
    PrintF('QUOTEHDR')
  ELSE
  BEGIN
    NL;
    Print('|03[컴컴컴컴컴컴컴컴컴컴컴? |11And Now |03... |11A Quote For You! |03]컴컴컴컴컴컴컴컴컴컴컴]');
    NL;
  END;
  TotLoad := 0;
  Assign(RGStrFile,General.DataPath+MenuOption+'.DAT');
  Reset(RGStrFile,1);
  Seek(RGStrFile,(StrPointer.Pointer - 1));
  REPEAT
    BlockRead(RGStrFile,S[0],1);
    BlockRead(RGStrFile,S[1],Ord(S[0]));
    Inc(TotLoad,(Length(S) + 1));
    IF (S[Length(S)] = '@') THEN
    BEGIN
      Dec(S[0]);
      Prt(Centre(S));
    END
    ELSE
      PrintACR(Centre(S));
  UNTIL (TotLoad >= StrPointer.TextSize) OR EOF(RGStrFile);
  Close(RGStrFile);
  LastError := IOResult;
  IF (Exist(General.MiscPath+'QUOTEFTR.*')) THEN
    PrintF('QUOTEFTR')
  ELSE
  BEGIN
    NL;
    Print('|03[컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?');
    NL;
  END;
  IF (NOT General.UserAddQuote) THEN
    PauseScr(FALSE)
  ELSE IF (PYNQ('Would you like to add a quote? ',0,FALSE)) THEN
  BEGIN
    PrintF('QUOTE');
    InResponseTo := '';
    MHeader.Status := [];
    IF (InputMessage(TRUE,FALSE,'New Quote',MHeader,General.DataPath+MenuOption+'.TMP',78,500)) then
      IF Exist(General.DataPath+MenuOption+'.TMP') THEN
      BEGIN
        Assign(F,General.DataPath+MenuOption+'.NEW');
        Reset(F);
        IF (IOResult <> 0) THEN
          ReWrite(F)
        ELSE
          Append(F);
        Assign(F1,General.DataPath+MenuOption+'.TMP');
        Reset(F1);
        IF (IOResult <> 0) THEN
          Exit;
        WriteLn(F,'New quote from: '+Caps(ThisUser.Name)+' #'+IntToStr(UserNum)+'.');
        WriteLn(F,'');
        WriteLn(F,'$');
        WHILE (NOT EOF(F1)) DO
        BEGIN
          ReadLn(F1,S);
          WriteLn(F,S);
        END;
        WriteLn(F,'$');
        WriteLn(F,'');
        WriteLn(F);
        Close(F);
        Close(F1);
        Kill(General.DataPath+MenuOption+'.TMP');
        NL;
        Print('^7Your new quote was saved.');
        PauseScr(FALSE);
        SendShortMessage(1,Caps(ThisUser.Name)+' added a new quote to "'+MenuOption+'.NEW".');
      END;
  END;
END;

END.
