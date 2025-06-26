Var btnTest
Var tmpGB
Var hDriveDropList
Var btnUninstall
Var DriveDropList
Var ServerInput
Var UserInput
Var PassInput
Var ProtocolDropList
Var RememberCredsCheckbox

;--------------------------------
; FUNCIONES

Function ShowOptionsForm
	Push $0
	nsDialogs::Create 1018
	Pop $0
	${If} $Protocol == ""
		StrCpy $Protocol "---"
	${EndIf}
	!insertmacro MUI_HEADER_TEXT "$(TXT_TituloComponentes)" "$(TXT_SubtituloComponentes)"
	; 1. Grupo: **Ruta de instalación**
	${NSD_CreateGroupBox} 5u 2u 290u 38u "$(TXT_EtiqRutaInstalacion)"
	Pop $0
		${NSD_CreateLabel} 15u 18u 90u 10u "$(TXT_EtiqUnidadDestino)"
		Pop $0
		${NSD_CreateDropList} 110u 16u 90u 14u ""
		Pop $DriveDropList
		StrCpy $hDriveDropList $DriveDropList
		Call FillDriveList
		${NSD_CB_SelectString} $DriveDropList "$InstDrive\"
		${If} $IsUpdateInstall == "1"
			System::Call 'user32::EnableWindow(p$DriveDropList,i0)'
			${NSD_CreateButton} 215u 16u 60u 16u "$(TXT_BotonDesinstalar)"
			Pop $btnUninstall
			${NSD_OnClick} $btnUninstall RunUninstaller
		${EndIf}
	; 2. Grupo: **Configuración de descargas**
	${NSD_CreateGroupBox} 5u 46u 290u 95u "$(TXT_EtiqConfigDescargas)"
	Pop $0
		${NSD_CreateLabel} 15u 61u 90u 10u "$(TXT_EtiqProtocolo)"
		Pop $0
		${NSD_CreateDropList} 110u 59u 90u 12u ""
		Pop $ProtocolDropList
			${NSD_CB_AddString} $ProtocolDropList "---"
			${NSD_CB_AddString} $ProtocolDropList "HTTP"
			${NSD_CB_AddString} $ProtocolDropList "FTP"
			${NSD_CB_SelectString} $ProtocolDropList "$Protocol"
		${NSD_CreateLabel} 15u 77u 90u 10u "$(TXT_EtiqDominioServidor)"
		Pop $0
		${NSD_CreateText} 110u 75u 90u 12u "$Server"
		Pop $ServerInput
		${NSD_CreateButton} 215u 59u 60u 16u "$(TXT_BotonComprobar)"
		Pop $btnTest
		${NSD_OnClick} $btnTest TestConnection
		${NSD_CreateLabel} 15u 93u 90u 10u "$(TXT_EtiqUsuarioFtp)"
		Pop $0
		${NSD_CreateText} 110u 91u 90u 12u "$User"
		Pop $UserInput
		${NSD_CreateLabel} 15u 109u 90u 10u "$(TXT_EtiqPassFtp)"
		Pop $0
		${NSD_CreatePassword} 110u 107u 90u 12u "$Pass"
		Pop $PassInput
		${NSD_CreateCheckbox} 110u 124u 150u 10u "$(TXT_EtiqRecordarCreds)"
		Pop $RememberCredsCheckbox
		${If} $RememberCreds == "1"
			${NSD_Check} $RememberCredsCheckbox
		${EndIf}
	nsDialogs::Show
	Pop $0
FunctionEnd

Function SaveOptionsForm
	Push $0
	${NSD_GetText} $DriveDropList $0
	StrCpy $InstDrive $0 2
	${NSD_GetText} $ServerInput $Server
	${NSD_GetText} $UserInput $User
	${NSD_GetText} $PassInput $Pass
	${NSD_GetText} $ProtocolDropList $Protocol
	${If} $Server == ""
	${AndIf} $Protocol != "---"
		MessageBox MB_ICONEXCLAMATION "$(TXT_MsgFaltaDominio)"
		Abort
	${Endif}
	${NSD_GetState} $RememberCredsCheckbox $RememberCreds
	${If} $Protocol == "FTP"
		${If} $User == ""
		${OrIf} $Pass == ""
			MessageBox MB_ICONEXCLAMATION "$(TXT_MsgFaltanCredencialesFtp)"
			Abort
		${EndIf}
	${EndIf}
	Pop $0
FunctionEnd

Function TestConnection
	${NSD_GetText} $ServerInput $Server
	${If} $Server == ""
		MessageBox MB_ICONEXCLAMATION "$(TXT_MsgFaltaDominio)"
		Return
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i0)'
	${NSD_GetText} $ProtocolDropList $Protocol
	${If} $Protocol == "FTP"
		Call TestFtpConnection
	${ElseIf} $Protocol == "HTTP"
		Call TestHttpConnection
	${Else}
		MessageBox MB_ICONEXCLAMATION "$(TXT_MsgFaltaProtocolo)"
	${EndIf}
	System::Call 'user32::EnableWindow(p$btnTest,i1)'
FunctionEnd

Function TestFtpConnection
	Push $R0
	Push $R1
	${NSD_GetText} $UserInput $User
	${NSD_GetText} $PassInput $Pass
	${If} $User == ""
	${OrIf} $Pass == ""
		MessageBox MB_ICONEXCLAMATION "$(TXT_MsgFaltanCredencialesFtp)"
		Return
	${EndIf}
	Push $R0
	Push $R1
	nsExec::ExecToStack '"curl.exe" -u $User@$Server:$Pass "ftp://$Server" --silent --list-only --connect-timeout 5'
	Pop $R0
	Pop $R1
	${If} $R0 == 0
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "$(TXT_MsgConexionFtpExito)"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "$(TXT_MsgConexionFtpError)$\n$R1"
	${EndIf}
	Pop $R1
	Pop $R0
FunctionEnd

Function TestHttpConnection
	Push $R0
	Push $R1
	nsExec::ExecToStack '"curl.exe" -s -S -L -I --connect-timeout 5 --write-out "%{http_code}" -o NUL "https://$Server/herramientas/${CATALOGFILE}"'
	Pop $R1
	Pop $R0
	${If} $R0 == "200"
	${AndIf} $R1 == "0"
		MessageBox MB_ICONINFORMATION|MB_SETFOREGROUND "$(TXT_MsgConexionHttpExito)"
	${Else}
		MessageBox MB_ICONSTOP|MB_SETFOREGROUND "$(TXT_MsgConexionHttpError)$\n$(TXT_MsgDetallesRespuesta) $R0"
	${EndIf}
	Pop $R1
	Pop $R0
FunctionEnd

Function FillDriveList
	${GetDrives} "ALL" AddDriveCallback
FunctionEnd

Function AddDriveCallback
	Push $9
	StrCpy $0 $9
	${DriveSpace} "$0" "/D=F" $1
	System::Int64Op $1 / 1073741824
	Pop $tmpGB
	${If} $tmpGB != ""
		StrCpy $2 "$0 ($tmpGB $(TXT_GbLibres))"
		${NSD_CB_AddString} $hDriveDropList $2
	${EndIf}
	Push ""
	Pop $9
FunctionEnd
