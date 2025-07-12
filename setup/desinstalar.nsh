; desinstalar.nsi
;================================
; MODULO: DESINSTALAR
;================================

;--------------------------------
; FUNCIONES
;--------------------------------

Function un.onInit
	Push $0
	ReadRegStr $Version HKCU "${HKCUNI}" "DisplayVersion"
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	InitPluginsDir
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	StrCpy $unComponentsIniTemp "$PluginsDir\componentes.ini"
	CopyFiles /SILENT /FILESONLY "$INSTDIR\componentes.ini" "$PluginsDir\"
	Pop $0
FunctionEnd

Function un.SetDateTimeStamp
	Push $1
	${GetTime} "" "L" $Day $Month $Year $1 $Hour $Min $Sec
	IntFmt $Year "%04d" $Year
	IntFmt $Month "%02d" $Month
	IntFmt $Day "%02d" $Day
	IntFmt $Hour "%02d" $Hour
	IntFmt $Min "%02d" $Min
	StrCpy $Timestamp "$Year$Month$Day-$Hour$Min"
	Pop $1
FunctionEnd

Function un.RemoveDirIfEmpty
	Exch $0
	IfFileExists "$0\*\*.*" 0 +2
		Return
	RMDir "$0"
FunctionEnd

Function un.RemoveFromComponentsIni
	${IfNot} ${SectionIsSelected} ${SEC_01}
		DetailPrint "$(TXT_LogRemoviendo): $unComponentKey = $unComponentValue"
		WriteINIStr "$INSTDIR\componentes.ini" "Installed" "$unComponentKey" ""
		WriteINIStr "$INSTDIR\componentes.ini" "Paths" "$unComponentKey" ""
	${EndIf}
FunctionEnd

Function un.UninstallComponents
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	${IfNot} ${FileExists} "$unComponentsIniTemp"
		Goto EndUninstall
	${EndIf}
	FileOpen $R0 "$unComponentsIniTemp" r
	StrCpy $R3 0
	ClearErrors
LoopRead:
	FileRead $R0 $R1
	IfErrors CloseFile
	${unStrTrimNewLines} $R1 "$R1"
	${If} "$R1" == ""
	${OrIf} "$R1" == ";"
		Goto LoopRead
	${EndIf}
	${If} "$R1" == "[Paths]"
		StrCpy $R3 1
		Goto LoopRead
	${EndIf}
	${If} $R3 == 1
		${WordFind} "$R1" "=" "+2" $unComponentValue
		${WordFind} "$R1" "=" "+1" $unComponentKey
		${unStrRep} $unComponentValue $unComponentValue '"' ''
		${If} $unComponentValue != ""
			${unStrStr} $R2 "$unComponentValue" "$unComponentsDir"
			${If} $R2 != ""
				
				DetailPrint "..."
				DetailPrint "$(TXT_LogDesinstalando): $unComponentKey"
				Delete "$unComponentValue\*.*"
				RMDir /r "$unComponentValue"
				Call un.RemoveFromComponentsIni
				Push "$unComponentValue"
				Call un.RemoveFromEnvUserPath
			${EndIf}
		${EndIf}
		Goto LoopRead
	${EndIf}
	Goto LoopRead
CloseFile:
	FileClose $R0
EndUninstall:
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
FunctionEnd

Function un.RemoveFromEnvUserPath
	Pop $0
	${unStrTrimNewLines} $0 $0
	${unStrRep} $0 $0 '"' ''
	ReadRegStr $1 HKCU "Environment" "Path"
	${If} $1 == ""
		Goto EndRm
	${EndIf}
	${unStrRep} $1 "$1" ";$0;" ";"
	${unStrRep} $1 "$1" "$0;" ""
	${unStrRep} $1 "$1" ";$0" ""
LoopCleanRm:
	${unStrStr} $2 $1 ";;"
	${If} $2 == ""
		Goto TrimEnds
	${EndIf}
	${unStrRep} $1 $1 ";;" ";"
	Goto LoopCleanRm
TrimEnds:
	${If} $1 != ""
		StrCpy $2 $1 1
		${If} $2 == ";"
			StrCpy $1 $1 "" 1
		${EndIf}
		StrLen $2 $1
		${If} $2 > 0
			IntOp $2 $2 - 1
			StrCpy $3 $1 1 $2
			${If} $3 == ";"
				StrCpy $1 $1 $2
			${EndIf}
		${EndIf}
	${EndIf}
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndRm:
FunctionEnd

Function un.CheckAllComponents
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	SectionSetFlags ${SEC_01} ${SF_SELECTED}
	${GetSize} "$INSTDIR" "/S=0K" $R1 $R2 $R3
	SectionSetSize ${SEC_01} $R1
	${If} ${FileExists} "$InstDrive${TOOLS}"
		SectionSetFlags ${SEC_02} ${SF_SELECTED}
		${GetSize} "$InstDrive${TOOLS}" "/S=0K" $R1 $R2 $R3
		SectionSetSize ${SEC_02} $R1
	${Else}
		SectionSetText ${SEC_02} ""
	${EndIf}
	${If} ${FileExists} "${RESOURCES}"
		SectionSetFlags ${SEC_03} ${SF_SELECTED}
		${GetSize} "${RESOURCES}" "/S=0K" $R1 $R2 $R3
		SectionSetSize ${SEC_03} $R1
	${Else}
		SectionSetText ${SEC_03} ""
	${EndIf}
	${If} ${FileExists} "$InstDrive${VENDOR}"
		SectionSetFlags ${SEC_04} ${SF_SELECTED}
		${GetSize} "$InstDrive${VENDOR}" "/S=0K" $R1 $R2 $R3
		SectionSetSize ${SEC_04} $R1
	${Else}
		SectionSetText ${SEC_04} ""
	${EndIf}
	${If} ${FileExists} "${APPDATA}"
		SectionSetFlags ${SEC_05} ${SF_SELECTED}
		${GetSize} "${APPDATA}" "/S=0K" $R1 $R2 $R3
		SectionSetSize ${SEC_05} $R1
	${Else}
		SectionSetText ${SEC_05} ""
	${EndIf}
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
FunctionEnd
