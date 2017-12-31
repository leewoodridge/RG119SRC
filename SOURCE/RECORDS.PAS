CONST
  Build = '1.20';

{$IFDEF MSDOS}
  OS = '/DOS';
{$ENDIF}

{$IFDEF WIN32}
  OS = '/Win32';
{$ENDIF}

{$IFDEF OS/2}
  OS = '/2';
{$ENDIF}

  Ver = Build + OS;
  MaxProtocols = 120;
  MaxEvents = 10;
  MaxArcs = 8;
  MaxCmds = 200;
  MaxMenus = 100;
  MaxResultCodes = 20;
  MaxExtDesc = 99;
  MaxFileAreas = 32767;
  MaxMsgAreas = 32767;
  MaxConfigurable = 1024;
  MaxVotes = 25;
  MaxChoices = 25;
  MaxSchemes = 255;
  MaxValKeys = 92;
  MaxConfKeys = 27;

  User_String_Ask  = ' ';        {Ask for user string fields}
  User_String_None = '';         {None for user string fields}

  User_Date_Ask  = -2145916799;  {Ask for user date fields - 01/01/1902}
  User_Date_None = -2146003199;  {None for user date fields - 12/31/1901}

  User_Word_Ask  = 65535;        {Ask for user word fields}
  User_Word_None = 65534;        {None for user word fields}

  User_Char_Ask  = '~';          {Ask for user character fields}
  User_Char_None = ' ';          {None for user character fields}

  User_Phone_Ask  = ' ';         {Ask for user phone fields}
  User_Phone_None = '';          {None for user phone fields}

TYPE
{$IFDEF MSDOS}
  SmallInt = Integer;
  SmallWord = Word;
{$ENDIF}
  AStr = STRING[160];
  Str1 = STRING[1];
  Str2 = STRING[2];
  Str3 = STRING[3];
  Str4 = STRING[4];
  Str5 = STRING[5];
  Str7 = STRING[7];
  Str8 = STRING[8];
  Str9 = STRING[9];
  Str11 = STRING[11];
  Str10 = STRING[10];
  Str12 = STRING[12];
  Str15 = STRING[15];
  Str20 = STRING[20];
  Str26 = STRING[26];
  Str30 = STRING[30];
  Str35 = STRING[35];
  Str36 = STRING[36];
  Str40 = STRING[40];
  Str50 = STRING[50];
  Str52 = STRING[52];
  Str65 = STRING[65];
  Str74 = STRING[74];
  Str78 = STRING[78];
  Str160 = STRING[160];
  
  UnixTime = LongInt;             { Seconds Since 01-01-70 }
  ACString = STRING[20];          { AC String }
  
  ARFlagType = '@'..'Z';          { AR Flags }
  ARFlagSet = SET OF ARFlagType;  { Set Of AR Flags }

  FlagType =
	{ Restrictions }
   (RLogon,			{ L - Limited To One Call Daily }
    RChat,			{ C - No SysOp Paging }
    RValidate,		{ V - Posts Are Unvalidated }
    RUserList,		{ U - Can't List Users }
    RAMsg,			{ A - Can't Leave Auto Message (Or Add To BBS List???) }
    RPostAn,		{ * - Can't Post Anonymously }
    RPost,			{ P - Can't Post }
    REmail,			{ E - Can't Send E-Mail }
    RVoting,		{ K - Can't Vote }
    RMsg,			{ M - Mandatory E-Mail Deletion }
	{ Privileges }
    FNoDLRatio,		{ 1 - No UL/DL Ratio }
    FNoPostRatio,	{ 2 - No Post/Call Ratio }
    FNoCredits,		{ 3 - No Credits Checking }
    FNoDeletion,	{ 4 - Protected From Deletion }
	{ Other / Preferenes }
	VT100,			{ Supports VT00 Emulation }
    HotKey,			{ Hotkey Input Mode }
    Avatar,			{ Supports Avatar Emulation }
    Pause,			{ Screen Pausing }
    Novice,			{ Novice/Expert Mode }
    ANSI,			{ Supports ANSI Emulation }
    Color,			{ Supports Color }
    SMW,			{ Short Message(s) Waiting }
    NoMail,			{ Mailbox Is Closed }
    CLSMsg,			{ If Screen Clearing }
    RIP,			{ If RIP Graphics Can Be Used }
    FSEditor,		{ If Full Screen Editor }
    AutoDetect,		{ If Emulation Is Auto Detected }
    UseLightBars);	{ If LightBars Are Enabled }
	
  FlagSet = SET OF FlagType;

  StatusFlagType =
   (LockedOut,			{ If Locked Out }
    Deleted,			{ If Deleted }
    TrapActivity,		{ If Trapping Users Activity }
    TrapSeparate,		{ If Trap To Seperate File }
    ChatAuto,			{ If Auto Chat Trapping }
    ChatSeparate,		{ If Separate Chat File To Trap To }
    SLogSeparate,		{ If Separate SysOp Log }
	Alert,				{ Alert SysOp Upon Login }
    UnUsedStatusFlag0,	{  }
    UnUsedStatusFlag1,	{  }
    UnUsedStatusFlag2,	{  }
    UnUsedStatusFlag3);	{  }
	
  StatusFlagSet = SET OF StatusFlagType;

  ANonTyp =
   (ATNo,		{ Anonymous Posts Not Allowed }
    ATYes,		{ Anonymous Posts Allowed }
    ATForced,	{ Force Anonymous }
    ATDearAbby,	{ "Dear Abby"  }
    ATAnyName);	{ Post Under Any Name }

  NetAttr =
    (Private,
     Crash,
     Recd,
     NSent,
     FileAttach,
     Intransit,
     Orphan,
     KillSent,
     Local,
     Hold,
     Unused,
     FileRequest,
     ReturnReceiptRequest,
     IsReturnReceipt,
     AuditRequest,
     FileUpdateRequest);

  NetAttribs = SET OF NetAttr;

  SecurityRangeType = ARRAY [0..255] OF LongInt; { Access Tables }

  UserIDXRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { USERS.IDX : Sorted Names Listing }
    Name: STRING[36];	{ User Name }
    Number,				{ User Number }
    Left,				{ Left Node }
    Right: SmallInt;	{ Right Node }
    RealName,			{ User's Real Name? }
    Deleted: Boolean;	{ Deleted? }
  END;

  UserRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { USERS.DAT : User Records }
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
    LockedFile: STRING[8];                  { File To Display If User Locked Out }
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
    FilePoints: LongInt;					{ File Points }
    UnUsedLongInt1,							{ }
    UnUsedLongInt2: LongInt;				{ }
    TeleConfEcho,                           { Teleconf Echo? }
    TeleConfInt,                            { Teleconf Interrupt }
    GetOwnQWK,                              { QWK: Get Own Messages? }
    ScanFilesQWK,                           { QWK: Get New Files List? }
    PrivateQWK: Boolean;                    { QWK: Get Own Private Mail? }
    UnUsedBoolean1,							{  }
    UnUsedBoolean2: Boolean;				{  }
    AR: ARFlagSet;                          { AR Flags }
    Flags: FlagSet;                         { AC Flags }
    SFlags: StatusFlagSet;                  { Status Flags }
	Country: STRING[40];					{ Country }
  END;

  MsgStatusR =
    (MDeleted,
     Sent,
     Unvalidated,
     Permanent,
     AllowMCI,
     NetMail,
     Prvt,
     Junked);

  FromToInfo = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { From/To Information For MHeaderRec }
    Anon: Byte;			{ Anonymous }
    UserNum: SmallWord;	{ User Number }
    A1S: STRING[36];	{ Posted As }
    Real: STRING[36];	{ Real Name }
    Name: STRING[36];	{ System Name }
    Zone,				{ NetMail Address }
    Net,				{ NetMail Address }
    Node,				{ NetMail Address }
    Point: SmallWord;	{ NetMail Address }
  END;

  MHeaderRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
    From,
    MTO: FromToInfo;			{ Message From/To Info }
    Pointer: LongInt;			{ Starting Record Of Text }
    TextSize: SmallWord;		{ Size Of Text }
    ReplyTo: SmallWord;			{ Original + ReplyTo = Current }
    Date: UnixTime;				{ Date/Time Packed String }
    DayOfWeek: Byte;			{ Message Day Of Week     }
    Status: SET OF MsgStatusR;	{ Message Status Flags }
    Replies: SmallWord;			{ Times Replied To }
    Subject: STRING[40];		{ Subject }
    OriginDate: STRING[19];		{ Date Of Echo/Group Messages }
    FileAttached: Byte;			{ File Attached? 0=No, 1=Yes&Del, 2=Yes&Save }
    NetAttribute: NetAttribs;	{ Netmail Attributes }
    Res: ARRAY [1..2] OF Byte;	{ Reserved }
  END;

  HistoryRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { HISTORY.DAT : Summary Logs }
    Date: UniXTime;             { The Date }
    Active,                     { Activity }
    Callers,                    { Callers }
    NewUsers,                   { New Users }
    Posts,                      { Message Posts }
    Email,                      { Private Mail Sent }
    FeedBack,                   { Feedback Sent }
    Errors,                     { Errors }
    Uploads,                    { Uploads }
    Downloads,                  { Downloads }
    UK,                         { Uploaded KB }
    DK: LongInt;                { Downloaded KB }
    UserBaud: ARRAY [0..20] OF LongInt;
  END;

  FileArcInfoRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { Archive Configuration Records }
    Active: Boolean;		{ Active? }
    Ext: STRING[3];			{ File Extension }
    ListLine,				{ /X For Internal; X: 1=ZIP, 2=ARC/PAK, 3=ZOO, 4=LZH }
    ArcLine,				{ Compression CmdLine }
    UnArcLine,				{ De-Compression CmdLine }
    TestLine,				{ Integrity Test CmdLine }
    CmtLine: STRING[25];	{ Comment CmdLine }
    SuccLevel: SmallInt;	{ Success Errorlevel, -1 = Ignore Results }
  END;

  ModemFlagType =	{ MODEM.DAT Status Flags }
   (Lockedport,		{ COM Port Locked At Constant Rate }
    XOnXOff,		{ XON/XOFF (Software) Flow Control }
    CTSRTS);		{ CTS/RTS (Hardware) Flow Control }

  MFlagSet = SET OF ModemFlagType;

  LineRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
    InitBaud: LongInt;				{ Initialization Baud }
    ComPort: Byte;					{ COM Port Number }
    MFlags: MFlagSet;				{ Status Flags }
    Init,							{ Init String }
    Answer,							{ Answer String }
    Hangup,							{ Hangup String }
    Offhook: STRING[30];			{ Off-Hook String }
    DoorPath,						{ Path For Drop Files }
    TeleConfNormal,                 { TeleConferencing: Normal Prefix }
    TeleConfAnon,					{ TeleConferencing: Anonymous Prefix }
    TeleConfGlobal,					{ TeleConferencing: Global Prefix }
    TeleConfPrivate: STRING[40];	{ TeleConferencing: Private Prefix }
    Ok,								{ Modem Result Code }
    Ring,							{  "             " }
    Reliable,						{  "             " }
    CallerID,						{  "             " }
    NoCarrier: STRING[20];			{  "             " }
    Connect: ARRAY [1..22] OF STRING[20]; {  "             " }
	
    { 300, 600, 1200, 2400, 4800, 7200, 9600, 12000, 14400, 16800, 19200,
      21600, 24000, 26400, 28800, 31200, 33600, 38400, 57600, 115200 + 2 Extra }
    
	UseCallerID: Boolean;			{ Add Caller ID To SysOp Note }
    LogonACS: ACString;				{ ACS Required For This Node }
    IRQ,							{ IRQ Number - For %E MCI }
    Address: STRING[10];			{ I/O Address - For %C MCI }
    AnswerOnRing: Byte;				{ Answer After How Many Rings }
    MultiRing: Boolean;				{ Answer Ringmaster Or Other Multiple-Ring System Only }
    NodeTelnetURL: STRING[65];		{ Telnet URL }
  END;

  ValidationRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { Validation }
    Key,						{ Key '!' To '~' }
    ExpireTo: Char;				{ Validation Level To Expire To }
    Description: STRING[30];	{ Description }
    UserMsg: STRING[78];		{ Message Sent To User Upon Validation }
    NewSL,						{ New SL }
    NewDSL,						{ New DSL }
    NewMenu: Byte;				{ User Start Menu }
    Expiration: SmallWord;		{ Days Until Expiration }
    NewFP,						{ NOTHING }
    NewCredit: LongInt;			{ New Credit }
    SoftAR,						{ If True, AR Added To Current, Else Replaces }
    SoftAC: Boolean;			{ If True, AC Added To Current, Else Replaces }
    NewAR: ARFlagSet;			{ New AR }
    NewAC: FlagSet;				{ New AC }
  END;

  GeneralRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { RENEGADE.DAT }
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
    LastOnDatACS,					   { Add To Last Callers }
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
    NetMailACS,                        { Send NetMail }
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
    MaxMassMailList,				   { Max Length Of Mass-Mail List }
    MaxLogonTries,                     { Max Tries Allowed For PW's At Logon }
    SysOpColor,                        { SysOp Color In Chat Mode }
    UserColor,                         { User Color In Chat Mode }
    SliceTimer, 					   { Seconds Between Time Slices }
    MaxBatchDLFiles,				   { Max Files In Batch DL Queue }
    MaxBatchULFiles,				   { Max Files In Batch UL Queue }
	Text_Color,                        { Color Of Standard Text }
    Quote_Color,                       { Color Of Quoted Text }
    Tear_Color,                        { Color Of Tear Line }
    Origin_Color,                      { Color Of Origin Line }
    BackSysOpLogs,                     { Number Of Days To Keep SysOp Logs }
    EventWarningTime,                  { Minutes Before Event To Warn User }
    WFCBlankTime,                      { Minutes Before Blanking WFC Menu }
    AlertBeep,                         { Time Between Alert Beeps (Was Integer) }
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
    TimeOutBell,                       { Minutes Before TimeOut Alert }
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
    AllowAlias,                        { Allow Aliases (Handles)? }
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
    ValidateAllFiles,                  { Validate Uploads Automatically? }
    FileDiz,                           { Search/Import FILE_ID.DIZ }
    SysOpPword,                        { Check For SysOp Password? }
    TrapTeleConf,                      { Trap TeleConferencing To ROOM#.TRP? }
    IsTopWindow,                       { Is Window At Top Of Screen? }
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

    NewUserToggles: ARRAY [1..30] OF Boolean; { LeeW: New User Application Toggles }
	
    Macro: ARRAY [0..9] OF STRING[100]; { SysOp Macros }

    NetAttribute: NetAttribs;         { Default NetMail Attributes }
    TimeAllow,                        { Time Allowance }
    CallAllow,                        { Call Allowance }
    DLRatio,                          { Download/Upload Ratio (#) }
    DLKRatio,                         { Download/Upload Ratio (K) }
    PostRatio,                        { Post/Call Ratio }
    DLOneday,                         { Max Download In One Day (#) }
    DLKOneDay: SecurityRangeType;     { Max Download In One Day (K) }
	
	ConnectionType: Array [1..2] Of Boolean; { LeeW: Added } { 1 = Modem, 2 = Telnet }
	
	LastCallersInLogon,			{ LeeW: Added } { Display Last Callers During Logon }
	OneLinersInLogon,			{ LeeW: Added } { Display OneLiners During Logon }
	VoteInLogon: Boolean;		{ LeeW: Added } { Display Voting Information During Logon }
  END;

  ShortMessageRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { SHORTMSG.DAT : One-Line Messages }
    Msg: STRING[160];
    Destin: SmallInt;
  END;

  VotingRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { VOTING.DAT } { Voting Records }
    Question1,					 { Question, Line 1 }
    Question2: STRING[60];		 { Question, Line 2 }
    ACS: ACString;				 { ACS Required To Vote }
    ChoiceNumber: Byte;			 { Number Of Choices }
    NumVotedQuestion: SmallInt;	 { Number Of Votes }
    CreatedBy: STRING[36];		 { Author }
    AddAnswersACS: ACString;	 { ACS Required To Add Answer }
      Answers: ARRAY [1..25] OF {$IFDEF WIN32} PACKED {$ENDIF} RECORD
	  Answer1,				     { Answer, Line 1 }
	  Answer2: STRING[59];	     { Answer, Line 2 } {65}
	  NumVotedAnswer: SmallInt;  { Number Of Votes }
	  END;
  END;

  MessageAreaFlagType =
   (MARealName,                   { Whether Real Names Are Forced }
    MAUnHidden,                   { Whether Visible To Users Without Access }
    MAFilter,                     { Whether To Filter ANSI/8-Bit ASCII }
    MAPrivate,                    { Allow Private Messages }
    MAForceRead,                  { Force The Reading Of This Area }
    MAQuote,                      { Allow Quote/Tagline To Messages Posted In This Area }
    MASKludge,                    { Strip IFNA Kludge Lines }
    MASSeenBy,                    { Strip Seen-By Lines }
    MASOrigin,                    { Strip Origin Lines }
    MAAddTear,                    { Add Tear/Origin Lines }
    MAInternet,                   { If Internet Message Area }
    MAScanOut);                   { Needs To Be Scanned Out By ReneMail }

  MAFlagSet = SET OF MessageAreaFlagType;

  MessageAreaRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { MBASES.DAT : Message Area Records }
    Name: STRING[40];             { Message Area Description }
    FileName: STRING[8];          { HDR/DAT Data Filename }
    MsgPath: STRING[40];          { NOT USED } { Messages Pathname }
    ACS,                          { ACS To Access }
    PostACS,                      { ACS To Post }
    MCIACS,                       { ACS To Use MCIs }
    SysOpACS: ACString;           { ACS To Be Message Area SysOp }
    MaxMsgs: SmallWord;           { Max Message Count }
    Anonymous: AnonTyp;           { Anonymous Type }
    Password: STRING[20];         { Password }
    MAFlags: MAFlagSet;           { Message Area Status Vars }
    MAType: SmallInt;             { Area Type: 0=Local 1=Echo 3=QWK }
    Origin: STRING[50];           { Origin Line }
    Text_Color,                   { Color Of Standard Text }
    Quote_Color,                  { Color Of Quoted Text }
    Tear_Color,                   { Color Of Tear Line }
    Origin_Color,                 { Color Of Origin Line }
    MessageReadMenu: Byte;		  {  }
    QuoteStart,					  {  }
    QuoteEnd: STRING[70];		  {  }
    PrePostFile: STRING[8];		  {  }
    AKA: Byte;                    { Alternate Address }
    QWKIndex: SmallWord;          { QWK Indexing Number }
  END;

  FileAreaFlagType =
   (FANoRatio,                    { If No Ratio Active }
    FAUnHidden,                   { Whether Visible To Users Without Access }
    FADirDLPath,                  { If .DIR File Stored In DLPATH }
    FAShowName,                   { Show Uploaders In Listings }
    FAUseGIFSpecs,                { Use GIFSpecs }
    FACDROM,                      { Area Is Read Only, No Sorting Or UL Scanning }
    FAShowDate,                   { Show Date Uploaded In Listings }
    FANoDupeCheck);               { No Dupe Check }

  FAFlagSet = SET OF FileAreaFlagType;

  FileAreaRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { FBASES.DAT  : File area records }
    AreaName: STRING[40];         { area description  }
    FileName: STRING[8];          { filename + ".DIR" }
    DLPath,                       { download path     }
    ULPath: STRING[40];           { upload path       }
    MaxFiles: SmallInt;           { max files allowed - VerbRec Limit would allow up to LongInt Value or Maximum 433835}
    Password: STRING[20];         { Password Required }
    ArcType,                      { Wanted Archive Type (1-Max, 0=Inactive) }
    CmtType: Byte;                { Wanted Comment Type (1-3, 0=Inactive) }
    ACS,                          { access requirements }
    ULACS,                        { upload requirements }
    DLACS: ACString;              { download requirements }
    FAFlags: FAFlagSet;           { file area Flags }
  END;

  FileInfoFlagType =
   (FINotVal,                     { If File Is Not Validated }
    FIIsRequest,                  { If File Is REQUEST }
    FIResumeLater,                { If File Is RESUME-LATER }
    FIHatched,                    { Has File Been Hatched? }
    FIOwnerCredited,			  {  }
    FIUnusedFlag1,				  {  }
    FIUnusedFlag2,				  {  }
    FIUnusedFlag3);				  {  }

  FIFlagSet = SET OF FileInfoFlagType;

  FileInfoRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { *.DIR : File records }
    FileName: STRING[12];          { Filename }
    Description: STRING[50];       { File Description }
    FilePoints: SmallInt;          { File Points }
    Downloaded: LongInt;           { Number Of Times Downloaded }
    FileSize: LongInt;             { File Size (Bytes) }
    OwnerNum: SmallInt;            { Uploaders User Number }
    OwnerName: STRING[36];         { Uploaders User Name }
    FileDate: UnixTime;            { Date Uploaded }
    VPointer: LongInt;             { Pointer to verbose descr, -1 if none }
    VTextSize: SmallInt;           { Verbose descr textsize - 50 Bytes x 99 Lines = 4950 max }
    FIFlags: FIFlagSet;            { File Status }
  END;

  LastCallerRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { LASTON.DAT : Last few callers records }
    Node: Byte;                      { Node Number }
    UserName: STRING[36];            { User Name }
    Location: STRING[30];            { Location }
    Caller,                          { Caller number } { LeeW: What does this do? it's just set in sys cfg}
    UserID,                          { User ID # }
    Speed: LongInt;                  { Speed, 0=Local }
    LogonTime,                       { Time Logged On }
    LogoffTime: UnixTime;            { Time Logged Off }
    NewUser,                         { Are They A New User? }
    Invisible: Boolean;              { Invisible User? } { LeeW: Remove? }
    Uploads,                         { Uploads During Call }
    Downloads,                       { Downloads During Call }
    MsgRead,                         { Messages Read }
    MsgPost,                         { Messages Posted }
    EmailSent,                       { Email Sent }
    FeedbackSent: SmallWord;         { Feedback Sent }
    UK,                              { Upload/Download Kbytes During Call }
									 { LeeW: Are we to assume all these stats are 'during call'? ^^^ }
    DK: LongInt;
    Reserved: ARRAY [1..17] OF Byte; { Reserved }
  END;

  EventFlagType =
   (EventIsExternal,
    EventIsActive,
    EventIsErrorLevel,
    EventIsShell,
    EventIsPackMsgAreas,
    EventIsSortFiles,
    EventIsFilesBBS,
    EventIsLogon,
    EventIsChat,
    EventIsOffHook,
    EventIsMonthly,
    EventIsPermission,
    EventIsSoft,
    EventIsMissed,
    BaudIsActive,
    ACSIsActive,
    TimeIsActive,
    ARisActive,
    SetARisActive,
    ClearARisActive,
    InRatioIsActive);

  EFlagSet = SET OF EventFlagType;

  EventDaysType  = SET OF 0..6; {Set Of Event Days}

  EventRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD {Events - EVENTS.DAT}
    EventDescription: STRING[30]; {Description of the Event}
    EventDayOfMonth: BYTE;        {If monthly, the Day of Month}
    EventDays: EventDaysType;     {If Daily, the Days Active}
    EventStartTime,               {Start Time in Min from Mid.}
    EventFinishTime: SmallWord;   {Finish Time}
    EventQualMsg,                 {Msg/Path if he qualifies}
    EventNotQualMsg: STRING[64];  {Msg/Path if he doesn't}
    EventPreTime: BYTE;           {Min. B4 event to rest. Call}
    EventNode: Byte;			  {  }
    EventLastDate: UnixTime;      {Last Date Executed}
    EventErrorLevel: BYTE;        {For Ext Event ErrorLevel}
    EventShellPath: STRING[8];    {File for Ext Event Shell}
    LoBaud,                       {Low baud rate limit}
    HiBaud: LongInt;              {High baud rate limit}
    EventACS: ACString;           {Event ACS}
    MaxTimeAllowed: SmallWord;    {Max Time per user this event}
    SetARflag,                    {AR Flag to Set}
    ClearARflag: CHAR;            {AR Flag to Clear}
    EFlags: EFlagSet;             {Kinds of Events Supported}   { Changed }
  END;

  ProtocolFlagType =
   (ProtActive,
    ProtIsBatch,
    ProtIsResume,
    ProtXferOkCode,
    ProtBiDirectional,
    ProtReliable);

  PRFlagSet = SET OF ProtocolFlagType;

  ProtocolCodeType = ARRAY [1..6] OF STRING[6];

  ProtocolRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { PROTOCOL.DAT }
    PRFlags: PRFlagSet;                           { Protocol Flags }
    CKeys: STRING[14];                            { Command Keys }
    Description: STRING[40];                      { Description }
    ACS: ACString;                                { User Access STRING }
    TempLog,                                      { Utilized for Batch DL's - Temporary Log File }
    DLoadLog,                                     { Utilized for Batch DL's - Permanent Log Files }
    ULoadLog,                                     { Not Utilized }
    DLFList: STRING[25];                          { Utilized for Batch DL's - DL File Lists }
    DLCmd,                                        { DL Command Line }
    ULCmd: STRING[76];                            { UL Command Line }
    DLCode,                                       { DL Status/Return codes }
    ULCode: ProtocolCodeType;                     { UL StAtus/Return codes }
    EnvCmd: STRING[60];                           { Environment Setup Cmd }
    MaxChrs,                                      { Utilized for Batch DL's - Max chrs in cmdline }
    TempLogPF,                                    { Utilized for Batch DL's - Position in log for DL Status }
    TempLogPS: Byte;                              { Utilized for Batch DL's - Position in log for file data }
  END;

  ConferenceRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { CONFRENC.DAT : Conference data }
    Key: Char;            { Key: '@' To 'Z' }
    Name: STRING[30];     { Name Of Conference }
    ACS: ACString;        { Access Requirement }
  END;

  NodeFlagType =
   (NActive,                 { Is this node active?               }
    NAvail,                  { Is this node's user available?     }
    NUpdate,                 { This node should re-read it's user }
    NHangup,                 { Hangup on this node                }
    NRecycle,                { Recycle this node to the OS        }
    NInvisible);             { This node is Invisible             }

  NodeFlagSet = SET OF NodeFlagType;

  NodeRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { MULTNODE.DAT }
    User: SmallWord;                            { What user number }
    UserName: STRING[36];                       { User's name }
    CityState: STRING[30];                      { User's location }
    Sex: Char;                                  { User's sex }
    Age: Byte;                                  { User's age }
    LogonTime: UnixTime;                        { What time they logged on }
    GroupChat: Boolean;                         { Are we in MultiNode Chat }
    ActivityDesc: STRING[50];                   { Activity STRING }
    Status: NodeFlagSet;
    Room: Byte;                                 { What room are they in? }
    Channel: SmallWord;                         { What channel are they in? }
    Invited,                                    { Have they been invited ? }
    Booted,                                     { Have they been kicked off ? }
    Forget: ARRAY [0..31] OF SET OF 0..7;       { Who are they forgetting? }
  END;

  RoomRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { ROOM.DAT }
    Topic: STRING[40];              { Topic OF this room          }
    Anonymous: Boolean;             { Is Room anonymous ?         }
    Private: Boolean;               { Is Room private ?           }
    Occupied: Boolean;              { Is anyone in here?          }
    Moderator: SmallWord;           { Who's the moderator?        }
  END;

  ScanRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { *.SCN files / MESSAGES }
    NewScan: Boolean;               { Scan this area? }
    LastRead: UnixTime;             { Last date read }
  END;

  SchemeRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { Scheme.dat }
    Description: STRING[30];        { Description Of The Color Scheme }
    Color: ARRAY [1..200] OF Byte;  { Colors in scheme }
  END;

 { 001 - 010 : System Colors
   011 - 027 : File List Colors
   028 - 044 : Message List Colors
   045 - 054 : File Area List Colors
   055 - 064 : Message Area List Colors
   065 - 079 : User List Colors
   080 - 099 : Who's Online Colors
   100 - 114 : Last On Colors
   115 - 134 : QWK Colors
   135 - ??? : E-Mail Colors } { LeeW: All that is irrelevant now }

  BBSListRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { *.BBS file records }
    RecordNum,                    { Number Of The Record For Edit }
    UserID,                       { User ID Of Person Adding This }
    MaxNodes        : LongInt;    { Maximum Number Of Nodes }
    Port            : Word;       { Telnet Port }
    BBSName         : STRING[30]; { Name Of BBS }
    SysOpName       : STRING[30]; { SysOp Of BBS }
    TelnetUrl       : STRING[60]; { Telnet URL }
    WebSiteUrl      : STRING[60]; { Web Site URL }
    PhoneNumber     : STRING[20]; { Phone Number Of BBS }
    Location        : STRING[30]; { Location Of BBS }
    Software,                     { Software Used By BBS }
    SoftwareVersion : String[12]; { Software Version Of BBS }
    OS              : STRING[20]; { Operating System Of BBS }
    Speed           : STRING[8];  { Highest Connect Speed Of BBS }
    Hours           : STRING[20]; { Hours Of Operation }
    Birth           : STRING[10]; { When The BBS Began }
    Description     : STRING[60]; { Description Of BBS }
    Description2    : STRING[60]; { Description Of BBS, Line 2 }
    DateAdded       : UnixTime;   { Date Entry Was Added }
    DateEdited      : UnixTime;   { Date Entry Was Edited }
    SDA             : STRING[8];  { SysOp Definable A }
    SDB             : STRING[30]; { SysOp Definable B }
    SDC             : STRING[30]; { SysOp Definable C }
    SDD             : STRING[40]; { SysOp Definable D }
    SDE             : STRING[60]; { SysOp Definable E }
    SDF             : STRING[60]; { SysOp Definable F }
    SDG             : Word;       { SysOp Definable G }
    SDH,                          { SysOp Definable H }
    SDI             : Boolean;    { SysOp Definable I }
  END;

  MenuFlagType =
    (ClrScrBefore,                 { C: Clear Screen Before Menu Is Displayed }
     DontCenter,                   { D: Don't Center Menu Titles }
     NoMenuTitle,                  { T: No Menu Titles Displayed }
     NoMenuPrompt,                 { N: No Menu Prompt }
     ForcePause,                   { P: Pause Before Menu Is Displayed }
     AutoTime,                     { A: Display Time Automatically }
     ForceLine,                    { F: Force Full Line Input }
     NoGenericAnsi,                { 1: No ANSI Prompt }
     NoGenericAvatar,              { 2: No AVT Prompt }
     NoGenericRIP,                 { 3: No RIP Prompt }
     NoGlobalDisplayed,            { 4: Do Not Display Global Commands }
     NoGlobalUsed);                { 5: Do Not Use Global Commands }

  MenuFlagSet = SET OF MenuFlagType;

  CmdFlagType =
     (Hidden,                       { H: Command Is Always Hidden }
      UnHidden);                    { U: Command Is Always Visible }

  CmdFlagSet = SET OF CmdFlagType;

  MenuRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD
    LDesc: ARRAY [1..3] OF STRING[100];  { Menu Or Command Long Description Array }
    ACS: ACString;                       { Access Requirements }
    NodeActivityDesc: STRING[50];
    CASE Menu: Boolean OF                { Menu Or Command - Variant Section }
      TRUE:
        (MenuFlags: MenuFlagSet;         { Menu Flag Set }
         LongMenu: STRING[12];           { Displayed In Place OF Long Description }
         MenuNum: Byte;                  { Menu Number }
         MenuPrompt: STRING[120];        { Menu Prompt }
         Password: STRING[20];           { Menu Password }
         FallBack: Byte;                 { Menu Fallback Number }
         Directive: STRING[12];
         ForceHelpLevel: Byte;           { Menu Forced Help Level }
         GenCols: Byte;                  { Generic Menus: # Of Columns }
         GCol: ARRAY [1..3] OF Byte);    { Generic Menus: Colors }
      FALSE:
        (CmdFlags: CmdFlagSet;           { Command Flag Set }
         SDesc: STRING[35];              { Command Short Description }
         CKeys: STRING[14];              { Command Execution Keys }
         CmdKeys: STRING[2];             { Command Keys: Type Of Command }
         Options: STRING[50]);           { MString: Command Data }
    END;