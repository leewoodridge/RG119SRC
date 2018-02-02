{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  -------------------
  COLOR SCHEME EDITOR
  -------------------
}

UNIT SysOp2J;

INTERFACE

PROCEDURE ColorConfiguration;

IMPLEMENTATION

USES
  Common,
  TimeFunc;

PROCEDURE ColorConfiguration;
CONST
  ColorName: ARRAY[0..7] OF STRING[7] = ('Black','Blue','Green','Cyan','Red','Magenta','Yellow','White');
  ColorDesc: ARRAY[0..9] OF STRING[20] = ('Normal Text','Bright Text','Input Field','Header Text','Header Border',
										  'Lightbar Normal','Lightbar Selected','UNUSED','Warning / Error','Notification');
VAR
  TempScheme: SchemeRec;
  Cmd: Char;
  RecNumToList: Integer;
  SaveTempPause: Boolean;
  
  	MinByte,
	MaxByte,
	TempB,
	TempB2: Byte;

  FUNCTION DisplayColorStr(Color: Byte): AStr;
  VAR
    TempStr: AStr;
  BEGIN
    TempStr := ColorName[Color AND 7]+' on '+ColorName[(Color SHR 4) AND 7];
    IF ((Color AND 8) <> 0) THEN
      TempStr := 'Bright '+TempStr;
    IF ((Color AND 128) <> 0) THEN
      TempStr := 'Blinking '+TempStr;
    DisplayColorStr := TempStr;
  END;

  FUNCTION GetColor: Byte;
  VAR
    NewColor,
    SaveOldColor,
    TempColor,
    Counter: Byte;
  BEGIN
    SetC(7);
    NL;
    FOR Counter := 0 TO 7 DO
    BEGIN
      SetC(7);
      Prompt(IntToStr(Counter)+'. ');
      SetC(Counter);
      Prompt(PadLeftStr(ColorName[Counter],12));
      SetC(7);
      Prompt(PadRightInt((Counter + 8),2)+'. ');
      SetC(Counter + 8);
      Print(PadLeftStr(ColorName[Counter]+'!',9));
    END;
    InputByteWOC('%LF^0Foreground',TempColor,[Numbersonly],0,15); (* Suppress Error *)
    IF (TempColor IN [0..15]) THEN
      NewColor := TempColor
    ELSE
      NewColor := 7;
    NL;
    FOR Counter := 0 TO 7 DO
    BEGIN
      SetC(7);
      Prompt(IntToStr(Counter)+'. ');
      SetC(Counter);
      Print(PadLeftStr(ColorName[Counter],12));
    END;
    InputByteWOC('%LF^0Background',TempColor,[NumbersOnly],0,7);  (* Suppress Error *)
    IF (TempColor IN [0..7]) THEN
      NewColor := NewColor OR TempColor SHL 4;
    IF PYNQ('%LF^0Blinking? ',0,FALSE) THEN
      NewColor := NewColor OR 128;
    SetC(7);
    Prompt('%LF^0Example: ');
    SetC(NewColor);
    Print(DisplayColorStr(NewColor));
    SetC(7);
    GetColor := NewColor;
  END;

  PROCEDURE SystemColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    Counter,
    NewColor: Byte;
  BEGIN
    REPEAT
      Cls;
	  Print(PadLeftStr('^2 '#240' Color Scheme Editor',80));
      FOR Counter := 1 TO 10 DO
      BEGIN
        SetC(7);
        Prompt(PadRightInt((Counter - 1),1)+#242+' '+PadLeftStr(ColorDesc[Counter - 1],18)+': ');
        SetC(TempScheme1.Color[Counter]);
        Print(DisplayColorStr(Scheme.Color[Counter]));
      END;

	    Print('%LF^0Q'+#242+' Quit');
      LOneK('%LF^0Change Which Color? [^10^0-^19^0,^1Q^0]: ',Cmd1,'0123456789Q',TRUE,TRUE);
      IF (Cmd1 IN ['0'..'9']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LF^0Is This Correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) - Ord('0') + 1] := NewColor;
          Changed := TRUE;
        END;
      END;
    UNTIL (Cmd1 = 'Q') OR (HangUp);
  END;
(*
  PROCEDURE FileColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    F: FileInfoRecordType;
    NewColor: Byte;
  BEGIN
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      FileAreaNameDisplayed := FALSE;
      DisplayFileAreaHeader;
      WITH F DO
      BEGIN
        FileName := 'RENEGADE.ZIP';
        Description := 'Latest version of Renegade!';
        FilePoints := 0;
        Downloaded := 0;
        FileSize := 2743;
        OwnerNum := 1;
        OwnerName:= 'Exodus';
        FileDate := Date2Pd(DateStr);
        VPointer := -1;
        VTextSize := 0;
        FIFlags := [];
      END;
      lDisplay_File(F,1,'',FALSE);
      PrintACR(PadLeftStr('',28)+'This is the latest version available');
      PrintACR(PadLeftStr('',28)+'Uploaded by: Exodus');
      WITH F DO
      BEGIN
        FileName := 'RG      .ZIP';
        Description := 'Latest Renegade upgrade.';
        FilePoints := 0;
        Downloaded := 0;
        FileSize := 2158;
        OwnerNum := 2;
        OwnerName := 'Nuclear';
        FileDate := Date2PD(DateStr);
        VPointer := -1;
        VTextSize := 0;
        FIFlags := [];
      END;
      lDisplay_File(F,2,'RENEGADE',FALSE);
      PrintACR(PadLeftStr('',28)+'This is the latest upgrade available');
      PrintACR(PadLeftStr('',28)+'Uploaded by: Nuclear');
      NL;
      LCmds3(20,3,'A Border','B File Name field','C Pts Field');
      LCmds3(20,3,'D Size field','E Desc Field','F Area field');
      NL;
      LCmds3(20,3,'G File name','H File Points','I File size');
      LCmds3(20,3,'J File desc','K Extended','L Status flags');
      LCmds(20,3,'M Uploader','N Search Match');
      LOneK('%LFFile color to change [^5A^4-^5N^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'ABCDEFGHIJKLMN',TRUE,TRUE);
      IF (Cmd1 IN ['A'..'N']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) - 54] := NewColor;
          Changed := TRUE;
        END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
  END;

  PROCEDURE MsgColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    NewColor: Byte;
  BEGIN
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      CLS; { starts at color 28 }
      PrintACR('旼컴컴컴쩡컴컴컴커');
      PrintACR('? Msg# ? Sender            ? Receiver           ?  '+
               'Subject           ?! Posted ?');
      PrintACR('읕컴컴컨컴컴컴컴컴컴컴컴컴좔컴컴컴켸');
      PrintACR('''* "2#      Exodus              $Nuclear              %Re: Renegade       &01/01/93');
      PrintACR('''> "3#      Nuclear             $Exodus               %RG Update          &01/01/93');
      NL;
      LCmds3(20,3,'A Border','B Msg Num field','C Sender Field');
      LCmds3(20,3,'D Receiver field','E Subject Field','F Date field');
      NL;
      LCmds3(20,3,'G Msg Num','H Msg Sender','I Msg Receiver');
      LCmds3(20,3,'J Subject','K Msg Date','L Status flags');
      LOneK('%LFMessage color to change [^5A^4-^5L^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'ABCDEFGHIJKL',TRUE,TRUE);
      IF (Cmd1 IN ['A'..'L']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) - 37] := NewColor;
          Changed := TRUE;
        END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
  END;

  PROCEDURE FileAreaColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    NewColor: Byte;
    FArea,
    NumFAreas: Integer;
    SaveConfSystem: Boolean;
  BEGIN
    SaveConfSystem := ConfSystem;
    ConfSystem := FALSE;
    IF (SaveConfSystem) THEN
      NewCompTables;
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      Farea := 1;
      NumFAreas := 0;
      LFileAreaList(FArea,NumFAreas,10,TRUE);   { starts at 45 }
      NL;
      LCmds3(20,3,'A Border','B Base Num field','C Base Name Field');
      NL;
      LCmds3(20,3,'D Scan Indicator','E Base Number','F Base Name');
      LOneK('%LFFile area color to change [^5A^4-^5F^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'ABCDEF',TRUE,TRUE);
      IF (Cmd1 IN ['A'..'F']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) - 20] := NewColor;
          Changed := TRUE;
        END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
    ConfSystem := SaveConfSystem;
    IF (SaveConfSystem) THEN
      NewCompTables;
  END;

  PROCEDURE MsgAreaColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    NewColor: Byte;
    MArea,
    NumMAreas: Integer;
  BEGIN
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      MArea := 1;
      NumMAreas := 0;
      MessageAreaList(MArea,NumMAreas,5,TRUE);   { starts at 55 }
      NL;
      LCmds3(20,3,'A Border','B Base Num field','C Base Name Field');
      NL;
      LCmds3(20,3,'D Scan Indicator','E Base Number','F Base Name');
      LOneK('%LFMessage area color to change [^5A^4-^5F^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'ABCDEF',TRUE,TRUE);
      IF (Cmd1 IN ['A'..'F']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) - 10] := NewColor;
        END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
  END;

  PROCEDURE QWKColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    NewColor: Byte;
  BEGIN
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      CLS;  { starts at 115 }
      Print(Centre('|The QWKSystem is now gathering mail.'));
      NL;
      PrintACR('s旼컴컴쩡컴컴컴컴컴컴컴컴컴컴컴쩡컴컴컴컴컴컴쩡컴컴커');
      PrintACR('s?t Num s?u Message base name     s?v  Short  s?w Echo s?x  Total  '+
               's?y New s?z Your s?{ Size s?');
      PrintACR('s읕컴컴좔컴컴컴컴컴컴컴컴컴컴컴좔컴컴컴컴컴컴좔컴컴켸');
      PrintACR('   }1    ~General                 GENERAL    No      530     328    13    103k');
      PrintACR('   }2    ~Not so general          NSGEN      No      854      86    15     43k');
      PrintACR('   }3    ~Vague                   VAGUE      No      985     148     8     74k');
      NL;
      LCmds3(20,3,'A Border','B Base num field','C Base name field');
      LCmds3(20,3,'D Short field','E Echo field','F Total field');
      LCmds3(20,3,'G New field','H Your field','I Size field');
      NL;
      LCmds3(20,3,'J Title','K Base Number','L Base name');
      LCmds3(20,3,'M Short','N Echo flag','O Total Msgs');
      LCmds3(20,3,'P New Msgs','R Your Msgs','S Msgs size');
      LOneK('%LFQWK color to change [^5A^4-^5S^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'ABCDEFGHIJKLMNOPRS'^M,TRUE,TRUE);
      IF (Cmd1 IN ['A'..'P','R'..'S']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
          IF (Cmd1 < 'Q') THEN
          BEGIN
            TempScheme1.Color[Ord(Cmd1) + 50] := NewColor;
            Changed := TRUE;
          END
          ELSE
          BEGIN
            TempScheme1.Color[Ord(Cmd1) + 49] := NewColor;
            Changed := TRUE;
          END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
  END;

  PROCEDURE EmailColors(VAR TempScheme1: SchemeRec; Cmd1: Char; VAR Changed: Boolean);
  VAR
    NewColor: Byte;
  BEGIN
    REPEAT
      Abort := FALSE;
      Next := FALSE;
      CLS;   { starts at 135 }
      PrintACR('旼컴컴쩡컴컴컴컴컴컴컫컴컴컴컴컴컴컴컴컴컴컴컴컴?');
      PrintACR('? Num ? Date/Time         ? Sender                 ? Subject                  ?');
      PrintACR('읕컴컴좔컴컴컴컴컴컴컴컨컴컴컴컴컴컴컴컴컴컴컴컴컴?');
      PrintACR('    1  01 Jan 1993  01:00a Exodus                   Renegade');
      PrintACR('    1  01 Jan 1993  01:00a Nuclear                  Upgrades');
      NL;
      LCmds3(20,3,'A Border','B Number field','C Date/Time field');
      LCmds(20,3,'D Sender field','E Subject field');
      NL;
      LCmds3(20,3,'F Number','G Date/Time','H Sender');
      LCmds(20,3,'I Subject','');
      LOneK('%LFEmail color to change [^5A^4-^5I^4,^5<CR>^4=^5Quit^4]: ',Cmd1,^M'QABCDEFGHI',TRUE,TRUE);
      IF (Cmd1 IN ['A'..'I']) THEN
      BEGIN
        NewColor := GetColor;
        IF PYNQ('%LFIs this correct? ',0,FALSE) THEN
        BEGIN
          TempScheme1.Color[Ord(Cmd1) + 70] := NewColor;
          Changed := TRUE;
        END;
      END;
    UNTIL (Cmd1 = ^M) OR (HangUp);
  END;
*)
  PROCEDURE InitSchemeVars(VAR Scheme: SchemeRec);
  BEGIN
    WITH Scheme DO
    BEGIN
      Description := '<< New Color Scheme >>';
      FillChar(Color,SizeOf(Color),7);
      Color[1] := 7;
      Color[2] := 15;
      Color[3] := 31;
      Color[4] := 7;
      Color[5] := 8;
      Color[6] := 7;
      Color[7] := 127;
      Color[8] := 93;
      Color[9] := 12;
      Color[10] := 10;
    END;
  END;

  PROCEDURE DeleteScheme(TempScheme1: SchemeRec; RecNumToDelete: Integer);
  VAR
    User: UserRecordType;
    RecNum: Integer;
  BEGIN
    IF (NumSchemes = 0) THEN
      Messages(4,0,'color schemes')
    ELSE
    BEGIN
      RecNumToDelete := -1;
      InputIntegerWOC('%LFColor scheme to delete',RecNumToDelete,[NumbersOnly],1,NumSchemes);
      IF (RecNumToDelete >= 1) AND (RecNumToDelete <= NumSchemes) THEN
      BEGIN
        Reset(SchemeFile);
        Seek(SchemeFile,(RecNumToDelete - 1));
        Read(SchemeFile,TempScheme1);
        Close(SchemeFile);
        LastError := IOResult;
        Print('%LFColor scheme: ^5'+TempScheme1.Description);
        IF PYNQ('%LFAre you sure you want to delete it? ',0,FALSE) THEN
        BEGIN
          Print('%LF[> Deleting color scheme record ...');
          Dec(RecNumToDelete);
          Reset(SchemeFile);
          IF (RecNumToDelete >= 0) AND (RecNumToDelete <= (FileSize(SchemeFile) - 2)) THEN
            FOR RecNum := RecNumToDelete TO (FileSize(SchemeFile) - 2) DO
            BEGIN
              Seek(SchemeFile,(RecNum + 1));
              Read(SchemeFile,Scheme);
              Seek(SchemeFile,RecNum);
              Write(SchemeFile,Scheme);
            END;
          Seek(SchemeFile,(FileSize(SchemeFile) - 1));
          Truncate(SchemeFile);
          Close(SchemeFile);
          LastError := IOResult;
          Dec(NumSchemes);
          SysOpLog('* Deleted color scheme: ^5'+TempScheme1.Description);
          Inc(RecNumToDelete);
          Print('%LFUpdating user records ...');
          Reset(UserFile);
          RecNum := 1;
          WHILE (RecNum < FileSize(UserFile)) DO
          BEGIN
            LoadURec(User,RecNum);
            IF (User.ColorScheme = RecNumToDelete) THEN
            BEGIN
              User.ColorScheme := 1;
              SaveURec(User,RecNum);
            END
            ELSE IF (User.ColorScheme > RecNumTodelete) THEN
            BEGIN
              Dec(User.ColorScheme);
              SaveURec(User,RecNum);
            END;
            Inc(RecNum);
          END;
          Close(UserFile);
          LastError := IOResult;
        END;
      END;
    END;
  END;

  PROCEDURE CheckScheme(Scheme: SchemeRec; StartErrMsg,EndErrMsg: Byte; VAR Ok: Boolean);
  VAR
    Counter: Byte;
  BEGIN
    FOR Counter := StartErrMsg TO EndErrMsg DO
      CASE Counter OF
        1 : IF (Scheme.Description = '') OR (Scheme.Description = '<< New Color Scheme >>') THEN
            BEGIN
              Print('%LF^8ERROR: Invalid Description!^0');
              OK := FALSE;
            END;
      END;
  END;

  PROCEDURE EditScheme(TempScheme1: SchemeRec; VAR Scheme: SchemeRec; VAR Cmd1: Char;
                            VAR RecNumToEdit: Integer; VAR Changed: Boolean; Editing: Boolean);
  VAR
    CmdStr: AStr;
    Ok: Boolean;
	
  BEGIN
    WITH Scheme DO
      REPEAT
        IF (Cmd1 <> '?') THEN
        BEGIN
          Abort := FALSE;
          Next := FALSE;
          CLS;
          IF (Editing) THEN
            Print(PadLeftStr('^2 '#240' Editing Color Scheme #'+IntToStr(RecNumToEdit),80)) {IntToStr(NumSchemes)}
          ELSE
            Print(PadLeftStr('^2 '#240' Inserting Color Scheme #'+IntToStr(RecNumToEdit),80)); {IntToStr(NumSchemes+1)}
          {NL;}
          PrintACR('^01'+#242+' Description : ^1'+Scheme.Description);
            Prompt('^02'+#242+' Colors      : ');
          ShowColors;
		  {
		  print(inttostr(Scheme.Color[1]));
		  print(inttostr(Scheme.Color[2]));
		  print(inttostr(Scheme.Color[3]));
		  print(inttostr(Scheme.Color[4]));
		  print(inttostr(Scheme.Color[5]));
		  print(inttostr(Scheme.Color[6]));
		  print(inttostr(Scheme.Color[7]));
		  print(inttostr(Scheme.Color[8]));
		  print(inttostr(Scheme.Color[9]));
		  print(inttostr(Scheme.Color[10]));
		  }
		  
          {PrintACR('^13. File listings');
          PrintACR('^14. Message listings');
          PrintACR('^15. File area listings');
          PrintACR('^16. Message area listings');
          PrintACR('^17. Offline mail screen');
          PrintACR('^18. Private mail listing');}
        END;
        IF (NOT Editing) THEN
          CmdStr := '12345678'
        ELSE
          CmdStr := '12345678[]FJL';
        LOneK('%LF^0Color Scheme Editor [(^1?^0)Help]: ',Cmd1,'Q?'+CmdStr++^M,TRUE,TRUE);
        CASE Cmd1 OF
          '1' : REPEAT
                  TempScheme1.Description := Description;
                  Ok := TRUE;
                  InputWN1('%LF^0New Description: ',Description,(SizeOf(Description) - 1),[InterActiveEdit],Changed);
                  CheckScheme(Scheme,1,1,Ok);
                  IF (NOT Ok) THEN
                    Description := TempScheme1.Description;
                UNTIL (Ok) OR (HangUp);
          '2' : SystemColors(Scheme,Cmd1,Changed);
          {'3' : FileColors(Scheme,Cmd1,Changed);
          '4' : MsgColors(Scheme,Cmd1,Changed);
          '5' : FileAreaColors(Scheme,Cmd1,Changed);
          '6' : MsgAreaColors(Scheme,Cmd1,Changed);
          '7' : QWKColors(Scheme,Cmd1,Changed);
          '8' : EmailColors(Scheme,Cmd1,Changed);}
          '[' : IF (RecNumToEdit > 1) THEN
                  Dec(RecNumToEdit)
                ELSE
                BEGIN
                  Messages(2,0,'');
                  Cmd1 := #0;
                END;
          ']' : IF (RecNumToEdit < NumSchemes) THEN
                  Inc(RecNumToEdit)
                ELSE
                BEGIN
                  Messages(3,0,'');
                  Cmd1 := #0;
                END;
          'F' : IF (RecNumToEdit <> 1) THEN
                  RecNumToEdit := 1
                ELSE
                BEGIN
                  Messages(2,0,'');
                  Cmd1 := #0;
                END;
          'J' : BEGIN
                  InputIntegerWOC('%LF^0Jump To Which Entry?',RecNumToEdit,[NumbersOnly],1,NumSchemes);
                  IF (RecNumToEdit < 1) OR (RecNumToEdit > NumSchemes) THEN
                    Cmd1 := #0;
                END;
          'L' : IF (RecNumToEdit <> NumSchemes) THEN
                  RecNumToEdit := NumSchemes
                ELSE
                BEGIN
                  Messages(3,0,'');
                  Cmd1 := #0;
                END;
          '?' : BEGIN
				  NL;
                  Print('^0<^1CR^0> Refresh Screen');
                  IF (NOT Editing) THEN
                    LCmds(22,1,'? Help','Q Quit')
                  ELSE
                  BEGIN
                    LCmds(22,1,'[ Previous Entry','] Next Entry');
                    LCmds(22,1,'F First Entry In List','J Jump To Entry');
                    LCmds(22,1,'L Last Entry In List','Q Quit');
                  END;
                END;
        END;
      UNTIL (Pos(Cmd1,'Q[]FJL') <> 0) OR (HangUp);
  END;

  PROCEDURE InsertScheme(TempScheme1: SchemeRec; Cmd1: Char; RecNumToInsertBefore: Integer);
  VAR
    User: UserRecordType;
    RecNum,
    RecNumToEdit: Integer;
    Ok,
    Changed: Boolean;
  BEGIN
    IF (NumSchemes = MaxSchemes) THEN
      Messages(5,MaxSchemes,'color schemes')
    ELSE
    BEGIN
      RecNumToInsertBefore := -1;
      InputIntegerWOC('%LF^0Insert Before Which Color Scheme?',RecNumToInsertBefore,[NumbersOnly],1,(NumSchemes + 1));
      IF (RecNumToInsertBefore >= 1) AND (RecNumToInsertBefore <= (NumSchemes + 1)) THEN
      BEGIN
        Reset(SchemeFile);
        InitSchemeVars(TempScheme1);
        IF (RecNumToInsertBefore = 1) THEN
          RecNumToEdit := 1
        ELSE IF (RecNumToInsertBefore = (NumSchemes + 1)) THEN
          RecNumToEdit := (NumSchemes + 1)
        ELSE
          RecNumToEdit := RecNumToInsertBefore;
        REPEAT
          OK := TRUE;
          EditScheme(TempScheme1,TempScheme1,Cmd1,RecNumToEdit,Changed,FALSE);
          CheckScheme(TempScheme1,1,1,Ok);
          IF (NOT OK) THEN
            IF (NOT PYNQ('%LF^0Continue Inserting Color Scheme? ',0,TRUE)) THEN
              Abort := TRUE;
        UNTIL (OK) OR (Abort) OR (HangUp);
        IF (NOT Abort) AND (PYNQ('%LF^0Save This Color Scheme? ',0,FALSE)) THEN
        BEGIN
          Print('%LF^9[> Saving ...');
          Seek(SchemeFile,FileSize(SchemeFile));
          Write(SchemeFile,Scheme);
          Dec(RecNumToInsertBefore);
          FOR RecNum := ((FileSize(SchemeFile) - 1) - 1) DOWNTO RecNumToInsertBefore DO
          BEGIN
            Seek(SchemeFile,RecNum);
            Read(SchemeFile,Scheme);
            Seek(SchemeFile,(RecNum + 1));
            Write(SchemeFile,Scheme);
          END;
          FOR RecNum := RecNumToInsertBefore TO ((RecNumToInsertBefore + 1) - 1) DO
          BEGIN
            Seek(SchemeFile,RecNum);
            Write(SchemeFile,TempScheme1);
            Inc(NumSchemes);
            SysOpLog('* Added Color Scheme: '+TempScheme1.Description);
          END;
        END;
        Close(SchemeFile);
        LastError := IOResult;
        Inc(RecNumToInsertBefore);
        Print('%LF^9[> Updating User Records ...');
        Reset(UserFile);
        RecNum := 1;
        WHILE (RecNum < FileSize(UserFile)) DO
        BEGIN
          LoadURec(User,RecNum);
          IF (User.ColorScheme >= RecNumToInsertBefore) THEN
          BEGIN
            Inc(User.ColorScheme);
            SaveURec(User,RecNum);
          END;
          Inc(RecNum);
        END;
        Close(UserFile);
        LastError := IOResult;
      END;
    END;
  END;

  PROCEDURE ModifyScheme(TempScheme1: SchemeRec; Cmd1: Char; RecNumToEdit: Integer);
  VAR
    SaveRecNumToEdit: Integer;
    Ok,
    Changed: Boolean;
  BEGIN
    IF (NumSchemes = 0) THEN
      Messages(4,0,'color schemes')
    ELSE
    BEGIN
      RecNumToEdit := -1;
      InputIntegerWOC('%LF^0Modify Which Color Scheme?',RecNumToEdit,[NumbersOnly],1,NumSchemes);
      IF (RecNumToEdit >= 1) AND (RecNumToEdit <= NumSchemes) THEN
      BEGIN
        SaveRecNumToEdit := -1;
        Cmd1 := #0;
        Reset(SchemeFile);
        WHILE (Cmd1 <> 'Q') AND (NOT HangUp) DO
        BEGIN
          IF (RecNumToEdit <> SaveRecNumToEdit) THEN
          BEGIN
            Seek(SchemeFile,(RecNumToEdit - 1));
            Read(SchemeFile,Scheme);
            SaveRecNumToEdit := RecNumToEdit;
            Changed := FALSE;
          END;
          REPEAT
            Ok := TRUE;
            EditScheme(TempScheme1,Scheme,Cmd1,RecNumToEdit,Changed,TRUE);
            CheckScheme(Scheme,1,1,Ok);
            IF (NOT OK) THEN
            BEGIN
              PauseScr(FALSE);
              IF (RecNumToEdit <> SaveRecNumToEdit) THEN
                RecNumToEdit := SaveRecNumToEdit;
            END;
          UNTIL (Ok) OR (HangUp);
          IF (Changed) THEN
          BEGIN
            Seek(SchemeFile,(SaveRecNumToEdit - 1));
            Write(SchemeFile,Scheme);
            SysOpLog('* Modified color scheme: ^5'+Scheme.Description);
          END;
        END;
        Close(SchemeFile);
        LastError := IOResult;
      END;
    END;
  END;

  PROCEDURE PositionScheme(TempScheme1: SchemeRec);
  VAR
    User: UserRecordType;
    RecNumToPosition,
    RecNumToPositionBefore,
    RecNum1,
    RecNum2: Integer;
  BEGIN
    IF (NumSchemes = 0) THEN
      Messages(4,0,'color schemes')
    ELSE IF (NumSchemes = 1) THEN
      Messages(6,0,'color schemes')
    ELSE
    BEGIN
      RecNumToPosition := -1;
      InputIntegerWOC('%LF^0Position Which Color Scheme?',RecNumToPosition,[NumbersOnly],1,NumSchemes);
      IF (RecNumToPosition >= 1) AND (RecNumToPosition <= NumSchemes) THEN
      BEGIN
        RecNumToPositionBefore := -1;
        InputIntegerWOC('%LF^0Position Before Which Color Scheme?',RecNumToPositionBefore,[NumbersOnly],1,(NumSchemes + 1));
        IF (RecNumToPositionBefore >= 1) AND (RecNumToPositionBefore <= (NumSchemes + 1)) AND
           (RecNumToPositionBefore <> RecNumToPosition) AND (RecNumToPositionBefore <> (RecNumToPosition + 1)) THEN
        BEGIN
          Print('%LF^9[> Positioning ...');
          Reset(SchemeFile);
          IF (RecNumToPositionBefore > RecNumToPosition) THEN
            Dec(RecNumToPositionBefore);
          Dec(RecNumToPosition);
          Dec(RecNumToPositionBefore);
          Seek(SchemeFile,RecNumToPosition);
          Read(SchemeFile,TempScheme1);
          RecNum1 := RecNumToPosition;
          IF (RecNumToPosition > RecNumToPositionBefore) THEN
            RecNum2 := -1
          ELSE
            RecNum2 := 1;
          WHILE (RecNum1 <> RecNumToPositionBefore) DO
          BEGIN
            IF ((RecNum1 + RecNum2) < FileSize(SchemeFile)) THEN
            BEGIN
              Seek(SchemeFile,(RecNum1 + RecNum2));
              Read(SchemeFile,Scheme);
              Seek(SchemeFile,RecNum1);
              Write(SchemeFile,Scheme);
            END;
            Inc(RecNum1,RecNum2);
          END;
          Seek(SchemeFile,RecNumToPositionBefore);
          Write(SchemeFile,TempScheme1);
          Close(SchemeFile);
          LastError := IOResult;
          Inc(RecNumToPosition);
          Inc(RecNumToPositionBefore);
          Print('%LF^9 [> Updating User Records ...');
          Reset(UserFile);
          RecNum1 := 1;
          WHILE (RecNum1 < FileSize(UserFile)) DO
          BEGIN
            LoadURec(User,RecNum1);
            IF (User.ColorScheme = RecNumToPosition) THEN
            BEGIN
              User.ColorScheme := RecNumToPositionBefore;
              SaveURec(User,RecNum1);
            END
            ELSE IF (User.ColorScheme = RecNumToPositionBefore) THEN
            BEGIN
              User.ColorScheme := RecNumToPosition;
              SaveURec(User,RecNum1);
            END;
            Inc(RecNum1);
          END;
          Close(UserFile);
          LastError := IOResult;
        END;
      END;
    END;
  END;

  PROCEDURE ListSchemes(VAR RecNumToList1: Integer);
  VAR
    NumDone: Integer;
  BEGIN
    IF (RecNumToList1 < 1) OR (RecNumToList1 > NumSchemes) THEN
      RecNumToList1 := 1;
    Abort := FALSE;
    Next := FALSE;
    CLS;
	Print(PadLeftStr('^2 '#240' Color Scheme Editor',80));
    PrintACR('^4+----+--------------------------------------------------+---------------------+');
	PrintACR('^4| ^3## ^4| ^3Description                                      ^4| ^3Colors              ^4|');
    PrintACR('^4+----+--------------------------------------------------+---------------------+');
    Reset(SchemeFile);
    NumDone := 0;
    WHILE (NumDone < (PageLength - 5)) AND (RecNumToList1 >= 1) AND (RecNumToList1 <= NumSchemes)
          AND (NOT Abort) AND (NOT HangUp) DO
    BEGIN
      Seek(SchemeFile,(RecNumToList1 - 1));
      Read(SchemeFile,Scheme);
      WITH Scheme DO
        Prompt('  ^0'+PadLeftInt(RecNumToList1,3)+
               '  ^1'+PadLeftStr(Description,49)+
               '  ^0');
      ShowColors;
      Inc(RecNumToList1);
      Inc(NumDone);
	  
	  { LeeW: this is loading each scheme to show the desc, colors, thereby affecting how each one displays }
    END;
    Close(SchemeFile);
    LastError := IOResult;
    IF (NumSchemes = 0) THEN
      Print('^8  [ NO COLOR SCHEMES DEFINED ]');
  END;

BEGIN
  SaveTempPause := TempPause;
  TempPause := FALSE;
  RecNumToList := 1;
  Cmd := #0;
  REPEAT
    IF (Cmd <> '?') THEN
      ListSchemes(RecNumToList);
    LOneK('%LF^0Color Scheme Editor [(^1?^0)Help]: ',Cmd,'QDIMP?!'^M,TRUE,TRUE);
    CASE Cmd OF
      ^M  : IF (RecNumToList < 1) OR (RecNumToList > NumSchemes) THEN
              RecNumToList := 1;
      'D' : DeleteScheme(TempScheme,RecNumToList);
      'I' : InsertScheme(TempScheme,Cmd,RecNumToList);
      'M' : ModifyScheme(TempScheme,Cmd,RecNumToList);
      'P' : PositionScheme(TempScheme);
      '?' : BEGIN
              Print('%LF^0<^1CR^0> Next Page / Refresh');
              LCmds(22,1,'D Delete Color Scheme','I Insert Color Scheme');
              LCmds(22,1,'M Modify Color Scheme','P Position Color Scheme');
              LCmds(22,1,'? Help','Q Quit');
			  LCmds(22,1,'! More Options','');
            END;
        '!' : BEGIN
                WITH General DO REPEAT
					CLS;
					PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : More Options',80));
					PrintACR('^0(^1%^0) Chat Colors : ^1'+PadLeftInt(SysOpColor,1)+'^0 / ^1'+PadLeftInt(UserColor,1));
					NL;
					Prt('^0More Options [^1%^0,(^1Q^0)uit]: ');				  
                  OneK(Cmd,'Q%',TRUE,TRUE);
                  CASE Cmd OF
			'%' : BEGIN
					MinByte := 0;
					MaxByte := 9;
					TempB := SysOpColor;
					TempB2 := UserColor;
					InputByteWOC('^0%LFSysOp Chat Color',TempB,[NumbersOnly],MinByte,MaxByte);
					InputByteWOC('^0%LFUser Chat Color',TempB2,[NumbersOnly],MinByte,MaxByte);
					SysOpColor := TempB;
					UserColor := TempB2;
				  END;

                  END;
                UNTIL (Cmd IN ['Q']) OR (HangUp);
                Cmd := #0;
              END;
    END;
    IF (CMD <> ^M) THEN
      RecNumToList := 1;
  UNTIL (Cmd = 'Q') OR (HangUp);
  TempPause := SaveTempPause;
  IF (ThisUser.ColorScheme < 1) OR (ThisUser.ColorScheme > FileSize(SchemeFile)) THEN
    ThisUser.ColorScheme := 1;
  Reset(SchemeFile);
  Seek(SchemeFile,(ThisUser.ColorScheme - 1));
  Read(SchemeFile,Scheme);
  Close(SchemeFile);
  LastError := IOResult;
END;

END.
