#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir % A_AppData . "\Plunge\"  ; Ensures a consistent starting directory.

Menu, Tray, Icon, %A_AppData%\Plunge\res\icons\nu.ico

if A_Is64bitOS
	Run, % A_AppData . "\Plunge\Kivy-1.9.0-py2.7-win32-x64\kivy-2.7.bat """ . A_AppData . "\Plunge\plunge.py""", A_WorkingDir, Hide
else
	Run, % A_AppData . "\Plunge\Kivy-1.9.0-py2.7-win32-x86\kivy-2.7.bat """ . A_AppData . "\Plunge\plunge.py""", A_WorkingDir, Hide
ExitApp



