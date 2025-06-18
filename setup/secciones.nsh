;--------------------------------
; SECCIONES NUMERADAS

Section "-WriteLogInicial" 0
	Call WriteLogInicial
SectionEnd

SectionGroup /e "$(TXT_SecPrograma)" 1
	Section "${NAME} (*)" 2
		Call WriteLogPrograma
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
	SectionEnd
	!insertmacro MCreateSectionComponent "Actualizaciones" 3
	!insertmacro MCreateSectionComponent "Actualizaciones" 4
	!insertmacro MCreateSectionComponent "Actualizaciones" 5
	!insertmacro MCreateSectionComponent "Actualizaciones" 6
	!insertmacro MCreateSectionComponent "Actualizaciones" 7
	!insertmacro MCreateSectionComponent "Actualizaciones" 8
	!insertmacro MCreateSectionComponent "Actualizaciones" 9
	!insertmacro MCreateSectionComponent "Actualizaciones" 10
	!insertmacro MCreateSectionComponent "Actualizaciones" 11
	!insertmacro MCreateSectionComponent "Actualizaciones" 12
SectionGroupEnd

Section "-WriteLogRequisitos" 14
	Call WriteLogRequisitos
SectionEnd

SectionGroup /e "$(TXT_GrpRequisitos)" 15
	!insertmacro MCreateSectionComponent "Requisitos" 16
	!insertmacro MCreateSectionComponent "Requisitos" 17
	!insertmacro MCreateSectionComponent "Requisitos" 18
	!insertmacro MCreateSectionComponent "Requisitos" 19
	!insertmacro MCreateSectionComponent "Requisitos" 20
	!insertmacro MCreateSectionComponent "Requisitos" 21
	!insertmacro MCreateSectionComponent "Requisitos" 22
	!insertmacro MCreateSectionComponent "Requisitos" 23
	!insertmacro MCreateSectionComponent "Requisitos" 24
	!insertmacro MCreateSectionComponent "Requisitos" 25
SectionGroupEnd

Section "-WriteLogComplementos" 27
	Call WriteLogComplementos
SectionEnd

SectionGroup "$(TXT_GrpComplementos)" 28
	!insertmacro MCreateSectionComponent "Complementos" 29
	!insertmacro MCreateSectionComponent "Complementos" 30
	!insertmacro MCreateSectionComponent "Complementos" 31
	!insertmacro MCreateSectionComponent "Complementos" 32
	!insertmacro MCreateSectionComponent "Complementos" 33
	!insertmacro MCreateSectionComponent "Complementos" 34
	!insertmacro MCreateSectionComponent "Complementos" 35
	!insertmacro MCreateSectionComponent "Complementos" 36
	!insertmacro MCreateSectionComponent "Complementos" 37
	!insertmacro MCreateSectionComponent "Complementos" 38
	!insertmacro MCreateSectionComponent "Complementos" 39
	!insertmacro MCreateSectionComponent "Complementos" 40
	!insertmacro MCreateSectionComponent "Complementos" 41
	!insertmacro MCreateSectionComponent "Complementos" 42
	!insertmacro MCreateSectionComponent "Complementos" 43
	!insertmacro MCreateSectionComponent "Complementos" 44
	!insertmacro MCreateSectionComponent "Complementos" 45
	!insertmacro MCreateSectionComponent "Complementos" 46
	!insertmacro MCreateSectionComponent "Complementos" 47
	!insertmacro MCreateSectionComponent "Complementos" 48
	!insertmacro MCreateSectionComponent "Complementos" 49
	!insertmacro MCreateSectionComponent "Complementos" 50
	!insertmacro MCreateSectionComponent "Complementos" 51
	!insertmacro MCreateSectionComponent "Complementos" 52
	!insertmacro MCreateSectionComponent "Complementos" 53
	!insertmacro MCreateSectionComponent "Complementos" 54
	!insertmacro MCreateSectionComponent "Complementos" 55
	!insertmacro MCreateSectionComponent "Complementos" 56
	!insertmacro MCreateSectionComponent "Complementos" 57
	!insertmacro MCreateSectionComponent "Complementos" 58
SectionGroupEnd

Section "-WriteLogExtensiones" 60
	Call WriteLogExtensiones
SectionEnd

SectionGroup "$(TXT_GrpExtensiones)" 61
	!insertmacro MCreateSectionComponent "Extensiones" 62
	!insertmacro MCreateSectionComponent "Extensiones" 63
	!insertmacro MCreateSectionComponent "Extensiones" 64
	!insertmacro MCreateSectionComponent "Extensiones" 65
	!insertmacro MCreateSectionComponent "Extensiones" 66
	!insertmacro MCreateSectionComponent "Extensiones" 67
	!insertmacro MCreateSectionComponent "Extensiones" 68
	!insertmacro MCreateSectionComponent "Extensiones" 69
	!insertmacro MCreateSectionComponent "Extensiones" 70
	!insertmacro MCreateSectionComponent "Extensiones" 71
	!insertmacro MCreateSectionComponent "Extensiones" 72
	!insertmacro MCreateSectionComponent "Extensiones" 73
	!insertmacro MCreateSectionComponent "Extensiones" 74
	!insertmacro MCreateSectionComponent "Extensiones" 75
	!insertmacro MCreateSectionComponent "Extensiones" 76
	!insertmacro MCreateSectionComponent "Extensiones" 77
	!insertmacro MCreateSectionComponent "Extensiones" 78
	!insertmacro MCreateSectionComponent "Extensiones" 79
	!insertmacro MCreateSectionComponent "Extensiones" 80
	!insertmacro MCreateSectionComponent "Extensiones" 81
SectionGroupEnd

Section "-WriteLogRecursos" 83
	Call WriteLogRecursos
SectionEnd

SectionGroup "$(TXT_GrpRecursos)" 84
	!insertmacro MCreateSectionComponent "Recursos" 85
	!insertmacro MCreateSectionComponent "Recursos" 86
	!insertmacro MCreateSectionComponent "Recursos" 87
	!insertmacro MCreateSectionComponent "Recursos" 88
	!insertmacro MCreateSectionComponent "Recursos" 89
	!insertmacro MCreateSectionComponent "Recursos" 90
	!insertmacro MCreateSectionComponent "Recursos" 91
	!insertmacro MCreateSectionComponent "Recursos" 92
	!insertmacro MCreateSectionComponent "Recursos" 93
	!insertmacro MCreateSectionComponent "Recursos" 94
	!insertmacro MCreateSectionComponent "Recursos" 95
	!insertmacro MCreateSectionComponent "Recursos" 96
	!insertmacro MCreateSectionComponent "Recursos" 97
	!insertmacro MCreateSectionComponent "Recursos" 98
	!insertmacro MCreateSectionComponent "Recursos" 99
	!insertmacro MCreateSectionComponent "Recursos" 100
	!insertmacro MCreateSectionComponent "Recursos" 101
	!insertmacro MCreateSectionComponent "Recursos" 102
	!insertmacro MCreateSectionComponent "Recursos" 103
	!insertmacro MCreateSectionComponent "Recursos" 104
	!insertmacro MCreateSectionComponent "Recursos" 105
	!insertmacro MCreateSectionComponent "Recursos" 106
	!insertmacro MCreateSectionComponent "Recursos" 107
	!insertmacro MCreateSectionComponent "Recursos" 108
	!insertmacro MCreateSectionComponent "Recursos" 109
	!insertmacro MCreateSectionComponent "Recursos" 110
	!insertmacro MCreateSectionComponent "Recursos" 111
	!insertmacro MCreateSectionComponent "Recursos" 112
	!insertmacro MCreateSectionComponent "Recursos" 113
	!insertmacro MCreateSectionComponent "Recursos" 114
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
	DetailPrint "$(TXT_LogCreateShortCut)"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\Actualizar.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
SectionEnd

Section "-WriteLogFinal" 118
	Call WriteLogFinal
SectionEnd
