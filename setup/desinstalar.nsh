; desinstalar.nsi
;================================
; MODULO: DESINSTALAR
;================================

;--------------------------------
; VARIABLES GLOBALES
;--------------------------------
Var unToolsCheckboxState
Var unToolsCheckbox
Var unVendorCheckboxState
Var unVendorCheckbox
Var unResourcesCheckboxState
Var unResourcesCheckbox

;--------------------------------
; MACROS DE EXTENSIONES
;--------------------------------
${unStrTrimNewLines}
${unStrRep}
${unStrStr}

;--------------------------------
; MACROS DESINSTALACION
;--------------------------------

!macro MUninstallAllComponents
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	Push $R5
	StrCpy $R2 "$PluginsDir\componentes.ini"
	IfFileExists "$R2" 0 EndUninstall
	FileOpen $R0 "$R2" r
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
		${WordFind} "$R1" "=" "+2" $R4
		${unStrRep} $R4 $R4 '"' ''
		${If} $R4 != ""
			${If} $unToolsCheckboxState == "1"
				${unStrStr} $R5 $R4 "$InstDrive${TOOLS}"
				${If} $R5 != ""
					RMDir /r "$R4"
					Push "$R4"
					Call un.RemoveFromEnvUserPath
				${EndIf}
			${EndIf}
			${If} $unVendorCheckboxState == "1"
				${unStrStr} $R5 $R4 "$InstDrive${VENDOR}"
				${If} $R5 != ""
					RMDir /r "$R4"
					Push "$R4"
					Call un.RemoveFromEnvUserPath
				${EndIf}
			${EndIf}
			${If} $unResourcesCheckboxState == "1"
				${unStrStr} $R5 $R4 "${RESOURCES}"
				${If} $R5 != ""
					RMDir /r "$R4"
					Push "$R4"
					Call un.RemoveFromEnvUserPath
				${EndIf}
			${EndIf}
		${EndIf}
		Goto LoopRead
	${EndIf}
	Goto LoopRead
CloseFile:
	FileClose $R0
EndUninstall:
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

;--------------------------------
; FUNCIONES
;--------------------------------

Function un.onInit
	Push $0
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	InitPluginsDir
	Pop $0
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "$(TXT_EtiqDesinstalarComponentes)"
	Pop $0
	${NSD_CreateCheckbox} 0 16u 100% 12u "$(TXT_EtiqRemoverTools) ($InstDrive${TOOLS})"
	Pop $unToolsCheckbox
	${NSD_Check} $unToolsCheckbox
	${NSD_CreateCheckbox} 0 32u 100% 12u "$(TXT_EtiqRemoverResources) (${RESOURCES})"
	Pop $unResourcesCheckbox
	${NSD_Check} $unResourcesCheckbox
	${NSD_CreateCheckbox} 0 48u 100% 12u "$(TXT_EtiqRemoverVendor) ($InstDrive${VENDOR})"
	Pop $unVendorCheckbox
	${NSD_Check} $unVendorCheckbox
	nsDialogs::Show
FunctionEnd

Function un.ReadChoiceUninstall
	${NSD_GetState} $unToolsCheckbox $unToolsCheckboxState
	${NSD_GetState} $unVendorCheckbox $unVendorCheckboxState
	${NSD_GetState} $unResourcesCheckbox $unResourcesCheckboxState
FunctionEnd

Function un.RemoveDirIfEmpty
	Exch $0
	IfFileExists "$0\*\*.*" 0 +2
		Return
	RMDir "$0"
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

;--------------------------------
; SECCIONES
;--------------------------------

Section "Uninstall"
	CopyFiles /SILENT /FILESONLY "$INSTDIR\componentes.ini" "$PluginsDir\"
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	Delete "$INSTDIR\*.*"
	Delete "$StartUpDir\${NAME}.lnk"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$DESKTOP\${INSTALLER_NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk"
	RMDir /r "$SMPROGRAMS\${NAME}"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$PluginsDir"
	RMDir /r "$INSTDIR"
	${If} $unToolsCheckboxState != "1"
	${AndIf} $unVendorCheckboxState != "1"
	${AndIf} $unResourcesCheckboxState != "1"
		Goto Done
	${EndIf}
	!insertmacro MUninstallAllComponents
	${If} $unToolsCheckboxState == "1"
		Push "$InstDrive${TOOLS}"
		Call un.RemoveDirIfEmpty
	${EndIf}
	${If} $unVendorCheckboxState == "1"
		Push "$InstDrive${VENDOR}"
		Call un.RemoveDirIfEmpty
	${EndIf}
	${If} $unResourcesCheckboxState == "1"
		Push "${RESOURCES}"
		Call un.RemoveDirIfEmpty
	${EndIf}
Done:
SectionEnd
