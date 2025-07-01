; prereqs.nsh
;================================
; MODULO: PREREQUISITOS
;================================

!define URL_PHP "https://www.apachefriends.org/download.html"
!define URL_COMPOSER "https://getcomposer.org/download/"
!define URL_MSVC "https://learn.microsoft.com/es-es/cpp/windows/latest-supported-vc-redist"
!define URL_NOTEPAD "https://notepad-plus-plus.org/downloads/"

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

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPrereq
	${If} $ResPHP != "NO"
	${AndIf} $ResComposer != "NO"
	${AndIf} $ResMSVC != "NO"
	${AndIf} $ResNotepad != "NO"
		StrCpy $SkipPrereq "1"
	${EndIf}
FunctionEnd

Function CheckPreRequisites
	${If} $SkipPrereq == "1"
		Abort
	${EndIf}
	Push $0
	Push $1
	Push $2
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "$(TXT_TituloPrereq)" "$(TXT_SubtituloPrereq)"
	Call DetectPHP
	Call DetectComposer
	Call DetectMSVC
	Call DetectNotepad
	;1. PHP
	${NSD_CreateGroupBox} 5u 0u 290u 32u "PHP (cli)"
	Pop $0
	${NSD_CreateBitmap} 13u 11u 100% 100% ""
	Pop $1
	${If} $ResPHP != "NO"
		${NSD_CreateLabel} 35u 15u 240u 9u "$ResPHP"
		Pop $0
		${NSD_SetBitmap} $1 "ok.bmp" $2
	${Else}
		${NSD_CreateLabel} 35u 15u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $0
		${NSD_CreateLink} 130u 15u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (XAMPP)"
		Pop $0
		${NSD_OnClick} $0 OpenUrlPHP
		${NSD_SetBitmap} $1 "no.bmp" $2
	${EndIf}
	;2. Composer
	${NSD_CreateGroupBox} 5u 32u 290u 32u "Composer"
	Pop $0
	${NSD_CreateBitmap} 13u 43u 100% 100% ""
	Pop $1
	${If} $ResComposer != "NO"
		${NSD_CreateLabel} 35u 47u 240u 9u "$ResComposer"
		Pop $0
		${NSD_SetBitmap} $1 "ok.bmp" $2
	${Else}
		${NSD_CreateLabel} 35u 47u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $0
		${NSD_CreateLink} 130u 47u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (Composer)"
		Pop $0
		${NSD_OnClick} $0 OpenUrlComposer
		${NSD_SetBitmap} $1 "no.bmp" $2
	${EndIf}
	;3. Visual C++ Redistributable
	${NSD_CreateGroupBox} 5u 64u 290u 32u "Visual C++ Redistributable"
	Pop $0
	${NSD_CreateBitmap} 13u 75u 100% 100% ""
	Pop $1
	${If} $ResMSVC != "NO"
		${NSD_CreateLabel} 35u 79u 240u 9u "$ResMSVC"
		Pop $0
		${NSD_SetBitmap} $1 "ok.bmp" $2
	${Else}
		${NSD_CreateLabel} 35u 79u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $0
		${NSD_CreateLink} 130u 79u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (MSVC)"
		Pop $0
		${NSD_OnClick} $0 OpenUrlMSVC
		${NSD_SetBitmap} $1 "no.bmp" $2
	${EndIf}
	;4. Notepad++
	${NSD_CreateGroupBox} 5u 96u 290u 32u "Notepad++"
	Pop $0
	${NSD_CreateBitmap} 13u 107u 100% 100% ""
	Pop $1
	${If} $ResNotepad != "NO"
		${NSD_CreateLabel} 35u 111u 240u 9u "$ResNotepad"
		Pop $0
		${NSD_SetBitmap} $1 "ok.bmp" $2
	${Else}
		${NSD_CreateLabel} 35u 111u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $0
		${NSD_CreateLink} 130u 111u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (Notepad++)"
		Pop $0
		${NSD_OnClick} $0 OpenUrlNotepad
		${NSD_SetBitmap} $1 "no.bmp" $2
	${EndIf}
	${NSD_CreateCheckbox} 100u 131u 150u 10u "$(TXT_EtiqNomostrarDenuevo)"
	Pop $SkipPreCheckbox
	nsDialogs::Show
	Pop $0
	${NSD_FreeBitmap} $2
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function OpenUrlPHP
	ExecShell "open" ${URL_PHP}
FunctionEnd

Function OpenUrlComposer
	ExecShell "open" ${URL_COMPOSER}
FunctionEnd

Function OpenUrlMSVC
	ExecShell "open" ${URL_MSVC}
FunctionEnd

Function OpenUrlNotepad
	ExecShell "open" ${URL_NOTEPAD}
FunctionEnd

Function DetectPHP
	Push $0
	Push $1
	Push $2
	nsExec::ExecToStack 'php -v'
	Pop $0
	Pop $1
	StrCmp $0 0 PHPDetected PHPNotDetected
PHPDetected:
	${WordFind} "$1" "PHP" "+1" $2
	${If} $2 != ""
		StrCpy $ResPHP $2
	${Else}
		Goto PHPNotDetected
	${EndIf}
	Goto EndDetectPHP
PHPNotDetected:
	StrCpy $ResPHP "NO"
	Goto EndDetectPHP
EndDetectPHP:
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function DetectComposer
	Push $0
	Push $1
	Push $2
	nsExec::ExecToStack 'composer.bat -V'
	Pop $0
	Pop $1
	StrCmp $0 0 ComposerDetected ComposerNotDetected
ComposerDetected:
	${WordFind} "$1" "Composer" "+1" $2
	${If} $2 != ""
		StrCpy $ResComposer $2
	${Else}
		Goto ComposerNotDetected
	${EndIf}
	Goto EndDetectComposer
ComposerNotDetected:
	StrCpy $ResComposer "NO"
	Goto EndDetectComposer
EndDetectComposer:
	Pop $2
	Pop $1
	Pop $0
FunctionEnd

Function DetectMSVC
	;TODO: Falta implementar la detección de MSVC
	StrCpy $ResMSVC "NO"
	;StrCpy $ResMSVC "ZTS Visual C++ 2019 x64"
FunctionEnd

Function DetectNotepad
	;TODO: Falta implementar la detección de Notepad
	StrCpy $ResNotepad "NO"
	;StrCpy $ResNotepad "Notepad++ v8.7.5 (64-bit)"
FunctionEnd
