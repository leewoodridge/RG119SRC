Updates
=======

- MCI %EC inserts ANSI escape character
- MCI %BT for telnet URL
- Menu Command “O3” for checking validation status from shuttle logon menu
- Added “Other/Non-Binary” gender option
- Added help (“Renegade /?”) for command-line parameters 
- Fixed new user application question toggles, they now work, and there's a sys config menu to toggle them
- Aesthetic redesign of system configuration menus (incomplete)
- Added date of AUTO.ASC to automessage title (“Automessage posted by USERNAME on MM/DD/YYYY”)
- Copyright banner displays current year, also condensed it to 2 lines
- Added "Your account has been validated" string to RgMain string file
- AutoMessage header (AUTOH.*) and footer (AUTOT.*)
- SysOp can toggle if unvalidated users can log in through shuttle menu or not
- Fixed error where after applying through shuttle menu, it would return you to the menu but not exec firstcmd
- Trying to page/message your own node now returns error message
- Standardizing default headers – work in progress
- Voting editor now displays the 2nd line of answer
- combined file area and message area lightbars into single toggle, either you're using them or not
- Added: PDToTime to return “1:00 PM”-formatted-date from packeddate, used in today's callers
- Fixed date entry error in history editor – now you can use  it
- Show  fallback menu name in addition to the number in menu editor
- Put flags and sflags in their proper places. Most new flags should go in flags NOT sflags
- Revamped records editor menus in user editor, added more fields
- Missing directories during init now allows you to create the dir rather than just showing error
- toggling multinode on/off now prompts user to continue instead of just exiting immediately
- combined warning time and timeout time in to one option
- combined sysop and user chat colors in to one option
- simplify configuration options
- Max logon attempts: minimum is now 1, since 0 was equal to 1 anyway
- Combined min baud and hrs
- Combined min dl baud and hrs
- Re-arranging menu options... WIP...
- Combined swap shell toggle and location setting
- Fixing indents
- Added toggles to show Voting, LastCallers, and OneLiners during logon, rather than having them in start menu since they're pretty standard
- Voting prompt during logon about unanswered questions now gives you the option to vote on them now
- Added user 'Country' field
- Country is selected from list of COUNTRY.TXT file
- User editor redesign
- Added Function: 'NewYN('Question String',TRUE OR FALSE FOR DEFAULT ANSWER);'. Prompt for yes/no questions, lightbar, arrowkey+y/n support and strings are in rglng
- user editor : Added option to clear all fields (including country)
- user editor : Added medium list mode
- MCI: Added %CO for Country
- Removed extra linefeed from top of generic menus
- Most new user question strings are now in the lang file
- QWK settings no longer part of new user questions
- Fixed inconsistent pausing when changing user settings
- New User App: Won't prompt on color scheme if theres only 1
- New User App: color scheme prompt no longer adding extra linefeed
- New User App: color scheme prompt skips if term emu doesn't support color
- new user app: input validation for prompts
- new user app: address input validation checks for 1 letter, 1 number, and 1 space
- new user app: screen size and color scheme prompt to use default on invalid input
- InputByte, InputInteger - if input is invalid, returns 1 less than minimum unless minimum is 0
- new user app questions have 5-try limit now before disconnect
- change password can now be aborted

Renegade v1.19
==============

This is a fork of the official v1.19 release, which can be found here: https://github.com/Renegade-Exodus/RG119SRC<br />

Copyright Cott Lang, Patrick Spence, Gary Hall, Jeff Herrings, T.J. McMillen, Chris Hoppman, and Lee Palmer<br />
Ported to Win32 by Rick Parrish<br />

<hr />

TODO list:<br />
<ul>
  <li>Find/correct any usage of FOR loop variables after the loop (since they are 1 greater in VP than in BP</li>
  <li>Find/correct any file i/o on untyped files where Words or Integers are being read</li>
</ul>

Completed list<br />
<ul>
  <li>IFDEF out anything that doesn't compile and make a WIN32 placeholder that does a "WriteLn('REETODO UNIT FUNCTION'); Halt;" (then you can grep the executables for REETODO to see which REETODOs actually need to be implemented)</li>
  <li>IFDEF out any ASM code blocks and handle the same as above</li>
  <li>TYPEs of OF WORD to OF SMALLWORD (just in case they're used in a RECORD)</li>
  <li>TYPEs of OF INTEGER to OF SMALLINT (just in case they're used in a RECORD)</li>
  <li>WORD in RECORD to SMALLWORD</li>
  <li>INTEGER in RECORD to SMALLINT</li>
  <li>Anything passing 0 for the Attr parameter to FindFirst should pass AnyFile instead (VP returns no files when 0 is passed for Attr)</li>
  <li>Investigate FILEMODE usage to see if FILEMODEREADWRITE, TEXTMODEREAD or TEXTMODEREADWRITE should be used</li>
  <li>Implement any REETODOs that appear in compiled executables</li>
</ul>
