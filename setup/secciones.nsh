;--------------------------------
; MACROS POR CLASE DE TOOL

!macro SECTION_ACTUALIZACION index
Section /o "" ${index}
	IntOp $i ${index} - ${SecLanzamiento}
	${If} $i < ${MAX_ACTUALIZACIONES}
		Call InstallActByIndex
	${EndIf}
SectionEnd
!macroend

!macro SECTION_REQUISITO index
Section /o "" ${index}
	IntOp $Ajuste ${GrpRequisitos} + 1
	IntOp $i ${index} - $Ajuste
	${If} $i < ${MAX_REQUISITOS}
		Call InstallReqByIndex
	${EndIf}
SectionEnd
!macroend

!macro SECTION_COMPLEMENTO index
Section /o "" ${index}
	IntOp $Ajuste ${GrpComplementos} + 1
	IntOp $i ${index} - $Ajuste
	${If} $i < ${MAX_COMPLEMENTOS}
		Call InstallCompByIndex
	${EndIf}
SectionEnd
!macroend

!macro SECTION_EXTENSION index
Section /o "" ${index}
	IntOp $Ajuste ${GrpExtensiones} + 1
	IntOp $i ${index} - $Ajuste
	${If} $i < ${MAX_EXTENSIONES}
		Call InstallExtByIndex
	${EndIf}
SectionEnd
!macroend

!macro SECTION_RECURSO index
Section /o "" ${index}
	IntOp $Ajuste ${GrpRecursos} + 1
	IntOp $i ${index} - $Ajuste
	${If} $i < ${MAX_RECURSOS}
		Call InstallRecByIndex
	${EndIf}
SectionEnd
!macroend
