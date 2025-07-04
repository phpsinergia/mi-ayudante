; prereqs.nsh
;================================
; MODULO: PREREQUISITOS
;================================

;--------------------------------
; CONSTANTES
;--------------------------------
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

Function ShowPreRequisites
	${If} $SkipPrereq == "1"
		Abort
	${EndIf}
	nsDialogs::Create 1018
	Pop $0
	!insertmacro MUI_HEADER_TEXT "$(TXT_TituloPrereq)" "$(TXT_SubtituloPrereq)"
	${If} ${RunningX64}
		SetRegView 64
	${EndIf}
	Call DetectPHP
	Call DetectComposer
	Call DetectMSVC
	Call DetectNotepad
	;1. PHP
	${NSD_CreateGroupBox} 5u 0u 290u 32u "PHP (cli)"
	Pop $R0
	${NSD_CreateBitmap} 13u 11u 100% 100% ""
	Pop $R1
	${If} $ResPHP != "NO"
		${NSD_CreateLabel} 35u 15u 240u 9u "$ResPHP"
		Pop $R0
		${NSD_SetBitmap} $R1 "ok.bmp" $R2
	${Else}
		${NSD_CreateLabel} 35u 15u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $R0
		${NSD_CreateLink} 130u 15u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (XAMPP)"
		Pop $R0
		${NSD_OnClick} $R0 OpenUrlPHP
		${NSD_SetBitmap} $R1 "no.bmp" $R2
	${EndIf}
	;2. Composer
	${NSD_CreateGroupBox} 5u 32u 290u 32u "Composer"
	Pop $R0
	${NSD_CreateBitmap} 13u 43u 100% 100% ""
	Pop $R1
	${If} $ResComposer != "NO"
		${NSD_CreateLabel} 35u 47u 240u 9u "$ResComposer"
		Pop $R0
		${NSD_SetBitmap} $R1 "ok.bmp" $R2
	${Else}
		${NSD_CreateLabel} 35u 47u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $R0
		${NSD_CreateLink} 130u 47u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (Composer)"
		Pop $R0
		${NSD_OnClick} $R0 OpenUrlComposer
		${NSD_SetBitmap} $R1 "no.bmp" $R2
	${EndIf}
	;3. Visual C++ Redistributable
	${NSD_CreateGroupBox} 5u 64u 290u 32u "Visual C++ Redistributable"
	Pop $R0
	${NSD_CreateBitmap} 13u 75u 100% 100% ""
	Pop $R1
	${If} $ResMSVC != "NO"
		${NSD_CreateLabel} 35u 79u 240u 9u "$ResMSVC"
		Pop $R0
		${NSD_SetBitmap} $R1 "ok.bmp" $R2
	${Else}
		${NSD_CreateLabel} 35u 79u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $R0
		${NSD_CreateLink} 130u 79u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (MSVC)"
		Pop $R0
		${NSD_OnClick} $R0 OpenUrlMSVC
		${NSD_SetBitmap} $R1 "no.bmp" $R2
	${EndIf}
	;4. Notepad++
	${NSD_CreateGroupBox} 5u 96u 290u 32u "Notepad++"
	Pop $R0
	${NSD_CreateBitmap} 13u 107u 100% 100% ""
	Pop $R1
	${If} $ResNotepad != "NO"
		${NSD_CreateLabel} 35u 111u 240u 9u "$ResNotepad"
		Pop $R0
		${NSD_SetBitmap} $R1 "ok.bmp" $R2
	${Else}
		${NSD_CreateLabel} 35u 111u 80u 9u "$(TXT_EtiqNoDetectado)"
		Pop $R0
		${NSD_CreateLink} 130u 111u 140u 9u "$(TXT_EtiqDescargarDeSitioOficial) (Notepad++)"
		Pop $R0
		${NSD_OnClick} $R0 OpenUrlNotepad
		${NSD_SetBitmap} $R1 "no.bmp" $R2
	${EndIf}
	${NSD_CreateCheckbox} 100u 131u 150u 10u "$(TXT_EtiqNomostrarDenuevo)"
	Pop $SkipPreCheckbox
	nsDialogs::Show
	${NSD_FreeBitmap} $R2
FunctionEnd

Function LeavePreRequisites
	${NSD_GetState} $SkipPreCheckbox $SkipPrereq
	${If} $ResPHP != "NO"
	${AndIf} $ResComposer != "NO"
	${AndIf} $ResMSVC != "NO"
	${AndIf} $ResNotepad != "NO"
		StrCpy $SkipPrereq "1"
	${EndIf}
FunctionEnd

;--------------------------------

Function DetectPHP
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
FunctionEnd

Function DetectComposer
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
FunctionEnd

Function DetectMSVC
	StrCpy $ResMSVC "NO"
	ReadRegStr $0 HKLM "SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86" "Version"
	${If} $0 != ""
		StrCpy $ResMSVC " $0 (x86)  . "
	${EndIf}
	ReadRegStr $1 HKLM "SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64" "Version"
	${If} $1 != ""
		StrCpy $ResMSVC "$ResMSVC $1 (x64)"
	${EndIf}
FunctionEnd

Function DetectNotepad
	StrCpy $ResNotepad "NO"
	ReadRegStr $0 HKLM "SOFTWARE\Notepad++" ""
	${If} $0 != ""
		StrCpy $ResNotepad "$0"
	${EndIf}
FunctionEnd

;--------------------------------

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
