;--------------------------------
; SECCIONES NUMERADAS

Section "-WriteLogInicial" 0
	Call WriteLogInicial
SectionEnd

SectionGroup /e "${TXT_SecPrograma}" 1
	Section "${NAME} (*)" 2
		DetailPrint "============================================"
		DetailPrint "*****${TXT_LogSecPrograma}*****"
		DetailPrint "============================================"
		CreateDirectory "$InstDrive$INSTDIR\compartidos"
		CreateDirectory "$InstDrive$INSTDIR\datos"
		CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
		CreateDirectory "$InstDrive$INSTDIR\logs"
		CreateDirectory "$InstDrive$INSTDIR\respaldos"
		CreateDirectory "$InstDrive${TOOLS}"
		SetOutPath "$InstDrive$INSTDIR\base"
		File /r "..\app\base\*.*"
		SetOutPath "$InstDrive$INSTDIR\img"
		File /r "..\app\img\*.*"
		SetOutPath "$InstDrive$INSTDIR"
		IfFileExists "$InstDrive$INSTDIR\${APPFILE}" +2 0
			File "..\app\${APPFILE}"
		IfFileExists "$InstDrive$INSTDIR\${README}" +2 0
			File "..\app\${README}"
		IfFileExists "$InstDrive$INSTDIR\${LICENSEFILE}" +2 0
			File /oname=LICENSE.txt "..\${LICENSEFILE}"
		SetOutPath "$InstDrive$INSTDIR\datos"
		IfFileExists "$InstDrive$INSTDIR\datos\basico_proyectos.txt" +2 0
			File /oname=basico_proyectos.txt "..\app\base\proyectos.txt"
		SetOutPath "$InstDrive$INSTDIR\entornos\basico"
		IfFileExists "$InstDrive$INSTDIR\entornos\basico\config.ini" +2 0
			File /r "..\app\base\entorno\*.*"
		SetOutPath "$InstDrive${TOOLS}"
		SetOutPath "$InstDrive$INSTDIR"
		IfFileExists "$InstDrive$INSTDIR\config.ini" +2 0
			File "config.ini"
		WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
		WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
		DetailPrint "============================================"
	SectionEnd
	!insertmacro MCreateSectionActualizaciones 3
	!insertmacro MCreateSectionActualizaciones 4
	!insertmacro MCreateSectionActualizaciones 5
	!insertmacro MCreateSectionActualizaciones 6
	!insertmacro MCreateSectionActualizaciones 7
	!insertmacro MCreateSectionActualizaciones 8
	!insertmacro MCreateSectionActualizaciones 9
	!insertmacro MCreateSectionActualizaciones 10
	!insertmacro MCreateSectionActualizaciones 11
	!insertmacro MCreateSectionActualizaciones 12
SectionGroupEnd

Section "-WriteLogRequisitos" 14
	Call WriteLogRequisitos
SectionEnd

SectionGroup /e "${TXT_GrpRequisitos}" 15
	!insertmacro MCreateSectionRequisitos 16
	!insertmacro MCreateSectionRequisitos 17
	!insertmacro MCreateSectionRequisitos 18
	!insertmacro MCreateSectionRequisitos 19
	!insertmacro MCreateSectionRequisitos 20
	!insertmacro MCreateSectionRequisitos 21
	!insertmacro MCreateSectionRequisitos 22
	!insertmacro MCreateSectionRequisitos 23
	!insertmacro MCreateSectionRequisitos 24
	!insertmacro MCreateSectionRequisitos 25
SectionGroupEnd

Section "-WriteLogComplementos" 27
	Call WriteLogComplementos
SectionEnd

SectionGroup "${TXT_GrpComplementos}" 28
	!insertmacro MCreateSectionComplementos 29
	!insertmacro MCreateSectionComplementos 30
	!insertmacro MCreateSectionComplementos 31
	!insertmacro MCreateSectionComplementos 32
	!insertmacro MCreateSectionComplementos 33
	!insertmacro MCreateSectionComplementos 34
	!insertmacro MCreateSectionComplementos 35
	!insertmacro MCreateSectionComplementos 36
	!insertmacro MCreateSectionComplementos 37
	!insertmacro MCreateSectionComplementos 38
	!insertmacro MCreateSectionComplementos 39
	!insertmacro MCreateSectionComplementos 40
	!insertmacro MCreateSectionComplementos 41
	!insertmacro MCreateSectionComplementos 42
	!insertmacro MCreateSectionComplementos 43
	!insertmacro MCreateSectionComplementos 44
	!insertmacro MCreateSectionComplementos 45
	!insertmacro MCreateSectionComplementos 46
	!insertmacro MCreateSectionComplementos 47
	!insertmacro MCreateSectionComplementos 48
	!insertmacro MCreateSectionComplementos 49
	!insertmacro MCreateSectionComplementos 50
	!insertmacro MCreateSectionComplementos 51
	!insertmacro MCreateSectionComplementos 52
	!insertmacro MCreateSectionComplementos 53
	!insertmacro MCreateSectionComplementos 54
	!insertmacro MCreateSectionComplementos 55
	!insertmacro MCreateSectionComplementos 56
	!insertmacro MCreateSectionComplementos 57
	!insertmacro MCreateSectionComplementos 58
SectionGroupEnd

Section "-WriteLogExtensiones" 60
	Call WriteLogExtensiones
SectionEnd

SectionGroup "${TXT_GrpExtensiones}" 61
	!insertmacro MCreateSectionExtensiones 62
	!insertmacro MCreateSectionExtensiones 63
	!insertmacro MCreateSectionExtensiones 64
	!insertmacro MCreateSectionExtensiones 65
	!insertmacro MCreateSectionExtensiones 66
	!insertmacro MCreateSectionExtensiones 67
	!insertmacro MCreateSectionExtensiones 68
	!insertmacro MCreateSectionExtensiones 69
	!insertmacro MCreateSectionExtensiones 70
	!insertmacro MCreateSectionExtensiones 71
	!insertmacro MCreateSectionExtensiones 72
	!insertmacro MCreateSectionExtensiones 73
	!insertmacro MCreateSectionExtensiones 74
	!insertmacro MCreateSectionExtensiones 75
	!insertmacro MCreateSectionExtensiones 76
	!insertmacro MCreateSectionExtensiones 77
	!insertmacro MCreateSectionExtensiones 78
	!insertmacro MCreateSectionExtensiones 79
	!insertmacro MCreateSectionExtensiones 80
	!insertmacro MCreateSectionExtensiones 81
SectionGroupEnd

Section "-WriteLogRecursos" 83
	Call WriteLogRecursos
SectionEnd

SectionGroup "${TXT_GrpRecursos}" 84
	!insertmacro MCreateSectionRecursos 85
	!insertmacro MCreateSectionRecursos 86
	!insertmacro MCreateSectionRecursos 87
	!insertmacro MCreateSectionRecursos 88
	!insertmacro MCreateSectionRecursos 89
	!insertmacro MCreateSectionRecursos 90
	!insertmacro MCreateSectionRecursos 91
	!insertmacro MCreateSectionRecursos 92
	!insertmacro MCreateSectionRecursos 93
	!insertmacro MCreateSectionRecursos 94
	!insertmacro MCreateSectionRecursos 95
	!insertmacro MCreateSectionRecursos 96
	!insertmacro MCreateSectionRecursos 97
	!insertmacro MCreateSectionRecursos 98
	!insertmacro MCreateSectionRecursos 99
	!insertmacro MCreateSectionRecursos 100
	!insertmacro MCreateSectionRecursos 101
	!insertmacro MCreateSectionRecursos 102
	!insertmacro MCreateSectionRecursos 103
	!insertmacro MCreateSectionRecursos 104
	!insertmacro MCreateSectionRecursos 105
	!insertmacro MCreateSectionRecursos 106
	!insertmacro MCreateSectionRecursos 107
	!insertmacro MCreateSectionRecursos 108
	!insertmacro MCreateSectionRecursos 109
	!insertmacro MCreateSectionRecursos 110
	!insertmacro MCreateSectionRecursos 111
	!insertmacro MCreateSectionRecursos 112
	!insertmacro MCreateSectionRecursos 113
	!insertmacro MCreateSectionRecursos 114
SectionGroupEnd

Section "-WriteLogConfig" 116
	Call WriteLogConfig
SectionEnd

Section "-Config" 117
	${GetSize} "$InstDrive\home" "/S=0K" $1 $R7 $R8
	DetailPrint "$1 KB"
	IntFmt $1 "0x%08X" $1
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$1"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$InstDrive"
	WriteRegStr HKCU "Software\${NAME}" "Server" "$Server"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$Protocol"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
	WriteRegStr HKCU "Software\${NAME}" "VendorPath" "$InstDrive${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "ToolsPath" "$InstDrive${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	WriteRegStr HKCU "Software\${NAME}" "Installer" "$EXEPATH"
	${If} $RememberCreds == "1"
		WriteRegStr HKCU "Software\${NAME}" "FtpUser" "$FtpUser"
		WriteRegStr HKCU "Software\${NAME}" "FtpPass" "$FtpPass"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "FtpUser"
		DeleteRegValue HKCU "Software\${NAME}" "FtpPass"
	${EndIf}
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$InstDrive$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALL}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	StrCpy $FtpUser ""
	StrCpy $FtpPass ""
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALL}"
	DetailPrint "${TXT_LogCreateShortCut}"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
SectionEnd

Section "-WriteLogFinal" 118
	Call WriteLogFinal
SectionEnd
