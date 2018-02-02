{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}
(*
finish converting all strings to lang file!!!

not all procs have input validation/error checking or output sysop log entry

blank country = " ", this is set up to check for ""

if no color, dont do color scheme?? -- depends if we plan to put more than colors in scheme data

if no input is needed, move up one char and exit. ie: color scheme for non color emu


*)
UNIT CUser;

INTERFACE

USES
  Common,
  CRT;
  
PROCEDURE CStuff(Which,How: Byte; VAR User: UserRecordType);
PROCEDURE UpString (VAR S : String); 
FUNCTION SearchFile (VAR Name, Find : STRING) : String; 

IMPLEMENTATION

USES
  Dos,
  Archive1,
  TimeFunc,
  MiscUser,
  SysOp12;

{VAR
  CountryNum: Integer;}

PROCEDURE UpString (VAR S : String); { LeeW: Convert a string to uppercase }
VAR 
  P : Byte; 
BEGIN 
  FOR P := 1 TO Length(S) DO
    S[P] := UpCase(S[P]); 
end; 

FUNCTION SearchFile (VAR Name, Find : String) : String; { LeeW: Search a text file for matching string }
VAR
  FS : Text; 
  RD : String; { Matched string }
  Line : LongInt;
  X,
  Y: Integer;
BEGIN
  Line := 0; 
  SearchFile := ''; 
  UpString(Find); 
  Assign(FS,Name); 
  Reset(FS); 
  X := WhereX;
  Y := WhereY;
    REPEAT
      ReadLn(FS,RD); 
      Inc(Line);
      IF Pos(Find,AllCaps(RD))>0 THEN
		BEGIN
		  GoToXY(X,Y); { LeeW: XY positioning to stop from writing a million lines } {ANSIG?}
		  {need to clear prev text (dobackspace?) }
		  IF PYNQ('"'+RD+'" Is This Correct? ',0,FALSE) THEN
		    BEGIN
			  SearchFile := RD;
			  Close(FS);
			  EXIT;
			END;
		END;
    UNTIL EOF(FS) OR (HangUp);
  Close(FS);
END; 
  
  { // }
  
PROCEDURE CStuff(Which,How: Byte; VAR User: UserRecordType);
VAR
  Tries: Byte;
  Done,
  Done1: Boolean;
  
  PROCEDURE ConfigureQWK;
  VAR
    ArcExt: Str3;
    AType: Byte;
  BEGIN
    IF (User.DefArcType < 1) OR (User.DefArcType > MaxArcs) THEN
      User.DefArcType := 1;
    Print('^0Current Archive Type: ^1'+General.FileArcInfo[User.DefArcType].Ext);
    NL;
    REPEAT
      Prt('^0Archive Type To Use? [(^1?^0)List]: ');
      MPL(3);
      Input(ArcExt,3);
      IF (ArcExt = '?') THEN
		BEGIN
		  NL;
		  ListArcTypes;
		  NL;
		END;
    UNTIL (ArcExt <> '?') OR (HangUp);
	IF (ArcExt = '') THEN
	  BEGIN
	  NL;
	  Print('^1'+General.FileArcInfo[User.DefArcType].Ext+'^0 selected'); {Aborted}
	  END;
    IF (StrToInt(ArcExt) <> 0) THEN
      AType := StrToInt(ArcExt)
    ELSE
      AType := ArcType('F.'+ArcExt);
    IF (AType > 0) AND (AType < MaxArcs) THEN
      User.DefArcType := AType;	
    NL;
    User.GetOwnQWK := PYNQ('Do you want your own replies in your QWK packet? ',0,FALSE);
    NL;
    User.ScanFilesQWK := PYNQ('Would you like a new files listing in your QWK packet? ',0,FALSE);
    NL;
    User.PrivateQWK := PYNQ('Do you want your private mail in your QWK packet? ',0,FALSE);
	Done1 := TRUE;
  END;
  
  { ------------------------------------------------------------------- }
  { everything below here is pretty much good to go                     }
  { just fix the formatting 											}
  { ------------------------------------------------------------------- }

  PROCEDURE ForwardMail;
  VAR
    User1: UserRecordType;
    UNum: Integer;
  BEGIN
    NL;
    Print('^0If you forward your mail, all email sent to your account');
    Print('^0will be redirected to that person.');
    NL;
    Print('^0Enter User Number, Name, or Partial Search String.');
    Prt(': ');
    lFindUserWS(UNum);
    IF (UNum < 1) OR (UNum > (MaxUsers - 1)) THEN
      User.ForUsr := 0
    ELSE
    BEGIN
      LoadURec(User1,UNum);
      IF (User.Name = User1.Name) OR (LockedOut IN User1.SFlags) OR (Deleted IN User1.SFlags) OR (NoMail IN User1.Flags) THEN
      BEGIN
        NL;
        Print('^8You can not forward mail to that user!^0');
      END
      ELSE
      BEGIN
        User.ForUsr := UNum;
        NL;
        Print('^0Forwarding mail to ^1'+Caps(User1.Name)+'^0 (#^1'+IntToStr(UNum)+'^0)');
        SysOpLog(User.Name+' is forwarding their mail to '+Caps(User1.Name)+' (#'+IntToStr(UNum)+')');
      END;
    END;
  END;
  
  PROCEDURE Mailbox;
  BEGIN
    IF (NoMail IN User.Flags) THEN
    BEGIN
      Exclude(User.Flags,NoMail);
      Print('^0Your mailbox is open');
      SysOpLog(User.Name+' opened their mailbox');
    END
    ELSE IF (User.ForUsr <> 0) THEN
    BEGIN
      User.ForUsr := 0;
      Print('^0Your mail is no longer being forwarded');
      SysOpLog(User.Name+' stopped forwarding their mail');
    END
    ELSE
    BEGIN
      IF PYNQ('^0Do you want to close your mail box? ',0,FALSE) THEN
      BEGIN
        Include(User.Flags,NoMail);
        NL;
        Print('Your mailbox is closed');
        SysOpLog(User.Name+' closed their mailbox');
      END
      ELSE
      BEGIN
        NL;
        IF PYNQ('^0Do you want to forward your mail? ',0,FALSE) THEN
          ForwardMail;
      END;
    END;
    {Done1 := TRUE;}
  END;
 
 PROCEDURE DoColorScheme;
  VAR
    AScheme: SchemeRec;
	TempScheme,
    Counter,
    OnLine: Integer;
  BEGIN
	Reset(SchemeFile);
	IF NOT (Color In User.Flags) OR NOT ((ANSI IN User.Flags) XOR (VT100 IN User.Flags)) THEN
	  BEGIN
		{ Don't prompt if the users terminal doesn't support color }
		Print('^0Default color scheme selected');
		TempScheme := 1;
	  END
	ELSE IF FileSize(SchemeFile) = 1 THEN
	  BEGIN
		{ Don't prompt if there's only one scheme }
	    Print('^0Default color scheme selected');
		TempScheme := 1;
	  END
	ELSE
	  BEGIN
		IF NOT (How = 1) THEN { Don't clear screen for new user application }
		  CLS;
		PrintACR('^0Available Color Schemes:');
		NL;
		PrintACR('^4+----+---------------------------------+----+---------------------------------+');
		PrintACR('^4| ^3## ^4| ^3Description                     ^4| ^3## ^4| ^3Description                     ^4|');
		PrintACR('^4+----+---------------------------------+----+---------------------------------+');
		Counter := 1;
		OnLine := 0;
		Seek(SchemeFile,0);
		WHILE (FilePos(SchemeFile) < FileSize(SchemeFile)) AND (NOT Abort) AND (NOT HangUp) DO
		  BEGIN
		    Read(SchemeFile,AScheme);
			Inc(OnLine);
			Prompt('^1  '+PadLeftInt(Counter,3)+'^0  '+PadLeftStr(AScheme.Description,32));
			IF (OnLine = 2) THEN
			  BEGIN
				IF (Counter <> FileSize(SchemeFile)) THEN { Don't add line unless there's more to list }
				  NL;
				OnLine := 0;
			  END;
			WKey;
			Inc(Counter);
		  END;
		NL;
		TempScheme := ThisUser.ColorScheme;
		InputIntegerWOC('^0%LFSelect A Color Scheme',TempScheme,[NumbersOnly,InterActiveEdit],1,FileSize(SchemeFile){,Changed});
	  END;
	IF (TempScheme = 0) THEN
	  BEGIN
		NL;
		IF PYNQ('^0Use the default color scheme? ',0,TRUE) THEN
		  BEGIN
			TempScheme := 1;
		  END
	  END;
	IF (TempScheme >= 1) AND (TempScheme <= FileSize(SchemeFile)) THEN
	  BEGIN
		IF (How = 2) AND (TempScheme <> ThisUser.ColorScheme) THEN
		  SysOpLog('Changed color scheme from '+IntToStr(ThisUser.ColorScheme)+' to '+IntToStr(TempScheme));
		ThisUser.ColorScheme := TempScheme;
		Seek(SchemeFile,(TempScheme - 1));
		Read(SchemeFile,Scheme);
		Done1 := TRUE;
	  END
	ELSE
      Close(SchemeFile);
    {
	LastError := IOResult;
	}
  END;
  
  PROCEDURE DoScreen;
  VAR
	TempLineLen,
	TempPageLen: Byte;
	DoneLine,
	DonePage: Boolean;
	Changed,
	Invalid: Boolean;
  BEGIN
	TempLineLen := User.LineLen;
	TempPageLen := User.PageLen;
	REPEAT
	  BEGIN { Screen Width }
        (*Changed := FALSE;
		Invalid := FALSE;*)
		DoneLine := FALSE;
	    NewInputByte(lRGLngStr(119,TRUE){ "How many characters wide is your screen?" },
			TempLineLen,[NumbersOnly,InterActiveEdit],32,132,80,TRUE,Changed,Invalid);
		(*
		InputByteWOC(lRGLngStr(119,TRUE){ "How many characters wide is your screen?" },
		TempLineLen,[NumbersOnly,InterActiveEdit],32,132);
		*)
		IF (TempLineLen >= 32) AND (TempLineLen <= 132) AND NOT (Invalid) THEN
		  BEGIN
			IF (How = 2) AND {(TempLineLen <> User.LineLen)} (Changed) THEN
			  SysOpLog('Changed screen width from '+IntToStr(User.LineLen)+' to '+IntToStr(TempLineLen));
			User.LineLen := TempLineLen;
			DoneLine := TRUE;
		  END;
		NL;
	  END;
	UNTIL (DoneLine = TRUE) OR (How = 2) OR (How = 3);
	REPEAT
	  BEGIN { Screen Length }
        (*Changed := FALSE;
		Invalid := FALSE;*)
	    DonePage := FALSE;
		NewInputByte(lRGLngStr(120,TRUE){ "How many characters tall is your screen?" },
			TempPageLen,[NumbersOnly,InterActiveEdit],4,50,25,TRUE,Changed,Invalid);
		(*
		InputByteWOC(lRGLngStr(120,TRUE){ "How many characters tall is your screen?" },
		TempPageLen,[NumbersOnly,InterActiveEdit],4,50);
		*)
		IF (TempPageLen >= 4) AND (TempPageLen <= 50) AND NOT (Invalid) THEN
		  BEGIN
			IF (How = 2) AND {(TempPageLen <> User.PageLen)} (Changed) THEN
			  SysOpLog('Changed screen length from '+IntToStr(User.PageLen)+' to '+IntToStr(TempPageLen));
			User.PageLen := TempPageLen;
			DonePage := TRUE;
		  END;
		IF (Invalid) THEN
		  NL;
	  END;
	UNTIL (DonePage = TRUE) OR (How = 2) OR (How = 3);
	IF (DoneLine = TRUE) AND (DonePage = TRUE) THEN
	  Done1 := TRUE
	ELSE
	  Done1 := FALSE;
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
		  lRGLngStr(102,FALSE);
		  { "Enter your handle, or your real first & last
		  names if you don't want to use one." }
		END
	  ELSE
		BEGIN
		  lRGLngStr(103,FALSE);
		  { "Enter your first and last name,
		  handles are not allowed." }
		END;
    {Prt(': ');}
    MPL((SizeOf(User.Name) - 1));
    Input(s,(SizeOf(User.Name) -1));
    Done1 := FALSE;
    WHILE (s[1] IN [' ','0'..'9']) AND (Length(s) > 0) DO
      Delete(s,1,1);
    WHILE (s[Length(s)] = ' ') DO
      Dec(s[0]);
    IF ((Pos(' ',s) = 0) AND (How <> 3) AND NOT (General.AllowAlias)) THEN
	  BEGIN
		NL;
		lRGLngStr(104,FALSE); { "Enter your first AND last name" }
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
			lRGLngStr(105,FALSE); { "That name is already in use" }
		  END;
	  END;
	Assign(TextFile,General.MiscPath+'TRASHCAN.TXT');
	Reset(TextFile);
	IF (IOResult = 0) THEN
	  BEGIN
		s2 := ' '+s+' ';
		WHILE NOT EOF(TextFile) DO
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
		lRGLngStr(106,FALSE); { "Invalid name" }
		sl1('Unacceptable Name : '+s);
	  END;
    IF ((How = 1) AND (NOT General.AllowAlias)) THEN { This was checking for 'done', which was unused - LeeW }
      User.RealName := Caps(s);
    IF (Done1) THEN
	  BEGIN
		IF (How = 2) AND (UserNum > -1) THEN  { Don't do index on unregged users! }
		  BEGIN
			IF (User.Name <> s) THEN
			  SysOpLog('Changed name from '+User.Name+' to '+s);
			InsertIndex(User.Name,UserNum,FALSE,TRUE);
			User.Name := s;
			InsertIndex(User.Name,UserNum,FALSE,FALSE);
		  END
		ELSE
		  User.Name := s;
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
		  EXIT;
		END
      ELSE IF (IEMSIRec.UserName <> '') THEN
		BEGIN
          Buf := IEMSIRec.UserName;
          IEMSIRec.UserName := '';
		END;
	  Prt(lRGLngStr(118,TRUE)); { "Enter your REAL first and last name" }
	  MPL((SizeOf(User.RealName) - 1));
	  InputCaps(TempRealName,(SizeOf(User.RealName) - 1));
	  WHILE (TempRealName[1] IN [' ','0'..'9']) AND (Length(TempRealName) > 0) DO
		Delete(TempRealName,1,1);
	  WHILE (TempRealName[Length(TempRealName)] = ' ') DO
		Dec(TempRealName[0]);
	  IF (Pos(' ',TempRealName) = 0) (*AND (How <> 3)*) THEN
		BEGIN
		  NL;
		  Print(lRGLngStr(104,TRUE)); { "Enter your first AND last name" }
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
			  Print(lRGLngStr(105,TRUE)); { "That name is already in use" }
			END;
		END;
		IF (Done1) THEN
		  BEGIN
		    Done1 := TRUE;
			IF (How = 2) AND (UserNum > -1) THEN { don't do index on unregged users! }
			  BEGIN
				IF (User.RealName <> TempRealName) THEN
				  SysOpLog('Changed real name from '+User.RealName+' to '+TempRealName);
				InsertIndex(User.RealName,UserNum,TRUE,TRUE);
				User.RealName := TempRealName;
				InsertIndex(User.RealName,UserNum,TRUE,FALSE);
			  END
			ELSE
			  User.RealName := TempRealName;
		  END;
  END;
  
  PROCEDURE DoCountry;
  VAR
	TextFile,
	TempCountryNameIn,
	TempCountryNameOut: String;
  BEGIN
	TextFile := 'DATA\COUNTRY.TXT';
	TempCountryNameIn := '';
	TempCountryNameOut := '';
	IF How = 1 THEN
	  BEGIN
		REPEAT
		  Prt(lRGLngStr(99,TRUE)); { "Enter your country: " }
		  MPL(30);
		  InputCaps(TempCountryNameIn,30);
		  TempCountryNameOut := SearchFile(TextFile,TempCountryNameIn);
		  IF TempCountryNameOut = '' THEN
		    lRGLngStr(154,FALSE); { "Invalid country" }
		UNTIL (TempCountryNameOut <> '') OR (HangUp);
	  END
	ELSE
	  BEGIN
		Prt(lRGLngStr(99,TRUE)); { "Enter your country: " }
		MPL(30);
		InputCaps(TempCountryNameIn,30);
		TempCountryNameOut := SearchFile(TextFile,TempCountryNameIn);
	  END;
	IF (TempCountryNameOut <> '') THEN
	  BEGIN
		Done1 := TRUE;
		IF (How = 2) AND (User.Country <> TempCountryNameOut) THEN
		  SL1('Changed Country from '+User.Country+' to '+TempCountryNameOut);
		User.Country := TempCountryNameOut;
	  END;
	(*
	TextFile := ''; { LeeW: Clear variables }
	TempCountryNameIn := ''; 
	TempCountryNameOut := '';
	*)
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
		Print(lRGLngStr(108,TRUE)); { "Enter your current password: " }
		NL;
		Prompt(lRGLngStr(109,TRUE)); { "Password: " }
		MPL(20);
		GetPassword(s,20);
		IF (CRC32(s) <> User.PW) THEN
		  BEGIN
			NL;
			Print('^8Wrong!'); { "Incorrect password" }
			NL;
			EXIT;
		  END;
	  END;
    REPEAT
      REPEAT
		lRGLngStr(110,FALSE);
		{ "Enter your desired password,
		   it must be between 4 and 20 characters in length" }
        NL;
		Prompt(lRGLngStr(109,TRUE)); { "Password: " }
        MPL(20);
        GetPassword(s,20);
        NL;
		IF (s = '') AND (How = 2) THEN { LeeW: Added in case user wants to abort password change }
			Exit;
		IF (Length(s) < 4) THEN
		  BEGIN
			Print(lRGLngStr(111,TRUE)); { "4 characters minimum" }
			NL;
		  END
		  (* { it can't be over 20 chars, input field is only 20 }
        ELSE IF (Length(s) > 20) THEN
		  BEGIN
			Print(lRGLngStr(112,TRUE)); { "20 characters maximum" }
			NL;
		  END
		  *)
        ELSE IF (How = 3) AND (CRC32(s) = SavePW) THEN
		  BEGIN
			Print(lRGLngStr(113,TRUE)); { "Must be different from your old password" }
			NL;
			s := '';
		  END
        ELSE IF (s = ThisUser.Name) OR (s = ThisUser.RealName) THEN
		  BEGIN
			Print(lRGLngStr(114,TRUE)); { "Invalid password" }
			NL;
			s := '';
		  END;
	  UNTIL (((Length(s) > 3) AND (Length(s) < 21)) OR (HangUp));
	  Print(lRGLngStr(115,TRUE)); { "Enter your password again for verification" }
      NL;
	  Prompt(lRGLngStr(109,TRUE)); { "Password: " }
      MPL(20);
      GetPassword(s2,20);
      IF (s2 <> s) THEN
		BEGIN
		  NL;
		  Print(lRGLngStr(116,TRUE)); { "Passwords do not match" }
		  NL;
		END;
    UNTIL ((s2 = s) OR (HangUp));	  
	IF (s2 = s) THEN { LeeW: I think this is correct for testing for successful password change }
	  BEGIN
		IF (HangUp) AND (How = 3) THEN
		  User.PW := SavePW
		ELSE
		  User.PW := CRC32(s);
		Done1 := TRUE;
		User.PasswordChanged := DayNum(DateStr);
		IF (How = 2) THEN
		  BEGIN
			NL;
			Print(lRGLngStr(117,TRUE)); { "Password changed" }
			SysOpLog(User.Name+' changed their password');
		  END;
	  END;
  END;

  PROCEDURE DoForgotPW;
  VAR
    TempForgotPWAnswer: AStr;
  BEGIN
	Print('^0This question will be asked should you ever forget your password.');
	NL;
	Print(General.ForgotPWQuestion);
	Prt(': ');
	MPL(40);
	Input(TempForgotPWAnswer,40);
	IF (TempForgotPWAnswer = '') AND ((How = 2) OR (How = 3)) THEN
	  Exit;
	IF (Length(TempForgotPWAnswer) >= 3) THEN
	  BEGIN
		Done1 := TRUE;
		IF (TempForgotPWAnswer <> User.ForgotPWAnswer) AND (How = 2) THEN
		  SysOpLog('Changed forgot password answer');
		User.ForgotPWAnswer := TempForgotPWAnswer;
	  END
	ELSE
	  BEGIN
		Print('^8Forgot password answer must be 3 characters minimum');
	  END;
  END;
  
  PROCEDURE DoAddress;
  VAR
    Counter: Integer;
	IsLetter,
	IsNumber,
	IsSpace: Boolean;
	TempStreet: Str30;
  BEGIN
	IsLetter := FALSE;
	IsNumber := FALSE;
	IsSpace := FALSE; { Reset }
	Prt(lRGLngStr(100,TRUE)); { "Enter your address: " }
	MPL((SizeOf(User.Street) - 1));
	InputCaps(TempStreet,(SizeOf(User.Street) - 1));
	{ Check for "A-Z","0-9"," " }
	{
		There's got to be a way better method of doing this -- please fix
	}
	FOR Counter := 1 TO Length(TempStreet) DO
	  IF (TempStreet[Counter] IN ['A'..'Z']) THEN
		BEGIN
		  IsLetter := TRUE;
		  Break;
		END;
	FOR Counter := 1 TO Length(TempStreet) DO
	  IF (TempStreet[Counter] IN ['0'..'9']) THEN
		BEGIN
		  IsNumber := TRUE;
		  Break;
		END;
	FOR Counter := 1 TO Length(TempStreet) DO
	  IF (TempStreet[Counter] IN [' ']) THEN
		BEGIN
		  IsSpace := TRUE;
		  Break;
		END;
	IF NOT (IsLetter) OR NOT (IsNumber) OR NOT (IsSpace) THEN
	    BEGIN
		  Print('^8Invalid address!'); { "Invalid address" }
		END
	ELSE
	  BEGIN
		IF (How = 2) AND (TempStreet <> User.Street) THEN
		  SysOpLog('Changed address from '+User.Street+' to '+TempStreet);
		User.Street := TempStreet;
		Done1 := TRUE;
	  END;
  END;
  
  PROCEDURE DoCityState;
  VAR
    TempCity,
    TempState: AStr;
  BEGIN
	IF (User.Country = '') AND (How = 1) THEN
	  DoCountry;
	IF ((Pos('United States',User.Country) > 0) OR (Pos('Canada',User.Country) > 0)) THEN
	  BEGIN
		Prt(lRGLngStr(149,TRUE)); { "Enter your city: " }
		MPL(((SizeOf(User.CityState) - 1) - 4));
		InputCaps(TempCity,((SizeOf(User.CityState) - 1) - 4));
		IF (Pos(',',TempCity) <> 0) THEN
		  BEGIN
			NL;
			lRGLngStr(150,FALSE); { "Enter ONLY your city" }
			Exit;
		  END;
		NL;
		IF (Length(TempCity) < 3) THEN
		  BEGIN
			Print('^8Invalid city name'); { "Invalid city name" }
			Exit;
		  END;
		Prt(lRGLngStr(151,TRUE){ "Enter the abbreviation of your " }
		+AOnOff((Pos('United States',User.Country) > 0),lRGLngStr(152,TRUE){ "state: " },lRGLngStr(153,TRUE){" province: " }));
		MPL(2);
		Input(TempState,2);
		IF (Length(TempState) < 2) THEN { LeeW: Also check that its alpha-only }
		  BEGIN
			Print('^8Invalid state/province abbreviation'); { "Invalid state/province name" }
			Exit;
		  END
		ELSE
		  BEGIN
			Done1 := TRUE;
			IF (How = 2) AND (User.CityState <> TempCity+', '+TempState) THEN
			  SysOpLog('Changed City/State from '+User.CityState+' to '+TempCity+', '+TempState);
			User.CityState := TempCity+', '+TempState;
		  END;
	  END
	ELSE
	  BEGIN
		Prt(lRGLngStr(149,TRUE)); { "Enter your city: " }
		MPL(26);
		InputCaps(TempCity,(SizeOf(User.CityState) - 1));
		IF (Length(TempCity) < 2) THEN { LeeW: Also check that its alpha-only }
		  BEGIN
			Print('^8Invalid city name'); { "Invalid city name" }
			Exit;
		  END
		ELSE
		  BEGIN
			Done1 := TRUE;
			IF (How = 2) AND (User.CityState <> TempCity) THEN
			  SysOpLog('Changed City/State from '+User.CityState+' to '+TempCity);
			User.CityState := TempCity;
		END;
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
    END;
	IF (User.Country = ' ') AND (How = 1) THEN
	  DoCountry;
	IF (Pos('United States',User.Country) > 0) OR (Pos('Canada',User.Country) > 0) THEN	
	  BEGIN { If Canada Or United States }
		InputFormatted(lRGLngStr(107,TRUE),TempPhone,'(###)###-####',(How = 3));
		TempPhone := Copy(TempPhone,2,3)+Copy(TempPhone,6,3)+Copy(TempPhone,10,4); { Remove Formatting }
		IF (Length(TempPhone) = 10) THEN
		  BEGIN
			Done1 := TRUE;
			IF (How = 2) AND (User.Ph <> TempPhone) THEN
			  SysOpLog('Changed phone from '+User.Ph+' to '+TempPhone);
			User.Ph := TempPhone;
		  END
		ELSE
		  BEGIN
			Print('^8Invalid phone number');
		  END;
	  END
	ELSE
	  BEGIN { If Other Country }
	    Prt(lRGLngStr(107,TRUE));
		MPL(12);
		Input(TempPhone,12); { LeeW: Should only be accepting numbers }
		IF (Length(TempPhone) > 5) THEN  
		  BEGIN
			Done1 := TRUE;
			IF (How = 2) AND (User.Ph <> TempPhone) THEN
			  SysOpLog('Changed phone from '+User.Ph+' to '+TempPhone);
			User.Ph := TempPhone;
		  END
		ELSE
		  BEGIN
			Print('^8Invalid phone number');
		  END;
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
	  Redo := FALSE;
	  Prt(lRGLngStr(101,TRUE)); { "Enter your birthdate (MM/DD/YYYY): " }
	  InputFormatted('',TempDate,'##/##/####',(How = 3));
	  IF (TempDate <> '') THEN
		BEGIN
		  TempMonth := StrToInt(Copy(TempDate,1,2));
		  TempDay := StrToInt(Copy(TempDate,4,2));
		  TempYear := StrToInt(Copy(TempDate,7,4));
		  IF (TempMonth = 0) OR (TempDay = 0) OR (TempYear = 0) THEN
			Redo := TRUE;
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
			  lRGLngStr(148,FALSE); { "Invalid birthdate" }
			  Exit;
			END
		  ELSE
		    BEGIN
			  Done1 := TRUE;
			  IF (How = 2) (*AND ({ LeeW: How to check for difference? })*) THEN 
				SysOpLog('Changed birthdate from '+PD2Date(User.BirthDate)+' to '+TempDate);
			  User.BirthDate := Date2PD(TempDate);
			END;
		END;
    UNTIL (NOT Redo) OR (HangUp);
  END;
  
  PROCEDURE DoSex;
  VAR
    TempSex: Char;
  BEGIN
	lRGLngStr(121,FALSE); { "(M)ale, (F)emale, or (O)ther/Non-Binary" }
	Prt(lRGLngStr(122,TRUE)); { Prompt }
    IF (How = 3) OR (How = 2) THEN
	  OneK(TempSex,'MFO'^M,TRUE,TRUE)
    ELSE
	  OneK(TempSex,'MFO',TRUE,TRUE);
	IF (TempSex IN ['M','F','O']) THEN
	  BEGIN
		Done1 := TRUE;
		IF (User.Sex <> TempSex) AND (How = 2) THEN
		  SL1(User.Name+' changed their gender from '+User.Sex+' to '+TempSex);
		User.Sex := TempSex;
	  END;
  END;
  
  PROCEDURE DoZipCode;
  VAR
    TempZipCode: Str10;
  BEGIN
	IF User.Country = '' THEN 
	  DoCountry;
	IF (Pos('United States',User.Country) > 0) THEN
	  BEGIN
		Prt(lRGLngStr(123,TRUE)); { "Enter your zip code (#####-####): " }
		InputFormatted('',TempZipCode,'#####-####',(How = 3));
	  END
	ELSE IF (Pos('Canada',User.Country) > 0) THEN
      BEGIN
		Prt(lRGLngStr(124,TRUE)); { "Enter your postal code (LNLNLN): " }
		InputFormatted('',TempZipCode,'@#@#@#',(How = 3));
	  END
	ELSE
	  BEGIN
		Prt(lRGLngStr(125,TRUE)); { "Enter your postal code: " }
		MPL((SizeOf(User.ZipCode) - 1));
		Input(TempZipCode,(SizeOf(User.ZipCode) - 1));
	  END;
	IF (Length(TempZipCode) > 2) AND (TempZipCode <> '') THEN 
	  BEGIN
		Done1 := TRUE;
		IF (User.ZipCode <> TempZipCode) AND (How = 2) THEN
		  SL1(User.Name+' changed their zip/postal code from '+User.ZipCode+' to '+TempZipCode);
		User.ZipCode := TempZipCode;		
	  END;
  END;
  
  PROCEDURE DoTermEmu;
  VAR
    Cmd: Char;
  BEGIN
    PrintF('TERMINAL');
	lRGLngStr(126,FALSE); { "(1) None (2) ANSI (3) Avatar (4) VT-100 (5) RIP" }
	Prt(lRGLngStr(127,TRUE)); { Prompt }
    
	If (How = 2) OR (How = 3) THEN
	  OneK(Cmd,'12345'^M,TRUE,TRUE)
	ELSE 
	  OneK(Cmd,'12345',TRUE,TRUE);
	
    Exclude(User.Flags,ANSI);
    Exclude(User.Flags,Avatar);
    Exclude(User.Flags,VT100);
    Exclude(User.Flags,RIP);
    CASE Cmd OF
      '2' : BEGIN
			  Include(User.Flags,ANSI);
			END;
      '3' : BEGIN
              Include(User.Flags,Avatar);
              NL;
              IF PYNQ(lRGLngStr(128,TRUE){ "Does your terminal client support ANSI fallback?" },0,TRUE) THEN
                Include(User.Flags,ANSI);
            END;
      '4' : BEGIN
			  Include(User.Flags,VT100);
			END;
      '5' : BEGIN
              Include(User.Flags,ANSI);
              Include(User.Flags,RIP);
            END;
    END;
    NL;
	IF Cmd <> ^M THEN
	  BEGIN
		IF (PYNQ(lRGLngStr(129,TRUE){ "Would you like this auto-detected in the future?" },0,TRUE)) THEN
		  Include(User.Flags,AutoDetect)
		ELSE
		  Exclude(User.Flags,AutoDetect);
		Done1 := TRUE;
	  END;
	{ LeeW: Enable or disable fullscreen editor based on terminal emulation }
    IF (ANSI IN User.Flags) OR {(Avatar IN User.Flags) OR} (VT100 IN User.Flags) THEN
      Include(User.Flags,FSEditor)
    ELSE
      Exclude(User.Flags,FSEditor);
	{ LeeW: how to do sysoplog for this one? }
  END;
  
  PROCEDURE DoUserDef(QuestionNum: Byte);
  VAR
    UserDefQues: STRING[80];
    s: Str35;
  BEGIN
    CASE QuestionNum OF
      1 : UserDefQues := lRGLngStr(38,TRUE); 
      2 : UserDefQues := lRGLngStr(39,TRUE); 
      3 : UserDefQues := lRGLngStr(40,TRUE); 
    END;
    IF (UserDefQues = '') THEN
    BEGIN
      User.UsrDefStr[QuestionNum] := '';
      Done1 := TRUE;
      Exit;
    END;
    Print(UserDefQues);
    Prt(': '); {tolang}
    MPL((SizeOf(User.UsrDefStr[QuestionNum]) - 1));
    InputL(s,(SizeOf(User.UsrDefStr[QuestionNum]) - 1));
    IF (s <> '') THEN
    BEGIN
      User.UsrDefStr[QuestionNum] := s;
      Done1 := TRUE;
	  {add sysoplog}
    END;
  END;
  
  PROCEDURE Toggle_LightBars;
  BEGIN
    IF (NOT General.UseLightBars) THEN
    BEGIN
      NL;
      Print('^0SysOp has disabled lightbars');
    END
    ELSE
    BEGIN
      IF (UseLightBars IN ThisUser.Flags) THEN
      BEGIN
        Exclude(ThisUser.Flags,UseLightBars);
        Print('^0Lightbars disabled');
		SysOpLog(User.Name+' disabled lightbars');
      END
      ELSE
      BEGIN
        Include(ThisUser.Flags,UseLightBars);
        Print('^0Lightbars enabled');
		SysOpLog(User.Name+' enabled lightbars');
      END;
    END;
    Done1 := TRUE;
  END;
  
  Procedure Toggle_Color;
  (*
  LeeW: Text color bug happening if select no -- investigate 
  *)
  Begin
    If How = 2 Then
      Begin
        IF (Color In User.Flags) Then
          Begin
			Exclude(User.Flags,Color);
			lRGLngStr(132,FALSE); { "ANSI color disabled" }
			SysOpLog(User.Name+' disabled ansi color');
          End
        Else
          Begin
			Include(User.Flags,Color);
			lRGLngStr(131,FALSE); { "ANSI color enabled" }
			SysOpLog(User.Name+' enabled ansi color');
          End;
	  End
    Else
      Begin
        If PYNQ(lRGLngStr(130,TRUE){ "Enable ANSI colors?" },0,True) Then
          Include(User.Flags,Color)
        Else
          Exclude(User.Flags,Color);
      End;
	Done1 := TRUE;
  End;

  Procedure Toggle_Editor;
	Begin
	  If How = 2 Then
		BEGIN
		  If (Not (ANSI In User.Flags)) And (Not (Avatar In User.Flags)) Then
			Begin
			  lRGLngStr(133,FALSE); { "Your terminal client must support ANSI to use the fullscreen editor" }
			  Exclude(User.Flags,FSEditor);
			  SysOpLog(User.Name+' couldn''t enable fullscreen editor because they don''t support ANSI emulation');
			  {Exit;}
			End;
		  If (FSEditor In User.Flags) Then
			Begin
			  Exclude(User.Flags,FSEditor);
			  lRGLngStr(134,FALSE); { "Line editor enabled" }
			  SysOpLog(User.Name+' enabled line editor');
			End
		  Else
			Begin
			  Include(User.Flags,FSEditor);
			  lRGLngStr(135,FALSE); { "Fullscreen editor enabled" }
			  SysOpLog(User.Name+' enabled fullscreen editor');
			End;
		END
	  Else
		Begin
		  If PYNQ('^0Use fullscreen editor? '{ "Use fullscreen editor?" },0,True) Then
		   Include(User.Flags,FSEditor)
		  Else
			Exclude(User.Flags,FSEditor);
		End;
	  Done1 := True;
	End;
 
  Procedure Toggle_Pause;
    Begin
      If How = 2 Then
        Begin
          If (Pause In User.Flags) Then
            Begin
              Exclude(User.Flags,Pause);
			  lRGLngStr(138,FALSE); { "Screen pausing disabled" }
			  SysOpLog(User.Name+' enabled screen pausing');
            End
          Else
            Begin
              Include(User.Flags,Pause);
			  lRGLngStr(137,FALSE); { "Screen pausing enabled" }
			  SysOpLog(User.Name+' disabled screen pausing');
            End;
          Done1 := True;
        End
      Else
        Begin
          If PYNQ(lRGLngStr(136,TRUE){ "Pause after each screen?" },0,True) Then
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
			  lRGLngStr(147,FALSE); { "Full line input enabled" }
			  SysOpLog(User.Name+' enabled full line input');
            End
          Else
            Begin
              Include(User.Flags,HotKey);
			  lRGLngStr(146,FALSE); { "Hotkeys enabled" }
			  SysOpLog(User.Name+' enabled hotkeys');
            End;
          Done1 := True;
        End
      Else
        Begin
          If PYNQ(lRGLngStr(145,TRUE){ "Do you want to use hotkeys?" },0,True) Then
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
			  lRGLngStr(143,FALSE); { "Expert mode enabled" }
			  SysOpLog(User.Name+' enabled expert mode');
            End
          Else
            Begin
              Include(User.Flags,Novice);
              CurHelpLevel := 2;
			  lRGLngStr(144,FALSE); { "Expert mode disabled" }
			  SysOpLog(User.Name+' disabled expert mode');
            End;
          Done1 := True;
        End
      Else
        Begin
          If PYNQ(lRGLngStr(142,TRUE){ "Do you want to be in expert mode?" },0,False) Then
		    BEGIN
			  CurHelpLevel := 1;
			  Exclude(User.Flags,Novice);
			END
          Else
		    BEGIN
			  CurHelpLevel := 2;
              Include(User.Flags,Novice);
			END;
          Done1 := True;
        End
    End;
  
  Procedure Toggle_Clear;
    Begin
      If How = 2 Then
        Begin
          If (CLSMsg In User.Flags) Then
            Begin
              Exclude(User.Flags,CLSMsg);
			  lRGLngStr(141,FALSE); { "Screen clearing disabled" }
			  SysOpLog(User.Name+' disabled screen clearing');
            End
          Else
            Begin
              Include(User.Flags,CLSMsg);
			  lRGLngStr(140,FALSE); { "Screen clearing enabled" }
			  SysOpLog(User.Name+' enabled screen clearing');
            End;
          Done1 := True;
        End
      Else
        Begin
          If PYNQ(lRGLngStr(139,TRUE){ "Clear screen before each message read?" },0,True) Then
            Include(User.Flags,CLSMsg)
          ELSE
            Exclude(User.Flags,CLSMsg);
          Done1 := True;
        End
    End;
  
  { ------------------------------------------------------------------- }
  
  PROCEDURE WW(www: Byte);
  BEGIN
    NL;
    CASE www OF
        01 : DoName;            { Handle, Or Real Name *MANDATORY* }
        02 : DoRealName;        { Real Name }
        03 : DoCountry;         { Country }
        04 : DoCityState;       { City State }
        05 : DoAddress;         { Address }
        06 : DoZipCode;         { Zip Code }
        07 : DoPhone;           { Phone Number }
        08 : DoAge;             { Birthdate }
        09 : DoSex;             { Gender Identity }
        10 : DoUserDef(1);      { SysOp Defined Question #1 }
        11 : DoUserDef(2);      { SysOp Defined Question #2 }
        12 : DoUserDef(3);      { SysOp Defined Question #3 }
        13 : DoTermEmu;         { Terminal Emulation }
        14 : Toggle_Color;      { ANSI Colors }
        15 : DoColorScheme;     { Color Scheme }
        16 : DoScreen;          { Screen Size }
        17 : Toggle_Clear;      { Screen Clearing }
        18 : Toggle_Pause;      { Screen Pause }
        19 : Toggle_HotKey;     { Hot Keys }
        20 : Toggle_Expert;		{ FIX THIS!!!!!!!!!!!!!!!!!!!!!!!!!!!}
        21 : Toggle_Expert;     { Expert Mode }
        22 : DoPW;              { Password *MANDATORY* }
        23 : DoForgotPW;        { Forgot Password Answer }

{       Commands above can be toggled on or off for new user application,
        Commands below are accessible through account settings menu and user editor }

        24 : Mailbox;			{ Mailbox / Mail Forwarding }
        25 : Toggle_Editor;		{ Fullscreen Or Line Editor }
        26 : Toggle_LightBars;	{ Use LightBars? }
		27 : ConfigureQWK;      { QWK Configuration }
		28 : PauseScr(FALSE);	{ }
		29 : PauseScr(FALSE);	{ }
		30 : PauseScr(FALSE);	{ }
    END;
  END;
  
  { // }
  
BEGIN
  Tries := 0;
  Done1 := FALSE;
  CASE How OF
    1 : REPEAT { 1 = New User Application }
          WW(Which);
		  Inc(Tries);
		  IF (Tries >= 5) THEN { make this custo }
		    BEGIN
			  NL;
			  Print('^8Exceeded maximum number of retries. Disconnecting.'); { this too }
			  HangUp := TRUE;
		  END;
        UNTIL (Done1) OR (HangUp);
    2,3 :
        BEGIN { 2 = Menu Command "OP", 3 = User Editor, Maint }
          WW(Which);
          IF (NOT Done1) THEN
            Print('^8Function aborted!');
		  PauseScr(FALSE);
        END;
  END;
END;

END.