;--------------------------------
; INCLUDES

!include "MUI2.nsh"
!include "logiclib.nsh"

;--------------------------------
; DEFINICIONES

!define VERSION "1.0.0"
!define NAME "Mi-Ayudante"
!define TARGET "C:\home\mi-ayudante"
!define ICON "img\favicon.ico"
!define SLUG "${NAME} v${VERSION}"
!define APPFILE "mi-ayudante.exe"

!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${SLUG}"
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_LICENSEPAGE_CHECKBOX_TEXT "Acepto la licencia"
!define MUI_STARTMENUPAGE
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_TEXT "Ejecutar ${NAME} ahora"

;--------------------------------
; GENERAL

Unicode true
Name "${NAME}"
OutFile "..\dist\Instalar_${NAME}_${VERSION}.exe"
InstallDir ${TARGET}
InstallDirRegKey HKCU "Software\${NAME}" ${TARGET}
RequestExecutionLevel user
SetCompressor lzma
Var STARTMENU_FOLDER

;--------------------------------
; PAGINAS
  
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_STARTMENU Application $STARTMENU_FOLDER
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES

Function un.RMDirUP
	!define RMDirUP '!insertmacro RMDirUPCall'
	!macro RMDirUPCall _PATH
		push '${_PATH}'
		Call un.RMDirUP
	!macroend
	ClearErrors
	Exch $0
	RMDir "$0\.."
	IfErrors Skip
		${RMDirUP} "$0\.."
	Skip:
	Pop $0
FunctionEnd

Function LaunchApp
	ExecShell "" "$INSTDIR\${APPFILE}"
FunctionEnd

;--------------------------------
; SECCIONES

Section "-hidden app"
	SetOutPath "$INSTDIR"
	File "..\app\${APPFILE}"
	File "config.ini"
	SetOutPath "$INSTDIR\base"
	File /r "..\app\base\*.*"
	SetOutPath "$INSTDIR\img"
	File "..\app\img\*.*"
	SetOutPath "$INSTDIR\bin"
	File "..\app\bin\*.*"
	CreateDirectory "$INSTDIR\compartidos"
	CreateDirectory "$INSTDIR\logs"
	CreateDirectory "$INSTDIR\datos"
	SetOutPath "$INSTDIR\datos"
	File /oname=base_proyectos.txt ..\app\base\proyectos.txt
	CreateDirectory "$INSTDIR\entornos\base"
	SetOutPath "$INSTDIR\entornos\base"
	File /r "..\app\base\entorno\*.*"
	SetOutPath "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "" $INSTDIR
	WriteUninstaller "$INSTDIR\desinstalar.exe"
SectionEnd

Section "Access Direct"
	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
		CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
		CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
		CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
	!insertmacro MUI_STARTMENU_WRITE_END
SectionEnd

Section "Uninstall"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$SMPROGRAMS\$STARTMENU_FOLDER\${NAME}.lnk"
	RMDir /r "$SMPROGRAMS\$STARTMENU_FOLDER"
	Delete "$INSTDIR\LICENSE"
	Delete "$INSTDIR\${APPFILE}"
	Delete "$INSTDIR\config.ini"
	Delete "$INSTDIR\desinstalar.exe"
	RMDir /r "$INSTDIR"
	${RMDirUP} "$INSTDIR"
	DeleteRegKey /ifempty HKCU "Software\${NAME}"
SectionEnd

