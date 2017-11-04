{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  System ACS Settings
  
  -control length of strings on right so they dont mess up display
}

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
      PrintACR(PadLeftStr('|17^1 þ Renegade BBS Configuration : System AC Settings',80));
      {NL;}
      PrintACR('^0(^1A^0) Full SysOp            : ^1'+PadLeftStr(SOp,13)+
               '^0(^1B^0) Full Co-SysOp         : ^1'+CSOp);
      PrintACR('^0(^1C^0) Msg Area SysOp        : ^1'+PadLeftStr(MSOp,13)+
               '^0(^1D^0) File Area SysOp       : ^1'+FSOp);
      PrintACR('^0(^1E^0) Change A Vote         : ^1'+PadLeftStr(ChangeVote,13)+
               '^0(^1F^0) Add Voting Choice     : ^1'+AddChoice);
      PrintACR('^0(^1G^0) Post Public           : ^1'+PadLeftStr(NormPubPost,13)+
               '^0(^1H^0) Post Private          : ^1'+NormPrivPost);
      PrintACR('^0(^1I^0) See Anon Pub Post     : ^1'+PadLeftStr(AnonPubRead,13)+
               '^0(^1J^0) See Anon E-Mail       : ^1'+AnonPrivRead);
      PrintACR('^0(^1K^0) Post Public Anon      : ^1'+PadLeftStr(AnonPubPost,13)+
               '^0(^1L^0) Post Private Anon     : ^1'+AnonPrivPost);
      PrintACR('^0(^1M^0) See Unvalidated Files : ^1'+PadLeftStr(SeeUnVal,13)+
               '^0(^1N^0) DL Unvalidated Files  : ^1'+DLUnVal);
      PrintACR('^0(^1O^0) No UL/DL Ratio        : ^1'+PadLeftStr(NoDLRatio,13)+
               '^0(^1P^0) No Post/Call Ratio    : ^1'+NoPostRatio);
      PrintACR('^0(^1R^0) No DL Credits Chk     : ^1'+PadLeftStr(NoFileCredits,13)+
               '^0(^1S^0) ULs Auto-Credited     : ^1'+ULValReq);
      PrintACR('^0(^1T^0) MCI In TeleConf       : ^1'+PadLeftStr(TeleConfMCI,13)+
               '^0(^1U^0) Chat At Any Hour      : ^1'+OverRideChat);
      PrintACR('^0(^1V^0) Send NetMail          : ^1'+PadLeftStr(NetMailACS,13)+
               '^0(^1W^0) "Invisible" Mode      : ^1'+Invisible);
      PrintACR('^0(^1X^0) Mail File Attach      : ^1'+PadLeftStr(FileAttachACS,13)+
               '^0(^1Y^0) SysOp PW At logon     : ^1'+SPW);
      PrintACR('^0(^1Z^0) Last On Add           : ^1'+PadLeftStr(LastOnDatACS,13));
      MCIAllowed := TRUE;
      NL;
      Prt('^0Enter Selection or (^1Q^0)uit: ^1');
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
