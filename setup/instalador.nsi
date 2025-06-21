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
Var FtpUser
Var FtpPass
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
Var ToolsCatalog
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox

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
; TEXTOS DE LA INTERFAZ
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
	${GetTime} "" "L" $Day $Month $Year $R3 $Hour $Min $Sec
	IntFmt $Year "%04d" $Year
	IntFmt $Month "%02d" $Month
	IntFmt $Day "%02d" $Day
	IntFmt $Hour "%02d" $Hour
	IntFmt $Min "%02d" $Min
	StrCpy  $Timestamp "$Year$Month$Day-$Hour$Min"
FunctionEnd

Function GetConfigValues
	StrCpy $IsUpdateInstall "0"
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	${If} $0 != ""
		StrCpy $INSTDIR $0
		StrCpy $IsUpdateInstall "1"
		ReadRegStr $InstDrive HKCU "Software\${NAME}" "Install_Drive"
		ReadRegStr $SkipPrereq HKCU "Software\${NAME}" "SkipPrereq"
		ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
		ReadRegStr $Server HKCU "Software\${NAME}" "Server"
		ReadRegStr $FtpUser HKCU "Software\${NAME}" "FtpUser"
		ReadRegStr $FtpPass HKCU "Software\${NAME}" "FtpPass"
		ReadRegStr $Protocol HKCU "Software\${NAME}" "Protocol"
		ReadRegStr $Version HKCU "${HKCUNI}" "DisplayVersion"
	${Else}
		StrCpy $InstDrive $EXEPATH 2
		StrCpy $Version ${RELEASE}
		StrCpy $SkipPrereq "0"
		StrCpy $RememberCreds "0"
	${EndIf}
	;TODO: Temporal
	StrCpy $Server "masexperto.cl"
	StrCpy $Protocol "HTTP"
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
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	Call un.JsonLoadCatalog
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

;--------------------------------
; SECCIONES

!include "secciones.nsh"

Section "Uninstall"
	Delete "$INSTDIR\*.*"
	Delete "$INSTDIR\${CATALOGFILE}"
	Delete "$INSTDIR\${UNINSTALLER}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$DESKTOP\${INSTALLER_NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk"
	RMDir /r "$SMPROGRAMS\${NAME}"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$PluginsDir"
	RMDir /r "$INSTDIR"
	StrCmp $unToolsCheckboxState "1" 0 Done
	!insertmacro MUninstallTools
	Push "$InstDrive${TOOLS}"
	Call un.RemoveDirIfEmpty
	RMDir /r "$InstDrive${VENDOR}"
Done:
	RMDir /r "$InstDrive${APPDIR}"
SectionEnd
