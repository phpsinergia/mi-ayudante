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
!include "nsArray.nsh"

;--------------------------------
; DEFINICIONES BÁSICAS

!define RELEASE "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Rubén Araya Tagle"
!define APPFILE "ayudante.exe"
!define TARGET "\home\mi-ayudante"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define LICENSEFILE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"
!define UNINSTALL "Desinstalar.exe"
!define INSTALL "..\dist\mi-ayudante_${RELEASE}.exe"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define MAX_COMPS 32
!define MAX_REQS 5

;--------------------------------
; VARIABLES GLOBALES

Var VERSION
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
Var TitleWelcome
Var TextWelcome
Var TitleFinish
Var TextFinish
Var TextCaption
Var unToolsCheckboxState
Var unToolsCheckbox
Var hDriveDropList
Var tmpGB
Var btnTest
Var btnUninstall
Var i
Var ToolId
Var ToolName
Var ToolVer
Var ToolKb
Var ToolAdd
Var ToolChk
Var ToolIndice
Var ToolsCatalog
Var CompsTotal
Var ReqsTotal

;--------------------------------
; TEXTOS DE LA INTERFAZ

!define STR_DescripcionArchivo "Instalador de ${NAME} para Windows"
!define STR_TituloLicencia "Acuerdo de Licencia"
!define STR_SubtituloLicencia "Por favor revise los términos de la licencia antes de instalar el software."
!define STR_InstruccionesLicencia "Si acepta todos los términos del acuerdo, seleccione ACEPTO para continuar.$\nDebe aceptar el acuerdo para poder instalar ${NAME}."
!define STR_InstruccionesComponentes "Marque los componentes que desee instalar y desmarque aquellos que no desee. Presione Instalar para comenzar el proceso (requiere conexión a Internet)."
!define STR_EtiqEjecutarApp "Ejecutar ${NAME} ahora"
!define STR_EtiqRevisarNotas "Revisar notas en ${README}"
!define STR_BotonAcepto "ACEPTO"
!define STR_VentanaActualizador "Actualización de ${NAME}"
!define STR_VentanaInstalador "Instalación de ${NAME}"
!define STR_TituloWelcomeActualizador "Asistente para Actualizar$\n${NAME} v$VERSION"
!define STR_InstruccionesWelcomeActualizador "Este programa ACTUALIZARÁ el software ${NAME} que está instalado en:$\n$\n$INSTDRIVE$0$\n$\nPodrá agregar nuevos componentes o restaurar los existentes, sin perder sus configuraciones y datos.$\n$\n$\nPresione Siguiente para continuar."
!define STR_TituloFinishActualizador "Finalizando el Asistente para$\nActualizar ${NAME}"
!define STR_InstruccionesFinishActualizador "${NAME} ha sido actualizado en:$\n$\n$INSTDRIVE$0$\n$\nPresione Terminar para cerrar este asistente."
!define STR_TituloWelcomeInstalador "Asistente para Instalar$\n${NAME} v$VERSION"
!define STR_InstruccionesWelcomeInstalador "Este programa INSTALARÁ el software ${NAME} en su computadora.$\n$\nSe recomienda que cierre todas las demás aplicaciones antes de iniciar la instalación. Esto hará posible actualizar archivos relacionados con el sistema sin tener que reiniciar el equipo.$\n$\n$\nPresione Siguiente para continuar."
!define STR_TituloFinishInstalador "Finalizando el Asistente para$\nInstalar ${NAME}"
!define STR_InstruccionesFinishInstalador "${NAME} ha sido instalado en su computadora.$\n$\nPresione Terminar para cerrar este asistente."
!define STR_TituloInstFinalizada "Instalación completada"
!define STR_SubtituloInstCompletada "Se ha completado el proceso de instalación de ${NAME}."
!define STR_TituloInstCancelada "Instalación cancelada"
!define STR_SubtituloInstCancelada "La instalación fue cancelada por el usuario."
!define STR_TituloPrereq "Comprobación de Pre-requisitos"
!define STR_SubtituloPrereq "Debe tener instalados PHP y Composer en su computadora local."
!define STR_EtiqNomostrarDenuevo "No volver a mostrar esta página"
!define STR_TituloComponentes "Opciones de instalación"
!define STR_SubtituloComponentes "Indique los datos necesarios para descargar y copiar los componentes."
!define STR_GbLibres "GB libres"
!define STR_MsgFaltaDominio "Debe indicar el Dominio del Servidor"
!define STR_MsgFaltanCredencialesFtp "Debe indicar Usuario y Contraseña FTP"
!define STR_MsgFaltaProtocolo "Seleccione un Protocolo (HTTP o FTP) para realizar la prueba."
!define STR_MsgConexionHttpExito "Conexión HTTP exitosa"
!define STR_MsgConexionHttpError "Falló la conexión HTTP a $SERVER:"
!define STR_MsgConexionFtpExito "Conexión FTP exitosa"
!define STR_MsgConexionFtpError "Falló la conexión FTP a $SERVER:"
!define STR_MsgDetallesRespuesta "Respuesta recibida:"
!define STR_MsgExeNoEncontrado "No se encontró el programa ${APPFILE}.$\nEjecute nuevamente el instalador."
!define STR_MsgUniNoEncontrado "No se encontró el desinstalador en:"
!define STR_EtiqRutaInstalacion "Ruta de instalación"
!define STR_EtiqUnidadDestino "Unidad de destino:"
!define STR_EtiqConfigDescargas "Configuración de descargas"
!define STR_EtiqProtocolo "Protocolo:"
!define STR_EtiqDominioServidor "Dominio del servidor:"
!define STR_EtiqUsuarioFtp "Usuario FTP:"
!define STR_EtiqPassFtp "Contraseña FTP:"
!define STR_BotonDesinstalar "Desinstalar"
!define STR_BotonComprobar "Comprobar"
!define STR_EtiqRecordarCreds "Recordar credenciales (FTP)"
!define STR_EtiqDesinstalarHerramientas "¿Desea Desinstalar también las Herramientas externas?"
!define STR_EtiqRemoverTodas "Remover todas"
!define STR_MsgErrorDescargaFtp "No se pudo descargar por FTP"
!define STR_MsgErrorDescargaHttp "No se pudo descargar por HTTP"
!define STR_MsgErrorDescomprimir "Error al descomprimir"
!define STR_CodigoRespuesta "Código de respuesta:"
!define STR_MsgErrorTamano "Tamaño incorrecto de "
!define STR_MsgDescargando "Descargando:"
!define STR_MsgInstalandoHerramienta "Instalando herramienta:"

;--------------------------------
; DEFINICIONES MUI

!define MUI_ICON "..\app\${ICON}"
!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE $TitleWelcome
!define MUI_WELCOMEPAGE_TEXT $TextWelcome
!define MUI_STARTMENU_REGISTRY_ROOT "HKCU"
!define MUI_STARTMENU_REGISTRY_KEY "Software\${NAME}"
!define MUI_STARTMENU_REGISTRY_VALUENAME "Start Menu Folder"
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION LaunchApp
!define MUI_FINISHPAGE_RUN_TEXT "${STR_EtiqEjecutarApp}"
!define MUI_FINISHPAGE_LINK "${STR_EtiqRevisarNotas}"
!define MUI_FINISHPAGE_LINK_LOCATION "$INSTDIR\${README}"
!define MUI_FINISHPAGE_TITLE $TitleFinish
!define MUI_FINISHPAGE_TEXT $TextFinish
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_HEADERIMAGE_BITMAP "head.bmp"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "${STR_InstruccionesComponentes}"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TEXT_LARGE
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "${STR_TituloInstFinalizada}"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "${STR_SubtituloInstCompletada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "${STR_TituloInstCancelada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "${STR_SubtituloInstCancelada}"
!define MUI_FINISHPAGE_NOREBOOTSUPPORT

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

VIProductVersion ${RELEASE}.0
VIAddVersionKey /LANG=0 "ProductName" "${NAME}"
VIAddVersionKey /LANG=0 "ProductVersion" "${RELEASE}"
VIAddVersionKey /LANG=0 "FileVersion" ${RELEASE}
VIAddVersionKey /LANG=0 "FileDescription" "${STR_DescripcionArchivo}"
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

!macro MLoadCompsJson
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `complementos` /end
	Pop $CompsTotal
	IntOp $CompsTotal $CompsTotal - 1
	${For} $i 0 $CompsTotal
		nsJSON::Get `complementos` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `complementos` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `complementos` /index $i "version" /end
		Pop $ToolVer
		nsJSON::Get `complementos` /index $i "size_kb" /end
		Pop $ToolKb
		nsJSON::Get `complementos` /index $i "add_path" /end
		Pop $ToolAdd
		nsJSON::Get `complementos` /index $i "op_chk" /end
		Pop $ToolChk
		IntOp $ToolIndice $i + 15
		nsArray::Set ListCompId /key=$ToolIndice $ToolId
		nsArray::Set ListCompName /key=$ToolIndice $ToolName
		nsArray::Set ListCompVer /key=$ToolIndice $ToolVer
		nsArray::Set ListCompKb /key=$ToolIndice $ToolKb
		nsArray::Set ListCompAdd /key=$ToolIndice $ToolAdd
		nsArray::Set ListCompChk /key=$ToolIndice $ToolChk
	${Next}
	${For} $i $CompsTotal ${MAX_COMPS}
		${If} $i > $CompsTotal
			IntOp $ToolIndice $i + 15
			nsArray::Set ListCompId /key=$ToolIndice ""
			nsArray::Set ListCompName /key=$ToolIndice ""
			nsArray::Set ListCompVer /key=$ToolIndice ""
			nsArray::Set ListCompKb /key=$ToolIndice 0
			nsArray::Set ListCompAdd /key=$ToolIndice 0
			nsArray::Set ListCompChk /key=$ToolIndice 0
		${EndIf}
	${Next}
!macroend

!macro MGetInfoComp
	nsArray::Get ListCompId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListCompName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListCompVer /at=$i
	Pop $1
	Pop $ToolVer
	nsArray::Get ListCompKb /at=$i
	Pop $1
	Pop $ToolKb
	nsArray::Get ListCompAdd /at=$i
	Pop $1
	Pop $ToolAdd
	nsArray::Get ListCompChk /at=$i
	Pop $1
	Pop $ToolChk
	IntOp $ToolIndice $i + 15
!macroend

!macro MLoadReqsJson
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `requisitos` /end
	Pop $ReqsTotal
	IntOp $ReqsTotal $ReqsTotal - 1
	${For} $i 0 $ReqsTotal
		nsJSON::Get `requisitos` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `requisitos` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `requisitos` /index $i "version" /end
		Pop $ToolVer
		nsJSON::Get `requisitos` /index $i "size_kb" /end
		Pop $ToolKb
		nsJSON::Get `requisitos` /index $i "add_path" /end
		Pop $ToolAdd
		nsJSON::Get `requisitos` /index $i "op_chk" /end
		Pop $ToolChk
		IntOp $ToolIndice $i + 8
		nsArray::Set ListReqId /key=$ToolIndice $ToolId
		nsArray::Set ListReqName /key=$ToolIndice $ToolName
		nsArray::Set ListReqVer /key=$ToolIndice $ToolVer
		nsArray::Set ListReqKb /key=$ToolIndice $ToolKb
		nsArray::Set ListReqAdd /key=$ToolIndice $ToolAdd
		nsArray::Set ListReqChk /key=$ToolIndice $ToolChk
	${Next}
	${For} $i $ReqsTotal ${MAX_COMPS}
		${If} $i > $ReqsTotal
			IntOp $ToolIndice $i + 8
			nsArray::Set ListReqId /key=$ToolIndice ""
			nsArray::Set ListReqName /key=$ToolIndice ""
			nsArray::Set ListReqVer /key=$ToolIndice ""
			nsArray::Set ListReqKb /key=$ToolIndice 0
			nsArray::Set ListReqAdd /key=$ToolIndice 0
			nsArray::Set ListReqChk /key=$ToolIndice 0
		${EndIf}
	${Next}
!macroend

!macro MGetInfoReq
	nsArray::Get ListReqId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListReqName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListReqVer /at=$i
	Pop $1
	Pop $ToolVer
	nsArray::Get ListReqKb /at=$i
	Pop $1
	Pop $ToolKb
	nsArray::Get ListReqAdd /at=$i
	Pop $1
	Pop $ToolAdd
	nsArray::Get ListReqChk /at=$i
	Pop $1
	Pop $ToolChk
	IntOp $ToolIndice $i + 8
!macroend

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
PageEx license
	PageCallbacks SkipLicenseIfUpdate ""
	LicenseData "..\${LICENSEFILE}"
	LicenseText "${STR_InstruccionesLicencia}" "${STR_BotonAcepto}"
	Caption " "
PageExEnd
Page custom ShowConfigForm SaveConfigForm " "
Page custom CheckPreRequisites LeavePreRequisites " "
!define MUI_PAGE_CUSTOMFUNCTION_PRE CheckAllTools
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
	ReadRegStr $VERSION HKCU "Software\${NAME}" "Version"
	StrCpy $SkipPre "0"
	${If} $2 != ""
		StrCpy $SkipPre $2
	${EndIf}
	${If} $VERSION == ""
		StrCpy $VERSION ${RELEASE}
	${EndIf}
	StrCpy $IsUpdateInstall "0"
	${If} $0 != ""
		StrCpy $IsUpdateInstall "1"
		StrCpy $INSTDIR $0
		${If} $1 != ""
			StrCpy $INSTDRIVE $1
		${EndIf}
		StrCpy $TextCaption "${STR_VentanaActualizador}"
		StrCpy $TitleWelcome "${STR_TituloWelcomeActualizador}"
		StrCpy $TextWelcome "${STR_InstruccionesWelcomeActualizador}"
		StrCpy $TitleFinish "${STR_TituloFinishActualizador}"
		StrCpy $TextFinish "${STR_InstruccionesFinishActualizador}"
		SectionSetFlags 1 0
		SectionSetFlags 2 ${SF_SELECTED}
	${Else}
		StrCpy $TextCaption "${STR_VentanaInstalador}"
		StrCpy $TitleWelcome "${STR_TituloWelcomeInstalador}"
		StrCpy $TextWelcome "${STR_InstruccionesWelcomeInstalador}"
		StrCpy $TitleFinish "${STR_TituloFinishInstalador}"
		StrCpy $TextFinish "${STR_InstruccionesFinishInstalador}"
		IntOp $3 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags 1 $3
		IntOp $3 0 | ${SF_RO}
		SectionSetFlags 2 $3
		SectionSetText 2 ""
	${EndIf}
	ReadRegStr $RememberCreds HKCU "Software\${NAME}" "RememberCreds"
	${If} $RememberCreds != "1"
		StrCpy $RememberCreds "0"
	${EndIf}
FunctionEnd

Function FetchToolsCatalog
	SetOutPath "$INSTDRIVE$INSTDIR"
	File "tools.json"
	StrCpy $ToolsCatalog "$INSTDRIVE$INSTDIR\tools.json"
	${If} ${FileExists} $ToolsCatalog
		Delete $ToolsCatalog
	${EndIf}
	${If} $SERVER == ""
	${OrIf} $PROTOCOL == ""
	${OrIf} $PROTOCOL == "---"
		Goto LoadLocalTools
	${Endif}
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/tools.json"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$ToolsCatalog" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/tools.json"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$ToolsCatalog" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		Goto ExitFetchTools
	${EndIf}
LoadLocalTools:
	SetOutPath "$INSTDRIVE$INSTDIR"
	File "tools.json"
ExitFetchTools:
FunctionEnd

Function DownloadSingleTool
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.php"
		Goto SkipTool
	${EndIf}
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/$ToolId.zip"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "${STR_MsgErrorDescargaFtp} $ToolId$\n$R2"
			Goto SkipTool
		${EndIf}
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/$ToolId.zip"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$TEMP\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "${STR_MsgErrorDescargaHttp} $ToolId$\n${STR_CodigoRespuesta} $R1"
			Goto SkipTool
		${EndIf}
	${Else}
		Goto SkipTool
	${EndIf}
	DetailPrint "${STR_MsgDescargando} $R0"
	StrCpy $R7 "$TEMP\$ToolId_tmp"
	RMDir /r "$R7"
	CreateDirectory "$R7"
	SetOutPath "$R7"
	Nsisunz::UnzipToLog "$TEMP\$ToolId.zip" "$R7"
	Pop $R1
	${If} $R1 != "success"
		MessageBox MB_ICONSTOP "${STR_MsgErrorDescomprimir} $ToolName: $R1"
		Goto SkipTool
	${EndIf}
	${GetSize} "$R7" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 SizeMismatch
	Goto SuccessTool
SizeMismatch:
	MessageBox MB_ICONEXCLAMATION "${STR_MsgErrorTamano} $ToolName ($R4 KB ≠ $ToolKb KB)"
	Goto SkipTool
SuccessTool:
	Push Tag_OK
	Return
SkipTool:
	Push Tag_FIN
FunctionEnd

Function LoadCompsJson
	!insertmacro MLoadCompsJson
FunctionEnd

Function LoadReqsJson
	!insertmacro MLoadReqsJson
FunctionEnd

Function GetInfoComp
	!insertmacro MGetInfoComp
FunctionEnd

Function GetInfoReq
	!insertmacro MGetInfoReq
FunctionEnd

Function CheckAllTools
	Call FetchToolsCatalog
	Call LoadCompsJson
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPS}
			Call GetInfoComp
			SectionSetText $ToolIndice $ToolName
			SectionSetSize $ToolIndice $ToolKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.php"
				${If} "$ToolChk" == "0"
					SectionSetFlags $ToolIndice 0
				${ElseIf} "$ToolChk" == "1"
					SectionSetFlags $ToolIndice ${SF_SELECTED}
				${ElseIf} "$ToolChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndice $0
				${ElseIf} "$ToolChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndice $0
				${ElseIf} "$ToolChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndice $0
					SectionSetText $ToolIndice ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndice 0
			${EndIf}
		${EndIf}
	${Next}
	Call LoadReqsJson
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQS}
			Call GetInfoReq
			SectionSetText $ToolIndice $ToolName
			SectionSetSize $ToolIndice $ToolKb
			;TODO: Diferenciar otros directorios como ${VENDOR}
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.php"
				${If} "$ToolChk" == "0"
					SectionSetFlags $ToolIndice 0
				${ElseIf} "$ToolChk" == "1"
					SectionSetFlags $ToolIndice ${SF_SELECTED}
				${ElseIf} "$ToolChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndice $0
				${ElseIf} "$ToolChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndice $0
				${ElseIf} "$ToolChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndice $0
					SectionSetText $ToolIndice ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndice 1
			${EndIf}
		${EndIf}
	${Next}
FunctionEnd

Function InstallCompByIndex
	${If} $i >= ${MAX_COMPS}
	${OrIf} $i > $CompsTotal
		Return
	${EndIf}
	Call GetInfoComp
	${If} ${SectionIsSelected} $ToolIndice
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	Goto $0
Tag_OK:
	DetailPrint "${STR_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAdd == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
Tag_FIN:
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallReqByIndex
	${If} $i >= ${MAX_REQS}
	${OrIf} $i > $ReqsTotal
		Return
	${EndIf}
	Call GetInfoReq
	${If} ${SectionIsSelected} $ToolIndice
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	Goto $0
Tag_OK:
	DetailPrint "${STR_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	;TODO: Diferenciar otros directorios como ${VENDOR}
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAdd == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
Tag_FIN:
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "${STR_TituloLicencia}" "${STR_SubtituloLicencia}"
FunctionEnd

Function CheckPreRequisites
	${If} $SkipPre == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "${STR_TituloPrereq}" "${STR_SubtituloPrereq}"

	;TODO: Aquí falta añadir la comprobación real de Pre-requisitos (y sus resultados)

	${NSD_CreateCheckbox} 100u 130u 150u 10u "${STR_EtiqNomostrarDenuevo}"
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
	!insertmacro MUI_HEADER_TEXT "${STR_TituloComponentes}" "${STR_SubtituloComponentes}"
	; 1. Grupo: **Ruta de instalación**
	${NSD_CreateGroupBox} 5u 2u 290u 38u "${STR_EtiqRutaInstalacion}"
	Pop $0
		${NSD_CreateLabel} 15u 18u 90u 10u "${STR_EtiqUnidadDestino}"
		Pop $0
		${NSD_CreateDropList} 110u 16u 90u 14u ""
		Pop $DriveDropList
		StrCpy $hDriveDropList $DriveDropList
		Call FillDriveList
		${NSD_CB_SelectString} $DriveDropList "$INSTDRIVE\"
		${If} $IsUpdateInstall == "1"
			System::Call 'user32::EnableWindow(p$DriveDropList,i0)'
			${NSD_CreateButton} 215u 16u 60u 16u "${STR_BotonDesinstalar}"
			Pop $btnUninstall
			${NSD_OnClick} $btnUninstall RunUninstaller
		${EndIf}
	; 2. Grupo: **Configuración de descargas**
	${NSD_CreateGroupBox} 5u 46u 290u 95u "${STR_EtiqConfigDescargas}"
	Pop $0
		${NSD_CreateLabel} 15u 61u 90u 10u "${STR_EtiqProtocolo}"
		Pop $0
		${NSD_CreateDropList} 110u 59u 90u 12u ""
		Pop $ProtocolDropList
			${NSD_CB_AddString} $ProtocolDropList "---"
			${NSD_CB_AddString} $ProtocolDropList "HTTP"
			${NSD_CB_AddString} $ProtocolDropList "FTP"
			${NSD_CB_SelectString} $ProtocolDropList "$PROTOCOL"
		${NSD_CreateLabel} 15u 77u 90u 10u "${STR_EtiqDominioServidor}"
		Pop $0
		${NSD_CreateText} 110u 75u 90u 12u "$SERVER"
		Pop $ServerInput
		${NSD_CreateButton} 215u 59u 60u 16u "${STR_BotonComprobar}"
		Pop $btnTest
		${NSD_OnClick} $btnTest TestConnection
		${NSD_CreateLabel} 15u 93u 90u 10u "${STR_EtiqUsuarioFtp}"
		Pop $0
		${NSD_CreateText} 110u 91u 90u 12u "$FTP_USER"
		Pop $FtpUserInput
		${NSD_CreateLabel} 15u 109u 90u 10u "${STR_EtiqPassFtp}"
		Pop $0
		${NSD_CreatePassword} 110u 107u 90u 12u "$FTP_PASS"
		Pop $FtpPassInput
		${NSD_CreateCheckbox} 110u 124u 150u 10u "${STR_EtiqRecordarCreds}"
		Pop $RememberCredsCheckbox
		${If} $RememberCreds == "1"
			${NSD_Check} $RememberCredsCheckbox
		${EndIf}
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
		MessageBox MB_ICONEXCLAMATION "${STR_MsgFaltaDominio}"
		Abort
	${Endif}
	${NSD_GetState} $RememberCredsCheckbox $RememberCreds
	${If} $PROTOCOL == "FTP"
		${If} $FTP_USER == ""
		${OrIf} $FTP_PASS == ""
			MessageBox MB_ICONEXCLAMATION "${STR_MsgFaltanCredencialesFtp}"
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

Function TestConnection
	${NSD_GetText} $ServerInput $SERVER
	${If} $SERVER == ""
		MessageBox MB_ICONEXCLAMATION "${STR_MsgFaltaDominio}"
		Return
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i0)'
	${NSD_GetText} $ProtocolDropList $PROTOCOL
	${If} $PROTOCOL == "FTP"
		Call TestFtpConnection
	${ElseIf} $PROTOCOL == "HTTP"
		Call TestHttpConnection
	${Else}
		MessageBox MB_ICONEXCLAMATION "${STR_MsgFaltaProtocolo}"
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i1)'
FunctionEnd

Function TestFtpConnection
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${If} $FTP_USER == ""
	${OrIf} $FTP_PASS == ""
		MessageBox MB_ICONEXCLAMATION "${STR_MsgFaltanCredencialesFtp}"
		Return
	${EndIf}
	nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "ftp://$SERVER" --silent --list-only --connect-timeout 5'
	Pop $R0
	Pop $R1
	${If} $R0 == 0
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "${STR_MsgConexionFtpExito}"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "${STR_MsgConexionFtpError}$\n$R1"
	${EndIf}
FunctionEnd

Function TestHttpConnection
	nsExec::ExecToStack '"curl.exe" -s -S -L -I --insecure --connect-timeout 5 --write-out "%{http_code}" -o NUL "https://$SERVER/herramientas/tools.json"'
	Pop $R1
	Pop $R0
	${If} $R0 == "200"
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "${STR_MsgConexionHttpExito}"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "${STR_MsgConexionHttpError}$\n${STR_MsgDetallesRespuesta} $R0"
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
		StrCpy $2 "$0 ($tmpGB ${STR_GbLibres})"
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
	MessageBox MB_ICONSTOP "${STR_MsgExeNoEncontrado}"
FunctionEnd

Function RunUninstaller
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "¿Desea desinstalar la versión instalada?" IDNO EndAsk
		StrCpy $0 "$INSTDRIVE$INSTDIR\${UNINSTALL}"
		IfFileExists "$0" 0 NoUninst
		Exec '"$0"'
		Quit
NoUninst:
	MessageBox MB_ICONSTOP "${STR_MsgUniNoEncontrado}$\n$0"
EndAsk:
FunctionEnd

;--------------------------------
; FUNCIONES: DESINSTALACIÓN

Function un.onInit
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Drive"
	StrCpy $INSTDRIVE $0
FunctionEnd

Function un.LoadCompsJson
	!insertmacro MLoadCompsJson
FunctionEnd

Function un.LoadReqsJson
	!insertmacro MLoadReqsJson
FunctionEnd

Function un.GetInfoComp
	!insertmacro MGetInfoComp
FunctionEnd

Function un.GetInfoReq
	!insertmacro MGetInfoReq
FunctionEnd

Function un.ShowOptionsUninstall
	nsDialogs::Create 1018
	Pop $0
	${NSD_CreateLabel} 0 0 100% 12u "${STR_EtiqDesinstalarHerramientas}"
	Pop $1
	${NSD_CreateCheckbox} 0 16u 100% 12u "${STR_EtiqRemoverTodas}"
	Pop $unToolsCheckbox
	nsDialogs::Show
FunctionEnd

Function un.ReadChoiceUninstall
	${NSD_GetState} $unToolsCheckbox $unToolsCheckboxState
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

SectionGroup /e "Programa" 0
	Section "!Mi Ayudante (*)" 1
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
		WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base Lanzamiento $VERSION
		CreateShortCut "$DESKTOP\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
		CreateShortCut "$SMPROGRAMS\${NAME}.lnk" "$INSTDRIVE$INSTDIR\${APPFILE}" "" "$INSTDRIVE$INSTDIR\${ICON}"
	SectionEnd
	Section /o "Actualizaciones" 2
		;TODO: Aquí falta un manejador de actualizaciones -> al directorio $INSTDIR
	SectionEnd
	Section "" 3
	SectionEnd
	Section "" 4
	SectionEnd
	Section "" 5
	SectionEnd
SectionGroupEnd

SectionGroup /e "Requisitos" 7
	Section "" 8
		StrCpy $i 0
		Call InstallReqByIndex
	SectionEnd
	Section "" 9
		StrCpy $i 1
		Call InstallReqByIndex
	SectionEnd
	Section "" 10
		StrCpy $i 2
		Call InstallReqByIndex
	SectionEnd
	Section "" 11
		StrCpy $i 3
		Call InstallReqByIndex
	SectionEnd
	Section "" 12
		StrCpy $i 4
		Call InstallReqByIndex
	SectionEnd
SectionGroupEnd

SectionGroup /e "Complementos" 14
	Section /o "" 15
		StrCpy $i 0
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 16
		StrCpy $i 1
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 17
		StrCpy $i 2
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 18
		StrCpy $i 3
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 19
		StrCpy $i 4
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 20
		StrCpy $i 5
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 21
		StrCpy $i 6
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 22
		StrCpy $i 7
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 23
		StrCpy $i 8
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 24
		Push 9
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 25
		Push 10
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 26
		Push 11
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 27
		Push 12
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 28
		Push 13
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 29
		Push 14
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 30
		Push 15
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 31
		Push 16
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 32
		Push 17
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 33
		Push 18
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 34
		Push 19
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 35
		Push 20
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 36
		Push 21
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 37
		Push 22
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 38
		Push 23
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 39
		Push 24
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 40
		Push 25
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 41
		Push 26
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 42
		Push 27
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 43
		Push 28
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 44
		Push 29
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 45
		Push 30
		Call InstallCompByIndex
	SectionEnd
	Section /o "" 46
		Push 31
		Call InstallCompByIndex
	SectionEnd
SectionGroupEnd

Section "-Config"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$INSTDRIVE"
	WriteRegStr HKCU "Software\${NAME}" "FTP_Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "Software\${NAME}" "SkipPre" "$SkipPre"
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$INSTDRIVE$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$VERSION"
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
	StrCpy $ToolsCatalog "$INSTDIR\tools.json"
	Call un.LoadCompsJson
	Call un.LoadReqsJson
	Delete "$INSTDIR\*.*"
	Delete "$INSTDIR\${UNINSTALL}"
	Delete "$DESKTOP\${NAME}.lnk"
	Delete "$SMPROGRAMS\${NAME}.lnk"
	DeleteRegKey HKCU "Software\${NAME}"
	DeleteRegKey HKCU "${HKCUNI}"
	SetOutPath "$INSTDRIVE\home"
	RMDir /r "$INSTDIR"
	StrCmp $unToolsCheckboxState "1" 0 Done
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPS}
			Call un.GetInfoComp
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQS}
			Call un.GetInfoReq
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	Push "$INSTDRIVE${TOOLS}"
	Call un.RemoveDirIfEmpty
	RMDir /r "$INSTDRIVE${VENDOR}"
Done:
SectionEnd
