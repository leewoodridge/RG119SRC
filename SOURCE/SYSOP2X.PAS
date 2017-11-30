{$A+,B-,D+,E-,F+,I-,L+,N-,O+,R-,S+,V-}

{  ___   ____  _      ____  __     __    ___   ____      ___   ___   __  
  | |_) | |_  | |\ | | |_  / /`_  / /\  | | \ | |_      | |_) | |_) ( (`
  |_| \ |_|__ |_| \| |_|__ \_\_/ /_/--\ |_|_/ |_|__     |_|_) |_|_) _)_)

  LIGHTBAR TEST MENU

}

UNIT SysOp2X;

INTERFACE

PROCEDURE TestMenu;

IMPLEMENTATION

USES
  Common,
  CRT;

  procedure donothing;
  begin
  end;
  
  
PROCEDURE TestMenu;
VAR
  Cmd: Char;
  Key: Word;
  ExtChar: boolean;
  c: char;
BEGIN
  REPEAT
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
      CLS;
	  PrintACR(PadLeftStr('^2 '#240' Renegade BBS Configuration : Multi-Page Menu Test',80));
      {NL;}
      PrintACR('^0(^1A^0) File Ratio System           : ^1'+ShowOnOff(ULDLRatio));
      PrintACR('^0(^1B^0) File Point System           : ^1'+ShowOnOff(FileCreditRatio));
	  NL;
      Prt('^0File System Configuration: ');
	  (*
	  if getkey = 18688 then pausescr(false)
	  else if getkey = 20736 then pausescr(false)
	  else donothing;
	  *)
      OneK(Cmd,'QABCDEFGHIJKLMNOPRSTUV',TRUE,TRUE);
	  {Key := GetKey;}
      CASE Cmd OF
	    {#0 : begin
				ExtChar := Cmd=#0; 
      if ExtChar then begin 
		  key := GetKey; 
		  print(inttostr(ord(key)));
				pausescr(false);
				end;
				
		end;}
        'A' : ULDLRatio := NOT ULDLRatio;
        'B' : FileCreditRatio := NOT FileCreditRatio;
        'C' : DailyLimits := NOT DailyLimits;
		(*^R{PGUP} : PauseScr(FALSE);
		^C{PGDN} : PauseScr(FALSE);
		^E : PauseScr(FALSE);*)
		else BEGIN
					print('gheto! '+Cmd);
					pausescr(false);
				END;
      END;
    END;
  UNTIL (Cmd = 'Q') OR (HangUp);
END;
END.