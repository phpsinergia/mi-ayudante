Var Ajuste
Var Pos
Var ToolId
Var ToolName
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolIndex
Var ToolTemp
Var LogMsg
Var ComponentesTotal
Var ComponentesVisibles

;--------------------------------
; MACROS

!macro MJsonLoadComponents TIPO
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
			IntOp $Ajuste ${GRP_${TIPO}} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set List${TIPO}Id /key=$ToolIndex $ToolId
			nsArray::Set List${TIPO}Name /key=$ToolIndex $ToolName
			nsArray::Set List${TIPO}Version /key=$ToolIndex $ToolVersion
			nsArray::Set List${TIPO}SizeKb /key=$ToolIndex $ToolSizeKb
			nsArray::Set List${TIPO}AddPath /key=$ToolIndex $ToolAddPath
			nsArray::Set List${TIPO}OpChk /key=$ToolIndex $ToolOpChk
			nsArray::Set List${TIPO}Hash /key=$ToolIndex $ToolHash
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
	IntOp $Ajuste ${GRP_${TIPO}} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MCreateSectionComponent TIPO INDEX
Section /o "" ${INDEX}
	IntOp $Ajuste ${GRP_${TIPO}} + 1
	IntOp $Pos ${INDEX} - $Ajuste
	${If} $Pos < ${MAX_COMPONENTES}
		Call InstallByIndex${TIPO}
	${EndIf}
SectionEnd
!macroend

!macro MCheckGrpComponents TIPO
	StrCpy $ComponentesVisibles "0"
	StrCpy $ComponentesTotal "0"
	Call JsonLoad${TIPO}
	${For} $Pos 0 $ComponentesTotal
		${If} $Pos < ${MAX_COMPONENTES}
			Call GetInfo${TIPO}
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				IntOp $ComponentesVisibles $ComponentesVisibles + 1
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
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
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_${TIPO}
	${EndIf}
	DetailPrint "..."
	DetailPrint "$(TXT_MsgInstalando${TIPO}) $ToolId"
	Call ${TIPO}InstallSingle
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_${TIPO}:
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
;JsonLoad...

Function JsonLoadComplementos
	!insertmacro MJsonLoadComponents "Complementos"
FunctionEnd

Function JsonLoadRequisitos
	!insertmacro MJsonLoadComponents "Requisitos"
FunctionEnd

Function JsonLoadActualizaciones
	!insertmacro MJsonLoadComponents "Actualizaciones"
FunctionEnd

Function JsonLoadExtensiones
	!insertmacro MJsonLoadComponents "Extensiones"
FunctionEnd

Function JsonLoadRecursos
	!insertmacro MJsonLoadComponents "Recursos"
FunctionEnd

;--------------------------------
;GetInfo...

Function GetInfoComplementos
	!insertmacro MGetInfoComponent "Complementos"
FunctionEnd

Function GetInfoRequisitos
	!insertmacro MGetInfoComponent "Requisitos"
FunctionEnd

Function GetInfoActualizaciones
	!insertmacro MGetInfoComponent "Actualizaciones"
FunctionEnd

Function GetInfoExtensiones
	!insertmacro MGetInfoComponent "Extensiones"
FunctionEnd

Function GetInfoRecursos
	!insertmacro MGetInfoComponent "Recursos"
FunctionEnd

;--------------------------------
;CheckGrp...

Function CheckGrpRequisitos
	!insertmacro MCheckGrpComponents "Requisitos"
FunctionEnd

Function CheckGrpComplementos
	!insertmacro MCheckGrpComponents "Complementos"
FunctionEnd

Function CheckGrpExtensiones
	!insertmacro MCheckGrpComponents "Extensiones"
FunctionEnd

Function CheckGrpRecursos
	!insertmacro MCheckGrpComponents "Recursos"
FunctionEnd

Function CheckGrpActualizaciones
	!insertmacro MCheckGrpComponents "Actualizaciones"
FunctionEnd

;--------------------------------
;InstallByIndex...

Function InstallByIndexComplementos
	!insertmacro MInstallComponentsByIndex "Complementos"
FunctionEnd

Function InstallByIndexRequisitos
	!insertmacro MInstallComponentsByIndex "Requisitos"
FunctionEnd

Function InstallByIndexExtensiones
	!insertmacro MInstallComponentsByIndex "Extensiones"
FunctionEnd

Function InstallByIndexRecursos
	!insertmacro MInstallComponentsByIndex "Recursos"
FunctionEnd

Function InstallByIndexActualizaciones
	!insertmacro MInstallComponentsByIndex "Actualizaciones"
FunctionEnd

;--------------------------------
;...InstallSingle

Function RecursosInstallSingle
	CreateDirectory "${RESOURCES}"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "${RESOURCES}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "${RESOURCES}\$ToolId"
	${Else}
		CreateDirectory "${RESOURCES}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "${RESOURCES}\$ToolId\"
	${EndIf}
FunctionEnd

Function RequisitosInstallSingle
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "$InstDrive${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$InstDrive${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolId == "vendor"
		DetailPrint ${SEPARATOR}
		DetailPrint "$(TXT_MsgInstalandoRequisitos) $ToolName v$ToolVersion"
		RMDir /r "$InstDrive${VENDOR}"
		Rename "$InstDrive${TOOLS}\$ToolId" "$InstDrive${VENDOR}"
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		SetOutPath "$InstDrive${TOOLS}\$ToolId"
		File "meta.json"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$InstDrive${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
FunctionEnd

Function ComplementosInstallSingle
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "$InstDrive${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$InstDrive${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$InstDrive${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
FunctionEnd

Function ExtensionesInstallSingle
	CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive$INSTDIR\"
FunctionEnd

Function ActualizacionesInstallSingle
	CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive$INSTDIR\"
FunctionEnd

;--------------------------------
;Genéricas

Function FetchCatalog
	StrCpy $ToolsCatalog "$InstDrive$INSTDIR\$CatalogFile"
	CreateDirectory "$InstDrive$INSTDIR"
	${If} ${FileExists} $ToolsCatalog
		Delete $ToolsCatalog
	${EndIf}
	${If} $Server == ""
	${OrIf} $Protocol == ""
	${OrIf} $Protocol == "---"
		Goto LoadLocalTools
	${Endif}
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/$CatalogFile"
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$ToolsCatalog" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/$CatalogFile"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$ToolsCatalog" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		${If} ${FileExists} "$ToolsCatalog"
			nsJSON::Set /file $ToolsCatalog
			Goto ExitFetchTools
		${Else}
			Goto LoadLocalTools
		${EndIf}
	${EndIf}
LoadLocalTools:
	SetOutPath "$InstDrive$INSTDIR"
	File "catalogo.json"
	${If} ${FileExists} "$ToolsCatalog"
		nsJSON::Set /file $ToolsCatalog
		Goto ExitFetchTools
	${EndIf}
ExitFetchTools:
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

Function CheckAllComponents
	Call FetchCatalog
	Call CheckGrpPrograma
	Call CheckGrpActualizaciones
	Call CheckGrpRequisitos
	Call CheckGrpComplementos
	Call CheckGrpExtensiones
	Call CheckGrpRecursos
FunctionEnd

Function CheckGrpPrograma
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} $(TXT_EtiqReinstalar)"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
	${EndIf}
	;TODO: Agregar Release
;InstallByIndex
	;TODO: Mover aparte
	;${If} $ToolId == "release"
	;	${If} $ToolVersion == $Version
	;		Return
	;	${EndIf}
	;	MessageBox MB_YESNO|MB_ICONQUESTION "$(TXT_MsgConfirmaActualizacion)$\n$\n$(TXT_MsgActual): $Version$\n$(TXT_MsgNueva): $ToolVersion" IDNO EndActualizaciones
	;${EndIf}
;InstallSingle
	;TODO: Mover aparte
	;${If} $ToolId == "release"
	;	StrCpy $Version $ToolVersion
	;	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	;	WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	;${EndIf}
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
	StrCpy $ToolTemp "$PluginsDir\$ToolId_tmp"
	RMDir /r "$ToolTemp"
	CreateDirectory "$ToolTemp"
	SetOutPath "$ToolTemp"
	Nsisunz::UnzipToLog "$PluginsDir\$ToolId.zip" "$ToolTemp"
	Pop $R1
	${If} $R1 != "success"
		StrCpy $LogMsg "$(TXT_MsgErrorDescomprimir) $ToolName: $R1"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${EndIf}
	${GetSize} "$ToolTemp" "/S=0K" $R4 $R5 $R6
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
	CopyFiles /SILENT /FILESONLY "$INSTDIR\$CatalogFile" "$PluginsDir\"
	StrCpy $ToolsCatalog "$PluginsDir\$CatalogFile"
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
