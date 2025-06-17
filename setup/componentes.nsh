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
			Call un.GetInfoComplemento
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	${For} $Pos 0 $RequisitosTotal
		${If} $Pos < ${MAX_REQUISITOS}
			Call un.GetInfoRequisito
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
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
		nsArray::Set ListComplementoId /key=$ToolIndex $ToolId
		nsArray::Set ListComplementoName /key=$ToolIndex $ToolName
		nsArray::Set ListComplementoVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListComplementoSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListComplementoAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListComplementoOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListComplementoHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ComplementosTotal ${MAX_COMPLEMENTOS}
		${If} $Pos > $ComplementosTotal
			IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListComplementoId /key=$ToolIndex ""
			nsArray::Set ListComplementoName /key=$ToolIndex ""
			nsArray::Set ListComplementoVersion /key=$ToolIndex ""
			nsArray::Set ListComplementoSizeKb /key=$ToolIndex 0
			nsArray::Set ListComplementoAddPath /key=$ToolIndex 0
			nsArray::Set ListComplementoOpChk /key=$ToolIndex 0
			nsArray::Set ListComplementoHash /key=$ToolIndex ""
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
		nsArray::Set ListRequisitoId /key=$ToolIndex $ToolId
		nsArray::Set ListRequisitoName /key=$ToolIndex $ToolName
		nsArray::Set ListRequisitoVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListRequisitoSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListRequisitoAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListRequisitoOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListRequisitoHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $RequisitosTotal ${MAX_COMPLEMENTOS}
		${If} $Pos > $RequisitosTotal
			IntOp $Ajuste ${GRP_REQUISITOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListRequisitoId /key=$ToolIndex ""
			nsArray::Set ListRequisitoName /key=$ToolIndex ""
			nsArray::Set ListRequisitoVersion /key=$ToolIndex ""
			nsArray::Set ListRequisitoSizeKb /key=$ToolIndex 0
			nsArray::Set ListRequisitoAddPath /key=$ToolIndex 0
			nsArray::Set ListRequisitoOpChk /key=$ToolIndex 0
			nsArray::Set ListRequisitoHash /key=$ToolIndex ""
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
		nsArray::Set ListActualizacionId /key=$ToolIndex $ToolId
		nsArray::Set ListActualizacionName /key=$ToolIndex $ToolName
		nsArray::Set ListActualizacionVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListActualizacionSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListActualizacionAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListActualizacionOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListActualizacionHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ActualizacionesTotal ${MAX_ACTUALIZACIONES}
		${If} $Pos > $ActualizacionesTotal
			IntOp $ToolIndex $Pos + ${SEC_LANZAMIENTO}
			nsArray::Set ListActualizacionId /key=$ToolIndex ""
			nsArray::Set ListActualizacionName /key=$ToolIndex ""
			nsArray::Set ListActualizacionVersion /key=$ToolIndex ""
			nsArray::Set ListActualizacionSizeKb /key=$ToolIndex 0
			nsArray::Set ListActualizacionAddPath /key=$ToolIndex 0
			nsArray::Set ListActualizacionOpChk /key=$ToolIndex 0
			nsArray::Set ListActualizacionHash /key=$ToolIndex ""
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
		nsArray::Set ListExtensionId /key=$ToolIndex $ToolId
		nsArray::Set ListExtensionName /key=$ToolIndex $ToolName
		nsArray::Set ListExtensionVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListExtensionSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListExtensionAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListExtensionOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListExtensionHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $ExtensionesTotal ${MAX_EXTENSIONES}
		${If} $Pos > $ExtensionesTotal
			IntOp $Ajuste ${GRP_EXTENSIONES} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListExtensionId /key=$ToolIndex ""
			nsArray::Set ListExtensionName /key=$ToolIndex ""
			nsArray::Set ListExtensionVersion /key=$ToolIndex ""
			nsArray::Set ListExtensionSizeKb /key=$ToolIndex 0
			nsArray::Set ListExtensionAddPath /key=$ToolIndex 0
			nsArray::Set ListExtensionOpChk /key=$ToolIndex 0
			nsArray::Set ListExtensionHash /key=$ToolIndex ""
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
		nsArray::Set ListRecursoId /key=$ToolIndex $ToolId
		nsArray::Set ListRecursoName /key=$ToolIndex $ToolName
		nsArray::Set ListRecursoVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListRecursoSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListRecursoAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListRecursoOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListRecursoHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $Pos $RecursosTotal ${MAX_RECURSOS}
		${If} $Pos > $RecursosTotal
			IntOp $Ajuste ${GRP_RECURSOS} + 1
			IntOp $ToolIndex $Pos + $Ajuste
			nsArray::Set ListRecursoId /key=$ToolIndex ""
			nsArray::Set ListRecursoName /key=$ToolIndex ""
			nsArray::Set ListRecursoVersion /key=$ToolIndex ""
			nsArray::Set ListRecursoSizeKb /key=$ToolIndex 0
			nsArray::Set ListRecursoAddPath /key=$ToolIndex 0
			nsArray::Set ListRecursoOpChk /key=$ToolIndex 0
			nsArray::Set ListRecursoHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

;--------------------------------
;MGetInfo... (5)

!macro MGetInfoActualizacion
	nsArray::Get ListActualizacionId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListActualizacionName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListActualizacionVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListActualizacionSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListActualizacionAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListActualizacionOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListActualizacionHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $ToolIndex $Pos + ${SEC_LANZAMIENTO}
!macroend

!macro MGetInfoRequisito
	nsArray::Get ListRequisitoId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListRequisitoName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListRequisitoVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListRequisitoSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListRequisitoAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListRequisitoOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListRequisitoHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_REQUISITOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoComplemento
	nsArray::Get ListComplementoId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListComplementoName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListComplementoVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListComplementoSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListComplementoAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListComplementoOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListComplementoHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoExtension
	nsArray::Get ListExtensionId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListExtensionName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListExtensionVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListExtensionSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListExtensionAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListExtensionOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListExtensionHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_EXTENSIONES} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

!macro MGetInfoRecurso
	nsArray::Get ListRecursoId /at=$Pos
	Pop $1
	Pop $ToolId
	nsArray::Get ListRecursoName /at=$Pos
	Pop $1
	Pop $ToolName
	nsArray::Get ListRecursoVersion /at=$Pos
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListRecursoSizeKb /at=$Pos
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListRecursoAddPath /at=$Pos
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListRecursoOpChk /at=$Pos
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListRecursoHash /at=$Pos
	Pop $1
	Pop $ToolHash
	IntOp $Ajuste ${GRP_RECURSOS} + 1
	IntOp $ToolIndex $Pos + $Ajuste
!macroend

;--------------------------------
;SECTION_... (5)

!macro CreateSectionActualizacion index
Section /o "" ${index}
	IntOp $Pos ${index} - ${SEC_LANZAMIENTO}
	${If} $Pos < ${MAX_ACTUALIZACIONES}
		Call InstallByIndexActualizacion
	${EndIf}
SectionEnd
!macroend

!macro CreateSectionRequisito index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_REQUISITOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_REQUISITOS}
		Call InstallByIndexRequisito
	${EndIf}
SectionEnd
!macroend

!macro CreateSectionComplemento index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_COMPLEMENTOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_COMPLEMENTOS}
		Call InstallByIndexComplemento
	${EndIf}
SectionEnd
!macroend

!macro CreateSectionExtension index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_EXTENSIONES} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_EXTENSIONES}
		Call InstallByIndexExtension
	${EndIf}
SectionEnd
!macroend

!macro CreateSectionRecurso index
Section /o "" ${index}
	IntOp $Ajuste ${GRP_RECURSOS} + 1
	IntOp $Pos ${index} - $Ajuste
	${If} $Pos < ${MAX_RECURSOS}
		Call InstallByIndexRecurso
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

Function GetInfoComplemento
	!insertmacro MGetInfoComplemento
FunctionEnd

Function GetInfoRequisito
	!insertmacro MGetInfoRequisito
FunctionEnd

Function GetInfoActualizacion
	!insertmacro MGetInfoActualizacion
FunctionEnd

Function GetInfoExtension
	!insertmacro MGetInfoExtension
FunctionEnd

Function GetInfoRecurso
	!insertmacro MGetInfoRecurso
FunctionEnd

;--------------------------------
;InstallByIndex... (5)

Function InstallByIndexComplemento
	${If} $Pos >= ${MAX_COMPLEMENTOS}
	${OrIf} $Pos > $ComplementosTotal
		Return
	${EndIf}
	Call GetInfoComplemento
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Complemento
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Complemento:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexRequisito
	${If} $Pos >= ${MAX_REQUISITOS}
	${OrIf} $Pos > $RequisitosTotal
		Return
	${EndIf}
	Call GetInfoRequisito
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Requisito
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	${If} $ToolId == "vendor"
		DetailPrint "============================================"
		DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolName v$ToolVersion"
		RMDir /r "$INSTDRIVE${VENDOR}"
		Rename "$INSTDRIVE${TOOLS}\$ToolId" "$INSTDRIVE${VENDOR}"
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		SetOutPath "$INSTDRIVE${TOOLS}\$ToolId"
		File "meta.json"
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Requisito:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexActualizacion
	${If} $Pos >= ${MAX_ACTUALIZACIONES}
	${OrIf} $Pos > $ActualizacionesTotal
		Return
	${EndIf}
	Call GetInfoActualizacion
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	${If} $ToolId == "release"
		${If} $ToolVersion == $VERSION
			Return
		${EndIf}
		MessageBox MB_YESNO|MB_ICONQUESTION "${TXT_MsgConfirmaActualizacion}$\n$\n${TXT_MsgActual}: $VERSION$\n${TXT_MsgNueva}: $ToolVersion" IDNO EndActualizacion
	${EndIf}
	DetailPrint "${TXT_LogDescargandoActualizacion} $ToolName v$ToolVersion"
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		DetailPrint "${TXT_MsgErrorActualizacion}"
		Goto Tag_FIN_Actualizacion
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_LogInstalandoActualizacion} $ToolVersion"
	CopyFiles /SILENT "$ToolTemp\*.*" "$INSTDRIVE$INSTDIR\"
	${If} $ToolId == "release"
		StrCpy $VERSION $ToolVersion
		WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$VERSION"
		WriteINIStr $INSTDRIVE$INSTDIR\config.ini Base Lanzamiento $VERSION
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Actualizacion:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
	Return
EndActualizacion:
	DetailPrint "${TXT_MsgActualizacionCancelada}"
FunctionEnd

Function InstallByIndexExtension
	${If} $Pos >= ${MAX_EXTENSIONES}
	${OrIf} $Pos > $ExtensionesTotal
		Return
	${EndIf}
	Call GetInfoExtension
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Extension
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Extension:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexRecurso
	${If} $Pos >= ${MAX_RECURSOS}
	${OrIf} $Pos > $RecursosTotal
		Return
	${EndIf}
	Call GetInfoRecurso
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Recurso
	${EndIf}
	DetailPrint "..."
	DetailPrint "${TXT_MsgInstalandoHerramienta} $ToolId"
	StrCpy $R8 $ToolTemp 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
	${If} "$R8" == "$R9"
		Rename "$ToolTemp" "$INSTDRIVE${TOOLS}\$ToolId"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\$ToolId"
		CopyFiles /SILENT "$ToolTemp\*.*" "$INSTDRIVE${TOOLS}\$ToolId\"
	${EndIf}
	${If} $ToolAddPath == "1"
		Push "$INSTDRIVE${TOOLS}\$ToolId"
		Call AddToEnvUserPath
	${EndIf}
	DetailPrint "$ToolName ($ToolId) → OK ($ToolVersion)"
Tag_FIN_Recurso:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

;--------------------------------
; Funciones generales

Function CheckAllComponents
	Call FetchToolsCatalog
	Call CheckPrograma
	Call CheckGrpActualizaciones
	Call CheckGrpRequisitos
	Call CheckGrpComplementos
	Call CheckGrpExtensiones
	Call CheckGrpRecursos
FunctionEnd

Function FetchToolsCatalog
	StrCpy $ToolsCatalog "$INSTDRIVE$INSTDIR\catalogo.json"
	${If} ${FileExists} $ToolsCatalog
		Delete $ToolsCatalog
	${EndIf}
	${If} $SERVER == ""
	${OrIf} $PROTOCOL == ""
	${OrIf} $PROTOCOL == "---"
		Goto LoadLocalTools
	${Endif}
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/catalogo.json"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$ToolsCatalog" --silent --show-error --fail'
		Pop $R1
		Pop $R2
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/catalogo.json"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$ToolsCatalog" "$R0"'
		Pop $R1
		Pop $R2
	${EndIf}
	${If} $R1 == "0"
		Goto ExitFetchTools
	${EndIf}
LoadLocalTools:
	SetOutPath "$INSTDRIVE$INSTDIR"
	File "catalogo.json"
ExitFetchTools:
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
			Call GetInfoActualizacion
			${If} $IsUpdateInstall == "1"
				SectionSetText $ToolIndex "$ToolName $ToolVersion"
				SectionSetSize $ToolIndex $ToolSizeKb
				${If} $ToolId == "release"
					${If} $ToolVersion == $VERSION
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
			Call GetInfoRequisito
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
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
			Call GetInfoComplemento
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
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
			Call GetInfoExtension
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
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
			Call GetInfoRecurso
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
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

Function DownloadSingleTool
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
		Goto SkipTool
	${EndIf}
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/$ToolId.zip"
		DetailPrint "============================================"
		DetailPrint "${TXT_MsgDescargando} $R0"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\$ToolId.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			StrCpy $LogMsg "${TXT_MsgErrorDescargaFtp} $ToolId$\n$R2"
			DetailPrint "$LogMsg"
			MessageBox MB_ICONEXCLAMATION "$LogMsg"
			Goto SkipTool
		${EndIf}
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/$ToolId.zip"
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
			Goto ValidateOk
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
ValidateOk:

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
	IntCmp $R0 1 0 0 SizeMismatch
	Goto SuccessTool
SizeMismatch:
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

Function un.GetInfoComplemento
	!insertmacro MGetInfoComplemento
FunctionEnd

Function un.GetInfoRequisito
	!insertmacro MGetInfoRequisito
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
