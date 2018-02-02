{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

(*
	Strings are in rglng now
	uses common.message for error now
	random is done except it displays the oneliner not sets itself as
	can now specify through menu command param how many oneliners to show
	oneliner length should be calcd by length of name and other info shown	
*)

UNIT OneLiner;

INTERFACE

USES
  Common,
  Common0, { NewYN, ToLower }
  CRT,
  Mail1,
  TimeFunc;
  
CONST
  DefOneLinersToList: Integer = 10;
  
TYPE
  OneLinerRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
	RecordNum  : LongInt;
	OneLiner   : STRING[55];
	UserID     : LongInt;
	UserName   : STRING[36];
	DateAdded,
	DateEdited : UnixTime;
	Anonymous  : Boolean;
  END;

PROCEDURE DoOneLiners(S: STRING);
PROCEDURE OneLiner_Add;
PROCEDURE OneLiner_View(OneLinersToList: Integer);
FUNCTION OneLiner_Random: STRING;

IMPLEMENTATION

VAR
  OneLinerListFile : FILE OF OneLinerRecordType;
  OneLineRec  : OneLinerRecordType;

FUNCTION OneLinerListMCI(CONST S: ASTR; Data1,Data2: Pointer): STRING;
VAR
  OneLinerListPtr: ^OneLinerRecordType;
  User: UserRecordType;
  TmpStr : String;
BEGIN
  OneLinerListPtr := Data1;
  OneLinerListMCI := S;
  CASE S[1] OF
    'A' : CASE S[2] OF
            'N' : OneLinerListMCI := ShowYesNo(OneLinerListPtr^.Anonymous); { Anon - Yes/No }
            'T' : OneLinerListMCI := AonOff(OneLinerListPtr^.Anonymous, 'True', 'False'); { Anon - True/False }
          END;
    'D' : CASE S[2] OF
            'A' : OneLinerListMCI := Pd2Date(OneLinerListPtr^.DateAdded); { Date Added }
            'E' : OneLinerListMCI := Pd2Date(OneLinerListPtr^.DateEdited); { Date Edited - Not Used }
          END;
    'O' : CASE S[2] OF
            'L' : OneLinerListMCI := OneLinerListPtr^.OneLiner; { The Oneliner }
          END;
    'R' : CASE S[2] OF
            'N' : OneLinerListMCI := IntToStr(OneLinerListPtr^.RecordNum); { Oneliner Record Number }
          END;
    'U' : CASE S[2] OF
            '#' : BEGIN { User ID }
                   IF (OneLinerListPtr^.Anonymous) THEN
                    OneLinerListMCI := '';
                   IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                    OneLinerListMCI := '#' + IntToStr(OneLinerListPtr^.UserID);
                   IF (NOT OneLinerListPtr^.Anonymous) THEN
                   OneLinerListMCI := '#' + IntToStr(OneLinerListPtr^.UserID);
                  END;
            '1' : BEGIN { User ID Without # }
                   IF (OneLinerListPtr^.Anonymous) THEN
                    OneLinerListMCI := '';
                   IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                    OneLinerListMCI := IntToStr(OneLinerListPtr^.UserID);
                   IF (NOT OneLinerListPtr^.Anonymous) THEN
                   OneLinerListMCI := IntToStr(OneLinerListPtr^.UserID);
                  END;
            'N' : BEGIN { User Name }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    IF (OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := 'Anonymous';
                    IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                     OneLinerListMCI := Caps(User.Name) + ' ^0(^1A^0)';
                    IF (NOT OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := Caps(User.Name);
                  END;
            'L' : BEGIN { User Name Lower }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    IF (OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := 'anonymous';
                    IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                     OneLinerListMCI := ToLower(User.Name) + ' ^0(^1a^0)';
                    IF (NOT OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := ToLower(User.Name);
                  END;
            'S' : BEGIN { User Name Short }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    IF (OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := 'Anon';
                    IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                     OneLinerListMCI := Copy(User.Name,1,2) + ' ^0(^1A^0)';
                    IF (NOT OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := Copy(User.Name,1,2);
                  END;
            'U' : BEGIN { User Name Short Lower }
                    LoadURec(User,OneLinerListPtr^.UserID);
                    IF (OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := 'anon';
                    IF (OneLinerListPtr^.Anonymous) AND (SysOp) THEN
                     OneLinerListMCI := ToLower(Copy(User.Name,1,2)) + ' ^0(^1a^0)';
                    IF (NOT OneLinerListPtr^.Anonymous) THEN
                     OneLinerListMCI := ToLower(Copy(User.Name,1,2));
                  END;
          END;
    END;
END;

FUNCTION ONELDAT_Exists: Boolean;
VAR
  OneLinerListFile: FILE OF OneLinerRecordType;
  FSize: LongInt;
  FExist: Boolean;
BEGIN
  FSize := 0;
  FExist := Exist(General.DataPath+'ONELINER.DAT');
  IF (FExist) THEN
  BEGIN
    Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
    Reset(OneLinerListFile);
    FSize := FileSize(OneLinerListFile);
    Close(OneLinerListFile);
  END;
  IF (NOT FExist) OR (FSize = 0) THEN
	lRGLngStr(158,FALSE); { "There are currently no one-liners" }
  ONELDAT_Exists := (FExist) AND (FSize > 0);
END;

FUNCTION ONELM_Exists: Boolean;
BEGIN
  IF (NOT ReadBuffer('ONELM')) THEN
	BEGIN
	  ONELM_Exists := FALSE;
	  Messages(15,0,'ONELM');
	END
  ELSE
    ONELM_Exists := TRUE;
END;

FUNCTION ONELR_Exists: Boolean;
BEGIN
  IF (NOT ReadBuffer('ONELR')) THEN
	BEGIN
	  ONELR_Exists := FALSE;
	  Messages(15,0,'ONELR');
	END
  ELSE
    ONELR_Exists := TRUE;
END;

PROCEDURE OneLiner_Add;
VAR
  Data2: Pointer;
  OneLinerList: OneLinerRecordType;
BEGIN
  IF NewYN(lRGLngStr(160,TRUE){ "Add A One-Liner?" },FALSE) THEN
	BEGIN
	  FillChar(OneLinerList,SizeOf(OneLinerList),0);
	  
	  WHILE (NOT Abort) AND (NOT Hangup) DO
		BEGIN
		  NL;
		  lRGLngStr(159,FALSE); { "Enter your one-liner ..." }
		  MPL(55);
		  InputMain(OneLinerList.OneLiner,(SizeOf(OneLinerList.OneLiner) - 1),[InterActiveEdit,ColorsAllowed]);
		  NL;
		  Abort := (OneLinerList.OneLiner = '');
		  IF (Abort) THEN
			BREAK
		  ELSE
			OneLinerList.Anonymous := NewYN(lRGLngStr(162,TRUE){ "Post Anonymously?" },FALSE);
		  BREAK;
		END;
	  
	  IF (NOT Abort) THEN
		BEGIN
		  PrintF('ONELH');
		  IF (NoFile) THEN
			BEGIN
			  CLS;
			  NL;
			  lRGLngStr(155,FALSE); { "%BN One-Liners" }
			  lRGLngStr(156,FALSE); { "--------------" }
			END;
		  Print('^1'+OneLinerList.OneLiner); { LeeW: show using onelm.* style }
		  PrintF('ONELE');
		  IF (NoFile) THEN
			lRGLngStr(157,FALSE); { "--------------" }
		  IF (NewYN(lRGLngStr(161,TRUE){ "Add This One-Liner?" },TRUE)) THEN
			BEGIN
			  Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
			  IF (Exist(General.DataPath+'ONELINER.DAT')) THEN
				Reset(OneLinerListFile)
			  ELSE
				Rewrite(OneLinerListFile);
				Seek(OneLinerListFile,FileSize(OneLinerListFile));
				OneLinerList.UserID := UserNum;
				OneLinerList.DateAdded := GetPackDateTime;
				OneLinerList.DateEdited := OneLinerList.DateAdded;
				OneLinerList.RecordNum := (FileSize(OneLinerListFile) + 1);
				Write(OneLinerListFile,OneLinerList);
				Close(OneLinerListFile);
				LastError := IOResult;
				SysOpLog('Added One-Liner "'+OneLinerList.OneLiner+'"');
			END;
		END;
    END;
END;

PROCEDURE OneLiner_View(OneLinersToList: Integer);
VAR
  Data2: Pointer;
  OneLinerList: OneLinerRecordType;
  Count : Byte;
BEGIN 
  AllowContinue := TRUE;
  Abort := FALSE;
  PrintF('ONELH');
  IF (NoFile) THEN
	BEGIN
	  CLS;
	  NL;
	  lRGLngStr(155,FALSE); { "%BN One-Liners" }
	  lRGLngStr(156,FALSE); { "--------------" }
	END;
  
  IF (ONELDAT_Exists) AND (ONELM_Exists) THEN
	BEGIN
	  Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
	  Reset(OneLinerListFile);
	  ReadBuffer('ONELM');
	  
	  IF OneLinersToList > FileSize(OneLinerListFile) THEN
		OneLinersToList := FileSize(OneLinerListFile); {ugh}
		
	  FOR Count := FileSize(OneLinerListFile) DOWNTO (FileSize(OneLinerListFile))-(OneLinersToList)+1 DO {ugh}
		BEGIN
		  Seek(OneLinerListFile,((Count)-1));
		  Read(OneLinerListFile,OneLinerList);
		  DisplayBuffer(OneLinerListMCI,@OneLinerList,Data2);
		END;
	  Close(OneLinerListFile);
	END;
  LastError := IOResult;
  IF (NOT Abort) THEN
	PrintF('ONELE');
  IF (NoFile) THEN
	lRGLngStr(157,FALSE); { "--------------" }
  AllowContinue := FALSE;
  SysOpLog(ThisUser.Name+' Viewed The One-Liners.');
  OneLiner_Add;
END;

FUNCTION OneLiner_Random : STRING;
VAR
  RandNmbr: Integer;
  Data2: Pointer;
  OneLinerList: OneLinerRecordType;
BEGIN
  IF (ONELDAT_Exists) AND (ONELR_Exists) THEN
	BEGIN
	  Assign(OneLinerListFile,General.DataPath+'ONELINER.DAT');
      Reset(OneLinerListFile);
      ReadBuffer('ONELR');
	  REPEAT
		RandNmbr := Random(FileSize(OneLinerListFile)+1);
	  UNTIL RandNmbr > 0; { Minimum of 1 }
	  Seek(OneLinerListFile,(RandNmbr-1));
	  Read(OneLinerListFile,OneLinerList);
	  OneLiner_Random := DisplayBuffer(OneLinerListMCI,@OneLinerList,Data2);	  
	  Close(OneLinerListFile);
    END;
  (*PauseScr(FALSE); {just for testing}*)
END;

PROCEDURE DoOneLiners(S: STRING); { To-Do : Variable Number of One Liners To Display }
VAR
  I: Integer; { Number of one-liners to list }
BEGIN
  I := StrToInt(S); { Use the passed param }
  
  IF I = 0 THEN { Was not a number }
	I := DefOneLinersToList; { Use the default }	
	
  OneLiner_View(I);
END;

END.
