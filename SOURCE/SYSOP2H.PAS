{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  Net/Echo Mail Configuration
}

UNIT SysOp2H;

INTERFACE

PROCEDURE NetworkConfiguration;

IMPLEMENTATION

USES
  Common,
  NodeList;

PROCEDURE NetworkConfiguration;
VAR
  Cmd: Char;
  Counter: Byte;
  Changed: Boolean;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
	  CLS;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Net/Echo Mail Configuration',80));
      PrintACR('^0(^1A^0) Net Addresses');
      PrintACR('^0(^1B^0) Origin Line : ^1'+Origin);
      NL;
      PrintACR('^0(^1C^0) Strip IFNA Kludge Lines : ^1'+PadLeftStr(ShowYesNo(SKludge),10)+
               '^0(^11^0) Color Of Standard Text  : ^'+IntToStr(Text_Color)+IntToStr(Text_Color));
      PrintACR('^0(^1D^0) Strip SEEN-BY Lines     : ^1'+PadLeftStr(ShowYesNo(SSeenBy),10)+
               '^0(^12^0) Color Of Quoted Text    : ^'+IntToStr(Quote_Color)+IntToStr(Quote_Color));
      PrintACR('^0(^1E^0) Strip Origin Lines      : ^1'+PadLeftStr(ShowYesNo(SOrigin),10)+
               '^0(^13^0) Color Of Tear Line      : ^'+IntToStr(Tear_Color)+IntToStr(Tear_Color));
      PrintACR('^0(^1F^0) Add Tear/Origin Line    : ^1'+PadLeftStr(ShowYesNo(AddTear),10)+
               '^0(^14^0) Color Of Origin Line    : ^'+IntToStr(Origin_Color)+IntToStr(Origin_Color));
      NL;
      PrintACR('^0(^1G^0) Default EchoMail Path   : ^1'+DefEchoPath);
      PrintACR('^0(^1H^0) NetMail Path            : ^1'+NetMailPath);
      PrintACR('^0(^1I^0) NetMail Attributes      : ^1'+NetMail_Attr(NetAttribute));
      PrintACR('^0(^1J^0) UUCP Gate Address       : ^1'+PadLeftStr('^1'+IntToStr(AKA[20].Zone)+'^0:^1'+IntToStr(AKA[20].Net)+
                                                       '^0/^1'+IntToStr(AKA[20].Node)+'^0.^1'+IntToStr(AKA[20].Point),20));
	  NL;
      Prt('^0Net/Echo Mail Configuration [^1A^0-^1J^0,^11^0-^14^0,(^1Q^0)uit]: ');
      OneK(Cmd,'QABCDEFGHIJ1234'^M,TRUE,TRUE);
      CASE Cmd OF
        'A' : BEGIN
                REPEAT
                  Abort := FALSE;
                  Next := FALSE;
				  CLS;
				  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Network Addresses',80));
                  FOR Counter := 0 TO 19 DO
                  BEGIN
                    Prompt('^0(^1'+Chr(Counter + 65)+'^0) Address #'+PadLeftInt(Counter,2)+' : '+
                    PadLeftStr('^1'+IntToStr(AKA[Counter].Zone)+
                        '^0:^1'+IntToStr(AKA[Counter].Net)+
                        '^0/^1'+IntToStr(AKA[Counter].Node)+
                        '^0.^1'+IntToStr(AKA[Counter].Point),20)+'^0');
                    IF (Odd(Counter)) THEN
                      NL;
                  END;
				  NL;
                  LOneK('^0Network Addresses [^1A^0-^1T^0,<^1CR^0>Quit]: ',Cmd,^M'ABCDEFGHIJKLMNOPQRST',TRUE,TRUE);
                  IF (Cmd IN ['A'..'T']) THEN
                    GetNewAddr('^0%LFNew Network Address ("^1Z^0:^1N^0/^1N^0.^1P^0" Format): ',30,
                                AKA[(Ord(Cmd) - 65)].Zone,
                                AKA[(Ord(Cmd) - 65)].Net,
                                AKA[(Ord(Cmd) - 65)].Node,
                                AKA[(Ord(Cmd) - 65)].Point);
                UNTIL (Cmd = ^M) OR (HangUp);
                Cmd := #0;
              END;
        'B' : InputWN1('^0%LFNew Origin Line: ',Origin,50,[interactiveedit],Changed);
        'C' : SKludge := NOT SKludge;
        'D' : SSeenBy := NOT SSeenBy;
        'E' : SOrigin := NOT SOrigin;
        'F' : AddTear := NOT AddTear;
        'G' : InputPath('^0%LFNew Default EchoMail Path: ',DefEchoPath,TRUE,FALSE,Changed);
        'H' : InputPath('^0%LFNew NetMail Path: ',NetMailPath,TRUE,FALSE,Changed);
        'I' : BEGIN
                REPEAT
                  Print('^0%LFNetmail Attributes: ^1'+NetMail_Attr(NetAttribute)+' ');
                  LOneK('^0%LFNetmail Attributes [^1CHIKLP^0,(^1?^0)Help,(^1Q^0)uit]: ',Cmd,'QPCKHIL?',TRUE,TRUE);
                  CASE Cmd OF
                    'C','H','I','K','L','P' :
                           ToggleNetAttrS(Cmd,NetAttribute);
                    '?' : BEGIN
                            NL;
                            LCmds3(22,1,'C Crash Mail','H Hold','I In-Transit');
                            LCmds3(22,1,'K Kill-Sent','L Local','P Private');
                          END;
                  END;

                UNTIL (Cmd = 'Q') OR (HangUp);

                Cmd := #0;
              END;
        'J' : GetNewAddr('^0%LFNew UUCP Gate Address ("^1Z^0:^1N^0/^1N^0.^1P^0" Format): ',30,
                         AKA[20].Zone,
                         AKA[20].Net,
                         AKA[20].Node,
                         AKA[20].Point);
        '1' : BEGIN
                Prompt('^0%LFColors: ');
                ShowColors;
				NL;
                InputByteWC('^0New Standard Text Color',Text_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '2' : BEGIN
                Prompt('^0%LFColors: ');
                ShowColors;
				NL;
                InputByteWC('^0New Quoted Text Color',Quote_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '3' : BEGIN
                Prompt('^0%LFColors: ');
                ShowColors;
				NL;
                InputByteWC('^0New Tear Line Color',Tear_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '4' : BEGIN
                Prompt('^0%LFColors: ');
                ShowColors;
				NL;
                InputByteWC('^0New Origin Line Color',Origin_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
