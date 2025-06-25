;--------------------------------
; INSTALADOR DE MI-AYUDANTE
;--------------------------------

;--------------------------------
; INCLUDES
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "nsDialogs.nsh"
!include "Sections.nsh"
!include "WinMessages.nsh"
!include "StrFunc.nsh"
!include "nsArray.nsh"
!include "WordFunc.nsh"

;--------------------------------
; DEFINICIONES BÁSICAS
!define NAME "Mi Ayudante"
!define RELEASE "1.0.0"
!define INSTALLER_VERSION "0.0.0.1"
!define INSTALLER_NAME "Actualizador"
!define INSTALLER "..\dist\Instalar-MiAyudante.exe"
!define UNINSTALLER "Desinstalar.exe"
!define DESCRIPTION "${INSTALLER_NAME} ${NAME}"
!define RESOURCES "$DOCUMENTS\MiAyudante"
!define PUBLISHER "Rubén Araya Tagle"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define APPDIR "\home\mi-ayudante"
!define APPFILE "ayudante.exe"
!define LICENSEFILE "LICENSE"
!define CATALOGFILE "catalogo.json"
!define READMEFILE "LEEME.txt"
!define ICON "img\favicon.ico"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define LANG_SPANISH 1034
!define SEPARATOR "============================================"
!define MAX_COMPONENTES 20
!define SEC_PROGRAMA 1
!define SEC_RELEASE 4

;--------------------------------
; VARIABLES GLOBALES
Var Version
Var InstDrive
Var Server
Var User
Var Pass
Var Protocol
Var Timestamp
Var Year
Var Month
Var Day
Var Hour
Var Min
Var Sec
Var IsUpdateInstall
Var SkipPrereq
Var RememberCreds
Var LogFile
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox
Var EncPass
Var StartUpDir

;--------------------------------
; DEFINICIONES MUI
!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE $TitleWelcome
!define MUI_WELCOMEPAGE_TEXT $TextWelcome
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_HEADERIMAGE_BITMAP "head.bmp"
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "$(TXT_InstruccionesComponentes)"
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "$(TXT_TituloInstFinalizada)"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "$(TXT_SubtituloInstCompletada)"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "$(TXT_TituloInstCancelada)"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "$(TXT_SubtituloInstCancelada)"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_TEXT "$(TXT_EtiqEjecutarApp)"
!define MUI_FINISHPAGE_TITLE $TitleFinish
!define MUI_FINISHPAGE_TEXT $TextFinish
!define MUI_FINISHPAGE_LINK "$(TXT_EtiqVerRegistro)"
!define MUI_FINISHPAGE_LINK_LOCATION "$LogFile"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\${READMEFILE}"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "$(TXT_EtiqRevisarNotas)"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TEXT_LARGE
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

;--------------------------------
; CONFIGURACION GENERAL
Unicode true
Name "${NAME}"
OutFile "${INSTALLER}"
InstallDir "${APPDIR}"
InstallDirRegKey HKCU "Software\${NAME}" "Install_Dir"
BrandingText " "
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show
AllowSkipFiles on
SetCompressor lzma
Caption $TextCaption
;--------------------------------
VIProductVersion ${INSTALLER_VERSION}
VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "${DESCRIPTION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" ${INSTALLER_VERSION}
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductVersion" "${RELEASE}"
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "${NAME}"
VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "${PUBLISHER}"

;--------------------------------
; MACROS
${StrTrimNewLines}
${StrRep}
${StrStr}
${StrCase}
${unStrTrimNewLines}
${unStrRep}
${unStrStr}
!insertmacro GetTime
!insertmacro WordFind

!macro MUninstallAllComponents
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	StrCpy $R2 "$PluginsDir\componentes.ini"
	IfFileExists "$R2" 0 EndMacro
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
			RMDir /r "$R4"
			Push "$R4"
			Call un.RemoveFromEnvUserPath
		${EndIf}
		Goto LoopRead
	${EndIf}
	Goto LoopRead
CloseFile:
	FileClose $R0
EndMacro:
	Pop $R5
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

;--------------------------------
; PAGINAS
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipIfUpdate
!insertmacro MUI_PAGE_LICENSE "..\${LICENSEFILE}"
Page custom ShowOptionsForm SaveOptionsForm " "
Page custom CheckPreRequisites LeavePreRequisites " "
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckAllComponents
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ShowOptionsUninstall un.ReadChoiceUninstall
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; TEXTOS DE INTERFAZ
!insertmacro MUI_LANGUAGE "Spanish"
!include "idioma_es.nsh"

;--------------------------------
; FUNCIONES: INSTALACIÓN

Function .onInit
	InitPluginsDir
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
FunctionEnd

Function SetDateTimeStamp
	${GetTime} "" "L" $Day $Month $Year $1 $Hour $Min $Sec
	IntFmt $Year "%04d" $Year
	IntFmt $Month "%02d" $Month
	IntFmt $Day "%02d" $Day
	IntFmt $Hour "%02d" $Hour
	IntFmt $Min "%02d" $Min
	StrCpy $Timestamp "$Year$Month$Day-$Hour$Min"
FunctionEnd

Function GetConfigValues
	StrCpy $IsUpdateInstall "0"
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	${If} $0 != ""
		StrCpy $INSTDIR $0
		StrCpy $IsUpdateInstall "1"
		ReadRegStr $Version HKCU "${HKCUNI}" "DisplayVersion"
		ReadRegStr $InstDrive HKCU "Software\${NAME}" "Install_Drive"
		ReadRegStr $SkipPrereq HKCU "Software\${NAME}" "SkipPrereq"
		ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
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
		StrCpy $RememberCreds "0"
	${EndIf}

	;TODO: Sólo para pruebas, quitar al terminar
	;StrCpy $Server "masexperto.com"
	;StrCpy $Protocol "FTP"
	StrCpy $SkipPrereq "1"
	StrCpy $InstDrive "D:"

FunctionEnd

Function SkipIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
FunctionEnd

Function LaunchApp
	IfFileExists "$InstDrive$INSTDIR\${APPFILE}" 0 +3
		ExecShell "" '"$InstDrive$INSTDIR\${APPFILE}"'
		Return
	MessageBox MB_ICONSTOP "$(TXT_MsgExeNoEncontrado)"
FunctionEnd

Function RunUninstaller
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "$(TXT_MsgConfirmaDesinstalacion)" IDNO EndAsk
		StrCpy $0 "$InstDrive$INSTDIR\${UNINSTALLER}"
		IfFileExists "$0" 0 NoUninst
		Exec '"$0"'
		Quit
NoUninst:
	MessageBox MB_ICONSTOP "$(TXT_MsgUniNoEncontrado)$\n$0"
EndAsk:
FunctionEnd

!include "opciones.nsh"
!include "prereqs.nsh"
!include "componentes.nsh"
!include "logs.nsh"

;--------------------------------
Function AddToEnvUserPath
	Exch $0
	Push $1
	Push $2
	Push $3
	${StrTrimNewLines} $0 $0
	${StrRep} $0 $0 '"' ''
	${If} $0 == ""
		Goto EndAdd
	${EndIf}
	ReadRegStr $1 HKCU "Environment" "Path"
	StrCpy $2 ";$1;"
	StrCpy $3 ";$0;"
	${StrCase} $2 $2 U
	${StrCase} $3 $3 U
	${StrStr} $2 $2 $3
	${If} $2 != ""
		Goto CleanAndSave
	${EndIf}
	StrLen $2 $1
	${If} $2 > 0
		IntOp $2 $2 - 1
		StrCpy $3 $1 1 $2
	${Else}
		StrCpy $3 ""
	${EndIf}
	${If} $3 == ";"
		StrCpy $1 "$1$0"
	${ElseIf} $1 == ""
		StrCpy $1 "$0"
	${Else}
		StrCpy $1 "$1;$0"
	${EndIf}
CleanAndSave:
LoopClean:
	${StrStr} $2 $1 ";;"
	${If} $2 == ""
		Goto WriteAndBroadcast
	${EndIf}
	${StrRep} $1 $1 ";;" ";"
	Goto LoopClean
WriteAndBroadcast:
	DetailPrint "$(TXT_LogAddPath) $0"
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndAdd:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function DownloadSinglePack
	${If} $ToolId == ""
		Goto SkipTool
	${EndIf}
	Call DownloadFile
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Call VerifySha256
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Call ExtractZip
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Push "OK"
	Return
SkipTool:
	Push "NO"
FunctionEnd

Function DownloadFile
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/$ToolId.zip"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgDescargando) $R0"
		nsExec::ExecToStack '"curl.exe" -u $User@$Server:$Pass "$R0" -o "$PluginsDir\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "$(TXT_MsgErrorDescargaFtp) $ToolId$\n$R2"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipDownload
		${EndIf}
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/$ToolId.zip"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgDescargando) $R0"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$PluginsDir\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 == "0"
			Goto SuccessDownload
		${Else}
			StrCpy $LogMsg "$(TXT_MsgErrorDescargaHttp) $ToolId$\n$(TXT_CodigoRespuesta) $R1"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipDownload
		${EndIf}
	${Else}
		Goto SkipDownload
	${EndIf}
SuccessDownload:
	Push "OK"
	Return
SkipDownload:
	Push "NO"
FunctionEnd

Function VerifySha256
	DetailPrint "$(TXT_MsgVerificando) $ToolName ($ToolId.zip)"
	nsExec::ExecToStack 'CertUtil -hashfile "$PluginsDir\$ToolId.zip" SHA256'
	Pop $0
	Pop $1
	StrCmp $0 0 +5
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipVerify
	${If} $1 != ""
	${AndIf} $ToolHash != ""
		${WordFind} "$1" "$ToolHash" "+1" $2
		${If} $2 != ""
			DetailPrint "$(TXT_MsgHashValidado) $ToolHash"
			Goto SuccessVerify
		${Else}
			StrCpy $LogMsg "$(TXT_MsgErrorHashNoCoincide) $ToolId.zip$\n$2 ≠ $ToolHash"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONSTOP "$LogMsg"
			Goto SkipVerify
		${EndIf}
	${Else}
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipVerify
	${EndIf}
SuccessVerify:
	Push "OK"
	Return
SkipVerify:
	Push "NO"
FunctionEnd

Function ExtractZip
	DetailPrint "..."
	StrCpy $ToolTempDir "$PluginsDir\$ToolId_tmp"
	RMDir /r "$ToolTempDir"
	CreateDirectory "$ToolTempDir"
	SetOutPath "$ToolTempDir"
	Nsisunz::UnzipToLog "$PluginsDir\$ToolId.zip" "$ToolTempDir"
	Pop $R1
	${If} $R1 != "success"
		StrCpy $LogMsg "$(TXT_MsgErrorDescomprimir) $ToolName: $R1"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipExtract
	${EndIf}
	${GetSize} "$ToolTempDir" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolSizeKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 +2
		Goto SuccessExtract
	StrCpy $LogMsg "$(TXT_MsgErrorTamano) $ToolName ($R4 KB ≠ $ToolSizeKb KB)"
	DetailPrint "$LogMsg"
	MessageBox MB_ICONEXCLAMATION "$LogMsg"
	Goto SkipExtract
SuccessExtract:
	Push "OK"
	Return
SkipExtract:
	Push "NO"
FunctionEnd

Function EncryptPw
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
FunctionEnd

Function DecryptPw
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
FunctionEnd

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	InitPluginsDir
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "$(TXT_EtiqDesinstalarHerramientas)"
	Pop $0
	${NSD_CreateCheckbox} 0 16u 100% 12u "$(TXT_EtiqRemoverTodas)"
	Pop $unToolsCheckbox
	nsDialogs::Show
FunctionEnd

Function un.ReadChoiceUninstall
	${NSD_GetState} $unToolsCheckbox $unToolsCheckboxState
FunctionEnd

Function un.RemoveDirIfEmpty
	Exch $0
	IfFileExists "$0\*\*.*" 0 +2
		Return
	RMDir "$0"
FunctionEnd

Function un.RemoveFromEnvUserPath
	Exch $0
	Push $1
	Push $2
	Push $3
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
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

;--------------------------------
; SECCIONES

Section "-Inicial" 0
	Call WriteLogInicial
SectionEnd

Section "!${NAME} (*)" 1
	Call WriteLogPrograma
	CreateDirectory "$InstDrive$INSTDIR\compartidos"
	CreateDirectory "$InstDrive$INSTDIR\datos"
	CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
	CreateDirectory "$InstDrive$INSTDIR\logs"
	CreateDirectory "$InstDrive$INSTDIR\respaldos"
	CreateDirectory "$InstDrive$INSTDIR\extensiones"
	CreateDirectory "$InstDrive${TOOLS}"
	CreateDirectory "$InstDrive${RESOURCES}"
	CreateDirectory "$InstDrive${VENDOR}"
	SetOutPath "$InstDrive$INSTDIR\base"
	File /r "..\app\base\*.*"
	SetOutPath "$InstDrive$INSTDIR\img"
	File /r "..\app\img\*.*"
	SetOutPath "$InstDrive$INSTDIR"
	IfFileExists "$InstDrive$INSTDIR\${APPFILE}" +2 0
		File "..\app\${APPFILE}"
	IfFileExists "$InstDrive$INSTDIR\${READMEFILE}" +2 0
		File "..\app\${READMEFILE}"
	IfFileExists "$InstDrive$INSTDIR\${LICENSEFILE}" +2 0
		File /oname=LICENSE.txt "..\${LICENSEFILE}"
	SetOutPath "$InstDrive$INSTDIR\datos"
	IfFileExists "$InstDrive$INSTDIR\datos\basico_proyectos.txt" +2 0
		File /oname=basico_proyectos.txt "..\app\base\proyectos.txt"
	SetOutPath "$InstDrive$INSTDIR\entornos\basico"
	IfFileExists "$InstDrive$INSTDIR\entornos\basico\config.ini" +2 0
		File /r "..\app\base\entorno\*.*"
	SetOutPath "$InstDrive${TOOLS}"
	SetOutPath "$InstDrive$INSTDIR"
	IfFileExists "$InstDrive$INSTDIR\config.ini" +2 0
		File "config.ini"
		File "componentes.ini"
SectionEnd

!include "secciones.nsh"

Section "-"
	Call WriteLogConfig
SectionEnd

Section "-Config"
	${GetSize} "$InstDrive\home" "/S=0K" $1 $R7 $R8
	DetailPrint "$1 KB"
	IntFmt $1 "0x%08X" $1
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$InstDrive"
	WriteRegStr HKCU "Software\${NAME}" "Server" "$Server"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$Protocol"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
	WriteRegStr HKCU "Software\${NAME}" "VendorPath" "$InstDrive${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "ToolsPath" "$InstDrive${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	WriteRegStr HKCU "Software\${NAME}" "Installer" "$EXEPATH"
	${If} $RememberCreds == "1"
		${If} $Pass != ""
			Call EncryptPw
			WriteRegStr HKCU "Software\${NAME}" "Pass" "$EncPass"
		${EndIf}
		WriteRegStr HKCU "Software\${NAME}" "User" "$User"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "User"
		DeleteRegValue HKCU "Software\${NAME}" "Pass"
	${EndIf}
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$InstDrive$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALLER}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
	WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	StrCpy $User ""
	StrCpy $Pass ""
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALLER}"
	DetailPrint "$(TXT_LogCreateShortCut)"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	SetOutPath "$InstDrive$INSTDIR"
	CreateShortCut "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	CreateDirectory $StartUpDir
	CreateShortCut "$StartUpDir\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}" "" SW_SHOWMINIMIZED
SectionEnd

Section "-Final"
	Call WriteLogFinal
SectionEnd

Section "Uninstall"
	CopyFiles /SILENT /FILESONLY "$INSTDIR\componentes.ini" "$PluginsDir\"
	StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
	Delete "$INSTDIR\*.*"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$DESKTOP\${INSTALLER_NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
	Delete "$StartUpDir\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk"
	RMDir /r "$SMPROGRAMS\${NAME}"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$PluginsDir"
	RMDir /r "$INSTDIR"
	StrCmp $unToolsCheckboxState "1" 0 Done
	!insertmacro MUninstallAllComponents
	Push "$InstDrive${TOOLS}"
	Call un.RemoveDirIfEmpty
	Push "${RESOURCES}"
	Call un.RemoveDirIfEmpty
	RMDir /r "$InstDrive${VENDOR}"
Done:
	RMDir /r "$InstDrive${APPDIR}"
SectionEnd
