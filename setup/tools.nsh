;------------------------------------------------------------
; MACROS PARA GESTIONAR HERRAMIENTAS

!macro UninstallTool TOOL_ID
	RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
	Call un.RemoveFromEnvUserPath
!macroend

!macro CheckIfInstalledTool TOOL_IDX TOOL_ID OP_SEL
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.php"
		${If} "${OP_SEL}" == "0"
			SectionSetFlags ${TOOL_IDX} 0
		${ElseIf} "${OP_SEL}" == "1"
			SectionSetFlags ${TOOL_IDX} ${SF_SELECTED}
		${ElseIf} "${OP_SEL}" == "2"
			IntOp $0 ${SF_SELECTED} | ${SF_RO}
			SectionSetFlags ${TOOL_IDX} $0
		${ElseIf} "${OP_SEL}" == "3"
			IntOp $0 0 | ${SF_RO}
			SectionSetFlags ${TOOL_IDX} $0
		${ElseIf} "${OP_SEL}" == "4"
			IntOp $0 0 | ${SF_RO}
			SectionSetFlags ${TOOL_IDX} $0
			SectionSetText  ${TOOL_IDX} ""
		${EndIf}
	${EndIf}
!macroend

!macro GenerateSectionTool TOOL_IDX TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_PATH
Section /o "${TOOL_NAME}" ${TOOL_IDX}
	AddSize ${TOOL_SIZE_KB}
	${If} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\bin\*.exe"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.json"
	${OrIf} ${FileExists} "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.php"
		Goto SkipTool_${TOOL_ID}
	${EndIf}

	${If} $PROTOCOL == "FTP"
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip" --silent --show-error --fail'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION "${STR_MsgErrorDescargaFtp} ${TOOL_ID}$\n$R2"
			Goto SkipTool_${TOOL_ID}
		${EndIf}
	${ElseIf} $PROTOCOL == "HTTP"
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"curl.exe" -s -S -L --fail --insecure --connect-timeout 30 -C - -o "$TEMP\${TOOL_ID}.zip" "$R0"'
		Pop $R1
		Pop $R2
		${If} $R1 != "0"
			MessageBox MB_ICONEXCLAMATION \
			  "${STR_MsgErrorDescargaHttp} ${TOOL_ID}$\n${STR_CodigoRespuesta} $R1"
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
		MessageBox MB_ICONSTOP "${STR_MsgErrorDescomprimir} ${TOOL_NAME}: $R1"
		Goto SkipTool_${TOOL_ID}
	${EndIf}
	${GetSize} "$R7" "/S=0K" $R4 $R5 $R6
	IntOp $R0 $R4 - ${TOOL_SIZE_KB}
	${IfThen} $R0 < 0 ${|} IntOp $R0 0 - $R0 ${|}
	IntCmp $R0 1 0 0 Tag_Mismatch_${TOOL_ID}
	Goto Tag_OK_${TOOL_ID}
Tag_Mismatch_${TOOL_ID}:
	MessageBox MB_ICONEXCLAMATION \
		"${STR_MsgErrorTamano} ${TOOL_NAME} ($R4 KB ≠ ${TOOL_SIZE_KB} KB)"
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
	${EndIf}
	${If} ${ADD_PATH} == 1
		Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
		Call AddToEnvUserPath
	${EndIf}
SkipTool_${TOOL_ID}:
	Delete "$TEMP\${TOOL_ID}.zip"
	RMDir /r "$TEMP\${TOOL_ID}_tmp"
SectionEnd
!macroend

;------------------------------------------------------------
; CATALOGO DE HERRAMIENTAS

Function CheckIfInstalledAllTools
    !insertmacro CheckIfInstalledTool 9 "7za" 4
    !insertmacro CheckIfInstalledTool 10 "gettext" 4
    !insertmacro CheckIfInstalledTool 11 "sqlite" 4
    !insertmacro CheckIfInstalledTool 12 "mkcert" 4
    !insertmacro CheckIfInstalledTool 13 "pdftk" 4
    !insertmacro CheckIfInstalledTool 14 "pandoc" 4
    !insertmacro CheckIfInstalledTool 15 "wkhtmltopdf" 4
    !insertmacro CheckIfInstalledTool 16 "ffmpeg" 4
FunctionEnd

!macro GenerateAllSectionTools
    !insertmacro GenerateSectionTool 9 7za "CLI 7za" 466 0
    !insertmacro GenerateSectionTool 10 gettext "CLI Gettext" 6080 1
    !insertmacro GenerateSectionTool 11 sqlite "CLI SQLite" 14257 1
    !insertmacro GenerateSectionTool 12 mkcert "CLI Mkcert" 5136 0
    !insertmacro GenerateSectionTool 13 pdftk "CLI PDFtk" 9638 1
    !insertmacro GenerateSectionTool 14 pandoc "CLI Pandoc" 216722 1
    !insertmacro GenerateSectionTool 15 wkhtmltopdf "CLI Wkhtmltopdf" 88533 1
    !insertmacro GenerateSectionTool 16 ffmpeg "CLI FFmpeg" 37121 1
!macroend

!macro UninstallAllTools
    !insertmacro UninstallTool 7za
    !insertmacro UninstallTool gettext
    !insertmacro UninstallTool sqlite
    !insertmacro UninstallTool mkcert
    !insertmacro UninstallTool pdftk
    !insertmacro UninstallTool pandoc
    !insertmacro UninstallTool wkhtmltopdf
    !insertmacro UninstallTool ffmpeg
!macroend
