{$IFDEF WIN32}
{$I DEFINES.INC}
{$ENDIF}

{$A+,B-,D-,E-,F+,I-,L-,N-,O+,R-,S+,V-}

UNIT SysOp2;

INTERFACE

PROCEDURE SystemConfigurationEditor;

IMPLEMENTATION

USES
  Common,
  SysOp2A,
  SysOp2B,
  SysOp2C,
  SysOp2D,
  SysOp2E,
  SysOp2F,
  SysOp2G,
  SysOp2H,
  SysOp2I,
  SysOp2J,
  SysOp2K,
  SysOp2L,
  SysOp2M,
  SysOp2O,
  Maint;

   {
   1. RGSysCfgStr(0,FALSE)

      %CL^5System Configuration:^1

      ^1A. Main BBS Configuration                 B. Modem/Node Configuration
      ^1C. System ACS Settings                    D. System Variables
      ^1E. System Toggles                         F. File System Configuration
      ^1G. Subscription/Validation System         H. Network Configuration
      ^1I. Offline Mail Configuration             J. Color Configuration
      ^1K. Archive Configuration                  L. Credit System Configuration
      ^1M. New User Log-In Toggles

      ^11. Time allowed per %CD                  2. Max calls per day
      ^13. UL/DL # files ratio                    4. UL/DL K-bytes ratio
      ^15. Post/Call ratio                        6. Max downloads per day
      ^17. Max download kbytes per day            8. Update System Averages

      Enter selection [^5A^4-^5M^4,^51^4-^58^4,^5Q^4=^5Quit^4]: @

   }

PROCEDURE SystemConfigurationEditor;
VAR
  Cmd: Char;
BEGIN
  REPEAT
    SaveGeneral(TRUE);
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      {RGSysCfgStr(0,FALSE);}
          Cls;

          Print(PadLeftStr('|17|15 þ Renegade BBS Configuration',80));

PrintACR('|07(|15A|07) Main BBS Configuration                 |07(|15B|07) Modem/Node Configuration');
PrintACR('|07(|15C|07) System ACS Settings                    |07(|15D|07) System Variables');
PrintACR('|07(|15E|07) System Toggles                         |07(|15F|07) File System Configuration');
PrintACR('|07(|15G|07) Subscription/Validation System         |07(|15H|07) Network Configuration');
PrintACR('|07(|15I|07) Offline Mail Configuration             |07(|15J|07) Color Configuration');
PrintACR('|07(|15K|07) Archive Configuration                  |07(|15L|07) Credit System Configuration');
PrintACR('|07(|15M|07) New User Application Toggles');
Nl;
PrintACR('|07(|151|07) Time Allowed Per %CD                  |07(|152|07) Max Calls Per Day');
PrintACR('|07(|153|07) UL/DL # Files Ratio                    |07(|154|07) UL/DL Kbytes Ratio');
PrintACR('|07(|155|07) Post/Call Ratio                        |07(|156|07) Max Downloads Per Day');
PrintACR('|07(|157|07) Max Download Kbytes Per Day            |07(|158|07) Update System Averages');
Nl;
Prt('|07Enter Selection or (|15Q|07)uit: |15');
      OneK(Cmd,'QABCDEFGHIJKLM12345678',TRUE,TRUE);
      CASE Cmd OF
        'A' : MainBBSConfiguration;
        'B' : ModemConfiguration;
        'C' : SystemACSSettings;
        'D' : SystemGeneralVariables;
        'E' : SystemFlaggedFunctions;
        'F' : FileAreaConfiguration;
        'G' : ValidationEditor;
        'H' : NetworkConfiguration;
        'I' : OffLineMailConfiguration;
        'J' : ColorConfiguration;
        'K' : ArchiveConfiguration;
        'L' : CreditConfiguration;
        'M' : NewUserTogglesConfiguration;
        '1' : GetSecRange(1,TimeAllow);
        '2' : GetSecRange(2,CallAllow);
        '3' : GetSecRange(3,DLRatio);
        '4' : GetSecRange(4,DLKratio);
        '5' : GetSecRange(5,PostRatio);
        '6' : GetSecRange(6,DLOneDay);
        '7' : GetSecRange(7,DLKOneDay);
        '8' : UpdateGeneral;
      END;
    END;
    SaveGeneral(FALSE);
  UNTIL (Cmd = 'Q') OR (HangUp);
END;

END.
