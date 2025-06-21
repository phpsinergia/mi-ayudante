Var ComponentesTotal
Var ComponentesVisibles
Var Ajuste
Var Pos
Var GroupIndex
Var GroupName
Var ToolId
Var ToolName
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolTarget
Var ToolUninstall
Var SectionIndex
Var ToolTempDir
Var LogMsg

;--------------------------------
; MACROS

!macro MJsonLoadComponents TIPO
	StrCpy $ComponentesTotal "0"
	StrCpy $ComponentesVisibles "0"
	StrCpy $GroupIndex "0"
	StrCpy $GroupName ""
	nsJSON::Get /count `${TIPO}` /end
	Pop $ComponentesTotal
	${If} $ComponentesTotal > 0
		IntOp $ComponentesTotal $ComponentesTotal - 1
		nsArray::Get MapCatalog ${TIPO}
		Pop $GroupIndex
		${For} $Pos 0 $ComponentesTotal
			nsJSON::Get `${TIPO}` /index $Pos "id" /end
			Pop $ToolId
			nsJSON::Get `${TIPO}` /index $Pos "name" /end
			Pop $ToolName
			nsJSON::Get `${TIPO}` /index $Pos "version" /end
			Pop $ToolVersion
			nsJSON::Get `${TIPO}` /index $Pos "size_kb" /end
			Pop $ToolSizeKb
			nsJSON::Get `${TIPO}` /index $Pos "add_path" /end
			Pop $ToolAddPath
			nsJSON::Get `${TIPO}` /index $Pos "op_chk" /end
			Pop $ToolOpChk
			nsJSON::Get `${TIPO}` /index $Pos "hash" /end
			Pop $ToolHash
			nsJSON::Get `${TIPO}` /index $Pos "target" /end
			Pop $ToolTarget
			nsJSON::Get `${TIPO}` /index $Pos "uninstall" /end
			Pop $ToolUninstall
			IntOp $Ajuste $GroupIndex + 1
			IntOp $SectionIndex $Pos + $Ajuste
			nsArray::Set List${TIPO}Id /key=$SectionIndex $ToolId
			nsArray::Set List${TIPO}Name /key=$SectionIndex $ToolName
			nsArray::Set List${TIPO}Version /key=$SectionIndex $ToolVersion
			nsArray::Set List${TIPO}SizeKb /key=$SectionIndex $ToolSizeKb
			nsArray::Set List${TIPO}AddPath /key=$SectionIndex $ToolAddPath
			nsArray::Set List${TIPO}OpChk /key=$SectionIndex $ToolOpChk
			nsArray::Set List${TIPO}Hash /key=$SectionIndex $ToolHash
			nsArray::Set List${TIPO}Target /key=$SectionIndex $ToolTarget
			nsArray::Set List${TIPO}Uninstall /key=$SectionIndex $ToolUninstall
		${Next}
	${EndIf}
!macroend

!macro MGetInfoComponent TIPO
	nsArray::Get List${TIPO}Id /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get List${TIPO}Name /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get List${TIPO}Version /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get List${TIPO}SizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get List${TIPO}AddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get List${TIPO}OpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get List${TIPO}Hash /at=$Pos
	Pop $1
	Pop $ToolHash
	nsArray::Get List${TIPO}Target /at=$Pos
	Pop $1
	Pop $ToolTarget
	nsArray::Get List${TIPO}Uninstall /at=$Pos
	Pop $1
	Pop $ToolUninstall
	IntOp $Ajuste $GroupIndex + 1
	IntOp $SectionIndex $Pos + $Ajuste
!macroend

!macro MCreateFunctionsComponent TIPO
Function InstallByIndex${TIPO}
	!insertmacro MInstallComponentsByIndex "${TIPO}"
FunctionEnd
Function JsonLoad${TIPO}
	!insertmacro MJsonLoadComponents "${TIPO}"
FunctionEnd
Function GetInfo${TIPO}
	!insertmacro MGetInfoComponent "${TIPO}"
FunctionEnd
Function CheckGroup${TIPO}
	!insertmacro MCheckGroupComponents "${TIPO}"
FunctionEnd
!macroend

!macro MCreateSectionComponent TIPO GRUPO INDEX
Section /o "" ${INDEX}
	StrCpy $GroupIndex ${GRUPO}
	IntOp $Ajuste $GroupIndex + 1
	IntOp $Pos ${INDEX} - $Ajuste
	${If} $Pos < ${MAX_COMPONENTES}
		Call InstallByIndex${TIPO}
	${EndIf}
SectionEnd
!macroend

!macro MCheckGroupComponents TIPO
	Call JsonLoad${TIPO}
	${For} $Pos 0 $ComponentesTotal
		${If} $Pos < ${MAX_COMPONENTES}
			Call GetInfo${TIPO}
			SectionSetText $SectionIndex $ToolName
			SectionSetSize $SectionIndex $ToolSizeKb

			;TODO: Cambiar por verificación en componentes.ini
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"

				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $SectionIndex $0
				SectionSetText $SectionIndex ""
			${Else}
				${If} "$ToolOpChk" == "0"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					SectionSetFlags $SectionIndex 0
				${ElseIf} "$ToolOpChk" == "1"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					SectionSetFlags $SectionIndex ${SF_SELECTED}
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $SectionIndex $0
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $SectionIndex $0
				${ElseIf} "$ToolOpChk" == "4"
					SectionSetFlags $SectionIndex 0
					SectionSetText $SectionIndex ""
				${EndIf}
			${EndIf}
		${EndIf}
	${Next}
	${If} $ComponentesVisibles == "0"
		SectionSetText $GroupIndex ""
	${EndIf}
!macroend

!macro MInstallComponentsByIndex TIPO
	${If} $Pos >= ${MAX_COMPONENTES}
		Return
	${EndIf}
	Call GetInfo${TIPO}
	${If} ${SectionIsSelected} $SectionIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTempDir == ""
		Return
	${EndIf}
	DetailPrint "..."
	DetailPrint "$(TXT_MsgInstalando) $ToolId"
	${If} $ToolTarget == "appdir"
		Call InstallOnAppDir
	${ElseIf} $ToolTarget == "vendor"
		Call InstallOnVendor
	${ElseIf} $ToolTarget == "tools"
		Call InstallOnTools
	${ElseIf} $ToolTarget == "resources"
		Call InstallOnResources
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$InstDrive${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	${If} $ToolId == "release"
		StrCpy $Version $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
!macroend

!macro MUninstallTools
	;TODO: Cambiar para que elimine usando componentes.ini
	Call un.JsonLoadComplementos
	${For} $Pos 0 ${MAX_COMPONENTES}
		${If} $Pos < ${MAX_COMPONENTES}
			Call un.GetInfoComplementos
			RMDir /r "$InstDrive${TOOLS}\$ToolId"
			Push "$InstDrive${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	Call un.JsonLoadRequisitos
	${For} $Pos 0 ${MAX_COMPONENTES}
		${If} $Pos < ${MAX_COMPONENTES}
			Call un.GetInfoRequisitos
			RMDir /r "$InstDrive${TOOLS}\$ToolId"
			Push "$InstDrive${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
!macroend

!insertmacro WordFind

;--------------------------------
; FUNCIONES INSTALACION
;--------------------------------

Function FetchCatalog
	StrCpy $ToolsCatalog "$InstDrive$INSTDIR\${CATALOGFILE}"
	CreateDirectory "$InstDrive$INSTDIR"
	${If} ${FileExists} $ToolsCatalog
		Delete $ToolsCatalog
	${EndIf}
	${If} $Server == ""
	${OrIf} $Protocol == ""
	${OrIf} $Protocol == "---"
		Goto LoadLocalCatalog
	${Endif}
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$ToolsCatalog" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$ToolsCatalog" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		${If} ${FileExists} "$ToolsCatalog"
			Goto MapCatalog
		${Else}
			Goto LoadLocalCatalog
		${EndIf}
	${EndIf}
LoadLocalCatalog:
	SetOutPath "$InstDrive$INSTDIR"
	File /oname=${CATALOGFILE} "catalogo.json"
	${If} ${FileExists} "$ToolsCatalog"
		Goto MapCatalog
	${EndIf}
MapCatalog:
	Call CreateMapCatalog
FunctionEnd

Function CreateMapCatalog
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count /end
	Pop $0 ;Total
	IntOp $R1 $0 - 1
	${For} $Pos 0 $R1
		nsJSON::Get /key /index $Pos /end
		Pop $R2 ;Nombre
		IntOp $R3 $Pos * 23
		IntOp $R4 $R3 + 3
		nsArray::Set MapCatalog /key=$R2 $R4
	${Next}
FunctionEnd

Function CheckAllComponents
	Call FetchCatalog
	;TODO: Hacer dinámico y sin nombres
	Call CheckGroupActualizaciones
	Call CheckGroupRequisitos
	Call CheckGroupComplementos
	Call CheckGroupExtensiones
	Call CheckGroupRecursos
	Call CheckSectionPrograma
FunctionEnd

Function CheckSectionPrograma
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} $(TXT_EtiqReinstalar)"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
		SectionSetFlags ${SEC_RELEASE} 0
		SectionSetText ${SEC_RELEASE} ""
	${EndIf}
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
	DetailPrint "$(TXT_LogAddPath) $0"
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndAdd:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

;--------------------------------

Function InstallOnAppDir
	CopyFiles /SILENT "$ToolTempDir\*.*" "$InstDrive$INSTDIR\"
FunctionEnd

Function InstallOnTools
	StrCpy $R8 $ToolTempDir 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "$InstDrive${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTempDir" "$InstDrive${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTempDir\*.*" "$InstDrive${TOOLS}\$ToolId\"
	${EndIf}
FunctionEnd

Function InstallOnResources
	StrCpy $R8 $ToolTempDir 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "${RESOURCES}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTempDir" "${RESOURCES}\$ToolId"
	${Else}
		CreateDirectory "${RESOURCES}\$ToolId"
		CopyFiles /SILENT "$ToolTempDir\*.*" "${RESOURCES}\$ToolId\"
	${EndIf}
FunctionEnd

Function InstallOnVendor
	StrCpy $R8 $ToolTempDir 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "$InstDrive${VENDOR}"
	${If} "$R8" == "$R9"
		Rename "$ToolTempDir" "$InstDrive${VENDOR}"
	${Else}
		CreateDirectory "$InstDrive${VENDOR}"
		CopyFiles /SILENT "$ToolTempDir\*.*" "$InstDrive${VENDOR}"
	${EndIf}
FunctionEnd

;--------------------------------

Function DownloadSinglePack
	${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
	${OrIf} $ToolId == ""
		Goto SkipTool
	${EndIf}
	Call DownloadFile
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Call VerifySHA256
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Call ExtractZip
	Pop $R1
	${If} $R1 == "NO"
		Goto SkipTool
	${EndIf}
	Push "OK"
	Return
SkipTool:
	Push "NO"
FunctionEnd

Function DownloadFile
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/$ToolId.zip"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgDescargando) $R0"
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$PluginsDir\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "$(TXT_MsgErrorDescargaFtp) $ToolId$\n$R2"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipDownload
		${EndIf}
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/$ToolId.zip"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgDescargando) $R0"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$PluginsDir\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 == "0"
			Goto SuccessDownload
		${Else}
			StrCpy $LogMsg "$(TXT_MsgErrorDescargaHttp) $ToolId$\n$(TXT_CodigoRespuesta) $R1"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipDownload
		${EndIf}
	${Else}
		Goto SkipDownload
	${EndIf}
SuccessDownload:
	Push "OK"
	Return
SkipDownload:
	Push "NO"
FunctionEnd

Function VerifySHA256
	DetailPrint "$(TXT_MsgVerificando) $ToolName ($ToolId.zip)"
	nsExec::ExecToStack 'CertUtil -hashfile "$PluginsDir\$ToolId.zip" SHA256'
	Pop $0
	Pop $1
	StrCmp $0 0 +5
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipVerify
	${If} $1 != ""
	${AndIf} $ToolHash != ""
		${WordFind} "$1" "$ToolHash" "+1" $2
		${If} $2 != ""
			DetailPrint "$(TXT_MsgHashValidado) $ToolHash"
			Goto SuccessVerify
		${Else}
			StrCpy $LogMsg "$(TXT_MsgErrorHashNoCoincide) $ToolId.zip$\n$2 ≠ $ToolHash"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONSTOP "$LogMsg"
			Goto SkipVerify
		${EndIf}
	${Else}
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipVerify
	${EndIf}
SuccessVerify:
	Push "OK"
	Return
SkipVerify:
	Push "NO"
FunctionEnd

Function ExtractZip
	DetailPrint "..."
	StrCpy $ToolTempDir "$PluginsDir\$ToolId_tmp"
	RMDir /r "$ToolTempDir"
	CreateDirectory "$ToolTempDir"
	SetOutPath "$ToolTempDir"
	Nsisunz::UnzipToLog "$PluginsDir\$ToolId.zip" "$ToolTempDir"
	Pop $R1
	${If} $R1 != "success"
		StrCpy $LogMsg "$(TXT_MsgErrorDescomprimir) $ToolName: $R1"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipExtract
	${EndIf}
	${GetSize} "$ToolTempDir" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolSizeKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 +2
		Goto SuccessExtract
	StrCpy $LogMsg "$(TXT_MsgErrorTamano) $ToolName ($R4 KB ≠ $ToolSizeKb KB)"
	DetailPrint "$LogMsg"
	MessageBox MB_ICONEXCLAMATION "$LogMsg"
	Goto SkipExtract
SuccessExtract:
	Push "OK"
	Return
SkipExtract:
	Push "NO"
FunctionEnd

;--------------------------------
; FUNCIONES DESINSTALACION

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

Function un.JsonLoadCatalog
	CopyFiles /SILENT /FILESONLY "$INSTDIR\${CATALOGFILE}" "$PluginsDir\"
	StrCpy $ToolsCatalog "$PluginsDir\${CATALOGFILE}"
	nsJSON::Set /file $ToolsCatalog
FunctionEnd

Function un.JsonLoadComplementos
	!insertmacro MJsonLoadComponents "Complementos"
FunctionEnd

Function un.JsonLoadRequisitos
	!insertmacro MJsonLoadComponents "Requisitos"
FunctionEnd

Function un.GetInfoComplementos
	!insertmacro MGetInfoComponent "Complementos"
FunctionEnd

Function un.GetInfoRequisitos
	!insertmacro MGetInfoComponent "Requisitos"
FunctionEnd
