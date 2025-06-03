!macro UninstallTool TOOL_ID
    RMDir /r "$INSTDRIVE${TOOLS}\${TOOL_ID}"
    Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
    Call un.RemoveFromEnvUserPath
!macroend

!macro GenerateSectionTool TOOL_ID TOOL_NAME TOOL_SIZE TOOL_ADD_PATH
	!insertmacro HandleDownloadAndExtractTool ${TOOL_ID} "${TOOL_NAME}" ${TOOL_SIZE} ${TOOL_ADD_PATH}
!macroend

!macro HandleDownloadAndExtractTool TOOL_ID TOOL_NAME TOOL_SIZE_KB ADD_TO_PATH
Section /o "${TOOL_NAME}" SEC_${TOOL_ID}
    AddSize ${TOOL_SIZE_KB}
    SetOutPath "$TEMP"
	IfFileExists "$INSTDRIVE${TOOLS}\${TOOL_ID}\*.*" 0 +2
		Goto SkipTool_${TOOL_ID}
	${If} $PROTOCOL == "FTP"
		;TODO: Corregir
		StrCpy $R0 "ftp://$SERVER/herramientas/${TOOL_ID}.zip"
		nsExec::ExecToStack '"$INSTDRIVE${TOOLS}\curl.exe" -u $FTP_USER@$SERVER:$FTP_PASS "$R0" -o "$TEMP\${TOOL_ID}.zip"'
	${Else}
		StrCpy $R0 "https://$SERVER/herramientas/${TOOL_ID}.zip"
		inetc::get /TIMEOUT=30000 /RESUME "" "$R0" "$TEMP\${TOOL_ID}.zip" /END
	${EndIf}
	Pop $0
    StrCmp $0 "OK" +3
		MessageBox MB_ICONEXCLAMATION "No se pudo descargar ${TOOL_NAME} desde $R0. Puede instalarlo después."
		Return
    CreateDirectory "$INSTDRIVE${TOOLS}\${TOOL_ID}"
    SetOutPath "$INSTDRIVE${TOOLS}\${TOOL_ID}"
    Nsisunz::UnzipToLog "$TEMP\${TOOL_ID}.zip" "$INSTDRIVE${TOOLS}\${TOOL_ID}"
    Pop $0
    StrCmp $0 "success" +2
        MessageBox MB_ICONSTOP "Error al descomprimir ${TOOL_NAME}: $0"
    Delete "$TEMP\${TOOL_ID}.zip"
    ${If} ${ADD_TO_PATH} = 1
        Push "$INSTDRIVE${TOOLS}\${TOOL_ID}"
        Call AddToEnvUserPath
    ${EndIf}
SkipTool_${TOOL_ID}:
SectionEnd
!macroend

!macro CheckSelectTool TOOL_ID SEC_ID
    IfFileExists "$INSTDRIVE${TOOLS}\${TOOL_ID}\*" 0 +2
		;SectionSetFlags ${SEC_ID} ${SF_SELECTED} | ${SF_RO}
!macroend

!macro GenerateAllSectionTools
    !insertmacro GenerateSectionTool 7za "CLI: 7za" 466 1
    !insertmacro GenerateSectionTool gettext "CLI: Gettext" 6080 1
    !insertmacro GenerateSectionTool sqlite "CLI: SQLite" 14257 1
    !insertmacro GenerateSectionTool mkcert "CLI: Mkcert" 5136 0
    !insertmacro GenerateSectionTool pdftk "CLI: PDFtk" 9638 1
    !insertmacro GenerateSectionTool pandoc "CLI: Pandoc" 216722 1
    !insertmacro GenerateSectionTool wkhtmltopdf "CLI: Wkhtmltopdf" 88533 1
    !insertmacro GenerateSectionTool ffmpeg "CLI: FFmpeg" 37121 1
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

Function CheckSelectAllTools
    !insertmacro CheckSelectTool 7za SEC_7za
    !insertmacro CheckSelectTool gettext SEC_gettext
    !insertmacro CheckSelectTool sqlite SEC_sqlite
    !insertmacro CheckSelectTool mkcert SEC_mkcert
    !insertmacro CheckSelectTool pdftk SEC_pdftk
    !insertmacro CheckSelectTool pandoc SEC_pandoc
    !insertmacro CheckSelectTool wkhtmltopdf SEC_wkhtmltopdf
    !insertmacro CheckSelectTool ffmpeg SEC_ffmpeg
FunctionEnd
