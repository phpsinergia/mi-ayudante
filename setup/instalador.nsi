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
!define RELEASE "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Rubén Araya Tagle"
!define TARGET "\home\mi-ayudante"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define APPFILE "ayudante.exe"
!define LICENSEFILE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"
!define UNINSTALL "Desinstalar.exe"
!define INSTALL "..\dist\Instalar-MiAyudante.exe"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

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
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox
Var LogFile
Var ToolsCatalog

;--------------------------------
; TEXTOS DE LA INTERFAZ
!include "idioma_es.nsh"

;--------------------------------
; DEFINICIONES MUI
!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE $TitleWelcome
!define MUI_WELCOMEPAGE_TEXT $TextWelcome
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_TEXT "${TXT_EtiqEjecutarApp}"
!define MUI_FINISHPAGE_TITLE $TitleFinish
!define MUI_FINISHPAGE_TEXT $TextFinish
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_HEADERIMAGE_BITMAP "head.bmp"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "${TXT_InstruccionesComponentes}"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TEXT_LARGE
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "${TXT_TituloInstFinalizada}"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "${TXT_SubtituloInstCompletada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "${TXT_TituloInstCancelada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "${TXT_SubtituloInstCancelada}"
!define MUI_FINISHPAGE_LINK "${TXT_EtiqVerRegistro}"
!define MUI_FINISHPAGE_LINK_LOCATION "$LogFile"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\${README}"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "${TXT_EtiqRevisarNotas}"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

;--------------------------------
; CONFIGURACION GENERAL
Unicode true
Name "${NAME}"
OutFile "${INSTALL}"
InstallDir "${TARGET}"
InstallDirRegKey HKCU "Software\${NAME}" "Install_Dir"
BrandingText " "
RequestExecutionLevel user
ShowInstDetails show
ShowUninstDetails show
AllowSkipFiles on
SetCompressor lzma
Caption $TextCaption
VIProductVersion ${RELEASE}.0
VIAddVersionKey /LANG=0 "ProductVersion" "${RELEASE}"
VIAddVersionKey /LANG=0 "FileVersion" ${RELEASE}
VIAddVersionKey /LANG=0 "ProductName" "${NAME}"
VIAddVersionKey /LANG=0 "FileDescription" "${TXT_DescripcionArchivo}"
VIAddVersionKey /LANG=0 "LegalCopyright" "${PUBLISHER}"

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
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES: INSTALACIÓN

Function .onInit
	Call SetDateTimeStamp
	Call GetEnvValues
	${If} $IsUpdateInstall == "1"
		StrCpy $LogFile "$INSTDIR\logs\actualizacion_$Timestamp.log"
		StrCpy $TextCaption "${TXT_VentanaActualizador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeActualizador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeActualizador}"
		StrCpy $TitleFinish "${TXT_TituloFinishActualizador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishActualizador}"
	${Else}
		StrCpy $LogFile "$INSTDIR\logs\instalacion_$Timestamp.log"
		StrCpy $TextCaption "${TXT_VentanaInstalador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeInstalador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeInstalador}"
		StrCpy $TitleFinish "${TXT_TituloFinishInstalador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishInstalador}"
	${EndIf}
FunctionEnd

Function SetDateTimeStamp
	${GetTime} "" "L" $Day $Month $Year $R3 $Hour $Min $Sec
	IntFmt $Year "%04d" $Year
	IntFmt $Month "%02d" $Month
	IntFmt $Day "%02d" $Day
	IntFmt $Hour "%02d" $Hour
	IntFmt $Min "%02d" $Min
	StrCpy  $Timestamp "$Year$Month$Day$Hour$Min"
FunctionEnd

Function GetEnvValues
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
	MessageBox MB_ICONSTOP "${TXT_MsgExeNoEncontrado}"
FunctionEnd

Function RunUninstaller
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "${TXT_MsgConfirmaDesinstalacion}" IDNO EndAsk
		StrCpy $0 "$InstDrive$INSTDIR\${UNINSTALL}"
		IfFileExists "$0" 0 NoUninst
		Exec '"$0"'
		Quit
NoUninst:
	MessageBox MB_ICONSTOP "${TXT_MsgUniNoEncontrado}$\n$0"
EndAsk:
FunctionEnd

!include "logs.nsh"
!include "opciones.nsh"
!include "prereqs.nsh"
!include "componentes.nsh"

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $InstDrive $0
	CopyFiles /SILENT /FILESONLY "$INSTDIR\catalogo.json" "$TEMP\catalogo.json"
	StrCpy $ToolsCatalog "$TEMP\catalogo.json"
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "${TXT_EtiqDesinstalarHerramientas}"
	Pop $0
	${NSD_CreateCheckbox} 0 16u 100% 12u "${TXT_EtiqRemoverTodas}"
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

Section "-WriteLog: Inicial" 0
	Call WriteLogInicial
SectionEnd

SectionGroup /e "${TXT_SecPrograma}" 1
	Section "${NAME} (*)" 2
		DetailPrint "============================================"
		DetailPrint "${TXT_LogSecPrograma}"
		CreateDirectory "$InstDrive$INSTDIR\compartidos"
		CreateDirectory "$InstDrive$INSTDIR\datos"
		CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
		CreateDirectory "$InstDrive$INSTDIR\logs"
		CreateDirectory "$InstDrive$INSTDIR\respaldos"
		CreateDirectory "$InstDrive${TOOLS}"
		SetOutPath "$InstDrive$INSTDIR\base"
		File /r "..\app\base\*.*"
		SetOutPath "$InstDrive$INSTDIR\img"
		File /r "..\app\img\*.*"
		SetOutPath "$InstDrive$INSTDIR"
		IfFileExists "$InstDrive$INSTDIR\${APPFILE}" +2 0
			File "..\app\${APPFILE}"
		IfFileExists "$InstDrive$INSTDIR\${README}" +2 0
			File "..\app\${README}"
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
		WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
		DetailPrint "============================================"
	SectionEnd
	!insertmacro CreateSectionActualizacion 3
	!insertmacro CreateSectionActualizacion 4
	!insertmacro CreateSectionActualizacion 5
	!insertmacro CreateSectionActualizacion 6
	!insertmacro CreateSectionActualizacion 7
	!insertmacro CreateSectionActualizacion 8
	!insertmacro CreateSectionActualizacion 9
	!insertmacro CreateSectionActualizacion 10
	!insertmacro CreateSectionActualizacion 11
	!insertmacro CreateSectionActualizacion 12
SectionGroupEnd

Section "-WriteLog: Requisitos" 14
	Call WriteLogRequisitos
SectionEnd

SectionGroup /e "${TXT_GrpRequisitos}" 15
	!insertmacro CreateSectionRequisito 16
	!insertmacro CreateSectionRequisito 17
	!insertmacro CreateSectionRequisito 18
	!insertmacro CreateSectionRequisito 19
	!insertmacro CreateSectionRequisito 20
	!insertmacro CreateSectionRequisito 21
	!insertmacro CreateSectionRequisito 22
	!insertmacro CreateSectionRequisito 23
	!insertmacro CreateSectionRequisito 24
	!insertmacro CreateSectionRequisito 25
SectionGroupEnd

Section "-WriteLog: Complementos" 27
	Call WriteLogComplementos
SectionEnd

SectionGroup "${TXT_GrpComplementos}" 28
	!insertmacro CreateSectionComplemento 29
	!insertmacro CreateSectionComplemento 30
	!insertmacro CreateSectionComplemento 31
	!insertmacro CreateSectionComplemento 32
	!insertmacro CreateSectionComplemento 33
	!insertmacro CreateSectionComplemento 34
	!insertmacro CreateSectionComplemento 35
	!insertmacro CreateSectionComplemento 36
	!insertmacro CreateSectionComplemento 37
	!insertmacro CreateSectionComplemento 38
	!insertmacro CreateSectionComplemento 39
	!insertmacro CreateSectionComplemento 40
	!insertmacro CreateSectionComplemento 41
	!insertmacro CreateSectionComplemento 42
	!insertmacro CreateSectionComplemento 43
	!insertmacro CreateSectionComplemento 44
	!insertmacro CreateSectionComplemento 45
	!insertmacro CreateSectionComplemento 46
	!insertmacro CreateSectionComplemento 47
	!insertmacro CreateSectionComplemento 48
	!insertmacro CreateSectionComplemento 49
	!insertmacro CreateSectionComplemento 50
	!insertmacro CreateSectionComplemento 51
	!insertmacro CreateSectionComplemento 52
	!insertmacro CreateSectionComplemento 53
	!insertmacro CreateSectionComplemento 54
	!insertmacro CreateSectionComplemento 55
	!insertmacro CreateSectionComplemento 56
	!insertmacro CreateSectionComplemento 57
	!insertmacro CreateSectionComplemento 58
SectionGroupEnd

Section "-WriteLog: Extensiones" 60
	Call WriteLogExtensiones
SectionEnd

SectionGroup "${TXT_GrpExtensiones}" 61
	!insertmacro CreateSectionExtension 62
	!insertmacro CreateSectionExtension 63
	!insertmacro CreateSectionExtension 64
	!insertmacro CreateSectionExtension 65
	!insertmacro CreateSectionExtension 66
	!insertmacro CreateSectionExtension 67
	!insertmacro CreateSectionExtension 68
	!insertmacro CreateSectionExtension 69
	!insertmacro CreateSectionExtension 70
	!insertmacro CreateSectionExtension 71
	!insertmacro CreateSectionExtension 72
	!insertmacro CreateSectionExtension 73
	!insertmacro CreateSectionExtension 74
	!insertmacro CreateSectionExtension 75
	!insertmacro CreateSectionExtension 76
	!insertmacro CreateSectionExtension 77
	!insertmacro CreateSectionExtension 78
	!insertmacro CreateSectionExtension 79
	!insertmacro CreateSectionExtension 80
	!insertmacro CreateSectionExtension 81
SectionGroupEnd

Section "-WriteLog: Recursos" 83
	Call WriteLogRecursos
SectionEnd

SectionGroup "${TXT_GrpRecursos}" 84
	!insertmacro CreateSectionRecurso 85
	!insertmacro CreateSectionRecurso 86
	!insertmacro CreateSectionRecurso 87
	!insertmacro CreateSectionRecurso 88
	!insertmacro CreateSectionRecurso 89
	!insertmacro CreateSectionRecurso 90
	!insertmacro CreateSectionRecurso 91
	!insertmacro CreateSectionRecurso 92
	!insertmacro CreateSectionRecurso 93
	!insertmacro CreateSectionRecurso 94
	!insertmacro CreateSectionRecurso 95
	!insertmacro CreateSectionRecurso 96
	!insertmacro CreateSectionRecurso 97
	!insertmacro CreateSectionRecurso 98
	!insertmacro CreateSectionRecurso 99
	!insertmacro CreateSectionRecurso 100
	!insertmacro CreateSectionRecurso 101
	!insertmacro CreateSectionRecurso 102
	!insertmacro CreateSectionRecurso 103
	!insertmacro CreateSectionRecurso 104
	!insertmacro CreateSectionRecurso 105
	!insertmacro CreateSectionRecurso 106
	!insertmacro CreateSectionRecurso 107
	!insertmacro CreateSectionRecurso 108
	!insertmacro CreateSectionRecurso 109
	!insertmacro CreateSectionRecurso 110
	!insertmacro CreateSectionRecurso 111
	!insertmacro CreateSectionRecurso 112
	!insertmacro CreateSectionRecurso 113
	!insertmacro CreateSectionRecurso 114
SectionGroupEnd

Section "-WriteLog: Config" 116
	Call WriteLogConfig
SectionEnd

Section "-Config" 117
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
		WriteRegStr HKCU "Software\${NAME}" "FtpUser" "$FtpUser"
		WriteRegStr HKCU "Software\${NAME}" "FtpPass" "$FtpPass"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "FtpUser"
		DeleteRegValue HKCU "Software\${NAME}" "FtpPass"
	${EndIf}
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$InstDrive$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALL}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	StrCpy $FtpUser ""
	StrCpy $FtpPass ""
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALL}"
	DetailPrint "${TXT_LogCreateShortCut}"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
SectionEnd

Section "-WriteLog: Final" 118
	Call WriteLogFinal
SectionEnd

Section "Uninstall"
	Delete "$INSTDIR\*.*"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$DESKTOP\Actualizar.lnk"
	Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\Actualizar.lnk"
	RMDir /r "$SMPROGRAMS\${NAME}"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$TEMP"
	Delete "$TEMP\catalogo.json"
	RMDir /r "$INSTDIR"
	StrCmp $unToolsCheckboxState "1" 0 Done
	!insertmacro MUninstallTools
	Push "$InstDrive${TOOLS}"
	Call un.RemoveDirIfEmpty
	RMDir /r "$InstDrive${VENDOR}"
Done:
	RMDir /r "$InstDrive${TARGET}"
SectionEnd
