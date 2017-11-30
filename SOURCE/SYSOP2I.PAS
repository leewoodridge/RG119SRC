{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2I;

INTERFACE

PROCEDURE OfflineMailConfiguration;

IMPLEMENTATION

USES
  Common;

PROCEDURE OfflineMailConfiguration;
VAR
  Cmd: CHAR;
  Changed: Boolean;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
	  CLS;
	  Print(PadLeftStr('^2 '#240' Renegade BBS Configuration : Offline Mail Configuration',80));
      {Print('^0%CLOffline Mail Configuration:');
      NL;}
      PrintACR('^0(^1A^0) QWK/REP Packet Name   : ^1'+PacketName);
      PrintACR('^0(^1B^0) Welcome Filename      : ^1'+QWKWelcome);
      PrintACR('^0(^1C^0) News Filename         : ^1'+QWKNews);
      PrintACR('^0(^1D^0) Goodbye Filename      : ^1'+QWKGoodbye);
      PrintACR('^0(^1E^0) Local QWK/REP Path    : ^1'+QWKLocalPath);
      PrintACR('^0(^1F^0) Ignore Time For DL?   : ^1'+ShowYesNo(QWKTimeIgnore));
      PrintACR('^0(^1G^0) Max Messages Total    : ^1'+IntToStr(MaxQWKTotal));
      PrintACR('^0(^1H^0) Max Messages Per Base : ^1'+IntToStr(MaxQWKBase));
      PrintACR('^0(^1I^0) ACS For Network .REP  : ^1'+QWKNetworkACS);
      Prt('^0%LFOffline Mail Configuration [^1A^0-^1I^0,(^1Q^0)uit]:');
      OneK(Cmd,'QABCDEFGHI'^M,TRUE,TRUE);
      CASE Cmd OF
        'A' : InputWN1('%LFQWK Packet name: ',PacketName,(SizeOf(PacketName) - 1),[InterActiveEdit],Changed);
        'B' : InputWN1('%LF^1Welcome screen file d:\path\name (^5Do not enter ^1"^5.EXT^1"):%LF^4: ',
                       QWKWelcome,(SizeOf(QWKWelcome) - 1),
                       [UpperOnly,InterActiveEdit],Changed);
        'C' : InputWN1('%LF^1News file d:\path\name (^5Do not enter ^1"^5.EXT^1"):%LF^4: ',QWKNews,(SizeOf(QWKNews) - 1),
                       [UpperOnly,InterActiveEdit],Changed);
        'D' : InputWN1('%LF^1Goodbye file d:\path\name (^5Do not enter ^1"^5.EXT^1"):%LF^4: ',
                       QWKGoodbye,(SizeOf(QWKGoodBye) - 1),
                       [UpperOnly,InterActiveEdit],Changed);
        'E' : InputPath('%LF^1Enter local QWK reader path (^5End with a ^1"^5\^1"):%LF^4:',QWKLocalPath,TRUE,FALSE,Changed);
        'F' : QWKTimeIgnore := NOT QWKTimeIgnore;
        'G' : InputWordWOC('%LFMaximum total messages in a QWK packet',MaxQWKTotal,[DisplayValue,NumbersOnly],0,65535);
        'H' : InputWordWOC('%LFMaximum messages per base in a packet',MaxQWKBase,[DisplayValue,NumbersOnly],0,65535);
        'I' : InputWN1('%LFNew ACS: ',QWKNetworkACS,(SizeOf(QWKNetworkACS) - 1),[InterActiveEdit],Changed);
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
