Var ComponentesTotal
Var ComponentesVisibles
Var Ajuste
Var Pos
Var GroupIndex
Var ToolId
Var ToolName
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolTarget
Var ToolUninstall
Var ToolIndex
Var ToolTempDir
Var LogMsg

;--------------------------------
; MACROS

!macro MJsonLoadComponents TIPO
	StrCpy $ComponentesTotal "0"
	StrCpy $ComponentesVisibles "0"

	StrCpy $Pos "0"
	StrCpy $Ajuste "0"

	nsJSON::Get /count `${TIPO}` /end
	Pop $ComponentesTotal
	${If} $ComponentesTotal > 0
		IntOp $ComponentesTotal $ComponentesTotal - 1
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

;GRP_Actualizaciones 3
;GRP_Requisitos 26
;GRP_Complementos 49
;GRP_Extensiones 72
;GRP_Recursos 95

;IntOp $R3 $Pos * 23
;IntOp $R3 $R3 + 3

			IntOp $Ajuste ${GRP_${TIPO}} + 1
			IntOp $ToolIndex $Pos + $Ajuste

			nsArray::Set List${TIPO}Id /key=$ToolIndex $ToolId
			nsArray::Set List${TIPO}Name /key=$ToolIndex $ToolName
			nsArray::Set List${TIPO}Version /key=$ToolIndex $ToolVersion
			nsArray::Set List${TIPO}SizeKb /key=$ToolIndex $ToolSizeKb
			nsArray::Set List${TIPO}AddPath /key=$ToolIndex $ToolAddPath
			nsArray::Set List${TIPO}OpChk /key=$ToolIndex $ToolOpChk
			nsArray::Set List${TIPO}Hash /key=$ToolIndex $ToolHash
			nsArray::Set List${TIPO}Target /key=$ToolIndex $ToolTarget
			nsArray::Set List${TIPO}Uninstall /key=$ToolIndex $ToolUninstall
		${Next}
		${For} $Pos $ComponentesTotal ${MAX_COMPONENTES}
			${If} $Pos > $ComponentesTotal

				IntOp $Ajuste ${GRP_${TIPO}} + 1
				IntOp $ToolIndex $Pos + $Ajuste

				nsArray::Set List${TIPO}Id /key=$ToolIndex ""
				nsArray::Set List${TIPO}Name /key=$ToolIndex ""
				nsArray::Set List${TIPO}Version /key=$ToolIndex ""
				nsArray::Set List${TIPO}SizeKb /key=$ToolIndex 0
				nsArray::Set List${TIPO}AddPath /key=$ToolIndex 0
				nsArray::Set List${TIPO}OpChk /key=$ToolIndex 0
				nsArray::Set List${TIPO}Hash /key=$ToolIndex ""
				nsArray::Set List${TIPO}Target /key=$ToolIndex ""
				nsArray::Set List${TIPO}Uninstall /key=$ToolIndex 0
			${EndIf}
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

	IntOp $Ajuste ${GRP_${TIPO}} + 1
	IntOp $ToolIndex $Pos + $Ajuste

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
Function CheckGrp${TIPO}
	!insertmacro MCheckGrpComponents "${TIPO}"
FunctionEnd
!macroend

!macro MCreateSectionComponent TIPO GRUPO INDEX
Section /o "" ${INDEX}
	
	StrCpy $GroupIndex ${GRUPO}
	IntOp $Ajuste ${GRP_${TIPO}} + 1

	IntOp $Pos ${INDEX} - $Ajuste
	${If} $Pos < ${MAX_COMPONENTES}
		Call InstallByIndex${TIPO}
	${EndIf}
SectionEnd
!macroend

!macro MCheckGrpComponents TIPO
	Call JsonLoad${TIPO}
	${For} $Pos 0 $ComponentesTotal
		${If} $Pos < ${MAX_COMPONENTES}
			Call GetInfo${TIPO}
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb

			;TODO: Cambiar por verificación en componentes.ini
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"

				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				${If} "$ToolOpChk" == "0"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					SectionSetFlags $ToolIndex 0
				${ElseIf} "$ToolOpChk" == "1"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					SectionSetFlags $ToolIndex ${SF_SELECTED}
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
				${ElseIf} "$ToolOpChk" == "4"
					SectionSetFlags $ToolIndex 0
					SectionSetText $ToolIndex ""
				${EndIf}
			${EndIf}
		${EndIf}
	${Next}
	${If} $ComponentesVisibles == "0"
		SectionSetText ${GRP_${TIPO}} ""
	${EndIf}
!macroend

!macro MInstallComponentsByIndex TIPO
	${If} $Pos >= ${MAX_COMPONENTES}
		Return
	${EndIf}
	Call GetInfo${TIPO}
	${If} ${SectionIsSelected} $ToolIndex
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
			nsJSON::Set /file $ToolsCatalog
			Goto MapCatalog
		${Else}
			Goto LoadLocalCatalog
		${EndIf}
	${EndIf}
LoadLocalCatalog:
	SetOutPath "$InstDrive$INSTDIR"
	File /oname=${CATALOGFILE} "catalogo.json"
	${If} ${FileExists} "$ToolsCatalog"
		nsJSON::Set /file $ToolsCatalog
		Goto MapCatalog
	${EndIf}
MapCatalog:
	nsJSON::Get /count /end
	Pop $0 ;Total
	IntOp $R1 $0 - 1
	${For} $Pos 0 $R1
		nsJSON::Get /key /index $Pos /end
		Pop $R2 ;Nombre
		IntOp $R3 $Pos * 23
		IntOp $R3 $R3 + 3
		MessageBox MB_OK "Pos Json (Index): $Pos $\nR3 (Section): $R3 $\nR2(Nombre): $R2"
	
	${Next}
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

Function CheckGrpPrograma
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} $(TXT_EtiqReinstalar)"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
	${EndIf}
FunctionEnd

Function CheckAllComponents
	Call FetchCatalog
	Call CheckGrpActualizaciones
	Call CheckGrpRequisitos
	Call CheckGrpComplementos
	Call CheckGrpExtensiones
	Call CheckGrpRecursos
	Call CheckGrpPrograma
FunctionEnd

;--------------------------------
;TODO: Refactorizar DownloadSinglePack en: DownloadFile + VerifySHA256 + ExtractZip

;Function DownloadFile
;FunctionEnd

;Function VerifySHA256
;FunctionEnd

;Function ExtractZip
;FunctionEnd

Function DownloadSinglePack
	${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
		Goto SkipTool
	${EndIf}

;DownloadTool:
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
			Goto SkipTool
		${EndIf}
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/$ToolId.zip"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgDescargando) $R0"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$PluginsDir\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "$(TXT_MsgErrorDescargaHttp) $ToolId$\n$(TXT_CodigoRespuesta) $R1"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipTool
		${EndIf}
	${Else}
		Goto SkipTool
	${EndIf}

;ValidateTool:
	!insertmacro WordFind
	DetailPrint "$(TXT_MsgVerificando) $ToolName ($ToolId.zip)"
	nsExec::ExecToStack 'CertUtil -hashfile "$PluginsDir\$ToolId.zip" SHA256'
	Pop $0
	Pop $1
	StrCmp $0 0 +5
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${If} $1 != ""
	${AndIf} $ToolHash != ""
		${WordFind} "$1" "$ToolHash" "+1" $2
		${If} $2 != ""
			DetailPrint "$(TXT_MsgHashValidado) $ToolHash"
			Goto ExtractTool
		${Else}
			StrCpy $LogMsg "$(TXT_MsgErrorHashNoCoincide) $ToolId.zip$\n$2 ≠ $ToolHash"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONSTOP "$LogMsg"
			Goto SkipTool
		${EndIf}
	${Else}
		StrCpy $LogMsg "$(TXT_MsgErrorHashNoCalculado) $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${EndIf}

ExtractTool:
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
		Goto SkipTool
	${EndIf}
	${GetSize} "$ToolTempDir" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolSizeKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 +2
		Goto SuccessTool
	StrCpy $LogMsg "$(TXT_MsgErrorTamano) $ToolName ($R4 KB ≠ $ToolSizeKb KB)"
	DetailPrint "$LogMsg"
	MessageBox MB_ICONEXCLAMATION "$LogMsg"
	Goto SkipTool

SuccessTool:
	Push "OK"
	Return
SkipTool:
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
