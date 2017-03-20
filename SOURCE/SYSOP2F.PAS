{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

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
      PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : File System Configuration',80));
      {NL;}
      PrintACR('|07(|15A|07) Upload/Download Ratio System    : |15'+ShowOnOff(ULDLRatio));
      PrintACR('|07(|15B|07) File Point System               : |15'+ShowOnOff(FileCreditRatio));
      PrintACR('|07(|15C|07) Daily Download Limits           : |15'+ShowOnOff(DailyLimits));
      PrintACR('|07(|15D|07) Test And Convert Uploads        : |15'+ShowOnOff(TestUploads));
      PrintACR('|07(|15E|07) File Point Rewarding System     : |15'+ShowOnOff(RewardSystem));
      PrintACR('|07(|15F|07) Search For/Use FILE_ID.DIZ      : |15'+ShowOnOff(FileDiz));
      PrintACR('|07(|15G|07) Recompress Like Archives        : |15'+ShowOnOff(Recompress));
      PrintACR('|07(|15H|07) Credit Reward Compensation Ratio: |15'+IntToStr(RewardRatio)+'%');
      PrintACR('|07(|15I|07) File Point Compensation Ratio   : |15'+IntToStr(FileCreditComp)+' to 1');
      PrintACR('|07(|15J|07) Area File Size Per 1 File Point : |15'+IntToStr(FileCreditCompBaseSize)+'k');
      PrintACR('|07(|15K|07) Upload Time Refund Percent      : |15'+IntToStr(ULRefund)+'%');
      PrintACR('|07(|15L|07) "To SysOp" File Area            : |15'+AOnOff(ToSysOpDir = 0,'*None*',IntToStr(ToSysOpDir)));
      PrintACR('|07(|15M|07) Auto-Validate All Files         : |15'+ShowYesNo(ValidateAllFiles));
      PrintACR('|07(|15N|07) Max KBytes Allowed In Temp Dir : |15'+IntToStr(MaxInTemp));
      PrintACR('|07(|15O|07) Min KBytes To Save For Resume  : |15'+IntToStr(MinResume));
      PrintACR('|07(|15P|07) Max Batch Download Files        : |15'+IntToStr(MaxBatchDLFiles));
      PrintACR('|07(|15R|07) Max Batch Upload Files          : |15'+IntToStr(MaxBatchUlFiles));
      PrintACR('|07(|15S|07) UL Duplicate File Search        : |15'+ShowOnOff(SearchDup));
      PrintACR('|07(|15T|07) Force Batch Download At Login   : |15'+ShowOnOff(ForceBatchDL));
      PrintACR('|07(|15U|07) Force Batch Upload At Login     : |15'+ShowOnOff(ForceBatchUL));
      NL;
      Prt('|07Enter Selection Or (|15Q|07) To Quit: |15');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTU',TRUE,TRUE);
      CASE Cmd OF
        'A' : ULDLRatio := NOT ULDLRatio;
        'B' : FileCreditRatio := NOT FileCreditRatio;
        'C' : DailyLimits := NOT DailyLimits;
        'D' : TestUploads := NOT TestUploads;
        'E' : RewardSystem := NOT RewardSystem;
        'F' : FileDiz := NOT FileDiz;
        'G' : Recompress := NOT Recompress;
        'H' : InputIntegerWOC('%LFNew percentage of file credits to reward',RewardRatio,[DisplayValue,NumbersOnly],0,100);
        'I' : InputByteWOC('%LFNew file point compensation ratio',FileCreditComp,[DisplayValue,Numbersonly],0,100);
        'J' : InputByteWOC('%LFNew area file size per 1 file Point',FileCreditCompBaseSize,[DisplayValue,NumbersOnly],0,255);
        'K' : InputByteWOC('%LFNew upload time refund percent',ULRefund,[DisplayValue,NumbersOnly],0,100);
        'L' : InputIntegerWOC('%LFNew "To-SysOp" file area (0=None)',ToSysOpDir,[DisplayValue,NumbersOnly],0,NumFileAreas);
        'M' : ValidateAllFiles := NOT ValidateAllFiles;
        'N' : InputLongIntWOC('%LFNew max k-bytes',MaxInTemp,[DisplayValue,NumbersOnly],0,2097151);
        'O' : InputLongIntWOC('%LFNew min resume k-bytes',MinResume,[DisplayValue,NumbersOnly],0,2097151);
        'P' : InputByteWOC('%LFNew max batch download files',MaxBatchDLFiles,[DisplayValue,NumbersOnly],1,255);
        'R' : InputByteWOC('%LFNew max batch upload files',MaxBatchULFiles,[DisplayValue,NumbersOnly],1,255);
        'S' : SearchDup := NOT SearchDup;
        'T' : ForceBatchDL := NOT ForceBatchDL;
        'U' : ForceBatchUL := NOT ForceBatchUL;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
