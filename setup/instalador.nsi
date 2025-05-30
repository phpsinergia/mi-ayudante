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

;--------------------------------
; DEFINICIONES BÁSICAS

!define VERSION "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Rubén Araya Tagle"
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
!define MUI_WELCOMEPAGE_TITLE "${NAME} v${VERSION}"
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
Var FTP_USER
Var FTP_PASS
Var FtpUserInput
Var FtpPassInput
Var ProtocolCombo
Var PROTOCOL
Var IsUpdateInstall

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
;TODO: Falta Agregar una Page custom para info sobre Pre-requisitos
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ConfirmTools un.ReadToolsChoice
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES: INSTALACIÓN

Function .onInit
    StrCpy $IsUpdateInstall "0"
    ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
    ReadRegStr $1 HKCU "Software\${NAME}" "Install_Drive"
	ReadRegStr $SERVER HKCU "Software\${NAME}" "FTP_Server"
	ReadRegStr $FTP_USER HKCU "Software\${NAME}" "FTP_User"
	ReadRegStr $FTP_PASS HKCU "Software\${NAME}" "FTP_Pass"
	ReadRegStr $PROTOCOL HKCU "Software\${NAME}" "Protocol"
    ${If} $0 != ""
        StrCpy $INSTDIR $0
        StrCpy $INSTDRIVE $1
        StrCpy $IsUpdateInstall "1"
        MessageBox MB_ICONINFORMATION "Ya existe una instalación en: $0. Sólo se actualizarán los archivos faltantes."
    ${EndIf}
FunctionEnd

Function ConfigPage
	${If} $PROTOCOL == ""
		StrCpy $PROTOCOL "HTTPS"
    ${EndIf}
	${If} $INSTDRIVE == ""
		StrCpy $INSTDRIVE "C:"
    ${EndIf}
    nsDialogs::Create 1018
    Pop $0
    ${If} $0 == error
        Abort
    ${EndIf}
    ;=== Grupo: Configuración de descarga
    ${NSD_CreateGroupBox} 5u 5u 290u 90u "Configuración de descargas"
    Pop $1
    ${NSD_CreateLabel} 15u 23u 100u 10u "Protocolo:"
    Pop $1
    ${NSD_CreateComboBox} 120u 21u 100u 12u ""
    Pop $ProtocolCombo
    ${NSD_CB_AddString} $ProtocolCombo "HTTPS"
    ${NSD_CB_AddString} $ProtocolCombo "FTP"
    ${NSD_CB_SelectString} $ProtocolCombo "$PROTOCOL"
    ${NSD_CreateLabel} 15u 41u 100u 10u "Dominio del servidor:"
    Pop $1
    ${NSD_CreateText} 120u 39u 100u 12u "$SERVER"
    Pop $ServerInput
    ${NSD_CreateLabel} 15u 59u 100u 10u "Usuario FTP:"
    Pop $1
    ${NSD_CreateText} 120u 57u 100u 12u "$FTP_USER"
    Pop $FtpUserInput
    ${NSD_CreateLabel} 15u 77u 100u 10u "Contraseña FTP:"
    Pop $1
    ${NSD_CreatePassword} 120u 75u 100u 12u "$FTP_PASS"
    Pop $FtpPassInput
    ;=== Grupo: Unidad de instalación
    ${NSD_CreateGroupBox} 5u 100u 290u 38u "Ruta de instalación"
    Pop $1
    ${NSD_CreateLabel} 15u 118u 100u 10u "Unidad de destino:"
    Pop $1
    ${NSD_CreateComboBox} 120u 116u 100u 14u ""
    Pop $DriveCombo
    ; Enumerar unidades
    !insertmacro DriveSpace
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
    ${NSD_CB_SelectString} $DriveCombo "$INSTDRIVE\"
	Call PreSelectTools
    nsDialogs::Show
FunctionEnd

Function SaveConfigPage
    ${NSD_GetText} $DriveCombo $0
    StrCpy $INSTDRIVE $0 2
    StrCpy $INSTDIR "$INSTDRIVE\${TARGET}"
    ${NSD_GetText} $ServerInput $SERVER
    ${NSD_GetText} $FtpUserInput $FTP_USER
    ${NSD_GetText} $FtpPassInput $FTP_PASS
	${NSD_GetText} $ProtocolCombo $PROTOCOL
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
; FUNCIONES: DESINSTALACIÓN

${unStrRep}

Function un.ConfirmTools
    nsDialogs::Create 1018
    Pop $0
    ${NSD_CreateLabel} 0 0 100% 12u "¿Desea Desinstalar las Herramientas externas?"
    Pop $1
    ${NSD_CreateCheckbox} 0 16u 100% 12u "Remover todas"
    Pop $un_ToolsCheckbox
    nsDialogs::Show
FunctionEnd

Function un.ReadToolsChoice
	${NSD_GetState} $un_ToolsCheckbox $un_ToolsCheckboxState
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

;--------------------------------
; MACROS

!macro DownloadAndExtract TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_TO_PATH
Section /o "${TOOL_NAME}" SEC_${TOOL_ID}
    AddSize ${TOOL_SIZE_KB}
    SetOutPath "$TEMP"
	IfFileExists "$INSTDRIVE\${TOOLS}\${TOOL_ID}\*.*" 0 +2
		Goto SkipTool_${TOOL_ID}
	${If} $PROTOCOL == "FTP"
		;TODO: Corregir
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"$INSTDRIVE\${TOOLS}\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip"'
	${Else}
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		;MessageBox MB_OK "$R0"
		inetc::get /TIMEOUT=30000 /RESUME "" "$R0" "$TEMP\${TOOL_ID}.zip" /END
	${EndIf}
	Pop $0
    StrCmp $0 "OK" +3
		MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} desde $R0. Puede instalarlo después."
		Return
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
SkipTool_${TOOL_ID}:
SectionEnd
!macroend

!macro InstallTool TOOL_ID TOOL_NAME TOOL_SIZE TOOL_ADD_PATH
	!insertmacro DownloadAndExtract ${TOOL_ID} "${TOOL_NAME}" ${TOOL_SIZE} ${TOOL_ADD_PATH}
!macroend

!macro UninstallTool TOOL_ID
    RMDir /r "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Push "$INSTDRIVE\${TOOLS}\${TOOL_ID}"
    Call un.RemoveFromUserPath
!macroend

!macro AutoSelectTool TOOL_ID
	StrCpy $R0 "SEC_${TOOL_ID}"
    IfFileExists "$INSTDRIVE\${TOOLS}\${TOOL_ID}\*" 0 +3
		MessageBox MB_ICONINFORMATION "$R0"
		SectionSetFlags $R0 ${SF_SELECTED}
!macroend

!include "herramientas.nsh"

;--------------------------------
; SECCIONES

Section "!Mi Ayudante"
	SectionIn RO
;Creación de directorios
	CreateDirectory "$INSTDIR\compartidos"
	CreateDirectory "$INSTDIR\datos"
	CreateDirectory "$INSTDIR\entornos\basico"
	CreateDirectory "$INSTDIR\logs"
	CreateDirectory "$INSTDIR\respaldos"
	CreateDirectory "$INSTDRIVE\${VENDOR}"
	CreateDirectory "$INSTDRIVE\${TOOLS}"
;Copia selectiva de archivos
	SetOutPath "$INSTDIR\base"
	File /r "${APPDIR}\base\*.*"
	SetOutPath "$INSTDIR\img"
	File /r "${APPDIR}\img\*.*"
	SetOutPath "$INSTDIR"
	IfFileExists "$INSTDIR\${APPFILE}" +2 0
		File "${APPDIR}\${APPFILE}"
	IfFileExists "$INSTDIR\${README}" +2 0
		File "${APPDIR}\${README}"
	SetOutPath "$INSTDIR\datos"
	IfFileExists "$INSTDIR\datos\basico_proyectos.txt" +2 0
		File /oname=basico_proyectos.txt ${APPDIR}\base\proyectos.txt
	SetOutPath "$INSTDRIVE\${TOOLS}"
	IfFileExists "$INSTDRIVE\${TOOLS}\curl.exe" +2 0
		File "${SRCDRIVE}\${TOOLS}\curl.exe"
	SetOutPath "$INSTDIR\entornos\basico"
	IfFileExists "$INSTDIR\entornos\basico\config.ini" +2 0
		File /r "${APPDIR}\base\entorno\*.*"
;Actualización de config.ini
	SetOutPath "$INSTDIR"
	IfFileExists "$INSTDIR\config.ini" +2 0
		File "config.ini"
	WriteINIStr $INSTDIR\config.ini Base RutaHerramientas $INSTDRIVE\${TOOLS}
	WriteINIStr $INSTDIR\config.ini Base Lanzamiento ${VERSION}
;Creación de Desinstalador
	IfFileExists "$INSTDIR\${UNINSTALL}" +2 0
		WriteUninstaller "$INSTDIR\${UNINSTALL}"
;Creación de accesos directos
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDIR\${APPFILE}" "" "$INSTDIR\${ICON}"
SectionEnd

Section "-Registro"
	Call GetInstalledSize
	Pop $1
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$INSTDRIVE"
	WriteRegStr HKCU "Software\${NAME}" "Tools_Dir" "$INSTDRIVE\${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "Vendor_Dir" "$INSTDRIVE\${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "FTP_User" "$FTP_USER"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Pass" "$FTP_PASS"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDIR\${UNINSTALL}"
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
SectionEnd

SectionGroup "Herramientas externas"
	!insertmacro GenerateToolSections
SectionGroupEnd

SectionGroup "-Actualizaciones"
SectionGroupEnd

SectionGroup "-Extensiones"
SectionGroupEnd

SectionGroup "-Recursos"
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
	Delete "$INSTDRIVE\${TOOLS}\curl.exe"
	!insertmacro UninstallAllTools
Done:
SectionEnd
