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
!define UPDATER "Instalar-MiAyudante.exe"
!define INSTALL "..\dist\${UPDATER}"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define MAX_ACTUALIZACIONES 10
!define MAX_REQUISITOS 10
!define MAX_COMPLEMENTOS 30
!define MAX_EXTENSIONES 20
!define MAX_RECURSOS 30
!define SecPrograma 2
!define SecLanzamiento 3
!define GrpRequisitos 15
!define GrpComplementos 28
!define GrpExtensiones 61
!define GrpRecursos 84

;--------------------------------
; VARIABLES GLOBALES
Var VERSION
Var INSTDRIVE
Var SERVER
Var FTP_USER
Var FTP_PASS
Var PROTOCOL
Var FullPath
Var IsUpdateInstall
Var ServerInput
Var DriveDropList
Var FtpUserInput
Var FtpPassInput
Var ProtocolDropList
Var SkipPrereq
Var RememberCredsCheckbox
Var RememberCreds
Var SkipPreCheckbox
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox
Var hDriveDropList
Var tmpGB
Var btnTest
Var btnUninstall
Var LogFile
Var LogMsg
Var Timestamp
Var UpdaterPath
Var Ajuste
Var i
Var n
Var ToolId
Var ToolName
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolIndex
Var ToolsCatalog
Var ToolTemp
;TODO: Revisar
Var CompsTotal
Var ReqsTotal
Var ActsTotal
Var CompsVisibles
Var ReqsVisibles

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
LicenseBkColor /windows
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
PageEx license
	PageCallbacks SkipLicenseIfUpdate ""
	LicenseData "..\${LICENSEFILE}"
	LicenseText "${TXT_InstruccionesLicencia}" "${TXT_BotonAcepto}"
	Caption " "
PageExEnd
Page custom ShowOptionsForm SaveOptionsForm " "
Page custom CheckPreRequisites LeavePreRequisites " "
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckAllTools
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
	GetFullPathName $FullPath $EXEPATH
	StrCpy $INSTDRIVE $FullPath 2
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	ReadRegStr $1 HKCU "Software\${NAME}" "Install_Drive"
	ReadRegStr $2 HKCU "Software\${NAME}" "SkipPrereq"
	ReadRegStr $3 HKCU "Software\${NAME}" "Installer"
	ReadRegStr $SERVER HKCU "Software\${NAME}" "Server"
	ReadRegStr $FTP_USER HKCU "Software\${NAME}" "FTP_User"
	ReadRegStr $FTP_PASS HKCU "Software\${NAME}" "FTP_Pass"
	ReadRegStr $PROTOCOL HKCU "Software\${NAME}" "Protocol"
	ReadRegStr $VERSION HKCU "${HKCUNI}" "DisplayVersion"
	${If} $0 != ""
		StrCpy $INSTDIR $0
		${If} $1 != ""
			StrCpy $INSTDRIVE $1
			StrCpy $UpdaterPath "$INSTDRIVE$INSTDIR\${UPDATER}"
			${If} $3 != ""
				${If} $UpdaterPath == $FullPath
				${AndIf} $3 != $UpdaterPath
					Delete $3
					WriteRegStr HKCU "Software\${NAME}" "Installer" "$FullPath"
				${EndIf}
			${EndIf}
		${EndIf}
	${Else}
		WriteRegStr HKCU "Software\${NAME}" "Installer" "$FullPath"
	${EndIf}
	StrCpy $SkipPrereq "0"
	${If} $2 != ""
		StrCpy $SkipPrereq $2
	${EndIf}
	${If} $VERSION == ""
		StrCpy $VERSION ${RELEASE}
	${EndIf}
	${GetTime} "" "L" $R0 $R1 $R2 $R3 $R4 $R5 $R6
	IntFmt $R2 "%04d" $R2
	IntFmt $R1 "%02d" $R1
	IntFmt $R0 "%02d" $R0
	IntFmt $R4 "%02d" $R4
	IntFmt $R5 "%02d" $R5
	StrCpy  $Timestamp "$R2$R1$R0$R4$R5"
	StrCpy $IsUpdateInstall "0"
	${If} $0 != ""
		StrCpy $IsUpdateInstall "1"
		StrCpy $LogFile "$INSTDIR\logs\actualizacion_$Timestamp.log"
		StrCpy $TextCaption "${TXT_VentanaActualizador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeActualizador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeActualizador}"
		StrCpy $TitleFinish "${TXT_TituloFinishActualizador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishActualizador}"
		SectionSetFlags ${SecPrograma} 0
		SectionSetFlags ${SecLanzamiento} ${SF_SELECTED}
		SectionSetText ${SecPrograma} "${NAME} ${TXT_EtiqReinstalar}"
	${Else}
		StrCpy $LogFile "$INSTDIR\logs\instalacion_$Timestamp.log"
		StrCpy $TextCaption "${TXT_VentanaInstalador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeInstalador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeInstalador}"
		StrCpy $TitleFinish "${TXT_TituloFinishInstalador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishInstalador}"
		IntOp $3 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SecPrograma} $3
		IntOp $3 0 | ${SF_RO}
		SectionSetFlags ${SecLanzamiento} $3
		SectionSetText ${SecLanzamiento} ""
	${EndIf}
	ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
	${If} $RememberCreds != "1"
		StrCpy $RememberCreds "0"
	${EndIf}
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "${TXT_TituloLicencia}" "${TXT_SubtituloLicencia}"
FunctionEnd

Function LaunchApp
	IfFileExists "$INSTDRIVE$INSTDIR\${APPFILE}" 0 +3
		ExecShell "" '"$INSTDRIVE$INSTDIR\${APPFILE}"'
		Return
	MessageBox MB_ICONSTOP "${TXT_MsgExeNoEncontrado}"
FunctionEnd

Function RunUninstaller
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "${TXT_MsgConfirmaDesinstalacion}" IDNO EndAsk
		StrCpy $0 "$INSTDRIVE$INSTDIR\${UNINSTALL}"
		IfFileExists "$0" 0 NoUninst
		Exec '"$0"'
		Quit
NoUninst:
	MessageBox MB_ICONSTOP "${TXT_MsgUniNoEncontrado}$\n$0"
EndAsk:
FunctionEnd

!include "secciones.nsh"
!include "tools.nsh"
!include "prereqs.nsh"
!include "opciones.nsh"

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $INSTDRIVE $0
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "${TXT_EtiqDesinstalarHerramientas}"
	Pop $1
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

!include "un.tools.nsh"

;--------------------------------
; SECCIONES

Section "-Inicial" 0
	DetailPrint "============================================"
	DetailPrint "${TXT_LogTitulo}"
	${GetTime} "" "L" $R0 $R1 $R2 $R3 $R4 $R5 $R6
	IntFmt $R2 "%04d" $R2
	IntFmt $R1 "%02d" $R1
	IntFmt $R0 "%02d" $R0
	IntFmt $R4 "%02d" $R4
	IntFmt $R5 "%02d" $R5
	DetailPrint "${TXT_LogFechaHora} $R0-$R1-$R2  $R4:$R5"
	DetailPrint "${TXT_LogVersion} v$VERSION"
	DetailPrint "${TXT_EtiqUnidadDestino} $INSTDRIVE"
	DetailPrint "${TXT_EtiqRutaInstalacion} $INSTDIR"
	DetailPrint "${TXT_LogServidorDescargas} $SERVER"
	DetailPrint "${TXT_LogProtocoloTransfer} $PROTOCOL"
	DetailPrint "============================================"
SectionEnd

SectionGroup /e "${TXT_SecPrograma}" 1
	Section "${NAME} (*)" 2
		DetailPrint "============================================"
		DetailPrint "${TXT_LogSecPrograma}"
	;Creación de directorios
		CreateDirectory "$INSTDRIVE$INSTDIR\compartidos"
		CreateDirectory "$INSTDRIVE$INSTDIR\datos"
		CreateDirectory "$INSTDRIVE$INSTDIR\entornos\basico"
		CreateDirectory "$INSTDRIVE$INSTDIR\logs"
		CreateDirectory "$INSTDRIVE$INSTDIR\respaldos"
		CreateDirectory "$INSTDRIVE${TOOLS}"
	;Copia selectiva de archivos
		SetOutPath "$INSTDRIVE$INSTDIR\base"
		File /r "..\app\base\*.*"
		SetOutPath "$INSTDRIVE$INSTDIR\img"
		File /r "..\app\img\*.*"
		SetOutPath "$INSTDRIVE$INSTDIR"
		IfFileExists "$INSTDRIVE$INSTDIR\${APPFILE}" +2 0
			File "..\app\${APPFILE}"
		IfFileExists "$INSTDRIVE$INSTDIR\${README}" +2 0
			File "..\app\${README}"
		IfFileExists "$INSTDRIVE$INSTDIR\${LICENSEFILE}" +2 0
			File /oname=LICENSE.txt "..\${LICENSEFILE}"
		SetOutPath "$INSTDRIVE$INSTDIR\datos"
		IfFileExists "$INSTDRIVE$INSTDIR\datos\basico_proyectos.txt" +2 0
			File /oname=basico_proyectos.txt "..\app\base\proyectos.txt"
		SetOutPath "$INSTDRIVE$INSTDIR\entornos\basico"
		IfFileExists "$INSTDRIVE$INSTDIR\entornos\basico\config.ini" +2 0
			File /r "..\app\base\entorno\*.*"
		SetOutPath "$INSTDRIVE${TOOLS}"
	;Actualización de config.ini
		SetOutPath "$INSTDRIVE$INSTDIR"
		IfFileExists "$INSTDRIVE$INSTDIR\config.ini" +2 0
			File "config.ini"
		WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base RutaHerramientas $INSTDRIVE${TOOLS}
		WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base Lanzamiento $VERSION
		DetailPrint "============================================"
	SectionEnd
	!insertmacro SECTION_ACTUALIZACION 3
	!insertmacro SECTION_ACTUALIZACION 4
	!insertmacro SECTION_ACTUALIZACION 5
	!insertmacro SECTION_ACTUALIZACION 6
	!insertmacro SECTION_ACTUALIZACION 7
	!insertmacro SECTION_ACTUALIZACION 8
	!insertmacro SECTION_ACTUALIZACION 9
	!insertmacro SECTION_ACTUALIZACION 10
	!insertmacro SECTION_ACTUALIZACION 11
	!insertmacro SECTION_ACTUALIZACION 12
SectionGroupEnd

Section "-Pre: Requisitos" 14
SectionEnd

SectionGroup /e "${TXT_GrpRequisitos}" 15
	!insertmacro SECTION_REQUISITO 16
	!insertmacro SECTION_REQUISITO 17
	!insertmacro SECTION_REQUISITO 18
	!insertmacro SECTION_REQUISITO 19
	!insertmacro SECTION_REQUISITO 20
	!insertmacro SECTION_REQUISITO 21
	!insertmacro SECTION_REQUISITO 22
	!insertmacro SECTION_REQUISITO 23
	!insertmacro SECTION_REQUISITO 24
	!insertmacro SECTION_REQUISITO 25
SectionGroupEnd

Section "-Pre: Complementos" 27
SectionEnd

SectionGroup "${TXT_GrpComplementos}" 28
	!insertmacro SECTION_COMPLEMENTO 29
	!insertmacro SECTION_COMPLEMENTO 30
	!insertmacro SECTION_COMPLEMENTO 31
	!insertmacro SECTION_COMPLEMENTO 32
	!insertmacro SECTION_COMPLEMENTO 33
	!insertmacro SECTION_COMPLEMENTO 34
	!insertmacro SECTION_COMPLEMENTO 35
	!insertmacro SECTION_COMPLEMENTO 36
	!insertmacro SECTION_COMPLEMENTO 37
	!insertmacro SECTION_COMPLEMENTO 38
	!insertmacro SECTION_COMPLEMENTO 39
	!insertmacro SECTION_COMPLEMENTO 40
	!insertmacro SECTION_COMPLEMENTO 41
	!insertmacro SECTION_COMPLEMENTO 42
	!insertmacro SECTION_COMPLEMENTO 43
	!insertmacro SECTION_COMPLEMENTO 44
	!insertmacro SECTION_COMPLEMENTO 45
	!insertmacro SECTION_COMPLEMENTO 46
	!insertmacro SECTION_COMPLEMENTO 47
	!insertmacro SECTION_COMPLEMENTO 48
	!insertmacro SECTION_COMPLEMENTO 49
	!insertmacro SECTION_COMPLEMENTO 50
	!insertmacro SECTION_COMPLEMENTO 51
	!insertmacro SECTION_COMPLEMENTO 52
	!insertmacro SECTION_COMPLEMENTO 53
	!insertmacro SECTION_COMPLEMENTO 54
	!insertmacro SECTION_COMPLEMENTO 55
	!insertmacro SECTION_COMPLEMENTO 56
	!insertmacro SECTION_COMPLEMENTO 57
	!insertmacro SECTION_COMPLEMENTO 58
SectionGroupEnd

Section "-Pre: Extensiones" 60
SectionEnd

SectionGroup "${TXT_GrpExtensiones}" 61
	!insertmacro SECTION_EXTENSION 62
	!insertmacro SECTION_EXTENSION 63
	!insertmacro SECTION_EXTENSION 64
	!insertmacro SECTION_EXTENSION 65
	!insertmacro SECTION_EXTENSION 66
	!insertmacro SECTION_EXTENSION 67
	!insertmacro SECTION_EXTENSION 68
	!insertmacro SECTION_EXTENSION 69
	!insertmacro SECTION_EXTENSION 70
	!insertmacro SECTION_EXTENSION 71
	!insertmacro SECTION_EXTENSION 72
	!insertmacro SECTION_EXTENSION 73
	!insertmacro SECTION_EXTENSION 74
	!insertmacro SECTION_EXTENSION 75
	!insertmacro SECTION_EXTENSION 76
	!insertmacro SECTION_EXTENSION 77
	!insertmacro SECTION_EXTENSION 78
	!insertmacro SECTION_EXTENSION 79
	!insertmacro SECTION_EXTENSION 80
	!insertmacro SECTION_EXTENSION 81
SectionGroupEnd

Section "-Pre: Recursos" 83
SectionEnd

SectionGroup "${TXT_GrpRecursos}" 84
	!insertmacro SECTION_RECURSO 85
	!insertmacro SECTION_RECURSO 86
	!insertmacro SECTION_RECURSO 87
	!insertmacro SECTION_RECURSO 88
	!insertmacro SECTION_RECURSO 89
	!insertmacro SECTION_RECURSO 90
	!insertmacro SECTION_RECURSO 91
	!insertmacro SECTION_RECURSO 92
	!insertmacro SECTION_RECURSO 93
	!insertmacro SECTION_RECURSO 94
	!insertmacro SECTION_RECURSO 95
	!insertmacro SECTION_RECURSO 96
	!insertmacro SECTION_RECURSO 97
	!insertmacro SECTION_RECURSO 98
	!insertmacro SECTION_RECURSO 99
	!insertmacro SECTION_RECURSO 100
	!insertmacro SECTION_RECURSO 101
	!insertmacro SECTION_RECURSO 102
	!insertmacro SECTION_RECURSO 103
	!insertmacro SECTION_RECURSO 104
	!insertmacro SECTION_RECURSO 105
	!insertmacro SECTION_RECURSO 106
	!insertmacro SECTION_RECURSO 107
	!insertmacro SECTION_RECURSO 108
	!insertmacro SECTION_RECURSO 109
	!insertmacro SECTION_RECURSO 110
	!insertmacro SECTION_RECURSO 111
	!insertmacro SECTION_RECURSO 112
	!insertmacro SECTION_RECURSO 113
	!insertmacro SECTION_RECURSO 114
SectionGroupEnd

Section "-Config" 116
	DetailPrint "============================================"
	DetailPrint "${TXT_LogSecConfig}"
	DetailPrint "${TXT_LogWriteReg} HKCU Software\${NAME}"
	DetailPrint "${TXT_LogWriteReg} HKCU ${HKCUNI}"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$INSTDRIVE"
	WriteRegStr HKCU "Software\${NAME}" "Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
	WriteRegStr HKCU "Software\${NAME}" "VendorPath" "$INSTDRIVE${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "ToolsPath" "$INSTDRIVE${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	${If} $RememberCreds == "1"
		WriteRegStr HKCU "Software\${NAME}" "FTP_User" "$FTP_USER"
		WriteRegStr HKCU "Software\${NAME}" "FTP_Pass" "$FTP_PASS"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "FTP_User"
		DeleteRegValue HKCU "Software\${NAME}" "FTP_Pass"
	${EndIf}
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDRIVE$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$VERSION"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDRIVE$INSTDIR\${UNINSTALL}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	StrCpy $FTP_USER ""
	StrCpy $FTP_PASS ""
	DetailPrint "${TXT_MsgCalculandoEspacio}"
	${GetSize} "$INSTDRIVE\home" "/S=0K" $1 $R7 $R8
	DetailPrint "$1 KB"
	IntFmt $1 "0x%08X" $1
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	${IfNot} ${FileExists} $UpdaterPath
		CopyFiles /SILENT /FILESONLY $FullPath "$INSTDRIVE$INSTDIR"
	${Else}
		${If} $UpdaterPath != $FullPath
			Delete $UpdaterPath
			CopyFiles /SILENT /FILESONLY $FullPath "$INSTDRIVE$INSTDIR"
		${EndIf}
	${EndIf}
	WriteUninstaller "$INSTDRIVE$INSTDIR\${UNINSTALL}"
	DetailPrint "${TXT_LogCreateShortCut}"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}\Actualizar.lnk" "$UpdaterPath" "" "$INSTDRIVE$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\Actualizar.lnk" "$UpdaterPath" "" "$INSTDRIVE$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
	DetailPrint "============================================"
SectionEnd

Section "-Final" 117
	DumpLog::DumpLogUTF8 "$LogFile" .r0
	Pop $0
	;DetailPrint "DumpLog→$0"
SectionEnd

Section "Uninstall"
	StrCpy $ToolsCatalog "$INSTDIR\catalogo.json"
	Call un.LoadCompsJson
	Call un.LoadReqsJson
	Delete "$INSTDIR\*.*"
	Delete "$INSTDIR\${UPDATER}"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$DESKTOP\Actualizar.lnk"
	Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}\Actualizar.lnk"
	RMDir /r "$SMPROGRAMS\${NAME}"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$TEMP"
	RMDir /r "$INSTDIR"
	StrCmp $unToolsCheckboxState "1" 0 Done
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPLEMENTOS}
			Call un.GetInfoComp
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQUISITOS}
			Call un.GetInfoReq
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	Push "$INSTDRIVE${TOOLS}"
	Call un.RemoveDirIfEmpty
	RMDir /r "$INSTDRIVE${VENDOR}"
Done:
	RMDir /r "$INSTDRIVE${TARGET}"
SectionEnd
