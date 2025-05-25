;--------------------------------
; INSTALADOR DE MI-AYUDANTE
;--------------------------------

;--------------------------------
; INCLUDES

!include "MUI2.nsh"
!include "logiclib.nsh"

;--------------------------------
; DEFINICIONES

!define LANZAMIENTO "1.0.0"

!define NAME "Mi Ayudante"
!define HOME "C:\home"
!define SLUG "${NAME} ${LANZAMIENTO}"
!define TARGET "${HOME}\mi-ayudante"
!define VENDOR "${HOME}\vendor"
!define TOOLS "${HOME}\herramientas"
!define ICON "img\favicon.ico"
!define APPFILE "mi-ayudante.exe"
!define APPDIR "..\app"
!define LICENSE "LICENSE"
!define README "LEEME.txt"
!define UNINSTALL "Uninst.exe"
!define INSTALL "setup_mi-ayudante_${LANZAMIENTO}.exe"

!define MUI_ICON "${APPDIR}\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${SLUG}"
!define MUI_LICENSEPAGE_CHECKBOX
!define MUI_LICENSEPAGE_CHECKBOX_TEXT "Acepto la licencia"
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_TEXT "Ejecutar ${NAME} ahora"
!define MUI_FINISHPAGE_LINK "Revisar notas en ${README}"
!define MUI_FINISHPAGE_LINK_LOCATION "$INSTDIR\${README}"
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_HEADERIMAGE_BITMAP "head.bmp"

;--------------------------------
; GENERAL

Unicode true
Name "${NAME}"
OutFile "..\dist\${INSTALL}"
InstallDir ${TARGET}
InstallDirRegKey HKCU "Software\${NAME}" ${TARGET}
RequestExecutionLevel user
SetCompressor lzma

;--------------------------------
; PAGINAS
  
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\${LICENSE}"
!insertmacro MUI_PAGE_DIRECTORY
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
	File "config.ini"
	File "${APPDIR}\${APPFILE}"
	File "${APPDIR}\${README}"
	SetOutPath "$INSTDIR\base"
	File /r "${APPDIR}\base\*.*"
	SetOutPath "$INSTDIR\img"
	File "${APPDIR}\img\*.*"
	CreateDirectory "$INSTDIR\compartidos"
	CreateDirectory "$INSTDIR\logs"
	CreateDirectory "$INSTDIR\respaldos"
	CreateDirectory "$INSTDIR\datos"
	SetOutPath "$INSTDIR\datos"
	File /oname=base_proyectos.txt ${APPDIR}\base\proyectos.txt
	CreateDirectory "$INSTDIR\entornos\base"
	SetOutPath "$INSTDIR\entornos\base"
	File /r "${APPDIR}\base\entorno\*.*"
	CreateDirectory "${VENDOR}"

	CreateDirectory "${TOOLS}"
	SetOutPath "${TOOLS}"
	File "${TOOLS}\7za.exe"
	;File "${TOOLS}\ftp.exe"

	SetOutPath "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "" $INSTDIR
	WriteUninstaller "$INSTDIR\${UNINSTALL}"
SectionEnd

Section "Access Direct"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
SectionEnd

Section "Uninstall"
	Delete "$INSTDIR\config.ini"
	Delete "$INSTDIR\${LICENSE}"
	Delete "$INSTDIR\${APPFILE}"
	Delete "$INSTDIR\${README}"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}.lnk"
	RMDir /r "$INSTDIR"
	${RMDirUP} "$INSTDIR"
	DeleteRegKey /ifempty HKCU "Software\${NAME}"
SectionEnd
