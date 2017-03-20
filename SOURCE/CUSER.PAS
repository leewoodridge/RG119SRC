UNIT CUser;

INTERFACE

USES
  Common;

PROCEDURE CStuff(Which,How: Byte; VAR User: UserRecordType);

IMPLEMENTATION

USES
  Dos,
  Archive1,
  TimeFunc,
  MiscUser;

VAR
  CountryNum: Integer;

PROCEDURE CStuff(Which,How: Byte; VAR User: UserRecordType);
VAR
  Try: Byte;
  Done,
  Done1: Boolean;

  PROCEDURE DoCountry;
  VAR
    Cmd: Char;
  BEGIN
    Print('Which country are you calling from?');
    NL;
    Print('(1) United States Of America');
    Print('(2) Canada');
    Print('(3) Other Country');
    NL;
    Prt('Select (123): ');
    OneK(Cmd,'123',TRUE,TRUE);
    CountryNum := (Ord(Cmd) - 48);
    Done1 := TRUE;
  END;

  PROCEDURE ConfigureQWK;
  VAR
    ArcExt: Str3;
    AType: Byte;
  BEGIN
    IF (User.DefArcType < 1) OR (User.DefArcType > MaxArcs) THEN
      User.DefArcType := 1;
    Print('Current archive type: ^5'+General.FileArcInfo[User.DefArcType].Ext);
    NL;
    REPEAT
      Prt('Archive type to use? (?=List): ');
      MPL(3);
      Input(ArcExt,3);
      IF (ArcExt = '?') THEN
      BEGIN
        NL;
        ListArcTypes;
        NL;
      END;
    UNTIL (ArcExt <> '?') OR (HangUp);
    IF (StrToInt(ArcExt) <> 0) THEN
      AType := StrToInt(ArcExt)
    ELSE
      AType := ArcType('F.'+ArcExt);
    IF (AType > 0) AND (AType < MaxArcs) THEN
      User.DefArcType := AType;
    Done1 := TRUE;
    NL;
    User.GetOwnQWK := PYNQ('Do you want your own replies in your QWK packet? ',0,FALSE);
    NL;
    User.ScanFilesQWK := PYNQ('Would you like a new files listing in your QWK packet? ',0,FALSE);
    NL;
    User.PrivateQWK := PYNQ('Do you want your private mail in your QWK packet? ',0,FALSE);
    {NL;}
  END;

  PROCEDURE DoAddress;
  VAR
    TempStreet: Str30;
  BEGIN
    {Print('Enter your street address:');}
    Prt('Enter your street address: ');
    MPL((SizeOf(User.Street) - 1));
    IF (How = 3) THEN
      InputL(TempStreet,(SizeOf(User.Street) - 1))
    ELSE
      InputCaps(TempStreet,(SizeOf(User.Street) - 1));
    IF (TempStreet <> '') THEN
    BEGIN
      IF (How = 2) THEN
        SysOpLog('Changed address from '+User.Street+' to '+TempStreet);
      User.Street := TempStreet;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoAge;
  VAR
    TempDate: Str10;
    TempDay,
    TempMonth,
    TempYear,
    CurYear: Word;
    Redo: Boolean;
  BEGIN
    GetYear(CurYear);
    IF (How = 1) AND (IEMSIRec.BDate <> '') THEN
    BEGIN
      Buf := IEMSIRec.BDate;
      IEMSIRec.BDate := '';
    END;
    REPEAT
      Redo := False;
      {Print('Enter your date of birth (mm/dd/yyyy):');}
      Prt('Enter your date of birth (MM/DD/YYYY): ');
      InputFormatted('',TempDate,'##/##/####',(How = 3));
      IF (TempDate <> '') THEN
      BEGIN
        TempMonth := StrToInt(Copy(TempDate,1,2));
        TempDay := StrToInt(Copy(TempDate,4,2));
        TempYear := StrToInt(Copy(TempDate,7,4));
        IF (TempMonth = 0) OR (TempDay = 0) OR (TempYear = 0) THEN
          ReDo := TRUE;
        IF (TempMonth > 12) THEN
          Redo := TRUE;
        IF (TempMonth IN [1,3,5,7,8,10,12]) AND (TempDay > 31) THEN
          Redo := TRUE;
        IF (TempMonth IN [4,6,9,11]) AND (TempDay > 30) THEN
          Redo := TRUE;
        IF (TempMonth = 2) AND ((TempYear MOD 4) <> 0) AND (TempDay > 28) THEN
          Redo := TRUE;
        IF (TempMonth = 2) AND ((TempYear MOD 4) = 0) AND (TempDay > 29) THEN
          Redo := TRUE;
        IF (TempYear >= CurYear) THEN
          Redo := TRUE;
        IF (TempYear < (CurYear - 100)) THEN
          Redo := TRUE;
        IF (Redo) THEN
        BEGIN
          NL;
          Print('^7You entered an invalid date of birth!^1');
          NL;
        END;
      END;
    UNTIL (NOT Redo) OR (HangUp);
    IF (TempDate <> '') THEN
    BEGIN
      IF (How = 2) THEN
        SysOpLog('Changed birthdate from '+PD2Date(User.BirthDate)+' to '+TempDate);
      User.BirthDate := Date2PD(TempDate);
    END;
    Done1 := TRUE;
  END;

  PROCEDURE DoCityState;
  VAR
    s,
    s1,
    s2: AStr;
  BEGIN
    CASE How OF
      2 : DoCountry;
      3 : CountryNum := 1;
    END;
    IF (CountryNum <> 3) THEN
    BEGIN
      IF (How = 3) THEN
      BEGIN
        {Print('Enter new city & state abbreviation:');}
        Prt('Enter your city & state abbreviation: ');
        MPL((SizeOf(User.CityState) - 1));
        InputL(s,(SizeOf(User.CityState) - 1));
        IF (s <> '') THEN
          User.CityState := s;
        Done1 := TRUE;
        Exit;
      END;

      {Print('Enter only your city:');}
      Prt('Enter your city: ');
      MPL(((SizeOf(User.CityState) - 1) - 4));
      InputCaps(s,((SizeOf(User.CityState) - 1) - 4));
      IF (Pos(',',s) <> 0) THEN
      BEGIN
        NL;
        Print('^7Enter only your city name.^1');
        Exit;
      END;
      NL;
      IF (Length(s) < 3) THEN
        Exit;
      Prompt('Enter your '+AOnOff((CountryNum = 1),'state','province')+' abbreviation: ');
      MPL(2);
      Input(s1,2);
      User.CityState := s+', '+s1;
      Done1 := TRUE;
    END
    ELSE
    BEGIN
      {Print('First enter your city name only:');}
      Prt('Enter your city: ');
      MPL(26);
      InputCaps(s1,26);
      IF (Length(s1) < 2) THEN
        Exit;
       NL;
      {Print('Now enter your country name:');}
      Prt('Enter your country: ');
      MPL(26);
      InputCaps(s2,26);
      IF (Length(s2) < 2) THEN
        Exit;
       s := s1+', '+s2;
       IF (Length(s) > 30) THEN
      BEGIN
        Print('^7Max total Length is 30 characters!^1');
        Exit;
      END;
       IF (How = 2) AND (User.CityState <> s) THEN
        SysOpLog('Changed city/state from '+User.CityState+' to '+s);
       User.CityState := s;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoUserDef(QuestionNum: Byte);
  VAR
    UserDefQues: STRING[80];
    s: Str35;
  BEGIN
    CASE QuestionNum OF
      1 : UserDefQues := lRGLngStr(38,TRUE); { SysOp Defined Question #1 }
      2 : UserDefQues := lRGLngStr(39,TRUE);                        { #2 }
      3 : UserDefQues := lRGLngStr(40,TRUE);                        { #3 }
    END;
    IF (UserDefQues = '') THEN
    BEGIN
      User.UsrDefStr[QuestionNum] := '';
      Done1 := TRUE;
      Exit;
    END;
    Print(UserDefQues);
    Prt(': ');
    MPL((SizeOf(User.UsrDefStr[QuestionNum]) - 1));
    InputL(s,(SizeOf(User.UsrDefStr[QuestionNum]) - 1));
    IF (s <> '') THEN
    BEGIN
      User.UsrDefStr[QuestionNum] := s;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoName;
  VAR
    TextFile: Text;
    s,
    s1,
    s2: AStr;
    UNum: Integer;
  BEGIN
    IF (How = 1) THEN
      IF (General.AllowAlias) AND (IEMSIRec.Handle <> '') THEN
      BEGIN
        Buf := IEMSIRec.Handle;
        IEMSIRec.Handle := '';
      END
      ELSE IF (IEMSIRec.UserName <> '') THEN
      BEGIN
        Buf := IEMSIRec.UserName;
        IEMSIRec.UserName := '';
      END;
    IF (General.AllowAlias) THEN
    BEGIN
      Print('Enter your handle, or your real first & last');
      Print('names if you don''t want to use one.')
    END
    ELSE
    BEGIN
      Print('Enter your first & last Name.');
      Print('Handles are not allowed.');
    END;
    Prt(': ');
    MPL((SizeOf(User.Name) - 1));
    Input(s,(SizeOf(User.Name) -1));
    Done1 := FALSE;
    WHILE (s[1] IN [' ','0'..'9']) AND (Length(s) > 0) do
      Delete(s,1,1);
    WHILE (s[Length(s)] = ' ') do
      Dec(s[0]);
    IF ((Pos(' ',s) = 0) AND (How <> 3) AND NOT (General.AllowAlias)) THEN
    BEGIN
      NL;
      Print('Enter your first and last Name!');
      s := '';
    END;
    IF (s <> '') THEN
    BEGIN
      Done1 := TRUE;
      UNum := SearchUser(s,TRUE);
      IF (UNum > 0) AND (UNum <> UserNum) THEN
      BEGIN
        Done1 := FALSE;
        NL;
        Print('^7That name is in use.^1');
      END;
    END;
    Assign(TextFile,General.MiscPath+'TRASHCAN.TXT');
    Reset(TextFile);
    IF (IOResult = 0) THEN
    BEGIN
      s2 := ' '+s+' ';
      WHILE NOT EOF(TextFile) do
      BEGIN
        ReadLn(TextFile,s1);
        IF (s1[Length(s1)] = #1) THEN
          s1[Length(s1)] := ' '
        ELSE
          s1 := s1 + ' ';
        s1 := ' ' + s1;
        S1 := AllCaps(S1);
        IF (Pos(s1,s2) <> 0) THEN
          Done1 := FALSE;
      END;
      Close(TextFile);
      LastError := IOResult;
    END;
    IF (NOT Done1) AND (NOT HangUp) THEN
    BEGIN
      NL;
      Print(^G'^7Sorry, can''t use that name.^1');
      Inc(Try);
      sl1('Unacceptable Name : '+s);
    END;
    IF (Try >= 3) AND (How = 1) THEN
      HangUp := TRUE;

    IF ((Done) AND (How = 1) AND (NOT General.AllowAlias)) THEN
      User.RealName := Caps(s);

    IF (Done1) THEN
    BEGIN
      IF (How = 2) AND (UserNum > -1) THEN  { Don't do index on unregged users! }
      BEGIN
        SysOpLog('Changed name from '+User.Name+' to '+s);
        InsertIndex(User.Name,UserNum,FALSE,TRUE);
        User.Name := s;
        InsertIndex(User.Name,UserNum,FALSE,FALSE);
      END
      ELSE
        User.Name := s;
    END;
  END;

 PROCEDURE DoPhone;
  VAR
    TempPhone: AStr;
  BEGIN
    CASE How OF
      1 : BEGIN
            IF (IEMSIRec.Ph <> '') THEN
            BEGIN
              Buf := IEMSIRec.Ph;
              IEMSIRec.Ph := '';
            END;
          END;
      {2 : DoCountry;
      3 : CountryNum := 1;}
    END;
    {Print('Enter your phone number:');}
    Prt('Enter your phone number: ');
    IF (((How = 1) AND (CountryNum = 3)) OR (How = 3)) THEN
    BEGIN
      MPL(12);
      Input(TempPhone,12);
      IF (Length(TempPhone) > 5) THEN
      BEGIN
        User.Ph := TempPhone;
        Done1 := TRUE;
      END;
    END
    ELSE
    BEGIN
      InputFormatted('',TempPhone,'(###)###-####',FALSE);
      TempPhone[5] := '-';
      TempPhone := Copy(TempPhone,2,(Length(TempPhone) - 1));
      IF (How = 2) AND (User.Ph <> TempPhone) THEN
        SysOpLog('Changed phone from '+User.Ph+' to '+TempPhone);
      User.Ph := TempPhone;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoPW;
  VAR
    s,
    s2: STRING[20];
    SavePW: LongInt;
  BEGIN
    IF (How = 1) AND (IEMSIRec.PW <> '') THEN
    BEGIN
      Buf := IEMSIRec.PW;
      IEMSIRec.PW := '';
    END;
    SavePW := User.PW;
    IF (How = 2) THEN
    BEGIN
      Print('^5Enter your current password:');
      NL;
      Prompt('Password: ^5');
      GetPassword(s,20);
      IF (CRC32(s) <> User.PW) THEN
      BEGIN
        NL;
        Print('Wrong!');
        NL;
        Exit;
      END;
    END;
    REPEAT
      REPEAT
        Print('Enter your desired password for future access.');
        Print('It should be 4 to 20 characters in length.');
        NL;
        Prompt('Password: ');
        MPL(20);
        GetPassword(s,20);
        NL;
        IF (Length(s) < 4) THEN
        BEGIN
          Print('^7Must be at least 4 characters long!^1');
          NL;
        END
        ELSE IF (Length(s) > 20) THEN
        BEGIN
          Print('^7Must be no more than 20 characters long.^1');
          NL;
        END
        ELSE IF (How = 3) AND (CRC32(s) = SavePW) THEN
        BEGIN
          Print('^7Must be different from your old password!^1');
          NL;
          s := '';
        END
        ELSE IF (s = ThisUser.Name) OR (s = ThisUser.RealName) THEN
        BEGIN
          Print('^7You cannot use that password!^1');
          NL;
          s := '';
        END;
      UNTIL (((Length(s) > 3) AND (Length(s) < 21)) OR (HangUp));
      Print('Enter your password again for verification:');
      NL;
      Prompt('Password: ');
      MPL(20);
      GetPassword(s2,20);
      IF (s2 <> s) THEN
      BEGIN
        NL;
        Print('^7Passwords do not match!^1');
        NL;
      END;
    UNTIL ((s2 = s) OR (HangUp));
    IF (HangUp) AND (How = 3) THEN
      User.PW := SavePW
    ELSE
      User.PW := CRC32(s);
    User.PasswordChanged := DayNum(DateStr);
    IF (How = 2) THEN
    BEGIN
      NL;
      Print('Password changed.');
      SysOpLog('Changed password.');
    END;
    Done1 := TRUE;
  END;

  PROCEDURE DoForgotPW;
  VAR
    s: AStr;
  BEGIN
    IF (How IN [1..2]) THEN
    BEGIN
      REPEAT
        s := '';
        Print('This question will be asked should you ever forget your password.');
        NL;
        Print(General.forgotpwquestion);
        Prt(': ');
        MPL(40);
        Input(s,40);
      UNTIL (s <> '') OR (HangUp);
      User.ForgotPWAnswer := s;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoRealName;
  VAR
    TempRealName: AStr;
    UNum: Integer;
  BEGIN
    IF (How = 1) THEN
      IF (NOT General.AllowAlias) THEN
      BEGIN
        User.RealName := Caps(User.Name);
        Done1 := TRUE;
        Exit;
      END
      ELSE IF (IEMSIRec.UserName <> '') THEN
      BEGIN
        Buf := IEMSIRec.UserName;
        IEMSIRec.UserName := '';
      END;
    {Print('Enter your real first & last name:');}
    Prt('Enter your REAL first & last name: ');
    MPL((SizeOf(User.RealName) - 1));
    IF (How = 3) THEN
      InputL(TempRealName,(SizeOf(User.RealName) - 1))
    ELSE
      InputCaps(TempRealName,(SizeOf(User.RealName) - 1));
    WHILE (TempRealName[1] IN [' ','0'..'9']) AND (Length(TempRealName) > 0) do
      Delete(TempRealName,1,1);
    WHILE (TempRealName[Length(TempRealName)] = ' ') do
      Dec(TempRealName[0]);
    IF (Pos(' ',TempRealName) = 0) AND (How <> 3) THEN
    BEGIN
      NL;
      Print('Enter your first and last name!');
      TempRealName := '';
    END;
    IF (TempRealName <> '') THEN
    BEGIN
      Done1 := TRUE;
      UNum := SearchUser(TempRealName,TRUE);
      IF (UNum > 0) AND (UNum <> UserNum) THEN
      BEGIN
        Done1 := FALSE;
        NL;
        Print('^7That name is in use.^1');
      END;
    END;
    IF (Done1) THEN
    BEGIN
      IF (How = 2) AND (UserNum > -1) THEN { don't do index on unregged users! }
      BEGIN
        SysOpLog('Changed real name from '+User.RealName+' to '+TempRealName);
        InsertIndex(User.RealName,UserNum,TRUE,TRUE);
        User.RealName := TempRealName;
        InsertIndex(User.RealName,UserNum,TRUE,FALSE);
      END
      ELSE
        User.RealName := TempRealName;
      Done1 := TRUE;
    END;
  END;

  PROCEDURE DoScreen; { Would be nice if defaults were in the input field }
  BEGIN
    InputByteWOC('How wide is your screen',User.LineLen,[DisplayValue,NumbersOnly],32,132);
	Nl;
    InputByteWOC('How many lines per page',User.PageLen,[DisplayValue,NumbersOnly],4,50);
    Done1 := TRUE;
  END;

  PROCEDURE DoSex; { Simplified this a bit, check to see if it's ok }
  VAR
    Cmd: Char;
  BEGIN
    Print('What''s your gender identity?');
    Nl;
    Print('(M) Male');
    Print('(F) Female');
    Print('(O) Other/Non-Binary');
    Nl;
    Prt('Select (MFO): ');
    IF (How = 3) THEN
      BEGIN
      OneK(Cmd,'MFO'^M,TRUE,TRUE);
      IF (Cmd IN ['M','F','O']) THEN
      User.Sex := Cmd;
      END
    ELSE
      BEGIN
        OneK(User.Sex,'MFO',TRUE,TRUE);
      END;
    Done1 := TRUE;
  END;

  PROCEDURE DoZipCode;
  VAR
    TempZipCode: Str10;
  BEGIN
    IF (How = 3) THEN
    BEGIN
      DoCountry;
      NL;
    END;
    CASE CountryNum OF
      1 : BEGIN
            {Print('Enter your zipcode (#####-####):');}
            Prt('Enter your zip code (#####-####): ');
            InputFormatted('',TempZipCode,'#####-####',(How = 3));
            IF (TempZipCode <> '') THEN
              User.ZipCode := TempZipCode;
            Done1 := TRUE;
          END;
      2 : BEGIN
            {Print('Enter your postal code (LNLNLN format)');}
            Prt('Enter your postal code (A#A#A#): ');
            InputFormatted('',TempZipCode,'@#@#@#',(How = 3));
            IF (TempZipCode <> '') THEN
              User.ZipCode := TempZipCode;
            Done1 := TRUE
          END;
      3 : BEGIN
            {Print('Enter your postal code:');}
            Prt('Enter your postal code: ');
            MPL((SizeOf(User.ZipCode) - 1));
            Input(TempZipCode,(SizeOf(User.ZipCode) - 1));
            IF (Length(TempZipCode) > 2) THEN
            BEGIN
              User.ZipCode := TempZipCode;
              Done1 := TRUE;
            END;
          END;
    END;
  END;

  PROCEDURE ForwardMail;
  VAR
    User1: UserRecordType;
    Unum: Integer;
  BEGIN
    NL;
    Print('^5If you forward your mail, all email sent to your account^1');
    Print('^5will be redirected to that person.^1');
    NL;
    Print('Enter User Number, Name, or Partial Search String.');
    Prt(': ');
    lFindUserWS(UNum);
    IF (UNum < 1) OR (UNum > (MaxUsers - 1)) THEN
      User.ForUsr := 0
    ELSE
    BEGIN
      LoadURec(User1,UNum);
      IF (User.Name = User1.Name) OR (LockedOut IN User1.SFlags) OR
         (Deleted IN User1.SFlags) OR (NoMail IN User1.Flags) THEN
      BEGIN
        NL;
        Print('^7You can not forward mail to that user!^1');
      END
      ELSE
      BEGIN
        User.ForUsr := UNum;
        NL;
        Print('Forwarding mail to: ^5'+Caps(User1.Name)+' #'+IntToStr(UNum)+'^1');
        SysOpLog('Forwarding mail to: ^5'+Caps(User1.Name)+' #'+IntToStr(UNum));
      END;
    END;
    IF (How = 3) THEN
      PauseScr(FALSE);
  END;

  PROCEDURE Mailbox;
  BEGIN
    IF (NoMail IN User.Flags) THEN
    BEGIN
      Exclude(User.Flags,NoMail);
      Print('Your mailbox is open');
      IF (How = 3) THEN
        PauseScr(FALSE);
      {SysOpLog('Mail box is now open.');}
    END
    ELSE IF (User.ForUsr <> 0) THEN
    BEGIN
      User.ForUsr := 0;
      Print('Your mail is no longer being forwarded');
      IF (How = 3) THEN
        PauseSCr(FALSE);
      {SysOpLog('Mail forwarding ended.');}
    END
    ELSE
    BEGIN
      IF PYNQ('Do you want to close your mail box? ',0,FALSE) THEN
      BEGIN
        Include(User.Flags,NoMail);
        NL;
        Print('Your mailbox is closed');
        IF (How = 3) THEN
          PauseScr(FALSE);
        {SysOpLog('Your Mailbox is closed');}
      END
      ELSE
      BEGIN
        NL;
        IF PYNQ('Do you want to forward your mail? ',0,FALSE) THEN
          ForwardMail;
      END;
    END;
    Done1 := TRUE;
  END;

  PROCEDURE DoTermEmu;
  VAR
    Cmd: Char;
  BEGIN
    PrintF('TERMINAL');
    Print('Which emulation does your terminal client support?');
    NL;
    Print('(1) None');
    Print('(2) ANSI');
    Print('(3) Avatar');
    Print('(4) VT-100');
    Print('(5) RIP');
    NL;
    Prt('Select (12345): ');
    OneK(Cmd,'12345',TRUE,TRUE);
    Exclude(User.Flags,ANSI);
    Exclude(User.Flags,Avatar);
    Exclude(User.Flags,VT100);
    Exclude(User.SFlags,RIP);
    CASE Cmd OF
      '2' : Include(User.Flags,ANSI);
      '3' : BEGIN
              Include(User.Flags,Avatar);
              NL;
              IF PYNQ('Does your terminal client support ANSI fallback? ',0,TRUE) THEN
                Include(User.Flags,ANSI);
            END;
      '4' : Include(User.Flags,VT100);
      '5' : BEGIN
              Include(User.Flags,ANSI);
              Include(User.SFlags,RIP);
            END;
    END;
    IF (ANSI IN User.Flags) OR (Avatar IN User.Flags) OR (VT100 IN User.Flags) THEN
      Include(User.SFlags,FSEditor)
    ELSE
      Exclude(User.SFlags,FSEditor);
    NL;
    IF (PYNQ('Would you like this to be auto-detected in the future? ',0,TRUE)) THEN
      Include(User.SFlags,AutoDetect)
    ELSE
      Exclude(User.SFlags,AutoDetect);
    Done1 := TRUE;
  END;
 
  Procedure Toggle_Color;
  Begin
    If How = 2 Then
      Begin
        IF (Color In User.Flags) Then
          Begin
            Exclude(User.Flags,Color);
            Print('ANSI color disabled');
          End
        Else
          Begin
          Include(User.Flags,Color);
          Print('ANSI color enabled');
          End;
	    Done1 := True;
	    PauseScr(False);
	  End
    Else
      Begin
        If PYNQ('Enable ANSI Colors? ',0,True) Then
          Include(User.Flags,Color)
        Else
          Exclude(User.Flags,Color);
        Done1 := TRUE;
{ Text color bug happening if select no -- investigate }
      End
  End;

  Procedure Toggle_Editor;
    Begin
      Done1 := True;
      If (Not (ANSI In User.Flags)) And (Not (Avatar In User.Flags)) Then
        Begin
          Print('Your terminal client must support ANSI to use the full screen editor');
          Exclude(User.SFlags,FSEditor);
          Exit;
        End;
      If (FSEditor In User.SFlags) Then
        Begin
          Exclude(User.SFlags,FSEditor);
          Print('Line editor enabled');
        End
      Else
        Begin
          Include(User.SFlags,FSEditor);
          Print('Full screen editor enabled');
        End;
	  PauseScr(False);
    End;

  PROCEDURE Toggle_File_Area_LightBar;
  BEGIN
    IF (NOT General.UseFileAreaLightBar) THEN
    BEGIN
      NL;
      Print('SysOp has disabled the file area lightbar');
	  PauseScr(False);
    END
    ELSE
    BEGIN
      IF (FileAreaLightBar IN ThisUser.SFlags) THEN
      BEGIN
        Exclude(ThisUser.SFlags,FileAreaLightBar);
        Print('File area lightbar disabled');
		PauseScr(False);
      END
      ELSE
      BEGIN
        Include(ThisUser.SFlags,FileAreaLightBar);
        Print('File area lightbar enabled');
		PauseScr(False);
      END;
    END;
    Done1 := TRUE;
  END;

  PROCEDURE Toggle_Message_Area_LightBar;
  BEGIN
    IF (NOT General.UseMsgAreaLightBar) THEN
    BEGIN
      NL;
      Print('SysOp has disabled the message area lightbar');
	  PauseScr(False);
    END
    ELSE
    BEGIN
      IF (MsgAreaLightBar IN ThisUser.SFlags) THEN
      BEGIN
        Exclude(ThisUser.SFlags,MsgAreaLightBar);
        Print('Message area lightbar disabled');
		PauseScr(False);
      END
      ELSE
      BEGIN
        Include(ThisUser.SFlags,MsgAreaLightBar);
        Print('Message area lightbar enabled');
		PauseScr(False);
      END;
    END;
    Done1 := TRUE;
  END;

  PROCEDURE DoColorScheme; { Would be nice if ENTER selected default (#1) }
  VAR
    AScheme: SchemeRec;
    i,
    Onlin: SmallInt;
  BEGIN
    Reset(SchemeFile);
    {CLS;}
    Abort := FALSE;
    Next := FALSE;
    PrintACR('Available Color Schemes:');
    NL;
    i := 1;
    Onlin := 0;
    Seek(SchemeFile,0);
    WHILE (FilePos(SchemeFile) < FileSize(SchemeFile)) AND (NOT Abort) AND (NOT HangUp) do
    BEGIN
      Read(SchemeFile,AScheme);
      Inc(Onlin);
      Prompt('('+PadLeftInt(i,2)+') '+PadLeftStr(AScheme.Description,35));
      IF (OnLin = 2) THEN
      BEGIN
        NL;
        Onlin := 0;
      END;
      WKey;
      Inc(i);
    END;
    Abort := FALSE;
    Next := FALSE;
    NL;
    InputIntegerWOC('%LFSelect a color scheme',i,[NumbersOnly],1,FileSize(SchemeFile));
    IF (i >= 1) AND (i <= FileSize(SchemeFile)) THEN
    BEGIN
      ThisUser.ColorScheme := i;
      Seek(SchemeFile,(i - 1));
      Read(SchemeFile,Scheme);
      Done1 := TRUE;
    END;
    Close(SchemeFile);
    LastError := IOResult;
  END;

  Procedure Toggle_Pause;
    Begin
      If How = 2 Then
        Begin
          If (Pause In User.Flags) Then
            Begin
              Exclude(User.Flags,Pause);
              Print('Pause after each screen disabled');
            End
          Else
            Begin
              Include(User.Flags,Pause);
              Print('Pause after each screen enabled');
            End;
          Done1 := True;
	      PauseScr(False);
        End
      Else
        Begin
          If PYNQ('Pause after each screen? ',0,True) Then
            Include(User.Flags,Pause)
          Else
            Exclude(User.Flags,Pause);
        Done1 := True;
        End
    End;
  
  Procedure Toggle_HotKey;
    Begin
      If How = 2 Then
        Begin
          If (HotKey In User.Flags) Then
            Begin
              Exclude(User.Flags,HotKey);
              Print('Full line input enabled');
            End
          Else
            Begin
              Include(User.Flags,HotKey);
              Print('Hot key input enabled');
            End;
          Done1 := True;
          PauseScr(False);
        End
      Else
        Begin
          If PYNQ('Do you want to use Hot Keys? ',0,True) Then
            Include(User.Flags,HotKey)
          Else
            Exclude(User.Flags,HotKey);
          Done1 := True;
        End
    End;
  
  Procedure Toggle_Expert;
    Begin
      If How = 2 Then
        Begin
          If (Novice In User.Flags) Then
            Begin
              Exclude(User.Flags,Novice);
              CurHelpLevel := 1;
              Print('Expert mode enabled');
            End
          Else
            Begin
              Include(User.Flags,Novice);
              CurHelpLevel := 2;
              Print('Expert mode disabled');
            End;
          Done1 := True;
	      PauseScr(False);
        End
      Else
        Begin
          If PYNQ('Do you want to be in expert mode? ',0,False) Then
            Exclude(User.Flags,Novice)
          Else
            Include(User.Flags,Novice);
          Done1 := True;
        End
    End;
  
  Procedure Toggle_Clear;
    Begin
      If How = 2 Then
        Begin
          If (CLSMsg In User.SFlags) Then
            Begin
              Exclude(User.SFlags,CLSMsg);
              Print('Screen clearing disabled');
            End
          Else
            Begin
              Include(User.SFlags,CLSMsg);
              Print('Screen clearing enabled');
            End;
          Done1 := True;
          PauseScr(False);
        End
      Else
        Begin
          If PYNQ('Clear screen before each message read? ',0,True) Then
            Include(User.SFlags,CLSMsg)
          ELSE
            Exclude(User.SFlags,CLSMsg);
          Done1 := True;
        End
    End;
  
  Procedure WW(www: Byte);
  Begin
    Nl;
    Case www Of
        01 : DoName;            { (!) Handle, or Real Name *MANDATORY* }
        02 : DoRealName;        { (A) Real Name }
        03 : DoCountry;         { (B) Country }
        04 : DoCityState;       { (C) City State }
        05 : DoAddress;         { (D) Address }
        06 : DoZipCode;         { (E) Zip Code }
        07 : DoPhone;           { (F) Phone Number }
        08 : DoAge;             { (G) Birthdate }
        09 : DoSex;             { (H) Gender Identity }
        10 : DoUserDef(1);      { (I) Sysop Defined Question #1 }
        11 : DoUserDef(2);      { (J) Sysop Defined Question #2 }
        12 : DoUserDef(3);      { (K) Sysop Defined Question #3 }
        13 : DoTermEmu;         { (L) Terminal Emulation }
        14 : Toggle_Color;      { (M) ANSI Colors }
        15 : DoColorScheme;     { (N) Color Scheme }
        16 : DoScreen;          { (O) Screen Size }
        17 : Toggle_Clear;      { (P) Screen Clearing }
        18 : Toggle_Pause;      { (R) Screen Pause }
        19 : Toggle_HotKey;     { (S) Hot Keys }
        20 : ConfigureQWK;      { (T) QWK Configuration } { Is This Relevent Anymore? }
        21 : Toggle_Expert;     { (U) Expert Mode }
        22 : DoPW;              { (!) Password *MANDATORY* }
        23 : DoForgotPW;        { (V) Forgot Password Answer }

{       Commands above can be toggled on or off for new user application,
        Commands below are accessible through account settings menu and user editor }

        24 : Mailbox;                           { Mailbox / Mail Forwarding }
        25 : Toggle_Editor;                     { Fullscreen or Line Editor }
        26 : Toggle_File_Area_LightBar;         { File Area Lightbar }
        27 : Toggle_Message_Area_LightBar;      { Message Area Lightbar }
    End;
  End;

Begin
  Try := 0;
  Done1 := False;
  Case How Of
    1 : Repeat { 1 = New User Application }
          WW(Which)
        Until (Done1) Or (HangUp);
    2,3 :
        Begin { 2 = Menu Command OP, 3 = User Editor, Maint }
          WW(Which);
          If (Not Done1) Then
            Print('Function aborted!');
        End;
  End;
End;

(*
  Procedure Toggle_Something;
    Begin
      If How = 2 Then
        Begin
         { for 2 }
        End
      Else
        Begin
          { for not 2 }
        End
    End;
*)

End.
