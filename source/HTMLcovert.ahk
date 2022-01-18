#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#NoTrayIcon

;#####################################

;default values here
MinedCores := "0"
CoreCount := "0|"
BlockHeight := "N/A"
TotalBalance := "0.00000000"
ImmatureBalance := "0.00000000"
powDifficulty := "N/A"
NetworkConnections := "0"
;CPUload := "N/A"
MineButton := "Start Mining"
SendToServer := "Send to Server"
MiningSince := "0"
MiningSinceText := "Mining Since:     N/A"
CoreCountText := "You are NOT currently mining"

;Features - independant select of cli and daemon, can rename them also
;
;
;

;Process
;check if coopers client is running [YES]
;check for html AppData location via registry [YES]
;check if HTMLD/CLI is present in directroy / choose new path [YES]
;check if htmld is already running-if so get uptime (if started from app previously, and app closed) [YES]
;check running cores [Maybe]

;

;##check if coopers is runnig First
Process, Exist, htmlcoin-qt.exe
	IF !ErrorLevel=0
	{
		MsgBox % "Coopers Wallet is Open...`n`nYou must Close it first!"
		ExitApp
	}


;##check for the HTML appdata location.
RegRead, HTMLCOINappDataLocation, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLCOIN-Qt, strDataDir
	if (!HTMLCOINappDataLocation){
		MsgBox % "No HTMLCOIN location found, please run coopers GUI first"
		ExitApp
	}

;get blocksFound
debugLogFile := HTMLCOINappDataLocation "\debug.log"

;##CHECK FOR htmld/cli exe in regfirst\ then current dir if not found-;


findRegKeysandPath(RegName)
{

global EXEtoFind
global EXEPath

	RegRead, FullEXEandPath, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, %RegName%
	if (FullEXEandPath){
		{
			;split path- eg; C:\KramWell\html\htmlcoind.exe > C:\KramWell\html\ + htmlcoind.exe
			FullEXEandPathSplit := StrSplit(FullEXEandPath, "\")
			EXEtoFind:=FullEXEandPathSplit[FullEXEandPathSplit.MaxIndex()]
			EXEPath := StrReplace(FullEXEandPath, EXEtoFind, "")
		} ;end if regkey found
	}else{
		;use default values if key not found
		if (RegName = "daemon"){
			EXEtoFind := "htmlcoind.exe"
		}else if (RegName = "cli"){
			EXEtoFind := "htmlcoin-cli.exe"
		}
		EXEPath := A_ScriptDir "\"
	} ;end if regkey not found

	;check if file exists
	if !FileExist(EXEPath EXEtoFind)
		{
			MsgBox % "I can't find " EXEtoFind " in " EXEPath "`nPlease show me where it is."
			FileSelectFile, FullEXEandPath, ,%A_ScriptDir%, , %EXEtoFind%
			if FullEXEandPath = 
				{
					MsgBox,,QT-Wallet, I cant find the HTML-Wallet.`nPlease Download and Install it.
					;run, https://github.com/HTMLCOIN/HTMLCOIN/releases	
					ExitApp
				}
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, %RegName%, %FullEXEandPath%
			FullEXEandPathSplit := StrSplit(FullEXEandPath, "\")
			EXEtoFind:=FullEXEandPathSplit[FullEXEandPathSplit.MaxIndex()]
			EXEPath := StrReplace(FullEXEandPath, EXEtoFind, "")		
		}	

		
} ;end Function findRegKeys


;we could check current block and see what we have? - wait until all good.


findRegKeysandPath("daemon") ;check for valid deamon path.
daemonEXEtoFind := EXEtoFind
daemonEXEPath := EXEPath

findRegKeysandPath("cli")
cliEXEtoFind := EXEtoFind
cliEXEPath := EXEPath

;clear globals
EXEPath =
EXEtoFind =

;MsgBox % daemonEXEtoFind

;here we will populate number of cores
;now we need to startmining to do this we get the amount of cores 
EnvGet, ProcessorCount, NUMBER_OF_PROCESSORS
Loop, %ProcessorCount%
{
	CoreCount := CoreCount . "|" . A_Index
}

;now we have the location we need to load htmld- (check if running first and see uptime)
Process, Exist, %daemonEXEtoFind%
HTMLCOIND_PID = %ErrorLevel%
	IF !HTMLCOIND_PID=0 ;if HTMLCOIND is not 0 then it is already running
	{

	}else{

		try
		{
		
	;delete debug log file before deamon is loaded- everytime it is loaded we need to delete the file-
	;FileDelete, %HTMLCOINappDataLocation%\debug.log
	;check for mined blocks
		
			;Run htmlcoind.exe --shrinkdebugfile,%COOPERSlocation% ,Hide , NewPID
			SplashTextOn,,, Starting Daemon.
			Run %daemonEXEtoFind%,%daemonEXEPath% ,Min , HTMLCOIND_PID
			Sleep, 6000
			;SplashTextOff
			;log starttime here in Reg
		;	RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, daeStartTime, %A_Now%	
		}
		catch e ;e not neede at this point
		{
			MsgBox % "ERROR: '" daemonEXEtoFind "' not found!"
			ExitApp
		}

		;MsgBox % NewPID

		;now that htmlcoind is running we need to log the starttime.

		
} ;end if HTMLCOIND already running

;#############
;check to see if currently mining - getgenerate = false/true
SplashTextOn,,, Loading Checks...
CommandToRun := cliEXEPath cliEXEtoFind " getgenerate"
ReadOut := RunWaitOne(CommandToRun)
;Sleep, 1000
;SplashTextOff
If InStr(ReadOut, "true"){
	;we are currently mining
	MineButton := "Stop Mining"
	RegRead, MiningSince, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MiningSince
	RegRead, MinedCores, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MinedCores
	MiningSinceText := "Mining Since:     " MiningSince
	CoreCountText := "You are currently mining with " MinedCores " out of " ProcessorCount " cores"	
	;check the amount of blocks found.
	
}

;MsgBox % HTMLCOIND_PID

;now we have a runnig protocall htmlcoind- with access to the cli- and a start time when loaded.

;Start CPU time
;#########################
SetTimer, ShowCpuLoad, 1000

;we can get the process- but will need to add later.
;#########################

SplashTextOn,,, Grabbing Info...

;#############
GoSub, UpdateValues

;update values every minute		
Settimer,UpdateValues,60000 ;once a minute update values
		
;#############		
;get saved time from reg
;RegRead, daemonStartTime, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, daeStartTime
;FormatTime, MiningSince, %daemonStartTime%, hh:mm tt - ddd MM yy
;MsgBox % daemonStartTime

SplashTextOff

;now we load up the gui and wait for button pressed.
;#############
;Create GUI
Gui,Add,DropDownList,x279 y9 w50 vMinedCores, %CoreCount%
Gui,Add,Text,x10 y10 w260 h15,Please choose the number of threads you want to mine
Gui,Font,norm s11,
Gui,Add,Button,x370 y10 w100 h30 gMineButton vMineButton ,%MineButton%
Gui,Font
Gui,Add,Text,x10 y30 w300 h13,It is recommended to use one or two less than the maximum
Gui,Add,Text,x10 y50 w300 h13 vCoreCountText,%CoreCountText%
Gui,Add,Button,x370 y80 w100 h23 gLockComputer,Lock Computer
Gui,Add,Text,x10 y90 w80 h13 vpowDifficulty,POW:     %powDifficulty%
Gui,Add,Text,x160 y90 w200 h13 vMiningSinceText, %MiningSinceText%
Gui,Add,Text,x10 y110 w130 h13 vBlockHeight,Block height     %BlockHeight%
Gui,Add,Text,x160 y110 w100 h13 vMinedBlocks,Mined Blocks:     %MinedBlocks%
Gui,Add,Button,x370 y110 w100 h23 gHideToTray,Hide to tray
Gui,Add,Text,x10 y130 w145 h13 vTotalBalance,Balance:     %TotalBalance%
Gui,Add,Text,x160 y130 w200 h13 vImmatureBalance,Immature Balance:     %ImmatureBalance%
Gui,Add,Button,x370 y140 w100 h23 gSendToServer vSendToServer, %SendToServer%
Gui,Add,Text,x10 y150 w120 h13 vNetworkConnections,Connections:     %NetworkConnections%
Gui,Add,Text,x160 y150 w120 h13 vCPUload,CPU Load:
Gui,Add,Text,x10 y170 w300 h13,Send found coins to address once confirmed:
Gui,Add,Text,x370 y180 w100 h13,Say Thanks!
Gui,Add,Edit,x55 y187 w250 h21,HmtknYWPx95Qjg15rN4FdDyG3Go2riQgcu
Gui,Add,Text,x10 y190 w45 h13,Address:
Gui,Add,Button,x370 y200 w100 h30,Buy me a beer?
Gui,Add,Button,x10 y210 w100 h23,Send to Address
Gui,Show,w478 h238,HTMLcovert CPU Miner x64- KramWell.com
Return

;mine button clicked
;########################
MineButton:

GuiControlGet, MinedCores
GuiControlGet, MineButton

If (MineButton = "Start Mining")
	{

		if (MinedCores = "0"){
			MsgBox % "ERROR: Please select a CPU number higher than 0 to mine with."
			Return
		}
	
		;here we need to start mining based on cores selected. check if getgenerate is true after

		CommandToRun := cliEXEPath cliEXEtoFind " setgenerate true " MinedCores
		ReadOut := RunWaitOne(CommandToRun)
		
		CommandToRun := cliEXEPath cliEXEtoFind " getgenerate"
		ReadOut := RunWaitOne(CommandToRun)		
		
		If InStr(ReadOut, "true"){
			;we are currently mining
			MiningSince := A_Now
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MiningSince, %A_Now%		
			RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MinedCores, %MinedCores%
			GuiControl, Text, MiningSinceText, Mining Since:     %A_Now%
			GuiControl, Text, CoreCountText, You are currently mining with %MinedCores% out of %ProcessorCount% cores						
			GuiControl, Text, MineButton, Stop Mining
			
		}else{
			MsgBox % "ERROR: Miner will not start..."
		}

		
		
	}else{
	
		;setgenerate false > stop mining.
		CommandToRun := cliEXEPath cliEXEtoFind " setgenerate false"
		ReadOut := RunWaitOne(CommandToRun)
		
		CommandToRun := cliEXEPath cliEXEtoFind " getgenerate"
		ReadOut := RunWaitOne(CommandToRun)		
		
		If InStr(ReadOut, "false"){
			;we have stopped mining
		RegDelete, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MiningSince
		RegDelete, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, MinedCores
		GuiControl, Text, MiningSinceText, Mining Since:     N/A
		GuiControl, Text, MineButton, Start Mining
		GuiControl, Text, CoreCountText, You are NOT currently mining.
		MiningSince := "0"
		
		;Settimer,UpdateValues,off
		}else{
			MsgBox % "ERROR: Miner will not stop..."
		}
		
		;here we need to stop mining check if getgenerate is false after

	
	}

;here we need to setgenerate true 

Return

;#########################
LockComputer:
	RunWaitOne("rundll32.exe user32.dll, LockWorkStation")
Return

;#########################
RunWaitOne(command) {
    shell := ComObjCreate("WScript.Shell")
    exec := shell.Exec(ComSpec " /C " command)
    return exec.StdOut.ReadAll()
}

;######################
CheckIfMinedBlocksFound(debugLogFile){
MinedBlocks := "0"

;MsgBox % debugLogFile
	if !FileExist(debugLogFile)
	{
		MsgBox % "Can't find debug.log file"
		ExitApp
	}
	Loop, read, %debugLogFile%
	{
		If InStr(A_LoopReadLine, "proof-of-work found"){
			MinedBlocks++
		}
	}
Return MinedBlocks
}

;######################
UpdateValues:

;now we have the location we need to load htmld- (check if running first and see uptime)
Process, Exist, %daemonEXEtoFind%
HTMLCOIND_PID = %ErrorLevel%
	IF HTMLCOIND_PID=0 ;if HTMLCOIND is not 0 then it is already running
	{
		try
		{
			Run %daemonEXEtoFind%,%daemonEXEPath% ,Min , HTMLCOIND_PID
			Sleep, 6000
		}
		catch e ;e not neede at this point
		{
			;log error here as had to restart.
		}	
} ;end if HTMLCOIND already running


		;every 60 seconds update values- 
		;Pow
		;BlockHeight
		;connections
		
	;populate values
	CommandToRun := cliEXEPath cliEXEtoFind " getinfo"
	;SplashTextOn,,, Getting info 1 of 2
	ReadOut := RunWaitOne(CommandToRun)
	SplitCommandByNewLine := StrSplit(ReadOut, "`n")
	;Sleep, 1000
	;SplashTextOff
	;MsgBox % ReadOut

	LoopAmount := SplitCommandByNewLine.maxindex()
	Loop, %LoopAmount%
	{
		;MsgBox % SplitCommandByNewLine[A_Index-1]

			;check here for needed value


		If InStr(SplitCommandByNewLine[A_Index-1], "balance"){		
			RegExMatch(SplitCommandByNewLine[A_Index-1],":(.*),",TotalBalance)		
			TotalBalance := StrReplace(TotalBalance1,A_Space , "")
			GuiControl, Text, TotalBalance, Balance:     %TotalBalance%	
		}				
			
		If InStr(SplitCommandByNewLine[A_Index-1], "connections"){		
			RegExMatch(SplitCommandByNewLine[A_Index-1],":(.*),",NetworkConnections)
			NetworkConnections := NetworkConnections1
			GuiControl, Text, NetworkConnections, Connections:     %NetworkConnections%
		}	
		
		If InStr(SplitCommandByNewLine[A_Index-1], "proof-of-work"){		
			RegExMatch(SplitCommandByNewLine[A_Index-1],":(.*),",powDifficulty)
			powDifficulty := Ceil(powDifficulty1)
			GuiControl, Text, powDifficulty, POW:     %powDifficulty%
		}	

		If InStr(SplitCommandByNewLine[A_Index-1], "blocks"){		
			RegExMatch(SplitCommandByNewLine[A_Index-1],":(.*),",BlockHeight)
			BlockHeight := StrReplace(BlockHeight1,A_Space , "")			
			GuiControl, Text, BlockHeight, Block Height:     %BlockHeight%
			;MsgBox % ";" BlockHeight ";"			
		}
			;-getinfo
			;connections
			;Pow
			;blocks

	}	

	;#############
	;populate values
	CommandToRun := cliEXEPath cliEXEtoFind " getwalletinfo"
	;SplashTextOn,,, Getting info 2 of 2
	ReadOut := RunWaitOne(CommandToRun)
	SplitCommandByNewLine := StrSplit(ReadOut, "`n")
	;Sleep, 1000
	;SplashTextOff
	;MsgBox % ReadOut

	LoopAmount := SplitCommandByNewLine.maxindex()
	Loop, %LoopAmount%
	{

		If InStr(SplitCommandByNewLine[A_Index-1], "immature_balance"){		
			RegExMatch(SplitCommandByNewLine[A_Index-1],":(.*),",ImmatureBalance)
			ImmatureBalance := ImmatureBalance1
			GuiControl, Text, ImmatureBalance, Immature Balance:     %ImmatureBalance%		
		}	
		
			;-getwalletinfo
			;balance
			;immature_balance
			;unconfirmed_balance	
		
	}	

	;##############
	;update block count.
	MinedBlocks := CheckIfMinedBlocksFound(debugLogFile)
	GuiControl, Text, MinedBlocks, Mined Blocks:     %MinedBlocks%

	;##############
	;send to server if button selected.
	GuiControlGet, SendToServer
	If (SendToServer = "Sending...")
	{
		;send stats to website-
		;check for callback it php?fffff > result 1
		;if not 1 then error.

MiningSinceUnix = %MiningSince%
MiningSinceUnix -= 1970,s
		
encodeTextToSend := "MinedCores=" MinedCores ";ProcessorCount=" ProcessorCount ";BlockHeight=" BlockHeight ";TotalBalance=" TotalBalance ";ImmatureBalance=" ImmatureBalance ";powDifficulty=" powDifficulty ";NetworkConnections=" NetworkConnections ";CPUload=" CPUload ";MiningSince=" MiningSinceUnix ";MinedBlocks=" MinedBlocks ";Worker=" Worker ";"

		
;"MinedCores="MinedCores
;ProcessorCount=
;BlockHeight
;TotalBalance
;ImmatureBalance
;powDifficulty
;NetworkConnections
;CPUload
;MiningSince
;MinedBlocks
;Worker
		
		
		;encodeTextToSend := "MiningSince=" MiningSince ";"
		
		;"setTime=33443343;upTime=56565656;totalBlocks=55667;worker=rig1"
		
		;encodeTextToSend := Base64Encode()
		
		;################################
		;Send and receive stats- send to localhost to be decoded.
		whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
		urlToSend := "http://localhost:8080/sendResults.php?info=" encodeTextToSend

		MsgBox % urlToSend

		whr.Open("GET", urlToSend, true)
		whr.Send()
		; Using 'true' above and the call below allows the script to remain responsive.
		whr.WaitForResponse()
		ResponseText := whr.ResponseText
		
		;responce back needs to be 1 for saved - anything else is error.
		;MsgBox % ResponseText
		
		
	}
	
Return

SendToServer:

GuiControlGet, SendToServer

	If (SendToServer = "Send To Server")
	{	
		RegRead, worker, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, worker
		InputBox, worker, Worker Name, Please enter a name for this worker., , 240, 125,,,,,%worker%
		if (!ErrorLevel){ ;if not cancelled
			if (!worker){ ;if wokrer name is blank
				RegDelete, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, worker
			}else{
				;load up to send
				RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\HTMLCOIN\HTMLcovert, worker, %worker%
				GuiControl, Text, SendToServer, Sending...
			}
		}
	}else{
		GuiControl, Text, SendToServer, Send To Server
	}


Return

;#############################################################################
;Base64Encode - Credits https://gist.github.com/tmplinshi/2f69c09d6bc5a800df76
Base64Encode(string) {
	; js code from http://www.hcidata.info/base64.htm
	static js_code := "
	(LTrim
		var base64s =  ""ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"";

		function aToB64(rawData){
			var encOut = ''
			var b64 = '';
			var i = 0;
			for (var i = 0 ; i <= rawData.length - 3 ; i += 3) {
				var snipit =
					   (rawData.charCodeAt(i  ) & 0xff) << 16
					 | (rawData.charCodeAt(i+1) & 0xff) <<  8
					 | (rawData.charCodeAt(i+2) & 0xff);
				b64 +=
					base64s.charAt(snipit >> 18 & 0x3F) +
					base64s.charAt(snipit >> 12 & 0x3f) +
					base64s.charAt(snipit >>  6 & 0x3f) +
					base64s.charAt(snipit       & 0x3f);
			}
			switch (rawData.length - i) {
			 case (2):
				var snipit =
					   (rawData.charCodeAt(i  ) & 0xff) << 16
					 | (rawData.charCodeAt(i+1) & 0xff) <<  8;
				b64 +=
					base64s.charAt(snipit >> 18 & 0x3F) +
					base64s.charAt(snipit >> 12 & 0x3f) +
					base64s.charAt(snipit >>  6 & 0x3f) +
					'=';
				break;
			 case (1):
				var snipit =
					   (rawData.charCodeAt(i  ) & 0xff) << 16;
				b64 +=
					base64s.charAt(snipit >> 18 & 0x3F) +
					base64s.charAt(snipit >> 12 & 0x3f) +
					'==';
				break;
			 case (0):	// all done
				}
			return b64;
		}
	)"
	static oSC := ComObjCreate("ScriptControl")
	oSC.Language := "JScript"
	oSC.ExecuteStatement(js_code)
	Return oSC.Eval("aToB64('" string "')")
}
;#############################################################################

HideToTray:
Gui, Hide
Menu, Tray, Icon
Menu, Tray, NoStandard
Menu, Tray, Add, Show Window, ShowWindow
Return

ShowWindow:
Gui, Show
Menu, Tray, NoIcon
Return

ShowCpuLoad:
 CPUload := Round( GetProcessTimes(HTMLCOIND_PID), 1)
 GuiControl, Text, CPUload,CPU Load:     %CPUload%`%
Return

GetProcessTimes( HTMLCOIND_PID=0 )    { 
   Static oldKrnlTime, oldUserTime 
   Static newKrnlTime, newUserTime 

   oldKrnlTime := newKrnlTime 
   oldUserTime := newUserTime 

   hProc := DllCall("OpenProcess", "Uint", 0x400, "int", 0, "Uint", HTMLCOIND_PID) 
   DllCall("GetProcessTimes", "Uint", hProc, "int64P", CreationTime, "int64P"
           , ExitTime, "int64P", newKrnlTime, "int64P", newUserTime) 

   DllCall("CloseHandle", "Uint", hProc) 
Return (newKrnlTime-oldKrnlTime + newUserTime-oldUserTime)/10000000 * 100 / 4
}		

GuiClose:
ExitApp 
