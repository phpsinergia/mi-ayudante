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
; VARIABLES GLOBALES

Var INSTDRIVE
Var SERVER
Var FTP_USER
Var FTP_PASS
Var PROTOCOL
Var FULL_PATH
Var TotalInstalledSize
Var IsUpdateInstall
Var ServerInput
Var DriveCombo
Var FtpUserInput
Var FtpPassInput
Var ProtocolCombo
Var SkipPre
Var RememberCredsCheckbox
Var RememberCreds
Var SkipPreCheckbox
Var un_ToolsCheckboxState
Var un_ToolsCheckbox

;--------------------------------
; DEFINICIONES MUI

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

${StrTrimNewLines}
${StrRep}
${StrStr}
${StrCase}
${unStrTrimNewLines}
${unStrRep}
${unStrStr}

!macro UninstallTool TOOL_ID
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Call un.RemoveFromEnvUserPath
!macroend

!macro GenerateSectionTool TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_TO_PATH
Section /o "${TOOL_NAME}" ${SEC_${TOOL_ID}}
	AddSize ${TOOL_SIZE_KB}
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	SetOutPath "$TEMP"
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"$TEMP\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} (FTP):$\n$R2"
			Goto SkipTool_${TOOL_ID}
		${EndIf}
	${Else}
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		inetc::get /TIMEOUT=30000 /RESUME "" "$R0" "$TEMP\${TOOL_ID}.zip" /END
		Pop $R1
		${If} $R1 != "OK"
			MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} (HTTP):$\n$R1"
			Goto SkipTool_${TOOL_ID}
		${EndIf}
	${EndIf}
	StrCpy $R7 "$TEMP\${TOOL_ID}_tmp"
	RMDir /r "$R7"
	CreateDirectory "$R7"
	SetOutPath "$R7"
	Nsisunz::UnzipToLog "$TEMP\${TOOL_ID}.zip" "$R7"
	Pop $R1
	${If} $R1 != "success"
		MessageBox MB_ICONSTOP "Error al descomprimir ${TOOL_NAME}: $R1"
		RMDir /r "$R7"
		Delete "$TEMP\${TOOL_ID}.zip"
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	${GetSize} "$R7" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - ${TOOL_SIZE_KB}
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 Tag_Mismatch_${TOOL_ID}
	Goto Tag_OK_${TOOL_ID}
Tag_Mismatch_${TOOL_ID}:
	MessageBox MB_ICONEXCLAMATION \
		"Tamaño incorrecto ($R4 KB ≠ ${TOOL_SIZE_KB} KB) en ${TOOL_NAME}"
	RMDir /r "$R7"
	Delete "$TEMP\\${TOOL_ID}.zip"
	Goto SkipTool_${TOOL_ID}
Tag_OK_${TOOL_ID}:
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\${TOOL_ID}\"
		RMDir /r "$R7"
	${EndIf}
	Delete "$TEMP\${TOOL_ID}.zip"
	${If} ${ADD_TO_PATH} == 1
		Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		Call AddToEnvUserPath
	${EndIf}
SkipTool_${TOOL_ID}:
SectionEnd
!macroend

!macro CheckIfInstalledTool TOOL_ID SEC_ID OPT_CHECK
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
		SectionSetFlags ${SEC_ID} ${SF_SELECTED}
		${If} "${OPT_CHECK}" == "1"
			IntOp $0 ${SF_SELECTED} | ${SF_RO}
			SectionSetFlags ${SEC_ID} $0
		${ElseIf} "${OPT_CHECK}" == "2"
			IntOp $0 0 | ${SF_RO}
			SectionSetFlags ${SEC_ID} $0
		${EndIf}
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
PageEx custom
	PageCallbacks CheckPreRequisites LeavePreRequisites
	Caption " "
PageExEnd
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ConfirmUnTools un.ReadUnToolsChoice
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_LANGUAGE "Spanish"

;--------------------------------
; FUNCIONES: INSTALACIÓN

Function .onInit
	GetFullPathName $FULL_PATH $EXEPATH
	StrCpy $INSTDRIVE $FULL_PATH 2
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	ReadRegStr $1 HKCU "Software\${NAME}" "Install_Drive"
	ReadRegStr $2 HKCU "Software\${NAME}" "SkipPre"
	ReadRegStr $SERVER HKCU "Software\${NAME}" "FTP_Server"
	ReadRegStr $FTP_USER HKCU "Software\${NAME}" "FTP_User"
	ReadRegStr $FTP_PASS HKCU "Software\${NAME}" "FTP_Pass"
	ReadRegStr $PROTOCOL HKCU "Software\${NAME}" "Protocol"
	StrCpy $SkipPre "0"
	${If} $2 != ""
		StrCpy $SkipPre $2
	${EndIf}
	StrCpy $IsUpdateInstall "0"
	${If} $0 != ""
		StrCpy $IsUpdateInstall "1"
		StrCpy $INSTDIR $0
		${If} $1 != ""
			StrCpy $INSTDRIVE $1
		${EndIf}
		MessageBox MB_ICONINFORMATION "Ya existe una instalación en:$\n$INSTDRIVE$0$\n$\nSe actualizarán los componentes que seleccione."
		SectionSetFlags 0 ${SF_SELECTED}
		Call CheckIfInstalledAllTools
	${EndIf}
	ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
	${If} $RememberCreds == ""
		StrCpy $RememberCreds 0
	${EndIf}
	SetOutPath "$TEMP"
	File "..\bin\curl.exe"
FunctionEnd

Function .onInstFailed
	Delete "$TEMP\curl.exe"
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${Else}
		!insertmacro MUI_HEADER_TEXT "Acuerdo de Licencia" "Por favor revise los términos de la licencia antes de instalar el software"
	${EndIf}
FunctionEnd

Function CheckPreRequisites
	${If} $SkipPre == "1"
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Comprobación de Pre-requisitos" "Debe tener instalados PHP y Composer en su sistema, junto con MySQL y un Editor de texto"
	nsDialogs::Create 1018
	Pop $0

	;TODO: Aquí falta añadir el diagnóstico real

	${NSD_CreateCheckbox} 15u 40u 250u 10u "No volver a mostrar esta página"
	Pop $SkipPreCheckbox
	${If} $SkipPre == "1"
		${NSD_Check} $SkipPreCheckbox
	${EndIf}
	nsDialogs::Show
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPre
FunctionEnd

Function ConfigForm
	${If} $PROTOCOL == ""
		StrCpy $PROTOCOL "HTTP"
	${EndIf}
	${If} $IsUpdateInstall == "1"
		${If} $PROTOCOL == "FTP"
		${AndIf} $FTP_USER == ""
		${AndIf} $FTP_PASS == ""
			Goto FormCreate
		${Else}
			Abort
		${EndIf}
	${EndIf}
FormCreate:
	!insertmacro MUI_HEADER_TEXT "Opciones de instalación" "Indique los datos necesarios para descargar y copiar los archivos"
	nsDialogs::Create 1018
	Pop $0
	${If} $0 == error
		Abort
	${EndIf}
	;=== Grupo: Configuración de descarga
	${NSD_CreateGroupBox} 5u 2u 290u 95u "Configuración de descargas"
	Pop $1
	${NSD_CreateLabel} 15u 17u 100u 10u "Protocolo:"
	Pop $1
	${NSD_CreateComboBox} 120u 15u 100u 12u ""
	Pop $ProtocolCombo
	${NSD_CB_AddString} $ProtocolCombo "HTTP"
	${NSD_CB_AddString} $ProtocolCombo "FTP"
	${NSD_CB_SelectString} $ProtocolCombo "$PROTOCOL"
	${NSD_CreateLabel} 15u 33u 100u 10u "Dominio del servidor:"
	Pop $1
	${NSD_CreateText} 120u 31u 100u 12u "$SERVER"
	Pop $ServerInput
	${NSD_CreateLabel} 15u 49u 100u 10u "Usuario FTP:"
	Pop $1
	${NSD_CreateText} 120u 47u 100u 12u "$FTP_USER"
	Pop $FtpUserInput
	${NSD_CreateLabel} 15u 66u 100u 10u "Contraseña FTP:"
	Pop $1
	${NSD_CreatePassword} 120u 63u 100u 12u "$FTP_PASS"
	Pop $FtpPassInput
	${NSD_CreateCheckbox} 120u 80u 100u 10u "Recordar credenciales"
	Pop $RememberCredsCheckbox
	${If} $RememberCreds == 1
		${NSD_Check} $RememberCredsCheckbox
	${EndIf}
	${NSD_CreateButton} 230u 76u 50u 14u "Probar"
	Pop $0
	${NSD_OnClick} $0 TestFtpConnection
	;=== Grupo: Unidad de instalación
	${NSD_CreateGroupBox} 5u 100u 290u 38u "Ruta de instalación"
	Pop $1
	${NSD_CreateLabel} 15u 118u 100u 10u "Unidad de destino:"
	Pop $1
	${NSD_CreateComboBox} 120u 116u 100u 14u ""
	Pop $DriveCombo
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
	System::Int64Op $R3 / 1073741824
	Pop $R4
	${If} $R4 != ""
		StrCpy $R5 "$R0:\ ($R4 GB libres)"
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
	${NSD_GetState} $RememberCredsCheckbox $RememberCreds
	${If} $PROTOCOL == "FTP"
		${If} $FTP_USER == ""
		${OrIf} $FTP_PASS == ""
			MessageBox MB_ICONEXCLAMATION "Debe indicar Usuario y Contraseña FTP"
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

Function TestFtpConnection
	${NSD_GetText} $DriveCombo $0
	StrCpy $INSTDRIVE $0 2
	${NSD_GetText} $ServerInput $SERVER
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${NSD_GetText} $ProtocolCombo $PROTOCOL
	${If} $PROTOCOL != "FTP"
		MessageBox MB_OK "La prueba de conexión sólo aplica para FTP"
		Return
	${EndIf}
	nsExec::ExecToStack '"$TEMP\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "ftp://$SERVER" --silent --list-only --connect-timeout 5'
	Pop $R0
	Pop $R1
	${If} $R0 == 0
		MessageBox MB_ICONINFORMATION "Conexión Exitosa!!!"
	${Else}
		MessageBox MB_ICONSTOP "No se pudo conectar al servidor FTP $SERVER:$\n$R1"
	${EndIf}
FunctionEnd

Function GetInstalledSize
	Push $0
	Push $1
	StrCpy $TotalInstalledSize 0
	${ForEach} $1 0 256 + 1
		${if} ${SectionIsSelected} $1
			SectionGetSize $1 $0
			IntOp $TotalInstalledSize $TotalInstalledSize + $0
		${Endif}
		${if} ${errors}
			${break}
		${Endif}
	${Next}
	ClearErrors
	Pop $1
	Pop $0
	IntFmt $TotalInstalledSize "0x%08X" $TotalInstalledSize
	Push $TotalInstalledSize
FunctionEnd

Function LaunchApp
	Delete "$TEMP\curl.exe"
	IfFileExists "$INSTDRIVE$INSTDIR\${APPFILE}" 0 +3
		ExecShell "" "$INSTDRIVE$INSTDIR\${APPFILE}"
		Return
	MessageBox MB_ICONSTOP "No se encontró el ejecutable ${APPFILE}.$\nEjecute nuevamente el instalador."
FunctionEnd

Function AddToEnvUserPath
	Exch $0
	Push $1
	Push $2
	Push $3
	${StrTrimNewLines} $0 $0
	${StrRep} $0 $0 '"' ''
	${If} $0 == ""
		Goto EndAdd
	${EndIf}
	ReadRegStr $1 HKCU "Environment" "Path"
	StrCpy $2 ";$1;"
	StrCpy $3 ";$0;"
	${StrCase} $2 $2 U
	${StrCase} $3 $3 U
	${StrStr} $2 $2 $3
	${If} $2 != ""
		Goto CleanAndSave
	${EndIf}
	StrLen $2 $1
	${If} $2 > 0
		IntOp $2 $2 - 1
		StrCpy $3 $1 1 $2
	${Else}
		StrCpy $3 ""
	${EndIf}
	${If} $3 == ";"
		StrCpy $1 "$1$0"
	${ElseIf} $1 == ""
		StrCpy $1 "$0"
	${Else}
		StrCpy $1 "$1;$0"
	${EndIf}
CleanAndSave:
LoopClean:
	${StrStr} $2 $1 ";;"
	${If} $2 == ""
		Goto WriteAndBroadcast
	${EndIf}
	${StrRep} $1 $1 ";;" ";"
	Goto LoopClean
WriteAndBroadcast:
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndAdd:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

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

Function un.RemoveIfEmpty
	Exch $0
	IfFileExists "$0\*\*.*" 0 +2
		Return
	RMDir "$0"
FunctionEnd

Function un.RemoveFromEnvUserPath
	Exch $0
	Push $1
	Push $2
	Push $3
	${unStrTrimNewLines} $0 $0
	${unStrRep} $0 $0 '"' ''
	ReadRegStr $1 HKCU "Environment" "Path"
	${If} $1 == ""
		Goto EndRm
	${EndIf}
	${unStrRep} $1 "$1" ";$0;" ";"
	${unStrRep} $1 "$1" "$0;" ""
	${unStrRep} $1 "$1" ";$0" ""
LoopCleanRm:
	${unStrStr} $2 $1 ";;"
	${If} $2 == ""
		Goto TrimEnds
	${EndIf}
	${unStrRep} $1 $1 ";;" ";"
	Goto LoopCleanRm
TrimEnds:
	${If} $1 != ""
		StrCpy $2 $1 1
		${If} $2 == ";"
			StrCpy $1 $1 "" 1
		${EndIf}
		StrLen $2 $1
		${If} $2 > 0
			IntOp $2 $2 - 1
			StrCpy $3 $1 1 $2
			${If} $3 == ";"
				StrCpy $1 $1 $2
			${EndIf}
		${EndIf}
	${EndIf}
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndRm:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

;--------------------------------
; SECCIONES

Section "!Mi Ayudante (*)"
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
	${If} $IsUpdateInstall == "0"
		Call GetInstalledSize
		Pop $1
		WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	${Else}
		${GetSize} "$INSTDRIVE\home" "/S=0K" $1 $R7 $R8
		IntFmt $1 "0x%08X" $1
		WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	${EndIf}
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$INSTDRIVE"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "Software\${NAME}" "SkipPre" "$SkipPre"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDRIVE$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "${VERSION}"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$INSTDRIVE$INSTDIR\${UNINSTALL}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	${If} $RememberCreds == 1
		WriteRegStr HKCU "Software\${NAME}" "FTP_User" "$FTP_USER"
		WriteRegStr HKCU "Software\${NAME}" "FTP_Pass" "$FTP_PASS"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "FTP_User"
		DeleteRegValue HKCU "Software\${NAME}" "FTP_Pass"
	${EndIf}
	StrCpy $FTP_USER ""
	StrCpy $FTP_PASS ""
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
	RMDir /r "$INSTDIR"
	${RMDirUP} "$INSTDIR"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	StrCmp $un_ToolsCheckboxState "1" 0 Done
	!insertmacro UninstallAllTools
	Push "$INSTDRIVE${TOOLS}"
	Call un.RemoveIfEmpty
Done:
SectionEnd
