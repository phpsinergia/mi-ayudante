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
Var DriveDropList
Var FtpUserInput
Var FtpPassInput
Var ProtocolDropList
Var SkipPre
Var RememberCredsCheckbox
Var RememberCreds
Var SkipPreCheckbox
Var TextWelcome
Var TitleWelcome
Var TextCaption
Var un_ToolsCheckboxState
Var un_ToolsCheckbox
Var hDriveDropList
Var tmpGB
Var btnTest

;--------------------------------
; DEFINICIONES MUI

!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "$TitleWelcome"
!define MUI_WELCOMEPAGE_TEXT $TextWelcome
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
Caption $TextCaption
LicenseBkColor /windows

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

!include "tools.nsh"

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
PageEx license
	PageCallbacks SkipLicenseIfUpdate ""
	LicenseData "..\${LICENSEFILE}"
	LicenseText "Si acepta todos los términos del acuerdo, seleccione ACEPTO para continuar.$\nDebe aceptar el acuerdo para poder instalar ${NAME}." "ACEPTO"
	Caption " "
PageExEnd
Page custom ShowConfigForm SaveConfigForm " "
Page custom CheckPreRequisites LeavePreRequisites " "
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
UninstPage custom un.ShowOptionsUninstall un.ReadChoiceUninstall
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
		StrCpy $TextCaption "Actualización de ${NAME}"
		StrCpy $TitleWelcome "Actualizar ${NAME} v${VERSION}"
		StrCpy $TextWelcome "Este programa ACTUALIZARÁ el software ${NAME} que está instalado en:$\n$\n$INSTDRIVE$0$\n$\nPodrá agregar nuevos componentes o restaurar los existentes, sin perder sus configuraciones y datos.$\n$\n$\nPresione Siguiente para continuar."
		SectionSetFlags 0 0
		Call CheckIfInstalledAllTools
	${Else}
		StrCpy $TextCaption "Instalación de ${NAME}"
		StrCpy $TitleWelcome "Instalar ${NAME} v${VERSION}"
		StrCpy $TextWelcome "Este programa INSTALARÁ el software ${NAME} en su computadora.$\n$\nSe recomienda que cierre todas las demás aplicaciones antes de iniciar la instalación. Esto hará posible actualizar archivos relacionados con el sistema sin tener que reiniciar el equipo.$\n$\n$\nPresione Siguiente para continuar."
		IntOp $3 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags 0 $3
	${EndIf}
	ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
	${If} $RememberCreds != "1"
		StrCpy $RememberCreds "0"
	${EndIf}
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Acuerdo de Licencia" "Por favor revise los términos de la licencia antes de instalar el software."
FunctionEnd

Function CheckPreRequisites
	${If} $SkipPre == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "Comprobación de Pre-requisitos" "Debe tener instalados PHP y Composer en su computadora local."

	;TODO: Aquí falta añadir el diagnóstico real

	${NSD_CreateCheckbox} 15u 40u 250u 10u "No volver a mostrar esta página"
	Pop $SkipPreCheckbox
	nsDialogs::Show
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPre
FunctionEnd

Function ShowConfigForm
	nsDialogs::Create 1018
	Pop $0
	${If} $PROTOCOL == ""
		StrCpy $PROTOCOL "---"
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "Opciones de instalación" \
		"Indique los datos necesarios para descargar y copiar los componentes."
	;------------------------------------------------------------
	; 1. Grupo: **Ruta de instalación**
	${NSD_CreateGroupBox} 5u 2u 290u 38u "Ruta de instalación"
	Pop $0
		${NSD_CreateLabel}   15u 18u 100u 10u "Unidad de destino:"
		Pop $0
		; Drop-list NO editable
		${NSD_CreateDropList} 120u 16u 100u 14u ""
		Pop $DriveDropList
		StrCpy $hDriveDropList $DriveDropList
		Call FillDriveList
		${NSD_CB_SelectString} $DriveDropList "$INSTDRIVE\"
		${If} $IsUpdateInstall == "1"
			System::Call 'user32::EnableWindow(p$DriveDropList,i0)'
		${EndIf}
	;------------------------------------------------------------
	; 2. Grupo: **Configuración de descargas**
	${NSD_CreateGroupBox} 5u 46u 290u 95u "Configuración de descargas"
	Pop $0
		${NSD_CreateLabel} 15u 61u 100u 10u "Protocolo:"
		Pop $0
		${NSD_CreateDropList} 120u 59u 100u 12u ""
		Pop $ProtocolDropList
			${NSD_CB_AddString} $ProtocolDropList "---"
			${NSD_CB_AddString} $ProtocolDropList "HTTP"
			${NSD_CB_AddString} $ProtocolDropList "FTP"
			${NSD_CB_SelectString} $ProtocolDropList "$PROTOCOL"
		${NSD_CreateLabel} 15u 77u 100u 10u "Dominio del servidor:"
		Pop $0
		${NSD_CreateText} 120u 75u 100u 12u "$SERVER"
		Pop $ServerInput
		${NSD_CreateLabel} 15u 93u 100u 10u "Usuario FTP:"
		Pop $0
		${NSD_CreateText} 120u 91u 100u 12u "$FTP_USER"
		Pop $FtpUserInput
		${NSD_CreateLabel} 15u 109u 100u 10u "Contraseña FTP:"
		Pop $0
		${NSD_CreatePassword} 120u 107u 100u 12u "$FTP_PASS"
		Pop $FtpPassInput
		${NSD_CreateCheckbox} 120u 124u 100u 10u "Recordar credenciales"
		Pop $RememberCredsCheckbox
		${If} $RememberCreds == "1"
			${NSD_Check} $RememberCredsCheckbox
		${EndIf}
		${NSD_CreateButton} 230u 120u 50u 14u "Probar"
		Pop $btnTest
		${NSD_OnClick} $btnTest TestConnection
	nsDialogs::Show
FunctionEnd

Function SaveConfigForm
	${NSD_GetText} $DriveDropList $0
	StrCpy $INSTDRIVE $0 2
	${NSD_GetText} $ServerInput $SERVER
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${NSD_GetText} $ProtocolDropList $PROTOCOL
	${If} $SERVER == ""
	${AndIf} $PROTOCOL != "---"
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

Function TestConnection
	${NSD_GetText} $ServerInput $SERVER
	${If} $SERVER == ""
		MessageBox MB_ICONEXCLAMATION "Debe indicar el Dominio del Servidor"
		Return
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i0)'
	${NSD_GetText} $ProtocolDropList $PROTOCOL
	${If} $PROTOCOL == "FTP"
		Call TestFtpConnection
	${ElseIf} $PROTOCOL == "HTTP"
		Call TestHttpConnection
	${Else}
		MessageBox MB_ICONEXCLAMATION "Seleccione un Protocolo (HTTP o FTP) para realizar la prueba."
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i1)'
FunctionEnd

Function TestFtpConnection
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${If} $FTP_USER == ""
	${OrIf} $FTP_PASS == ""
		MessageBox MB_ICONEXCLAMATION "Debe indicar Usuario y Contraseña FTP"
		Return
	${EndIf}
	nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "ftp://$SERVER" --silent --list-only --connect-timeout 5'
	Pop $R0
	Pop $R1
	${If} $R0 == 0
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "Conexión FTP exitosa."
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "Falló la conexión FTP a $SERVER:$\n$R1"
	${EndIf}
FunctionEnd

Function TestHttpConnection
	nsExec::ExecToStack '"curl.exe" -s -S -L -I --insecure --connect-timeout 5 --write-out "%{http_code}" -o NUL "https://$SERVER/herramientas/tools.json"'
	Pop $R1
	Pop $R0
	${If} $R0 == "200"
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND \
			"Conexión HTTP exitosa."
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND \
			"Falló la conexión HTTP a $SERVER:$\nRespuesta recibida: $R0"
	${EndIf}
FunctionEnd

Function FillDriveList
	${GetDrives} "ALL" AddDriveCallback
FunctionEnd

Function AddDriveCallback
	StrCpy $0 $9
	${DriveSpace} "$0" "/D=F" $1
	System::Int64Op $1 / 1073741824
	Pop $tmpGB
	${If} $tmpGB != ""
		StrCpy $2 "$0 ($tmpGB GB libres)"
		${NSD_CB_AddString} $hDriveDropList $2
	${EndIf}
	Push ""
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

Function LaunchApp
	IfFileExists "$INSTDRIVE$INSTDIR\${APPFILE}" 0 +3
		ExecShell "" "$INSTDRIVE$INSTDIR\${APPFILE}"
		Return
	MessageBox MB_ICONSTOP "No se encontró el programa ${APPFILE}.$\nEjecute nuevamente el instalador."
FunctionEnd

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $INSTDRIVE $0
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "¿Desea Desinstalar también las Herramientas externas?"
	Pop $1
	${NSD_CreateCheckbox} 0 16u 100% 12u "Remover todas"
	Pop $un_ToolsCheckbox
	nsDialogs::Show
FunctionEnd

Function un.ReadChoiceUninstall
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

Function un.RemoveDirIfEmpty
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
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
SectionEnd

SectionGroup /e "!Requisitos"
	Section "PHP 8"
		AddSize 99688
	SectionEnd
	Section "PhpSinergIA"
		AddSize 887
	SectionEnd
SectionGroupEnd

SectionGroup "Herramientas externas"
	!insertmacro GenerateAllSectionTools
SectionGroupEnd

Section "-Config"
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
	${If} $RememberCreds == "1"
		WriteRegStr HKCU "Software\${NAME}" "FTP_User" "$FTP_USER"
		WriteRegStr HKCU "Software\${NAME}" "FTP_Pass" "$FTP_PASS"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "FTP_User"
		DeleteRegValue HKCU "Software\${NAME}" "FTP_Pass"
	${EndIf}
	StrCpy $FTP_USER ""
	StrCpy $FTP_PASS ""
	${If} $IsUpdateInstall == "0"
		Call GetInstalledSize
		Pop $1
	${Else}
		${GetSize} "$INSTDRIVE\home" "/S=0K" $1 $R7 $R8
		IntFmt $1 "0x%08X" $1
	${EndIf}
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
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
	Call un.RemoveDirIfEmpty
Done:
SectionEnd
