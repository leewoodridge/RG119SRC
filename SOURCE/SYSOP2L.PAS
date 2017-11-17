
{ Lee Woodridge } { Credit System Configuration }

UNIT SysOp2L;

INTERFACE

PROCEDURE CreditConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE CreditConfiguration;
VAR
  Cmd: Char;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      CLS;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Credit System Configuration',80));
      PrintACR('^0(^1A^0) Charge Per Minute          : ^1'+IntToStr(CreditMinute));
      PrintACR('^0(^1B^0) Charge Per Message         : ^1'+IntToStr(CreditPost));
      PrintACR('^0(^1C^0) Charge Per E-Mail          : ^1'+IntToStr(CreditEmail));
      PrintACR('^0(^1D^0) Charge Per Internet E-Mail : ^1'+IntToStr(CreditInternetMail));
	  Nl;
	  PrintACR('^0(^1E^0) Free Time At Logon         : ^1'+IntToStr(CreditFreeTime));
	  Nl;
      Prt('^0Enter Selection Or (^1Q^0) To Quit: ^1');
      OneK(Cmd,'QABCDE',TRUE,TRUE);
      CASE Cmd OF
        'A' : InputIntegerWOC('%LF^0Credits To Charge Per Minute Online',CreditMinute,[NumbersOnly],0,32767);
        'B' : InputIntegerWOC('%LF^0Credits To Charge Per Message Post',CreditPost,[NumbersOnly],0,32767);
        'C' : InputIntegerWOC('%LF^0Credits To Charge Per E-Mail Sent',CreditEmail,[Numbersonly],0,32767);
		'D' : InputIntegerWOC('%LF^0Credits To Charge Per Internet E-Mail Sent',CreditInternetMail,[NumbersOnly],0,32767);
        'E' : InputIntegerWOC('%LF^0Minutes To Give Users W/O Credits At Logon',CreditFreeTime,[NumbersOnly],0,32767);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
