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

;--------------------------------
; DEFINICIONES

!define LANZAMIENTO "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Ruben Araya Tagle"
!define SERVER "https://masexperto.cl/phpsinergia/herramientas"
!define SRCDRIVE "C:"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define SLUG "${NAME} ${LANZAMIENTO}"
!define INSTALL "setup_miayudante_${LANZAMIENTO}.exe"
!define UNINSTALL "Desinstalar.exe"
!define APPFILE "ayudante.exe"
!define TARGET "home\mi-ayudante"
!define VENDOR "home\vendor"
!define TOOLS "home\herramientas"
!define APPDIR "..\app"
!define LICENSE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"

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
!define MUI_COMPONENTSPAGE_NODESC

;--------------------------------
; DECLARACIONES

Var INSTDRIVE
Var DriveCombo

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
!insertmacro MUI_PAGE_COMPONENTS
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
	!insertmacro DriveSpace
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
; MACRO DESCARGA Y DESCOMPRESIÓN

!macro DownloadAndExtract TOOL_ID TOOL_NAME
Section "${TOOL_NAME}" SEC_${TOOL_ID}
    SetOutPath "$TEMP"
    inetc::get /TIMEOUT=30000 /RESUME "" "${SERVER}/${TOOL_ID}.zip" "$TEMP\${TOOL_ID}.zip" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_ICONSTOP "Error al descargar ${TOOL_NAME}: $0"
        Abort
    CreateDirectory "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    nsExec::Exec '"$INSTDRIVE\${TOOLS}\7za.exe" x "$TEMP\${TOOL_ID}.zip" -o"$INSTDRIVE\${TOOLS}\${TOOL_ID}" -y'
    Delete "$TEMP\${TOOL_ID}.zip"
SectionEnd
!macroend

;--------------------------------
; SECCIONES

Section "Programa: Mi Ayudante"
	SectionIn RO
	SetOutPath "$INSTDIR"
	File "config.ini"
	File "${APPDIR}\${APPFILE}"
	File "${APPDIR}\${README}"
	SetOutPath "$INSTDIR\base"
	File /r "${APPDIR}\base\*.*"
	SetOutPath "$INSTDIR\img"
	File /r "${APPDIR}\img\*.*"
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
	File "${SRCDRIVE}\${TOOLS}\7za.exe"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "${LANZAMIENTO}"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDIR\${UNINSTALL}"
	WriteUninstaller "$INSTDIR\${UNINSTALL}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
SectionEnd

SectionGroup "Herramientas"
	!insertmacro DownloadAndExtract gettext "CLI: Gettext"
	!insertmacro DownloadAndExtract mkcert "CLI: Mkcert"
	!insertmacro DownloadAndExtract pandoc "CLI: Pandoc"
	!insertmacro DownloadAndExtract pdftk "CLI: PDFtk"
	!insertmacro DownloadAndExtract sqlite "CLI: SQLite"
	!insertmacro DownloadAndExtract wkhtmltopdf "CLI: Wkhtmltopdf"
	!insertmacro DownloadAndExtract ffmpeg "CLI: FFmpeg"
	!insertmacro DownloadAndExtract scss "SCSS: Bootstrap"
SectionGroupEnd

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
	DeleteRegKey HKCU "${HKCUNI}"
SectionEnd
