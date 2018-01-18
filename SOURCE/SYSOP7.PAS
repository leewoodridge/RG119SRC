
{$A+,B+,D+,E+,F+,I+,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  -----------
  MENU EDITOR
  -----------
  ISSUES:
	- going into submenu system menus, when returning, returns to page 1 instead of where last was
}

UNIT SysOp7;

INTERFACE

USES
 Common;

PROCEDURE FindMenu(DisplayStr: AStr; VAR MenuNum: Byte; LowMenuNum, HighMenuNum: Byte; VAR Changed: Boolean);
PROCEDURE MenuEditor;

IMPLEMENTATION

USES
  Menus2,
  SysOp7M;

PROCEDURE DisplayMenus(VAR RecNumToList1: Integer; DisplayListNum: Boolean);
VAR
  NumDone: Byte;
BEGIN
  DisplayListNum := FALSE; { LeeW: No need to display both numbers }
  Abort := FALSE;
  Next := FALSE;
  AllowContinue := TRUE;
  MCIAllowed := FALSE;
  CLS;
(*  IF (DisplayListNum) THEN
  BEGIN
	PrintACR('^4+-----+--------+--------------------------------------------------------------+');
    PrintACR('^4| ^3### ^4| ^3Menu # ^4| ^3Menu Name                                                    ^4|');
    PrintACR('^4+-----+--------+--------------------------------------------------------------+');
  END
  ELSE*)
  BEGIN
	{PrintACR('^1                                                                               ')}
	PrintACR('^4+-----+-----------------------------------------------------------------------+');
	PrintACR('^4| ^3### ^4| ^3Menu Name                                                             ^4|');
	PrintACR('^4+-----+-----------------------------------------------------------------------+');
  END;
  Reset(MenuFile);
  NumDone := 0;
  WHILE (NumDone < (PageLength - 7)) AND (RecNumToList1 >= 1) AND (RecNumToList1 <= NumMenus)
        AND (NOT Abort) AND (NOT HangUp) DO
  BEGIN
    Seek(MenuFile,MenuRecNumArray[RecNumToList1]);
    Read(MenuFile,MenuR);
    WITH MenuR DO
    BEGIN
      IF (DisplayListNum) THEN
        PrintACR('  ^0'+PadLeftInt(RecNumToList1,4)+
                 '  ^0'+PadLeftInt(MenuNum,7)+
                 '  ^1'+PadLeftStr(LDesc[1],62))
      ELSE
        PrintACR('  ^0'+PadLeftInt(MenuNum,4)+
                 '  ^1'+PadLeftStr(LDesc[1],70));
    END;
    Inc(RecNumToList1);
    Inc(NumDone);
  END;
  Close(MenuFile);
  LastError := IOResult;
  MCIAllowed := TRUE;
  AllowContinue := FALSE;
  IF (NumMenus = 0) THEN
    Print('^8[ NO MENUS DEFINED ]');
	
	{  IF (DisplayListNum) THEN
    PrintACR('%LF^1[Users start at menu number: ^5'+IntToStr(General.AllStartMenu)+'^1]');} { LeeW: Redundant Information }
END;

PROCEDURE FindMenu(DisplayStr: AStr;
                   VAR MenuNum: Byte;
                   LowMenuNum,
                   HighMenuNum: Byte;
                   VAR Changed: Boolean);
VAR
  TempMenuR: MenuRec;
  InputStr: AStr;
  SaveMenuNum: Byte;
  RecNum,
  RecNum1,
  RecNumToList: Integer;
BEGIN
  SaveMenuNum := MenuNum;
  RecNumToList := 1;
  InputStr := '?';
  REPEAT
    IF (InputStr = '?') THEN
      DisplayMenus(RecNumToList,FALSE);
    Prt(DisplayStr+' (^5'+IntToStr(LowMenuNum)+'^4-^5'+IntToStr(HighMenuNum)+'^4)'+
        ' [^5?^4=^5First^4,^5<CR>^4=^5Next^4,^5Q^4=^5Quit^4): ');
    MPL(Length(IntToStr(NumMenus)));
    ScanInput(InputStr,'Q?'^M);
    IF (InputStr = '-') THEN
      InputStr := 'Q';
    IF (InputStr <> 'Q') THEN
    BEGIN
      IF (InputStr = ^M) THEN
      BEGIN
        InputStr := '?';
        IF (RecNumToList < 1) OR (RecNumToList > NumMenus) THEN
          RecNumToList := 1
      END
      ELSE IF (InputStr = '?') THEN
        RecNumToList := 1
      ELSE IF (StrToInt(InputStr) < LowMenuNum) OR (StrToInt(InputStr) > HighMenuNum) THEN
        Print('%LF^7The range must be from '+IntToStr(LowMenuNum)+' to '+IntToStr(HighMenuNum)+'!^1')
      ELSE IF (InputStr = '0') AND (LowMenuNum = 0) THEN
      BEGIN
        MenuNum := StrToInt(InputStr);
        InputStr := 'Q';
        Changed := TRUE;
      END
      ELSE
      BEGIN
        RecNum1 := -1;
        RecNum := 1;

        Reset(MenuFile);

        WHILE (RecNum <= NumMenus) AND (RecNum1 = -1) DO
        BEGIN
          Seek(MenuFile,MenuRecNumArray[RecNum]);
          Read(MenuFile,TempMenuR);
          IF (StrToInt(InputStr) = TempMenuR.MenuNum) THEN
            RecNum1 := TempMenuR.MenuNum;
          Inc(RecNum);
        END;

        Close(MenuFile);

        IF (RecNum1 = -1) THEN
        BEGIN
          RGNoteStr(2,FALSE);
          MenuNum := SaveMenuNum;
        END
        ELSE
        BEGIN
          MenuNum := StrToInt(InputStr);
          InputStr := 'Q';
          Changed := TRUE;
        END;
      END;
    END;
  UNTIL (InputStr = 'Q') OR (HangUp);
END;

PROCEDURE MenuEditor;
VAR
  Cmd: Char;
  SaveCurMenu: Byte;
  RecNumToList: Integer;
  SaveTempPause: Boolean;
  Changed: Boolean;

  FUNCTION DisplayMenuFlags(MenuFlags: MenuFlagSet; C1,C2: Char): AStr;
  VAR
    MenuFlagT: MenuFlagType;
    TempS: AStr;
  BEGIN
    TempS := '';
    FOR MenuFlagT := ClrScrBefore TO NoGlobalUsed DO
      IF (MenuFlagT IN MenuFlags) THEN
        TempS := TempS + '^'+C1+Copy('CDTNPAF12345',(Ord(MenuFlagT) + 1),1)
      ELSE
        TempS := TempS + '^'+C2+'-';
    DisplayMenuFlags := TempS;
  END;

  PROCEDURE ToggleMenuFlag(MenuFlagT: MenuFlagType; VAR MenuFlags: MenuFlagSet);
  BEGIN
    IF (MenuFlagT IN MenuFlags) THEN
      Exclude(MenuFlags,MenuFlagT)
    ELSE
      Include(MenuFlags,MenuFlagT);
  END;

  PROCEDURE ToggleMenuFlags(C: Char; VAR MenuFlags: MenuFlagSet; VAR Changed: Boolean);
  VAR
    TempMenuFlags: MenuFlagSet;
  BEGIN
    TempMenuFlags := MenuFlags;
    CASE C OF
      'C' : ToggleMenuFlag(ClrScrBefore,MenuFlags);
      'D' : ToggleMenuFlag(DontCenter,MenuFlags);
      'T' : ToggleMenuFlag(NoMenuTitle,MenuFlags);
      'N' : ToggleMenuFlag(NoMenuPrompt,MenuFlags);
      'P' : ToggleMenuFlag(ForcePause,MenuFlags);
      'A' : ToggleMenuFlag(AutoTime,MenuFlags);
      'F' : ToggleMenuFlag(ForceLine,MenuFlags);
      '1' : ToggleMenuFlag(NoGenericAnsi,MenuFlags);
      '2' : ToggleMenuFlag(NoGenericAvatar,MenuFlags);
      '3' : ToggleMenuFlag(NoGenericRIP,MenuFlags);
      '4' : ToggleMenuFlag(NoGlobalDisplayed,MenuFlags);
      '5' : ToggleMenuFlag(NoGlobalUsed,MenuFlags);
    END;
    IF (MenuFlags <> TempMenuFlags) THEN
      Changed := TRUE;
  END;

  PROCEDURE InitMenuVars(VAR MenuR: MenuRec);
  BEGIN
    FillChar(MenuR,SizeOf(MenuR),0);
    WITH MenuR DO
    BEGIN
      LDesc[1] := 'New Menu';
      LDesc[2] := '';
      LDesc[3] := '';
      ACS := '';
      NodeActivityDesc := '';
      Menu := TRUE;
      MenuFlags := [ClrScrBefore];
      LongMenu := '';
      MenuNum := 0;
      MenuPrompt := '^0Command? ^1';
      Password := '';
      FallBack := 0;
      Directive := '';
      ForceHelpLevel := 0;
      GenCols := 3;
      GCol[1] := 0;
      GCol[2] := 1;
      GCol[3] := 0;
    END;
  END;

  PROCEDURE DeleteMenu;
  VAR
    RecNumToDelete,
    RecNum: SmallInt;
    DeleteOk: Boolean;
  BEGIN
    IF (NumMenus = 0) THEN
      Messages(4,0,'menus')
    ELSE
    BEGIN
      RecNumToDelete := -1;
      InputIntegerWOC('%LFMenu number to delete?',RecNumToDelete,[NumbersOnly],1,NumMenus);
      IF (RecNumToDelete >= 1) AND (RecNumToDelete <= NumMenus) THEN
      BEGIN
        Reset(MenuFile);
        Seek(MenuFile,MenuRecNumArray[RecNumToDelete]);
        Read(MenuFile,MenuR);
        Close(MenuFile);
        LastError := IOResult;
        DeleteOK := TRUE;
        IF (MenuR.MenuNum = General.AllStartMenu) THEN
        BEGIN
          Print('%LFYou can not delete the menu new users start at.');
          DeleteOK := FALSE;
        END
        ELSE IF (MenuR.MenuNum = General.NewUserInformationMenu) THEN
        BEGIN
          Print('%LFYou can not delete the new user information menu.');
          DeleteOK := FALSE;
        END
        ELSE IF (MenuR.MenuNum = General.FileListingMenu) THEN
        BEGIN
          Print('%LFYou can not delete the file listing menu.');
          DeleteOK := FALSE;
        END
        ELSE IF (MenuR.MenuNum = General.MessageReadMenu) THEN
        BEGIN
          Print('%LFYou can not delete the message read menu.');
          DeleteOK := FALSE;
        END
        ELSE IF (CmdNumArray[RecNumToDelete] <> 0) THEN
        BEGIN
          Print('%LFThis menu is not empty.');
          DeleteOK := FALSE;
        END;
        IF (NOT DeleteOK) THEN
          PauseScr(FALSE)
        ELSE
        BEGIN
          Print('%LFMenu: ^5'+MenuR.LDesc[1]);
          IF PYNQ('%LFAre you sure you want to delete it? ',0,FALSE) THEN
          BEGIN
            Print('%LF[> Deleting menu record ...');
            SysOpLog('* Deleted menu: ^5'+MenuR.LDesc[1]);
            RecNumToDelete := MenuRecNumArray[RecNumToDelete];  { Convert To Real Record Number }
            Reset(MenuFile);
            IF (RecNumToDelete >= 0) AND (RecNumToDelete <= (FileSize(MenuFile) - 2)) THEN
              FOR RecNum := RecNumToDelete TO (FileSize(MenuFile) - 2) DO
              BEGIN
                Seek(MenuFile,(RecNum + 1));
                Read(MenuFile,MenuR);
                Seek(MenuFile,RecNum);
                Write(MenuFile,MenuR);
              END;
            Seek(MenuFile,(FileSize(MenuFile) - 1));
            Truncate(MenuFile);
            LoadMenuPointers;
            Close(MenuFile);
            LastError := IOResult;
          END;
        END;
      END;
    END;
  END;

  PROCEDURE InsertMenu;
  VAR
    RecNumToInsertBefore,
    NewMenuNum,
    RecNum: SmallInt;
  BEGIN
    IF (NumMenus = MaxMenus) THEN
      Messages(5,MaxMenus,'menus')
    ELSE
    BEGIN
      RecNumToInsertBefore := -1;
      InputIntegerWOC('%LFMenu number to insert before?',RecNumToInsertBefore,[NumbersOnly],1,(NumMenus + 1));
      IF (RecNumToInsertBefore >= 1) AND (RecNumToInsertBefore <= (NumMenus + 1)) THEN
      BEGIN
        Print('%LF[> Inserting menu record ...');
        SysOpLog('* Inserted 1 menu.');
        IF (RecNumToInsertBefore = (NumMenus + 1)) THEN
          MenuRecNumArray[RecNumToInsertBefore] := (MenuRecNumArray[NumMenus] + CmdNumArray[NumMenus] + 1);
        RecNumToInsertBefore := MenuRecNumArray[RecNumToInsertBefore];  {Convert To Real Record Number }
        NewMenuNum := 0;
        Reset(MenuFile);
        RecNum := 1;
        WHILE (RecNum <= NumMenus) DO
        BEGIN
          Seek(MenuFile,MenuRecNumArray[RecNum]);
          Read(MenuFile,MenuR);
          IF (MenuR.MenuNum > NewMenuNum) THEN
            NewMenuNum := MenuR.MenuNum;
          Inc(RecNum);
        END;
        FOR RecNum := 1 TO 1 DO
        BEGIN
          Seek(MenuFile,FileSize(MenuFile));
          Write(MenuFile,MenuR);
        END;
        FOR RecNum := ((FileSize(MenuFile) - 1) - 1) DOWNTO RecNumToInsertBefore DO
        BEGIN
          Seek(MenuFile,RecNum);
          Read(MenuFile,MenuR);
          Seek(MenuFile,(RecNum + 1));
          Write(MenuFile,MenuR);
        END;
        InitMenuVars(MenuR);
        FOR RecNum := RecNumToInsertBefore TO ((RecNumToInsertBefore + 1) - 1) DO
        BEGIN
          Seek(MenuFile,RecNum);
          MenuR.MenuNum := (NewMenuNum + 1);
          Write(MenuFile,MenuR);
        END;
        LoadMenuPointers;
        Close(MenuFile);
        LastError := IOResult;
      END;
    END;
  END;

  PROCEDURE ModifyMenu;
  VAR
    TempMenuR: MenuRec;
    Cmd1: Char;
    SaveMenuNum: Byte;
    RecNum,
    RecNum1,
    RecNumToModify,
    SaveRecNumToModify: SmallInt;
    Changed: Boolean;
	FallBackMenuName: STRING[100];
  BEGIN
    IF (NumMenus = 0) THEN
      Messages(4,0,'menus')
    ELSE
    BEGIN
      RecNumToModify := -1;
      InputIntegerWOC('^0%LFMenu Number To Modify?',RecNumToModify,[NumbersOnly],1,NumMenus);
      IF (RecNumToModify >= 1) AND (RecNumToModify <= NumMenus) THEN
      BEGIN
        SaveRecNumToModify := -1;
        Cmd1 := #0;
        Reset(MenuFile);
        WHILE (Cmd1 <> 'Q') AND (NOT HangUp) DO
        BEGIN
          IF (SaveRecNumToModify <> RecNumToModify) THEN
          BEGIN
            Seek(MenuFile,MenuRecNumArray[RecNumToModify]);
            Read(MenuFile,MenuR);
            SaveRecNumToModify := RecNumToModify;
            Changed := FALSE;
          END;
		  WITH MenuR Do { LeeW: Get the name of the fallback menu }
		    BEGIN
		      Seek(MenuFile,MenuRecNumArray[FallBack]);
		      Read(MenuFile,MenuR);
		      FallBackMenuName := LDesc[1];
		      Seek(MenuFile,MenuRecNumArray[RecNumToModify]);
		      Read(MenuFile,MenuR);
		    END;
          WITH MenuR DO
            REPEAT
              IF (Cmd1 <> '?') THEN
              BEGIN
                Abort := FALSE;
                Next := FALSE;
                MCIAllowed := FALSE;
                CLS;
                {PrintACR('^0Menu #^1'+IntToStr(RecNumToModify)+'^0 Of ^1'+IntToStr(NumMenus));}
				PrintACR(PadLeftStr('^2 '#254' Menu Editor : Menu #'+IntToStr(RecNumToModify)+' Of '
				+IntToStr(NumMenus)+' "'+LDesc[1]+'"',80));
                {NL;}
                PrintACR('^11^0> Menu Number     : ^1'+IntToStr(MenuNum));
                PrintACR('^12^0> Menu Title      : ^1'+LDesc[1]);
                IF (LDesc[2] <> '') THEN
					PrintACR('^0   Menu Title #2   : ^1'+LDesc[2]);
                IF (LDesc[3] <> '') THEN
					PrintACR('^0   Menu Title #3   : ^1'+LDesc[3]);
                PrintACR('^13^0> Help Files      : ^1'+AOnOff((Directive = ''),'*Generic*',Directive)+'/'+
													   AOnOff((LongMenu = ''),'*Generic*',LongMenu));
                PrintACR('^14^0> Menu Prompt     : ^1'+MenuPrompt);
                PrintACR('^15^0> ACS Required    : ^1"'+ACS+'"');
                PrintACR('^16^0> Password        : ^1'+AOnOff((Password = ''),'*None*',Password));
                PrintACR('^17^0> Fallback Menu   : ^1'+IntToStr(FallBack)+' ['+FallBackMenuName+']');
                PrintACR('^18^0> Forced Help Lvl : ^1'+AOnOff((ForceHelpLevel=0),'*None*',IntToStr(ForceHelpLevel)));
                PrintACR('^19^0> Layout / Colors : ^1'+IntToStr(GenCols)+' Columns / '+IntToStr(GCol[1])+'/'+IntToStr(GCol[2])+
                                                   '/'+IntToStr(GCol[3]));
                IF (General.MultiNode) THEN
					PrintACR('^1N^0> Node Activity   : ^1'+NodeActivityDesc);
                PrintACR('^1T^0> Flags           : ^1'+DisplayMenuFlags(MenuFlags,'1','0'));
                MCIAllowed := TRUE;
                Print('%LF^0[Commands On This Menu: ^1'+IntToStr(CmdNumArray[RecNumToModify])+'^0]');
                IF (NumMenus = 0) THEN
                  Print('^8[ NO MENUS DEFINED ]');
              END;
              IF (General.MultiNode) THEN
                LOneK('^0%LFMenu Editor [(^1C^0)ommand Editor,(^1?^0)Help]: ',Cmd1,'Q123456789CNT[]FJL?'^M,TRUE,TRUE)
              ELSE
                LOneK('^0%LFMenu Editor [(^1C^0)ommand Editor,(^1?^0)Help]: ',Cmd1,'Q123456789CT[]FJL?'^M,TRUE,TRUE);
              CASE Cmd1 OF
                '1' : BEGIN
                        REPEAT
                          SaveMenuNum := MenuNum;
                          RecNum1 := -1;
                          InputByteWC('^0%LFNew Menu Number',MenuNum,[DisplayValue,NumbersOnly],1,(NumMenus + 1),Changed);
                          IF (MenuNum <> SaveMenuNum) AND (MenuNum >= 1) AND (MenuNum <= (NumMenus + 1)) THEN
                          BEGIN
                            RecNum := 1;
                            WHILE (Recnum <= NumMenus) AND (RecNum1 = -1) DO
                            BEGIN
                              Seek(MenuFile,MenuRecNumArray[RecNum]);
                              Read(MenuFile,TempMenuR);
                              IF (MenuNum = TempMenuR.MenuNum) THEN
                                RecNum1 := TempMenuR.MenuNum;
                              Inc(RecNum);
                            END;
                            IF (RecNum1 <> -1) THEN
                            BEGIN
                              NL;
                              Print('^8Duplicate menu number!^1');
                              MenuNum := SaveMenuNum;
                            END;
                          END;
                        UNTIL (RecNum1 = -1) OR (HangUp);
                        Changed := TRUE;
                      END;
                '2' : BEGIN
                        InputWNWC('^0%LFNew Menu Title #1: ',LDesc[1],
                                  (SizeOf(LDesc[1]) - 1),Changed);
                        IF (LDesc[1] <> '') THEN
                          InputWNWC('^0New Menu Title #2: ',LDesc[2],
                                    (SizeOf(LDesc[2]) - 1),Changed);
                        IF (LDesc[2] <> '') THEN
                          InputWNWC('^0New Menu Title #3: ',LDesc[3],
                                    (SizeOf(LDesc[3]) - 1),Changed);
                      END;
                '3' : BEGIN
                        InputWN1('%LFNew Help File: ',Directive,(SizeOf(Directive) - 1),
						[InterActiveEdit,UpperOnly],Changed);
                        InputWN1('%LFNew Extended Help File: ',LongMenu,(SizeOf(LongMenu) - 1),
						[InterActiveEdit,UpperOnly],Changed);
                      END;
                '4' : InputWNWC('^0%LFNew Menu Prompt: ',MenuPrompt,(SizeOf(MenuPrompt) - 1),Changed);
                '5' : InputWN1('^0%LFNew Menu ACS: ',ACS,(SizeOf(ACS) - 1),[InterActiveEdit],Changed);
                '6' : InputWN1('^0%LFNew Password: ',Password,(SizeOf(Password) - 1),[InterActiveEdit,UpperOnly],Changed);
                '7' : BEGIN
                        SaveMenuNum := FallBack;
                        IF (Changed) THEN
                        BEGIN
                          Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                          Write(MenuFile,MenuR);
                          Changed := FALSE;
                        END;
                        Close(MenuFile);
                        FindMenu('%LFNew fallback menu (^50^4=^5None^4)',SaveMenuNum,0,NumMenus,Changed);
                        Reset(MenuFile);
                        Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                        Read(MenuFile,MenuR);
                        IF (Changed) THEN
                          FallBack := SaveMenuNum;
                      END;
                '8' : BEGIN { LeeW: }
						NL;
						PrintACR(' ^10^0 = None');
						PrintACR(' ^11^0 = Expert Level (Only Prompt)');
						PrintACR(' ^12^0 = Normal Level (Short Menu)');
						PrintACR(' ^13^0 = Novice Level (Long Menu)');
						InputByteWC('^0%LFNew Forced Help Level:',ForceHelpLevel,
						[DisplayValue,NumbersOnly],0,3,Changed);
					  END;
                '9' : BEGIN
                        REPEAT
                          NL;
                          PrintACR('^1C^0> Number Of Columns : '+IntToStr(GenCols));
                          PrintACR('^11^0> Bracket Color     : '+IntToStr(GCol[1]));
                          PrintACR('^12^0> Command Color     : '+IntToStr(GCol[2]));
                          PrintACR('^13^0> Description Color : '+IntToStr(GCol[3]));
                          PrintACR('^1S^0> Show Menu');
                          LOneK('^0%LFSelect (CS,1-3,Q=Quit): ',Cmd1,'QCS123'^M,TRUE,TRUE);
                          CASE Cmd1 OF
                            'S' : BEGIN
                                    IF (Changed) THEN
                                    BEGIN
                                      Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                                      Write(MenuFile,MenuR);
                                      Changed := FALSE;
                                    END;
                                    Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                                    Read(MenuFile,MenuR);
                                    CurMenu := MenuR.MenuNum;
                                    LoadMenu;
                                    Reset(MenuFile);
                                    GenericMenu(2);
                                    NL;
                                    PauseSCR(FALSE);
                                    Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                                    Read(MenuFile,MenuR);
                                  END;
                            'C' : InputByteWC('%LFNew number of generic columns'
							      ,GenCols,[DisplayValue,NumbersOnly],0,7,Changed);
                            '1' : InputByteWC('^0%LFNew Bracket Color',GCol[1],[DisplayValue,NumbersOnly],0,9,Changed);
                            '2' : InputByteWC('^0%LFNew Command Color',GCol[2],[DisplayValue,NumbersOnly],0,9,Changed);
                            '3' : InputByteWC('^0%LFNew Description Color',GCol[3],[DisplayValue,NumbersOnly],0,9,Changed);
                          END;
                        UNTIL (Cmd1 IN ['Q',^M]) OR (HangUp);
                        Cmd1 := #0;
                      END;
                'C' : BEGIN
                        IF (Changed) THEN
                        BEGIN
                          Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
                          Write(MenuFile,MenuR);
                          Changed := FALSE;
                        END;
                        CommandEditor(RecNumToModify,MenuNum,LDesc[1]);
                        SaveRecNumToModify := -1;
                      END;
                'N' : IF (General.MultiNode) THEN
                        InputWNWC('^0%LFNew Node Activity Description :%LF',NodeActivityDesc,
                                  (SizeOf(NodeActivityDesc) - 1),Changed);
                'T' : BEGIN
                        REPEAT
                          LOneK('^0%LFToggle Which Flag? ('+DisplayMenuFlags(MenuFlags,'1','0')+'^0)'+
                                ' [(^1?^0)Help,<^1CR^0>Quit]: ',Cmd1,^M'CDTNPAF12345?',TRUE,TRUE);
                          CASE Cmd1 OF
                            'C','D','T','N','P','A','F','1'..'5' :
                                    ToggleMenuFlags(Cmd1,MenuFlags,Changed);
                            '?' : BEGIN
                                    NL;
                                    LCmds(21,1,'C Clear Screen',		'D Don''t Center Titles');
                                    LCmds(21,1,'N No Menu Prompt',		'P Pause Before Display');
                                    LCmds(21,1,'A Auto Time Display',	'F Force Line Input');
                                    LCmds(21,1,'T No Menu Titles',		'1 No ANS Prompt');
                                    LCmds(21,1,'2 No AVT Prompt',		'3 No RIP Prompt');
                                    LCmds(21,1,'4 No Global Display',	'5 No Global Use');
                                  END;
                          END;
                        UNTIL (Cmd1 = ^M) OR (HangUp);
                        Cmd1 := #0;
                      END;
                '[' : IF (RecNumToModify > 1) THEN
                        Dec(RecNumToModify)
                      ELSE
                      BEGIN
                        Messages(2,0,'');
                        Cmd1 := #0;
                      END;
                ']' : IF (RecNumToModify < NumMenus) THEN
                        Inc(RecNumToModify)
                      ELSE
                      BEGIN
                        Messages(3,0,'');
                        Cmd1 := #0;
                      END;
                'F' : IF (RecNumToModify <> 1) THEN
                        RecNumToModify := 1
                      ELSE
                      BEGIN
                        Messages(2,0,'');
                        Cmd1 := #0;
                      END;
                'J' : BEGIN
                        InputIntegerWOC('^0%LFJump To Which Entry?',RecNumToModify,[NumbersOnly],1,NumMenus);
                        IF (RecNumToModify < 1) AND (RecNumToModify > NumMenus) THEN
                          Cmd1 := #0;
                      END;
                'L' : IF (RecNumToModify <> NumMenus) THEN
                        RecNumToModify := NumMenus
                      ELSE
                      BEGIN
                        Messages(3,0,'');
                        Cmd1 := #0;
                      END;
                '?' : BEGIN
                        {Print('%LF^1<^3CR^1>Redisplay screen');
                        Print('^31-9,C,N,T^1:Modify item');} {LeeW: }
                        LCmds(18,1,'[ Previous Entry','] Next Entry');
                        LCmds(18,1,'F First Entry','L Last Entry');
						LCmds(18,1,'C Command Editor','J Jump To Entry');
                        LCmds(18,1,'Q Quit','');
                      END;
              END;
            UNTIL (Pos(Cmd1,'QC[]FJL') <> 0) OR (HangUp);
          IF (Changed) THEN
          BEGIN
            Seek(MenuFile,MenuRecNumArray[SaveRecNumToModify]);
            Write(MenuFile,MenuR);
            Changed := FALSE;
            SysOpLog('* Modified menu: '+Menur.LDesc[1]);
          END;
        END;
        Close(MenuFile);
        LastError := IOResult;
      END;
    END;
  END;

BEGIN
  LoadMenuPointers;
  SaveTempPause := TempPause;
  TempPause := FALSE;
  RecNumToList := 1;
  Cmd := #0;
  REPEAT
    IF (Cmd <> '?') THEN
      DisplayMenus(RecNumToList,TRUE);
	Nl;
	
	{LeeW: printacr(inttostr(recnumtolist-1)+' '+inttostr(nummenus)+' '); divide to figure out num pages}
	
    LOneK('^0Menu Editor [^1DIMS^0,(^1?^0)Help,(^1Q^0)uit]: ',Cmd,'QDIM?S'^M,TRUE,TRUE);
    CASE Cmd OF
      ^M  : IF (RecNumToList < 1) OR (RecNumToList > NumMenus) THEN
              RecNumToList := 1;
      'D' : DeleteMenu;
      'I' : InsertMenu;
      'M' : ModifyMenu;
	  'S' : BEGIN
                WITH General DO 
				  REPEAT
				  CLS;
				  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : System Menus',80));
				  PrintACR('^0Here you can define which menus are used for various functions on your BBS.');
				  NL;
				PrintACR('^0(^11^0) Global Commands      : ^1'+IntToStr(GlobalMenu)+'');
				PrintACR('^0(^12^0) Start                : ^1'+IntToStr(AllStartMenu)+'');
				PrintACR('^0(^13^0) Shuttle Logon        : ^1'+IntToStr(ShuttleLogonMenu));
				PrintACR('^0(^14^0) New User Information : ^1'+IntToStr(NewUserInformationMenu));
				PrintACR('^0(^15^0) Reading Messages     : ^1'+IntToStr(MessageReadMenu));
				PrintACR('^0(^16^0) Listing Files        : ^1'+IntToStr(FileListingMenu));
				NL;
				Prt('^0System Menus [^11^0-^16^0,(^1Q^0)uit]: ');				  
                  OneK(Cmd,'123456Q',TRUE,TRUE);
                  CASE Cmd OF
                    '1' : FindMenu(RGSysCfgStr(16,TRUE),GlobalMenu,0,NumMenus,Changed);
                    '2' : FindMenu(RGSysCfgStr(17,TRUE),AllStartMenu,1,NumMenus,Changed);
                    '3' : FindMenu(RGSysCfgStr(18,TRUE),ShuttleLogonMenu,0,NumMenus,Changed);
                    '4' : FindMenu(RGSysCfgStr(19,TRUE),NewUserInformationMenu,1,NumMenus,Changed);
                    '5' : FindMenu(RGSysCfgStr(20,TRUE),MessageReadMenu,1,NumMenus,Changed);
                    '6' : FindMenu(RGSysCfgStr(21,TRUE),FileListingMenu,1,NumMenus,Changed);
                  END;
                UNTIL (Cmd IN ['Q']) OR (HangUp);
                Cmd := #0;
              END;
      '?' : BEGIN
			  Nl;
              Print('^0<^1CR^0> Next Page / Refresh');
              LCmds(14,1,'D Delete Menu','I Insert Menu');
              LCmds(14,1,'M Modify Menu','Q Quit');
			  LCmds(14,1,'S System Menus','')
            END;
    END;
    IF (CMD <> ^M) THEN
      RecNumToList := 1;
  UNTIL (Cmd = 'Q') OR (HangUp);
  TempPause := SaveTempPause;
  LastError := IOResult;
  LoadMenuPointers;
  IF (UserOn) THEN {LeeW: What's with this?}
  BEGIN
    SaveCurMenu := CurMenu;
    NumCmds := 0;
    GlobalCmds := 0;
    IF (General.GlobalMenu > 0) THEN
    BEGIN
      CurMenu := General.GlobalMenu;
      LoadMenu;
      GlobalCmds := NumCmds;
    END;
    CurMenu := SaveCurMenu;
    LoadMenu;
  END;
END;

END.
