; desinstalar.nsi
;================================
; MODULO: DESINSTALAR
;================================

;--------------------------------
; VARIABLES GLOBALES
;--------------------------------
;Var unToolsCheckboxState
;Var unToolsCheckbox
;Var unVendorCheckboxState
;Var unVendorCheckbox
;Var unResourcesCheckboxState
;Var unResourcesCheckbox
Var unComponentsIniTemp

;--------------------------------
; MACROS DE EXTENSIONES
;--------------------------------
${unStrTrimNewLines}
${unStrRep}
${unStrStr}

;--------------------------------
; SECCIONES
;--------------------------------

Section /o "!un.${NAME}" SEC_01
	${If} ${SectionIsSelected} ${SEC_01}
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
	${EndIf}
SectionEnd

Section /o "un.Requisitos y Complementos (herramientas)" SEC_02
	;${If} $unToolsCheckboxState == "1"
	${If} ${SectionIsSelected} ${SEC_02}
		;Push "Tools"
		Push "$InstDrive${TOOLS}"
		Call un.UninstallComponents
		Push "$InstDrive${TOOLS}"
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section /o "un.PhpSinergIA + dependencias (vendor)" SEC_03
	;${If} $unVendorCheckboxState == "1"
	${If} ${SectionIsSelected} ${SEC_03}
		;Push "Vendor"
		Push "$InstDrive${VENDOR}"
		Call un.UninstallComponents
		Push "$InstDrive${VENDOR}"
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section /o "un.Recursos" SEC_04
	;${If} $unResourcesCheckboxState == "1"
	${If} ${SectionIsSelected} ${SEC_04}
		;Push "Resources"
		Push "${RESOURCES}"
		Call un.UninstallComponents
		Push "${RESOURCES}"
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

;--------------------------------
; FUNCIONES
;--------------------------------

Function un.onInit
	Push $0
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	InitPluginsDir
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	StrCpy $unComponentsIniTemp "$PluginsDir\componentes.ini"
	CopyFiles /SILENT /FILESONLY "$INSTDIR\componentes.ini" "$PluginsDir\"
	SectionSetFlags ${SEC_01} ${SF_SELECTED}
	SectionSetFlags ${SEC_02} ${SF_SELECTED}
	SectionSetFlags ${SEC_03} ${SF_SELECTED}
	SectionSetFlags ${SEC_04} ${SF_SELECTED}
	Pop $0
FunctionEnd

;Function un.ShowOptionsUninstall
;	nsDialogs::Create 1018
;	Pop $0
;	${NSD_CreateLabel} 0 0 100% 12u "$(TXT_EtiqDesinstalarComponentes)"
;	Pop $0
;	${NSD_CreateCheckbox} 0 16u 100% 12u "$(TXT_EtiqRemoverTools) ($InstDrive${TOOLS})"
;	Pop $unToolsCheckbox
;	${NSD_Check} $unToolsCheckbox
;	${NSD_CreateCheckbox} 0 32u 100% 12u "$(TXT_EtiqRemoverResources) (${RESOURCES})"
;	Pop $unResourcesCheckbox
;	${NSD_Check} $unResourcesCheckbox
;	${NSD_CreateCheckbox} 0 48u 100% 12u "$(TXT_EtiqRemoverVendor) ($InstDrive${VENDOR})"
;	Pop $unVendorCheckbox
;	${NSD_Check} $unVendorCheckbox
;	nsDialogs::Show
;FunctionEnd

;Function un.ReadChoiceUninstall
;	${NSD_GetState} $unToolsCheckbox $unToolsCheckboxState
;	${NSD_GetState} $unVendorCheckbox $unVendorCheckboxState
;	${NSD_GetState} $unResourcesCheckbox $unResourcesCheckboxState
;FunctionEnd

Function un.RemoveDirIfEmpty
	Exch $0
	IfFileExists "$0\*\*.*" 0 +2
		Return
	RMDir "$0"
FunctionEnd

Function un.RemoveFromComponentsIni
	Pop $0
	MessageBox MB_OK "4-RemoveFromComponentsIni (0): $0"
FunctionEnd

Function un.UninstallComponents
	Pop $0
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	MessageBox MB_OK "1-UninstallComponents: $0"
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
		MessageBox MB_OK "2-UninstallComponents (R1): $R1"
		${WordFind} "$R1" "=" "+2" $R4
		${unStrRep} $R4 $R4 '"' ''
		${If} $R4 != ""
			MessageBox MB_OK "3-UninstallComponents (R4): $R4"
			${unStrStr} $R2 $R4 "$0"
			${If} $R2 != ""
				RMDir /r "$R4"
				Push "$R4"
				Call un.RemoveFromEnvUserPath
				Push "$R4"
				Call un.RemoveFromComponentsIni
			${EndIf}
			;${If} $unToolsCheckboxState == "1"
			;${AndIf} $0 == "Tools"
			;${If} $0 == "Tools"
			;	${unStrStr} $R2 $R4 "$InstDrive${TOOLS}"
			;	${If} $R2 != ""
			;		RMDir /r "$R4"
			;		Push "$R4"
			;		Call un.RemoveFromEnvUserPath
			;	${EndIf}
			;${EndIf}
			;${If} $unVendorCheckboxState == "1"
			;${AndIf} $0 == "Vendor"
			;${ElseIf} $0 == "Vendor"
			;	${unStrStr} $R2 $R4 "$InstDrive${VENDOR}"
			;	${If} $R2 != ""
			;		RMDir /r "$R4"
			;		Push "$R4"
			;		Call un.RemoveFromEnvUserPath
			;	${EndIf}
			;${EndIf}
			;${If} $unResourcesCheckboxState == "1"
			;${AndIf} $0 == "Resources"
			;${ElseIf} $0 == "Resources"
			;	${unStrStr} $R2 $R4 "${RESOURCES}"
			;	${If} $R2 != ""
			;		RMDir /r "$R4"
			;		Push "$R4"
			;		Call un.RemoveFromEnvUserPath
			;	${EndIf}
			;${EndIf}
		${EndIf}
		Goto LoopRead
	${EndIf}
	Goto LoopRead
CloseFile:
	FileClose $R0
EndUninstall:
	Pop $R4
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
