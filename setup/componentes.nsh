!define MAX_ACTUALIZACIONES 10
!define MAX_REQUISITOS 10
!define MAX_COMPLEMENTOS 30
!define MAX_EXTENSIONES 20
!define MAX_RECURSOS 30

!define SecPrograma 2
!define SecLanzamiento 3
!define GrpRequisitos 15
!define GrpComplementos 28
!define GrpExtensiones 61
!define GrpRecursos 84

Var LogMsg
Var n
Var i
Var ToolId
Var ToolName
Var ToolVersion
Var ToolSizeKb
Var ToolAddPath
Var ToolOpChk
Var ToolHash
Var ToolIndex
Var ToolTemp
Var ActsTotal
Var CompsTotal
Var ReqsTotal
Var ExtsTotal
Var RecsTotal
Var CompsVisibles
Var ReqsVisibles
Var ExtsVisibles
Var RecsVisibles
Var Aux

;--------------------------------
; MACROS

;--------------------------------
;MJsonLoad... (5)

!macro MJsonLoadComps
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `complementos` /end
	Pop $CompsTotal
	IntOp $CompsTotal $CompsTotal - 1
	${For} $i 0 $CompsTotal
		nsJSON::Get `complementos` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `complementos` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `complementos` /index $i "version" /end
		Pop $ToolVersion
		nsJSON::Get `complementos` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `complementos` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `complementos` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `complementos` /index $i "hash" /end
		Pop $ToolHash
		IntOp $n ${GrpComplementos} + 1
		IntOp $ToolIndex $i + $n
		nsArray::Set ListCompId /key=$ToolIndex $ToolId
		nsArray::Set ListCompName /key=$ToolIndex $ToolName
		nsArray::Set ListCompVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListCompSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListCompAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListCompOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListCompHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $CompsTotal ${MAX_COMPLEMENTOS}
		${If} $i > $CompsTotal
			IntOp $n ${GrpComplementos} + 1
			IntOp $ToolIndex $i + $n
			nsArray::Set ListCompId /key=$ToolIndex ""
			nsArray::Set ListCompName /key=$ToolIndex ""
			nsArray::Set ListCompVersion /key=$ToolIndex ""
			nsArray::Set ListCompSizeKb /key=$ToolIndex 0
			nsArray::Set ListCompAddPath /key=$ToolIndex 0
			nsArray::Set ListCompOpChk /key=$ToolIndex 0
			nsArray::Set ListCompHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadReqs
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `requisitos` /end
	Pop $ReqsTotal
	IntOp $ReqsTotal $ReqsTotal - 1
	${For} $i 0 $ReqsTotal
		nsJSON::Get `requisitos` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `requisitos` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `requisitos` /index $i "version" /end
		Pop $ToolVersion
		nsJSON::Get `requisitos` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `requisitos` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `requisitos` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `requisitos` /index $i "hash" /end
		Pop $ToolHash
		IntOp $n ${GrpRequisitos} + 1
		IntOp $ToolIndex $i + $n
		nsArray::Set ListReqId /key=$ToolIndex $ToolId
		nsArray::Set ListReqName /key=$ToolIndex $ToolName
		nsArray::Set ListReqVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListReqSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListReqAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListReqOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListReqHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $ReqsTotal ${MAX_COMPLEMENTOS}
		${If} $i > $ReqsTotal
			IntOp $n ${GrpRequisitos} + 1
			IntOp $ToolIndex $i + $n
			nsArray::Set ListReqId /key=$ToolIndex ""
			nsArray::Set ListReqName /key=$ToolIndex ""
			nsArray::Set ListReqVersion /key=$ToolIndex ""
			nsArray::Set ListReqSizeKb /key=$ToolIndex 0
			nsArray::Set ListReqAddPath /key=$ToolIndex 0
			nsArray::Set ListReqOpChk /key=$ToolIndex 0
			nsArray::Set ListReqHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadActs
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `actualizaciones` /end
	Pop $ActsTotal
	IntOp $ActsTotal $ActsTotal - 1
	${For} $i 0 $ActsTotal
		nsJSON::Get `actualizaciones` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `actualizaciones` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `actualizaciones` /index $i "version" /end
		Pop $ToolVersion
		nsJSON::Get `actualizaciones` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `actualizaciones` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `actualizaciones` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `actualizaciones` /index $i "hash" /end
		Pop $ToolHash
		IntOp $ToolIndex $i + ${SecLanzamiento}
		nsArray::Set ListActId /key=$ToolIndex $ToolId
		nsArray::Set ListActName /key=$ToolIndex $ToolName
		nsArray::Set ListActVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListActSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListActAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListActOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListActHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $ActsTotal ${MAX_ACTUALIZACIONES}
		${If} $i > $ActsTotal
			IntOp $ToolIndex $i + ${SecLanzamiento}
			nsArray::Set ListActId /key=$ToolIndex ""
			nsArray::Set ListActName /key=$ToolIndex ""
			nsArray::Set ListActVersion /key=$ToolIndex ""
			nsArray::Set ListActSizeKb /key=$ToolIndex 0
			nsArray::Set ListActAddPath /key=$ToolIndex 0
			nsArray::Set ListActOpChk /key=$ToolIndex 0
			nsArray::Set ListActHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadExts
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `extensiones` /end
	Pop $ExtsTotal
	IntOp $ExtsTotal $ExtsTotal - 1
	${For} $i 0 $ExtsTotal
		nsJSON::Get `extensiones` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `extensiones` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `extensiones` /index $i "version" /end
		Pop $ToolVersion
		nsJSON::Get `extensiones` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `extensiones` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `extensiones` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `extensiones` /index $i "hash" /end
		Pop $ToolHash
		IntOp $n ${GrpExtensiones} + 1
		IntOp $ToolIndex $i + $n
		nsArray::Set ListExtId /key=$ToolIndex $ToolId
		nsArray::Set ListExtName /key=$ToolIndex $ToolName
		nsArray::Set ListExtVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListExtSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListExtAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListExtOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListExtHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $ExtsTotal ${MAX_EXTENSIONES}
		${If} $i > $ExtsTotal
			IntOp $n ${GrpExtensiones} + 1
			IntOp $ToolIndex $i + $n
			nsArray::Set ListExtId /key=$ToolIndex ""
			nsArray::Set ListExtName /key=$ToolIndex ""
			nsArray::Set ListExtVersion /key=$ToolIndex ""
			nsArray::Set ListExtSizeKb /key=$ToolIndex 0
			nsArray::Set ListExtAddPath /key=$ToolIndex 0
			nsArray::Set ListExtOpChk /key=$ToolIndex 0
			nsArray::Set ListExtHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

!macro MJsonLoadRecs
	nsJSON::Set /file $ToolsCatalog
	nsJSON::Get /count `recursos` /end
	Pop $RecsTotal
	IntOp $RecsTotal $RecsTotal - 1
	${For} $i 0 $RecsTotal
		nsJSON::Get `recursos` /index $i "id" /end 
		Pop $ToolId
		nsJSON::Get `recursos` /index $i "name" /end
		Pop $ToolName
		nsJSON::Get `recursos` /index $i "version" /end
		Pop $ToolVersion
		nsJSON::Get `recursos` /index $i "size_kb" /end
		Pop $ToolSizeKb
		nsJSON::Get `recursos` /index $i "add_path" /end
		Pop $ToolAddPath
		nsJSON::Get `recursos` /index $i "op_chk" /end
		Pop $ToolOpChk
		nsJSON::Get `recursos` /index $i "hash" /end
		Pop $ToolHash
		IntOp $n ${GrpRecursos} + 1
		IntOp $ToolIndex $i + $n
		nsArray::Set ListRecId /key=$ToolIndex $ToolId
		nsArray::Set ListRecName /key=$ToolIndex $ToolName
		nsArray::Set ListRecVersion /key=$ToolIndex $ToolVersion
		nsArray::Set ListRecSizeKb /key=$ToolIndex $ToolSizeKb
		nsArray::Set ListRecAddPath /key=$ToolIndex $ToolAddPath
		nsArray::Set ListRecOpChk /key=$ToolIndex $ToolOpChk
		nsArray::Set ListRecHash /key=$ToolIndex $ToolHash
	${Next}
	${For} $i $RecsTotal ${MAX_RECURSOS}
		${If} $i > $RecsTotal
			IntOp $n ${GrpRecursos} + 1
			IntOp $ToolIndex $i + $n
			nsArray::Set ListRecId /key=$ToolIndex ""
			nsArray::Set ListRecName /key=$ToolIndex ""
			nsArray::Set ListRecVersion /key=$ToolIndex ""
			nsArray::Set ListRecSizeKb /key=$ToolIndex 0
			nsArray::Set ListRecAddPath /key=$ToolIndex 0
			nsArray::Set ListRecOpChk /key=$ToolIndex 0
			nsArray::Set ListRecHash /key=$ToolIndex ""
		${EndIf}
	${Next}
!macroend

;--------------------------------
;MGetInfo... (5)

!macro MGetInfoAct
	nsArray::Get ListActId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListActName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListActVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListActSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListActAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListActOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListActHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $ToolIndex $i + ${SecLanzamiento}
!macroend

!macro MGetInfoReq
	nsArray::Get ListReqId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListReqName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListReqVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListReqSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListReqAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListReqOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListReqHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $n ${GrpRequisitos} + 1
	IntOp $ToolIndex $i + $n
!macroend

!macro MGetInfoComp
	nsArray::Get ListCompId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListCompName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListCompVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListCompSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListCompAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListCompOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListCompHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $n ${GrpComplementos} + 1
	IntOp $ToolIndex $i + $n
!macroend

!macro MGetInfoExt
	nsArray::Get ListExtId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListExtName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListExtVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListExtSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListExtAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListExtOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListExtHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $n ${GrpExtensiones} + 1
	IntOp $ToolIndex $i + $n
!macroend

!macro MGetInfoRec
	nsArray::Get ListRecId /at=$i
	Pop $1
	Pop $ToolId
	nsArray::Get ListRecName /at=$i
	Pop $1
	Pop $ToolName
	nsArray::Get ListRecVersion /at=$i
	Pop $1
	Pop $ToolVersion
	nsArray::Get ListRecSizeKb /at=$i
	Pop $1
	Pop $ToolSizeKb
	nsArray::Get ListRecAddPath /at=$i
	Pop $1
	Pop $ToolAddPath
	nsArray::Get ListRecOpChk /at=$i
	Pop $1
	Pop $ToolOpChk
	nsArray::Get ListRecHash /at=$i
	Pop $1
	Pop $ToolHash
	IntOp $n ${GrpRecursos} + 1
	IntOp $ToolIndex $i + $n
!macroend

;--------------------------------
;SECTION_... (5)

!macro SECTION_ACTUALIZACION index
Section /o "" ${index}
	IntOp $i ${index} - ${SecLanzamiento}
	${If} $i < ${MAX_ACTUALIZACIONES}
		Call InstallByIndexAct
	${EndIf}
SectionEnd
!macroend

!macro SECTION_REQUISITO index
Section /o "" ${index}
	IntOp $Aux ${GrpRequisitos} + 1
	IntOp $i ${index} - $Aux
	${If} $i < ${MAX_REQUISITOS}
		Call InstallByIndexReq
	${EndIf}
SectionEnd
!macroend

!macro SECTION_COMPLEMENTO index
Section /o "" ${index}
	IntOp $Aux ${GrpComplementos} + 1
	IntOp $i ${index} - $Aux
	${If} $i < ${MAX_COMPLEMENTOS}
		Call InstallByIndexComp
	${EndIf}
SectionEnd
!macroend

!macro SECTION_EXTENSION index
Section /o "" ${index}
	IntOp $Aux ${GrpExtensiones} + 1
	IntOp $i ${index} - $Aux
	${If} $i < ${MAX_EXTENSIONES}
		Call InstallByIndexExt
	${EndIf}
SectionEnd
!macroend

!macro SECTION_RECURSO index
Section /o "" ${index}
	IntOp $Aux ${GrpRecursos} + 1
	IntOp $i ${index} - $Aux
	${If} $i < ${MAX_RECURSOS}
		Call InstallByIndexRec
	${EndIf}
SectionEnd
!macroend

;--------------------------------
!macro MUninstallTools
	Call un.JsonLoadComps
	Call un.JsonLoadReqs
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPLEMENTOS}
			Call un.GetInfoComp
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQUISITOS}
			Call un.GetInfoReq
			RMDir /r "$INSTDRIVE${TOOLS}\$ToolId"
			Push "$INSTDRIVE${TOOLS}\$ToolId"
			Call un.RemoveFromEnvUserPath
		${EndIf}
	${Next}
!macroend

;--------------------------------
; FUNCIONES INSTALACION

;--------------------------------
;JsonLoad... (5)

Function JsonLoadComps
	!insertmacro MJsonLoadComps
FunctionEnd

Function JsonLoadReqs
	!insertmacro MJsonLoadReqs
FunctionEnd

Function JsonLoadActs
	!insertmacro MJsonLoadActs
FunctionEnd

Function JsonLoadExts
	!insertmacro MJsonLoadExts
FunctionEnd

Function JsonLoadRecs
	!insertmacro MJsonLoadRecs
FunctionEnd

;--------------------------------
;GetInfo... (5)

Function GetInfoComp
	!insertmacro MGetInfoComp
FunctionEnd

Function GetInfoReq
	!insertmacro MGetInfoReq
FunctionEnd

Function GetInfoAct
	!insertmacro MGetInfoAct
FunctionEnd

Function GetInfoExt
	!insertmacro MGetInfoExt
FunctionEnd

Function GetInfoRec
	!insertmacro MGetInfoRec
FunctionEnd

;--------------------------------
;InstallByIndex... (5)

Function InstallByIndexComp
	${If} $i >= ${MAX_COMPLEMENTOS}
	${OrIf} $i > $CompsTotal
		Return
	${EndIf}
	Call GetInfoComp
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Comp
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
Tag_FIN_Comp:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexReq
	${If} $i >= ${MAX_REQUISITOS}
	${OrIf} $i > $ReqsTotal
		Return
	${EndIf}
	Call GetInfoReq
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Req
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
Tag_FIN_Req:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexAct
	${If} $i >= ${MAX_ACTUALIZACIONES}
	${OrIf} $i > $ActsTotal
		Return
	${EndIf}
	Call GetInfoAct
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	${If} $ToolId == "release"
		${If} $ToolVersion == $VERSION
			Return
		${EndIf}
		MessageBox MB_YESNO|MB_ICONQUESTION "${TXT_MsgConfirmaActualizacion}$\n$\n${TXT_MsgActual}: $VERSION$\n${TXT_MsgNueva}: $ToolVersion" IDNO EndAct
	${EndIf}
	DetailPrint "${TXT_LogDescargandoActualizacion} $ToolName v$ToolVersion"
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		DetailPrint "${TXT_MsgErrorActualizacion}"
		Goto Tag_FIN_Act
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
Tag_FIN_Act:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
	Return
EndAct:
	DetailPrint "${TXT_MsgActualizacionCancelada}"
FunctionEnd

Function InstallByIndexExt
	${If} $i >= ${MAX_EXTENSIONES}
	${OrIf} $i > $ExtsTotal
		Return
	${EndIf}
	Call GetInfoExt
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Ext
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
Tag_FIN_Ext:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

Function InstallByIndexRec
	${If} $i >= ${MAX_RECURSOS}
	${OrIf} $i > $RecsTotal
		Return
	${EndIf}
	Call GetInfoRec
	${If} ${SectionIsSelected} $ToolIndex
	${Else}
		Return
	${EndIf}
	Call DownloadSingleTool
	Pop $0
	${If} $0 == "NO"
	${OrIf} $ToolTemp == ""
		Goto Tag_FIN_Rec
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
Tag_FIN_Rec:
	DetailPrint "..."
	SetOutPath "$INSTDRIVE$INSTDIR"
	Delete "$TEMP\$ToolId.zip"
	RMDir /r "$TEMP\$ToolId_tmp"
FunctionEnd

;--------------------------------
; Funciones generales

Function CheckAllTools
	StrCpy $CompsVisibles "0"
	StrCpy $ReqsVisibles "0"
	StrCpy $ExtsVisibles "0"
	StrCpy $RecsVisibles "0"
	Call FetchToolsCatalog
	Call JsonLoadComps
	${For} $i 0 $CompsTotal
		${If} $i < ${MAX_COMPLEMENTOS}
			Call GetInfoComp
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				IntOp $0 0 | ${SF_RO}
				SectionSetFlags $ToolIndex $0
				SectionSetText $ToolIndex ""
			${Else}
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $CompsVisibles $CompsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${EndIf}
		${EndIf}
	${Next}
	Call JsonLoadReqs
	${For} $i 0 $ReqsTotal
		${If} $i < ${MAX_REQUISITOS}
			Call GetInfoReq
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ReqsVisibles $ReqsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndex ${SF_SELECTED}
				IntOp $ReqsVisibles $ReqsVisibles + 1
			${EndIf}
		${EndIf}
	${Next}
	Call JsonLoadExts
	${For} $i 0 $ExtsTotal
		${If} $i < ${MAX_EXTENSIONES}
			Call GetInfoExt
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $ExtsVisibles $ExtsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $ExtsVisibles $ExtsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ExtsVisibles $ExtsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $ExtsVisibles $ExtsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndex ${SF_SELECTED}
				IntOp $ExtsVisibles $ExtsVisibles + 1
			${EndIf}
		${EndIf}
	${Next}
	Call JsonLoadRecs
	${For} $i 0 $RecsTotal
		${If} $i < ${MAX_RECURSOS}
			Call GetInfoRec
			SectionSetText $ToolIndex $ToolName
			SectionSetSize $ToolIndex $ToolSizeKb
			${If} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\bin\*.exe"
			${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\$ToolId\*.json"
				${If} "$ToolOpChk" == "0"
					SectionSetFlags $ToolIndex 0
					IntOp $RecsVisibles $RecsVisibles + 1
				${ElseIf} "$ToolOpChk" == "1"
					SectionSetFlags $ToolIndex ${SF_SELECTED}
					IntOp $RecsVisibles $RecsVisibles + 1
				${ElseIf} "$ToolOpChk" == "2"
					IntOp $0 ${SF_SELECTED} | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $RecsVisibles $RecsVisibles + 1
				${ElseIf} "$ToolOpChk" == "3"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					IntOp $RecsVisibles $RecsVisibles + 1
				${ElseIf} "$ToolOpChk" == "4"
					IntOp $0 0 | ${SF_RO}
					SectionSetFlags $ToolIndex $0
					SectionSetText $ToolIndex ""
				${EndIf}
			${Else}
				SectionSetFlags $ToolIndex ${SF_SELECTED}
				IntOp $RecsVisibles $RecsVisibles + 1
			${EndIf}
		${EndIf}
	${Next}
	Call JsonLoadActs
	${For} $i 0 $ActsTotal
		${If} $i < ${MAX_ACTUALIZACIONES}
			Call GetInfoAct
			${If} $IsUpdateInstall == "1"
				SectionSetText $ToolIndex "$ToolName $ToolVersion"
				SectionSetSize $ToolIndex $ToolSizeKb
				${If} $ToolVersion == $VERSION
				${AndIf} $ToolId == "release"
					SectionSetText $ToolIndex ""
					SectionSetSize $ToolIndex 0
				${Else}
					SectionSetFlags $ToolIndex ${SF_SELECTED}
				${EndIf}
			${Else}
				SectionSetText $ToolIndex ""
			${EndIf}
		${EndIf}
	${Next}
	${If} $CompsVisibles == "0"
		SectionSetText ${GrpComplementos} ""
	${EndIf}
	${If} $ReqsVisibles == "0"
		SectionSetText ${GrpRequisitos} ""
	${EndIf}
	${If} $ExtsVisibles == "0"
		SectionSetText ${GrpExtensiones} ""
	${EndIf}
	${If} $RecsVisibles == "0"
		SectionSetText ${GrpRecursos} ""
	${EndIf}
FunctionEnd

Function CheckBaseComponents
	${If} $IsUpdateInstall == "1"
		SectionSetFlags ${SecPrograma} 0
		SectionSetFlags ${SecLanzamiento} ${SF_SELECTED}
		SectionSetText ${SecPrograma} "${NAME} ${TXT_EtiqReinstalar}"
	${Else}
		IntOp $Aux ${SF_SELECTED} | ${SF_RO}
		SectionSetFlags ${SecPrograma} $Aux
		IntOp $Aux 0 | ${SF_RO}
		SectionSetFlags ${SecLanzamiento} $Aux
		SectionSetText ${SecLanzamiento} ""
	${EndIf}
FunctionEnd

Function FetchToolsCatalog
	SetOutPath "$INSTDRIVE$INSTDIR"
	File "catalogo.json"
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

Function un.JsonLoadComps
	!insertmacro MJsonLoadComps
FunctionEnd

Function un.JsonLoadReqs
	!insertmacro MJsonLoadReqs
FunctionEnd

Function un.GetInfoComp
	!insertmacro MGetInfoComp
FunctionEnd

Function un.GetInfoReq
	!insertmacro MGetInfoReq
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
