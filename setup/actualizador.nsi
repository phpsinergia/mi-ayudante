; actualizador.nsi
;================================
; ACTUALIZADOR DE MI-AYUDANTE
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
!define INSTALLER "..\dist\Actualizar-MiAyudante.exe"
!define UNINSTALLER "desinstalar.exe"
!define DESCRIPTION "${INSTALLER_NAME} ${NAME}"
!define RESOURCES "$DOCUMENTS\mi-ayudante"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define APPDATA "$LOCALAPPDATA\mi-ayudante"
!define APPDIR "\home\mi-ayudante"
!define APPFILE "ayudante.exe"
!define LICENSEFILE "LICENSE"
!define CATALOGFILE "catalogo.json"
!define READMEFILE "LEEME.txt"
!define ICON "favicon.ico"
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
Icon "..\app\${ICON}"
;--------------------------------
VIProductVersion ${INSTALLER_VERSION}
VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "${DESCRIPTION}"
VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" ${INSTALLER_VERSION}
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductVersion" "${RELEASE}"
VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "${NAME}"
VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "${PUBLISHER}"

;--------------------------------
; DEFINICIONES INTERFAZ USUARIO
;--------------------------------
!define MUI_ICON "..\app\${ICON}"
!define MUI_UNICON "..\app\${ICON}"
!define MUI_ABORTWARNING
!define MUI_UNABORTWARNING
;--------------------------------
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_BITMAP "head.bmp"
!define MUI_HEADERIMAGE_UNBITMAP "head.bmp"
;--------------------------------
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
;--------------------------------
!define MUI_WELCOMEPAGE_TITLE "$TitleWelcome"
!define MUI_WELCOMEPAGE_TEXT "$TextWelcome"
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "left.bmp"
;--------------------------------
!define MUI_PAGE_HEADER_TEXT "$(TXT_TituloLicencia)"
!define MUI_PAGE_HEADER_SUBTEXT "$(TXT_SubtituloLicencia)"
!define MUI_LICENSEPAGE_TEXT_TOP "$(TXT_InstruccionesLicenciaSup)"
!define MUI_LICENSEPAGE_TEXT_BOTTOM "$(TXT_InstruccionesLicenciaInf)"
!define MUI_LICENSEPAGE_BUTTON "$(TXT_BotonAcepto)"
!define MUI_LICENSEPAGE_BGCOLOR /windows
;--------------------------------
!define MUI_COMPONENTSPAGE_TEXT_TOP "$(TXT_InstruccionesComponentes)"
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST "$(TXT_SeleccionarComponentes)"
!define MUI_COMPONENTSPAGE_NODESC
;--------------------------------
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "$(TXT_TituloInstFinalizada)"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "$(TXT_SubtituloInstCompletada)"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "$(TXT_TituloInstCancelada)"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "$(TXT_SubtituloInstCancelada)"
;--------------------------------
!define MUI_FINISHPAGE_TITLE "$TitleFinish"
!define MUI_FINISHPAGE_TEXT "$TextFinish"
!define MUI_FINISHPAGE_TEXT_LARGE
!define MUI_FINISHPAGE_BUTTON "$(TXT_BotonFinalizar)"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "$(TXT_EtiqEjecutarApp)"
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\${READMEFILE}"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "$(TXT_EtiqRevisarNotas)"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
!define MUI_FINISHPAGE_LINK "$(TXT_EtiqVerRegistro)"
!define MUI_FINISHPAGE_LINK_LOCATION "$LogFile"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_NOREBOOTSUPPORT
;--------------------------------
!define MUI_UNCONFIRMPAGE_TEXT_TOP "$(TXT_InstruccionesDesinstalar)"
!define MUI_UNCONFIRMPAGE_TEXT_LOCATION "$(TXT_UbicacionDesinstalar)"
;--------------------------------
; PAGINAS INSTALADOR (8)
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
; PAGINAS DESINSTALADOR (4)
;--------------------------------
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!define MUI_PAGE_CUSTOMFUNCTION_PRE un.CheckAllComponents
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
; TEXTOS DE INTERFAZ USUARIO
;--------------------------------
!insertmacro MUI_LANGUAGE "Spanish"
!include "txt_spanish.nsh"

;--------------------------------
; MACROS DE EXTENSIONES
;--------------------------------
!insertmacro GetTime
!insertmacro WordFind
;--------------------------------
${StrTrimNewLines}
${StrRep}
${StrStr}
${StrCase}
${StrTok}
;--------------------------------
${unStrTrimNewLines}
${unStrRep}
${unStrStr}
${unStrCase}

!macro UpdateSizeTotal DIR_BASE
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	StrCpy $R4 "0"
	${GetSize} "${DIR_BASE}" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	ClearErrors
	${GetSize} "$InstDrive${VENDOR}" "/S=0K" $R1 $R2 $R3
	IfErrors 0 +2
		StrCpy $R1 "0"
	IntOp $R4 $R4 + $R1
	ClearErrors
	${GetSize} "$InstDrive${TOOLS}" "/S=0K" $R1 $R2 $R3
	IfErrors 0 +2
		StrCpy $R1 "0"
	IntOp $R4 $R4 + $R1
	ClearErrors
	${GetSize} "${RESOURCES}" "/S=0K" $R1 $R2 $R3
	IfErrors 0 +2
		StrCpy $R1 "0"
	IntOp $R4 $R4 + $R1
	ClearErrors
	${GetSize} "${APPDATA}" "/S=0K" $R1 $R2 $R3
	IfErrors 0 +2
		StrCpy $R1 "0"
	IntOp $R4 $R4 + $R1
	DetailPrint "$R4 KB"
	IntFmt $R4 "0x%08X" $R4
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$R4"
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
!macroend

;--------------------------------
; MODULOS
;--------------------------------
!include "instalar.nsh"
!include "opciones.nsh"
!include "prerequisitos.nsh"
!include "confirmacion.nsh"
!include "componentes.nsh"
!include "registro.nsh"
!include "secciones.nsh"
;--------------------------------
!include "secciones.un.nsh"
!include "registro.un.nsh"
!include "desinstalar.nsh"
