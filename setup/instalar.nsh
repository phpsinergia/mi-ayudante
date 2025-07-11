; instalar.nsi
;================================
; MODULO: INSTALAR
;================================

;--------------------------------
; FUNCIONES
;--------------------------------

Function .onInit
	InitPluginsDir
	SetOutPath "$PluginsDir"
	File /oname=favicon.ico "..\app\${ICON}"
	File /oname=ok.bmp "ok.bmp"
	File /oname=no.bmp "no.bmp"
	Call GetConfigValues
	${If} $IsUpdateInstall == "1"
		StrCpy $TextCaption "$(TXT_VentanaActualizador)"
		StrCpy $TitleWelcome "$(TXT_TituloWelcomeActualizador)"
		StrCpy $TextWelcome "$(TXT_InstruccionesWelcomeActualizador)"
		StrCpy $TitleFinish "$(TXT_TituloFinishActualizador)"
		StrCpy $TextFinish "$(TXT_InstruccionesFinishActualizador)"
	${Else}
		StrCpy $TextCaption "$(TXT_VentanaInstalador)"
		StrCpy $TitleWelcome "$(TXT_TituloWelcomeInstalador)"
		StrCpy $TextWelcome "$(TXT_InstruccionesWelcomeInstalador)"
		StrCpy $TitleFinish "$(TXT_TituloFinishInstalador)"
		StrCpy $TextFinish "$(TXT_InstruccionesFinishInstalador)"
	${EndIf}
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	Call DetectPHP
	Call DetectComposer
	Call DetectMSVC
	Call DetectNotepad
FunctionEnd

Function SetDateTimeStamp
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

Function GetConfigValues
	Push $0
	StrCpy $IsUpdateInstall "0"
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	${If} $0 != ""
		StrCpy $INSTDIR $0
		StrCpy $IsUpdateInstall "1"
		ReadRegStr $Version HKCU "${HKCUNI}" "DisplayVersion"
		ReadRegStr $InstDrive HKCU "Software\${NAME}" "Install_Drive"
		ReadRegStr $SkipPrereq HKCU "Software\${NAME}" "SkipPrereq"
		ReadRegStr $SkipConfirm HKCU "Software\${NAME}" "SkipConfirm"
		ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
		ReadRegStr $ShortcutStartMenu HKCU "Software\${NAME}" "ShortcutStartMenu"
		ReadRegStr $ShortcutDesktop HKCU "Software\${NAME}" "ShortcutDesktop"
		ReadRegStr $ShortcutUpdater HKCU "Software\${NAME}" "ShortcutUpdater"
		ReadRegStr $ShortcutWindowsStart HKCU "Software\${NAME}" "ShortcutWindowsStart"
		ReadRegStr $Server HKCU "Software\${NAME}" "Server"
		ReadRegStr $Protocol HKCU "Software\${NAME}" "Protocol"
		ReadRegStr $User HKCU "Software\${NAME}" "User"
		ReadRegStr $EncPass HKCU "Software\${NAME}" "Pass"
		${If} $EncPass != ""
			Call DecryptPw
		${EndIf}
	${Else}
		StrCpy $InstDrive $EXEPATH 2
		StrCpy $Version ${RELEASE}
		StrCpy $SkipPrereq "0"
		StrCpy $SkipConfirm "0"
		StrCpy $RememberCreds "0"
		StrCpy $ShortcutStartMenu "1"
		StrCpy $ShortcutDesktop "1"
		StrCpy $ShortcutUpdater "1"
		StrCpy $ShortcutWindowsStart "0"
	${EndIf}
	Pop $0
FunctionEnd

Function SkipIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
FunctionEnd

Function LaunchApp
	${If} ${FileExists} "$InstDrive$INSTDIR\${APPFILE}"
		ExecShell "" '"$InstDrive$INSTDIR\${APPFILE}"'
		Return
	${Else}
		MessageBox MB_ICONSTOP "$(TXT_MsgExeNoEncontrado)"
	${EndIf}
FunctionEnd

Function RunUninstaller
	Push $0
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "$(TXT_MsgConfirmaDesinstalacion)" IDNO EndAsk
		StrCpy $0 "$InstDrive$INSTDIR\${UNINSTALLER}"
		IfFileExists "$0" 0 NoUninst
		HideWindow
		ExecShell "open" "$0"
		Sleep 100
		System::Call 'kernel32::ExitProcess(i0)'
NoUninst:
	MessageBox MB_ICONSTOP "$(TXT_MsgUninstallNoEncontrado)$\n$0"
EndAsk:
	Pop $0
FunctionEnd

Function EncryptPw
	Push $0
	Push $1
	Push $2
	Push $3
	Push $4
	StrCpy $1 "$PluginsDir\pw.txt"
	Delete $1
	FileOpen $2 $1 "w"
	FileWrite $2 "$Pass"
	FileClose $2
	StrCpy $3 "$PluginsDir\pw.b64"
	Delete $3
	nsExec::ExecToStack 'CertUtil -f -encode "$1" "$3"'
	Pop $4
	Pop $4
	StrCpy $4 ""
	FileOpen $2 $3 "r"
	${Do}
		FileRead $2 $1
		${IfThen} '$1' == "" ${|} ${Break} ${|}
		StrCpy $1 $1 -2
		${If} $1 == "-----BEGIN CERTIFICATE-----"
		${OrIf} $1 == "-----END CERTIFICATE-----"
		${OrIf} $1 == ""
		${Else}
			StrCpy $4 "$4$1"
		${EndIf}
	${Loop}
	FileClose $2
	Delete "$PluginsDir\pw.txt"
	Delete "$PluginsDir\pw.b64"
	StrCpy $EncPass $4
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function DecryptPw
	Push $0
	Push $1
	Push $2
	Push $3
	Push $4
	Push $5
	Push $6
	StrCpy $1 "$PluginsDir\pw.b64"
	Delete $1
	FileOpen $2 $1 "w"
	FileWrite $2 "-----BEGIN CERTIFICATE-----$\r$\n"
	StrLen $3 $EncPass
	StrCpy $4 0
	${While} $4 < $3
		StrCpy $5 $EncPass 64 $4
		FileWrite $2 "$5$\r$\n"
		IntOp $4 $4 + 64
	${EndWhile}
	FileWrite $2 "-----END CERTIFICATE-----$\r$\n"
	FileClose $2
	StrCpy $6 "$PluginsDir\pw.txt"
	Delete $6
	nsExec::ExecToStack 'CertUtil -f -decode "$1" "$6"'
	Pop $5
	Pop $5
	FileOpen $2 $6 "r"
	FileRead $2 $5
	FileClose $2
	Delete "$PluginsDir\pw.b64"
	Delete "$PluginsDir\pw.txt"
	StrCpy $Pass $5
	Pop $6
	Pop $5
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd
