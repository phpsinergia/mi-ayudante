; secciones.nsh
;================================
; MODULO: SECCIONES INSTALADOR
;================================

Section "-Inicial" 0
	Call WriteLogInicial
SectionEnd

Section "${NAME} (*)" 1
	Call WriteLogBase
	SetOutPath "$InstDrive$INSTDIR"
	File "..\app\${ICON}"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${APPFILE}"
		File "..\app\${APPFILE}"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${READMEFILE}"
		File "..\app\${READMEFILE}"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\${LICENSEFILE}"
		File /oname=LICENSE.txt "..\${LICENSEFILE}"
	${EndIf}
	CreateDirectory "$InstDrive$INSTDIR\compartidos"
	CreateDirectory "$InstDrive$INSTDIR\datos"
	CreateDirectory "$InstDrive$INSTDIR\entornos\basico"
	CreateDirectory "$InstDrive$INSTDIR\logs"
	CreateDirectory "$InstDrive$INSTDIR\respaldos"
	CreateDirectory "$InstDrive$INSTDIR\extensiones"
	CreateDirectory "$InstDrive${TOOLS}"
	CreateDirectory "$InstDrive${VENDOR}"
	CreateDirectory "${RESOURCES}"
	CreateDirectory "${APPDATA}"
	SetOutPath "$InstDrive$INSTDIR\base"
	File /r "..\app\base\*.*"
	SetOutPath "$InstDrive$INSTDIR\img"
	File /r "..\app\img\*.*"
	SetOutPath "$InstDrive$INSTDIR\datos"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\datos\basico_proyectos.txt"
		File /oname=basico_proyectos.txt "..\app\base\proyectos.txt"
	${EndIf}
	SetOutPath "$InstDrive$INSTDIR\entornos\basico"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\entornos\basico\config.ini"
		File /r "..\app\base\entorno\*.*"
	${EndIf}
	SetOutPath "$InstDrive$INSTDIR"
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\config.ini"
		File "config.ini"
	${EndIf}
	${IfNot} ${FileExists} "$InstDrive$INSTDIR\componentes.ini"
		File "componentes.ini"
	${EndIf}
SectionEnd ;2

!insertmacro MCreateSectionLog 2 3

SectionGroup /e "-" 3 ;CATEGORIA 0
	!insertmacro MCreateFunctionsComponent "0"
	!insertmacro MCreateSectionComponent "0" 3 4 ;Reservado para SEC_RELEASE
	!insertmacro MCreateSectionComponent "0" 3 5
	!insertmacro MCreateSectionComponent "0" 3 6
	!insertmacro MCreateSectionComponent "0" 3 7
	!insertmacro MCreateSectionComponent "0" 3 8
	!insertmacro MCreateSectionComponent "0" 3 9
	!insertmacro MCreateSectionComponent "0" 3 10
	!insertmacro MCreateSectionComponent "0" 3 11
	!insertmacro MCreateSectionComponent "0" 3 12
	!insertmacro MCreateSectionComponent "0" 3 13
	!insertmacro MCreateSectionComponent "0" 3 14
	!insertmacro MCreateSectionComponent "0" 3 15
	!insertmacro MCreateSectionComponent "0" 3 16
	!insertmacro MCreateSectionComponent "0" 3 17
	!insertmacro MCreateSectionComponent "0" 3 18
	!insertmacro MCreateSectionComponent "0" 3 19
	!insertmacro MCreateSectionComponent "0" 3 20
	!insertmacro MCreateSectionComponent "0" 3 21
	!insertmacro MCreateSectionComponent "0" 3 22
	!insertmacro MCreateSectionComponent "0" 3 23
SectionGroupEnd ;24

!insertmacro MCreateSectionLog 25 26

SectionGroup /e "-" 26 ;CATEGORIA 1
	!insertmacro MCreateFunctionsComponent "1"
	!insertmacro MCreateSectionComponent "1" 26 27 ;Reservado para SEC_PHP
	!insertmacro MCreateSectionComponent "1" 26 28
	!insertmacro MCreateSectionComponent "1" 26 29
	!insertmacro MCreateSectionComponent "1" 26 30
	!insertmacro MCreateSectionComponent "1" 26 31
	!insertmacro MCreateSectionComponent "1" 26 32
	!insertmacro MCreateSectionComponent "1" 26 33
	!insertmacro MCreateSectionComponent "1" 26 34
	!insertmacro MCreateSectionComponent "1" 26 35
	!insertmacro MCreateSectionComponent "1" 26 36
	!insertmacro MCreateSectionComponent "1" 26 37
	!insertmacro MCreateSectionComponent "1" 26 38
	!insertmacro MCreateSectionComponent "1" 26 39
	!insertmacro MCreateSectionComponent "1" 26 40
	!insertmacro MCreateSectionComponent "1" 26 41
	!insertmacro MCreateSectionComponent "1" 26 42
	!insertmacro MCreateSectionComponent "1" 26 43
	!insertmacro MCreateSectionComponent "1" 26 44
	!insertmacro MCreateSectionComponent "1" 26 45
	!insertmacro MCreateSectionComponent "1" 26 46
SectionGroupEnd ;47

!insertmacro MCreateSectionLog 48 49

SectionGroup "-" 49 ;CATEGORIA 2
	!insertmacro MCreateFunctionsComponent "2"
	!insertmacro MCreateSectionComponent "2" 49 50
	!insertmacro MCreateSectionComponent "2" 49 51
	!insertmacro MCreateSectionComponent "2" 49 52
	!insertmacro MCreateSectionComponent "2" 49 53
	!insertmacro MCreateSectionComponent "2" 49 54
	!insertmacro MCreateSectionComponent "2" 49 55
	!insertmacro MCreateSectionComponent "2" 49 56
	!insertmacro MCreateSectionComponent "2" 49 57
	!insertmacro MCreateSectionComponent "2" 49 58
	!insertmacro MCreateSectionComponent "2" 49 59
	!insertmacro MCreateSectionComponent "2" 49 60
	!insertmacro MCreateSectionComponent "2" 49 61
	!insertmacro MCreateSectionComponent "2" 49 62
	!insertmacro MCreateSectionComponent "2" 49 63
	!insertmacro MCreateSectionComponent "2" 49 64
	!insertmacro MCreateSectionComponent "2" 49 65
	!insertmacro MCreateSectionComponent "2" 49 66
	!insertmacro MCreateSectionComponent "2" 49 67
	!insertmacro MCreateSectionComponent "2" 49 68
	!insertmacro MCreateSectionComponent "2" 49 69
SectionGroupEnd ;70

!insertmacro MCreateSectionLog 71 72

SectionGroup "-" 72 ;CATEGORIA 3
	!insertmacro MCreateFunctionsComponent "3"
	!insertmacro MCreateSectionComponent "3" 72 73
	!insertmacro MCreateSectionComponent "3" 72 74
	!insertmacro MCreateSectionComponent "3" 72 75
	!insertmacro MCreateSectionComponent "3" 72 76
	!insertmacro MCreateSectionComponent "3" 72 77
	!insertmacro MCreateSectionComponent "3" 72 78
	!insertmacro MCreateSectionComponent "3" 72 79
	!insertmacro MCreateSectionComponent "3" 72 80
	!insertmacro MCreateSectionComponent "3" 72 81
	!insertmacro MCreateSectionComponent "3" 72 82
	!insertmacro MCreateSectionComponent "3" 72 83
	!insertmacro MCreateSectionComponent "3" 72 84
	!insertmacro MCreateSectionComponent "3" 72 85
	!insertmacro MCreateSectionComponent "3" 72 86
	!insertmacro MCreateSectionComponent "3" 72 87
	!insertmacro MCreateSectionComponent "3" 72 88
	!insertmacro MCreateSectionComponent "3" 72 89
	!insertmacro MCreateSectionComponent "3" 72 90
	!insertmacro MCreateSectionComponent "3" 72 91
	!insertmacro MCreateSectionComponent "3" 72 92
SectionGroupEnd ;93

!insertmacro MCreateSectionLog 94 95

SectionGroup "-" 95 ;CATEGORIA 4
	!insertmacro MCreateFunctionsComponent "4"
	!insertmacro MCreateSectionComponent "4" 95 96
	!insertmacro MCreateSectionComponent "4" 95 97
	!insertmacro MCreateSectionComponent "4" 95 98
	!insertmacro MCreateSectionComponent "4" 95 99
	!insertmacro MCreateSectionComponent "4" 95 100
	!insertmacro MCreateSectionComponent "4" 95 101
	!insertmacro MCreateSectionComponent "4" 95 102
	!insertmacro MCreateSectionComponent "4" 95 103
	!insertmacro MCreateSectionComponent "4" 95 104
	!insertmacro MCreateSectionComponent "4" 95 105
	!insertmacro MCreateSectionComponent "4" 95 106
	!insertmacro MCreateSectionComponent "4" 95 107
	!insertmacro MCreateSectionComponent "4" 95 108
	!insertmacro MCreateSectionComponent "4" 95 109
	!insertmacro MCreateSectionComponent "4" 95 110
	!insertmacro MCreateSectionComponent "4" 95 111
	!insertmacro MCreateSectionComponent "4" 95 112
	!insertmacro MCreateSectionComponent "4" 95 113
	!insertmacro MCreateSectionComponent "4" 95 114
	!insertmacro MCreateSectionComponent "4" 95 115
SectionGroupEnd ;116

!insertmacro MCreateSectionLog 117 118

SectionGroup "-" 118 ;CATEGORIA 5
	!insertmacro MCreateFunctionsComponent "5"
	!insertmacro MCreateSectionComponent "5" 118 119
	!insertmacro MCreateSectionComponent "5" 118 120
	!insertmacro MCreateSectionComponent "5" 118 121
	!insertmacro MCreateSectionComponent "5" 118 122
	!insertmacro MCreateSectionComponent "5" 118 123
	!insertmacro MCreateSectionComponent "5" 118 124
	!insertmacro MCreateSectionComponent "5" 118 125
	!insertmacro MCreateSectionComponent "5" 118 126
	!insertmacro MCreateSectionComponent "5" 118 127
	!insertmacro MCreateSectionComponent "5" 118 128
	!insertmacro MCreateSectionComponent "5" 118 129
	!insertmacro MCreateSectionComponent "5" 118 130
	!insertmacro MCreateSectionComponent "5" 118 131
	!insertmacro MCreateSectionComponent "5" 118 132
	!insertmacro MCreateSectionComponent "5" 118 133
	!insertmacro MCreateSectionComponent "5" 118 134
	!insertmacro MCreateSectionComponent "5" 118 135
	!insertmacro MCreateSectionComponent "5" 118 136
	!insertmacro MCreateSectionComponent "5" 118 137
	!insertmacro MCreateSectionComponent "5" 118 138
SectionGroupEnd ;139

!insertmacro MCreateSectionLog 140 141

SectionGroup "-" 141 ;CATEGORIA 6
	!insertmacro MCreateFunctionsComponent "6"
	!insertmacro MCreateSectionComponent "6" 141 142
	!insertmacro MCreateSectionComponent "6" 141 143
	!insertmacro MCreateSectionComponent "6" 141 144
	!insertmacro MCreateSectionComponent "6" 141 145
	!insertmacro MCreateSectionComponent "6" 141 146
	!insertmacro MCreateSectionComponent "6" 141 147
	!insertmacro MCreateSectionComponent "6" 141 148
	!insertmacro MCreateSectionComponent "6" 141 149
	!insertmacro MCreateSectionComponent "6" 141 150
	!insertmacro MCreateSectionComponent "6" 141 151
	!insertmacro MCreateSectionComponent "6" 141 152
	!insertmacro MCreateSectionComponent "6" 141 153
	!insertmacro MCreateSectionComponent "6" 141 154
	!insertmacro MCreateSectionComponent "6" 141 155
	!insertmacro MCreateSectionComponent "6" 141 156
	!insertmacro MCreateSectionComponent "6" 141 157
	!insertmacro MCreateSectionComponent "6" 141 158
	!insertmacro MCreateSectionComponent "6" 141 159
	!insertmacro MCreateSectionComponent "6" 141 160
	!insertmacro MCreateSectionComponent "6" 141 161
SectionGroupEnd ;162

!insertmacro MCreateSectionLog 163 164

SectionGroup "-" 164 ;CATEGORIA 7
	!insertmacro MCreateFunctionsComponent "7"
	!insertmacro MCreateSectionComponent "7" 164 165
	!insertmacro MCreateSectionComponent "7" 164 166
	!insertmacro MCreateSectionComponent "7" 164 167
	!insertmacro MCreateSectionComponent "7" 164 168
	!insertmacro MCreateSectionComponent "7" 164 169
	!insertmacro MCreateSectionComponent "7" 164 170
	!insertmacro MCreateSectionComponent "7" 164 171
	!insertmacro MCreateSectionComponent "7" 164 172
	!insertmacro MCreateSectionComponent "7" 164 173
	!insertmacro MCreateSectionComponent "7" 164 174
	!insertmacro MCreateSectionComponent "7" 164 175
	!insertmacro MCreateSectionComponent "7" 164 176
	!insertmacro MCreateSectionComponent "7" 164 177
	!insertmacro MCreateSectionComponent "7" 164 178
	!insertmacro MCreateSectionComponent "7" 164 179
	!insertmacro MCreateSectionComponent "7" 164 180
	!insertmacro MCreateSectionComponent "7" 164 181
	!insertmacro MCreateSectionComponent "7" 164 182
	!insertmacro MCreateSectionComponent "7" 164 183
	!insertmacro MCreateSectionComponent "7" 164 184
SectionGroupEnd ;185

!insertmacro MCreateSectionLog 186 187

SectionGroup "-" 187 ;CATEGORIA 8
	!insertmacro MCreateFunctionsComponent "8"
	!insertmacro MCreateSectionComponent "8" 187 188
	!insertmacro MCreateSectionComponent "8" 187 189
	!insertmacro MCreateSectionComponent "8" 187 190
	!insertmacro MCreateSectionComponent "8" 187 191
	!insertmacro MCreateSectionComponent "8" 187 192
	!insertmacro MCreateSectionComponent "8" 187 193
	!insertmacro MCreateSectionComponent "8" 187 194
	!insertmacro MCreateSectionComponent "8" 187 195
	!insertmacro MCreateSectionComponent "8" 187 196
	!insertmacro MCreateSectionComponent "8" 187 197
	!insertmacro MCreateSectionComponent "8" 187 198
	!insertmacro MCreateSectionComponent "8" 187 199
	!insertmacro MCreateSectionComponent "8" 187 200
	!insertmacro MCreateSectionComponent "8" 187 201
	!insertmacro MCreateSectionComponent "8" 187 202
	!insertmacro MCreateSectionComponent "8" 187 203
	!insertmacro MCreateSectionComponent "8" 187 204
	!insertmacro MCreateSectionComponent "8" 187 205
	!insertmacro MCreateSectionComponent "8" 187 206
	!insertmacro MCreateSectionComponent "8" 187 207
SectionGroupEnd ;208

!insertmacro MCreateSectionLog 209 210

SectionGroup "-" 210 ;CATEGORIA 9
	!insertmacro MCreateFunctionsComponent "9"
	!insertmacro MCreateSectionComponent "9" 210 211
	!insertmacro MCreateSectionComponent "9" 210 212
	!insertmacro MCreateSectionComponent "9" 210 213
	!insertmacro MCreateSectionComponent "9" 210 214
	!insertmacro MCreateSectionComponent "9" 210 215
	!insertmacro MCreateSectionComponent "9" 210 216
	!insertmacro MCreateSectionComponent "9" 210 217
	!insertmacro MCreateSectionComponent "9" 210 218
	!insertmacro MCreateSectionComponent "9" 210 219
	!insertmacro MCreateSectionComponent "9" 210 220
	!insertmacro MCreateSectionComponent "9" 210 221
	!insertmacro MCreateSectionComponent "9" 210 222
	!insertmacro MCreateSectionComponent "9" 210 223
	!insertmacro MCreateSectionComponent "9" 210 224
	!insertmacro MCreateSectionComponent "9" 210 225
	!insertmacro MCreateSectionComponent "9" 210 226
	!insertmacro MCreateSectionComponent "9" 210 227
	!insertmacro MCreateSectionComponent "9" 210 228
	!insertmacro MCreateSectionComponent "9" 210 229
	!insertmacro MCreateSectionComponent "9" 210 230
SectionGroupEnd ;231

Section "-"
	Call WriteLogConfig
SectionEnd

Section "-Config"
	Push $R0
	Push $R1
	Push $R2
	Push $R3
	Push $R4
	StrCpy $R4 "0"
	${GetSize} "$InstDrive${VENDOR}" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	${GetSize} "$InstDrive${TOOLS}" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	${GetSize} "$InstDrive$INSTDIR" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	${GetSize} "${RESOURCES}" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	${GetSize} "${APPDATA}" "/S=0K" $R1 $R2 $R3
	IntOp $R4 $R4 + $R1
	DetailPrint "$R4 KB"
	IntFmt $R4 "0x%08X" $R4
	WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$R4"
	WriteRegStr HKCU "Software\${NAME}" "Install_Dir" "$INSTDIR"
	WriteRegStr HKCU "Software\${NAME}" "Install_Drive" "$InstDrive"
	WriteRegStr HKCU "Software\${NAME}" "Server" "$Server"
	WriteRegStr HKCU "Software\${NAME}" "Protocol" "$Protocol"
	WriteRegStr HKCU "Software\${NAME}" "SkipPrereq" "$SkipPrereq"
	WriteRegStr HKCU "Software\${NAME}" "SkipConfirm" "$SkipConfirm"
	WriteRegStr HKCU "Software\${NAME}" "VendorPath" "$InstDrive${VENDOR}"
	WriteRegStr HKCU "Software\${NAME}" "ToolsPath" "$InstDrive${TOOLS}"
	WriteRegStr HKCU "Software\${NAME}" "ResourcesPath" "${RESOURCES}"
	WriteRegStr HKCU "Software\${NAME}" "AppDataPath" "${APPDATA}"
	WriteRegStr HKCU "Software\${NAME}" "RememberCreds" "$RememberCreds"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutStartMenu" "$ShortcutStartMenu"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutDesktop" "$ShortcutDesktop"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutUpdater" "$ShortcutUpdater"
	WriteRegStr HKCU "Software\${NAME}" "ShortcutWindowsStart" "$ShortcutWindowsStart"
	WriteRegStr HKCU "Software\${NAME}" "Installer" "$EXEPATH"
	${If} $RememberCreds == "1"
		${If} $Pass != ""
			Call EncryptPw
			WriteRegStr HKCU "Software\${NAME}" "Pass" "$EncPass"
		${EndIf}
		WriteRegStr HKCU "Software\${NAME}" "User" "$User"
	${Else}
		DeleteRegValue HKCU "Software\${NAME}" "User"
		DeleteRegValue HKCU "Software\${NAME}" "Pass"
	${EndIf}
	StrCpy $User ""
	StrCpy $Pass ""
	WriteRegStr HKCU "${HKCUNI}" "DisplayName" "${NAME}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayIcon" "$InstDrive$INSTDIR\${ICON}"
	WriteRegStr HKCU "${HKCUNI}" "DisplayVersion" "$Version"
	WriteRegStr HKCU "${HKCUNI}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKCU "${HKCUNI}" "UninstallString" "$InstDrive$INSTDIR\${UNINSTALLER}"
	WriteRegStr HKCU "${HKCUNI}" "NoRepair" "1"
	WriteUninstaller "$InstDrive$INSTDIR\${UNINSTALLER}"
	SetOutPath "$InstDrive$INSTDIR"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogPostInstall)"
	${If} $ShortcutStartMenu == "1"
		CreateDirectory "$SMPROGRAMS\${NAME}"
		CreateShortCut "$SMPROGRAMS\${NAME}\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
		CreateShortCut "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutDesktop == "1"
		CreateShortCut "$DESKTOP\${INSTALLER_NAME}.lnk" "$EXEPATH" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutUpdater == "1"
		CreateShortCut "$DESKTOP\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}"
	${EndIf}
	${If} $ShortcutWindowsStart == "1"
		CreateDirectory $StartUpDir
		CreateShortCut "$StartUpDir\${NAME}.lnk" "$InstDrive$INSTDIR\${APPFILE}" "" "$InstDrive$INSTDIR\${ICON}" "" SW_SHOWMINIMIZED
	${EndIf}
	Pop $R4
	Pop $R3
	Pop $R2
	Pop $R1
	Pop $R0
SectionEnd

Section "-Final"
	Call WriteLogFinal
SectionEnd
