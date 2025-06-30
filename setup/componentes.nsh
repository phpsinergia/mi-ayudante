; componentes.nsh
;================================
; MODULO: COMPONENTES
;================================

;--------------------------------
; VARIABLES
;--------------------------------
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
Var SectionIndex
Var ToolTempDir
Var ToolFinalPath
Var CatalogPath
Var LogMsg
Var GroupName
Var CatalogStatus

;--------------------------------
; MACROS
;--------------------------------

!macro MJsonLoadComponents CATEGORIA
	StrCpy $ComponentesTotal "0"
	nsJSON::Get /count /index ${CATEGORIA} /end
	Pop $ComponentesTotal
	nsArray::Get GroupByPosSectionIndex ${CATEGORIA}
	Pop $GroupIndex
	nsArray::Get GroupByPosSectionName ${CATEGORIA}
	Pop $GroupName
	${If} $ComponentesTotal > 0
	${AndIf} $GroupIndex > 0
		SectionSetText $GroupIndex "$GroupName"
		IntOp $Ajuste $GroupIndex + 1
		IntOp $R0 $ComponentesTotal - 1
		${For} $Pos 0 $R0
			nsJSON::Get /index ${CATEGORIA} /index $Pos "id" /end
			Pop $ToolId
			nsJSON::Get /index ${CATEGORIA} /index $Pos "name" /end
			Pop $ToolName
			nsJSON::Get /index ${CATEGORIA} /index $Pos "version" /end
			Pop $ToolVersion
			nsJSON::Get /index ${CATEGORIA} /index $Pos "size_kb" /end
			Pop $ToolSizeKb
			nsJSON::Get /index ${CATEGORIA} /index $Pos "add_path" /end
			Pop $ToolAddPath
			nsJSON::Get /index ${CATEGORIA} /index $Pos "op_chk" /end
			Pop $ToolOpChk
			nsJSON::Get /index ${CATEGORIA} /index $Pos "hash" /end
			Pop $ToolHash
			nsJSON::Get /index ${CATEGORIA} /index $Pos "target" /end
			Pop $ToolTarget
			IntOp $SectionIndex $Pos + $Ajuste
			nsArray::Set List${CATEGORIA}Id /key=$SectionIndex $ToolId
			nsArray::Set List${CATEGORIA}Name /key=$SectionIndex $ToolName
			nsArray::Set List${CATEGORIA}Version /key=$SectionIndex $ToolVersion
			nsArray::Set List${CATEGORIA}SizeKb /key=$SectionIndex $ToolSizeKb
			nsArray::Set List${CATEGORIA}AddPath /key=$SectionIndex $ToolAddPath
			nsArray::Set List${CATEGORIA}OpChk /key=$SectionIndex $ToolOpChk
			nsArray::Set List${CATEGORIA}Hash /key=$SectionIndex $ToolHash
			nsArray::Set List${CATEGORIA}Target /key=$SectionIndex $ToolTarget
		${Next}
		${For} $Pos $ComponentesTotal ${MAX_COMPONENTES}
			IntOp $SectionIndex $Pos + $Ajuste
			nsArray::Set List${CATEGORIA}Id /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}Name /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}Version /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}SizeKb /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}AddPath /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}OpChk /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}Hash /key=$SectionIndex ""
			nsArray::Set List${CATEGORIA}Target /key=$SectionIndex ""
		${Next}
	${EndIf}
!macroend

!macro MGetInfoComponent CATEGORIA
	nsArray::Get List${CATEGORIA}Id /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get List${CATEGORIA}Name /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get List${CATEGORIA}Version /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get List${CATEGORIA}SizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get List${CATEGORIA}AddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get List${CATEGORIA}OpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get List${CATEGORIA}Hash /at=$Pos
	Pop $1
	Pop $ToolHash
	nsArray::Get List${CATEGORIA}Target /at=$Pos
	Pop $1
	Pop $ToolTarget
	IntOp $Ajuste $GroupIndex + 1
	IntOp $SectionIndex $Pos + $Ajuste
!macroend

!macro MCreateFunctionsComponent CATEGORIA
Function InstallByIndex${CATEGORIA}
	!insertmacro MInstallComponentsByIndex "${CATEGORIA}"
FunctionEnd
Function JsonLoad${CATEGORIA}
	!insertmacro MJsonLoadComponents "${CATEGORIA}"
FunctionEnd
Function GetInfo${CATEGORIA}
	!insertmacro MGetInfoComponent "${CATEGORIA}"
FunctionEnd
Function CheckGroup${CATEGORIA}
	!insertmacro MCheckGroupComponents "${CATEGORIA}"
FunctionEnd
!macroend

!macro MCreateSectionComponent CATEGORIA GRUPO SECCION
Section /o "" ${SECCION}
	StrCpy $GroupIndex ${GRUPO}
	IntOp $Ajuste $GroupIndex + 1
	IntOp $Pos ${SECCION} - $Ajuste
	${If} $Pos < ${MAX_COMPONENTES}
		Call InstallByIndex${CATEGORIA}
	${EndIf}
SectionEnd
!macroend

!macro MCheckGroupComponents CATEGORIA
	Call JsonLoad${CATEGORIA}
	StrCpy $ComponentesVisibles "0"
	${If} $ComponentesTotal > 0
		IntOp $R0 $ComponentesTotal - 1
		${For} $Pos 0 $R0
			${If} $Pos < ${MAX_COMPONENTES}
				Call GetInfo${CATEGORIA}
				Call CheckComponentInRegistry
				Pop $1
				${If} $1 == 2 ; misma versión
				${OrIf} $1 == 3 ; versión más reciente
					IntOp $R1 0 | ${SF_RO}
					SectionSetFlags $SectionIndex $R1
					SectionSetText $SectionIndex ""
				${ElseIf} $1 == 1 ; versión antigua
					IntOp $ComponentesVisibles $ComponentesVisibles + 1
					SectionSetText $SectionIndex $ToolName
					SectionSetFlags $SectionIndex ${SF_SELECTED}
					SectionSetSize $SectionIndex $ToolSizeKb
				${Else} ; no instalado
					${If} "$ToolOpChk" == "3"
						IntOp $R1 0 | ${SF_RO}
						SectionSetFlags $SectionIndex $R1
						SectionSetText $SectionIndex ""
					${Else}
						IntOp $ComponentesVisibles $ComponentesVisibles + 1
						SectionSetText $SectionIndex $ToolName
						SectionSetSize $SectionIndex $ToolSizeKb
						${If} "$ToolOpChk" == "0"
							SectionSetFlags $SectionIndex 0
						${ElseIf} "$ToolOpChk" == "1"
							SectionSetFlags $SectionIndex ${SF_SELECTED}
						${ElseIf} "$ToolOpChk" == "2"
							IntOp $R1 ${SF_SELECTED} | ${SF_RO}
							SectionSetFlags $SectionIndex $R1
						${EndIf}
					${EndIf}
				${EndIf}
			${EndIf}
		${Next}
	${EndIf}
	${If} $ComponentesVisibles == "0"
		SectionSetText $GroupIndex ""
	${EndIf}
!macroend

!macro MInstallComponentsByIndex CATEGORIA
	Call GetInfo${CATEGORIA}
	${IfNot} ${SectionIsSelected} $SectionIndex
	${OrIf} $ToolId == ""
	${OrIf} $Pos >= ${MAX_COMPONENTES}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTempDir == ""
		Return
	${EndIf}
	DetailPrint "..."
	DetailPrint "$(TXT_MsgInstalando) $ToolName"
	StrCpy $ToolFinalPath ""
	${If} $ToolTarget == "appdir"
		CopyFiles /SILENT "$ToolTempDir\*.*" "$InstDrive$INSTDIR\"
	${Else}
		${If} $ToolTarget == "vendor"
			StrCpy $ToolFinalPath "$InstDrive${VENDOR}"
		${ElseIf} $ToolTarget == "resources"
			StrCpy $ToolFinalPath "${RESOURCES}\$ToolId"
		${ElseIf} $ToolTarget == "tools"
			StrCpy $ToolFinalPath "$InstDrive${TOOLS}\$ToolId"
		${EndIf}
		${If} ${FileExists} $ToolFinalPath
			CopyFiles /SILENT "$ToolTempDir\*.*" "$ToolFinalPath\"
		${Else}
			StrCpy $R8 $ToolTempDir 2
			StrCpy $R9 $InstDrive 2
			${If} "$R8" == "$R9"
				Rename "$ToolTempDir" "$ToolFinalPath"
			${Else}
				CreateDirectory "$ToolFinalPath"
				CopyFiles /SILENT "$ToolTempDir\*.*" "$ToolFinalPath\"
			${EndIf}
		${EndIf}
	${EndIf}
	${If} $ToolAddPath == "1"
	${AndIf} $ToolFinalPath != ""
		Push "$ToolFinalPath"
		Call AddToEnvUserPath
	${EndIf}
	Call AddComponentToRegistry
	${If} $ToolId == "release"
		StrCpy $Version $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	${EndIf}
	DetailPrint "$ToolName $ToolVersion ($ToolId) → OK"
	StrCpy $ToolId ""
!macroend

!macro MCreateSectionLog GRUPO SECCION
Section "-" ${SECCION}
	Push ${GRUPO}
	Call WriteLogSection
SectionEnd
!macroend

;--------------------------------
; FUNCIONES
;--------------------------------

Function CheckAllComponents
	Push $R0
	Push $R1
	Push $R2
	Call FetchCatalog
	${If} $CatalogStatus == "OK"
		Call CheckGroup0
		Call CheckGroup1
		Call CheckGroup2
		Call CheckGroup3
		Call CheckGroup4
		Call CheckGroup5
		Call CheckGroup6
		Call CheckGroup7
		Call CheckGroup8
		Call CheckGroup9
	${Else}
		StrCpy $R0 "3"
		Call HideSectionGroup
		StrCpy $R0 "26"
		Call HideSectionGroup
		StrCpy $R0 "49"
		Call HideSectionGroup
		StrCpy $R0 "72"
		Call HideSectionGroup
		StrCpy $R0 "95"
		Call HideSectionGroup
		StrCpy $R0 "118"
		Call HideSectionGroup
		StrCpy $R0 "141"
		Call HideSectionGroup
		StrCpy $R0 "164"
		Call HideSectionGroup
		StrCpy $R0 "187"
		Call HideSectionGroup
		StrCpy $R0 "210"
		Call HideSectionGroup
	${EndIf}
	Call CheckSectionBase
	Pop $R2
	Pop $R1
	Pop $R0
FunctionEnd

Function HideSectionGroup
	SectionSetText $R0 ""
	IntOp $R1 $R0 + 1
	IntOp $R2 $R0 + 20
	${For} $Pos $R1 $R2
		SectionSetText $Pos ""
		SectionSetFlags $Pos 0
	${Next}
FunctionEnd

Function FetchCatalog
	Push $R0
	Push $R1
	Push $R2
	StrCpy $CatalogPath "$InstDrive$INSTDIR\${CATALOGFILE}"
	CreateDirectory "$InstDrive$INSTDIR"
	${If} ${FileExists} $CatalogPath
		Delete $CatalogPath
	${EndIf}
	${If} $Server == ""
		Goto LoadLocalCatalog
	${Endif}
	${Select} $Protocol
	${Case} "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -u $User@$Server:$Pass "$R0" -o "$CatalogPath" --silent --show-error --fail'
	${Case} "FTPS"
		StrCpy $R0 "ftps://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" --ftp-ssl -u $User@$Server:$Pass "$R0" --silent --show-error --fail -o "$CatalogPath"'
	${Case} "HTTP"
		StrCpy $R0 "http://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$CatalogPath" "$R0"'
	${Case} "HTTPS"
		StrCpy $R0 "https://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -X POST "$R0" --connect-timeout 30 --fail -H "Content-Type: application/json" --data "{\"user\":\"$User\",\"pass\":\"$Pass\"}" -o "$CatalogPath" --silent --show-error'
	${Default}
		Goto LoadLocalCatalog
	${EndSelect}
	Pop $R1
	Pop $R2
	${If} $R1 == "0"
		${If} ${FileExists} "$CatalogPath"
			Goto CatalogMap
		${Else}
			Goto LoadLocalCatalog
		${EndIf}
	${Else}
		MessageBox MB_ICONEXCLAMATION "$(TXT_MsgErrorCatalogo)"
	${EndIf}
LoadLocalCatalog:
	StrCpy $CatalogStatus "NO"
	SetOutPath "$InstDrive$INSTDIR"
	File /oname=${CATALOGFILE} "catalogo.json"
	Goto EndFetch
CatalogMap:
	StrCpy $CatalogStatus "OK"
	Call CreateMapCatalog
EndFetch:
	Pop $R2
	Pop $R1
	Pop $R0
FunctionEnd

Function CreateMapCatalog
	Push $0
	Push $1
	Push $2
	Push $3
	Push $4
	${For} $Pos 0 9
		IntOp $3 $Pos * 23
		IntOp $4 $3 + 3
		nsArray::Set GroupByPosSectionIndex /key=$Pos $4
		nsArray::Set GroupByPosSectionName /key=$Pos ""
	${Next}
	nsJSON::Set /file $CatalogPath
	nsJSON::Get /count /end
	Pop $0 ;Total
	${If} $0 > 0
		IntOp $1 $0 - 1
		${If} $1 > 9
			StrCpy $1 "9"
		${EndIf}
		${For} $Pos 0 $1
			nsJSON::Get /key /index $Pos /end
			Pop $2 ;Nombre
			IntOp $3 $Pos * 23
			IntOp $4 $3 + 3
			nsArray::Set GroupByPosSectionIndex /key=$Pos $4
			nsArray::Set GroupByPosSectionName /key=$Pos $2
		${Next}
	${EndIf}
	Pop $4
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function CheckSectionBase
	Push $0
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} $(TXT_EtiqReinstalar)"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
		SectionSetFlags ${SEC_RELEASE} 0
		SectionSetText ${SEC_RELEASE} ""
	${EndIf}
	Pop $0
FunctionEnd

Function CheckComponentInRegistry
	ReadINIStr $2 "$InstDrive$INSTDIR\componentes.ini" "Installed" "$ToolId"
	${If} $2 == ""
		Push "0" ; no instalado
	${ElseIf} $2 == $ToolVersion
		Push "2" ; misma versión
	${Else}
		${VersionCompare} "$2" "$ToolVersion" $3
		${If} $3 == 1
			Push "1" ; instalado < catálogo
		${Else}
			Push "3" ; instalado > catálogo
		${EndIf}
	${EndIf}
FunctionEnd

Function AddComponentToRegistry
	WriteINIStr "$InstDrive$INSTDIR\componentes.ini" "Installed" "$ToolId" "$ToolVersion"
	${If} $ToolFinalPath != ""
		WriteINIStr "$InstDrive$INSTDIR\componentes.ini" "Paths" "$ToolId" "$ToolFinalPath"
	${EndIf}
FunctionEnd
