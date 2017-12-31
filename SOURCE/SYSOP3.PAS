{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}
{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  USER EDITOR
  ======================================================================
    [TODO]
	  - Blink LOCK and DEL tag in header
	  - sysop note input field
	  - postal code should have space
	  - ph num formatting
      - Preference Records: Change conference not working, should add it to CUser
	  - Add a few pieces of info to records (uploaded #/k etc..)
	[ISSUES]
	  - 
}

UNIT SysOp3;

INTERFACE

USES
Crt,
Common;

PROCEDURE ShowUserInfo(DisplayType: Byte; UNum: Integer; CONST User: UserRecordType);
PROCEDURE UserEditor(UNum: Integer);

IMPLEMENTATION

USES
  CUser,	{ New User Data Input }
  Mail0,	{  }
  Script,	{  }
  ShortMsg,	{  }
  SysOp2G,	{ Subscription/Validation Configuration }
  SysOp7,	{  }
  SysOp12,	{ Conferences }
  TimeFunc,	{ Date & Time Functions }
  MiscUser;	{  }

FUNCTION DisplayTerminalStr(StatusFlags: StatusFlagSet; Flags: FlagSet): Str8;
VAR
  TempS: Str8;
BEGIN
  IF (AutoDetect IN Flags) THEN { LeeW: Should show all? Or like "ANSI/Auto" }
    TempS := 'Auto'
  ELSE IF (RIP IN Flags) THEN
    TempS := 'RIP'
  ELSE IF (Avatar IN Flags) THEN
    TempS := 'Avatar'
  ELSE IF (ANSI IN Flags) THEN
    TempS := 'ANSI'
  ELSE IF (VT100 IN Flags) THEN {LeeW: Was using OKVT100, FIXED }
    TempS := 'VT-100'
  ELSE
    TempS := 'None';
  DisplayTerminalStr := TempS;
END;

FUNCTION DisplayGenderStr(Gender: Char): Str20;
VAR
  TempS: Str8;
BEGIN
  CASE Gender OF
  'M' : DisplayGenderStr := 'Male';
  'F' : DisplayGenderStr := 'Female';
  'O' : DisplayGenderStr := 'Other';
  END;
END;

PROCEDURE ShowUserInfo(DisplayType: Byte; UNum: Integer; CONST User: UserRecordType);
VAR
  Counter: Byte;

  PROCEDURE ShowUser(VAR Counter1: Byte);
  VAR
    S,
	S2: AStr;
  BEGIN
	S2 := '';
	IF (LockedOut IN user.SFlags) THEN
	  BEGIN
		{ blink damnit! }
	    S2 := S2+'[LOCK] ';
	  END;
	IF (Deleted IN user.SFlags) THEN
	  S2 := S2+'[DEL] ';
    WITH User DO
      CASE Counter1 OF
        1 : BEGIN
              IF (UNum = 0) THEN
                S := 'New User Configuration'
              ELSE
              BEGIN
                S := '#'+IntToStr(UNum)+' (Of '+IntToStr(MaxUsers - 1)+') ';
                IF NOT (OnNode(UNum) IN [0,ThisNode]) THEN
                  S := S+'[ On Node '+IntToStr(OnNode(UNum))+' ]'; { LeeW: Test this }
              END;
			  S := PadLeftStr('^2 '#240' User Editor : '+ S,65)+PadRightStr(S2,15);
            END;
        2 : S := '^1A^0'#242' User Name  : ^1'+PadLeftStr(Name,28)+				 															
				 '^1L^0'#242' Security   : ^1'+PadLeftStr(IntToStr(SL),19);
        3 : S := '^1B^0'#242' Real Name  : ^1'+PadLeftStr(RealName,28)+																		
				 '^1M^0'#242' D Security : ^1'+IntToStr(DSL);
		4 : S := '^1P^0'#242' Gend/Bdate : ^1'+PadLeftStr(DisplayGenderStr(Sex)+'^0 / ^1'+ToDate82(PD2Date(BirthDate))+
				 '^0 (^1'+IntToStr(AgeUser(BirthDate))+'^0)',28)+
				 '^1N^0'#242' AR : ^1'+DisplayARFlags(AR,'1','0');
        5 : S := '^1K^0'#242' Country    : ^1'+PadLeftStr(Country,28)+				 														
				 '^1O^0'#242' AC : ^1'+DisplayACFlags(Flags,'1','0');
        6 : S := '^1D^0'#242' City/State : ^1'+PadLeftStr(CityState,28)+				 													
				 '^1R^0'#242' Phone Num  : ^1'+PadLeftStr(PH,19);
        7 : S := '^1E^0'#242' Zip Code   : ^1'+PadLeftStr(ZipCode,28)+				 														
				 '^1X^0'#242' Caller ID  : ^1'+PadLeftStr(CallerID,19);
        8 : S := '^1C^0'#242' Address    : ^1'+PadLeftStr(Street,28)+				 														
				 '^1W^0'#242' Password   : ^8[NOT SHOWN]';
	    9 : S := '^1G^0'#242' '+PadLeftStr(lRGLngStr(41,TRUE),10)+' : ^1'+PadLeftStr(UsrDefStr[1],28)+
				 ''+PadLeftStr('',19);
	   10 : S := '^1H^0'#242' '+PadLeftStr(lRGLngStr(42,TRUE),10)+' : ^1'+PadLeftStr(UsrDefStr[2],28)+
				 ''+PadLeftStr('',19);
       11 : S := '^1I^0'#242' '+PadLeftStr(lRGLngStr(43,TRUE),10)+' : ^1'+PadLeftStr(UsrDefStr[3],28)+
				 ''+PadLeftStr('',19);
       12 : S := '^1Z^0'#242' Forgot PW  : ^1'+PadLeftStr(ForgotPWAnswer,28)+
				 ''+PadLeftStr('',19);
       13 : S := '^1F^0'#242' SysOp Note : ^1'+PadLeftStr(Note,28)+
				 ''+PadLeftStr('',19);
	   14 : BEGIN
			  S := '';
			  IF (TrapActivity IN SFlags) AND ((UNum <> UserNum) OR (UserNum = 1)) THEN
				IF (TrapSeparate IN SFlags) THEN
				  S := S + '^8[ACT/S] '
				ELSE
                S := S + '^8[ACT] '
			  ELSE
				S := S + '^0[ACT] ';
			  IF (ChatAuto IN SFlags) AND ((UNum <> UserNum) OR (UserNum = 1)) THEN
				IF (ChatSeparate IN SFlags) THEN
				  S := S + '^8[CHT/S] '
				ELSE
                  S := S + '^8[CHT] '
                ELSE
                  S := S + '^0[CHT] ';
			  IF (Alert IN SFlags) AND ((UNum <> UserNum) OR (UserNum = 1)) THEN
				S := S+'^8[ALERT] '
			  ELSE
				S := S+'^0[ALERT] ';
              S := '^1J^0'#242' Log/Alert  : ^1'+PadLeftStr(S,28)+
			  ''+PadLeftStr('',19);
				   
            END;
	   15 : S := ''; { Spacer }
       16 : S := '^11^0'#242' Call Records - TC: ^1'+PadLeftInt(LoggedOn,8)+
										 ' ^0TT: ^1'+PadLeftInt(TTimeOn,8)+
										 ' ^0CT: ^1'+PadLeftInt(OnToday,8)+
										 ' ^0TL: ^1'+PadLeftInt(TLToday,8)+
										 ' ^0TB: ^1'+PadLeftInt(TimeBank,5);
       17 : S := '^12^0'#242' Mail Records - PB: ^1'+PadLeftInt(MsgPost,8)+
										 ' ^0PV: ^1'+PadLeftInt(EmailSent,8)+
										 ' ^0FB: ^1'+PadLeftInt(FeedBack,8)+
										 ' ^0WT: ^1'+PadLeftInt(Waiting,5);
       18 : S := '^13^0'#242' File Records - DL: ^1'+PadLeftStr(IntToStr(Downloads)+' ^0/ ^1'+FormatNumber(DK)+'^0K',21)+
										 ' ^0UL: ^1'+PadLeftStr(IntToStr(Uploads)+' ^0/ ^1'+FormatNumber(UK)+'^0K',21)+
										 ' ^0FP: ^1'+PadLeftInt(FilePoints,5);
       19 : S := '^14^0'#242' Pref Records - EM: ^1'+PadLeftStr(DisplayTerminalStr(SFlags,Flags),8)+
										 ' ^0CS: ^1'+PadLeftStr(ShowYesNo(CLSMsg IN Flags),8)+
										 ' ^0PS: ^1'+PadLeftStr(ShowYesNo(Pause IN Flags),8)+
										 ' ^0CL: ^1'+PadLeftStr(ShowYesNo(Color IN Flags),8)+
										 ' ^0ED: ^1'+PadLeftStr(AOnOff((FSEditor IN Flags),'F/S','Line'),5);
       20 : S := '^15^0'#242' Subs Records - CR: ^1'+PadLeftInt(lCredit,8)+
										 ' ^0DB: ^1'+PadLeftInt(Debit,8)+
										 ' ^0BL: ^1'+PadLeftInt(lCredit - Debit,8)+
										 ' ^0ED: ^1'+PadLeftStr(AOnOff(Expiration <> 0,ToDate8(PD2Date(Expiration)),'Never'),8)+
										 ' ^0ET: ^1'+PadLeftStr(AOnOff(ExpireTo <> ' ',ExpireTo,'None'),5);
      END;
    PrintACR(S);
    Inc(Counter1);
  END;

BEGIN
  Abort := FALSE;
  Next := FALSE;
  CLS;
  Counter := 1;
  CASE DisplayType OF
    1 : WHILE (Counter <= 5) AND (NOT Abort) AND (NOT HangUp) DO
          ShowUser(Counter);
    2 : WHILE (Counter <= 14) AND (NOT Abort) AND (NOT HangUp) DO
          ShowUser(Counter);
    3 : WHILE (Counter <= 20) AND (NOT Abort) AND (NOT HangUp) DO
          ShowUser(Counter);
  END;
END;

PROCEDURE UserEditor(UNum: Integer);
TYPE
  F_StatusFlagsRec = (FS_Deleted,FS_Trapping,FS_ChatBuffer,FS_LockedOut,FS_Alert,FS_SLogging);
CONST
  AutoList: Boolean = TRUE;
  UserInfoTyp: Byte = 3;
  F_State: ARRAY [0..14] OF Boolean = (FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,
                                       FALSE,FALSE,FALSE,FALSE,FALSE,FALSE,FALSE);
  F_GenText: STRING[40] = '';
  F_ACS: STRING[20] = '';
  F_SL1: Byte = 0;
  F_SL2: Byte = 255;
  F_DSL1: Byte = 0;
  F_DSL2: Byte = 255;
  F_AR: ARFlagSet = [];
  F_AC: FlagSet = [];
  F_Status: SET OF F_StatusFlagsRec = [];
  F_LastOn1: LongInt = 0;
  F_LastOn2: LongInt = $FFFFFFF;
  F_FirstOn1: LongInt = 0;
  F_FirstOn2: LongInt = $FFFFFFF;
  F_NumCalls1: LongInt = 0;
  F_NumCalls2: LongInt = 2147483647;
  F_Age1: Byte = 0;
  F_Age2: Byte = 255;
  F_Gender: Char = 'M';
  F_PostRatio1: LongInt = 0;
  F_PostRatio2: LongInt = 2147483647;
  F_DLKRatio1: LongInt = 0;
  F_DLKRatio2: LongInt = 2147483647;
  F_DLRatio1: LongInt = 0;
  F_DLRatio2: LongInt = 2147483647;
VAR
  User: UserRecordType;
  TempStr: AStr;
  Cmd: Char;
  TempB,
  Counter: Byte;
  UNum1,
  SaveUNum,
  TempMaxUsers,
  RecNumToList: Integer;
  Changed,
  Save,
  Save1,
  Ok: Boolean;

  FUNCTION SearchType(SType: Byte): AStr;
  BEGIN
    CASE SType OF
      0 : SearchType := 'General Text';
      1 : SearchType := 'Search ACS';
      2 : SearchType := 'User SL';
      3 : SearchType := 'User DSL';
      4 : SearchType := 'User AR Flags';
      5 : SearchType := 'User AC Flags';
      6 : SearchType := 'User Status';
      7 : SearchType := 'Date Since Last On';
      8 : SearchType := 'Date Since First On';
      9 : SearchType := 'Number Of Calls';
     10 : SearchType := 'User Age';
     11 : SearchType := 'User Gender';
     12 : SearchType := '# 1/10''s Call/Post';
     13 : SearchType := '#K DL/1K UL';
     14 : SearchType := '# DL/1 UL';
    END;
  END;

  FUNCTION Find_FS: AStr;
  VAR
    FSF: F_StatusFlagsRec;
    TempStr1: AStr;
  BEGIN
    TempStr1 := '';
    FOR FSF := FS_Deleted TO FS_SLogging DO
      IF (FSF IN F_Status) THEN
        CASE FSF OF
          FS_Deleted   : TempStr1 := TempStr1 +'^1Deleted^0, ';
          FS_Trapping  : TempStr1 := TempStr1 +'^1Trapping^0, ';
          FS_ChatBuffer: TempStr1 := TempStr1 +'^1Chat Buffering^0, ';
          FS_LockedOut : TempStr1 := TempStr1 +'^1Locked Out^0, ';
          FS_Alert     : TempStr1 := TempStr1 +'^1Alert^0, ';
          FS_SLogging  : TempStr1 := TempStr1 +'^1Sep. SysOp Log^0, ';
        END;
    IF (TempStr1 <> '') THEN
      TempStr1 := Copy(TempStr1,1,(Length(TempStr1) - 2))
    ELSE
      TempStr1 := '^1None^0';
    Find_FS := TempStr1;
  END;

  PROCEDURE DisplaySearchOptions;
  VAR
    TempStr1: AStr;
    Cmd1: Char;
    Counter1: Byte;
  BEGIN
  Cls;
    Print('^0Search Criterea:');
    NL;
    Abort := FALSE;
    Next := FALSE;
    Counter1 := 0;
    WHILE ((Counter1 <= 14) AND (NOT Abort) AND (NOT HangUp)) DO
    BEGIN
      CASE Counter1 OF
        0..9 :
             Cmd1 := Chr(Counter1 + 48);
        10 : Cmd1 := 'A';
        11 : Cmd1 := 'G';
        12 : Cmd1 := 'P';
        13 : Cmd1 := 'K';
        14 : Cmd1 := 'N';
      END;
      Prompt('^0(^1'+Cmd1+'^0'#242' '+PadLeftStr(SearchType(Counter1),19)+': ');
      TempStr1 := '';
      IF (NOT F_State[Counter1]) THEN
        TempStr1 := '^8<INACTIVE>'
      ELSE
      BEGIN
        CASE Counter1 OF
          0 : TempStr1 := '^0"^1'+F_GenText+'^0"';
          1 : TempStr1 := '^0"^1'+F_ACS+'^0"';
          2 : TempStr1 := '^1'+IntToStr(F_SL1)+'^0 - ^1'+IntToStr(F_SL2)+'^0 SL';
          3 : TempStr1 := '^1'+IntToStr(F_DSL1)+'^0 - ^1'+IntToStr(F_DSL2)+'^0 DSL';
          4 : TempStr1 := '^1'+DisplayARFlags(F_AR,'1','0');
          5 : TempStr1 := '^1'+DisplayACFlags(F_AC,'1','0');
          6 : TempStr1 := '^1'+Find_FS;
          7 : TempStr1 := '^1'+PD2Date(F_LastOn1)+'^0 - ^1'+PD2Date(F_LastOn2);
          8 : TempStr1 := '^1'+PD2Date(F_FirstOn1)+'^0 - ^1'+PD2Date(F_FirstOn2);
          9 : TempStr1 := '^1'+IntToStr(F_NumCalls1)+'^0 - ^1'+IntToStr(F_NumCalls2)+'^0 Calls';
         10 : TempStr1 := '^1'+IntToStr(F_Age1)+'^0 - ^1'+IntToStr(F_Age2)+'^0 Years Old';
         11 : BEGIN
				CASE F_Gender OF
				'M' : TempStr1 := '^0Male';
				'F' : TempStr1 := '^0Female';
				'O' : TempStr1 := '^0Other';
				END;
			  END;
         12 : TempStr1 := '^1'+IntToStr(F_PostRatio1)+'^0 - ^1'+IntToStr(F_PostRatio2);
         13 : TempStr1 := '^1'+IntToStr(F_DLKRatio1)+'^0 - ^1'+IntToStr(F_DLKRatio2);
         14 : TempStr1 := '^1'+IntToStr(F_DLRatio1)+'^0 - ^1'+IntToStr(F_DLRatio2);
        END;
        {UserColor(3);}
      END;
      Print(TempStr1);
      WKey;
      Inc(Counter1);
    END;
  END;

  FUNCTION OKUser(UNum1: Integer): Boolean;
  VAR
    FSF: F_StatusFlagsRec;
    User1: UserRecordType;
    Counter1: Byte;
    TempL: LongInt;
    Ok1: Boolean;

    FUNCTION NoFindIt(TempStr1: AStr): Boolean;
    BEGIN
      NoFindIt := (Pos(AllCaps(F_GenText),AllCaps(TempStr1)) = 0);
    END;

  BEGIN
    WITH User1 DO
    BEGIN
      LoadURec(User1,UNum1);
      Ok1 := TRUE;
      Counter1 := 0;
      WHILE ((Counter1 <= 14) AND (Ok1)) DO
      BEGIN
        IF (F_State[Counter1]) THEN
          CASE Counter1 OF
            0 : IF ((NoFindIt(Name)) AND (NoFindIt(RealName)) AND
                   (NoFindIt(Street)) AND (NoFindIt(CityState)) AND
                   (NoFindIt(ZipCode)) AND (NoFindIt(UsrDefStr[1])) AND
                   (NoFindIt(Ph)) AND (NoFindIt(Note)) AND
                   (NoFindIt(UsrDefStr[2])) AND (NoFindIt(UsrDefStr[3]))) THEN
                  Ok1 := FALSE;
            1 : IF (NOT AACS1(User1,UNum1,F_ACS)) THEN
                  Ok1 := FALSE;
            2 : IF ((SL < F_SL1) OR (SL > F_SL2)) THEN
                  Ok1 := FALSE;
            3 : IF ((DSL < F_DSL1) OR (DSL > F_DSL2)) THEN
                  Ok1 := FALSE;
            4 : IF (NOT (AR >= F_AR)) THEN
                  Ok1 := FALSE;
            5 : IF (NOT (Flags >= F_AC)) THEN
                  Ok1 := FALSE;
            6 : FOR FSF := FS_Deleted TO FS_SLogging DO
                  IF (FSF IN F_Status) THEN
                    CASE FSF OF
                      FS_Deleted    : IF NOT (Deleted IN User1.SFlags) THEN
                                        Ok1 := FALSE;
                      FS_Trapping   : IF NOT (TrapActivity IN User1.SFlags) THEN
                                        Ok1 := FALSE;
                      FS_ChatBuffer : IF NOT (ChatAuto IN User1.SFlags) THEN
                                        Ok1 := FALSE;
                      FS_LockedOut  : IF NOT (LockedOut IN User1.SFlags) THEN
                                        Ok1 := FALSE;
                      FS_Alert      : IF NOT ((Alert IN SFlags)) THEN
                                        Ok1 := FALSE;
                      FS_SLogging   : IF NOT (SLogSeparate IN User1.SFlags) THEN
                                        Ok1 := FALSE;
                    END;
            7 : IF ((LastOn < F_LastOn1) OR (LastOn > F_LastOn2)) THEN
                  Ok1 := FALSE;
            8 : IF ((FirstOn < F_FirstOn1) OR (FirstOn > F_FirstOn2)) THEN
                  Ok1 := FALSE;
            9 : IF ((LoggedOn < F_NumCalls1) OR (LoggedOn > F_NumCalls2)) THEN
                  Ok1 := FALSE;
           10 : IF (((AgeUser(BirthDate) < F_Age1) OR (AgeUser(BirthDate) > F_Age2)) AND (AgeUser(BirthDate) <> 0)) THEN
                  Ok1 := FALSE;
           11 : IF (Sex <> F_Gender) THEN
                  Ok1 := FALSE;
           12 : BEGIN
                  IF (LoggedOn > 0) THEN
                    TempL := LoggedOn
                  ELSE
                    TempL := 1;
                  TempL := ((MsgPost DIV TempL) * 100);
                  IF ((TempL < F_PostRatio1) OR (TempL > F_PostRatio2)) THEN
                    Ok1 := FALSE;
                END;
           13 : BEGIN
                  IF (UK > 0) THEN
                    TempL := UK
                  ELSE
                    TempL := 1;
                  TempL := (DK DIV TempL);
                  IF ((TempL < F_DLKRatio1) OR (TempL > F_DLKRatio2)) THEN
                    Ok1 := FALSE;
                END;
           14 : BEGIN
                  IF (Uploads > 0) THEN
                    TempL := Uploads
                  ELSE
                    TempL := 1;
                  TempL := (Downloads DIV TempL);
                  IF ((TempL < F_DLRatio1) OR (TempL > F_DLRatio2)) THEN
                    Ok1 := FALSE;
                END;
          END;
        Inc(Counter1);
      END;
    END;
    OKUser := Ok1;
  END;

  PROCEDURE Search(i: Integer);
  VAR
    n,
    TempMaxUsers: Integer;
  BEGIN
    Prompt('^0Searching ... ');
    Reset(UserFile);
    TempMaxUsers := (MaxUsers - 1);
    n := UNum;
    REPEAT
      Inc(UNum,i);
      IF (UNum < 1) THEN
        UNum := TempMaxUsers;
      IF (UNum > TempMaxUsers) THEN
        UNum := 1;
    UNTIL ((OKUser(UNum)) OR (UNum = n));
    Close(UserFile);
  END;

  PROCEDURE Clear_F;
  VAR
    Counter1: Byte;
  BEGIN
    FOR Counter1 := 0 TO 14 DO
      F_State[Counter1] := FALSE;
    F_GenText := '';
    F_ACS := '';
    F_SL1 := 0;
    F_SL2 := 255;
    F_DSL1 := 0;
    F_DSL2 := 255;
    F_AR := [];
    F_AC := [];
    F_Status := [];
    F_LastOn1 := 0;
    F_LastOn2 := $FFFFFFF;
    F_FirstOn1 := 0;
    F_FirstOn2 := $FFFFFFF;
    F_NumCalls1 := 0;
    F_NumCalls2 := 2147483647;
    F_Age1 := 0;
    F_Age2 := 255;
    F_Gender := 'M';
    F_PostRatio1 := 0;
    F_PostRatio2 := 2147483647;
    F_DLKRatio1 := 0;
    F_DLKRatio2 := 2147483647;
    F_DLRatio1 := 0;
    F_DLRatio2 := 2147483647;
  END;

  PROCEDURE UserSearch;
  VAR
    User1: UserRecordType;
    FSF: F_StatusFlagsRec;
    TempStr1: AStr;
    Cmd1: Char;
    SType,
    UNum1,
    UserCount: Integer;
    Changed1: Boolean;
  BEGIN
    REPEAT
	  DisplaySearchOptions;
      NL;
      Prt('^0Enter Selection [(^1?^0'#242'Help,(^1Q^0'#242'uit]: ');
      OneK(Cmd1,'Q0123456789AGPKNCLTU?',TRUE,TRUE);
      NL;
      CASE Cmd1 OF
        '0'..'9' :
              SType := (Ord(Cmd1) - 48);
        'A' : SType := 10;
        'G' : SType := 11;
        'P' : SType := 12;
        'K' : SType := 13;
        'N' : SType := 14;
      ELSE
        SType := -1;
      END;
      IF (SType <> -1) THEN
      BEGIN
        {Prompt('^3[> ^1');}
        IF (F_State[SType]) THEN
          {Print(SearchType(SType))}
        ELSE
        BEGIN
          F_State[SType] := TRUE;
          {Print(SearchType(SType)+' is now enabled');}
        END;
      END;
      CASE Cmd1 OF
        '0' : BEGIN
                Print('^0Enter the text that you would like to search for: '); {["'+F_GenText+'"]}
                {Prt('^1: ');}
                MPL(40);
                Input(TempStr1,40);
                IF Length(TempStr1)<>0 THEN
                  F_GenText := TempStr1;
              END;
        '1' : BEGIN
                Print('Search ACS ["'+F_ACS+'"]');
                Prt(': ');
                MPL(20);
                InputL(TempStr1,20);
                IF (TempStr1 <> '') THEN
                  F_ACS := TempStr1;
              END;
        '2' : BEGIN
				Print('SL');
                InputByteWOC('Lower limit',F_SL1,[DisplayValue,NumbersOnly],0,255);
                InputByteWOC('%LFUpper limit',F_SL2,[DisplayValue,NumbersOnly],(0 + F_SL1),255);
              END;
        '3' : BEGIN
				Print('DSL');
                InputByteWOC('Lower limit',F_DSL1,[DisplayValue,NumbersOnly],0,255);
                InputByteWOC('%LFUpper limit',F_DSL2,[DisplayValue,NumbersOnly],(0 + F_DSL1),255);
              END;
        '4' : BEGIN
                REPEAT
                  Prt('^0Toggle Which AR Flag? ['+DisplayArFlags(F_AR,'0','1')+'^0] [(^1?^0)Help,<^1CR^0>Quit]: ');
                  OneK(Cmd1,^M'ABCDEFGHIJKLMNOPQRSTUVWXYZ?',TRUE,TRUE);
                  IF (Cmd1 = '?') THEN
                    PrintF('ARFLAGS')
                  ELSE IF (Cmd1 <> ^M) THEN
                    ToggleARFlag(Cmd1,F_AR,Changed);
                UNTIL ((Cmd1 = ^M) OR (HangUp));
                Cmd1 := #0;
              END;
        '5' : BEGIN
                REPEAT
                  Prt('Toggle which AC flag? ['+DisplayACFlags(F_AC,'5','4')+'] [?]Help: ');
                  OneK(Cmd1,^M'LCVUA*PEKM1234?',TRUE,TRUE);
                  IF (Cmd1 = '?') THEN
                    PrintF('ACFLAGS')
                  ELSE IF (Cmd1 <> ^M) THEN
                    ToggleACFlags(Cmd1,F_AC,Changed1);
                UNTIL (Cmd1 = ^M) OR (HangUp);
                Cmd1 := #0;
              END;
        '6' : BEGIN
                REPEAT
				  NL;
                  Print('^1Current Flags: ^3'+Find_FS);
                  NL;
                  Prt('^1Select Flags, or (^3?^1) Help, or (^3Q^1) Quit: ');
                  OneK(Cmd1,'QACDLST?',TRUE,TRUE);
                  CASE Cmd1 OF
                    'A' : FSF := FS_Alert;
                    'C' : FSF := FS_ChatBuffer;
                    'D' : FSF := FS_Deleted;
                    'L' : FSF := FS_LockedOut;
                    'S' : FSF := FS_SLogging;
                    'T' : FSF := FS_Trapping;
                    '?' : BEGIN
                            NL;
                            LCmds3(24,1,'A Alert',		'C Chat Buffering',		'D Deleted');
                            LCmds3(24,1,'L Locked Out',	'S Separate SysOp Log',	'T Trapping');
							{NL;}
                          END;
                    END;
                    IF (Cmd1 IN ['A','C','D','L','S','T']) THEN
                      IF (FSF IN F_Status) THEN
                        Exclude(F_Status,FSF)
                      ELSE
                        Include(F_Status,FSF);
                UNTIL ((Cmd1 IN ['Q',' ',^M]) OR (HangUp));
                Cmd1 := #0;
              END;
        '7' : BEGIN
                Prt('Starting date: ');
                MPL(10);
                InputFormatted('',TempStr1,'##/##/####',TRUE);
                F_LastOn1 := Date2PD(TempStr1);
                NL;
                Prt('Ending date: ');
                MPL(10);
                InputFormatted('',TempStr1,'##/##/####',TRUE);
                F_LastOn2 := Date2PD(TempStr1);
              END;
        '8' : BEGIN
                Prt('Starting date: ');
                MPL(10);
                InputFormatted('',TempStr1,'##/##/####',TRUE);
                F_FirstOn1 := Date2PD(TempStr1);
                NL;
                Prt('Ending date: ');
                MPL(10);
                InputFormatted('',TempStr1,'##/##/####',TRUE);
                F_FirstOn2 := Date2PD(TempStr1);
              END;
        '9' : BEGIN
				NL;
                InputLongIntWOC('Lower limit',F_NumCalls1,[DisplayValue,NumbersOnly],0,2147483647);
				NL;
                InputLongIntWOC('Upper limit',F_NumCalls2,[DisplayValue,NumbersOnly],(0 + F_NumCalls1),2147483647);
              END;
        'A' : BEGIN
				NL;
                InputByteWOC('Lower limit',F_Age1,[DisplayValue,NumbersOnly],0,255);
				NL;
                InputByteWOC('Upper limit',F_Age2,[displayValue,NumbersOnly],(0 + F_Age1),255);
              END;
        'G' : BEGIN
                NL;
				Prt('^1Gender? (^3M^1)ale/(^3F^1)emale/(^3O^1)ther: ');
                OneK(Cmd1,'MFO',TRUE,TRUE);
                IF (Cmd1 IN ['F','M','O']) THEN
                  F_Gender := Cmd1;
              END;
        'P' : BEGIN
                InputLongIntWOC('%LFLower limit',F_PostRatio1,[DisplayValue,NumbersOnly],0,2147483647);
                InputLongIntWOC('%LFUpper limit',F_PostRatio2,[DisplayValue,NumbersOnly],(0 + F_PostRatio1),2147483647);
              END;
        'K' : BEGIN
                InputLongIntWOC('%LFLower limit',F_DLKRatio1,[DisplayValue,NumbersOnly],0,2147483647);
                InputLongIntWOC('%LFUpper limit',F_DLKRatio2,[DisplayValue,NumbersOnly],(0 + F_DLKRatio1),2147483647);
              END;
        'N' : BEGIN
                InputLongIntWOC('%LFLower limit',F_DLRatio1,[DisplayValue,NumbersOnly],0,2147483647);
                InputLongIntWOC('%LFUpper limit',F_DLRatio2,[DisplayValue,NumbersOnly],(0 + F_DLRatio1),2147483647);
              END;
        'C' : IF PYNQ('Are you sure? ',0,FALSE) THEN
                Clear_F;
        {^M,'L' :
              DisplaySearchOptions;}
        'T' : BEGIN
                Prt('Which (0-9,A,G,P,K,N)? [Q]=Quit]: ');
                OneK(Cmd1,'Q0123456789AGPKN'^M,TRUE,TRUE);
                NL;
                CASE Cmd1 OF
                  '0'..'9' :
                        SType := (Ord(Cmd1) - 48);
                  'A' : SType := 10;
                  'G' : SType := 11;
                  'P' : SType := 12;
                  'K' : SType := 13;
                  'N' : SType := 14;
                ELSE
                  SType := -1;
                END;
                IF (SType <> -1) THEN
                BEGIN
                  F_State[SType] := NOT F_State[SType];
                  Prompt('^8[>^0 '+SearchType(SType)+' is now *'+AonOff(F_State[SType],'ON','OFF')+'*^1');
                  NL;
                END;
                Cmd1 := #0;
              END;
        'U' : BEGIN
                Abort := FALSE;
                Next := FALSE;
                Reset(UserFile);
                UserCount := 0;
                TempMaxUsers := (MaxUsers - 1);
                UNum1 := 1;
                WHILE (UNum1 <= TempMaxUsers) AND (NOT Abort) AND (NOT HangUp) DO
                BEGIN
                  IF (OKUser(UNum1)) THEN
                  BEGIN
                    LoadURec(User1,UNum1);
                    PrintACR('^1'+Caps(User1.Name)+'^0 (#^1'+IntToStr(UNum1)+'^0'#242'');
                    Inc(UserCount);
                  END;
                  Inc(UNum1);
                END;
				{PauseScr(FALSE);}
                Close(UserFile);
                IF (NOT Abort) THEN
                BEGIN
                  NL;
                  Print('^0 - ^1'+IntToStr(UserCount)+'^0 User(s)');
                END;
			  PauseScr(FALSE);
              END;
        '?' : BEGIN
                {Print('(^30^1-^39^1,^3AGPKN^1) Change Option');}
                LCmds3(17,1,{'L List Options',}'T Toggle Options','C Clear Options','U User''s Who Match');
                {LCmds3(17,1,'Q Quit','? Help','');}
				NL;
				PauseScr(False);
              END;
      END;
    UNTIL (Cmd1 = 'Q') OR (HangUp);
  END;

  PROCEDURE KillUserMail;
  VAR
    User1: UserRecordType;
    MHeader: MHeaderRec;
    SaveReadMsgArea: Integer;
    MsgNum: Word;
  BEGIN
    SaveReadMsgArea := ReadMsgArea;
    InitMsgArea(-1);
    Reset(MsgHdrF);
    FOR MsgNum := 1 TO HiMsg DO
    BEGIN
      LoadHeader(MsgNum,MHeader);
      IF (NOT (MDeleted IN MHeader.Status)) AND ((MHeader.MTO.UserNum = UNum) OR (MHeader.From.UserNum = UNum)) THEN
      BEGIN
        Include(MHeader.Status,MDeleted);
        SaveHeader(MsgNum,MHeader);
        LoadURec(User1,MHeader.MTO.UserNum);
        IF (User1.Waiting > 0) THEN
          Dec(User1.Waiting);
        SaveURec(User1,MHeader.MTO.UserNum);
        Reset(MsgHdrF);
      END;
    END;
    Close(MsgHdrF);
    InitMsgArea(SaveReadMsgArea);
  END;

  PROCEDURE KillUserVotes;
  VAR
    Counter1: Byte;
  BEGIN
    Assign(VotingFile,General.DataPath+'VOTING.DAT');
    Reset(VotingFile);
    IF (IOResult = 0) THEN
    BEGIN
      FOR Counter1 := 1 TO FileSize(VotingFile) DO
        IF (User.Vote[Counter1] > 0) THEN
        BEGIN
          Seek(VotingFile,(Counter1 - 1));
          Read(VotingFile,Topic);
          Dec(Topic.Answers[User.Vote[Counter1]].NumVotedAnswer);
          Dec(Topic.NumVotedQuestion);
          Seek(VotingFile,(Counter1 - 1));
          Write(VotingFile,Topic);
          User.Vote[Counter1] := 0;
        END;
      Close(VotingFile);
    END;
    LastError := IOResult;
  END;

  PROCEDURE ChangeRecords(On: Byte);
  VAR
    OneKCmds: AStr;
	Cmd,
    Cmd1: Char;
    TempL1: LongInt;
	TempSchemeName: STRING[30]; { LeeW: Added }
	TempConfName: STRING[30]; { LeeW }
	RecNumToList: Integer; { LeeW }	
  BEGIN
    WITH User DO
      REPEAT
        NL;
        CASE on OF
          1 : BEGIN
				ClrScr;
				Print(PadLeftStr('^2 '#240' User Editor: Call Records ('+ Name+')',80));
                Print('^0<^1A^0> Total Calls       : ^1'+IntToStr(LoggedOn));
				Print('^0<^1B^0> Calls Today       : ^1'+IntToStr(OnToday));
				Print('^0<^1C^0> Total Time Online : ^1'+IntToStr(TTimeOn));
				Print('^0<^1D^0> Time Online Today : ^1'); { LeeW: Add this }
				Print('^0<^1E^0> Time Left Today   : ^1'+IntToStr(TLToday));
				Print('^0<^1F^0> Mins In Time Bank : ^1'+IntToStr(TimeBank));
				Print('^0<^1G^0> Illegal Logons    : ^1'+IntToStr(Illegal));
				Print('^0<^1T^0> Last On/First On  : ^1'+ToDate8(PD2Date(LastOn))+'^0 / ^1'+ToDate8(PD2Date(FirstOn)));
				NL;
				Print('^0<^12^0> File Records');
				Print('^0<^13^0> Mail Records');
				Print('^0<^14^0> Preference Records');
				Print('^0<^15^0> Subscription Records');
				NL;
                Prt('^0Records Editor [<^1CR^0>Quit]: ');
                OneK(Cmd1,^M'ABCDEFGT12345',TRUE,TRUE);
              END;
          2 : BEGIN
				ClrScr;
				Print(PadLeftStr('^2 '#240' User Editor: Mail Records ('+ Name+')',80));
                Print('^0<^1A^0> Public Posts  : ^1'+PadLeftStr(IntToStr(MsgPost),6));
				Print('^0<^1B^0> Private Posts : ^1'+PadLeftStr(IntToStr(EmailSent),6));
				Print('^0<^1C^0> Feedback Sent : ^1'+PadLeftStr(IntToStr(FeedBack),6));
				Print('^0<^1D^0> Mail Waiting  : ^1'+PadLeftStr(IntToStr(Waiting),6));
                NL;
				Print('^0<^11^0> Call Records');
				Print('^0<^13^0> File Records');
				Print('^0<^14^0> Preference Records');
				Print('^0<^15^0> Subscription Records');
				NL;
                Prt('^0Records Editor [<^1CR^0>Quit]: ');
                OneK(Cmd1,^M'ABCD12345',TRUE,TRUE);
              END;
          3 : BEGIN
				ClrScr;
				Print(PadLeftStr('^2 '#240' User Editor: File Records ('+ Name+')',80));
                Print('^0<^1A^0> Downloads           : ^1'+IntToStr(Downloads));
                Print('^0<^1B^0> Downloaded KB       : ^1'+FormatNumber(DK)+'^0KB');
                Print('^0<^1C^0> Uploads             : ^1'+IntToStr(Uploads));
                Print('^0<^1D^0> Uploaded KB         : ^1'+FormatNumber(UK)+'^0KB');
                Print('^0<^1E^0> Downloads Today     : ^1'+IntToStr(DLToday));
                Print('^0<^1F^0> Downloaded KB Today : ^1'+FormatNumber(DLKToday)+'^0KB');
(*				Print('^0<^1X^0> Uploads Today       : ^1'+IntToStr(ULToday)); { LeeW: Add this }
				Print('^0<^1X^0> Uploaded KB Today   : ^1'+FormatNumber(ULKToday)+'^0KB'); { LeeW: Add this } *)
                Print('^0<^1G^0> File Points         : ^1'+FormatNumBer(FilePoints));
                NL;
				Print('^0<^11^0> Call Records');
				Print('^0<^12^0> Mail Records');
				Print('^0<^14^0> Preference Records');
				Print('^0<^15^0> Subscription Records');
				NL;
                Prt('^0Records Editor [<^1CR^0>Quit]: ');
                OneK(Cmd1,^M'ABCDEFG12345',TRUE,TRUE);
              END;
          4 : BEGIN
				BEGIN { Get color scheme name }
				  Reset(SchemeFile);
				  Seek(SchemeFile,ThisUser.ColorScheme - 1);
				  Read(SchemeFile,Scheme);
				  TempSchemeName := Scheme.Description;
				  Close(SchemeFile);
				END;				
				BEGIN { Get Conference Name }
				  Reset(ConferenceFile);
				  RecNumToList := 1;
				  WHILE (RecNumToList <= NumConfKeys) DO
					BEGIN
					  Seek(ConferenceFile,(RecNumToList - 1));
					  Read(ConferenceFile,Conference);
					  IF (LastConf = Conference.Key) THEN
						TempConfName := Conference.Name;
					  Inc(RecNumToList);
					END;
				  Close(ConferenceFile);
				END;				
				ClrScr;
				Print(PadLeftStr('^2 '#240' User Editor: Preference Records ('+ Name+')',80));
                
                Print('^0<^0A^0> Emulation       : ^1'+DisplayTerminalStr(SFlags,Flags));
				Print('^0<^1B^0> Color           : ^1'+AOnOff((Color IN Flags),'Enabled','Disabled'));
				Print('^0<^1C^0> Screen Clearing : ^1'+AOnOff((CLSMsg IN Flags),'Enabled','Disabled'));
				Print('^0<^1D^0> Screen Pausing  : ^1'+AOnOff((Pause IN Flags),'Enabled','Disabled'));
				Print('^0<^1E^0> Editor          : ^1'+AOnOff((FSEditor IN Flags),'Fullscreen','Line'));						
				Print('^0<^1F^0> LightBars       : ^1'+AOnOff((UseLightBars IN Flags),'Enabled','Disabled'));
				Print('^0<^1G^0> Hot Keys        : ^1'+AOnOff((HotKey IN Flags),'Enabled','Disabled'));
				Print('^0<^1H^0> Expert Mode     : ^1'+AOnOff((Novice IN Flags),'Disabled','Enabled'));
				Print('^0<^1I^0> Screen Size     : ^1'+IntToStr(LineLen)+'^0 Columns ^1'+IntToStr(PageLen)+'^0 Lines');
				Print('^0<^1J^0> Color Scheme    : ^1'+IntToStr(ColorScheme)+'^0 [^1'+TempSchemeName+'^0]');
				Print('^0<^1K^0> Conference      : ^1'+LastConf+'^0 [^1'+TempConfName+'^0]');
				NL;
				Print('^0<^11^0> Call Records');
				Print('^0<^12^0> File Records');
				Print('^0<^13^0> Mail Records');
				Print('^0<^15^0> Subscription Records');
                NL;
                Prt('^0Records Editor [<^1CR^0>Quit]: ');
                OneK(Cmd1,^M'ABCDEFGHIJK12345',TRUE,TRUE);
              END;
          5 : BEGIN
				ClrScr;
				Print(PadLeftStr('^2 '#240' User Editor: Subscription Records ('+ Name+')',80));
                Print('^0<^1A^0> Credit  : ^1'+IntToStr(lCredit));
                Print('^0<^1B^0> Debit   : ^1'+IntToStr(Debit));
                Print('^0<^1C^0> Expires : ^1'+AOnOff(Expiration = 0,'Never',ToDate8(PD2Date(Expiration)))+
				'^0 > ^1'+AOnOff(ExpireTo = ' ','None',ExpireTo) );
                NL;
				Print('^0<^11^0> Call Records');
				Print('^0<^12^0> File Records');
				Print('^0<^13^0> Mail Records');
				Print('^0<^14^0> Preference Records');
				NL;
                Prt('^0Records Editor [<^1CR^0>Quit]: ');
                OneK(Cmd1,^M'ABC12345',TRUE,TRUE);
              END;
        END;
        CASE Cmd1 OF
          '1' : ON := 1;
		  '2' : ON := 2;
          '3' : ON := 3;
          '4' : ON := 4;
          '5' : ON := 5;
		  'T' : BEGIN
				  Print('New last on date (MM/DD/YYYY).');
				  Prt(': ');
				  MPL(10);
				  InputFormatted('',TempStr,'##/##/####',TRUE);
				  IF (TempStr <> '') THEN
					User.LastOn := Date2PD(TempStr);
				END;
          'A'..'Z' :
                BEGIN
                  NL;
                  IF (on <> 4) THEN
                  BEGIN
                    IF (on <> 5) OR NOT (Cmd1 IN ['C'..'D']) THEN
                    BEGIN
                      Prt('^0New Value: ');
                      Input(TempStr,10);
                      TempL1 := StrToInt(TempStr);
                    END
                    ELSE
                      CASE Cmd1 OF
                        'C' : IF (PYNQ('^0Reset Expiration Date & Level? ',0,FALSE)) THEN
                            BEGIN
                              TempL1 := 0;
                              TempStr := ' ';
                            END
                            ELSE
                            BEGIN
                              NL;
                              Prt('^0New Expiration Date: ');
                              MPL(10);
                              InputFormatted('',TempStr,'##/##/####',TRUE);
                              IF (TempStr <> '') THEN
                                TempL1 := Date2PD(TempStr)
                              ELSE
                                TempL1 := 0;
                              OneKCmds := '';
                              FOR Cmd1 := '!' TO '~' DO
                                IF (Cmd1 IN ValKeys) THEN
                                    OneKCmds := OneKCmds + Cmd1;
                              NL;
                              Prt('^0Expire To Which Level? [^1!^0-^1~^0] [^1Space^0=No Change]: ');
                              OneK1(Cmd1,^M' '+OneKCmds,TRUE,TRUE);
                              TempStr := Cmd1;
                              IF (TempL1 = 0) OR (TempStr = ' ') THEN
                              BEGIN
                                TempL1 := 0;
                                TempStr := ' ';
                              END;
                              Cmd1 := 'C';
                            END;
                      END;
                      IF (TempStr <> '') THEN
                        CASE on OF
                          1 : CASE Cmd1 OF
                                'A' : LoggedOn := TempL1;
                                'C' : TTimeOn := TempL1;
                                'B' : OnToday := TempL1;
                                'E' : TLToday := TempL1;
                                'G' : Illegal := TempL1;
                                'F' : TimeBank := TempL1;
								'D' : ;
                              END;
                          2 : CASE Cmd1 OF
                                'A' : MsgPost := TempL1;
                                'B' : EmailSent := TempL1;
                                'C' : FeedBack := TempL1;
                                'D' : Waiting := TempL1;
                              END;
                          3 : CASE Cmd1 OF
                                'A' : Downloads := TempL1;
                                'B' : DK := TempL1;
                                'C' : Uploads := TempL1;
                                'D' : UK := TempL1;
                                'E' : DLToday := TempL1;
                                'F' : DLKToday := TempL1;
                                'G' : FilePoints := TempL1;
                              END;
                          5 : CASE Cmd1 OF
                                'A' : lCredit := TempL1;	{ Credits }
                                'B' : Debit := TempL1;		{ Debits }
                                'C' : BEGIN					{ Expiration Date / Level }
                                      Expiration := TempL1;
                                      IF (TempStr[1] IN [' ','!'..'~']) THEN
                                        ExpireTo := TempStr[1];
                                    END;
                              END;
                        END;
                      END
                      ELSE
                        CASE Cmd1 OF
                          'A' : CStuff(13,3,User); 					{ Emulation }
						  'B' : ToggleACFlag(Color,Flags);			{ Color }
                          'C' : ToggleACFlag(CLSMsg,Flags);			{ Screen Clearing }
                          'D' : ToggleACFlag(Pause,Flags);			{ Screen Pausing }
                          'E' : ToggleACFlag(FSEditor,Flags);		{ Editor Type }
						  'F' : ToggleACFlag(UseLightBars,Flags);	{ LightBars }
						  'G' : ToggleACFlag(HotKey,Flags);			{ HotKeys }
						  'H' : ToggleACFlag(Novice,Flags);			{ Expert Mode }
						  'I' : CStuff(16,3,User);					{ Screen Size }
						  'J' : CStuff(15,3,User);					{ Color Scheme }
						  'K' : ChangeConference('');				{ Conference }
						  { ChangeConference('') doesn't work in user editor -- ? not applying to right user }
                        END;
                END;
        END;
      UNTIL (Cmd1 = ^M) OR (HangUp);
  END;

BEGIN
  IF ((UNum < 1) OR (UNum > (MaxUsers - 1))) THEN
    Exit;
  IF (UNum = UserNum) THEN
  BEGIN
    User := ThisUser;
    SaveURec(User,UNum);
  END;
  LoadURec(User,UNum);
  Clear_F;
  SaveUNum := 0;
  Save := FALSE;
  REPEAT
    Abort := FALSE;
    IF (AutoList) OR (UNum <> SaveUNum) OR (Cmd = ^M) THEN
    BEGIN
      ShowUserInfo(UserInfoTyp,UNum,User);
      SaveUNum := UNum;
    END;
    NL;
    Prt('^0User Editor: ');
    OneK(Cmd,'Q?[]=${}*ABCDEFGHIJKLMNOPRSTUVWXYZ12345-+_;:\/^%!#&',True,True);
    
	IF (Cmd IN ['A','F','L'..'O','S'..'X','Z','/','{','}','-',';','^','?','<','\','=','_','#','&']) THEN
	  NL;

    CASE Cmd OF
      '?' : BEGIN
              Abort := FALSE;
              LCmds3(20,1,'; List Mode',		'& Lock Out User',		'\ Show SysOp Log');
              LCmds3(20,1,'[ Previous User',	'] Next User',			'= Reload Old Data');
              LCmds3(20,1,'{ Search Backward',	'} Search Forward',		'* Validate User');
              LCmds3(20,1,'+ Mailbox Config',	'# Go To User Name/#',	'! Search Options');
              LCmds3(20,1,'- New User Answers',	'_ Other Q. Answers',	'% .QWK Config');
              LCmds3(20,1,'^ Delete User', 		'/ New User Config',	'$ Clear Fields');
              NL;
              PauseScr(FALSE);
              Save := FALSE;
            END;
      '[',']','/','{','}','#','Q' :
            BEGIN
              IF (Save) THEN
              BEGIN
                SaveURec(User,UNum);
                IF (UNum = UserNum) THEN
                  ThisUser := User;
                Save := FALSE;
              END;
              CASE Cmd OF
                '[' : BEGIN
                        Dec(UNum);
                        IF (UNum < 1) THEN
                          UNum := (MaxUsers - 1);
                      END;
                ']' : BEGIN
                        Inc(UNum);
                        IF (UNum > (MaxUsers - 1)) THEN
                          UNum := 1;
                      END;
                '/' : UNum := 0;
                '{' : Search(-1);
                '}' : Search(1);
                '#' : BEGIN
                        Print('Enter User Name, Number, or Partial Search String');
                        {Prt(': ');}
                        lFindUserWS(UNum1);
                        IF (UNum1 > 0) THEN
                        BEGIN
                          LoadURec(User,UNum1);
                          UNum := UNum1;
                        END;
                      END;
              END;
              LoadURec(User,UNum);
              IF (UNum = UserNum) THEN
                ThisUser := User;
            END;
      '=' : IF PYNQ('Reload old user data? ',0,FALSE) THEN
            BEGIN
              LoadURec(User,UNum);
              IF (UNum = UserNum) THEN
                ThisUser := User;
              Save := FALSE;
              Print('^9Old User Data Loaded^0');
            END;
      '!','-','_',';',':','\' :
            BEGIN
              CASE Cmd OF
                '!' : UserSearch;
                '-' : BEGIN
                        ReadAsw(UNum,General.MiscPath+'NEWUSER');
                        PauseScr(FALSE);
                      END;
                '_' : BEGIN
                        Print('^0Print Questionairre');
						NL;
						Prt('^0Filename: ');
                        MPL(8);
                        Input(TempStr,8);
                        NL;
                        ReadAsw(UNum,General.MiscPath+TempStr);
                        PauseScr(FALSE);
                      END;
                ';' : BEGIN
						Print('^0(^1X^0) Expert '#196' Nothing');
						Print('^0(^1S^0) Short  '#196' User Name, Real Name, Gender & Birthdate, Country, SL, DSL, AR, AC');
						Print('^0(^1M^0) Medium '#196' Everything Except Call, Mail, File, Pref, Subs Records');
						Print('^0(^1L^0) Long   '#196' Everything');
						NL;
						Prt('^0List Mode: ');
                        OneK(Cmd,'SMLX'^M,TRUE,TRUE);
                        CASE Cmd OF
						  'X' : AutoList := FALSE;
                          'S' : BEGIN
								  UserInfoTyp := 1;
								  AutoList := TRUE;
								END;
						  'M' : BEGIN
								  UserInfoTyp := 2;
								  AutoList := TRUE;
								END;
                          'L' : BEGIN
								  UserInfoTyp := 3;
								  AutoList := TRUE;
								END;
                        END;
                        Cmd := #0;
                      END;
                {':' : AutoList := NOT AutoList;}
                '\' : BEGIN
                        TempStr := General.LogsPath+'SLOG'+IntToStr(UNum)+'.LOG';
                        PrintF(TempStr);
                        IF (NoFile) THEN
                          Print('^8"'+TempStr+'": File not found.');
                        PauseScr(True);
                      END;
              END;
            END;
      '$','*','+','A','B','C','D','E','F','G','H','I','J','K','%','L','M',
      'N','O','P','R','T','&','W','X','Y','Z','1','2','3','4','5','^' :
            BEGIN
              IF (((ThisUser.SL <= User.SL) OR (ThisUser.DSL <= User.DSL)) AND
                 (UserNum <> 1) AND (UserNum <> UNum)) THEN
              BEGIN
                SysOpLog('Tried to modify '+Caps(User.Name)+' #'+IntToStr(UNum));
                Print('^8Access denied.');
                NL;
                PauseScr(FALSE);
              END
              ELSE
              BEGIN
                Save1 := Save;
                Save := TRUE;
                CASE Cmd OF
                  '$' : BEGIN { Clear Fields }
                          REPEAT
                            NL;
                            Prt('^0Clear Fields [^1A^0-^1K^0,(^1*^0)All,(^1Q^0)uit,(^1?^0)Help]: ');
                            OneK(Cmd,'QABCDEFGHIJK?*',TRUE,TRUE);
                            IF (Cmd = '?') THEN
                              NL;
                            CASE Cmd OF
                             'A' : User.RealName := User_String_Ask;
                             'B' : User.Street := User_String_Ask;
                             'C' : User.CityState := User_String_Ask;
                             'D' : User.ZipCode := User_String_Ask;
                             'E' : User.Birthdate := User_Date_Ask;
                             'F' : User.PH := User_Phone_Ask;
                             'G' : User.UsrDefStr[1] := User_String_Ask;
                             'H' : User.UsrDefStr[2] := User_String_Ask;
                             'I' : User.UsrDefStr[3] := User_String_Ask;
                             'J' : User.ForgotPWAnswer := User_String_Ask;
							 'K' : User.Country := User_String_Ask;
							 '*' : BEGIN 
									 User.RealName := User_String_Ask;
									 User.Street := User_String_Ask;
									 User.CityState := User_String_Ask;
									 User.ZipCode := User_String_Ask;
									 User.Birthdate := User_Date_Ask;
									 User.PH := User_Phone_Ask;
									 User.UsrDefStr[1] := User_String_Ask;
									 User.UsrDefStr[2] := User_String_Ask;
									 User.UsrDefStr[3] := User_String_Ask;
									 User.ForgotPWAnswer := User_String_Ask;
									 User.Country := User_String_Ask;
								   END;
                             '?' : BEGIN
                                     LCmds(21,1,'A Real Name','B Address');
                                     LCmds(21,1,'C City/State','D Zip Code');
                                     LCmds(21,1,'E Birth Date','F Phone Number');
                                     LCmds(21,1,'G SysOp Question 1','H SysOp Question 2');
                                     LCmds(21,1,'I SysOp Question 3','J Forgot PW Answer');
									 LCmds(21,1,'K Country','* All');
                                   END;
                            END;
                          UNTIL (Cmd = 'Q') OR (HangUp);
                          Cmd := #0;
                        END;
                  '*' : AutoVal(User,UNum);
                  '+' : CStuff(24,3,User); { Mailbox }
                  '1'..'5' :
                        ChangeRecords(Ord(Cmd) - 48);
                  'A' : BEGIN { User Name }
                          IF (Deleted IN User.SFlags) THEN
                            Print('^8Can''t rename deleted users.')
                          ELSE
                            BEGIN
                            Print('Enter new name.');
                            Prt(': ');
                            MPL((SizeOf(ThisUser.Name) - 1));
                            Input(TempStr,(SizeOf(ThisUser.Name) - 1));
                            UNum1 := SearchUser(TempStr,TRUE);
                            IF ((UNum1 = 0) OR (UNum1 = UNum)) AND (TempStr <> '') THEN
                            BEGIN
                              InsertIndex(User.Name,UNum,FALSE,TRUE);
                              User.Name := TempStr;
                              InsertIndex(User.Name,UNum,FALSE,FALSE);
                              Save := TRUE;
                              IF (UNum = UserNum) THEN
                                ThisUser.Name := TempStr;
                            END
                            ELSE
                              Print('^8Illegal Name.');
                          END;
                        END;
                  'B' : BEGIN { Real Name }
                          TempStr := User.RealName;
                          CStuff(2,3,User);
                          IF (User.RealName <> TempStr) THEN
                          BEGIN
                            InsertIndex(TempStr,UNum,TRUE,TRUE);
                            InsertIndex(User.RealName,UNum,TRUE,FALSE);
                          END;
                        END;
                  'C' : CStuff(5,3,User); { Address }
                  'D' : CStuff(4,3,User); { City/State }
                  'E' : CStuff(6,3,User); { Zip Code }
                  'F' : BEGIN
						  InputWN1('^0New SysOp Note:%LF^2',User.Note,(SizeOf(User.Note) - 1),[ColorsAllowed],Next);
						END;
                  'G' : CStuff(10,3,User); { SysOp Question #1 }
                  'H' : CStuff(11,3,User); { SysOp Question #2 }
                  'I' : CStuff(12,3,User); { SysOp Question #3 }
                  'J' : BEGIN
                          REPEAT
							NL;
							Print('^0(^11^0) Activity Log  : ^1'+AOnOff((TrapActivity IN User.SFlags),
																+AOnOff((TrapSeparate IN User.SFlags),
																'On ^0> ^1TRAP'+IntToStr(UNum)+'.LOG',
																'On ^0> ^1TRAP.LOG'),'Off')
																+AOnOff(General.GlobalTrap,'^8 <GLOBAL>',''));
                            Print('^0(^12^0) Chat Log      : ^1'+AOnOff((ChatAuto IN User.SFlags),
																+AOnOff((ChatSeparate IN User.SFlags),
																'On ^0> ^1CHAT'+IntToStr(UNum)+'.LOG',
																'On ^0> ^1CHAT.LOG'),'Off')+
																+AOnOff(General.AutoChatOpen,'^8 <GLOBAL>',''));
                            Print('^0(^13^0) Sep SysOp Log : ^1'+AOnOff((SLogSeparate IN User.SFlags),
																'On ^0> ^1SLOG'+IntToStr(UNum)+'.LOG',
																'Off'));
                            Print('^0(^14^0) Alert         : ^1'+AOnOff((Alert IN User.SFlags),
																'On',
																'Off'));
                            NL;
                            Prt('^0Logging/Alert Options ^0[^11^0-^14^0,<^1CR^0>Quit]: ');
                            OneK(Cmd,^M'1234',TRUE,TRUE);
                            IF (Cmd <> ^M) THEN
                              NL;
                            CASE Cmd OF
                              '1' : BEGIN
                                      IF PYNQ('Log Activity? ['+ShowYesNo((TrapActivity IN User.SFlags))+']: ',
                                              0,TrapActivity IN User.SFlags) THEN
                                        Include(User.SFlags,TrapActivity)
                                      ELSE
                                        Exclude(User.SFlags,TrapActivity);
                                      IF (TrapActivity IN User.SFlags) THEN
                                      BEGIN
                                        IF PYNQ('Log To Separate File? ['+ShowYesNo(TrapSeparate IN User.SFlags)+']: ',
                                                0,TrapSeparate IN User.SFlags) THEN
                                          Include(User.SFlags,TrapSeparate)
                                        ELSE
                                          Exclude(User.SFlags,TrapSeparate);
                                      END
                                      ELSE
                                        Exclude(User.SFlags,TrapSeparate);
                                    END;
                              '2' : BEGIN
                                      IF PYNQ('Log Chat Sessions? ['+ShowYesNo(ChatAuto IN User.SFlags)+']: ',
                                              0,ChatAuto IN User.SFlags) THEN
                                        Include(User.SFlags,ChatAuto)
                                      ELSE
                                        Exclude(User.SFlags,ChatAuto);
                                      IF (ChatAuto IN User.SFlags) THEN
                                      BEGIN
                                        IF PYNQ('Log To Separate File? ['+ShowYesNo(ChatSeparate IN User.SFlags)+']: ',
                                                0,ChatSeparate IN User.SFlags) THEN
                                          Include(User.SFlags,ChatSeparate)
                                        ELSE
                                          Exclude(User.SFlags,ChatSeparate);
                                      END
                                      ELSE
                                        Exclude(User.SFlags,ChatSeparate);
                                    END;
                              '3' : BEGIN
                                 IF PYNQ('Output Separate SysOp Log? ['+ShowYesNo(SLogSeparate IN User.SFlags)+']: ',
                                         0,SLogSeparate IN User.SFlags) THEN
                                        Include(User.SFlags,SLogSeparate)
                                      ELSE
                                        Exclude(User.SFlags,SLogSeparate);
                                    END;
                              '4' : ToggleStatusFlag(Alert,User.SFlags);
                            END;
                          UNTIL (Cmd = ^M) OR (HangUp);
                          Cmd := #0;
                        END;
				  'K' : CStuff(03,3,User); { Country }
                  '%' : CStuff(27,3,User); { QWK }
                  'L' : BEGIN
                          TempB := User.SL;
                          InputByteWOC('Enter new SL',TempB,[NumbersOnly],0,255);
                          IF (TempB >= 0) AND (TempB <= 255) THEN
                          BEGIN
                            Ok := TRUE;
                            IF (TempB < ThisUser.SL) OR (UserNum = 1) THEN
                            BEGIN
                              IF (UserNum = UNum) AND (TempB < ThisUser.SL) THEN
                              BEGIN
                                NL;
                                IF NOT PYNQ('Lower your own SL level? ',0,FALSE) THEN
                                  Ok := FALSE;
                              END;
                              IF (Ok) THEN
                              BEGIN
                                User.SL := TempB;
                                User.TLToday := (General.TimeAllow[User.SL] - User.TTimeOn);
                              END;
                            END
                            ELSE
                            BEGIN
                              NL;
                              Print('^8Access denied.'^G);
                              SysOpLog('Illegal SL edit attempt: '+Caps(User.Name)+' #'+IntToStr(UNum)+' to '+IntToStr(TempB));
                            END;
                          END;
                        END;
                  'M' : BEGIN
                          TempB := User.DSL;
                          InputByteWOC('Enter new DSL',TempB,[NumbersOnly],0,255);
                          IF (TempB >= 0) AND (TempB <= 255) THEN
                          BEGIN
                            Ok := TRUE;
                            IF (TempB < ThisUser.DSL) OR (UserNum = 1) THEN
                            BEGIN
                              IF (UserNum = UNum) AND (TempB < ThisUser.SL) THEN
                              BEGIN
                                NL;
                                IF NOT PYNQ('Lower your own DSL level? ',0,FALSE) THEN
                                  Ok := FALSE;
                              END;
                              IF (Ok) THEN
                                User.DSL := TempB;
                            END
                            ELSE
                            BEGIN
                              NL;
                              Print('^8Access denied.'^G);
                              SysOpLog('Illegal DSL edit attempt: '+Caps(User.Name)+' #'+IntToStr(UNum)+
                                       ' to '+IntToStr(TempB));
                            END;
                          END;
                        END;
                  'N' : BEGIN
                          REPEAT
                            Prt('^0Toggle Which AR Flag? ['+DisplayARFlags(User.AR,'1','0')+'^0]'+
                                ' [(^1*^0)All,(^1?^0)Help,<^1CR^0>Quit]: ');
                            OneK(Cmd,^M'ABCDEFGHIJKLMNOPQRSTUVWXYZ*?',TRUE,TRUE);
                            IF (Cmd = '?') THEN
                              PrintF('ARFLAGS')
                            ELSE IF (Cmd <> ^M) THEN
                            BEGIN
                              IF (NOT (Cmd IN ThisUser.AR)) AND (NOT SysOp) THEN
                              BEGIN
                                Print('^8Access denied.'^G);
                                SysOpLog('Tried to give '+Caps(User.Name)+' #'+IntToStr(UNum)+' AR flag "'+Cmd+'"');
                              END
                              ELSE IF (Cmd IN ['A'..'Z']) THEN
                                ToggleARFlag(Cmd,User.AR,Changed)
                              ELSE IF (Cmd = '*') THEN
                              BEGIN
                                FOR Cmd := 'A' TO 'Z' DO
                                  ToggleARFlag(Cmd,User.AR,Changed);
                                Cmd := '*';
                              END;
                            END;
                          UNTIL (Cmd = ^M) OR (HangUp);
                          Cmd := #0;
                        END;
                  'O' : BEGIN
                          REPEAT
                            Prt('^0Toggle Which AC Flag? ['+DisplayACFlags(User.Flags,'1','0')+'^0]'+
                                ' [(^1?^0)Help,<^1CR^0>Quit]: ');
                            OneK(Cmd,^M'LCVUA*PEKM1234?',TRUE,TRUE);
                            IF (Cmd = '?') THEN
							  BEGIN
								{PrintF('ACFLAGS')}
								NL;
								Print('^0Restrictions:');
								NL;
								LCmds(28,1,'L Can Only Logon Once Daily',	'C Cant Page SysOp');
								LCmds(28,1,'V Posts Marked Unvalidated',	'U Cant List Users');
								LCmds(28,1,'A Cant Add To BBS List',		'* Cant Post/Send Anonymously');
								LCmds(28,1,'P Cant Post At All',			'E Cant Send EMail');
								LCmds(28,1,'K Cant Vote',					'M Mandatory Mail Deletion');
								NL;
								Print('^0Privileges:');
								NL;
								LCmds(28,1,'1 No UL/DL Ratio Check',	'2 No Post/Call Ratio Check');
								LCmds(28,1,'3 No Credit Check',			'4 Protected From Deletion');
								NL;
							  END
                            ELSE
                            BEGIN
                              IF (Cmd = '4') AND (NOT SysOp) THEN
                              BEGIN
                                Print('^8Access denied.'^G);
                                SysOpLog('Tried to change '+Caps(User.Name)+' #'+IntToStr(UNum)+' deletion status');
                              END
                              ELSE IF (Cmd <> ^M) THEN
                                ToggleACFlags(Cmd,User.Flags,Changed);
                            END;
                          UNTIL (Cmd = ^M) OR (HangUp);
                          Cmd := #0;
                        END;
                  'P' : BEGIN
                          CStuff(9,3,User); { Sex }
                          CStuff(8,3,User); { Age }
                        END;
                  'R' : CStuff(7,3,User); { Phone Number }

                  '&' : BEGIN
                          IF (LockedOut IN User.SFlags) THEN
						    BEGIN
							  Print('^0User ^1'+User.Name+'^0 is currently locked out, displaying file "^1'+User.LockedFile+'^0"');
							  IF PYNQ('^0Do you want to restore their access? ',0,TRUE) THEN
								BEGIN
								  Exclude(User.SFlags,LockedOut);
								  User.LockedFile := '';
								  SysOpLog('User '+User.Name+' (#'+IntToStr(UNum)+') is no longer locked out');
								END;
							END
                          ELSE
						    BEGIN
							  Print('^0User ^1'+User.Name+'^0 is not currently locked out,');
							  IF PYNQ('^0Do you want to restrict their access? ',0,FALSE) THEN
								BEGIN
								  NL;
								  Print('^0When this user attempts to log on, a file will be displayed to');
								  Print('^0them before they are disconnected.');
								  Print('^0You can specify this file now, or leave blank for default message.');
								  NL;
								  Prt('^0Enter Filename: ');
								  MPL(8);
								  Input(TempStr,8);
								  Include(User.SFlags,LockedOut);
								  User.LockedFile := TempStr;
								  SysOpLog('Locked out '+User.Name+' (#'+IntToStr(UNum)+') File "'+TempStr+'"');
								END;
							  {PauseScr(FALSE);}
							END;
						END;
                  'W' : BEGIN
                          Print('Enter new password.');
                          Prt(': ');
                          MPL(20);
                          Input(TempStr,20);
                          IF (TempStr <> '') THEN
                            User.PW := CRC32(TempStr);
                        END;
                  'X' : BEGIN
                          Print('Enter new caller ID string.');
                          Prt(': ');
                          MPL((SizeOf(User.CallerID) - 1));
                          Input(TempStr,(SizeOf(User.CallerID) - 1));
                          IF (TempStr <> '') THEN
                            User.CallerID := TempStr;
                        END;
(*                'Y' : FindMenu('%LFEnter new start menu (^50^4=^5Default^4)',User.UserStartMenu,0,NumMenus,Changed); *)
                  'Z' : BEGIN
                          Print('Question:');
                          NL;
                          Print(RGMainStr(6,TRUE)); {Forgot Password Question}
                          NL;
                          Print('Enter new forgot password answer.');
                          Prt(': ');
                          MPL((SizeOf(User.ForgotPWAnswer) - 1));
                          Input(TempStr,(SizeOf(User.ForgotPWAnswer) - 1));
                          IF (TempStr <> '') THEN
                            User.ForgotPWAnswer := TempStr;
                        END;
                  '^' : IF (Deleted IN User.SFlags) THEN
                        BEGIN
                          Print('^0This user is currently marked for deletion.');
                          NL;
                          IF PYNQ('^0Do you want to restore this user? ',0,FALSE) THEN
                          BEGIN
                            InsertIndex(User.Name,UNum,FALSE,FALSE);
                            InsertIndex(User.RealName,UNum,TRUE,FALSE);
                            Inc(LTodayNumUsers);
                            SaveGeneral(TRUE);
                            Exclude(User.SFlags,Deleted);
                          END
                          ELSE
                            Save := Save1;
                        END
                        ELSE IF (FNoDeletion IN User.Flags) THEN
                        BEGIN
                          Print('^8Access denied! This user is protected from deletion.');
                          SysOpLog('* Attempt to delete user: '+Caps(User.Name)+' #'+IntToStr(UNum));
                          NL;
                          PauseScr(FALSE);
                          Save := Save1;
                        END
                        ELSE
                        BEGIN
                          {NL;}
                          IF PYNQ('^0Do you want to mark this user for deletion? ',0,FALSE) THEN
                          BEGIN
                            IF NOT (Deleted IN User.SFlags) THEN
                            BEGIN
                              Save := TRUE;
                              Include(User.SFlags,Deleted);
                              InsertIndex(User.Name,UNum,FALSE,TRUE);
                              InsertIndex(User.RealName,UNum,TRUE,TRUE);
                              Dec(LTodayNumUsers);
                              SaveGeneral(TRUE);
                              SysOpLog('* Deleted User: '+Caps(User.Name)+' #'+IntToStr(UNum));
                              UNum1 := UserNum;
                              UserNum := UNum;
                              ReadShortMessage;
                              UserNum := UNum1;
                              User.Waiting := 0;
                              KillUserMail;
                              KillUserVotes;
                            END
                            ELSE
                              Save := Save1;
                          END;
                        END;
                ELSE
                  Save := Save1;
                END;
            END;
          END;
    END;
    IF (UNum = UserNum) THEN
    BEGIN
      ThisUser := User;
      NewComptables;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
  Update_Screen;
  LastError := IOResult;
  {PauseScr(FALSE);}
END;

END.
