;--------------------------------
; INSTALADOR DE MI-AYUDANTE
;--------------------------------

;--------------------------------
; INCLUDES

!include "MUI2.nsh"
!include "FileFunc.nsh"
!include "nsDialogs.nsh"
!include "logiclib.nsh"
!include "WinMessages.nsh"
!include "Sections.nsh"
!include "StrFunc.nsh"

;--------------------------------
; DEFINICIONES

!define LANZAMIENTO "1.0.0"

!define NAME "Mi-Ayudante"
!define SLUG "${NAME} ${LANZAMIENTO}"
!define APPFILE "mi-ayudante.exe"
!define APPDIR "..\app"
!define LICENSE "LICENSE"
!define README "LEEME.txt"
!define UNINSTALL "Uninstall.exe"
!define INSTALL "setup_mi-ayudante_${LANZAMIENTO}.exe"
!define ICON "img\favicon.ico"
!define TARGET "home\mi-ayudante"
!define VENDOR "home\vendor"
!define TOOLS "home\herramientas"
!define SERVER "masexperto.cl"
!define PUBLISHER "Ruben Araya Tagle"

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
; DECLARACIONES

Var INSTDRIVE
Var DriveCombo

!insertmacro DriveSpace
!insertmacro GetSize

Unicode true
Name "${NAME}"
OutFile "..\dist\${INSTALL}"
InstallDir "$INSTDRIVE\${TARGET}"
InstallDirRegKey HKCU "Software\${NAME}" "Install_Dir"
RequestExecutionLevel user
SetCompressor lzma

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\${LICENSE}"
Page custom SelectDrive SetInstallPath
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES

Function LaunchApp
	ExecShell "" "$INSTDIR\${APPFILE}"
FunctionEnd

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

Function SelectDrive
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    ${NSD_CreateLabel} 0 0 100% 12u "Selecciona la unidad donde instalar:"
    Pop $1
    ${NSD_CreateComboBox} 0 16u 100% 12u ""
    Pop $DriveCombo
    StrCpy $R0 "A"
    StrCpy $R9 ""
    StrCpy $9 0
DriveLoop:
    IntOp $R1 $9 + 65
    IntFmt $R0 "%c" $R1
    StrCpy $R2 "$R0:\"
    IfFileExists "$R2*" 0 NextDrive
    ${DriveSpace} "$R2" "/D=F" $R3
    System::Int64Op $R3 / 1048576
    Pop $R4
    ${If} $R4 != ""
        StrCpy $R5 "$R0:\ ($R4 MB libres)"
        ${NSD_CB_AddString} $DriveCombo $R5
    ${EndIf}
NextDrive:
    IntOp $9 $9 + 1
    ${IfThen} $9 < 26 ${|} Goto DriveLoop ${|}
    ${NSD_CB_SelectString} $DriveCombo "C:\"
    nsDialogs::Show
FunctionEnd

Function SetInstallPath
    ${NSD_GetText} $DriveCombo $0
    StrCpy $INSTDRIVE $0 2
    StrCpy $INSTDIR "$INSTDRIVE\${TARGET}"
FunctionEnd

;--------------------------------
; SECCIONES

Section "Install"
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
	CreateDirectory "$INSTDIR\entornos\basico"
	SetOutPath "$INSTDIR\entornos\basico"
	File /r "${APPDIR}\base\entorno\*.*"
	CreateDirectory "$INSTDRIVE\${VENDOR}"
	CreateDirectory "$INSTDRIVE\${TOOLS}"
	SetOutPath "$INSTDRIVE\${TOOLS}"
	File "C:\${TOOLS}\7za.exe"
	SetOutPath "$INSTDIR"
	${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
	IntFmt $0 "0x%08X" $0
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayIcon" "$INSTDIR\${ICON}"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "DisplayVersion" "${LANZAMIENTO}"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "UninstallString" "$INSTDIR\${UNINSTALL}"
	WriteRegDWORD HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}" "EstimatedSize" "$0"
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
	DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
SectionEnd
