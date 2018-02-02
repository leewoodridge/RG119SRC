
{ LeeW: Removed just about everything... }

UNIT ExecBat;

INTERFACE

USES
  Common,
  MyIO;

PROCEDURE ExecBatch(VAR Ok: Boolean; Dir, BatLine: AStr; OkLevel: Integer; VAR RCode: Integer; Windowed: Boolean);
{ result }{ directory }{ command }{ errorlevel for success }{ errorlevel returned }{ windowed? }

IMPLEMENTATION

USES
  CRT,
  DOS;

PROCEDURE ExecBatch(VAR Ok: Boolean; Dir: AStr;	BatLine: AStr; OkLevel: Integer; VAR RCode: Integer; Windowed: Boolean);

VAR
  BatchFile: Text;
  SaveDir: AStr;
  BName: STRING[20];
  ResultCode: Integer;
BEGIN
  BName := 'TEMP'+IntToStr(ThisNode)+'.BAT';
  GetDir(0,SaveDir);
  Dir := BSlash(FExpand(Dir),FALSE);
  Assign(BatchFile,BName);
  ReWrite(BatchFile);
  WriteLn(BatchFile,'@ECHO OFF');
  WriteLn(BatchFile,Chr(ExtractDriveNumber(Dir) + 64)+':');
  IF (Dir <> '') THEN
    WriteLn(BatchFile,'CD '+Dir);
  IF (NOT WantOut) THEN
    BatLine := BatLine + ' > NUL';
  WriteLn(BatchFile,BatLine);
  WriteLn(BatchFile,':DONE');
  WriteLn(BatchFile,Chr(ExtractDriveNumber(SaveDir) + 64)+':');
  WriteLn(BatchFile,'CD '+SaveDir);
  WriteLn(BatchFile,'Exit');
  Close(BatchFile);
  IF (NOT WantOut) THEN
    BName := BName + ' > NUL';
  ShellDOS(FALSE,BName,ResultCode);
  ChDir(SaveDir);
  Kill(BName);
  IF (OkLevel <> -1) THEN
    Ok := (RCode = OkLevel)
  ELSE
    Ok := TRUE;
  LastError := IOResult;
END;

END.
