{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  Network Configuration
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
      Print('%CL^0Network Configuration:');
      NL;
      PrintACR('^1A^0> Net Addresses');
      PrintACR('^1B^0> Origin Line     : ^1'+Origin);
      NL;
      PrintACR('^1C^0> Strip IFNA Kludge Lines : ^1'+ShowYesNo(SKludge)+
               '          ^11^0> Color Of Standard Text : ^'+IntToStr(Text_Color)+IntToStr(Text_Color));
      PrintACR('^1D^0> Strip SEEN-BY Lines     : ^1'+ShowYesNo(SSeenBy)+
               '          ^12^0> Color Of Quoted Text   : ^'+IntToStr(Quote_Color)+IntToStr(Quote_Color));
      PrintACR('^1E^0> Strip Origin Lines      : ^1'+ShowYesNo(SOrigin)+
               '          ^13^0> Color Of Tear Line     : ^'+IntToStr(Tear_Color)+IntToStr(Tear_Color));
      PrintACR('^1F^0> Add Tear/Origin Line    : ^1'+ShowYesNo(AddTear)+
               '          ^14^0> Color Of Origin Line   : ^'+IntToStr(Origin_Color)+IntToStr(Origin_Color));
      NL;
      PrintACR('^1G^0> Default EchoMail Path   : ^1'+DefEchoPath);
      PrintACR('^1H^0> NetMail Path            : ^1'+NetMailPath);
      PrintACR('^1I^0> NetMail Attributes      : ^1'+NetMail_Attr(NetAttribute));
      PrintACR('^1J^0> UUCP Gate Address       : ^1'+PadLeftStr('^1'+IntToStr(AKA[20].Zone)+'^0:^1'+IntToStr(AKA[20].Net)+
                                                       '^0/^1'+IntToStr(AKA[20].Node)+'^0.^1'+IntToStr(AKA[20].Point),20));
      Prt('^0%LFNetwork Configuration: ');
      OneK(Cmd,'QABCDEFGHIJ1234'^M,TRUE,TRUE);
      CASE Cmd OF
        'A' : BEGIN
                REPEAT
                  Abort := FALSE;
                  Next := FALSE;
                  Print('%CL^5Network Addresses:^1');
                  NL;
                  FOR Counter := 0 TO 19 DO
                  BEGIN
                    Prompt('^1'+Chr(Counter + 65)+'. Address #'+PadLeftInt(Counter,2)+' : '+
                    PadLeftStr('^5'+IntToStr(AKA[Counter].Zone)+
                        ':'+IntToStr(AKA[Counter].Net)+
                        '/'+IntToStr(AKA[Counter].Node)+
                        '.'+IntToStr(AKA[Counter].Point),20));
                    IF (Odd(Counter)) THEN
                      NL;
                  END;
                  LOneK('%LFEnter selection [^5A^4-^5T^4,^5<CR>^4=^5Quit^4]: ',Cmd,^M'ABCDEFGHIJKLMNOPQRST',TRUE,TRUE);
                  IF (Cmd IN ['A'..'T']) THEN
                    GetNewAddr('%LFEnter new network address (^5Z^4:^5N^4/^5N^4.^5P^4 format): ',30,
                                AKA[(Ord(Cmd) - 65)].Zone,
                                AKA[(Ord(Cmd) - 65)].Net,
                                AKA[(Ord(Cmd) - 65)].Node,
                                AKA[(Ord(Cmd) - 65)].Point);
                UNTIL (Cmd = ^M) OR (HangUp);
                Cmd := #0;
              END;
        'B' : InputWN1('%LF^1Enter new origin line:%LF^4: ',Origin,50,[],Changed);
        'C' : SKludge := NOT SKludge;
        'D' : SSeenBy := NOT SSeenBy;
        'E' : SOrigin := NOT SOrigin;
        'F' : AddTear := NOT AddTear;
        'G' : InputPath('%LF^1Enter new default echomail path (^5End with a ^1"^5\^1"):%LF^4:',DefEchoPath,TRUE,FALSE,Changed);
        'H' : InputPath('%LF^1Enter new netmail path (^5End with a ^1"^5\^1"):%LF^4:',NetMailPath,TRUE,FALSE,Changed);
        'I' : BEGIN

                REPEAT
                  Print('%LF^1Netmail attributes: ^5'+NetMail_Attr(NetAttribute)+'^1');
                  LOneK('%LFToggle attributes (CHIKLP) [?]Help [Q]uit: ',Cmd,'QPCKHIL?',TRUE,TRUE);
                  CASE Cmd OF
                    'C','H','I','K','L','P' :
                           ToggleNetAttrS(Cmd,NetAttribute);
                    '?' : BEGIN
                            NL;
                            LCmds(22,3,'Crash mail','Hold');
                            LCmds(22,3,'In-Transit','Kill-Sent');
                            LCmds(22,3,'Local','Private');
                          END;
                  END;

                UNTIL (Cmd = 'Q') OR (HangUp);

                Cmd := #0;
              END;
        'J' : GetNewAddr('%LFEnter new UUCP Gate Address (^5Z^4:^5N^4/^5N^4.^5P^4 format): ',30,
                         AKA[20].Zone,
                         AKA[20].Net,
                         AKA[20].Node,
                         AKA[20].Point);
        '1' : BEGIN
                Prompt('%LF^5Colors: ');
                ShowColors;
                InputByteWC('%LFNew standard text color',Text_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '2' : BEGIN
                Prompt('%LF^5Colors: ');
                ShowColors;
                InputByteWC('%LFNew quoted text color',Quote_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '3' : BEGIN
                Prompt('%LF^5Colors: ');
                ShowColors;
                InputByteWC('%LFNew tear line color',Tear_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
        '4' : BEGIN
                Prompt('%LF^5Colors: ');
                ShowColors;
                InputByteWC('%LFNew origin line color',Origin_Color,[DisplayValue,NumbersOnly],0,9,Changed);
              END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
