{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)
  --------------
  LOGIN SEQUENCE 
  --------------
  
  TO-DO:
	cfg what sl can log on from shuttle mnu
  (* LeeW: Maybe "force batch ul/dl" should be with logon secq *)
  }

  
  
UNIT SysOp2P;

INTERFACE

PROCEDURE MessageSystemConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE MessageSystemConfiguration;
VAR
  Cmd: Char;
  MinByte,
  MaxByte,
  TempB: Byte;
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
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Message System Configuration',80));
	  PrintACR('^0(^1C^0) Max Public Posts   : ^1'+PadLeftStr(AOnOff((MaxPubPost = 0),'Unlimited',
															IntToStr(MaxPubPost)+'^0 Per Day'),14));
	  PrintACR('^0(^1A^0) Max Private Msgs   : ^1'+PadLeftStr(IntToStr(MaxPrivPost)+'^0 Per Day',14));
	  PrintACR('^0(^1B^0) Max Feedback       : ^1'+PadLeftStr(IntToStr(MaxFBack)+'^0 Per Day',14));
	  PrintACR('^0(^1E^0) Max Mail Waiting   : ^1'+PadLeftInt(MaxWaiting,14));
	  PrintACR('^0(^1G^0) Max Mass Mail List : ^1'+PadLeftStr(IntToStr(MaxMassMailList)+'^0 Users',14));
	  PrintACR('^0(^1@^0) Min Free Space For Posts  : ^1'+PadLeftStr(IntToStr(MinSpaceForPost)+'^0 KB',14));
	  PrintACR('^0(^1M^0) Compress M&F Area Numbers : ^1'+PadLeftStr(ShowOnOff(CompressBases),7));
      NL;
      Prt('^0Message System Configuration [^1A^0-^1Z^0,(^1Q^0)uit]: ');
      OneK(Cmd,'QM',TRUE,TRUE);
      CASE Cmd OF
	  			'@' : BEGIN
					MinInt := 1;
					MaxInt := 32767;
					TempI := MinSpaceForPost;
					InputIntegerWOC('^0%LFNew Value',TempI,[NumbersOnly],MinInt,MaxInt);
					MinSpaceForPost := TempI;
				  END;
		'M' : BEGIN
				CompressBases := NOT CompressBases;
				IF (CompressBases) THEN
				  Print('^0%LFCompressing Message & File Areas ...')
				ELSE
				  Print('^0%LFDe-Compressing Message & File Areas ...');
				NewCompTables;
				PauseScr(FALSE);
			  END;
			      'A' : BEGIN
					      MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPrivPost;
						  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
						  MaxPrivPost := TempB;
                        END;
                  'B' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxFBack;
						  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
						  MaxFBack := TempB;
                        END;
                  'C' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxPubPost;
						  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
						  MaxPubPost := TempB;
                        END;
                  'E' : BEGIN
                          MinByte := 0;
                          MaxByte := 255;
                          TempB := MaxWaiting;
						  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
						  MaxWaiting := TempB;
                        END;
                  'G' : BEGIN
                          MinByte := 2;
                          MaxByte := 255;
                          TempB := MaxMassMailList;
						  InputByteWOC('^0%LFNew Value',TempB,[NumbersOnly],MinByte,MaxByte);
						  MaxMassMailList := TempB;
                        END;

      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.