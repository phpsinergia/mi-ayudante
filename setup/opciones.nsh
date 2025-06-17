Var btnTest
Var tmpGB
Var hDriveDropList
Var btnUninstall
Var DriveDropList
Var ServerInput
Var FtpUserInput
Var FtpPassInput
Var ProtocolDropList
Var RememberCredsCheckbox

;--------------------------------
; FUNCIONES

Function ShowOptionsForm
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

Function SaveOptionsForm
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
	nsExec::ExecToStack '"curl.exe" -s -S -L -I --insecure --connect-timeout 5 --write-out "%{http_code}" -o NUL "https://$SERVER/herramientas/catalogo.json"'
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
