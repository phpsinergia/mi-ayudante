;--------------------------------
; SECCIONES NUMERADAS

Section "-WriteLogInicial" 0
	Call WriteLogInicial
SectionEnd

Section "${NAME} (*)" 1
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
		File "componentes.ini"
	WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
	WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
SectionEnd

Section "-WriteLogActualizaciones" 2
	Call WriteLogActualizaciones
SectionEnd

SectionGroup /e "$(TXT_GrpActualizaciones)" 3
	!insertmacro MCreateSectionComponent "Actualizaciones" 4
	!insertmacro MCreateSectionComponent "Actualizaciones" 5
	!insertmacro MCreateSectionComponent "Actualizaciones" 6
	!insertmacro MCreateSectionComponent "Actualizaciones" 7
	!insertmacro MCreateSectionComponent "Actualizaciones" 8
	!insertmacro MCreateSectionComponent "Actualizaciones" 9
	!insertmacro MCreateSectionComponent "Actualizaciones" 10
	!insertmacro MCreateSectionComponent "Actualizaciones" 11
	!insertmacro MCreateSectionComponent "Actualizaciones" 12
	!insertmacro MCreateSectionComponent "Actualizaciones" 13
	!insertmacro MCreateSectionComponent "Actualizaciones" 14
	!insertmacro MCreateSectionComponent "Actualizaciones" 15
	!insertmacro MCreateSectionComponent "Actualizaciones" 16
	!insertmacro MCreateSectionComponent "Actualizaciones" 17
	!insertmacro MCreateSectionComponent "Actualizaciones" 18
	!insertmacro MCreateSectionComponent "Actualizaciones" 19
	!insertmacro MCreateSectionComponent "Actualizaciones" 20
	!insertmacro MCreateSectionComponent "Actualizaciones" 21
	!insertmacro MCreateSectionComponent "Actualizaciones" 22
	!insertmacro MCreateSectionComponent "Actualizaciones" 23
SectionGroupEnd ;24

Section "-WriteLogRequisitos" 25
	Call WriteLogRequisitos
SectionEnd

SectionGroup /e "$(TXT_GrpRequisitos)" 26
	!insertmacro MCreateSectionComponent "Requisitos" 27
	!insertmacro MCreateSectionComponent "Requisitos" 28
	!insertmacro MCreateSectionComponent "Requisitos" 29
	!insertmacro MCreateSectionComponent "Requisitos" 30
	!insertmacro MCreateSectionComponent "Requisitos" 31
	!insertmacro MCreateSectionComponent "Requisitos" 32
	!insertmacro MCreateSectionComponent "Requisitos" 33
	!insertmacro MCreateSectionComponent "Requisitos" 34
	!insertmacro MCreateSectionComponent "Requisitos" 35
	!insertmacro MCreateSectionComponent "Requisitos" 36
	!insertmacro MCreateSectionComponent "Requisitos" 37
	!insertmacro MCreateSectionComponent "Requisitos" 38
	!insertmacro MCreateSectionComponent "Requisitos" 39
	!insertmacro MCreateSectionComponent "Requisitos" 40
	!insertmacro MCreateSectionComponent "Requisitos" 41
	!insertmacro MCreateSectionComponent "Requisitos" 42
	!insertmacro MCreateSectionComponent "Requisitos" 43
	!insertmacro MCreateSectionComponent "Requisitos" 44
	!insertmacro MCreateSectionComponent "Requisitos" 45
	!insertmacro MCreateSectionComponent "Requisitos" 46
SectionGroupEnd ;47

Section "-WriteLogComplementos" 48
	Call WriteLogComplementos
SectionEnd

SectionGroup "$(TXT_GrpComplementos)" 49
	!insertmacro MCreateSectionComponent "Complementos" 50
	!insertmacro MCreateSectionComponent "Complementos" 51
	!insertmacro MCreateSectionComponent "Complementos" 52
	!insertmacro MCreateSectionComponent "Complementos" 53
	!insertmacro MCreateSectionComponent "Complementos" 54
	!insertmacro MCreateSectionComponent "Complementos" 55
	!insertmacro MCreateSectionComponent "Complementos" 56
	!insertmacro MCreateSectionComponent "Complementos" 57
	!insertmacro MCreateSectionComponent "Complementos" 58
	!insertmacro MCreateSectionComponent "Complementos" 59
	!insertmacro MCreateSectionComponent "Complementos" 60
	!insertmacro MCreateSectionComponent "Complementos" 61
	!insertmacro MCreateSectionComponent "Complementos" 62
	!insertmacro MCreateSectionComponent "Complementos" 63
	!insertmacro MCreateSectionComponent "Complementos" 64
	!insertmacro MCreateSectionComponent "Complementos" 65
	!insertmacro MCreateSectionComponent "Complementos" 66
	!insertmacro MCreateSectionComponent "Complementos" 67
	!insertmacro MCreateSectionComponent "Complementos" 68
	!insertmacro MCreateSectionComponent "Complementos" 69
SectionGroupEnd ;70

Section "-WriteLogExtensiones" 71
	Call WriteLogExtensiones
SectionEnd

SectionGroup "$(TXT_GrpExtensiones)" 72
	!insertmacro MCreateSectionComponent "Extensiones" 73
	!insertmacro MCreateSectionComponent "Extensiones" 74
	!insertmacro MCreateSectionComponent "Extensiones" 75
	!insertmacro MCreateSectionComponent "Extensiones" 76
	!insertmacro MCreateSectionComponent "Extensiones" 77
	!insertmacro MCreateSectionComponent "Extensiones" 78
	!insertmacro MCreateSectionComponent "Extensiones" 79
	!insertmacro MCreateSectionComponent "Extensiones" 80
	!insertmacro MCreateSectionComponent "Extensiones" 81
	!insertmacro MCreateSectionComponent "Extensiones" 82
	!insertmacro MCreateSectionComponent "Extensiones" 83
	!insertmacro MCreateSectionComponent "Extensiones" 84
	!insertmacro MCreateSectionComponent "Extensiones" 85
	!insertmacro MCreateSectionComponent "Extensiones" 86
	!insertmacro MCreateSectionComponent "Extensiones" 87
	!insertmacro MCreateSectionComponent "Extensiones" 88
	!insertmacro MCreateSectionComponent "Extensiones" 89
	!insertmacro MCreateSectionComponent "Extensiones" 90
	!insertmacro MCreateSectionComponent "Extensiones" 91
	!insertmacro MCreateSectionComponent "Extensiones" 92
SectionGroupEnd ;93

Section "-WriteLogRecursos" 94
	Call WriteLogRecursos
SectionEnd

SectionGroup "$(TXT_GrpRecursos)" 95
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
	!insertmacro MCreateSectionComponent "Recursos" 115
SectionGroupEnd ;116

Section "-WriteLogConfig" 117
	Call WriteLogConfig
SectionEnd

Section "-Config" 118
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

Section "-WriteLogFinal" 119
	Call WriteLogFinal
SectionEnd
