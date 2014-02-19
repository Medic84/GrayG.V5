#Include <File.au3>

;Dim $sIgnoreFolders[4] = ["boots", "fonts", "preview", "wallpaper"]
;$sOutputDir = "C:\Users\RDP\Documents\Archives"
;$s7za = "C:\Program Files (x86)\7-Zip"

Dim $szDrive, $szDir, $szFName, $szExt

$s7za = IniRead(@ScriptDir & "\config.ini", "Paths", "7za", "C:\Program Files (x86)\7-Zip")
$sOutputDir = IniRead(@ScriptDir & "\config.ini", "Paths", "OutputDir", "C:\Users\RDP\Documents\Archives")
$sOutputFile = IniRead(@ScriptDir & "\config.ini", "Paths", "OutputFile", "Compiled_theme")
$sIgnoreFolders = IniRead(@ScriptDir & "\config.ini", "Settings", "IgnoreFolders", "boots,fonts,preview,wallpaper")
$asDirs = _FileListToArray(@ScriptDir, "*", 2)
$aIgnoreFolders = StringSplit($sIgnoreFolders, ",", 2)

If Not FileExists($s7za) Then
	MsgBox(16,"Ошибка","Путь до 7z не найден!",20)
	Exit
EndIf

If Not FileExists($sOutputDir) Then
	MsgBox(16,"Ошибка","Пути " & $sOutputDir & " не существует!",20)
	Exit
EndIf

ProgressOn("Обработано", "", "0 %")

For $i = 1 To $asDirs[0]
	Local $sKeys = ' a -tzip -mx0 -w"' & @ScriptDir & "\" & $asDirs[$i] & '" '
	Local $p = Round($i / $asDirs[0] * 100,2)
	
	ProgressSet($p , $p & "%", $asDirs[$i])
	For $j = 0 To UBound($aIgnoreFolders) - 1
		If $aIgnoreFolders[$j] == $asDirs[$i] Then 
			DirCopy(@ScriptDir & "\" & $asDirs[$i], $sOutputDir & "\" & $asDirs[$i],9)
			ContinueLoop(2)
		EndIf
	Next
	
	RunWait($s7za & "\7z.exe" & $sKeys & $asDirs[$i] & ".zip " & ".\" & $asDirs[$i] & "\*", @ScriptDir, @SW_HIDE)
	Sleep(500)
	FileMove(@ScriptDir & "\" & $asDirs[$i] & '.zip', $sOutputDir & "\" & $asDirs[$i], 9)
	FileCopy(@ScriptDir & "\description.xml", $sOutputDir & "\description.xml", 9)
Next

$sPath = _PathSplit($sOutputDir, $szDrive, $szDir, $szFName, $szExt)

RunWait($s7za & '\7z.exe a -tzip -mx0 -w"' & $sOutputDir & '" '& $sOutputFile &'.zip ' & '.\'& $sPath[3] &'\*', $sPath[1] & $sPath[2], @SW_HIDE)
sleep(500)
FileMove($sPath[1] & $sPath[2] & $sOutputFile &'.zip', $sPath[1] & $sPath[2] & $sOutputFile &'.mtz', 9)
ProgressOff()