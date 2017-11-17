{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  ----------------------------------------------------------------------
  FILE SYSTEM CONFIGURATION }

UNIT SysOp2F;

INTERFACE

PROCEDURE FileAreaConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE FileAreaConfiguration;
VAR
  Cmd: Char;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      Cls;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : File System Configuration',80));
      {NL;}
      PrintACR('^0(^1A^0) File Ratio System                : ^1'+ShowOnOff(ULDLRatio));
      PrintACR('^0(^1B^0) File Point System                : ^1'+ShowOnOff(FileCreditRatio));
      PrintACR('^0(^1C^0) Daily DL Limits                  : ^1'+ShowOnOff(DailyLimits));
      PrintACR('^0(^1D^0) Test/Convert Uploads             : ^1'+ShowOnOff(TestUploads));
      PrintACR('^0(^1E^0) File Point Rewarding System      : ^1'+ShowOnOff(RewardSystem));
      PrintACR('^0(^1F^0) Search For/Use FILE_ID.DIZ       : ^1'+ShowOnOff(FileDiz));
      PrintACR('^0(^1G^0) Recompress Like Archives         : ^1'+ShowOnOff(Recompress));
      PrintACR('^0(^1H^0) Credit Reward Compensation Ratio : ^1'+IntToStr(RewardRatio)+'^0%');
      PrintACR('^0(^1I^0) File Point Compensation Ratio    : ^1'+IntToStr(FileCreditComp)+'^0 To ^11');
      PrintACR('^0(^1J^0) File Size Per 1 File Point       : ^1'+IntToStr(FileCreditCompBaseSize)+'^0k');
      PrintACR('^0(^1K^0) Upload Time Refund               : ^1'+IntToStr(ULRefund)+'^0%');
      PrintACR('^0(^1L^0) "To SysOp" File Area             : ^1'+AOnOff(ToSysOpDir = 0,'*None*',IntToStr(ToSysOpDir)));
      PrintACR('^0(^1M^0) Auto-Validate All Files          : ^1'+ShowYesNo(ValidateAllFiles));
      PrintACR('^0(^1N^0) Max KBytes Allowed In Temp Dir   : ^1'+IntToStr(MaxInTemp)+'^0k');
      PrintACR('^0(^1O^0) Min KBytes To Save For Resume    : ^1'+IntToStr(MinResume)+'^0k');
      PrintACR('^0(^1P^0) Max Batch DL Files               : ^1'+IntToStr(MaxBatchDLFiles));
      PrintACR('^0(^1R^0) Max Batch UL Files               : ^1'+IntToStr(MaxBatchUlFiles));
      PrintACR('^0(^1S^0) UL Duplicate File Search         : ^1'+ShowOnOff(SearchDup));
      PrintACR('^0(^1T^0) Force Batch DL At Login          : ^1'+ShowOnOff(ForceBatchDL));
      PrintACR('^0(^1U^0) Force Batch UL At Login          : ^1'+ShowOnOff(ForceBatchUL));
      NL;
      Prt('^0File System Configuration: ');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTU',TRUE,TRUE);
      CASE Cmd OF
        'A' : ULDLRatio := NOT ULDLRatio;
        'B' : FileCreditRatio := NOT FileCreditRatio;
        'C' : DailyLimits := NOT DailyLimits;
        'D' : TestUploads := NOT TestUploads;
        'E' : RewardSystem := NOT RewardSystem;
        'F' : FileDiz := NOT FileDiz;
        'G' : Recompress := NOT Recompress;
        'H' : InputIntegerWOC('^0%LFNew percentage of file credits to reward',RewardRatio,[DisplayValue,NumbersOnly],0,100);
        'I' : InputByteWOC('^0%LFNew file point compensation ratio',FileCreditComp,[DisplayValue,Numbersonly],0,100);
        'J' : InputByteWOC('^0%LFNew area file size per 1 file Point',FileCreditCompBaseSize,[DisplayValue,NumbersOnly],0,255);
        'K' : InputByteWOC('^0%LFNew upload time refund percent',ULRefund,[DisplayValue,NumbersOnly],0,100);
        'L' : InputIntegerWOC('^0%LFNew "To-SysOp" file area (0=None)',ToSysOpDir,[DisplayValue,NumbersOnly],0,NumFileAreas);
        'M' : ValidateAllFiles := NOT ValidateAllFiles;
        'N' : InputLongIntWOC('^0%LFNew max k-bytes in temp dir',MaxInTemp,[DisplayValue,NumbersOnly],0,2097151);
        'O' : InputLongIntWOC('^0%LFNew min resume k-bytes',MinResume,[DisplayValue,NumbersOnly],0,2097151);
        'P' : InputByteWOC('^0%LFNew max batch download files',MaxBatchDLFiles,[DisplayValue,NumbersOnly],1,255);
        'R' : InputByteWOC('^0%LFNew max batch upload files',MaxBatchULFiles,[DisplayValue,NumbersOnly],1,255);
        'S' : SearchDup := NOT SearchDup;
        'T' : ForceBatchDL := NOT ForceBatchDL;
        'U' : ForceBatchUL := NOT ForceBatchUL;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.