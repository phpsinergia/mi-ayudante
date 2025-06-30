; prereqs.nsh
;================================
; MODULO: PREREQUISITOS
;================================

;--------------------------------
; VARIABLES
;--------------------------------
Var SkipPreCheckbox
Var ResPHP
Var ResComposer
Var ResMSVC
Var ResNotepad

;--------------------------------
; FUNCIONES
;--------------------------------

Function CheckPreRequisites
	${If} $SkipPrereq == "1"
		Abort
	${EndIf}
	Push $0
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "$(TXT_TituloPrereq)" "$(TXT_SubtituloPrereq)"
	Call DetectPHP
	Call DetectComposer
	Call DetectMSVC
	Call DetectNotepad
	;TODO: Falta añadir la vista de resultados y sugerencias

	;1. PHP
	${NSD_CreateGroupBox} 5u 0u 290u 32u "PHP 8.x"
	Pop $0
	${If} $ResPHP == "OK"
	${Else}
	${EndIf}

	;2. Composer
	${NSD_CreateGroupBox} 5u 32u 290u 32u "Composer"
	Pop $0
	${If} $ResComposer == "OK"
	${Else}
	${EndIf}

	;3. Visual C++ Redistributable
	${NSD_CreateGroupBox} 5u 64u 290u 32u "Visual C++ Redistributable"
	Pop $0
	${If} $ResMSVC == "OK"
	${Else}
	${EndIf}

	;4. Notepad++
	${NSD_CreateGroupBox} 5u 96u 290u 32u "Notepad++"
	Pop $0
	${If} $ResNotepad == "OK"
	${Else}
	${EndIf}

	${NSD_CreateCheckbox} 100u 131u 150u 10u "$(TXT_EtiqNomostrarDenuevo)"
	Pop $SkipPreCheckbox
	nsDialogs::Show
	Pop $0
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPrereq
	;TODO: Falta encadenar que si $ResPHP == "OK", desmarque PHP de la lista de Requisitos (SEC_PHP)
FunctionEnd

Function DetectPHP
	;TODO: Falta implementar la detección de PHP
	StrCpy $ResPHP ""
FunctionEnd

Function DetectComposer
	;TODO: Falta implementar la detección de Composer
	StrCpy $ResComposer ""
FunctionEnd

Function DetectNotepad
	;TODO: Falta implementar la detección de Notepad
	StrCpy $ResNotepad ""
FunctionEnd

Function DetectMSVC
	;TODO: Falta implementar la detección de MSVC
	StrCpy $ResMSVC ""
FunctionEnd
