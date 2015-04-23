#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir % A_AppData . "\Plunge\"  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
#SingleInstance force

if not A_IsAdmin
{
   Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
   ExitApp
}

FileInstall, nu.ico, % A_Temp . "\nu.ico" 

Menu, Tray, NoStandard
Menu, Tray, Add, Exit, GuiClose
Menu, Tray, Icon, % A_Temp . "\nu.ico"

#Persistent

DownloadFile(UrlToFile, SaveFileAs) {
    ;Initialize the WinHttpRequest Object
	WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	;Download the headers
	WebRequest.Open("HEAD", UrlToFile)
	WebRequest.Send()
	;Store the header which holds the file size in a variable:
	FinalSize := WebRequest.GetResponseHeader("Content-Length")
	FinalSizeMB := Round(FinalSize / 1000000, 2)
	;set the timer
	SetTimer, __UpdateProgressBar, 500
    ;Download the file
    UrlDownloadToFile, %UrlToFile%, %SaveFileAs%
    ;Remove the timer because the download has finished
    SetTimer, __UpdateProgressBar, Off
    Return
    
    __UpdateProgressBar:
    ;Get the current filesize and tick
    CurrentSize := FileOpen(SaveFileAs, "r").Length ;FileGetSize wouldn't return reliable results
	CurrentSizeMB := Round(CurrentSize / 1000000, 2)
    CurrentSizeTick := A_TickCount
    ;Save the current filesize and tick for the next time
    LastSizeTick := CurrentSizeTick
    LastSize := FileOpen(SaveFileAs, "r").Length
	;Calculate the download speed
    Speed := Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
    ;Calculate percent done
    PercentDone := Round(CurrentSize/FinalSize*100)
    ;Update the ProgressBar
	GuiControl, , ProgressBar, %PercentDone%
	GuiControl, , Action, Downloading Kivy`n%CurrentSizeMB% MB / %FinalSizeMB% MB
    Return
}

MsgBox, 36, Plunge Installer, You are about to install the Plunge GUI onto your system.`n`nPlunge requires Kivy <http://kivy.org> in order to work.`n`nThis installer will now download and configure Kivy.`n`nThis may take some time depending on your internet connection`nDo you want to continue?
IfMsgBox, No
	ExitApp

Gui, -Caption
Gui, +Border
Gui, Font, s12
Gui, Add, Text, w400 Center vAction R2
Gui, Add, Progress, w400 vProgressBar -Smooth
Gui, Show, AutoSize, Plunge Installer  

GuiControl, , Action, Creating Plunge Directories`n%A_WorkingDir%
GuiControl, , ProgressBar, 50 
#Include, create_plunge_dirs.ahk
Sleep, 1500
GuiControl, , Action, Copying Plunge Files
GuiControl, , ProgressBar, 100
#Include, install_plunge_files.ahk
Sleep, 1500
GuiControl, , Action, Downloading Kivy
GuiControl, , ProgressBar, 0

if A_Is64bitOS
	url = http://kivy.org/downloads/1.9.0/Kivy-1.9.0-py2.7-win32-x64.exe
else
	url = http://kivy.org/downloads/1.9.0/Kivy-1.9.0-py2.7-win32-x86.exe
	
file = % A_AppData . "\Plunge\kivy.exe"	
DownloadFile(url, file)
;FileCopy, kivy.exe, % file, 1	
GuiControl, , Action, Extracting Kivy
Process, Close, kivy.exe
Run, % A_AppData . "\Plunge\kivy.exe """ . A_AppData . "\Plunge\""", , Hide
counter = 0
while !WinExist("ahk_class #32770", "E&xtract to") 
{
	counter += 1
	if counter > 1000000000
	{
		MsgBox, 16, Plunge Installer, There was an error when installing Kivy.`n`nPlease try again.
		ExitApp
	}
	continue
}
ControlClick, Button2, ahk_class #32770, E&xtract to
counter = 0
while !WinExist("ahk_class #32770", "Remaining time:")
{
	counter += 1
	if counter > 1000000000
	{
		MsgBox, 16, Plunge Installer, There was an error when installing Kivy.`n`nPlease try again.
		ExitApp
	}
	continue
}
WinHide, ahk_class #32770, Remaining time
while WinExist("ahk_class #32770", "Remaining time:")
{
	WinHide, ahk_class #32770, Remaining time
	ControlGetText, total_size, Static15, ahk_class #32770, Remaining time
	ControlGetText, current_size, Static17, ahk_class #32770, Remaining time
	WinGetTitle, perc, ahk_class #32770, Remaining time
	perc := StrReplace(perc, "`% Extracting")
	perc = %perc%
	GuiControl, , Action, Extracting Kivy`n%current_size% / %total_size%
	;ToolTip, a%perc%b
	GuiControl, , ProgressBar, %perc%
	Sleep, 500
	if perc = 100
	{
		sleep, 1500
		break
	}
	continue
}
GuiControl, , ProgressBar, 100
GuiControl, , Action, Installing Start Menu Shortcut
FileInstall, plunge runner.exe, % A_AppData . "\Plunge\Plunge.exe", 1
FileCreateDir, % A_StartMenuCommon . "\Plunge"
FileCreateShortcut, % A_AppData . "\Plunge\Plunge.exe", % A_StartMenuCommon . "\Plunge\Plunge.lnk", % A_AppData . "\Plunge", , Plunge UI, %A_AppData%\Plunge\res\icons\nu.ico
Sleep, 1000
MsgBox, 36, Plunge Installer, Would you like a shortcut to be placed on your desktop?
IfMsgBox, Yes
{
	FileCreateShortcut, % A_AppData . "\Plunge\Plunge.exe", % A_Desktop . "\Plunge.lnk", % A_AppData . "\Plunge", , Plunge UI, %A_AppData%\Plunge\res\icons\nu.ico
	GuiControl, , Action, Installing Desktop Shortcut
	Sleep, 1500
}
GuiControl, , Action, Finished
Sleep, 2000
Process, Close, kivy.exe
ExitApp

GuiClose:
Process, Close, kivy.exe
ExitApp


 


