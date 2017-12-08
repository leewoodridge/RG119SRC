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
  
PROCEDURE TestMenu;

VAR
  Key: Word; {keyboard input}
{FOR menu}
  CmdList : ARRAY [1..29] OF STRING; {menu options}
  X,
  Y,
  CmdCounter,
{FOR PRINTCMDS}
  X2,		{temp x pos}
  Y2,		{temp y pos}
  CountB,	{temp counter}
{FOR DRAWBOX}
  CounterY,
  CounterX,
  Height,		{height of box}
  Width: Byte;	{width of box}
  
  PROCEDURE DrawBox; {WORKS!}
	BEGIN
	  CounterY := Y;
	  CounterX := X;
	  Height := 9;
	  Width := 24;
	  GoToXY(X-1,Y-1);
	  Prt('^4'+#218); {topleft corner}
	  WHILE CounterX < X+Width-2 DO
	    BEGIN
		  Prt('^4'+#196); {top}
		  Inc(CounterX);
		END;
	  Prt('^4'+#191); {topright corner}
	  WHILE CounterY < Y+Height-2 DO
		BEGIN
		  GoToXY(X-1,CounterY);
		  Print('^4'+#179); {leftside}
		  GoToXY(X-1+Width-1,CounterY);
		  Print('^4'+#179); {rightside}
		  Inc(CounterY);
		END;
	  GoToXY(X-1,Y+Height-2);
	  Prt('^4'+#192); {bottomleft corner}
	  CounterX := X;
	  WHILE CounterX < X+Width-2 DO
	    BEGIN
		  Prt('^4'+#196); {bottom}
		  Inc(CounterX);
		END;
	  Prt('^4'+#217); {bottomright corner}

	  GoToXY(X-1,Y+1);
	  Prt(#030); {uparrow}
	  GoToXY(X-1,Y+Height-4);
	  Prt(#031); {downarrow}
	END;
	
  PROCEDURE PrintCmds; {good}
	BEGIN
	  X2 := 10;
	  Y2 := 5;
	  CountB := CmdCounter;
	  WHILE (CountB <= CmdCounter+4) DO
	    BEGIN
		  GoToXY(X2,Y2);
		  Print(PadLeftStr('|07'+CmdList[CountB],20));
		  Inc(CountB);
		  Inc(Y2);
	    END;
	  CountB := 1;
	END;
  
BEGIN
	CmdList[01] := 'System Configuration';
	CmdList[02] := '-';
	CmdList[03] := 'User Editor';
	CmdList[04] := 'Menu Editor';
	CmdList[05] := 'Event Editor';
	CmdList[06] := 'Validation Editor';
	CmdList[07] := 'File Base Editor';
	CmdList[08] := 'Message Base Editor';
	CmdList[09] := 'Conference Editor';
	CmdList[10] := 'Protocol Editor';
	CmdList[11] := 'Archiver Editor';
	CmdList[12] := 'Voting Editor';
	CmdList[13] := '-';
	CmdList[14] := 'Write Mail';
	CmdList[15] := 'Callers';
	CmdList[16] := 'Pack Messages';
	CmdList[17] := 'Mail Read';
	CmdList[18] := 'Read Mail';
	CmdList[19] := 'Log On';
	CmdList[20] := 'Init Modem';
	CmdList[21] := 'Offhook Modem';
	CmdList[22] := 'Answer Modem';
	CmdList[23] := 'Hangup Modem';
	CmdList[24] := 'Node Listing';
	CmdList[25] := 'Validate Things';
	CmdList[26] := 'SysOp Log';
	CmdList[27] := 'History Log';
	CmdList[28] := 'Drop To DOS';
	CmdList[29] := 'Quit';
	
	{X = column Y=line}
	
	CLS;
	CmdCounter := 1;
	X := 10;
	Y := 5;
	DrawBox;
	GoToXY(X,Y);
	PrintCmds;
	X := 10;
	Y := 5;
	GoToXY(X,Y);
	Print('|15'+CmdList[CmdCounter]); {indicate first item selected}
  REPEAT
  
    WITH General DO
    BEGIN
      Abort := FALSE;
      Next := FALSE;
	  {Prt('^0File System Configuration: ');}
Key := GetKey;
    CASE Key OF
	 F_UP : IF Low(CmdList) <> CmdCounter THEN BEGIN
			if (y <= 5) then
			begin
			dec(cmdcounter,1);
			printcmds;
			gotoxy(x,y);
			print('|15'+cmdlist[cmdcounter]);			
			end
else
			begin
			gotoxy(x,y);
			print('|07'+cmdlist[cmdcounter]);
			dec(y);
			GoToXY(x,y);
			dec(CmdCounter);
			print('|15'+cmdlist[cmdcounter]);
				end;
				{gotoxy(20,20);
				print('cmdcounter:'+inttostr(cmdcounter)+'...cmdcounterb:'+inttostr(cmdcounterb)+
				'...y:'+Inttostr(y)+'...countb:'+inttostr(countb));}
	       END;
	 F_DOWN : IF High(CmdList) <> CmdCounter THEN BEGIN {}
			if (y = 9) then
			begin
			dec(cmdcounter,3);
			printcmds;
			inc(cmdcounter,4);
			gotoxy(x,y);
			print('|15'+cmdlist[cmdcounter]);
			end
else
			begin
			gotoxy(x,y);
			print('|07'+cmdlist[cmdcounter]);
			inc(y);
			GoToXY(x,y);
			Inc(CmdCounter);
(*			IF CmdList[CmdCounter] = '-' THEN { skip spacer items NOT QUITE WORKING, dwn but not up}
			  BEGIN
			    Inc(Y);
				Inc(CmdCounter);
				GoToXY(X,Y);
END;*)
			print('|15'+cmdlist[cmdcounter]);
				end;
				{gotoxy(20,20);
				print('cmdcounter:'+inttostr(cmdcounter)+'...cmdcounterb:'+inttostr(cmdcounterb)+
				'...y:'+Inttostr(y)+'...countb:'+inttostr(countb));}
	       END;
      13 : BEGIN { ENTER }
			 GoToXY(0,20); {move out of the way}
             CASE CmdCounter OF
			   01 : PauseScr(FALSE);
			   02 : PauseScr(FALSE);
			   03 : PauseScr(FALSE);
			   04 : PauseScr(FALSE);
			   05 : PauseScr(FALSE);
			   06 : PauseScr(FALSE);
			   07 : PauseScr(FALSE);
			   08 : PauseScr(FALSE);
			   09 : PauseScr(FALSE);
			   10 : PauseScr(FALSE);
			   11 : PauseScr(FALSE);
			   12 : PauseScr(FALSE);
			   13 : PauseScr(FALSE);
			   14 : PauseScr(FALSE);
			   15 : PauseScr(FALSE);
			   16 : PauseScr(FALSE);
			   17 : PauseScr(FALSE);
			   18 : PauseScr(FALSE);
			   19 : PauseScr(FALSE);
			   20 : PauseScr(FALSE);
			   21 : PauseScr(FALSE);
			   22 : PauseScr(FALSE);
			   23 : PauseScr(FALSE);
			   24 : PauseScr(FALSE);
			   25 : PauseScr(FALSE);
			   26 : PauseScr(FALSE);
			   27 : PauseScr(FALSE);
			   28 : PauseScr(FALSE);
			   29 : PauseScr(FALSE);
			   30 : PauseScr(FALSE);
			   31 : PauseScr(FALSE);
			   32 : PauseScr(FALSE);
			 END;
		   END;
	  END;
    END;
  UNTIL (KEY = 27) OR (HangUp);
END;
END.