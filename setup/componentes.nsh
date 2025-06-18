!define MAX_Actualizaciones 10
!define MAX_Requisitos 10
!define MAX_Complementos 30
!define MAX_Extensiones 20
!define MAX_Recursos 30
!define SEC_PROGRAMA 2
!define GRP_Actualizaciones 3
!define GRP_Requisitos 15
!define GRP_Complementos 28
!define GRP_Extensiones 61
!define GRP_Recursos 84

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
Var ActualizacionesTotal
Var ComplementosTotal
Var RequisitosTotal
Var ExtensionesTotal
Var RecursosTotal
Var ComplementosVisibles
Var RequisitosVisibles
Var ExtensionesVisibles
Var RecursosVisibles

;--------------------------------
; MACROS

!macro MJsonLoadComponents TIPO
	nsJSON::Get /count `${TIPO}` /end
	Pop $${TIPO}Total
	${If} $${TIPO}Total > 0
		IntOp $${TIPO}Total $${TIPO}Total - 1
		${For} $Pos 0 $${TIPO}Total
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
		${For} $Pos $${TIPO}Total ${MAX_${TIPO}}
			${If} $Pos > $${TIPO}Total
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
	${If} $Pos < ${MAX_${TIPO}}
		Call InstallByIndex${TIPO}
	${EndIf}
SectionEnd
!macroend

!macro MCheckGrpComponents TIPO
	StrCpy $${TIPO}Visibles "0"
	StrCpy $${TIPO}Total "0"
	Call JsonLoad${TIPO}
	${For} $Pos 0 $${TIPO}Total
		${If} $Pos < ${MAX_${TIPO}}
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
				IntOp $${TIPO}Visibles $${TIPO}Visibles + 1
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
	${If} $${TIPO}Visibles == "0"
		SectionSetText ${GRP_${TIPO}} ""
	${EndIf}
!macroend

!macro MInstallComponentsByIndex TIPO
	${If} $Pos >= ${MAX_${TIPO}}
	${OrIf} $Pos > $${TIPO}Total
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
	Call DeleteTempFiles
!macroend

!macro MUninstallTools
	Call un.JsonLoadComplementos
	${For} $Pos 0 $ComplementosTotal
		${If} $Pos < ${MAX_Complementos}
			Call un.GetInfoComplementos
			RMDir /r "$InstDrive${TOOLS}\$ToolId"
			Push "$InstDrive${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	Call un.JsonLoadRequisitos
	${For} $Pos 0 $RequisitosTotal
		${If} $Pos < ${MAX_Requisitos}
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
	${If} $Pos >= ${MAX_Actualizaciones}
	${OrIf} $Pos > $ActualizacionesTotal
		Return
	${EndIf}
	Call GetInfoActualizaciones
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	${If} $ToolId == "release"
		${If} $ToolVersion == $Version
			Return
		${EndIf}
		MessageBox MB_YESNO|MB_ICONQUESTION "$(TXT_MsgConfirmaActualizacion)$\n$\n$(TXT_MsgActual): $Version$\n$(TXT_MsgNueva): $ToolVersion" IDNO EndActualizaciones
	${EndIf}
	DetailPrint "$(TXT_LogDescargandoActualizacion) $ToolName v$ToolVersion"
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		DetailPrint "$(TXT_MsgErrorActualizacion)"
		Goto Tag_FIN_Actualizaciones
	${EndIf}
	DetailPrint "..."
	DetailPrint "$(TXT_LogInstalandoActualizaciones) $ToolVersion"
	Call ActualizacionesInstallSingle
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Actualizaciones:
	Call DeleteTempFiles
	Return
EndActualizaciones:
	DetailPrint "$(TXT_MsgActualizacionCancelada)"
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
	${If} $ToolId == "release"
		StrCpy $Version $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	${EndIf}
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

Function DeleteTempFiles
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
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
	Call CheckPrograma
	Call CheckActualizaciones
	Call CheckGrpRequisitos
	Call CheckGrpComplementos
	Call CheckGrpExtensiones
	Call CheckGrpRecursos
FunctionEnd

Function CheckPrograma
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} $(TXT_EtiqReinstalar)"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
	${EndIf}
FunctionEnd

Function CheckActualizaciones
	StrCpy $ActualizacionesTotal "0"
	Call JsonLoadActualizaciones
	${For} $Pos 0 $ActualizacionesTotal
		${If} $Pos < ${MAX_Actualizaciones}
			Call GetInfoActualizaciones
			${If} $IsUpdateInstall == "1"
				SectionSetText $ToolIndex "$ToolName $ToolVersion"
				SectionSetSize $ToolIndex $ToolSizeKb
				${If} $ToolId == "release"
					${If} $ToolVersion == $Version
						SectionSetText $ToolIndex ""
						SectionSetSize $ToolIndex 0
						SectionSetFlags $ToolIndex 0
					${Else}
						SectionSetFlags $ToolIndex ${SF_SELECTED}
					${EndIf}
				${Else}
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
			${Else}
				SectionSetText $ToolIndex ""
				SectionSetSize $ToolIndex 0
				SectionSetFlags $ToolIndex 0
			${EndIf}
		${EndIf}
	${Next}
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
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$TEMP\$ToolId.zip" --silent --show-error --fail'
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
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$TEMP\$ToolId.zip" "$R0"'
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
	nsExec::ExecToStack 'CertUtil -hashfile "$TEMP\$ToolId.zip" SHA256'
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
	StrCpy $ToolTemp "$TEMP\$ToolId_tmp"
	RMDir /r "$ToolTemp"
	CreateDirectory "$ToolTemp"
	SetOutPath "$ToolTemp"
	Nsisunz::UnzipToLog "$TEMP\$ToolId.zip" "$ToolTemp"
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
	CopyFiles /SILENT /FILESONLY "$INSTDIR\$CatalogFile" "$TEMP\"
	StrCpy $ToolsCatalog "$TEMP\$CatalogFile"
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
