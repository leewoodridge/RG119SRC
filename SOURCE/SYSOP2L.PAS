
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
	  PrintACR(PadLeftStr('|17|15 _ Renegade BBS Configuration : Credit System Configuration',80));
      PrintACR('|07(|15A|07) Charge Per Minute          : |15'+IntToStr(CreditMinute));
      PrintACR('|07(|15B|07) Charge Per Message         : |15'+IntToStr(CreditPost));
      PrintACR('|07(|15C|07) Charge Per E-Mail          : |15'+IntToStr(CreditEmail));
      PrintACR('|07(|15D|07) Charge Per Internet E-Mail : |15'+IntToStr(CreditInternetMail));
	  Nl;
	  PrintACR('|07(|15E|07) Free Time At Logon         : |15'+IntToStr(CreditFreeTime));
	  Nl;
      Prt('|07Enter Selection Or (|15Q|07) To Quit: |15');
      OneK(Cmd,'QABCDE',TRUE,TRUE);
      CASE Cmd OF
        'A' : InputIntegerWOC('%LF|07Credits To Charge Per Minute Online',CreditMinute,[NumbersOnly],0,32767);
        'B' : InputIntegerWOC('%LF|07Credits To Charge Per Message Post',CreditPost,[NumbersOnly],0,32767);
        'C' : InputIntegerWOC('%LF|07Credits To Charge Per E-Mail Sent',CreditEmail,[Numbersonly],0,32767);
		'D' : InputIntegerWOC('%LF|07Credits To Charge Per Internet E-Mail Sent',CreditInternetMail,[NumbersOnly],0,32767);
        'E' : InputIntegerWOC('%LF|07Minutes To Give Users W/O Credits At Logon',CreditFreeTime,[NumbersOnly],0,32767);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
