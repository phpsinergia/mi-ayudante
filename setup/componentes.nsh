;--------------------------------
; DEFINICIONES HEREDADAS:
;!define MAX_COMPONENTES 20
;!define SEC_PROGRAMA 1
;!define SEC_RELEASE 4
;--------------------------------
; VARIABLES
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

;--------------------------------
; MACROS

!macro MJsonLoadComponents TIPO
	StrCpy $ComponentesTotal "0"
	nsJSON::Get /count `${TIPO}` /end
	Pop $ComponentesTotal
	nsArray::Get MapGroupsByName ${TIPO}
	Pop $GroupIndex
	${If} $ComponentesTotal > 0
	${AndIf} $GroupIndex > 0
		IntOp $Ajuste $GroupIndex + 2
		IntOp $R0 $ComponentesTotal - 1
		${For} $Pos 0 $R0
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
			IntOp $SectionIndex $Pos + $Ajuste
			nsArray::Set List${TIPO}Id /key=$SectionIndex $ToolId
			nsArray::Set List${TIPO}Name /key=$SectionIndex $ToolName
			nsArray::Set List${TIPO}Version /key=$SectionIndex $ToolVersion
			nsArray::Set List${TIPO}SizeKb /key=$SectionIndex $ToolSizeKb
			nsArray::Set List${TIPO}AddPath /key=$SectionIndex $ToolAddPath
			nsArray::Set List${TIPO}OpChk /key=$SectionIndex $ToolOpChk
			nsArray::Set List${TIPO}Hash /key=$SectionIndex $ToolHash
			nsArray::Set List${TIPO}Target /key=$SectionIndex $ToolTarget
		${Next}
		${For} $Pos $ComponentesTotal ${MAX_COMPONENTES}
			IntOp $SectionIndex $Pos + $Ajuste
			nsArray::Set List${TIPO}Id /key=$SectionIndex ""
			nsArray::Set List${TIPO}Name /key=$SectionIndex ""
			nsArray::Set List${TIPO}Version /key=$SectionIndex ""
			nsArray::Set List${TIPO}SizeKb /key=$SectionIndex ""
			nsArray::Set List${TIPO}AddPath /key=$SectionIndex ""
			nsArray::Set List${TIPO}OpChk /key=$SectionIndex ""
			nsArray::Set List${TIPO}Hash /key=$SectionIndex ""
			nsArray::Set List${TIPO}Target /key=$SectionIndex ""
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
	IntOp $Ajuste $GroupIndex + 2
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
	IntOp $Ajuste $GroupIndex + 2
	IntOp $Pos ${INDEX} - $Ajuste
	${If} $Pos < ${MAX_COMPONENTES}
		Call InstallByIndex${TIPO}
	${EndIf}
SectionEnd
!macroend

!macro MCreateSectionLog GRUPO INDEX
Section "-" ${INDEX}
	Push ${GRUPO}
	Call WriteLogSection
SectionEnd
!macroend

!macro MCheckGroupComponents TIPO
	Call JsonLoad${TIPO}
	StrCpy $ComponentesVisibles "0"
	${If} $ComponentesTotal > 0
		IntOp $R0 $ComponentesTotal - 1
		${For} $Pos 0 $R0
			${If} $Pos < ${MAX_COMPONENTES}
				Call GetInfo${TIPO}
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
				${Else}
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

!macro MInstallComponentsByIndex TIPO
	;La variable $Pos contiene el índice del componente actual en los nsArray de su TIPO (su grupo dentro del catalogo)
	;La siguiente función establece los valores de: ToolId, ToolName, ToolVersion, ToolSizeKb, ToolAddPath, ToolOpChk, ToolHash, ToolTarget y SectionIndex, y usa $Pos
	Call GetInfo${TIPO}
	${IfNot} ${SectionIsSelected} $SectionIndex
	${OrIf} $ToolId == ""
	${OrIf} $Pos >= ${MAX_COMPONENTES}
		Return
	${EndIf}
	; Función para descargar un componente
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTempDir == ""
		Return
	${EndIf}
	DetailPrint "..."
	DetailPrint "$(TXT_MsgInstalando) $ToolId"
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
		; Función para agregar la ruta del componente a la variable de entorno Path
		Call AddToEnvUserPath
	${EndIf}
	Call AddComponentToRegistry
	${If} $ToolId == "release"
		StrCpy $Version $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
	StrCpy $ToolId ""
!macroend

;--------------------------------
; FUNCIONES

Function CheckAllComponents
	Call FetchCatalog
	;TODO: Falta avanzar en hacer dinámico el siguiente conjunto de "CheckGroup" sin usar nombres de "TIPO" (Actualizaciones, Requisitos, Complementos, Extensiones, Recursos), para que puedan cambiarse de nombre o agregarse nuevos tipos.
	Call CheckGroupActualizaciones
	Call CheckGroupRequisitos
	Call CheckGroupComplementos
	Call CheckGroupExtensiones
	Call CheckGroupRecursos
	Call CheckSectionPrograma
FunctionEnd

Function FetchCatalog
	StrCpy $CatalogPath "$InstDrive$INSTDIR\${CATALOGFILE}"
	CreateDirectory "$InstDrive$INSTDIR"
	${If} ${FileExists} $CatalogPath
		Delete $CatalogPath
	${EndIf}
	${If} $Server == ""
	${OrIf} $Protocol == ""
	${OrIf} $Protocol == "---"
		Goto LoadLocalCatalog
	${Endif}
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -u $User@$Server:$Pass "$R0" -o "$CatalogPath" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/${CATALOGFILE}"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --connect-timeout 30 -C - -o "$CatalogPath" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		${If} ${FileExists} "$CatalogPath"
			Goto CatalogMap
		${Else}
			Goto LoadLocalCatalog
		${EndIf}
	${EndIf}
LoadLocalCatalog:
	SetOutPath "$InstDrive$INSTDIR"
	File /oname=${CATALOGFILE} "catalogo.json"
	${If} ${FileExists} "$CatalogPath"
		Goto CatalogMap
	${EndIf}
CatalogMap:
	Call CreateMapCatalog
FunctionEnd

Function CreateMapCatalog
	nsJSON::Set /file $CatalogPath
	nsJSON::Get /count /end
	Pop $0 ;Total
	IntOp $R1 $0 - 1
	${For} $Pos 0 $R1
		nsJSON::Get /key /index $Pos /end
		Pop $R2 ;Nombre
		IntOp $R3 $Pos * 23
		IntOp $R4 $R3 + 2
		nsArray::Set MapGroupsByName /key=$R2 $R4
	${Next}
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
