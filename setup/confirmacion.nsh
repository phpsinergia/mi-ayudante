; confirmacion.nsh
;================================
; MODULO: CONFIRMACION
;================================

;--------------------------------
; VARIABLES
;--------------------------------
Var SkipConfirmCheckbox
Var ShortcutStartMenuCheckbox
Var ShortcutDesktopCheckbox
Var ShortcutUpdaterCheckbox
Var ShortcutWindowsStartCheckbox

;--------------------------------
; FUNCIONES
;--------------------------------

Function ShowConfirmInstall
	${If} $SkipConfirm == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "$(TXT_TituloConfirm)" "$(TXT_SubtituloConfirm)"
	;1. UBICACION
	${NSD_CreateGroupBox} 5u 0u 290u 28u "$(TXT_EtiqUbicacion)"
	Pop $R0
	${NSD_CreateLabel} 18u 13u 240u 9u "$(TXT_EtiqRutaFinal) $InstDrive$INSTDIR"
	Pop $R0
	;2. ACCESOS DIRECTOS
	${NSD_CreateGroupBox} 5u 33u 290u 60u "$(TXT_EtiqAccesosDirectos)"
	Pop $R0
	${NSD_CreateCheckbox} 15u 47u 240u 9u " $(TXT_EtiqMenuInicio)"
	Pop $ShortcutStartMenuCheckbox
	${If} $ShortcutStartMenu == "1"
		${NSD_Check} $ShortcutStartMenuCheckbox
	${EndIf}
	${NSD_CreateCheckbox} 15u 61u 240u 9u " $(TXT_EtiqEscritorioPrograma)"
	Pop $ShortcutDesktopCheckbox
	${If} $ShortcutDesktop == "1"
		${NSD_Check} $ShortcutDesktopCheckbox
	${EndIf}
	${NSD_CreateCheckbox} 15u 75u 240u 9u " $(TXT_EtiqEscritorioActualizador)"
	Pop $ShortcutUpdaterCheckbox
	${If} $ShortcutUpdater == "1"
		${NSD_Check} $ShortcutUpdaterCheckbox
	${EndIf}
	;3. INICIO
	${NSD_CreateGroupBox} 5u 98u 290u 29u "$(TXT_EtiqInicioWindows)"
	Pop $R0
	${NSD_CreateCheckbox} 15u 111u 240u 9u " $(TXT_EtiqEjecutarInicio)"
	Pop $ShortcutWindowsStartCheckbox
	${If} $ShortcutWindowsStart == "1"
		${NSD_Check} $ShortcutWindowsStartCheckbox
	${EndIf}
	${NSD_CreateCheckbox} 100u 131u 150u 10u "$(TXT_EtiqNomostrarDenuevo)"
	Pop $SkipConfirmCheckbox
	nsDialogs::Show
FunctionEnd

Function LeaveConfirmInstall
	${NSD_GetState} $SkipConfirmCheckbox $SkipConfirm
	${NSD_GetState} $ShortcutStartMenuCheckbox $ShortcutStartMenu
	${NSD_GetState} $ShortcutDesktopCheckbox $ShortcutDesktop
	${NSD_GetState} $ShortcutUpdaterCheckbox $ShortcutUpdater
	${NSD_GetState} $ShortcutWindowsStartCheckbox $ShortcutWindowsStart
FunctionEnd
