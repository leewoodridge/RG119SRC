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
  UnixTime = LongInt;             { Seconds Since 1-1-70 }
  ACString = STRING[20];          { AC String }
  ARFlagType = '@'..'Z';          { AR Flags }

  ARFlagSet = SET OF ARFlagType;  {SET OF AR flags}
  FlagType =
   (RLogon,                       { L - Limited to one call a day }
    RChat,                        { C - No SysOp paging }
    RValidate,                    { V - Posts are unvalidated }
    RUserList,                    { U - Can't list users }
    RAMsg,                        { A - Can't leave automsg }
    RPostAn,                      { * - Can't post anonymously }
    RPost,                        { P - Can't post }
    REmail,                       { E - Can't send email }
    RVoting,                      { K - Can't use voting booth }
    RMsg,                         { M - Force email deletion }
    VT100,                        { Supports VT00 }
    HotKey,                       { hotkey input mode }
    Avatar,                       { Supports Avatar }
    Pause,                        { screen pausing }
    Novice,                       { user requires novice help }
    ANSI,                         { Supports ANSI }
    Color,                        { Supports color }
    Alert,                        { Alert SysOp upon login }
    SMW,                          { Short Message(s) Waiting }
    NoMail,                       { Mailbox Is Closed }
    FNoDLRatio,                   { 1 - No UL/DL Ratio }
    FNoPostRatio,                 { 2 - No Post/Call Ratio }
    FNoCredits,                   { 3 - No Credits Checking }
    FNoDeletion);                 { 4 - Protected From Deletion }

  FlagSet = SET OF FlagType;

  StatusFlagType =
   (LockedOut,                    { If Locked Out }
    Deleted,                      { If Deleted }
    TrapActivity,	              { If Trapping Users Activity }
    TrapSeparate,                 { If Trap To Seperate File }
    ChatAuto,                     { If Auto Chat Trapping }
    ChatSeparate,                 { If Separate Chat File To Trap To }
    SLogSeparate,                 { If Separate SysOp Log }
    CLSMsg,                       { If Screen Clearing }
    RIP,                          { If RIP Graphics Can Be Used }
    FSEditor,                     { If Full Screen Editor }
    AutoDetect,                   { Use Auto-Detected Emulation }
    FileAreaLightBar,
    MsgAreaLightBar,
    UnUsedStatusFlag1,
    UnUsedStatusFlag2,
    UnUsedStatusFlag3
  );

  StatusFlagSet = SET OF StatusFlagType;

  ANonTyp =
   (ATNo,		{ Anonymous Posts Not Allowed }
    ATYes,		{ Anonymous Posts Are Allowed }
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
    Downloads,                              { # OF Downloads }
    UK,                                     { Uploaded Kb }
    DK,                                     { Downloaded Kb }
    LoggedOn,                               { # Times On }
    MsgPost,                                { # Message Posts }
    EmailSent,                              { # E-mail Sent }
    FeedBack,                               { # Feedback Sent }
    TimeBank,                               { # Mins In Bank }
    TimeBankAdd,                            { # Mins Deposited Today }
	TimeBankWith,                           { Time Withdrawn }
    DLKToday,                               { # KBytes Downloaded Today }
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
    Anon: Byte;
    UserNum: SmallWord;	{ User Number }
    A1S: STRING[36];	{ Posted As }
    Real: STRING[36];	{ Real Name }
    Name: STRING[36];	{ System Name }
    Zone,
    Net,
    Node,
    Point: SmallWord;
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
    Active,                     {  }
    Callers,                    { Callers }
    NewUsers,                   { New Users }
    Posts,                      { Message Posts }
    Email,                      { Private Mail Sent }
    FeedBack,                   { Feedback Sent }
    Errors,                     { Errors }
    Uploads,                    { # Of Uploads }
    Downloads,                  { # Of Downloads }
    UK,                         { Uploaded Kb }
    DK: LongInt;                { Downloaded Kb }
    UserBaud: ARRAY [0..20] OF LongInt;
  END;

  FileArcInfoRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { Archive Configuration Records }
    Active: Boolean;		{ Active Or Not }
    Ext: STRING[3];			{ File Extension }
    ListLine,				{ /X For Internal; X: 1=ZIP, 2=ARC/PAK, 3=ZOO, 4=LZH }
    ArcLine,				{ Compression CmdLine }
    UnArcLine,				{ De-Compression CmdLine }
    TestLine,				{ Integrity Test CmdLine }
    CmtLine: STRING[25];	{ Comment CmdLine }
    SuccLevel: SmallInt;	{ Success Errorlevel, -1=Ignore Results }
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
    TeleConfNormal,                 { Teleconferencing Strings }
    TeleConfAnon,					
    TeleConfGlobal,
    TeleConfPrivate: STRING[40];
    Ok,
    Ring,
    Reliable,
    CallerID,
    NoCarrier: STRING[20];
    Connect: ARRAY [1..22] OF STRING[20];
	
    { 300, 600, 1200, 2400, 4800, 7200, 9600, 12000, 14400, 16800, 19200,
      21600, 24000, 26400, 28800, 31200, 33600, 38400, 57600, 115200 + 2 Extra }
    
	UseCallerID: Boolean;			{ Add Caller ID To SysOp Note }
    LogonACS: ACString;				{ ACS Required For This Node }
    IRQ,
    Address: STRING[10];			{ Used Only For Functional MCI Codes
									  %C = Comport Address, %E = IRQ }
    AnswerOnRing: Byte;				{ Answer After How Many Rings }
    MultiRing: Boolean;				{ Answer Ringmaster Or Other Multiple-Ring System Only }
    NodeTelnetUrl: STRING[65];		{ Telnet URL }
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

  GeneralRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { General }
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
    lMultPath,                         { Mult Path }
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
    TeleConfMCI,                       { Use MCI In Teleconference }
    OverrideChat,                      { Override Chat Hours }
    NetMailACS,                        { NetMail }
    Invisible,                         { Invisible Mode } { Should This Be Deleted? }
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
    MaxBatchDLFiles,				   {}
    MaxBatchULFiles,				   {}
    Text_Color,                        { color OF standard text }
    Quote_Color,                       { color OF quoted text }
    Tear_Color,                        { color OF tear line }
    Origin_Color,                      { color OF origin line }
    BackSysOpLogs,                     { Days To Keep SYSOP##.LOG }
    EventWarningTime,                  { minutes before event to warn user }
    WFCBlankTime,                      { minutes before blanking WFC menu }
    AlertBeep,                         { time between alert beeps - Was Integer }
    FileCreditComp,                    { file credit compensation ratio }
    FileCreditCompBaseSize,            { file credit area compensation size }
    ULRefund,                          { percent OF time to refund on ULs }
    GlobalMenu,						   {}
    AllStartMenu,					   {}
    ShuttleLogonMenu,				   {}
    NewUserInformationMenu,			   {}
    FileListingMenu,				   {}
    MessageReadMenu,				   {}
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
    MinimumBaud,                       { minimum baud rate to logon }
    MinimumDLBaud,                     { minimum baud rate to download }
    MaxDepositEver,					   { Maximum Amount Of Time Allowed In TimeBank }
    MaxDepositPerDay,				   { Maximum Daily TimeBank Deposit }
    MaxWithdrawalPerDay,			   { Maximum Daily TimeBank Withdrawl }
    CallerNum,                         { system caller number }
    RegNumber,                         { registration number }
    TotalCalls,                        { incase different from callernum }
    TotalUsage,                        { total usage in minutes }
    TotalPosts,                        { total number OF posts }
    TotalDloads,                       { total number OF dloads }
    TotalUloads,                       { total number OF uloads }
    MinResume,                         { min K to allow resume-later }
    MaxInTemp,                         { max K allowed in TEMP }
    MinSpaceForPost,                   { minimum drive space left to post }
    MinSpaceForUpload: LongInt;        { minimum drive space left to upload }
    UnUsedLongInt1,                    { UNUSED }
    UnUsedLongInt2: LongInt;           { UNUSED }
    AllowAlias,                        { allow handles? }
    PhonePW,                           { phone number password in logon? }
    LocalSec,                          { use local security? }
    GlobalTrap,                        { trap everyone's activity? }
    AutoChatOpen,                      { automatically open chat buffer? }
    AutoMInLogon,                      { Auto-Message at logon? }
    BullInLogon,                       { bulletins at logon? }
    YourInfoInLogon,                   { "Your Info" at logon? }
    OffHookLocalLogon,                 { phone off-hook for local logons? }
    ForceVoting,                       { manditory voting? }
    CompressBases,                     { "compress" file/msg area numbers? }
    SearchDup,                         { search for dupes files when UL? }
    ForceBatchDL,                      {  }
    ForceBatchUL,                      {  }
    LogonQuote,				           { Quotes In Logon? }
    UserAddQuote,                      { Ask User To Add Quote In Logon? }
    StripCLog,                         { strip colors from SysOp log? }
    SKludge,                           { show kludge lines? }
    SSeenby,                           { show SEEN-BY lines? }
    SOrigin,                           { show origin line? }
    AddTear,                           { show tear line? }
    ShuttleLog,                        { Use Shuttle Logon? }
    ClosedSystem,                      { Allow new users? }
    SwapShell,                         { Swap on shell? }
    UseEMS,                            { use EMS for overlay }
    UseBios,                           { use BIOS for video output }
    UseIEMSI,                          { use IEMSI }
    ULDLRatio,                         { use UL/DL ratios? }
    FileCreditRatio,                   { use auto file-credit compensation? }
    ValidateAllFiles,                  { validate files automatically? }
    FileDiz,                           { Search/Import file_id.diz }
    SysOpPword,                        { check for sysop password? }
    TrapTeleConf,                      { Trap teleconferencing to ROOMx.TRP? }
    IsTopWindow,                       { is window at top OF screen? }
    ReCompress,                        { recompress like archives? }
    RewardSystem,                      { use file rewarding system? }
    TrapGroup,                         { record group chats? }
    QWKTimeIgnore,                     { ignore time remaining for qwk download? }
    NetworkMode,                       { Network mode ? }
    WindowOn,                          { is the sysop window on? }
    ChatCall,                          { Whether system keeps beeping after chat}
    DailyLimits,                       { Daily file limits on/off }
    MultiNode,                         { enable multinode support }
    PerCall,                           { time limits are per call or per day?}
    TestUploads,                       { perform integrity tests on uploads? }
    UseFileAreaLightBar,		  	   { File Area LightBar }
    UseMsgAreaLightBar: Boolean;  	   { Message Area LightBar }
    ShuttleUnvalLogin,                 { Can UnValidated Users Logon From Shuttle Menu? } { Was UnUsedBoolean1 } 
    UnUsedBoolean2: Boolean;           { UNUSED }
	
	ConnectionType: Array [1..2] Of Boolean; { 1 = Modem, 2 = Telnet }
	  
    FileArcInfo: ARRAY [1..MaxArcs] OF FileArcInfoRecordType; { Archive Specs }

    FileArcComment: ARRAY [1..3] OF STRING[40]; { BBS Comment Files For Archives }

    Aka: ARRAY [0..20] OF {$IFDEF WIN32} PACKED {$ENDIF} RECORD { 20 Addresses } { 21 = UUCP Address }
      Zone,                           
      Net,
      Node,
      Point: SmallWord;
    END;

    NewUserToggles: ARRAY [1..27] OF Boolean; { New User Application Toggles }

    Macro: ARRAY [0..9] OF STRING[100]; { SysOp Macros }

    NetAttribute: NetAttribs;         { Default NetMail Attributes }
    TimeAllow,                        { Time Allowance }
    CallAllow,                        { Call Allowance }
    DLRatio,                          { # ULs/# DLs Ratios }
    DLKRatio,                         { DLk/ULk ratios }
    PostRatio,                        { Posts/Call Ratio }
    DLOneday,                         { Max Downloads In One Day }
    DLKOneDay: SecurityRangeType;     { Max K Downloaded In One Day }
  END;

  ShortMessageRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { SHORTMSG.DAT : One-Line Messages }
    Msg: AStr;
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
	  Answer2: STRING[65];	     { Answer, Line 2 }
	  NumVotedAnswer: SmallInt;  { Number Of Votes }
	  END;
  END;

  MessageAreaFlagType =
   (MARealName,                   { whether real names are forced }
    MAUnHidden,                   { whether *VISIBLE* to users w/o access }
    MAFilter,                     { whether to filter ANSI/8-bit ASCII }
    MAPrivate,                    { allow private messages }
    MAForceRead,                  { force the reading of this area }
    MAQuote,                      { Allow Quote/Tagline to messages posted in this area }
    MASKludge,                    { strip IFNA kludge lines }
    MASSeenBy,                    { strip SEEN-BY lines }
    MASOrigin,                    { strip origin lines }
    MAAddTear,                    { add tear/origin lines }
    MAInternet,                   { if internet message area }
    MAScanOut);                   { Needs to be scanned out by renemail }

  MAFlagSet = SET OF MessageAreaFlagType;

  MessageAreaRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { MBASES.DAT : Message Area Records }
    Name: STRING[40];             { message area description }
    FileName: STRING[8];          { HDR/DAT data filename }
    MsgPath: STRING[40];          { Not Used } { Messages Pathname }
    ACS,                          { access requirement }
    PostACS,                      { post access requirement }
    MCIACS,                       { MCI usage requirement }
    SysOpACS: ACString;           { Message area sysop requirement }
    MaxMsgs: SmallWord;           { max message count }
    Anonymous: AnonTyp;           { anonymous type }
    Password: STRING[20];         { area password }
    MAFlags: MAFlagSet;           { message area status vars }
    MAType: SmallInt;             { Area type (0=Local,1=Echo, 3=Qwk) }
    Origin: STRING[50];           { origin line }
    Text_Color,                   { color OF standard text }
    Quote_Color,                  { color OF quoted text }
    Tear_Color,                   { color OF tear line }
    Origin_Color,                 { color OF origin line }
    MessageReadMenu: Byte;
    QuoteStart,
    QuoteEnd: STRING[70];
    PrePostFile: STRING[8];
    AKA: Byte;                    { alternate address }
    QWKIndex: SmallWord;          { QWK indexing number }
  END;

  FileAreaFlagType =
   (FANoRatio,                    { if <No Ratio> active }
    FAUnHidden,                   { whether *VISIBLE* to users w/o access }
    FADirDLPath,                  { if *.DIR file stored in DLPATH }
    FAShowName,                   { show uploaders in listings }
    FAUseGIFSpecs,                { whether to use GifSpecs }
    FACDROM,                      { Area is read only, no sorting or ul scanning }
    FAShowDate,                   { show date uploaded in listings }
    FANoDupeCheck);               { No dupe check on this area }

  FAFlagSet = SET OF FileAreaFlagType;

  FileAreaRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { FBASES.DAT  : File area records }
    AreaName: STRING[40];         { area description  }
    FileName: STRING[8];          { filename + ".DIR" }
    DLPath,                       { download path     }
    ULPath: STRING[40];           { upload path       }
    MaxFiles: SmallInt;           { max files allowed - VerbRec Limit would allow up to LongInt Value or Maximum 433835}
    Password: STRING[20];         { password required }
    ArcType,                      { wanted archive type (1..max,0=inactive) }
    CmtType: Byte;                { wanted comment type (1..3,0=inactive) }
    ACS,                          { access requirements }
    ULACS,                        { upload requirements }
    DLACS: ACString;              { download requirements }
    FAFlags: FAFlagSet;           { file area status vars }
  END;

  FileInfoFlagType =
   (FINotVal,                     { If file is not validated }
    FIIsRequest,                  { If file is REQUEST }
    FIResumeLater,                { If file is RESUME-LATER }
    FIHatched,                    { Has file been hatched? }
    FIOwnerCredited,
    FIUnusedFlag1,
    FIUnusedFlag2,
    FIUnusedFlag3);

  FIFlagSet = SET OF FileInfoFlagType;

  FileInfoRecordType = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { *.DIR : File records }
    FileName: STRING[12];          { Filename }
    Description: STRING[50];       { File description }
    FilePoints: SmallInt;          { File points }
    Downloaded: LongInt;           { Number DLs }
    FileSize: LongInt;             { File size in Bytes }
    OwnerNum: SmallInt;            { ULer OF file }
    OwnerName: STRING[36];         { ULer's name }
    FileDate: UnixTime;            { Date ULed }
    VPointer: LongInt;             { Pointer to verbose descr, -1 if none }
    VTextSize: SmallInt;           { Verbose descr textsize - 50 Bytes x 99 Lines = 4950 max }
    FIFlags: FIFlagSet;            { File status }
  END;

  LastCallerRec = {$IFDEF WIN32} PACKED {$ENDIF} RECORD { LASTON.DAT : Last few callers records }
    Node: Byte;                      { Node number }
    UserName: STRING[36];            { User name OF caller }
    Location: STRING[30];            { Location OF caller }
    Caller,                          { system caller number }
    UserID,                          { User ID # }
    Speed: LongInt;                  { Speed OF caller 0=Local }
    LogonTime,                       { time user logged on }
    LogoffTime: UnixTime;            { time user logged off }
    NewUser,                         { was it a new user? }
    Invisible: Boolean;              { Invisible user? }
    Uploads,                         { Uploads during call }
    Downloads,                       { Downloads during call }
    MsgRead,                         { Messages Read }
    MsgPost,                         { Messages Posted }
    EmailSent,                       { Email sent }
    FeedbackSent: SmallWord;         { Feedback sent }
    UK,                              { Upload/Download kbytes during call }
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
    Key: Char;            { key '@' to 'Z' }
    Name: STRING[30];     { name of conference }
    ACS: ACString;        { access requirement }
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
    Description: STRING[30];        { Description OF the color scheme }
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
   135 - ??? : E-Mail Colors }

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
    (ClrScrBefore,                 { C: clear screen before menu display }
     DontCenter,                   { D: don't center the menu titles }
     NoMenuTitle,                  { T: no menu title displayed }
     NoMenuPrompt,                 { N: no menu prompt whatsoever? }
     ForcePause,                   { P: force a pause before menu display? }
     AutoTime,                     { A: is time displayed automatically? }
     ForceLine,                    { F: Force full line input }
     NoGenericAnsi,                { 1: DO NOT generate generic prompt if ANSI }
     NoGenericAvatar,              { 2: DO NOT generate generic prompt if AVT }
     NoGenericRIP,                 { 3: DO NOT generate generic prompt if RIP }
     NoGlobalDisplayed,            { 4: DO NOT display the global commands }
     NoGlobalUsed);                { 5: DO NOT use global commands }

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