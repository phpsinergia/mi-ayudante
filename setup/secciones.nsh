;--------------------------------
; SECCIONES NUMERADAS

Section "-Inicial" 0
	Call WriteLogInicial
SectionEnd

Section "!${NAME} (*)" 1
	Call WriteLogPrograma
	CreateDirectory "$InstDrive$INSTDIR\compartidos"
	CreateDirectory "$InstDrive$INSTDIR\datos"
	CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
	CreateDirectory "$InstDrive$INSTDIR\logs"
	CreateDirectory "$InstDrive$INSTDIR\respaldos"
	CreateDirectory "$InstDrive$INSTDIR\extensiones"
	CreateDirectory "$InstDrive${TOOLS}"
	CreateDirectory "$InstDrive${RESOURCES}"
	CreateDirectory "$InstDrive${VENDOR}"
	SetOutPath "$InstDrive$INSTDIR\base"
	File /r "..\app\base\*.*"
	SetOutPath "$InstDrive$INSTDIR\img"
	File /r "..\app\img\*.*"
	SetOutPath "$InstDrive$INSTDIR"
	IfFileExists "$InstDrive$INSTDIR\${APPFILE}" +2 0
		File "..\app\${APPFILE}"
	IfFileExists "$InstDrive$INSTDIR\${READMEFILE}" +2 0
		File "..\app\${READMEFILE}"
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
SectionEnd

Section "-" 2
	Push "ACTUALIZACIONES"
	Call WriteLogSection
SectionEnd

SectionGroup /e "Actualizaciones" 3
	!insertmacro MCreateFunctionsComponent "Actualizaciones"
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 4
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 5
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 6
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 7
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 8
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 9
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 10
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 11
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 12
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 13
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 14
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 15
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 16
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 17
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 18
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 19
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 20
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 21
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 22
	!insertmacro MCreateSectionComponent "Actualizaciones" 3 23
SectionGroupEnd ;24

Section "-" 25
	Push "REQUISITOS"
	Call WriteLogSection
SectionEnd

SectionGroup /e "Requisitos" 26
	!insertmacro MCreateFunctionsComponent "Requisitos"
	!insertmacro MCreateSectionComponent "Requisitos" 26 27
	!insertmacro MCreateSectionComponent "Requisitos" 26 28
	!insertmacro MCreateSectionComponent "Requisitos" 26 29
	!insertmacro MCreateSectionComponent "Requisitos" 26 30
	!insertmacro MCreateSectionComponent "Requisitos" 26 31
	!insertmacro MCreateSectionComponent "Requisitos" 26 32
	!insertmacro MCreateSectionComponent "Requisitos" 26 33
	!insertmacro MCreateSectionComponent "Requisitos" 26 34
	!insertmacro MCreateSectionComponent "Requisitos" 26 35
	!insertmacro MCreateSectionComponent "Requisitos" 26 36
	!insertmacro MCreateSectionComponent "Requisitos" 26 37
	!insertmacro MCreateSectionComponent "Requisitos" 26 38
	!insertmacro MCreateSectionComponent "Requisitos" 26 39
	!insertmacro MCreateSectionComponent "Requisitos" 26 40
	!insertmacro MCreateSectionComponent "Requisitos" 26 41
	!insertmacro MCreateSectionComponent "Requisitos" 26 42
	!insertmacro MCreateSectionComponent "Requisitos" 26 43
	!insertmacro MCreateSectionComponent "Requisitos" 26 44
	!insertmacro MCreateSectionComponent "Requisitos" 26 45
	!insertmacro MCreateSectionComponent "Requisitos" 26 46
SectionGroupEnd ;47

Section "-" 48
	Push "COMPLEMENTOS"
	Call WriteLogSection
SectionEnd

SectionGroup "Complementos" 49
	!insertmacro MCreateFunctionsComponent "Complementos"
	!insertmacro MCreateSectionComponent "Complementos" 49 50
	!insertmacro MCreateSectionComponent "Complementos" 49 51
	!insertmacro MCreateSectionComponent "Complementos" 49 52
	!insertmacro MCreateSectionComponent "Complementos" 49 53
	!insertmacro MCreateSectionComponent "Complementos" 49 54
	!insertmacro MCreateSectionComponent "Complementos" 49 55
	!insertmacro MCreateSectionComponent "Complementos" 49 56
	!insertmacro MCreateSectionComponent "Complementos" 49 57
	!insertmacro MCreateSectionComponent "Complementos" 49 58
	!insertmacro MCreateSectionComponent "Complementos" 49 59
	!insertmacro MCreateSectionComponent "Complementos" 49 60
	!insertmacro MCreateSectionComponent "Complementos" 49 61
	!insertmacro MCreateSectionComponent "Complementos" 49 62
	!insertmacro MCreateSectionComponent "Complementos" 49 63
	!insertmacro MCreateSectionComponent "Complementos" 49 64
	!insertmacro MCreateSectionComponent "Complementos" 49 65
	!insertmacro MCreateSectionComponent "Complementos" 49 66
	!insertmacro MCreateSectionComponent "Complementos" 49 67
	!insertmacro MCreateSectionComponent "Complementos" 49 68
	!insertmacro MCreateSectionComponent "Complementos" 49 69
SectionGroupEnd ;70

Section "-" 71
	Push "EXTENSIONES"
	Call WriteLogSection
SectionEnd

SectionGroup "Extensiones" 72
	!insertmacro MCreateFunctionsComponent "Extensiones"
	!insertmacro MCreateSectionComponent "Extensiones" 72 73
	!insertmacro MCreateSectionComponent "Extensiones" 72 74
	!insertmacro MCreateSectionComponent "Extensiones" 72 75
	!insertmacro MCreateSectionComponent "Extensiones" 72 76
	!insertmacro MCreateSectionComponent "Extensiones" 72 77
	!insertmacro MCreateSectionComponent "Extensiones" 72 78
	!insertmacro MCreateSectionComponent "Extensiones" 72 79
	!insertmacro MCreateSectionComponent "Extensiones" 72 80
	!insertmacro MCreateSectionComponent "Extensiones" 72 81
	!insertmacro MCreateSectionComponent "Extensiones" 72 82
	!insertmacro MCreateSectionComponent "Extensiones" 72 83
	!insertmacro MCreateSectionComponent "Extensiones" 72 84
	!insertmacro MCreateSectionComponent "Extensiones" 72 85
	!insertmacro MCreateSectionComponent "Extensiones" 72 86
	!insertmacro MCreateSectionComponent "Extensiones" 72 87
	!insertmacro MCreateSectionComponent "Extensiones" 72 88
	!insertmacro MCreateSectionComponent "Extensiones" 72 89
	!insertmacro MCreateSectionComponent "Extensiones" 72 90
	!insertmacro MCreateSectionComponent "Extensiones" 72 91
	!insertmacro MCreateSectionComponent "Extensiones" 72 92
SectionGroupEnd ;93

Section "-" 94
	Push "RECURSOS"
	Call WriteLogSection
SectionEnd

SectionGroup "Recursos" 95
	!insertmacro MCreateFunctionsComponent "Recursos"
	!insertmacro MCreateSectionComponent "Recursos" 95 96
	!insertmacro MCreateSectionComponent "Recursos" 95 97
	!insertmacro MCreateSectionComponent "Recursos" 95 98
	!insertmacro MCreateSectionComponent "Recursos" 95 99
	!insertmacro MCreateSectionComponent "Recursos" 95 100
	!insertmacro MCreateSectionComponent "Recursos" 95 101
	!insertmacro MCreateSectionComponent "Recursos" 95 102
	!insertmacro MCreateSectionComponent "Recursos" 95 103
	!insertmacro MCreateSectionComponent "Recursos" 95 104
	!insertmacro MCreateSectionComponent "Recursos" 95 105
	!insertmacro MCreateSectionComponent "Recursos" 95 106
	!insertmacro MCreateSectionComponent "Recursos" 95 107
	!insertmacro MCreateSectionComponent "Recursos" 95 108
	!insertmacro MCreateSectionComponent "Recursos" 95 109
	!insertmacro MCreateSectionComponent "Recursos" 95 110
	!insertmacro MCreateSectionComponent "Recursos" 95 111
	!insertmacro MCreateSectionComponent "Recursos" 95 112
	!insertmacro MCreateSectionComponent "Recursos" 95 113
	!insertmacro MCreateSectionComponent "Recursos" 95 114
	!insertmacro MCreateSectionComponent "Recursos" 95 115
SectionGroupEnd ;116

Section "-" 117
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
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALLER}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteINIStr $InstDrive$INSTDIR\config.ini Base RutaHerramientas $InstDrive${TOOLS}
	WriteINIStr $InstDrive$INSTDIR\config.ini Base Lanzamiento $Version
	StrCpy $FtpUser ""
	StrCpy $FtpPass ""
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALLER}"
	DetailPrint "$(TXT_LogCreateShortCut)"
	CreateDirectory "$SMPROGRAMS\${NAME}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
SectionEnd

Section "-Final" 119
	Call WriteLogFinal
SectionEnd
