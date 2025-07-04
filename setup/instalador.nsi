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
; PAGINAS DEL INSTALADOR (8)
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
; PAGINAS DEL DESINSTALADOR (3)
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
!insertmacro GetTime
!insertmacro WordFind

;--------------------------------
; MODULOS
;--------------------------------

!include "instalar.nsh"
!include "opciones.nsh"
!include "prerequisitos.nsh"
!include "componentes.nsh"
!include "confirmacion.nsh"
!include "registro.nsh"
!include "secciones.nsh"
!include "desinstalar.nsh"
