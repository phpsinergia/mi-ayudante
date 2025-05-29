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
!include "tools.nsh"

;--------------------------------
; DEFINICIONES BÁSICAS

!define VERSION "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Ruben Araya Tagle"
!define SRCDRIVE "C:"
!define APPFILE "ayudante.exe"
!define TARGET "home\mi-ayudante"
!define VENDOR "home\vendor"
!define TOOLS "home\herramientas"
!define LICENSE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"
!define APPDIR "..\app"
!define UNINSTALL "Desinstalar.exe"
!define INSTALL "..\dist\setup_miayudante_${VERSION}.exe"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

;--------------------------------
; DEFINICIONES INTERFAZ

!define MUI_ICON "${APPDIR}\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${NAME} ${VERSION}"
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
; VARIABLES

Var INSTDRIVE
Var SERVER
Var ServerInput
Var DriveCombo
Var GetInstalledSize.total
Var un_ToolsCheckboxState
Var un_ToolsCheckbox

;--------------------------------
; CONFIGURACION GENERAL

Unicode true
Name "${NAME}"
OutFile "${INSTALL}"
InstallDir "$INSTDRIVE\${TARGET}"
InstallDirRegKey HKCU "Software\${NAME}" "Install_Dir"
RequestExecutionLevel user
SetCompressor lzma

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\${LICENSE}"
Page custom ConfigPage SaveConfigPage
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ConfirmTools un.ReadToolsChoice
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES INSTALACIÓN

Function ConfigPage
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    ; --- Label + Combo de unidades ---
    ${NSD_CreateLabel} 0 0 100% 12u "Unidad donde instalar:"
    Pop $1
    ${NSD_CreateComboBox} 0 14u 100% 12u ""
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
    ; --- Label + Input para dominio ---
    ${NSD_CreateLabel} 0 36u 100% 12u "Dominio del Servidor de Herramientas:"
    Pop $2
    ${NSD_CreateText} 0 50u 100% 12u "$SERVER"
    Pop $ServerInput
    nsDialogs::Show
FunctionEnd

Function SaveConfigPage
    ${NSD_GetText} $DriveCombo $0
    StrCpy $INSTDRIVE $0 2
    StrCpy $INSTDIR "$INSTDRIVE\${TARGET}"
    ${NSD_GetText} $ServerInput $SERVER
FunctionEnd

Function AddToUserPath
    Exch $0
    Push $1
    ReadRegStr $1 HKCU "Environment" "Path"
    ${If} $1 != ""
        ${If} $1 != "" 
		${AndIf} $1 != $0 
		${AndIf} $1 != "$0;" 
		${AndIf} $1 != ";$0" 
		${AndIf} $1 != ";$0;" 
		${AndIf} $1 != "$0"
            StrCpy $1 "$1;$0"
        ${Else}
            Pop $1
            Return
        ${EndIf}
    ${Else}
        StrCpy $1 "$0"
    ${EndIf}
    WriteRegExpandStr HKCU "Environment" "Path" $1
    System::Call 'Kernel32::SendMessageTimeout(i 0xffff, i ${WM_SETTINGCHANGE}, i 0, t "Environment", i 0, i 1000, *i .r0)'
    Pop $1
FunctionEnd

Function GetInstalledSize
	Push $0
	Push $1
	StrCpy $GetInstalledSize.total 0
	${ForEach} $1 0 256 + 1
		${if} ${SectionIsSelected} $1
			SectionGetSize $1 $0
			IntOp $GetInstalledSize.total $GetInstalledSize.total + $0
		${Endif}
		${if} ${errors}
			${break}
		${Endif}
	${Next}
	ClearErrors
	Pop $1
	Pop $0
	IntFmt $GetInstalledSize.total "0x%08X" $GetInstalledSize.total
	Push $GetInstalledSize.total
FunctionEnd

Function LaunchApp
	ExecShell "" "$INSTDIR\${APPFILE}"
FunctionEnd

;--------------------------------
; FUNCIONES DESINSTALACIÓN

${unStrRep}

Function un.ConfirmTools
    nsDialogs::Create 1018
    Pop $0
    ${NSD_CreateLabel} 0 0 100% 12u "Desinstalar las Herramientas externas"
    Pop $1
    ${NSD_CreateCheckbox} 0 16u 100% 12u "Remover todas"
    Pop $un_ToolsCheckbox
    nsDialogs::Show
FunctionEnd

Function un.ReadToolsChoice
	${NSD_GetState} $un_ToolsCheckbox $un_ToolsCheckboxState
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

Function un.RemoveFromUserPath
    Exch $0
    Push $1
    Push $2
    ReadRegStr $1 HKCU "Environment" "Path"
    StrCpy $2 "$1"
    Push "$2"
    Push "$0;"
	${unStrRep} $1 "$2" "$0" ""
    WriteRegExpandStr HKCU "Environment" "Path" "$1"
    System::Call 'Kernel32::SendMessageTimeout(i 0xffff, i ${WM_SETTINGCHANGE}, i 0, t "Environment", i 0, i 1000, *i .r0)'
    Pop $2
    Pop $1
FunctionEnd

;--------------------------------
; MACROS

!macro DownloadAndExtract TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_TO_PATH
Section "${TOOL_NAME}" SEC_${TOOL_ID}
    AddSize ${TOOL_SIZE_KB}
    SetOutPath "$TEMP"
    inetc::get /TIMEOUT=30000 /RESUME "" "https://$SERVER/phpsinergia/herramientas/${TOOL_ID}.zip" "$TEMP\${TOOL_ID}.zip" /END
    Pop $0
    StrCmp $0 "OK" +3
        MessageBox MB_ICONSTOP "Error al descargar ${TOOL_NAME}: $0"
        Abort
    CreateDirectory "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    SetOutPath "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Nsisunz::UnzipToLog "$TEMP\${TOOL_ID}.zip" "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Pop $0
    StrCmp $0 "success" +2
        MessageBox MB_ICONSTOP "Error al descomprimir ${TOOL_NAME}: $0"
    Delete "$TEMP\${TOOL_ID}.zip"
    ${If} ${ADD_TO_PATH} = 1
        Push "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
        Call AddToUserPath
    ${EndIf}
SectionEnd
!macroend

!macro UninstallTool TOOL_ID
    RMDir /r "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Push "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Call un.RemoveFromUserPath
!macroend

;--------------------------------
; SECCIONES

Section "Mi Ayudante"
	SectionIn RO
	SetOutPath "$INSTDIR"
	IfFileExists $INSTDIR\config.ini +2 0
		File "config.ini"
	WriteINIStr $INSTDIR\config.ini Base RutaHerramientas $INSTDRIVE\${TOOLS}
	WriteINIStr $INSTDIR\config.ini Base Lanzamiento ${VERSION}
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
	IfFileExists $INSTDIR\datos\basico_proyectos.txt +2 0
		File /oname=basico_proyectos.txt ${APPDIR}\base\proyectos.txt
	CreateDirectory "$INSTDIR\entornos\basico"
	SetOutPath "$INSTDIR\entornos\basico"
	File /r "${APPDIR}\base\entorno\*.*"
	CreateDirectory "$INSTDRIVE\${VENDOR}"
	CreateDirectory "$INSTDRIVE\${TOOLS}"
	SetOutPath "$INSTDRIVE\${TOOLS}"
	SetOutPath "$INSTDIR"
	Call GetInstalledSize
	Pop $0
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Tools_Dir" "$INSTDRIVE\${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "Vendor_Dir" "$INSTDRIVE\${VENDOR}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDIR\${UNINSTALL}"
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$0"
	WriteUninstaller "$INSTDIR\${UNINSTALL}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
SectionEnd

SectionGroup "Herramientas externas"
	!insertmacro GenerateToolSections
SectionGroupEnd

Section "Uninstall"
	StrCpy $INSTDRIVE $INSTDIR 2
	Delete "$INSTDIR\config.ini"
	Delete "$INSTDIR\${LICENSE}"
	Delete "$INSTDIR\${APPFILE}"
	Delete "$INSTDIR\${README}"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}.lnk"
	RMDir /r "$INSTDIR"
	${RMDirUP} "$INSTDIR"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	StrCmp $un_ToolsCheckboxState "1" 0 Done
	!insertmacro UninstallAllTools
Done:
SectionEnd
