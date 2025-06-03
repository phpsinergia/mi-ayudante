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
; VARIABLES

Var INSTDRIVE
Var SERVER
Var FTP_USER
Var FTP_PASS
Var PROTOCOL
Var GetInstalledSize.total
Var IsUpdateInstall
Var ServerInput
Var DriveCombo
Var FtpUserInput
Var FtpPassInput
Var ProtocolCombo
Var un_ToolsCheckboxState
Var un_ToolsCheckbox

;--------------------------------
; DEFINICIONES BÁSICAS

!define VERSION "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Rubén Araya Tagle"
!define APPFILE "ayudante.exe"
!define TARGET "\home\mi-ayudante"
!define TOOLS "\home\herramientas"
!define LICENSEFILE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"
!define UNINSTALL "Desinstalar.exe"
!define INSTALL "..\dist\mi-ayudante_${VERSION}.exe"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"

;--------------------------------
; DEFINICIONES INTERFAZ

!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "${NAME} v${VERSION}"
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

VIProductVersion ${VERSION}.0
VIAddVersionKey /LANG=0 "ProductName" "${NAME}"
VIAddVersionKey /LANG=0 "ProductVersion" "${VERSION}"
VIAddVersionKey /LANG=0 "FileVersion" ${VERSION}
VIAddVersionKey /LANG=0 "FileDescription" "Instalador de ${NAME} para Windows"
VIAddVersionKey /LANG=0 "LegalCopyright" "${PUBLISHER}"

;--------------------------------
; MACROS

!macro UninstallTool TOOL_ID
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Call un.RemoveFromEnvUserPath
!macroend

!macro GenerateSectionTool TOOL_ID TOOL_NAME TOOL_SIZE TOOL_ADD_PATH
Section /o "${TOOL_NAME}" ${SEC_${TOOL_ID}}
	!insertmacro HandleDownloadAndExtractTool ${TOOL_ID} "${TOOL_NAME}" ${TOOL_SIZE} ${TOOL_ADD_PATH}
SectionEnd
!macroend

!macro HandleDownloadAndExtractTool TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_TO_PATH
	AddSize ${TOOL_SIZE_KB}
	SetOutPath "$TEMP"
	IfFileExists "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.*" 0 +2
		Goto SkipTool_${TOOL_ID}
	StrCmp $PROTOCOL "FTP" 0 +4
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"$INSTDRIVE${TOOLS}\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip"'
		Goto +3
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		inetc::get /TIMEOUT=30000 /RESUME "" "$R0" "$TEMP\${TOOL_ID}.zip" /END
	Pop $0
	StrCmp $0 "OK" +2
	MessageBox MB_OK "$0"
	;	MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} desde $R0. Puede instalarlo después."
	;	Abort
	CreateDirectory "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	SetOutPath "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Nsisunz::UnzipToLog "$TEMP\${TOOL_ID}.zip" "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Pop $0
	StrCmp $0 "success" +2
		MessageBox MB_ICONSTOP "Error al descomprimir ${TOOL_NAME}: $0"
	Delete "$TEMP\${TOOL_ID}.zip"
	${If} ${ADD_TO_PATH} = 1
		Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		Call AddToEnvUserPath
	${EndIf}
SkipTool_${TOOL_ID}:
!macroend

!macro AutoSelectTool TOOL_ID SEC_ID READONLY
    IfFileExists "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.*" 0 +9
        SectionSetFlags ${SEC_ID} ${SF_SELECTED}
        ${If} "${READONLY}" == "1"
            IntOp $0 ${SF_SELECTED} | ${SF_RO}
            SectionSetFlags ${SEC_ID} $0
        ${ElseIf} "${READONLY}" == "2"
            IntOp $0 0 | ${SF_RO}
            SectionSetFlags ${SEC_ID} $0
        ${EndIf}
!macroend

!include "tools.nsh"

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
LicenseBkColor /windows
PageEx license
	PageCallbacks SkipLicenseIfUpdate ""
	LicenseData "..\${LICENSEFILE}"
	LicenseText "Si acepta todos los términos del acuerdo, seleccione ACEPTO para continuar.$\nDebe aceptar el acuerdo para instalar ${NAME}." "ACEPTO"
	Caption " "
PageExEnd
PageEx custom
	PageCallbacks ConfigForm SaveConfigForm
	Caption " "
PageExEnd
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ConfirmUnTools un.ReadUnToolsChoice
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES: INSTALACIÓN

Function .onInit
	StrCpy $INSTDRIVE $EXEPATH 2
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	ReadRegStr $1 HKCU "Software\${NAME}" "Install_Drive"
	ReadRegStr $SERVER HKCU "Software\${NAME}" "FTP_Server"
	ReadRegStr $FTP_USER HKCU "Software\${NAME}" "FTP_User"
	ReadRegStr $FTP_PASS HKCU "Software\${NAME}" "FTP_Pass"
	ReadRegStr $PROTOCOL HKCU "Software\${NAME}" "Protocol"
	StrCpy $IsUpdateInstall "0"
	${If} $0 != ""
		StrCpy $IsUpdateInstall "1"
		StrCpy $INSTDIR $0
		${If} $1 != ""
			StrCpy $INSTDRIVE $1
		${EndIf}
		MessageBox MB_ICONINFORMATION "Ya existe una instalación en:$\n$INSTDRIVE$0$\n$\nSe actualizarán los componentes que seleccione."
		Call CheckSelectAllTools
	${EndIf}
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${Else}
		!insertmacro MUI_HEADER_TEXT "Acuerdo de Licencia" "Por favor revise los términos de la licencia antes de instalar el software"
	${EndIf}
FunctionEnd

Function ConfigForm
	${If} $IsUpdateInstall == "1"
		Abort
	${Else}
		!insertmacro MUI_HEADER_TEXT "Opciones de instalación" "Indique los datos necesarios para descargar y copiar los archivos"
	${EndIf}
	${If} $PROTOCOL == ""
		StrCpy $PROTOCOL "HTTP"
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
	${NSD_CB_AddString} $ProtocolCombo "HTTP"
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
	nsDialogs::Show
FunctionEnd

Function SaveConfigForm
	${NSD_GetText} $DriveCombo $0
	StrCpy $INSTDRIVE $0 2
	${NSD_GetText} $ServerInput $SERVER
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${NSD_GetText} $ProtocolCombo $PROTOCOL
	${If} $SERVER == ""
		MessageBox MB_ICONEXCLAMATION "Debe indicar el Dominio del Servidor"
		Abort
	${Endif}
FunctionEnd

Function AddToEnvUserPath
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
	ExecShell "" "$INSTDRIVE$INSTDIR\${APPFILE}"
FunctionEnd

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

${unStrRep}

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $INSTDRIVE $0
FunctionEnd

Function un.ConfirmUnTools
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "¿Desea Desinstalar las Herramientas externas?"
	Pop $1
	${NSD_CreateCheckbox} 0 16u 100% 12u "Remover todas"
	Pop $un_ToolsCheckbox
	nsDialogs::Show
FunctionEnd

Function un.ReadUnToolsChoice
	${NSD_GetState} $un_ToolsCheckbox $un_ToolsCheckboxState
FunctionEnd

Function un.RemoveFromEnvUserPath
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
; SECCIONES

Section "!Mi Ayudante (requerido)"
	SectionIn RO
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
	IfFileExists "$INSTDRIVE${TOOLS}\curl.exe" +2 0
		File "..\bin\curl.exe"
;Actualización de config.ini
	SetOutPath "$INSTDRIVE$INSTDIR"
	IfFileExists "$INSTDRIVE$INSTDIR\config.ini" +2 0
		File "config.ini"
	WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base RutaHerramientas $INSTDRIVE${TOOLS}
	WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base Lanzamiento ${VERSION}
;Creación de accesos directos
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
SectionEnd

SectionGroup "Herramientas externas"
	!insertmacro GenerateAllSectionTools
SectionGroupEnd

Section "-Registro"
	Call GetInstalledSize
	Pop $1
;Actualización de Registro
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$INSTDRIVE"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "FTP_User" "$FTP_USER"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Pass" "$FTP_PASS"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDRIVE$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDRIVE$INSTDIR\${UNINSTALL}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
;Creación de Desinstalador
	WriteUninstaller "$INSTDRIVE$INSTDIR\${UNINSTALL}"
SectionEnd

Section "Uninstall"
	Delete "$INSTDIR\config.ini"
	Delete "$INSTDIR\${LICENSEFILE}.txt"
	Delete "$INSTDIR\${APPFILE}"
	Delete "$INSTDIR\${README}"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}.lnk"
	Delete "$INSTDRIVE${TOOLS}\curl.exe"
	RMDir /r "$INSTDIR"
	${RMDirUP} "$INSTDIR"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	StrCmp $un_ToolsCheckboxState "1" 0 Done
	!insertmacro UninstallAllTools
Done:
SectionEnd
