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
!include "WordFunc.nsh"

;--------------------------------
; DEFINICIONES BÁSICAS

!define RELEASE "1.0.0"
!define NAME "Mi Ayudante"
!define PUBLISHER "Rubén Araya Tagle"
!define TARGET "\home\mi-ayudante"
!define TOOLS "\home\herramientas"
!define VENDOR "\home\vendor"
!define APPFILE "ayudante.exe"
!define LICENSEFILE "LICENSE"
!define README "LEEME.txt"
!define ICON "img\favicon.ico"
!define UNINSTALL "Desinstalar.exe"
!define INSTALL "..\dist\mi-ayudante_${RELEASE}.exe"
!define HKCUNI "Software\Microsoft\Windows\CurrentVersion\Uninstall\${NAME}"
!define MAX_COMPS 32
!define MAX_REQS 7

;--------------------------------
; VARIABLES GLOBALES

Var VERSION
Var INSTDRIVE
Var SERVER
Var FTP_USER
Var FTP_PASS
Var PROTOCOL
Var FullPath
Var IsUpdateInstall
Var ServerInput
Var DriveDropList
Var FtpUserInput
Var FtpPassInput
Var ProtocolDropList
Var SkipPrereq
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
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolIndex
Var ToolsCatalog
Var CompsTotal
Var ReqsTotal
Var CompsVisibles
Var ReqsVisibles

;--------------------------------
; TEXTOS DE LA INTERFAZ

!define TXT_DescripcionArchivo "Instalador de ${NAME} para Windows"
!define TXT_TituloLicencia "Acuerdo de Licencia"
!define TXT_SubtituloLicencia "Por favor revise los términos de la licencia antes de instalar el software."
!define TXT_InstruccionesLicencia "Si acepta todos los términos del acuerdo, seleccione ACEPTO para continuar.$\nDebe aceptar el acuerdo para poder instalar ${NAME}."
!define TXT_InstruccionesComponentes "Marque los componentes que desee instalar y desmarque aquellos que no desee. Presione Instalar para comenzar el proceso (requiere conexión a Internet)."
!define TXT_EtiqEjecutarApp "Ejecutar ${NAME} ahora"
!define TXT_EtiqRevisarNotas "Revisar notas en ${README}"
!define TXT_BotonAcepto "ACEPTO"
!define TXT_VentanaActualizador "Actualización de ${NAME}"
!define TXT_VentanaInstalador "Instalación de ${NAME}"
!define TXT_TituloWelcomeActualizador "Asistente para Actualizar$\n${NAME} v$VERSION"
!define TXT_InstruccionesWelcomeActualizador "Este programa ACTUALIZARÁ el software ${NAME} que está instalado en:$\n$\n$INSTDRIVE$0$\n$\nPodrá agregar nuevos componentes o restaurar los existentes, sin perder sus configuraciones y datos.$\n$\n$\nPresione Siguiente para continuar."
!define TXT_TituloFinishActualizador "Finalizando el Asistente para$\nActualizar ${NAME}"
!define TXT_InstruccionesFinishActualizador "${NAME} ha sido actualizado en:$\n$\n$INSTDRIVE$0$\n$\nPresione Terminar para cerrar este asistente."
!define TXT_TituloWelcomeInstalador "Asistente para Instalar$\n${NAME} v$VERSION"
!define TXT_InstruccionesWelcomeInstalador "Este programa INSTALARÁ el software ${NAME} en su computadora.$\n$\nSe recomienda que cierre todas las demás aplicaciones antes de iniciar la instalación. Esto hará posible actualizar archivos relacionados con el sistema sin tener que reiniciar el equipo.$\n$\n$\nPresione Siguiente para continuar."
!define TXT_TituloFinishInstalador "Finalizando el Asistente para$\nInstalar ${NAME}"
!define TXT_InstruccionesFinishInstalador "${NAME} ha sido instalado en su computadora.$\n$\nPresione Terminar para cerrar este asistente."
!define TXT_TituloInstFinalizada "Instalación completada"
!define TXT_SubtituloInstCompletada "Se ha completado el proceso de instalación de ${NAME}."
!define TXT_TituloInstCancelada "Instalación cancelada"
!define TXT_SubtituloInstCancelada "La instalación fue cancelada por el usuario."
!define TXT_TituloPrereq "Comprobación de Pre-requisitos"
!define TXT_SubtituloPrereq "Debe tener instalados PHP y Composer en su computadora local."
!define TXT_EtiqNomostrarDenuevo "No volver a mostrar esta página"
!define TXT_TituloComponentes "Opciones de instalación"
!define TXT_SubtituloComponentes "Indique los datos necesarios para descargar y copiar los componentes."
!define TXT_GbLibres "GB libres"
!define TXT_MsgFaltaDominio "Debe indicar el Dominio del Servidor"
!define TXT_MsgFaltanCredencialesFtp "Debe indicar Usuario y Contraseña FTP"
!define TXT_MsgFaltaProtocolo "Seleccione un Protocolo (HTTP o FTP) para realizar la prueba."
!define TXT_MsgConexionHttpExito "Conexión HTTP exitosa"
!define TXT_MsgConexionHttpError "Falló la conexión HTTP a $SERVER:"
!define TXT_MsgConexionFtpExito "Conexión FTP exitosa"
!define TXT_MsgConexionFtpError "Falló la conexión FTP a $SERVER:"
!define TXT_MsgDetallesRespuesta "Respuesta recibida:"
!define TXT_MsgExeNoEncontrado "No se encontró el programa ${APPFILE}.$\nEjecute nuevamente el instalador."
!define TXT_MsgUniNoEncontrado "No se encontró el desinstalador en:"
!define TXT_EtiqRutaInstalacion "Ruta de instalación"
!define TXT_EtiqUnidadDestino "Unidad de destino:"
!define TXT_EtiqConfigDescargas "Configuración de descargas"
!define TXT_EtiqProtocolo "Protocolo:"
!define TXT_EtiqDominioServidor "Dominio del servidor:"
!define TXT_EtiqUsuarioFtp "Usuario FTP:"
!define TXT_EtiqPassFtp "Contraseña FTP:"
!define TXT_BotonDesinstalar "Desinstalar"
!define TXT_BotonComprobar "Comprobar"
!define TXT_EtiqRecordarCreds "Recordar credenciales (FTP)"
!define TXT_EtiqDesinstalarHerramientas "¿Desea Desinstalar también las Herramientas externas?"
!define TXT_EtiqRemoverTodas "Remover todas"
!define TXT_MsgErrorDescargaFtp "No se pudo descargar por FTP"
!define TXT_MsgErrorDescargaHttp "No se pudo descargar por HTTP"
!define TXT_MsgErrorDescomprimir "Error al descomprimir"
!define TXT_CodigoRespuesta "Código de respuesta:"
!define TXT_MsgErrorTamano "Tamaño incorrecto de "
!define TXT_MsgDescargando "Descargando:"
!define TXT_MsgVerificando "Verificando Hash SHA256:"
!define TXT_MsgInstalandoHerramienta "Instalando herramienta:"
!define TXT_EtiqReinstalar "(Reinstalar)"
!define TXT_SecPrograma "Programa"
!define TXT_SecRequisitos "Requisitos"
!define TXT_SecComplementos "Complementos"
!define TXT_SecActualizaciones "Buscar Actualizaciones"
!define TXT_MsgCalculandoEspacio "Calculando el espacio utilizado..."
!define TXT_MsgErrorHashNoCalculado "No se pudo obtener el Hash del archivo:"
!define TXT_MsgErrorHashNoCoincide "No coincide el Hash del archivo:"
!define TXT_MsgHashValidado "Hash validado:"
!define TXT_EtiqVerRegistro "Ver Registro de Instalación (inst.log)"

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
!define MUI_FINISHPAGE_RUN_TEXT "${TXT_EtiqEjecutarApp}"
!define MUI_FINISHPAGE_TITLE $TitleFinish
!define MUI_FINISHPAGE_TEXT $TextFinish
!define MUI_WELCOMEFINISHPAGE_BITMAP "left.bmp"
!define MUI_HEADERIMAGE_BITMAP "head.bmp"
!define MUI_COMPONENTSPAGE_NODESC
!define MUI_COMPONENTSPAGE_TEXT_TOP "${TXT_InstruccionesComponentes}"
!define MUI_FINISHPAGE_NOAUTOCLOSE
!define MUI_FINISHPAGE_TEXT_LARGE
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "${TXT_TituloInstFinalizada}"
!define MUI_INSTFILESPAGE_FINISHHEADER_SUBTEXT "${TXT_SubtituloInstCompletada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_TEXT "${TXT_TituloInstCancelada}"
!define MUI_INSTFILESPAGE_ABORTHEADER_SUBTEXT "${TXT_SubtituloInstCancelada}"
!define MUI_FINISHPAGE_LINK "${TXT_EtiqVerRegistro}"
!define MUI_FINISHPAGE_LINK_LOCATION "$INSTDIR\inst.log"
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\${README}"
!define MUI_FINISHPAGE_SHOWREADME_TEXT "${TXT_EtiqRevisarNotas}"
!define MUI_FINISHPAGE_SHOWREADME_NOTCHECKED
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
VIAddVersionKey /LANG=0 "ProductVersion" "${RELEASE}"
VIAddVersionKey /LANG=0 "FileVersion" ${RELEASE}
VIAddVersionKey /LANG=0 "ProductName" "${NAME}"
VIAddVersionKey /LANG=0 "FileDescription" "${TXT_DescripcionArchivo}"
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
		Pop $ToolVersion
		nsJSON::Get `complementos` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `complementos` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `complementos` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `complementos` /index $i "hash" /end
		Pop $ToolHash
		IntOp $ToolIndex $i + 15
		nsArray::Set ListCompId /key=$ToolIndex $ToolId
		nsArray::Set ListCompName /key=$ToolIndex $ToolName
		nsArray::Set ListCompVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListCompSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListCompAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListCompOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListCompHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $CompsTotal ${MAX_COMPS}
		${If} $i > $CompsTotal
			IntOp $ToolIndex $i + 15
			nsArray::Set ListCompId /key=$ToolIndex ""
			nsArray::Set ListCompName /key=$ToolIndex ""
			nsArray::Set ListCompVersion /key=$ToolIndex ""
			nsArray::Set ListCompSizeKb /key=$ToolIndex 0
			nsArray::Set ListCompAddPath /key=$ToolIndex 0
			nsArray::Set ListCompOpChk /key=$ToolIndex 0
			nsArray::Set ListCompHash /key=$ToolIndex ""
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
	nsArray::Get ListCompVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListCompSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListCompAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListCompOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListCompHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $ToolIndex $i + 15
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
		Pop $ToolVersion
		nsJSON::Get `requisitos` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `requisitos` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `requisitos` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `requisitos` /index $i "hash" /end
		Pop $ToolHash
		IntOp $ToolIndex $i + 6
		nsArray::Set ListReqId /key=$ToolIndex $ToolId
		nsArray::Set ListReqName /key=$ToolIndex $ToolName
		nsArray::Set ListReqVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListReqSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListReqAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListReqOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListReqHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $ReqsTotal ${MAX_COMPS}
		${If} $i > $ReqsTotal
			IntOp $ToolIndex $i + 6
			nsArray::Set ListReqId /key=$ToolIndex ""
			nsArray::Set ListReqName /key=$ToolIndex ""
			nsArray::Set ListReqVersion /key=$ToolIndex ""
			nsArray::Set ListReqSizeKb /key=$ToolIndex 0
			nsArray::Set ListReqAddPath /key=$ToolIndex 0
			nsArray::Set ListReqOpChk /key=$ToolIndex 0
			nsArray::Set ListReqHash /key=$ToolIndex ""
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
	nsArray::Get ListReqVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListReqSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListReqAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListReqOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListReqHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $ToolIndex $i + 6
!macroend

;--------------------------------
; PAGINAS

!insertmacro MUI_PAGE_WELCOME
PageEx license
	PageCallbacks SkipLicenseIfUpdate ""
	LicenseData "..\${LICENSEFILE}"
	LicenseText "${TXT_InstruccionesLicencia}" "${TXT_BotonAcepto}"
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
	GetFullPathName $FullPath $EXEPATH
	StrCpy $INSTDRIVE $FullPath 2
	ReadRegStr $0 HKCU "Software\${NAME}" "Install_Dir"
	ReadRegStr $1 HKCU "Software\${NAME}" "Install_Drive"
	ReadRegStr $2 HKCU "Software\${NAME}" "SkipPrereq"
	ReadRegStr $SERVER HKCU "Software\${NAME}" "Server"
	ReadRegStr $FTP_USER HKCU "Software\${NAME}" "FTP_User"
	ReadRegStr $FTP_PASS HKCU "Software\${NAME}" "FTP_Pass"
	ReadRegStr $PROTOCOL HKCU "Software\${NAME}" "Protocol"
	ReadRegStr $VERSION HKCU "Software\${NAME}" "Version"
	StrCpy $SkipPrereq "0"
	${If} $2 != ""
		StrCpy $SkipPrereq $2
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
		StrCpy $TextCaption "${TXT_VentanaActualizador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeActualizador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeActualizador}"
		StrCpy $TitleFinish "${TXT_TituloFinishActualizador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishActualizador}"
		SectionSetFlags 1 0
		SectionSetFlags 2 ${SF_SELECTED}
		SectionSetText 1 "${NAME} ${TXT_EtiqReinstalar}"
	${Else}
		StrCpy $TextCaption "${TXT_VentanaInstalador}"
		StrCpy $TitleWelcome "${TXT_TituloWelcomeInstalador}"
		StrCpy $TextWelcome "${TXT_InstruccionesWelcomeInstalador}"
		StrCpy $TitleFinish "${TXT_TituloFinishInstalador}"
		StrCpy $TextFinish "${TXT_InstruccionesFinishInstalador}"
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

Function HandleUpdateApp
	;TODO: Pendiente de implementar
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
		Goto SkipTool
	${EndIf}
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/$ToolId.zip"
		DetailPrint "${TXT_MsgDescargando} $R0"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "${TXT_MsgErrorDescargaFtp} $ToolId$\n$R2"
			Goto SkipTool
		${EndIf}
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/$ToolId.zip"
		DetailPrint "${TXT_MsgDescargando} $R0"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$TEMP\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "${TXT_MsgErrorDescargaHttp} $ToolId$\n${TXT_CodigoRespuesta} $R1"
			Goto SkipTool
		${EndIf}
	${Else}
		Goto SkipTool
	${EndIf}
	!insertmacro WordFind
	DetailPrint "${TXT_MsgVerificando} $ToolName ($ToolId.zip)"
	;Validación de hash SHA256 del .ZIP descargado
	nsExec::ExecToStack 'CertUtil -hashfile "$TEMP\$ToolId.zip" SHA256'
	Pop $0
	Pop $1
	StrCmp $0 0 +3
		MessageBox MB_ICONSTOP "${TXT_MsgErrorHashNoCalculado} $ToolId.zip"
		Goto SkipTool
	${If} $1 != ""
	${AndIf} $ToolHash != ""
		${WordFind} "$1" "$ToolHash" "+1" $2
		${If} $2 != ""
			DetailPrint "${TXT_MsgHashValidado} $ToolHash"
			Goto ValidateOk
		${Else}
			MessageBox MB_ICONSTOP "${TXT_MsgErrorHashNoCoincide} $ToolId.zip$\n$2 ≠ $ToolHash"
			Goto SkipTool
		${EndIf}
	${Else}
		MessageBox MB_ICONSTOP "${TXT_MsgErrorHashNoCalculado} $ToolId.zip"
		Goto SkipTool
	${EndIf}
ValidateOk:
	StrCpy $R7 "$TEMP\$ToolId_tmp"
	RMDir /r "$R7"
	CreateDirectory "$R7"
	SetOutPath "$R7"
	Nsisunz::UnzipToLog "$TEMP\$ToolId.zip" "$R7"
	Pop $R1
	${If} $R1 != "success"
		MessageBox MB_ICONSTOP "${TXT_MsgErrorDescomprimir} $ToolName: $R1"
		Goto SkipTool
	${EndIf}
	${GetSize} "$R7" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolSizeKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 SizeMismatch
	Goto SuccessTool
SizeMismatch:
	MessageBox MB_ICONEXCLAMATION "${TXT_MsgErrorTamano} $ToolName ($R4 KB ≠ $ToolSizeKb KB)"
	Goto SkipTool
SuccessTool:
	Push "OK"
	Return
SkipTool:
	Push "NO"
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
	StrCpy $CompsVisibles "0"
	StrCpy $ReqsVisibles "0"
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPS}
			Call GetInfoComp
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndex 0
				IntOp $CompsVisibles $CompsVisibles + 1
			${EndIf}
		${EndIf}
	${Next}
	${If} $CompsVisibles == "0"
		SectionSetText 14 ""
	${EndIf}
	Call LoadReqsJson
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQS}
			Call GetInfoReq
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndex 1
				IntOp $ReqsVisibles $ReqsVisibles + 1
			${EndIf}
		${EndIf}
	${Next}
	${If} $ReqsVisibles == "0"
		SectionSetText 5 ""
	${EndIf}
FunctionEnd

Function InstallCompByIndex
	${If} $i >= ${MAX_COMPS}
	${OrIf} $i > $CompsTotal
		Return
	${EndIf}
	Call GetInfoComp
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $R7 == ""
		Goto Tag_FIN_Comp
	${EndIf}
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
Tag_FIN_Comp:
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
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $R7 == ""
		Goto Tag_FIN_Req
	${EndIf}
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	${If} $ToolId == "vendor"
		DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolName v$ToolVersion"
		RMDir /r "$INSTDRIVE${VENDOR}"
		Rename "$INSTDRIVE${TOOLS}\$ToolId" "$INSTDRIVE${VENDOR}"
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		SetOutPath "$INSTDRIVE${TOOLS}\$ToolId"
		File "meta.json"
	${EndIf}
Tag_FIN_Req:
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function SkipLicenseIfUpdate
	${If} $IsUpdateInstall == "1"
		Abort
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "${TXT_TituloLicencia}" "${TXT_SubtituloLicencia}"
FunctionEnd

Function CheckPreRequisites
	${If} $SkipPrereq == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "${TXT_TituloPrereq}" "${TXT_SubtituloPrereq}"

	;TODO: Aquí falta añadir la comprobación real de Pre-requisitos (y sus resultados)

	${NSD_CreateCheckbox} 100u 130u 150u 10u "${TXT_EtiqNomostrarDenuevo}"
	Pop $SkipPreCheckbox
	nsDialogs::Show
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPrereq
FunctionEnd

Function ShowConfigForm
	nsDialogs::Create 1018
	Pop $0
	${If} $PROTOCOL == ""
		StrCpy $PROTOCOL "---"
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "${TXT_TituloComponentes}" "${TXT_SubtituloComponentes}"
	; 1. Grupo: **Ruta de instalación**
	${NSD_CreateGroupBox} 5u 2u 290u 38u "${TXT_EtiqRutaInstalacion}"
	Pop $0
		${NSD_CreateLabel} 15u 18u 90u 10u "${TXT_EtiqUnidadDestino}"
		Pop $0
		${NSD_CreateDropList} 110u 16u 90u 14u ""
		Pop $DriveDropList
		StrCpy $hDriveDropList $DriveDropList
		Call FillDriveList
		${NSD_CB_SelectString} $DriveDropList "$INSTDRIVE\"
		${If} $IsUpdateInstall == "1"
			System::Call 'user32::EnableWindow(p$DriveDropList,i0)'
			${NSD_CreateButton} 215u 16u 60u 16u "${TXT_BotonDesinstalar}"
			Pop $btnUninstall
			${NSD_OnClick} $btnUninstall RunUninstaller
		${EndIf}
	; 2. Grupo: **Configuración de descargas**
	${NSD_CreateGroupBox} 5u 46u 290u 95u "${TXT_EtiqConfigDescargas}"
	Pop $0
		${NSD_CreateLabel} 15u 61u 90u 10u "${TXT_EtiqProtocolo}"
		Pop $0
		${NSD_CreateDropList} 110u 59u 90u 12u ""
		Pop $ProtocolDropList
			${NSD_CB_AddString} $ProtocolDropList "---"
			${NSD_CB_AddString} $ProtocolDropList "HTTP"
			${NSD_CB_AddString} $ProtocolDropList "FTP"
			${NSD_CB_SelectString} $ProtocolDropList "$PROTOCOL"
		${NSD_CreateLabel} 15u 77u 90u 10u "${TXT_EtiqDominioServidor}"
		Pop $0
		${NSD_CreateText} 110u 75u 90u 12u "$SERVER"
		Pop $ServerInput
		${NSD_CreateButton} 215u 59u 60u 16u "${TXT_BotonComprobar}"
		Pop $btnTest
		${NSD_OnClick} $btnTest TestConnection
		${NSD_CreateLabel} 15u 93u 90u 10u "${TXT_EtiqUsuarioFtp}"
		Pop $0
		${NSD_CreateText} 110u 91u 90u 12u "$FTP_USER"
		Pop $FtpUserInput
		${NSD_CreateLabel} 15u 109u 90u 10u "${TXT_EtiqPassFtp}"
		Pop $0
		${NSD_CreatePassword} 110u 107u 90u 12u "$FTP_PASS"
		Pop $FtpPassInput
		${NSD_CreateCheckbox} 110u 124u 150u 10u "${TXT_EtiqRecordarCreds}"
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
		MessageBox MB_ICONEXCLAMATION "${TXT_MsgFaltaDominio}"
		Abort
	${Endif}
	${NSD_GetState} $RememberCredsCheckbox $RememberCreds
	${If} $PROTOCOL == "FTP"
		${If} $FTP_USER == ""
		${OrIf} $FTP_PASS == ""
			MessageBox MB_ICONEXCLAMATION "${TXT_MsgFaltanCredencialesFtp}"
			Abort
		${EndIf}
	${EndIf}
FunctionEnd

Function TestConnection
	${NSD_GetText} $ServerInput $SERVER
	${If} $SERVER == ""
		MessageBox MB_ICONEXCLAMATION "${TXT_MsgFaltaDominio}"
		Return
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i0)'
	${NSD_GetText} $ProtocolDropList $PROTOCOL
	${If} $PROTOCOL == "FTP"
		Call TestFtpConnection
	${ElseIf} $PROTOCOL == "HTTP"
		Call TestHttpConnection
	${Else}
		MessageBox MB_ICONEXCLAMATION "${TXT_MsgFaltaProtocolo}"
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i1)'
FunctionEnd

Function TestFtpConnection
	${NSD_GetText} $FtpUserInput $FTP_USER
	${NSD_GetText} $FtpPassInput $FTP_PASS
	${If} $FTP_USER == ""
	${OrIf} $FTP_PASS == ""
		MessageBox MB_ICONEXCLAMATION "${TXT_MsgFaltanCredencialesFtp}"
		Return
	${EndIf}
	nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "ftp://$SERVER" --silent --list-only --connect-timeout 5'
	Pop $R0
	Pop $R1
	${If} $R0 == 0
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "${TXT_MsgConexionFtpExito}"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "${TXT_MsgConexionFtpError}$\n$R1"
	${EndIf}
FunctionEnd

Function TestHttpConnection
	nsExec::ExecToStack '"curl.exe" -s -S -L -I --insecure --connect-timeout 5 --write-out "%{http_code}" -o NUL "https://$SERVER/herramientas/tools.json"'
	Pop $R1
	Pop $R0
	${If} $R0 == "200"
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "${TXT_MsgConexionHttpExito}"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "${TXT_MsgConexionHttpError}$\n${TXT_MsgDetallesRespuesta} $R0"
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
		StrCpy $2 "$0 ($tmpGB ${TXT_GbLibres})"
		${NSD_CB_AddString} $hDriveDropList $2
	${EndIf}
	Push ""
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
	MessageBox MB_ICONSTOP "${TXT_MsgExeNoEncontrado}"
FunctionEnd

Function RunUninstaller
	MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "¿Desea desinstalar la versión instalada?" IDNO EndAsk
		StrCpy $0 "$INSTDRIVE$INSTDIR\${UNINSTALL}"
		IfFileExists "$0" 0 NoUninst
		Exec '"$0"'
		Quit
NoUninst:
	MessageBox MB_ICONSTOP "${TXT_MsgUniNoEncontrado}$\n$0"
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
	${NSD_CreateLabel} 0 0 100% 12u "${TXT_EtiqDesinstalarHerramientas}"
	Pop $1
	${NSD_CreateCheckbox} 0 16u 100% 12u "${TXT_EtiqRemoverTodas}"
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

SectionGroup /e "${TXT_SecPrograma}" 0
	Section "!${NAME} (*)" 1
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
	Section /o "${TXT_SecActualizaciones}" 2
		Call HandleUpdateApp
	SectionEnd
	Section "" 3
	SectionEnd
SectionGroupEnd

SectionGroup /e "${TXT_SecRequisitos}" 5
	Section "" 6
		StrCpy $i 0
		Call InstallReqByIndex
	SectionEnd
	Section "" 7
		StrCpy $i 1
		Call InstallReqByIndex
	SectionEnd
	Section "" 8
		StrCpy $i 2
		Call InstallReqByIndex
	SectionEnd
	Section "" 9
		StrCpy $i 3
		Call InstallReqByIndex
	SectionEnd
	Section "" 10
		StrCpy $i 4
		Call InstallReqByIndex
	SectionEnd
	Section "" 11
		StrCpy $i 5
		Call InstallReqByIndex
	SectionEnd
	Section "" 12
		StrCpy $i 6
		Call InstallReqByIndex
	SectionEnd
SectionGroupEnd

SectionGroup /e "${TXT_SecComplementos}" 14
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
	WriteRegStr HKCU "Software\${NAME}" "Server" "$SERVER"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$PROTOCOL"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
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
	DetailPrint "${TXT_MsgCalculandoEspacio}"
	${GetSize} "$INSTDRIVE\home" "/S=0K" $1 $R7 $R8
	IntFmt $1 "0x%08X" $1
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	WriteUninstaller "$INSTDRIVE$INSTDIR\${UNINSTALL}"
SectionEnd

Section "-DumpLog"
	DumpLog::DumpLogUTF8 "$INSTDRIVE$INSTDIR\inst.log" .r0
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
	SetOutPath "$TEMP"
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
	RMDir /r "$INSTDRIVE${TARGET}"
SectionEnd
