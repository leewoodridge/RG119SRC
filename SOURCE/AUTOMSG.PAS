UNIT AutoMsg;

INTERFACE

PROCEDURE ReadAutoMsg;
PROCEDURE WriteAutoMsg;
PROCEDURE ReplyAutoMsg;

IMPLEMENTATION

USES
  Dos,
  {SysUtils,}
  Common,
  Email,
  Mail0,
  Mail1;

PROCEDURE ReadAutoMsg;
VAR
  AutoMsgFile: Text;
  TempStr: AStr;
  Counter,
  LenTempStr: Byte;
  FileDateTime: LongInt;
  FileDateTime2: DateTime;
BEGIN
  Assign(AutoMsgFile,General.MiscPath+'AUTO.ASC');
  Reset(AutoMsgFile);
  IF (IOResult <> 0) THEN
    Print('%LFNo auto-message available.')
  ELSE
  BEGIN
    ReadLn(AutoMsgFile,TempStr);
    CASE TempStr[1] OF
      '@' : IF (AACS(General.AnonPubRead)) THEN
              TempStr := Copy(TempStr,2,Length(TempStr))+' (Posted Anonymously)'
            ELSE
              TempStr := 'Anonymous';
      '!' : IF (CoSysOp) THEN
              TempStr := Copy(TempStr,2,Length(TempStr))+' (Posted Anonymously)'
            ELSE
              TempStr := 'Anonymous';
    END;
    NL;
	GetFileDateTime(General.MiscPath+'AUTO.ASC',FileDateTime);
	UnpackTime(FileDateTime,FileDateTime2);
	With FileDateTime2 Do
	  Begin
        Print(lRGLngStr(10,TRUE)+TempStr+'|07 on |15'+IntToStr(Month)+'/'+IntToStr(Day)+'/'+IntToStr(Year));
		{ AutoMessage Posted By USERNAME On 01/01/2017 }
      End;
	  
	If (NOT ReadBuffer('AUTOH')) Then
	  Begin
	    LenTempStr := 0;
        REPEAT
          ReadLn(AutoMsgFile,TempStr);
          IF (LennMCI(TempStr) > LenTempStr) THEN
            LenTempStr := LennMCI(TempStr);
        UNTIL (EOF(AutoMsgFile));
        IF (LenTempStr >= ThisUser.LineLen) THEN
          LenTempStr := (ThisUser.LineLen - 1);
        Reset(AutoMsgFile);
        ReadLn(AutoMsgFile,TempStr);
        TempStr := lRGLngStr(11,TRUE);
        {UserColor(0);}
        IF ((NOT OkANSI) AND (NOT OkAvatar) AND (Ord(TempStr[1]) > 128) OR (TempStr[1] = #32)) THEN
          NL
        ELSE
          BEGIN
            FOR Counter := 1 TO LenTempStr DO
              OutKey(TempStr[1]);
              NL;
          END;
	  End
	Else
	  Begin
	    PrintF('AUTOH'); { AutoMessage Header }
	  End;

    REPEAT { Print The AutoMessage }
      ReadLn(AutoMsgFile,TempStr);
      PrintACR(TempStr);
    UNTIL EOF(AutoMsgFile) OR (Abort) OR (HangUp);
    Close(AutoMsgFile);

	If (NOT ReadBuffer('AUTOT')) Then
	  Begin
	    TempStr := lRGLngStr(11,TRUE); { AutoMessage Border Character }
        UserColor(0);
        IF ((NOT OkANSI) AND (NOT OkAvatar) AND (Ord(TempStr[1]) > 128) OR (TempStr[1] = #32)) THEN
         NL
        ELSE
          BEGIN
            FOR Counter := 1 TO LenTempStr DO
            OutKey(TempStr[1]);
            NL;
          END;
	  End
	Else
	  Begin
		PrintF('AUTOT'); { AutoMessage Footer }
	  End;
    PauseScr(FALSE);
  END;
  LastError := IOResult;
END;

PROCEDURE WriteAutoMsg;
VAR
  AutoMsgFile1,
  AutoMsgFile2: Text;
  MHeader: MHeaderRec;
  TempStr: AStr;
BEGIN
  IF (RAMsg IN ThisUser.Flags) THEN
    Print('%LFYou are restricted from writing auto-messages.')
  ELSE
  BEGIN
    InResponseTo := '';
    MHeader.Status := [];
    IF (InputMessage(TRUE,FALSE,'Auto-Message',MHeader,General.MiscPath+'AUTO'+IntToStr(ThisNode)+'.TMP',78,500)) THEN
      IF Exist(General.MiscPath+'AUTO'+IntToStr(ThisNode)+'.TMP') THEN
      BEGIN
        Assign(AutoMsgFile1,General.MiscPath+'AUTO.ASC');
        ReWrite(AutoMsgFile1);
        Assign(AutoMsgFile2,General.MiscPath+'AUTO'+IntToStr(ThisNode)+'.TMP');
        Reset(AutoMsgFile2);
        IF (IOResult <> 0) THEN
          Exit;
        IF (AACS(General.AnonPubPost)) AND PYNQ('Post Anonymously? ',0,FALSE) THEN
          IF (CoSysOp) THEN
            WriteLn(AutoMsgFile1,'!'+Caps(ThisUser.Name))
          ELSE
            WriteLn(AutoMsgFile1,'@'+Caps(ThisUser.Name))
        ELSE
          WriteLn(AutoMsgFile1,Caps(ThisUser.Name));
        WHILE (NOT EOF(AutoMsgFile2)) DO
        BEGIN
          ReadLn(AutoMsgFile2,TempStr);
          WriteLn(AutoMsgFile1,TempStr);
        END;
        Close(AutoMsgFile1);
        Close(AutoMsgFile2);
        Kill(General.MiscPath+'AUTO'+IntToStr(ThisNode)+'.TMP');
      END;
  END;
END;

PROCEDURE ReplyAutoMsg;
VAR
  AutoMsgFile: Text;
  MHeader: MHeaderRec;
  TempStr: AStr;
BEGIN
  Assign(AutoMsgFile,General.MiscPath+'AUTO.ASC');
  Reset(AutoMsgFile);
  IF (IOResult <> 0) THEN
    Print('No auto-message to reply to.')
  ELSE
  BEGIN
    ReadLn(AutoMsgFile,TempStr);
    Close(AutoMsgFile);
    IF (TempStr[1] IN ['!','@']) THEN
    BEGIN
      LastAuthor := SearchUser(Copy(TempStr,2,Length(TempStr)),CoSysOp);
      IF (NOT AACS(General.AnonPrivRead)) THEN
        LastAuthor := 0;
    END
    ELSE
      LastAuthor := SearchUser(TempStr,CoSysOp);
    IF (LastAuthor = 0) THEN
	  Print('Unable to reply to an anonymous message!')
    ELSE
    BEGIN
      InResponseTo := 'Your auto-message';
      MHeader.Status := [];
      AutoReply(MHeader);
    END;
  END;
END;

END.
