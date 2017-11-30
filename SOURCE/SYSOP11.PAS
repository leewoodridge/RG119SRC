{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  SYSOP LOGGING
}

UNIT SysOp11;

INTERFACE

PROCEDURE ChangeUser;
PROCEDURE ShowLogs;

IMPLEMENTATION

USES
  Common,
  TimeFunc,
  MiscUser;

PROCEDURE ChangeUser;
VAR
  UNum: Integer;
BEGIN
  Prt('Change to which User (1-'+IntToStr(MaxUsers - 1)+'): ');
  FindUser(UNum);
  IF (UNum >= 1) THEN
  BEGIN
    SaveURec(ThisUser,UserNum);
    LoadURec(ThisUser,UNum);
    UserNum := UNum;
    ChopTime := 0;
    ExtraTime := 0;
    FreeTime := 0;
    IF (ComPortSpeed > 0) THEN
      SysOpLog('---> ^7Switched accounts to: ^5'+Caps(ThisUser.Name));
    Update_Screen;
    NewCompTables;
    LoadNode(ThisNode);
    WITH NodeR DO
    BEGIN
      User := UserNum;
      UserName := ThisUser.Name;
    END;
    SaveNode(ThisNode);
  END;
END;

PROCEDURE ShowLogs;
VAR
  TempStr: Str10;
  Day: Word;
  Changed: Boolean;
BEGIN
  NL;
  TempStr := '0';
  InputWN1('^0Enter date in MM/DD/YYYY format, or number of days ago [^10^0-^1'+IntToStr(General.BackSysOpLogs)+
  '^0] ',TempStr,(SizeOf(TempStr)-1),[InteractiveEdit],Changed);
  {Input(TempStr,10);}
  IF (Length(TempStr) = 10) AND (DayNum(TempStr) > 0) THEN
    Day := (DayNum(DateStr) - DayNum(TempStr))
  ELSE
    Day := StrToInt(TempStr);
  AllowContinue := TRUE;
  IF (Day = 0) THEN
    PrintF(General.LogsPath+'SYSOP.LOG')
  ELSE
    PrintF(General.LogsPath+'SYSOP'+IntToStr(Day)+'.LOG');
  AllowContinue := FALSE;
  IF (NoFile) THEN
  BEGIN
    NL;
    Print('^8SysOp log not found.');
  END;
  IF (UserOn) THEN
    SysOpLog('Viewed SysOp Log - '+AOnOff(Day = 0,'Today''s',IntToStr(Day)+' days ago'));
  PauseScr(FALSE); { LeeW: Added }
END;

END.
