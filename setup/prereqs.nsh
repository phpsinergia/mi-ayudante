;--------------------------------
; FUNCIONES

Function CheckPreRequisites
	${If} $SkipPrereq == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "${TXT_TituloPrereq}" "${TXT_SubtituloPrereq}"

	;TODO: Aquí falta añadir la Detección real de Pre-requisitos, la entrega de sus resultados y sugerencias
	;1. PHP
	Call DetectPHP
	;2. Composer
	Call DetectComposer
	;3. Visual C++ Redistributable
	Call DetectMSVC
	;4. Notepad++ (o notepad.exe)
	Call DetectNotepad

	${NSD_CreateCheckbox} 100u 130u 150u 10u "${TXT_EtiqNomostrarDenuevo}"
	Pop $SkipPreCheckbox
	nsDialogs::Show
FunctionEnd

Function DetectPHP
FunctionEnd

Function DetectComposer
FunctionEnd

Function DetectNotepad
FunctionEnd

Function DetectMSVC
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPrereq
FunctionEnd
