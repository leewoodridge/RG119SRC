(*{$M 49152,0,65536}*)
PROGRAM RGUPDATE;

USES
  Crt,
  Dos,
  TimeFunc;

{$I RECORDS.PAS}

CONST
  DYNY: BOOLEAN = FALSE;

(* +---------------------------------------------------+ 
   |             START OF OLD RENEGADE.DAT             |
   +---------------------------------------------------+ *)
  
TYPE

OldGeneralRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
    ForgotPWQuestion: STRING[70];      { Forgot Password Question }
    QWKWelcome,                        { QWK Welcome Filename }
    QWKNews,                           { QWK News Filename }
    QWKGoodbye,                        { QWK Goodbye Filename }
    Origin: STRING[50];                { Default Origin Line }
    DataPath,                          { Data Path }
    MiscPath,                          { Misc Path }
    LogsPath,                          { Logs Path }
    MsgPath,                           { Msgs Path }
    NodePath,                          { Node List Path }
    TempPath,                          { Temp Path }
    ProtPath,                          { Prot Path }
    ArcsPath,                          { Arcs Path }
    lMultPath,                         { Mult Path } { LeeW: Was for strings, is used still?? }
    FileAttachPath,                    { File Attachments Path }
    QWKLocalPath,                      { QWK Path For Local Usage }
    DefEchoPath,                       { Default EchoMail Path }
    NetMailPath,                       { NetMail Path }
    BBSName: STRING[40];               { BBS name }
    SysOpName: STRING[30];             { SysOp's Name }
    Version: STRING[20];			   { Renegade BBS Version }
    BBSPhone: STRING[12];              { BBS Phone Number }
    LastDate: STRING[10];              { Last System Date }
    PacketName,                        { QWK Packet Name }
    BulletPrefix: STRING[8];           { Default Bulletins Filename }
    SysOpPW,                           { SysOp Password }
    NewUserPW,                         { New User Password }
    MinBaudOverride,                   { Minimum Baud Override Password }
    { ACS Requirements: Begin }
	QWKNetworkACS,                     { QWK Network Rep }
    LastOnDatACS,					   {  }
    SOP,                               { SysOp }
    CSOP,                              { Co-SysOp }
    MSOP,                              { Message SysOp }
    FSOP,                              { File SysOp }
    SPW,                               { SysOp PW At Logon }
    AddChoice,                         { Add Voting Choices }
    NormPubPost,                       { Make Normal Public Posts }
    NormPrivPost,                      { Send Normal E-Mail }
    AnonPubRead,                       { See Who Posted Public Anonymous }
    AnonPrivRead,                      { See Who Sent Anonymous E-Mail }
    AnonPubPost,                       { Make Anonymous Posts }
    AnonPrivPost,                      { Send Anonymous E-Mail }
    SeeUnval,                          { See Unvalidated Files }
    DLUnval,                           { Download Unvalidated Files }
    NoDLRatio,                         { No UL/DL Ratio }
    NoPostRatio,                       { No Post/Call Ratio }
    NoFileCredits,                     { No File Credits Checking }
    ULValReq,                          { Uploads Require Validation }
    TeleConfMCI,                       { Use MCI In TeleConference }
    OverrideChat,                      { Override Chat Hours }
    NetMailACS,                        { NetMail }
    Invisible,                         { Invisible Mode } { LeeW: Should This Be Deleted? }
    FileAttachACS,                     { Add File Attachments To Messages }
    ChangeVote,                        { Change Their Vote }
    UnUsedACS1,                        { UNUSED }
    UnUsedACS2: ACString;              { UNUSED }
	{ ACS Requirements: End }
    MaxPrivPost,                       { Max E-Mail Sent Per Call }
    MaxFBack,                          { Max Feedback Sent Per Call }
    MaxPubPost,                        { Max Posts Per Call }
    MaxChat,                           { Max SysOp Pages Per Call }
    MaxWaiting,                        { Max Mail Waiting }
    CSMaxWaiting,                      { Max Mail Waiting For Co-SysOp + }
    MaxMassMailList,				   {}
    MaxLogonTries,                     { Max Tries Allowed For PW's At Logon }
    SysOpColor,                        { SysOp Color In Chat Mode }
    UserColor,                         { User Color In Chat Mode }
    SliceTimer, 					   {}
    MaxBatchDLFiles,				   { Max Files In Batch DL Queue }
    MaxBatchULFiles,				   { Max Files In Batch UL Queue }
	Text_Color,                        { Color Of Standard Text }
    Quote_Color,                       { Color Of Quoted Text }
    Tear_Color,                        { Color Of Tear Line }
    Origin_Color,                      { Color Of Origin Line }
    BackSysOpLogs,                     { Days To Keep SYSOP##.LOG }
    EventWarningTime,                  { Minutes Before Event To Warn User }
    WFCBlankTime,                      { Minutes Before Blanking WFC Menu }
    AlertBeep,                         { time between alert beeps - Was Integer }
    FileCreditComp,                    { File Credit Compensation Ratio }
    FileCreditCompBaseSize,            { File Credit Area Compensation Size }
    ULRefund,                          { Percent Of Time To Refund For ULs }
    GlobalMenu,						   { Global Menu # }
    AllStartMenu,					   { Start Menu # }
    ShuttleLogonMenu,				   { Shuttle Logon Menu # }
    NewUserInformationMenu,			   { New User Info Menu # }
    FileListingMenu,				   { File Listing Menu # }
    MessageReadMenu,				   { Message Reading Menu # }
    CurWindow,                         { Type Of SysOp Window In Use }
    SwapTo: Byte;                      { Swap Where? }
    UnUsedByte1,                       { UNUSED }
    UnUsedByte2: Byte;                 { UNUSED }
    lLowTime,                          { SysOp Chat Hours: Begin }
    HiTime,                            { SysOp Chat Hours: End }
    DLLowTime,                         { Normal Download Hours: Begin }
    DLHiTime,                          { Normal Download Hours: End }
    MinBaudLowTime,                    { Minimum Baud Calling Hours: Begin }
    MinBaudHiTime,                     { Minimum Baud Calling Hours: End }
    MinBaudDLLowTime,                  { Minimum Baud Downloading Hours: Begin }
    MinBaudDLHiTime,                   { Minimum Baud Downloading Hours: End }
    NewApp,                            { Send New User Application Letter To User # }
    TimeOutBell,                       { Minutes Before TimeOut Beep }
    TimeOut,                           { Minutes Before TimeOut }
    ToSysOpDir,                        { "To SysOp" File Area }
    CreditMinute,                      { Credits Per Minute }
    CreditPost,                        { Credits Per Post }
    CreditEmail,                       { Credits Per E-Mail Sent }
    CreditFreeTime,                    { Amount Of "Free" Time Given To User At Logon }
    NumUsers,                          { Number Of Users }
    PasswordChange,                    { Password Change Required Every # Days }
    RewardRatio,                       { % Of File Points To Reward Back }
    CreditInternetMail,                { Credits Per Internet E-Mail }
    BirthDateCheck,                    { Verify Users Birthdate Every # Logons }
    UnUsedInteger1,                    { UNUSED }
    UnUsedInteger2: SmallInt;          { UNUSED }
    MaxQWKTotal,                       { Max Msgs In A Packet, Period! }
    MaxQWKBase,                        { Max Msgs In A Area }
    DaysOnline: SmallWord;             { Days Online }
    UnUsedWord1,					   { UNUSED }
    UnUsedWord2: SmallWord;            { UNUSED }
    MinimumBaud,                       { Minimum Baud Rate To Logon }
    MinimumDLBaud,                     { Minimum Baud Rate To Download }
    MaxDepositEver,					   { Maximum Amount Of Time Allowed In TimeBank }
    MaxDepositPerDay,				   { Maximum Daily TimeBank Deposit }
    MaxWithdrawalPerDay,			   { Maximum Daily TimeBank Withdrawl }
    CallerNum,                         { System Caller Number }
    RegNumber,                         { Registration Number }
    TotalCalls,                        { incase different from callernum ??? }
    TotalUsage,                        { Total Usage In Minutes }
    TotalPosts,                        { Total number Of Posts }
    TotalDloads,                       { Total number Of DLs }
    TotalUloads,                       { Total number Of ULs }
    MinResume,                         { Minimum K Allowed For Resume Later }
    MaxInTemp,                         { Maximum K Allowed In Temp }
    MinSpaceForPost,                   { Minimum Drive Space Left To Post }
    MinSpaceForUpload,		           { Minimum Drive Space Left To Upload }
    UnUsedLongInt1,                    { UNUSED }
    UnUsedLongInt2: LongInt;           { UNUSED }
    AllowAlias,                        { Allow Aliases(Handles)? }
    PhonePW,                           { Ask For Phone Number During Logon? }
    LocalSec,                          { Use Local Security? }
    GlobalTrap,                        { Trap Everyone's Activity? }
    AutoChatOpen,                      { Automatically Open Chat Buffer? }
    AutoMInLogon,                      { Display Auto-Message During Logon? }
    BullInLogon,                       { Display Bulletins During Logon? }
    YourInfoInLogon,                   { Display "Your Info" During Logon? }
    OffHookLocalLogon,                 { Take The Phone Off-Hook During Local Logons? }
    ForceVoting,                       { Mandatory Voting? }
    CompressBases,                     { "Compress" File/Message Area Numbers? }
    SearchDup,                         { Search For Duplicate Files On Uploads? }
    ForceBatchDL,                      { Force Batch DL? }
    ForceBatchUL,                      { Force Batch UL? }
    LogonQuote,				           { Display Quotes During Logon? }
    UserAddQuote,                      { Ask User To Add Quote During Logon? }
    StripCLog,                         { Strip Colors From SysOp Log? }
    SKludge,                           { Show Kludge Lines? }
    SSeenby,                           { Show Seen-By Lines? }
    SOrigin,                           { Show Origin Lines? }
    AddTear,                           { Show Tear Line? }
    ShuttleLog,                        { Use Shuttle Logon? }
    ClosedSystem,                      { Allow New Users? }
    SwapShell,                         { Swap On Shell? }
    UseEMS,                            { Use EMS For Overlay? }
    UseBios,                           { Use BIOS For Video Output? }
    UseIEMSI,                          { Use IEMSI? }
    ULDLRatio,                         { Use UL/DL Ratios? }
    FileCreditRatio,                   { Use Automatic File-Credit Compensation? }
    ValidateAllFiles,                  { Validate Files Automatically? }
    FileDiz,                           { Search/Import FILE_ID.DIZ }
    SysOpPword,                        { Check For SysOp Password? }
    TrapTeleConf,                      { Trap TeleConferencing To ROOM#.TRP? }
    IsTopWindow,                       { is window at top OF screen? }
    ReCompress,                        { ReCompress Like Archives? }
    RewardSystem,                      { Use File Rewarding System? }
    TrapGroup,                         { Trap Group Chats? }
    QWKTimeIgnore,                     { Ignore Time Remaining For QWK Download? }
    NetworkMode,                       { Network Mode? }
    WindowOn,                          { Is The SysOp Window On? }
    ChatCall,                          { Keep Beeping After Chat Call? }
    DailyLimits,                       { Daily File Limits On/Off }
    MultiNode,                         { Enable Multi-Node Support? }
    PerCall,                           { Are Time Limits Per-Call Or Per-Day? }
    TestUploads,                       { Perform Integrity Tests On Uploads? }
    UseLightBars,				  	   { Use LightBars? }
    ShuttleUnvalLogin,                 { Allow UnValidated Users To Logon From Shuttle Menu? } { LeeW: Added }
	UnUsedBoolean1,					   { UNUSED }
    UnUsedBoolean2: Boolean;           { UNUSED }
	
    FileArcInfo: ARRAY [1..MaxArcs] OF FileArcInfoRecordType; { Archive Specs } 

    FileArcComment: ARRAY [1..3] OF STRING[40]; { BBS Comment Files For Archives }

    Aka: ARRAY [0..20] OF {$IFDEF WIN32} PACKED {$ENDIF} RECORD { 20 Addresses } { 21 = UUCP Address }
      Zone,                           
      Net,
      Node,
      Point: SmallWord;
    END;

    NewUserToggles: ARRAY [1..27] OF Boolean; { LeeW: New User Application Toggles }
	
    Macro: ARRAY [0..9] OF STRING[100]; { SysOp Macros }

    NetAttribute: NetAttribs;         { Default NetMail Attributes }
    TimeAllow,                        { Time Allowance }
    CallAllow,                        { Call Allowance }
    DLRatio,                          { Download/Upload Ratio (#) }
    DLKRatio,                         { Download/Upload Ratio (K) }
    PostRatio,                        { Post/Call Ratio }
    DLOneday,                         { Max Download In One Day (#) }
    DLKOneDay: SecurityRangeType;     { Max Download In One Day (K) }
	
	ConnectionType: ARRAY [1..2] OF Boolean; { 1 = Modem, 2 = Telnet }

	LastCallersInLogon,				  { Last Callers Displayed During Logon }
	OneLinersInLogon,				  { One Liners During Logon }
	VoteInLogon: BOOLEAN;			  { Voting During Logon }
	END;
  
(* +---------------------------------------------------+ 
   |              END OF OLD RENEGADE.DAT              |
   +---------------------------------------------------+ *)

(* +---------------------------------------------------+ 
   |             START OF OLD USERS.DAT                |
   +---------------------------------------------------+ *)
   
OldUserRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
    Name,                                   { System Name }
    RealName: STRING[36];                   { Real Name }
    Street,                                 { Street Address }
    CityState: STRING[30];                  { City, State }
    CallerID: STRING[20];                   { Caller ID String }
    ZipCode: STRING[10];                    { Zip Code }
    PH: STRING[12];                         { Phone Number }
    ForgotPWAnswer: STRING[40];             { Forgot Password Answer }
    UsrDefStr: ARRAY [1..3] OF STRING[35];	{ Definable Strings }
    Note: STRING[35];                       { SysOp Note }
    LockedFile: STRING[8];                  { Print Lockout Message }
    Vote: ARRAY [1..25] OF Byte;            { Voting Data }
    Sex,                                    { Gender }
    Subscription,                           { Their Subscription }
    ExpireTo,                               { Level To Expire To }
    LastConf: Char;                         { Last Conference In }
    UnUsedChar1,
    UnUsedChar2: Char; 
    SL,                                     { SL }
    DSL,                                    { DSL }
    Waiting,                                { Mail Waiting }
    LineLen,                                { Line Length }
    PageLen,                                { Page Length }
    OnToday,                                { # Times On Today }
    Illegal,                                { # Illegal Logons }
    DefArcType,                             { QWK Archive Type }
    ColorScheme,                            { Color Scheme # }
    UserStartMenu: Byte;                    { Menu To Start At }
    UnUsedByte1,
    UnUsedByte2: Byte; 
    BirthDate,                              { Birth Date }
    FirstOn,                                { First On Date }
    LastOn,                                 { Last On Date }
    TTimeOn,                                { Total Time On }
    LastQWK,                                { Last QWK Packet }
    Expiration: UnixTime;                   { Expiration Date }
    UnUsedUnixTime1,
    UnUsedUnixTime2: UnixTime; 
    UserID,                                 { Permanent User ID }
    TLToday,                                { # Min Left Today }
    ForUsr,                                 { Forward Mail To }
    LastMsgArea,                            { # Last Msg Area }
    LastFileArea: SmallInt;                 { # Last File Area }
    UnUsedInteger1,
    UnUsedInteger2: SmallInt; 
    PasswordChanged: SmallWord;             { Numeric Date PW Changed (Was UnixTime) }
    UnUsedWord1,
    UnUsedWord2: SmallWord; 
    lCredit,                                { Amount Of Credit }
    Debit,                                  { Amount Of Debit }
    PW,                                     { Password }
    Uploads,                                { # Of Uploads }
    Downloads,                              { # Of Downloads }
    UK,                                     { Uploaded Kb }
    DK,                                     { Downloaded Kb }
    LoggedOn,                               { # Times On }
    MsgPost,                                { # Message Posts }
    EmailSent,                              { # E-Mail Sent }
    FeedBack,                               { # Feedback Sent }
    TimeBank,                               { # Mins In Bank }
    TimeBankAdd,                            { # Mins Deposited Today }
	TimeBankWith,                           { Time Withdrawn }
    DLKToday,                               { kB Downloaded Today }
    DLToday,                                { # Files Downloaded Today }
    FilePoints: LongInt;
    UnUsedLongInt1,
    UnUsedLongInt2: LongInt; 
    TeleConfEcho,                           { Teleconf Echo? }
    TeleConfInt,                            { Teleconf Interrupt }
    GetOwnQWK,                              { Get Own Messages }
    ScanFilesQWK,                           { New Files In QWK }
    PrivateQWK: Boolean;                    { Private Mail QWK }
    UnUsedBoolean1,
    UnUsedBoolean2: Boolean; 
    AR: ARFlagSet;                          { AR Flags }
    Flags: FlagSet;                         { Flags }
    SFlags: StatusFlagSet;                  { Status Flags }
	Country: STRING[40];
  END;

(* +---------------------------------------------------+ 
   |              END OF OLD USERS.DAT                 |
   +---------------------------------------------------+ *)


function sqoutsp(s:string):string;
begin
  while (pos(' ',s)>0) do delete(s,pos(' ',s),1);
  sqoutsp:=s;
end;

function exist(fn: astr): boolean;
var
  srec: searchrec;
begin
  findfirst(sqoutsp(fn),anyfile,srec);
  exist := (doserror = 0);
end;

FUNCTION SYN(B: BOOLEAN): STRING;
BEGIN
  IF (B) THEN
    SYN := 'Yes'
  ELSE
    SYN := 'No ';
END;

FUNCTION YN: BOOLEAN;
VAR
  C: CHAR;
BEGIN
  Write(SQOutSp(SYN(DYNY)));
  REPEAT
    C := UpCase(Char(ReadKey));
  UNTIL (C IN ['Y','N',^M]);
  IF (DYNY) AND (C <> 'N') THEN
    C := 'Y';
  IF (DYNY) AND (C = 'N') THEN
    Write(#8#8#8'No ')
  ELSE IF (NOT DYNY) AND (C = 'Y') THEN
    Write(#8#8'Yes');
  WriteLn;
  YN := (C = 'Y');
  DYNY := FALSE;
end;

FUNCTION PYNQ(CONST S: AStr): BOOLEAN;
BEGIN
  Write(S);
  PYNQ := YN;
END;

PROCEDURE ChangeLength(S: STRING; VAR S1,S2: STRING);
VAR
  TempStr: STRING;
  Counter: Byte;
BEGIN
  IF (Length(S) <= 60) THEN
  BEGIN
    S1 := S;
    S2 := '';
  END
  ELSE
  BEGIN
    TempStr := Copy(S,1,65);
    IF (TempStr[65] <> ' ') THEN
    BEGIN
      Counter := 65;
      WHILE (TempStr[Counter] <> ' ') DO
      BEGIN
        Dec(TempStr[0]);
        Dec(Counter);
      END;
      Dec(TempStr[0]);
      S1 := TempStr;
      S2 := Copy(S,(Counter + 1),Length(S));
    END
    ELSE
    BEGIN
      S1 := Copy(S,1,64);
      S2 := Copy(S,66,Length(S));
    END;
  END;
END;

PROCEDURE Kill(CONST FileName: AStr);
VAR
  F: FILE;
BEGIN
  Assign(F,FileName);
  Erase(F);
END;

PROCEDURE ConvertGeneralRec;
VAR
  OldGeneralFile: FILE OF OldGeneralRecordType;
  GeneralFile: FILE OF GeneralRecordType;
  OldGeneral: OldGeneralRecordType;
  General: GeneralRecordType;
  Counter: Integer;
BEGIN
  Write('Converting "RENEGADE.DAT" file ... ');
  Assign(OldGeneralFile,'RENEGADE.DAT');
  Reset(OldGeneralFile);
  Assign(GeneralFile,'RENEGADE.NEW');
  ReWrite(GeneralFile);
  Seek(OldGeneralFile,0);
  Read(OldGeneralFile,OldGeneral);
  WITH General DO
  
(* +---------------------------------------------------+ 
   |             START OF NEW RENEGADE.DAT             |
   +---------------------------------------------------+ *)
  
  BEGIN
    ForgotPWQuestion := OldGeneral.ForgotPWQuestion;
    QWKWelcome := OldGeneral.QWKWelcome;
    QWKNews := OldGeneral.QWKNews;
    QWKGoodbye := OldGeneral.QWKGoodbye;
    Origin := OldGeneral.Origin;
    DataPath := OldGeneral.DataPath;
    MiscPath := OldGeneral.MiscPath;
    LogsPath := OldGeneral.LogsPath;
    MsgPath := OldGeneral.MsgPath;
    NodePath := OldGeneral.NodePath;
    TempPath := OldGeneral.TempPath;
    ProtPath := OldGeneral.ProtPath;
    ArcsPath := OldGeneral.ArcsPath;
    lMultPath := OldGeneral.lMultPath; { LeeW: Remove? }
    FileAttachPath := OldGeneral.FileAttachPath; { LeeW: Isn't this stored in temp now? Remove? }
    QWKLocalPath := OldGeneral.QWKLocalPath;
    DefEchoPath := OldGeneral.DefEchoPath;
    NetMailPath := OldGeneral.NetMailPath;
    BBSName := OldGeneral.BBSName;
    SysOpName := OldGeneral.SysOpName;
    Version := OldGeneral.Version; { LeeW: Update }
    BBSPhone := OldGeneral.BBSPhone;
    LastDate := OldGeneral.LastDate;
    PacketName := OldGeneral.PacketName;
    BulletPrefix := OldGeneral.BulletPrefix;
    SysOpPW := OldGeneral.SysOpPW;
    NewUserPW := OldGeneral.NewUserPW;
    MinBaudOverride := OldGeneral.MinBaudOverride;
	QWKNetworkACS := OldGeneral.QWKNetworkACS;
    LastOnDatACS := OldGeneral.LastOnDatACS;
    SOP := OldGeneral.SOP;
    CSOP := OldGeneral.CSOP;
    MSOP := OldGeneral.MSOP;
    FSOP := OldGeneral.FSOP;
    SPW := OldGeneral.SPW;
    AddChoice := OldGeneral.AddChoice;
    NormPubPost := OldGeneral.NormPubPost;
    NormPrivPost := OldGeneral.NormPrivPost;
    AnonPubRead := OldGeneral.AnonPubRead;
    AnonPrivRead := OldGeneral.AnonPrivRead;
    AnonPubPost := OldGeneral.AnonPubPost;
    AnonPrivPost := OldGeneral.AnonPrivPost;
    SeeUnval := OldGeneral.SeeUnval;
    DLUnval := OldGeneral.DLUnval;
    NoDLRatio := OldGeneral.NoDLRatio;
    NoPostRatio := OldGeneral.NoPostRatio;
    NoFileCredits := OldGeneral.NoFileCredits;
    ULValReq := OldGeneral.ULValReq;
    TeleConfMCI := OldGeneral.TeleConfMCI;
    OverrideChat := OldGeneral.OverrideChat;
    NetMailACS := OldGeneral.NetMailACS;
    Invisible := OldGeneral.Invisible; { LeeW: Remove? }
    FileAttachACS := OldGeneral.FileAttachACS;
    ChangeVote := OldGeneral.ChangeVote;
    UnUsedACS1 := OldGeneral.UnUsedACS1;
    UnUsedACS2 := OldGeneral.UnUsedACS2;
    MaxPrivPost := OldGeneral.MaxPrivPost;
    MaxFBack := OldGeneral.MaxFBack;
    MaxPubPost := OldGeneral.MaxPubPost;
    MaxChat := OldGeneral.MaxChat;
    MaxWaiting := OldGeneral.MaxWaiting;
    CSMaxWaiting := OldGeneral.CSMaxWaiting;
    MaxMassMailList := OldGeneral.MaxMassMailList;
    MaxLogonTries := OldGeneral.MaxLogonTries;
    SysOpColor := OldGeneral.SysOpColor;
    UserColor := OldGeneral.UserColor;
    SliceTimer := OldGeneral.SliceTimer;
    MaxBatchDLFiles := OldGeneral.MaxBatchDLFiles;
    MaxBatchULFiles := OldGeneral.MaxBatchULFiles;
	Text_Color := OldGeneral.Text_Color;
    Quote_Color := OldGeneral.Quote_Color;
    Tear_Color := OldGeneral.Tear_Color;
    Origin_Color := OldGeneral.Origin_Color;
    BackSysOpLogs := OldGeneral.BackSysOpLogs;
    EventWarningTime := OldGeneral.EventWarningTime;
    WFCBlankTime := OldGeneral.WFCBlankTime;
    AlertBeep := OldGeneral.AlertBeep;
    FileCreditComp := OldGeneral.FileCreditComp;
    FileCreditCompBaseSize := OldGeneral.FileCreditCompBaseSize;
    ULRefund := OldGeneral.ULRefund;
    GlobalMenu := OldGeneral.GlobalMenu;
    AllStartMenu := OldGeneral.AllStartMenu;
    ShuttleLogonMenu := OldGeneral.ShuttleLogonMenu;
    NewUserInformationMenu := OldGeneral.NewUserInformationMenu;
    FileListingMenu := OldGeneral.FileListingMenu;
    MessageReadMenu := OldGeneral.MessageReadMenu;
    CurWindow := OldGeneral.CurWindow;
    SwapTo := OldGeneral.SwapTo;
    UnUsedByte1 := OldGeneral.UnUsedByte1;
    UnUsedByte2 := OldGeneral.UnUsedByte2;
    lLowTime := OldGeneral.lLowTime;
    HiTime := OldGeneral.HiTime;
    DLLowTime := OldGeneral.DLLowTime;
    DLHiTime := OldGeneral.DLHiTime;
    MinBaudLowTime := OldGeneral.MinBaudLowTime;
    MinBaudHiTime := OldGeneral.MinBaudHiTime;
    MinBaudDLLowTime := OldGeneral.MinBaudDLLowTime;
    MinBaudDLHiTime := OldGeneral.MinBaudDLHiTime;
    NewApp := OldGeneral.NewApp;
    TimeOutBell := OldGeneral.TimeOutBell;
    TimeOut := OldGeneral.TimeOut;
    ToSysOpDir := OldGeneral.ToSysOpDir;
    CreditMinute := OldGeneral.CreditMinute;
    CreditPost := OldGeneral.CreditPost;
    CreditEmail := OldGeneral.CreditEmail;
    CreditFreeTime := OldGeneral.CreditFreeTime;
    NumUsers := OldGeneral.NumUsers;
    PasswordChange := OldGeneral.PasswordChange;
    RewardRatio := OldGeneral.RewardRatio;
    CreditInternetMail := OldGeneral.CreditInternetMail;
    BirthDateCheck := OldGeneral.BirthDateCheck;
    UnUsedInteger1 := OldGeneral.UnUsedInteger1;
    UnUsedInteger2 := OldGeneral.UnUsedInteger2;
    MaxQWKTotal := OldGeneral.MaxQWKTotal;
    MaxQWKBase := OldGeneral.MaxQWKBase;
    DaysOnline := OldGeneral.DaysOnline;
    UnUsedWord1 := OldGeneral.UnUsedWord1;
    UnUsedWord2 := OldGeneral.UnUsedWord2;
    MinimumBaud := OldGeneral.MinimumBaud;
    MinimumDLBaud := OldGeneral.MinimumDLBaud;
    MaxDepositEver := OldGeneral.MaxDepositEver;
    MaxDepositPerDay := OldGeneral.MaxDepositPerDay;
    MaxWithdrawalPerDay := OldGeneral.MaxWithdrawalPerDay;
    CallerNum := OldGeneral.CallerNum;
    RegNumber := OldGeneral.RegNumber;
    TotalCalls := OldGeneral.TotalCalls;
    TotalUsage := OldGeneral.TotalUsage;
    TotalPosts := OldGeneral.TotalPosts;
    TotalDloads := OldGeneral.TotalDloads;
    TotalUloads := OldGeneral.TotalUloads;
    MinResume := OldGeneral.MinResume;
    MaxInTemp := OldGeneral.MaxInTemp;
    MinSpaceForPost := OldGeneral.MinSpaceForPost;
    MinSpaceForUpload := OldGeneral.MinSpaceForUpload;
    UnUsedLongInt1 := OldGeneral.UnUsedLongInt1;
    UnUsedLongInt2 := OldGeneral.UnUsedLongInt2;
    AllowAlias := OldGeneral.AllowAlias;
    PhonePW := OldGeneral.PhonePW;
    LocalSec := OldGeneral.LocalSec;
    GlobalTrap := OldGeneral.GlobalTrap;
    AutoChatOpen := OldGeneral.AutoChatOpen;
    AutoMInLogon := OldGeneral.AutoMInLogon;
    BullInLogon := OldGeneral.BullInLogon;
	LastCallersInLogon := OldGeneral.LastCallersInLogon; { LeeW: Added }
    OneLinersInLogon := OldGeneral.OneLinersInLogon; { LeeW: Added } 
	VoteInLogon := OldGeneral.VoteInLogon; { LeeW: Added }
    YourInfoInLogon := OldGeneral.YourInfoInLogon;
    OffHookLocalLogon := OldGeneral.OffHookLocalLogon;
    ForceVoting := OldGeneral.ForceVoting;
    CompressBases := OldGeneral.CompressBases;
    SearchDup := OldGeneral.SearchDup;
    ForceBatchDL := OldGeneral.ForceBatchDL;
    ForceBatchUL := OldGeneral.ForceBatchUL;
    LogonQuote := OldGeneral.LogonQuote;
    UserAddQuote := OldGeneral.UserAddQuote;
    StripCLog := OldGeneral.StripCLog;
    SKludge := OldGeneral.SKludge;
    SSeenby := OldGeneral.SSeenby;
    SOrigin := OldGeneral.SOrigin;
    AddTear := OldGeneral.AddTear;
    ShuttleLog := OldGeneral.ShuttleLog;
    ClosedSystem := OldGeneral.ClosedSystem;
    SwapShell := OldGeneral.SwapShell;
    UseEMS := OldGeneral.UseEMS;
    UseBIOS := OldGeneral.UseBIOS;
    UseIEMSI := OldGeneral.UseIEMSI;
    ULDLRatio := OldGeneral.ULDLRatio;
    FileCreditRatio := OldGeneral.FileCreditRatio;
    ValidateAllFiles := OldGeneral.ValidateAllFiles;
    FileDiz := OldGeneral.FileDiz;
    SysOpPword := OldGeneral.SysOpPword;
    TrapTeleConf := OldGeneral.TrapTeleConf;
    IsTopWindow := OldGeneral.IsTopWindow;
    ReCompress := OldGeneral.ReCompress;
    RewardSystem := OldGeneral.RewardSystem;
    TrapGroup := OldGeneral.TrapGroup;
    QWKTimeIgnore := OldGeneral.QWKTimeIgnore;
    NetworkMode := OldGeneral.NetworkMode;
    WindowOn := OldGeneral.WindowOn;
    ChatCall := OldGeneral.ChatCall;
    DailyLimits := OldGeneral.DailyLimits;
    MultiNode := OldGeneral.MultiNode;
    PerCall := OldGeneral.PerCall;
    TestUploads := OldGeneral.TestUploads;
    UseLightBars := OldGeneral.UseLightBars;
    ShuttleUnvalLogin := OldGeneral.ShuttleUnvalLogin;
	UnUsedBoolean1 := OldGeneral.UnUsedBoolean1;
    UnUsedBoolean2 := OldGeneral.UnUsedBoolean2;

	FOR Counter := 1 TO MaxArcs DO
      FileArcInfo[Counter] := OldGeneral.FileArcInfo[Counter];

    FOR Counter := 1 TO 3 DO
      FileArcComment[Counter] := OldGeneral.FileArcComment[Counter];

    FOR Counter := 0 TO 20 DO
      WITH AKA[Counter] DO
      BEGIN
        Zone := OldGeneral.AKA[Counter].Zone;
        Net := OldGeneral.AKA[Counter].Net;
        Node := OldGeneral.AKA[Counter].Node;
        Point := OldGeneral.AKA[Counter].Point;
      END;

	FOR Counter := 1 TO 30 DO
      NewUserToggles[Counter] := OldGeneral.NewUserToggles[Counter];

    FOR Counter := 0 TO 9 DO
      Macro[Counter] := OldGeneral.Macro[Counter];

    NetAttribute := OldGeneral.NetAttribute;
    TimeAllow := OldGeneral.TimeAllow;
    CallAllow := OldGeneral.CallAllow;
    DLRatio := OldGeneral.DLRatio;
    DLKRatio := OldGeneral.DLKRatio;
    PostRatio := OldGeneral.PostRatio;
    DLOneday := OldGeneral.DLOneday;
    DLKOneDay := OldGeneral.DLKOneDay;
	
	FOR Counter := 1 TO 2 DO
	  ConnectionType[Counter] := OldGeneral.ConnectionType[Counter];
  END;
  
(* +---------------------------------------------------+ 
   |              END OF NEW RENEGADE.DAT              |
   +---------------------------------------------------+ *)
  
  Seek(GeneralFile,0);
  Write(GeneralFile,General);
  Close(OldGeneralFile);
  Close(GeneralFile);
  Assign(OldGeneralFile,'RENEGADE.DAT');
  Erase(OldGeneralFile);
  Assign(GeneralFile,'RENEGADE.NEW');
  ReName(GeneralFile,'RENEGADE.DAT');
  WriteLn('Done');
END;

PROCEDURE ConvertUserRec(OldGeneral: OldGeneralRecordType);
VAR
  OldUserFile: FILE OF OldUserRecordType;
  UserFile: FILE OF UserRecordType;
  OldUser: OldUserRecordType;
  User: UserRecordType;
  Counter,
  Counter1: Integer;
  PH: STRING[13];
BEGIN
  Write('Converting "USERS.DAT" file ... ');
  Write('[');
  Assign(OldUserFile,OldGeneral.DataPath+'USERS.DAT');
  Reset(OldUserFile);
  Assign(UserFile,OldGeneral.DataPath+'USERS.NEW');
  ReWrite(UserFile);
  Counter := 0;
  WHILE (Counter <= (FileSize(OldUserFile) - 1)) DO
  BEGIN
    Seek(OldUserFile,Counter);
    Read(OldUserFile,OldUser);
    WITH User DO
    BEGIN

(* +---------------------------------------------------+ 
   |             START OF NEW USERS.DAT                |
   +---------------------------------------------------+ *)	
	
    Name := OldUser.Name;
    RealName := OldUser.RealName;
    Street := OldUser.Street;
    CityState := OldUser.CityState;
    CallerID := OldUser.CallerID;
    ZipCode := OldUser.ZipCode;
    PH := '1234567890123';
    ForgotPWAnswer := OldUser.ForgotPWAnswer;
    FOR Counter1 := 1 TO 3 DO
	  UsrDefStr[Counter1] := OldUser.UsrDefStr[Counter1];
    Note := OldUser.Note;
    LockedFile := OldUser.LockedFile;
    FOR Counter1 := 1 TO 25 DO
	  Vote[Counter1] := OldUser.Vote[Counter1];
    Sex := OldUser.Sex;
    Subscription := OldUser.Subscription;
    ExpireTo := OldUser.ExpireTo;
    LastConf := OldUser.LastConf;
    UnUsedChar1 := OldUser.UnUsedChar1;
    UnUsedChar2 := OldUser.UnUsedChar2;
    SL := OldUser.SL;
    DSL := OldUser.DSL;
    Waiting := OldUser.Waiting;
    LineLen := OldUser.LineLen;
    PageLen := OldUser.PageLen;
    OnToday := OldUser.OnToday;
    Illegal := OldUser.Illegal;
    DefArcType := OldUser.DefArcType;
    ColorScheme := OldUser.ColorScheme;
    UserStartMenu := OldUser.UserStartMenu;
    UnUsedByte1 := OldUser.UnUsedByte1;
    UnUsedByte2 := OldUser.UnUsedByte2;
    BirthDate := OldUser.BirthDate;
    FirstOn := OldUser.FirstOn;
    LastOn := OldUser.LastOn;
    TTimeOn := OldUser.TTimeOn;
    LastQWK := OldUser.LastQWK;
    Expiration := OldUser.Expiration;
    UnUsedUnixTime1 := OldUser.UnUsedUnixTime1;
    UnUsedUnixTime2 := OldUser.UnUsedUnixTime2;
    UserID := OldUser.UserID;
    TLToday := OldUser.TLToday;
    ForUsr := OldUser.ForUsr;
    LastMsgArea := OldUser.LastMsgArea;
    LastFileArea := OldUser.LastFileArea;
    UnUsedInteger1 := OldUser.UnUsedInteger1;
    UnUsedInteger2 := OldUser.UnUsedInteger2;
    PasswordChanged := OldUser.PasswordChanged;
    UnUsedWord1 := OldUser.UnUsedWord1;
    UnUsedWord2 := OldUser.UnUsedWord2;
    lCredit := OldUser.lCredit;
    Debit := OldUser.Debit;
    PW := OldUser.PW;
    Uploads := OldUser.Uploads;
    Downloads := OldUser.Downloads;
    UK := OldUser.UK;
    DK := OldUser.DK;
    LoggedOn := OldUser.LoggedOn;
    MsgPost := OldUser.MsgPost;
    EmailSent := OldUser.EmailSent;
    FeedBack := OldUser.FeedBack;
    TimeBank := OldUser.TimeBank;
    TimeBankAdd := OldUser.TimeBankAdd;
	TimeBankWith := OldUser.TimeBankWith;
    DLKToday := OldUser.DLKToday;
    DLToday := OldUser.DLToday;
    FilePoints := OldUser.FilePoints;
    UnUsedLongInt1 := OldUser.UnUsedLongInt1;
    UnUsedLongInt2 := OldUser.UnUsedLongInt2;
    TeleConfEcho := OldUser.TeleConfEcho;
    TeleConfInt := OldUser.TeleConfInt;
    GetOwnQWK := OldUser.GetOwnQWK;
    ScanFilesQWK := OldUser.ScanFilesQWK;
    PrivateQWK := OldUser.PrivateQWK;
    UnUsedBoolean1 := OldUser.UnUsedBoolean1;
    UnUsedBoolean2 := OldUser.UnUsedBoolean2;
	
	{AR := [];}
	AR := OldUser.AR;
	
	{LeeW: Add AR Flags Here! } {Include(AR,'A');}
	
	Flags := [];
	
	IF (RLogon IN OldUser.Flags) THEN
        Include(Flags,RLogon);
	IF (RChat IN OldUser.Flags) THEN
        Include(Flags,RChat);
	IF (RValidate IN OldUser.Flags) THEN
        Include(Flags,RValidate);
	IF (RUserList IN OldUser.Flags) THEN
        Include(Flags,RUserList);
	IF (RAMsg IN OldUser.Flags) THEN
        Include(Flags,RAMsg);
	IF (RPostAn IN OldUser.Flags) THEN
        Include(Flags,RPostAn);
	IF (RPost IN OldUser.Flags) THEN
        Include(Flags,RPost);
	IF (REmail IN OldUser.Flags) THEN
        Include(Flags,REmail);
	IF (RVoting IN OldUser.Flags) THEN
        Include(Flags,RVoting);
	IF (RMsg IN OldUser.Flags) THEN
        Include(Flags,RMsg);
    
    IF (FNoDLRatio IN OldUser.Flags) THEN
      Include(Flags,FNoDLRatio);
    IF (FNoPostRatio IN OldUser.Flags) THEN
      Include(Flags,FNoPostRatio);
    IF (FNoCredits IN OldUser.Flags) THEN
      Include(Flags,FNoCredits);
    IF (FNoDeletion IN OldUser.Flags) THEN
      Include(Flags,FNoDeletion);

	IF (VT100 IN OldUser.Flags) THEN
      Include(Flags,VT100);
    IF (HotKey IN OldUser.Flags) THEN
      Include(Flags,HotKey);
    IF (Avatar IN OldUser.Flags) THEN
      Include(Flags,Avatar);
    IF (Pause IN OldUser.Flags) THEN
      Include(Flags,Pause);
    IF (Novice IN OldUser.Flags) THEN
      Include(Flags,Novice);
    IF (ANSI IN OldUser.Flags) THEN
      Include(Flags,ANSI);
    IF (Color IN OldUser.Flags) THEN
      Include(Flags,Color);
    IF (SMW IN OldUser.Flags) THEN
      Include(Flags,SMW);
    IF (NoMail IN OldUser.Flags) THEN
      Include(Flags,NoMail);
    IF (CLSMsg IN OldUser.Flags) THEN
      Include(Flags,CLSMsg);
    IF (RIP IN OldUser.Flags) THEN
      Include(Flags,RIP);
    IF (FSEditor IN OldUser.Flags) THEN
      Include(Flags,FSEditor);
    IF (AutoDetect IN OldUser.Flags) THEN
      Include(Flags,AutoDetect);
    IF (UseLightBars IN OldUser.Flags) THEN
      Include(Flags,UseLightBars);
	
	SFlags := [];
	
    IF (LockedOut IN OldUser.SFlags) THEN
      Include(SFlags,LockedOut);
    IF (Deleted IN OldUser.SFlags) THEN
      Include(SFlags,Deleted);
    IF (TrapActivity IN OldUser.SFlags) THEN
      Include(SFlags,TrapActivity);
    IF (TrapSeparate IN OldUser.SFlags) THEN
      Include(SFlags,TrapSeparate);
    IF (ChatAuto IN OldUser.SFlags) THEN
      Include(SFlags,ChatAuto);
    IF (ChatSeparate IN OldUser.SFlags) THEN
      Include(SFlags,ChatSeparate);
    IF (SLogSeparate IN OldUser.SFlags) THEN
      Include(SFlags,SLogSeparate);
    IF (Alert IN OldUser.SFlags) THEN
      Include(SFlags,Alert);
	
	Country := OldUser.Country;
	
(* +---------------------------------------------------+ 
   |             END OF NEW USERS.DAT                  |
   +---------------------------------------------------+ *)

    END;
    Write(UserFile,User);
	Write(Counter);
	Write(',');
    Inc(Counter);
  END;
  Write(']');
  Close(OldUserFile);
  Close(UserFile);
  Assign(OldUserFile,OldGeneral.DataPath+'USERS.DAT');
  Erase(OldUserFile);
  Assign(UserFile,OldGeneral.DataPath+'USERS.NEW');
  ReName(UserFile,OldGeneral.DataPath+'USERS.DAT');
  WriteLn('Done');
END;

VAR
  OldGeneralFile: FILE OF OldGeneralRecordType;
  OldGeneral: OldGeneralRecordType;

BEGIN
  ClrScr;
  WriteLn('Renegade Upgrade Utility (v1.XX to v1.XX)');  (* <-- Update this with version *)
  WriteLn;
  Writeln('This utility will upgrade your Renegade BBS from');
  WriteLn('Version 1.XX to Version 1.XX');   (* <-- Update this with version *)
  WriteLn;
  IF PYNQ('Do you want to continue? ') THEN
  BEGIN
    WriteLn;
    Write('Reading "RENEGADE.DAT" file ... ');
    Assign(OldGeneralFile,'RENEGADE.DAT');
    Reset(OldGeneralFile);
    Seek(OldGeneralFile,0);
    Read(OldGeneralFile,OldGeneral);
    Close(OldGeneralFile);
    WriteLn('Done');
    WriteLn;
    IF (Exist(OldGeneral.DataPath+'BATCHDL.DAT')) THEN
    BEGIN
      Write('Deleting "BATCHDL.DAT" file ... ');
      Kill(OldGeneral.DataPath+'BATCHDL.DAT');
      WriteLn('Done');
    END; 
    ConvertUserRec(OldGeneral);
    ConvertGeneralRec;
  END;
END.