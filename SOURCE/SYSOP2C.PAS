{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2C;

INTERFACE

PROCEDURE SystemACSSettings;

IMPLEMENTATION

USES
  Common;

PROCEDURE SystemACSSettings;
VAR
  TempACS: ACString;
  Cmd: Char;
  Changed: Boolean;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      MCIAllowed := FALSE;
      CLS;
      PrintACR(PadLeftStr('|17|15 þ Renegade BBS Configuration : System AC Settings',80));
      {NL;}
      PrintACR('|07(|15A|07) Full SysOp       : |15'+PadLeftStr(SOp,17)+
               '|07(|15B|07) Full Co-SysOp    : |15'+CSOp);
      PrintACR('|07(|15C|07) Msg Area SysOp   : |15'+PadLeftStr(MSOp,17)+
               '|07(|15D|07) File Area SysOp  : |15'+FSOp);
      PrintACR('|07(|15E|07) Change A Vote    : |15'+PadLeftStr(ChangeVote,17)+
               '|07(|15F|07) Add Voting Choice: |15'+AddChoice);
      PrintACR('|07(|15G|07) Post public      : |15'+PadLeftStr(NormPubPost,17)+
               '|07(|15H|07) Send e-mail      : |15'+NormPrivPost);
      PrintACR('|07(|15I|07) See anon pub post: |15'+PadLeftStr(AnonPubRead,17)+
               '|07(|15J|07) See anon E-mail  : |15'+AnonPrivRead);
      PrintACR('|07(|15K|07) Global Anon post : |15'+PadLeftStr(AnonPubPost,17)+
               '|07(|15L|07) E-mail anon      : |15'+AnonPrivPost);
      PrintACR('|07(|15M|07) See unval. files : |15'+PadLeftStr(SeeUnVal,17)+
               '|07(|15N|07) DL unval. files  : |15'+DLUnVal);
      PrintACR('|07(|15O|07) No UL/DL ratio   : |15'+PadLeftStr(NoDLRatio,17)+
               '|07(|15P|07) No PostCall ratio: |15'+NoPostRatio);
      PrintACR('|07(|15R|07) No DL credits chk: |15'+PadLeftStr(NoFileCredits,17)+
               '|07(|15S|07) ULs Auto-Credited: |15'+ULValReq);
      PrintACR('|07(|15T|07) MCI In TeleConf  : |15'+PadLeftStr(TeleConfMCI,17)+
               '|07(|15U|07) Chat At Any Hour : |15'+OverRideChat);
      PrintACR('|07(|15V|07) Send Netmail     : |15'+PadLeftStr(NetMailACS,17)+
               '|07(|15W|07) "Invisible" Mode : |15'+Invisible);
      PrintACR('|07(|15X|07) Mail File Attach : |15'+PadLeftStr(FileAttachACS,17)+
               '|07(|15Y|07) SysOp PW At logon: |15'+SPW);
      PrintACR('|07(|15Z|07) Last On Add      : |15'+PadLeftStr(LastOnDatACS,17));
      MCIAllowed := TRUE;
      NL;
      Prt('|07Enter Selection or (|15Q|07)uit: |15');
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUVWXYZ',TRUE,TRUE);
      IF (Cmd IN ['A'..'P','R'..'Z']) THEN
      BEGIN
        CASE Cmd OF
          'A' : TempACS := SOp;
          'B' : TempACS := CSOp;
          'C' : TempACS := MSOp;
          'D' : TempACS := FSOp;
          'E' : TempACS := ChangeVote;
          'F' : TempACS := AddChoice;
          'G' : TempACS := NormPubPost;
          'H' : TempACS := NormPrivPost;
          'I' : TempACS := AnonPubRead;
          'J' : TempACS := AnonPrivRead;
          'K' : TempACS := AnonPubPost;
          'L' : TempACS := AnonPrivPost;
          'M' : TempACS := SeeUnVal;
          'N' : TempACS := DLUnVal;
          'O' : TempACS := NoDLRatio;
          'P' : TempACS := NoPostRatio;
          'R' : TempACS := NoFileCredits;
          'S' : TempACS := ULValReq;
          'T' : TempACS := TeleConfMCI;
          'U' : TempACS := OverRideChat;
          'V' : TempACS := NetMailACS;
          'W' : TempACS := Invisible;
          'X' : TempACS := FileAttachACS;
          'Y' : TempACS := SPW;
          'Z' : TempACS := LastOnDatACS;
        END;
        InputWN1('%LFNew ACS: ',TempACS,(SizeOf(ACString) - 1),[InterActiveEdit],Changed);
        CASE Cmd OF
          'A' : SOp := TempACS;
          'B' : CSOp := TempACS;
          'C' : MSOp := TempACS;
          'D' : FSOp := TempACS;
          'E' : ChangeVote := TempACS;
          'F' : AddChoice := TempACS;
          'G' : NormPubPost := TempACS;
          'H' : NormPrivPost := TempACS;
          'I' : AnonPubRead := TempACS;
          'J' : AnonPrivRead := TempACS;
          'K' : AnonPubPost := TempACS;
          'L' : AnonPrivPost := TempACS;
          'M' : SeeUnVal := TempACS;
          'N' : DLUnVal := TempACS;
          'O' : NoDLRatio := TempACS;
          'P' : NoPostRatio := TempACS;
          'R' : NoFileCredits := TempACS;
          'S' : ULValReq := TempACS;
          'T' : TeleConfMCI := TempACS;
          'U' : OverRideChat := TempACS;
          'V' : NetMailACS := TempACS;
          'W' : Invisible := TempACS;
          'X' : FileAttachACS := TempACS;
          'Y' : SPW := TempACS;
          'Z' : LastOnDatACS := TempACS;
        END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
