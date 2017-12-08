{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  -------------------------
  FILE SYSTEM CONFIGURATION
  -------------------------
}
  
(* add compress numbers*)

UNIT SysOp2F;

INTERFACE

PROCEDURE FileSystemConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE FileSystemConfiguration;
  VAR
	Cmd: Char;
	MinInt,
	MaxInt,
	TempI: Integer;
  BEGIN
	REPEAT
	  WITH General DO
		BEGIN
		  Abort := FALSE;
		  Next := FALSE;
		  CLS;
		  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : File System Configuration',80));
		  PrintACR('^0(^1A^0) File Ratio System        : ^1'+PadLeftStr(ShowOnOff(ULDLRatio),8)+
				   '^0(^1M^0) Auto-Validate All Files  : ^1'+PadLeftStr(ShowYesNo(ValidateAllFiles),8));
		  PrintACR('^0(^1B^0) File Point System        : ^1'+PadLeftStr(ShowOnOff(FileCreditRatio),8)+
				   '^0(^1N^0) Max KBytes In Temp Dir   : ^1'+PadLeftStr(IntToStr(MaxInTemp)+'^0 KB',9));
		  PrintACR('^0(^1E^0) File Point Reward System : ^1'+PadLeftStr(ShowOnOff(RewardSystem),8)+
				   '^0(^1O^0) Min KBytes For Resume    : ^1'+PadLeftStr(IntToStr(MinResume)+'^0 KB',8));
		  PrintACR('^0(^1C^0) Daily DL Limits          : ^1'+PadLeftStr(ShowOnOff(DailyLimits),8)+
				   '^0(^1P^0) Max Batch DL Files       : ^1'+PadLeftStr(IntToStr(MaxBatchDLFiles),8));
		  PrintACR('^0(^1D^0) Test/Convert Uploads     : ^1'+PadLeftStr(ShowOnOff(TestUploads),8)+
				   '^0(^1R^0) Max Batch UL Files       : ^1'+PadLeftStr(IntToStr(MaxBatchUlFiles),8));
		  PrintACR('^0(^1F^0) Use FILE_ID.DIZ          : ^1'+PadLeftStr(ShowOnOff(FileDiz),8)+
				   '^0(^1S^0) UL Duplicate File Search : ^1'+PadLeftStr(ShowOnOff(SearchDup),8));
		  PrintACR('^0(^1G^0) Recompress Like Archives : ^1'+PadLeftStr(ShowOnOff(Recompress),8)+
				   '^0(^1T^0) Force Batch DL At Login  : ^1'+PadLeftStr(ShowOnOff(ForceBatchDL),8));
		  PrintACR('^0(^1H^0) Credit Reward Ratio      : ^1'+PadLeftStr(IntToStr(RewardRatio)+'^0%',8)+
				   '^0(^1U^0) Force Batch UL At Login  : ^1'+PadLeftStr(ShowOnOff(ForceBatchUL),8));
		  PrintACR('^0(^1I^0) File Point Ratio         : ^1'+PadLeftStr(IntToStr(FileCreditComp)+'^0:^11',8)+
				   '^0(^1V^0) Min Free Space For ULs   : ^1'+PadLeftStr(PadLeftStr(IntToStr(MinSpaceForUpload)+'^0 KB',14),8));
		  PrintACR('^0(^1J^0) Size Per 1 File Point    : ^1'+PadLeftStr(IntToStr(FileCreditCompBaseSize)+'^0 KB',8)+
				   '^0(^1W^0) Compress Base Numbers    : ^1'+PadLeftStr(ShowOnOff(CompressBases),8));
		  PrintACR('^0(^1K^0) Upload Time Refund       : ^1'+PadLeftStr(IntToStr(ULRefund)+'^0%',8)+
				   '');
		  PrintACR('^0(^1L^0) "To SysOp" File Area     : ^1'+PadLeftStr(AOnOff(ToSysOpDir = 0,'None',IntToStr(ToSysOpDir)),8)+
				   '');
		  NL;
		  Prt('^0File System Configuration [^1A^0-^1W^0,(^1Q^0)uit]: ');
		  OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVW',TRUE,TRUE);
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
			'L' : InputIntegerWOC('^0%LFNew "To SysOp" file area (0=None)',ToSysOpDir,[DisplayValue,NumbersOnly],0,NumFileAreas);
			'M' : ValidateAllFiles := NOT ValidateAllFiles;
			'N' : InputLongIntWOC('^0%LFNew max k-bytes in temp dir',MaxInTemp,[DisplayValue,NumbersOnly],0,2097151);
			'O' : InputLongIntWOC('^0%LFNew min resume k-bytes',MinResume,[DisplayValue,NumbersOnly],0,2097151);
			'P' : InputByteWOC('^0%LFNew max batch download files',MaxBatchDLFiles,[DisplayValue,NumbersOnly],1,255);
			'R' : InputByteWOC('^0%LFNew max batch upload files',MaxBatchULFiles,[DisplayValue,NumbersOnly],1,255);
			'S' : SearchDup := NOT SearchDup;
			'T' : ForceBatchDL := NOT ForceBatchDL;
			'U' : ForceBatchUL := NOT ForceBatchUL;
			'V' : BEGIN
					MinInt := 1;
					MaxInt := 32767;
					TempI := MinSpaceForUpload;
					InputIntegerWOC('^0%LFNew Value',TempI,[NumbersOnly],MinInt,MaxInt);
					MinSpaceForUpload := TempI;
				  END;
			'W' : BEGIN
					CompressBases := NOT CompressBases;
					IF (CompressBases) THEN
					  Print('^0%LFCompressing File & Message Areas ...')
					ELSE
					  Print('^0%LFDe-Compressing File & Message Areas ...');
					NewCompTables;
					PauseScr(FALSE);
				  END;
		  END;
	  END;
	UNTIL (Cmd = 'Q') OR (HangUp);
  END;
END.
{ LeeW: Indenting Done! }