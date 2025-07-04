; instalador.nsi
;================================
; INSTALADOR DE MI-AYUDANTE
;================================

;--------------------------------
; INCLUDES
;--------------------------------
!include "MUI2.nsh"
!include "x64.nsh"
!include "LogicLib.nsh"
!include "FileFunc.nsh"
!include "nsDialogs.nsh"
!include "Sections.nsh"
!include "WinMessages.nsh"
!include "StrFunc.nsh"
!include "nsArray.nsh"
!include "WordFunc.nsh"

;--------------------------------
; VARIABLES GLOBALES
;--------------------------------
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
Var SkipConfirm
Var RememberCreds
Var ShortcutStartMenu
Var ShortcutDesktop
Var ShortcutUpdater
Var ShortcutWindowsStart
Var LogFile
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox
Var unVendorCheckboxState
Var unVendorCheckbox
Var unResourcesCheckboxState
Var unResourcesCheckbox
Var EncPass
Var StartUpDir

;--------------------------------
; CONSTANTES
;--------------------------------
!define NAME "Mi Ayudante"
!define RELEASE "1.0.0"
!define PUBLISHER "Rubén Araya Tagle"
;--------------------------------
!define INSTALLER_VERSION "0.0.0.1"
!define INSTALLER_NAME "Actualizador"
!define INSTALLER "..\dist\Instalar-MiAyudante.exe"
!define UNINSTALLER "Desinstalar.exe"
!define DESCRIPTION "${INSTALLER_NAME} ${NAME}"
!define RESOURCES "$DOCUMENTS\MiAyudante"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define APPDIR "\home\mi-ayudante"
!define APPFILE "ayudante.exe"
!define LICENSEFILE "LICENSE"
!define CATALOGFILE "catalogo.json"
!define READMEFILE "LEEME.txt"
!define ICON "img\favicon.ico"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define SEPARATOR "============================================"
!define LANG_SPANISH 1034

;--------------------------------
; CONFIGURACION GENERAL
;--------------------------------
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
; DEFINICIONES MUI
;--------------------------------
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
; PAGINAS DEL ASISTENTE (8 + 3)
;--------------------------------
!insertmacro MUI_PAGE_WELCOME
!define MUI_PAGE_CUSTOMFUNCTION_PRE SkipIfUpdate
!insertmacro MUI_PAGE_LICENSE "..\${LICENSEFILE}"
Page custom ShowOptionsForm LeaveOptionsForm " "
Page custom ShowConfirmInstall LeaveConfirmInstall " "
Page custom ShowPreRequisites LeavePreRequisites " "
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckAllComponents
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
;--------------------------------
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ShowOptionsUninstall un.ReadChoiceUninstall
!insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
; TEXTOS INTERFAZ DE USUARIO
;--------------------------------
!insertmacro MUI_LANGUAGE "Spanish"
!include "txt_spanish.nsh"

;--------------------------------
; MACROS DE EXTENSIONES
;--------------------------------
${StrTrimNewLines}
${StrRep}
${StrStr}
${StrCase}
${StrTok}
${unStrTrimNewLines}
${unStrRep}
${unStrStr}
!insertmacro GetTime
!insertmacro WordFind

;--------------------------------
; FUNCIONES: INSTALACIÓN
;--------------------------------

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
	SetOutPath "$PluginsDir"
	File /oname=ok.bmp "ok.bmp"
	File /oname=no.bmp "no.bmp"
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

!include "opciones.nsh"
!include "prereqs.nsh"
!include "componentes.nsh"
!include "confirmacion.nsh"
!include "registro.nsh"

;--------------------------------
; FUNCIONES: DESINSTALACIÓN
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
; MACROS: DESINSTALACIÓN
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
; SECCIONES
;--------------------------------

Section "-Inicial" 0
	Call WriteLogInicial
SectionEnd

Section "!${NAME} (*)" 1
	Call WriteLogBase
	CreateDirectory "$InstDrive$INSTDIR\compartidos"
	CreateDirectory "$InstDrive$INSTDIR\datos"
	CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
	CreateDirectory "$InstDrive$INSTDIR\logs"
	CreateDirectory "$InstDrive$INSTDIR\respaldos"
	CreateDirectory "$InstDrive$INSTDIR\extensiones"
	CreateDirectory "$InstDrive${TOOLS}"
	CreateDirectory "$InstDrive${VENDOR}"
	CreateDirectory "${RESOURCES}"
	SetOutPath "$InstDrive$INSTDIR\base"
	File /r "..\app\base\*.*"
	SetOutPath "$InstDrive$INSTDIR\img"
	File /r "..\app\img\*.*"
	SetOutPath "$InstDrive$INSTDIR"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${APPFILE}"
		File "..\app\${APPFILE}"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${READMEFILE}"
		File "..\app\${READMEFILE}"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${LICENSEFILE}"
		File /oname=LICENSE.txt "..\${LICENSEFILE}"
	${EndIf}
	SetOutPath "$InstDrive$INSTDIR\datos"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\datos\basico_proyectos.txt"
		File /oname=basico_proyectos.txt "..\app\base\proyectos.txt"
	${EndIf}
	SetOutPath "$InstDrive$INSTDIR\entornos\basico"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\entornos\basico\config.ini"
		File /r "..\app\base\entorno\*.*"
	${EndIf}
	SetOutPath "$InstDrive$INSTDIR"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\config.ini"
		File "config.ini"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\componentes.ini"
		File "componentes.ini"
	${EndIf}
SectionEnd

!include "secciones.nsh"

Section "-"
	Call WriteLogConfig
SectionEnd

Section "-Config"
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	${GetSize} "$InstDrive\home" "/S=0K" $R1 $R2 $R3
	DetailPrint "$R1 KB"
	IntFmt $R1 "0x%08X" $R1
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$R1"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$InstDrive"
	WriteRegStr HKCU "Software\${NAME}" "Server" "$Server"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$Protocol"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
	WriteRegStr HKCU "Software\${NAME}" "SkipConfirm" "$SkipConfirm"
	WriteRegStr HKCU "Software\${NAME}" "VendorPath" "$InstDrive${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "ToolsPath" "$InstDrive${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "ResourcesPath" "${RESOURCES}"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutStartMenu" "$ShortcutStartMenu"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutDesktop" "$ShortcutDesktop"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutUpdater" "$ShortcutUpdater"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutWindowsStart" "$ShortcutWindowsStart"
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
	StrCpy $User ""
	StrCpy $Pass ""
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$InstDrive$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALLER}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALLER}"
	SetOutPath "$InstDrive$INSTDIR"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogPostInstall)"
	${If} $ShortcutStartMenu == "1"
		CreateDirectory "$SMPROGRAMS\${NAME}"
		CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
		CreateShortCut "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutDesktop == "1"
		CreateShortCut "$DESKTOP\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutUpdater == "1"
		CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutWindowsStart == "1"
		StrCpy $StartUpDir "$APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
		CreateDirectory $StartUpDir
		CreateShortCut "$StartUpDir\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}" "" SW_SHOWMINIMIZED
	${EndIf}
	;TODO: Quitar al cambiar el Programa
		WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
SectionEnd

Section "-Final"
	Call WriteLogFinal
SectionEnd

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
