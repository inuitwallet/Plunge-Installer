#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance, force

;########Plunge########

plunge_dir = C:\Users\sammoth\Documents\projects\plunge

;########Directories#########

out_dir_file = create_plunge_dirs.ahk
FileDelete, % out_dir_file
FileAppend, % "FileCreateDir, %A_AppData%\Plunge`n", % out_dir_file

Loop, Files, % plunge_dir . "\*", DR
{
	if InStr(A_LoopFileFullPath, ".git") || A_LoopFileName = "logs"
		continue
	dest_dir = % "%A_AppData%\Plunge" . StrReplace(A_LoopFileFullPath, plunge_dir)
	FileAppend, % "FileCreateDir, " . dest_dir . "`n", % out_dir_file
}

;#######Files##############

out_file_file = install_plunge_files.ahk
FileDelete, % out_file_file

Loop, Files, % plunge_dir . "\*", FR
{
	if InStr(A_LoopFileFullPath, ".git") || InStr(A_LoopFileFullPath, "logs") || InStr(A_LoopFileFullPath, "api_keys.json") || InStr(A_LoopFileFullPath, "user_data.json") || A_LoopFileExt = "ini" || A_LoopFileExt = "pyc"
		continue
	FileGetSize, file_size
	if (file_size = 0)
		FileAppend, #Cant be blank, % A_LoopFileFullPath
	dest_file = % "%A_AppData%\Plunge" . StrReplace(A_LoopFileFullPath, plunge_dir)
	FileAppend, % "FileInstall, " . A_LoopFileFullPath . ", " . dest_file . ", 1`n", % out_file_file
}

MsgBox Done