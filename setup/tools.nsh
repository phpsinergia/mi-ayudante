!macro UninstallTool TOOL_ID
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Call un.RemoveFromEnvUserPath
!macroend

!macro GenerateSectionTool TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_PATH
Section /o "${TOOL_NAME}" ${SEC_${TOOL_ID}}
	AddSize ${TOOL_SIZE_KB}
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
	${OrIf} $PROTOCOL == "---"
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	SetOutPath "$TEMP"
	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"$TEMP\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} (FTP):$\n$R2"
			Goto SkipTool_${TOOL_ID}
		${EndIf}
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		inetc::get /TIMEOUT=30000 /RESUME "" "$R0" "$TEMP\${TOOL_ID}.zip" /END
		Pop $R1
		${If} $R1 != "OK"
			MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} (HTTP):$\n$R1"
			Goto SkipTool_${TOOL_ID}
		${EndIf}
	${Else}
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	StrCpy $R7 "$TEMP\${TOOL_ID}_tmp"
	RMDir /r "$R7"
	CreateDirectory "$R7"
	SetOutPath "$R7"
	Nsisunz::UnzipToLog "$TEMP\${TOOL_ID}.zip" "$R7"
	Pop $R1
	${If} $R1 != "success"
		MessageBox MB_ICONSTOP "Error al descomprimir ${TOOL_NAME}: $R1"
		RMDir /r "$R7"
		Delete "$TEMP\${TOOL_ID}.zip"
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	${GetSize} "$R7" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - ${TOOL_SIZE_KB}
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 Tag_Mismatch_${TOOL_ID}
	Goto Tag_OK_${TOOL_ID}
Tag_Mismatch_${TOOL_ID}:
	MessageBox MB_ICONEXCLAMATION \
		"Tamaño incorrecto ($R4 KB ≠ ${TOOL_SIZE_KB} KB) en ${TOOL_NAME}"
	RMDir /r "$R7"
	Delete "$TEMP\${TOOL_ID}.zip"
	Goto SkipTool_${TOOL_ID}
Tag_OK_${TOOL_ID}:
	StrCpy $R8 $R7 2
	StrCpy $R9 $INSTDRIVE 2
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	${If} "$R8" == "$R9"
		Rename "$R7" "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	${Else}
		CreateDirectory "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		CopyFiles /SILENT "$R7\*.*" "$INSTDRIVE${TOOLS}\${TOOL_ID}\"
		RMDir /r "$R7"
	${EndIf}
	Delete "$TEMP\${TOOL_ID}.zip"
	${If} ${ADD_PATH} == 1
		Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		Call AddToEnvUserPath
	${EndIf}
SkipTool_${TOOL_ID}:
SectionEnd
!macroend

!macro CheckIfInstalledTool TOOL_ID SEC_ID OP_SEL
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
		${If} "${OP_SEL}" == "0"
			SectionSetFlags ${SEC_ID} 0
		${ElseIf} "${OP_SEL}" == "1"
			SectionSetFlags ${SEC_ID} ${SF_SELECTED}
		${ElseIf} "${OP_SEL}" == "2"
			IntOp $0 ${SF_SELECTED} | ${SF_RO}
			SectionSetFlags ${SEC_ID} $0
		${ElseIf} "${OP_SEL}" == "3"
			IntOp $0 0 | ${SF_RO}
			SectionSetFlags ${SEC_ID} $0
		${EndIf}
	${EndIf}
!macroend

!define SEC_curl 6
!define SEC_7za 7
!define SEC_gettext 8
!define SEC_sqlite 9
!define SEC_mkcert 10
!define SEC_pdftk 11
!define SEC_pandoc 12
!define SEC_wkhtmltopdf 13
!define SEC_ffmpeg 14
!define SEC_bootstrap 15

!macro GenerateAllSectionTools
    !insertmacro GenerateSectionTool curl "CLI Curl" 6071 1
    !insertmacro GenerateSectionTool 7za "CLI 7za" 466 0
    !insertmacro GenerateSectionTool gettext "CLI Gettext" 6080 1
    !insertmacro GenerateSectionTool sqlite "CLI SQLite" 14257 1
    !insertmacro GenerateSectionTool mkcert "CLI Mkcert" 5136 0
    !insertmacro GenerateSectionTool pdftk "CLI PDFtk" 9638 1
    !insertmacro GenerateSectionTool pandoc "CLI Pandoc" 216722 1
    !insertmacro GenerateSectionTool wkhtmltopdf "CLI Wkhtmltopdf" 88533 1
    !insertmacro GenerateSectionTool ffmpeg "CLI FFmpeg" 37121 1
    !insertmacro GenerateSectionTool bootstrap "SCSS Bootstrap" 11580 0
!macroend

!macro UninstallAllTools
    !insertmacro UninstallTool 7za
    !insertmacro UninstallTool curl
    !insertmacro UninstallTool gettext
    !insertmacro UninstallTool sqlite
    !insertmacro UninstallTool mkcert
    !insertmacro UninstallTool pdftk
    !insertmacro UninstallTool pandoc
    !insertmacro UninstallTool wkhtmltopdf
    !insertmacro UninstallTool ffmpeg
    !insertmacro UninstallTool bootstrap
!macroend

Function CheckIfInstalledAllTools
    !insertmacro CheckIfInstalledTool "curl" ${SEC_curl} 3
    !insertmacro CheckIfInstalledTool "7za" ${SEC_7za} 3
    !insertmacro CheckIfInstalledTool "gettext" ${SEC_gettext} 3
    !insertmacro CheckIfInstalledTool "sqlite" ${SEC_sqlite} 3
    !insertmacro CheckIfInstalledTool "mkcert" ${SEC_mkcert} 3
    !insertmacro CheckIfInstalledTool "pdftk" ${SEC_pdftk} 3
    !insertmacro CheckIfInstalledTool "pandoc" ${SEC_pandoc} 3
    !insertmacro CheckIfInstalledTool "wkhtmltopdf" ${SEC_wkhtmltopdf} 3
    !insertmacro CheckIfInstalledTool "ffmpeg" ${SEC_ffmpeg} 3
    !insertmacro CheckIfInstalledTool "bootstrap" ${SEC_bootstrap} 3
FunctionEnd
