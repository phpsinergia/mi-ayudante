!define MAX_ACTUALIZACIONES 10
!define MAX_REQUISITOS 10
!define MAX_COMPLEMENTOS 30
!define MAX_EXTENSIONES 20
!define MAX_RECURSOS 30
!define SEC_PROGRAMA 2
!define SEC_LANZAMIENTO 3
!define GRP_REQUISITOS 15
!define GRP_COMPLEMENTOS 28
!define GRP_EXTENSIONES 61
!define GRP_RECURSOS 84

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
Var ActualizacionesTotal
Var ComplementosTotal
Var RequisitosTotal
Var ExtensionesTotal
Var RecursosTotal
Var ComplementosVisibles
Var RequisitosVisibles
Var ExtensionesVisibles
Var RecursosVisibles
Var LogMsg

;--------------------------------
; MACROS

;--------------------------------
!macro MUninstallTools
	Call un.JsonLoadComplementos
	Call un.JsonLoadRequisitos
	${For} $Pos 0 $ComplementosTotal
		${If} $Pos < ${MAX_COMPLEMENTOS}
			Call un.GetInfoComplementos
			RMDir /r "$InstDrive${TOOLS}\$ToolId"
			Push "$InstDrive${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	${For} $Pos 0 $RequisitosTotal
		${If} $Pos < ${MAX_REQUISITOS}
			Call un.GetInfoRequisitos
			RMDir /r "$InstDrive${TOOLS}\$ToolId"
			Push "$InstDrive${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
!macroend

;--------------------------------
;MJsonLoad... (5)

!macro MJsonLoadComplementos
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `complementos` /end
	Pop $ComplementosTotal
	IntOp $ComplementosTotal $ComplementosTotal - 1
	${For} $Pos 0 $ComplementosTotal
		nsJSON::Get `complementos` /index $Pos "id" /end 
		Pop $ToolId
		nsJSON::Get `complementos` /index $Pos "name" /end
		Pop $ToolName
		nsJSON::Get `complementos` /index $Pos "version" /end
		Pop $ToolVersion
		nsJSON::Get `complementos` /index $Pos "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `complementos` /index $Pos "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `complementos` /index $Pos "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `complementos` /index $Pos "hash" /end
		Pop $ToolHash
		IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
		IntOp $ToolIndex $Pos + $Ajuste
		nsArray::Set ListComplementosId /key=$ToolIndex $ToolId
		nsArray::Set ListComplementosName /key=$ToolIndex $ToolName
		nsArray::Set ListComplementosVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListComplementosSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListComplementosAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListComplementosOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListComplementosHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ComplementosTotal ${MAX_COMPLEMENTOS}
		${If} $Pos > $ComplementosTotal
			IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListComplementosId /key=$ToolIndex ""
			nsArray::Set ListComplementosName /key=$ToolIndex ""
			nsArray::Set ListComplementosVersion /key=$ToolIndex ""
			nsArray::Set ListComplementosSizeKb /key=$ToolIndex 0
			nsArray::Set ListComplementosAddPath /key=$ToolIndex 0
			nsArray::Set ListComplementosOpChk /key=$ToolIndex 0
			nsArray::Set ListComplementosHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadRequisitos
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `requisitos` /end
	Pop $RequisitosTotal
	IntOp $RequisitosTotal $RequisitosTotal - 1
	${For} $Pos 0 $RequisitosTotal
		nsJSON::Get `requisitos` /index $Pos "id" /end 
		Pop $ToolId
		nsJSON::Get `requisitos` /index $Pos "name" /end
		Pop $ToolName
		nsJSON::Get `requisitos` /index $Pos "version" /end
		Pop $ToolVersion
		nsJSON::Get `requisitos` /index $Pos "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `requisitos` /index $Pos "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `requisitos` /index $Pos "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `requisitos` /index $Pos "hash" /end
		Pop $ToolHash
		IntOp $Ajuste ${GRP_REQUISITOS} + 1
		IntOp $ToolIndex $Pos + $Ajuste
		nsArray::Set ListRequisitosId /key=$ToolIndex $ToolId
		nsArray::Set ListRequisitosName /key=$ToolIndex $ToolName
		nsArray::Set ListRequisitosVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListRequisitosSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListRequisitosAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListRequisitosOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListRequisitosHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $RequisitosTotal ${MAX_COMPLEMENTOS}
		${If} $Pos > $RequisitosTotal
			IntOp $Ajuste ${GRP_REQUISITOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListRequisitosId /key=$ToolIndex ""
			nsArray::Set ListRequisitosName /key=$ToolIndex ""
			nsArray::Set ListRequisitosVersion /key=$ToolIndex ""
			nsArray::Set ListRequisitosSizeKb /key=$ToolIndex 0
			nsArray::Set ListRequisitosAddPath /key=$ToolIndex 0
			nsArray::Set ListRequisitosOpChk /key=$ToolIndex 0
			nsArray::Set ListRequisitosHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadActualizaciones
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `actualizaciones` /end
	Pop $ActualizacionesTotal
	IntOp $ActualizacionesTotal $ActualizacionesTotal - 1
	${For} $Pos 0 $ActualizacionesTotal
		nsJSON::Get `actualizaciones` /index $Pos "id" /end 
		Pop $ToolId
		nsJSON::Get `actualizaciones` /index $Pos "name" /end
		Pop $ToolName
		nsJSON::Get `actualizaciones` /index $Pos "version" /end
		Pop $ToolVersion
		nsJSON::Get `actualizaciones` /index $Pos "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `actualizaciones` /index $Pos "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `actualizaciones` /index $Pos "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `actualizaciones` /index $Pos "hash" /end
		Pop $ToolHash
		IntOp $ToolIndex $Pos + ${SEC_LANZAMIENTO}
		nsArray::Set ListActualizacionesId /key=$ToolIndex $ToolId
		nsArray::Set ListActualizacionesName /key=$ToolIndex $ToolName
		nsArray::Set ListActualizacionesVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListActualizacionesSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListActualizacionesAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListActualizacionesOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListActualizacionesHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ActualizacionesTotal ${MAX_ACTUALIZACIONES}
		${If} $Pos > $ActualizacionesTotal
			IntOp $ToolIndex $Pos + ${SEC_LANZAMIENTO}
			nsArray::Set ListActualizacionesId /key=$ToolIndex ""
			nsArray::Set ListActualizacionesName /key=$ToolIndex ""
			nsArray::Set ListActualizacionesVersion /key=$ToolIndex ""
			nsArray::Set ListActualizacionesSizeKb /key=$ToolIndex 0
			nsArray::Set ListActualizacionesAddPath /key=$ToolIndex 0
			nsArray::Set ListActualizacionesOpChk /key=$ToolIndex 0
			nsArray::Set ListActualizacionesHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadExtensiones
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `extensiones` /end
	Pop $ExtensionesTotal
	IntOp $ExtensionesTotal $ExtensionesTotal - 1
	${For} $Pos 0 $ExtensionesTotal
		nsJSON::Get `extensiones` /index $Pos "id" /end 
		Pop $ToolId
		nsJSON::Get `extensiones` /index $Pos "name" /end
		Pop $ToolName
		nsJSON::Get `extensiones` /index $Pos "version" /end
		Pop $ToolVersion
		nsJSON::Get `extensiones` /index $Pos "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `extensiones` /index $Pos "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `extensiones` /index $Pos "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `extensiones` /index $Pos "hash" /end
		Pop $ToolHash
		IntOp $Ajuste ${GRP_EXTENSIONES} + 1
		IntOp $ToolIndex $Pos + $Ajuste
		nsArray::Set ListExtensionesId /key=$ToolIndex $ToolId
		nsArray::Set ListExtensionesName /key=$ToolIndex $ToolName
		nsArray::Set ListExtensionesVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListExtensionesSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListExtensionesAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListExtensionesOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListExtensionesHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ExtensionesTotal ${MAX_EXTENSIONES}
		${If} $Pos > $ExtensionesTotal
			IntOp $Ajuste ${GRP_EXTENSIONES} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListExtensionesId /key=$ToolIndex ""
			nsArray::Set ListExtensionesName /key=$ToolIndex ""
			nsArray::Set ListExtensionesVersion /key=$ToolIndex ""
			nsArray::Set ListExtensionesSizeKb /key=$ToolIndex 0
			nsArray::Set ListExtensionesAddPath /key=$ToolIndex 0
			nsArray::Set ListExtensionesOpChk /key=$ToolIndex 0
			nsArray::Set ListExtensionesHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadRecursos
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `recursos` /end
	Pop $RecursosTotal
	IntOp $RecursosTotal $RecursosTotal - 1
	${For} $Pos 0 $RecursosTotal
		nsJSON::Get `recursos` /index $Pos "id" /end 
		Pop $ToolId
		nsJSON::Get `recursos` /index $Pos "name" /end
		Pop $ToolName
		nsJSON::Get `recursos` /index $Pos "version" /end
		Pop $ToolVersion
		nsJSON::Get `recursos` /index $Pos "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `recursos` /index $Pos "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `recursos` /index $Pos "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `recursos` /index $Pos "hash" /end
		Pop $ToolHash
		IntOp $Ajuste ${GRP_RECURSOS} + 1
		IntOp $ToolIndex $Pos + $Ajuste
		nsArray::Set ListRecursosId /key=$ToolIndex $ToolId
		nsArray::Set ListRecursosName /key=$ToolIndex $ToolName
		nsArray::Set ListRecursosVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListRecursosSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListRecursosAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListRecursosOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListRecursosHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $RecursosTotal ${MAX_RECURSOS}
		${If} $Pos > $RecursosTotal
			IntOp $Ajuste ${GRP_RECURSOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListRecursosId /key=$ToolIndex ""
			nsArray::Set ListRecursosName /key=$ToolIndex ""
			nsArray::Set ListRecursosVersion /key=$ToolIndex ""
			nsArray::Set ListRecursosSizeKb /key=$ToolIndex 0
			nsArray::Set ListRecursosAddPath /key=$ToolIndex 0
			nsArray::Set ListRecursosOpChk /key=$ToolIndex 0
			nsArray::Set ListRecursosHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

;--------------------------------
;MGetInfo... (5)

!macro MGetInfoActualizaciones
	nsArray::Get ListActualizacionesId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListActualizacionesName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListActualizacionesVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListActualizacionesSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListActualizacionesAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListActualizacionesOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListActualizacionesHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $ToolIndex $Pos + ${SEC_LANZAMIENTO}
!macroend

!macro MGetInfoRequisitos
	nsArray::Get ListRequisitosId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListRequisitosName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListRequisitosVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListRequisitosSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListRequisitosAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListRequisitosOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListRequisitosHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_REQUISITOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoComplementos
	nsArray::Get ListComplementosId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListComplementosName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListComplementosVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListComplementosSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListComplementosAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListComplementosOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListComplementosHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoExtensiones
	nsArray::Get ListExtensionesId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListExtensionesName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListExtensionesVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListExtensionesSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListExtensionesAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListExtensionesOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListExtensionesHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_EXTENSIONES} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoRecursos
	nsArray::Get ListRecursosId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListRecursosName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListRecursosVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListRecursosSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListRecursosAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListRecursosOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListRecursosHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_RECURSOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

;--------------------------------
;MCreateSection... (5)

!macro MCreateSectionActualizaciones index
Section /o "" ${index}
	IntOp $Pos ${index} - ${SEC_LANZAMIENTO}
	${If} $Pos < ${MAX_ACTUALIZACIONES}
		Call InstallByIndexActualizaciones
	${EndIf}
SectionEnd
!macroend

!macro MCreateSectionRequisitos index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_REQUISITOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_REQUISITOS}
		Call InstallByIndexRequisitos
	${EndIf}
SectionEnd
!macroend

!macro MCreateSectionComplementos index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_COMPLEMENTOS}
		Call InstallByIndexComplementos
	${EndIf}
SectionEnd
!macroend

!macro MCreateSectionExtensiones index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_EXTENSIONES} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_EXTENSIONES}
		Call InstallByIndexExtensiones
	${EndIf}
SectionEnd
!macroend

!macro MCreateSectionRecursos index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_RECURSOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_RECURSOS}
		Call InstallByIndexRecursos
	${EndIf}
SectionEnd
!macroend

;--------------------------------
; FUNCIONES INSTALACION

;--------------------------------
;JsonLoad... (5)

Function JsonLoadComplementos
	!insertmacro MJsonLoadComplementos
FunctionEnd

Function JsonLoadRequisitos
	!insertmacro MJsonLoadRequisitos
FunctionEnd

Function JsonLoadActualizaciones
	!insertmacro MJsonLoadActualizaciones
FunctionEnd

Function JsonLoadExtensiones
	!insertmacro MJsonLoadExtensiones
FunctionEnd

Function JsonLoadRecursos
	!insertmacro MJsonLoadRecursos
FunctionEnd

;--------------------------------
;GetInfo... (5)

Function GetInfoComplementos
	!insertmacro MGetInfoComplementos
FunctionEnd

Function GetInfoRequisitos
	!insertmacro MGetInfoRequisitos
FunctionEnd

Function GetInfoActualizaciones
	!insertmacro MGetInfoActualizaciones
FunctionEnd

Function GetInfoExtensiones
	!insertmacro MGetInfoExtensiones
FunctionEnd

Function GetInfoRecursos
	!insertmacro MGetInfoRecursos
FunctionEnd

;--------------------------------
;InstallByIndex... (5)

Function InstallByIndexComplementos
	${If} $Pos >= ${MAX_COMPLEMENTOS}
	${OrIf} $Pos > $ComplementosTotal
		Return
	${EndIf}
	Call GetInfoComplementos
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Complementos
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
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
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Complementos:
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexRequisitos
	${If} $Pos >= ${MAX_REQUISITOS}
	${OrIf} $Pos > $RequisitosTotal
		Return
	${EndIf}
	Call GetInfoRequisitos
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Requisitos
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
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
	${If} $ToolId == "vendor"
		DetailPrint "============================================"
		DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolName v$ToolVersion"
		RMDir /r "$InstDrive${VENDOR}"
		Rename "$InstDrive${TOOLS}\$ToolId" "$InstDrive${VENDOR}"
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		SetOutPath "$InstDrive${TOOLS}\$ToolId"
		File "meta.json"
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Requisitos:
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexActualizaciones
	${If} $Pos >= ${MAX_ACTUALIZACIONES}
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
		MessageBox MB_YESNO|MB_ICONQUESTION "${TXT_MsgConfirmaActualizacion}$\n$\n${TXT_MsgActual}: $Version$\n${TXT_MsgNueva}: $ToolVersion" IDNO EndActualizaciones
	${EndIf}
	DetailPrint "${TXT_LogDescargandoActualizacion} $ToolName v$ToolVersion"
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		DetailPrint "${TXT_MsgErrorActualizacion}"
		Goto Tag_FIN_Actualizaciones
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_LogInstalandoActualizacion} $ToolVersion"
	CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive$INSTDIR\"
	${If} $ToolId == "release"
		StrCpy $Version $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Actualizaciones:
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
	Return
EndActualizaciones:
	DetailPrint "${TXT_MsgActualizacionCancelada}"
FunctionEnd

Function InstallByIndexExtensiones
	${If} $Pos >= ${MAX_EXTENSIONES}
	${OrIf} $Pos > $ExtensionesTotal
		Return
	${EndIf}
	Call GetInfoExtensiones
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Extensiones
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoExtension} $ToolId"
	CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive$INSTDIR\"
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Extensiones:
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexRecursos
	${If} $Pos >= ${MAX_RECURSOS}
	${OrIf} $Pos > $RecursosTotal
		Return
	${EndIf}
	Call GetInfoRecursos
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSinglePack
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Recursos
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoRecurso} $ToolId"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $InstDrive 2
	RMDir /r "$InstDrive${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$InstDrive${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$InstDrive${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$InstDrive${TOOLS}\$ToolId\"
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Recursos:
	DetailPrint "..."
	SetOutPath "$InstDrive$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

;--------------------------------
; Funciones generales

Function FetchCatalog
	StrCpy $ToolsCatalog "$InstDrive$INSTDIR\catalogo.json"
	${If} ${FileExists} $ToolsCatalog
		Delete $ToolsCatalog
	${EndIf}
	${If} $Server == ""
	${OrIf} $Protocol == ""
	${OrIf} $Protocol == "---"
		Goto LoadLocalTools
	${Endif}
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/catalogo.json"
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$ToolsCatalog" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/catalogo.json"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$ToolsCatalog" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		Goto ExitFetchTools
	${EndIf}
LoadLocalTools:
	SetOutPath "$InstDrive$INSTDIR"
	File "catalogo.json"
ExitFetchTools:
FunctionEnd

Function CheckAllComponents
	Call FetchCatalog
	Call CheckPrograma
	Call CheckGrpActualizaciones
	Call CheckGrpRequisitos
	Call CheckGrpComplementos
	Call CheckGrpExtensiones
	Call CheckGrpRecursos
FunctionEnd

Function CheckPrograma
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SEC_PROGRAMA} 0
		SectionSetText ${SEC_PROGRAMA} "${NAME} ${TXT_EtiqReinstalar}"
	${Else}
		IntOp $0 ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SEC_PROGRAMA} $0
	${EndIf}
FunctionEnd

Function CheckGrpActualizaciones
	Call JsonLoadActualizaciones
	${For} $Pos 0 $ActualizacionesTotal
		${If} $Pos < ${MAX_ACTUALIZACIONES}
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

Function CheckGrpRequisitos
	StrCpy $RequisitosVisibles "0"
	Call JsonLoadRequisitos
	${For} $Pos 0 $RequisitosTotal
		${If} $Pos < ${MAX_REQUISITOS}
			Call GetInfoRequisitos
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				IntOp $RequisitosVisibles $RequisitosVisibles + 1
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
	${If} $RequisitosVisibles == "0"
		SectionSetText ${GRP_REQUISITOS} ""
	${EndIf}
FunctionEnd

Function CheckGrpComplementos
	StrCpy $ComplementosVisibles "0"
	Call JsonLoadComplementos
	${For} $Pos 0 $ComplementosTotal
		${If} $Pos < ${MAX_COMPLEMENTOS}
			Call GetInfoComplementos
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				IntOp $ComplementosVisibles $ComplementosVisibles + 1
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
	${If} $ComplementosVisibles == "0"
		SectionSetText ${GRP_COMPLEMENTOS} ""
	${EndIf}
FunctionEnd

Function CheckGrpExtensiones
	StrCpy $ExtensionesVisibles "0"
	Call JsonLoadExtensiones
	${For} $Pos 0 $ExtensionesTotal
		${If} $Pos < ${MAX_EXTENSIONES}
			Call GetInfoExtensiones
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				IntOp $ExtensionesVisibles $ExtensionesVisibles + 1
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
	${If} $ExtensionesVisibles == "0"
		SectionSetText ${GRP_EXTENSIONES} ""
	${EndIf}
FunctionEnd

Function CheckGrpRecursos
	StrCpy $RecursosVisibles "0"
	Call JsonLoadRecursos
	${For} $Pos 0 $RecursosTotal
		${If} $Pos < ${MAX_RECURSOS}
			Call GetInfoRecursos
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				IntOp $RecursosVisibles $RecursosVisibles + 1
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
	${If} $RecursosVisibles == "0"
		SectionSetText ${GRP_RECURSOS} ""
	${EndIf}
FunctionEnd

Function DownloadSinglePack
	${If} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\bin\*.exe"
	${OrIf} ${FileExists} "$InstDrive${TOOLS}\$ToolId\*.json"
		Goto SkipTool
	${EndIf}

; descarga
;DownloadTool:
	${If} $Protocol == "FTP"
		StrCpy $R0 "ftp://$Server/herramientas/$ToolId.zip"
		DetailPrint "============================================"
		DetailPrint "${TXT_MsgDescargando} $R0"
		nsExec::ExecToStack '"curl.exe" -u $FtpUser@$Server:$FtpPass "$R0" -o "$TEMP\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "${TXT_MsgErrorDescargaFtp} $ToolId$\n$R2"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipTool
		${EndIf}
	${ElseIf} $Protocol == "HTTP"
		StrCpy $R0 "https://$Server/herramientas/$ToolId.zip"
		DetailPrint "============================================"
		DetailPrint "${TXT_MsgDescargando} $R0"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$TEMP\$ToolId.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "${TXT_MsgErrorDescargaHttp} $ToolId$\n${TXT_CodigoRespuesta} $R1"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipTool
		${EndIf}
	${Else}
		Goto SkipTool
	${EndIf}

; verificación
;ValidateTool:
	!insertmacro WordFind
	DetailPrint "${TXT_MsgVerificando} $ToolName ($ToolId.zip)"
	nsExec::ExecToStack 'CertUtil -hashfile "$TEMP\$ToolId.zip" SHA256'
	Pop $0
	Pop $1
	StrCmp $0 0 +5
		StrCpy $LogMsg "${TXT_MsgErrorHashNoCalculado} $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${If} $1 != ""
	${AndIf} $ToolHash != ""
		${WordFind} "$1" "$ToolHash" "+1" $2
		${If} $2 != ""
			DetailPrint "${TXT_MsgHashValidado} $ToolHash"
			Goto ExtractTool
		${Else}
			StrCpy $LogMsg "${TXT_MsgErrorHashNoCoincide} $ToolId.zip$\n$2 ≠ $ToolHash"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONSTOP "$LogMsg"
			Goto SkipTool
		${EndIf}
	${Else}
		StrCpy $LogMsg "${TXT_MsgErrorHashNoCalculado} $ToolId.zip"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${EndIf}

; descompresión
ExtractTool:
	DetailPrint "..."
	StrCpy $ToolTemp "$TEMP\$ToolId_tmp"
	RMDir /r "$ToolTemp"
	CreateDirectory "$ToolTemp"
	SetOutPath "$ToolTemp"
	Nsisunz::UnzipToLog "$TEMP\$ToolId.zip" "$ToolTemp"
	Pop $R1
	${If} $R1 != "success"
		StrCpy $LogMsg "${TXT_MsgErrorDescomprimir} $ToolName: $R1"
		DetailPrint "$LogMsg"
		MessageBox MB_ICONSTOP "$LogMsg"
		Goto SkipTool
	${EndIf}
	${GetSize} "$ToolTemp" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - $ToolSizeKb
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 +2
		Goto SuccessTool
	StrCpy $LogMsg "${TXT_MsgErrorTamano} $ToolName ($R4 KB ≠ $ToolSizeKb KB)"
	DetailPrint "$LogMsg"
	MessageBox MB_ICONEXCLAMATION "$LogMsg"
	Goto SkipTool

SuccessTool:
	Push "OK"
	Return
SkipTool:
	Push "NO"
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
	DetailPrint "${TXT_LogAddPath} $0"
	WriteRegExpandStr HKCU "Environment" "Path" "$1"
	System::Call 'Kernel32::SendMessageTimeout(i 0xffff,i ${WM_SETTINGCHANGE},i 0,t "Environment",i 0,i 1000,*i .r0)'
EndAdd:
	Pop $3
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

;--------------------------------
; FUNCIONES DESINSTALACION

Function un.JsonLoadComplementos
	!insertmacro MJsonLoadComplementos
FunctionEnd

Function un.JsonLoadRequisitos
	!insertmacro MJsonLoadRequisitos
FunctionEnd

Function un.GetInfoComplementos
	!insertmacro MGetInfoComplementos
FunctionEnd

Function un.GetInfoRequisitos
	!insertmacro MGetInfoRequisitos
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
