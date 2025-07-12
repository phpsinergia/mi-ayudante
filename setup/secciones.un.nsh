; secciones.un.nsh
;================================
; MODULO: SECCIONES DESINSTALADOR
;================================

;--------------------------------
; VARIABLES GLOBALES
;--------------------------------
Var unComponentsIniTemp
Var unComponentsDir
Var unComponentKey
Var unComponentValue

;--------------------------------
; SECCIONES
;--------------------------------

Section "-un.Inicial" SEC_00
	Call un.WriteLogInicial
SectionEnd

Section /o "un.${NAME}" SEC_01
	${If} ${SectionIsSelected} ${SEC_01}
		Push "${NAME}"
		Call un.WriteLogSection
		Delete "$INSTDIR\*.*"
		Delete "$StartUpDir\${NAME}.lnk"
		Delete "$DESKTOP\${NAME}.lnk"
		Delete "$DESKTOP\${INSTALLER_NAME}.lnk"
		Delete "$SMPROGRAMS\${NAME}\${NAME}.lnk"
		Delete "$SMPROGRAMS\${NAME}\${INSTALLER_NAME}.lnk"
		RMDir /r "$SMPROGRAMS\${NAME}"
		DeleteRegKey HKCU "Software\${NAME}"
		DeleteRegKey HKCU "${HKCUNI}"
		SetOutPath "$PluginsDir"
		RMDir /r "$INSTDIR"
	${EndIf}
SectionEnd

Section /o "un.Herramientas externas" SEC_02
	${If} ${SectionIsSelected} ${SEC_02}
		Push "Herramientas externas"
		Call un.WriteLogSection
		StrCpy $unComponentsDir "$InstDrive${TOOLS}"
		Call un.UninstallComponents
		Push $unComponentsDir
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section /o "un.Recursos descargados" SEC_03
	${If} ${SectionIsSelected} ${SEC_03}
		Push "Recursos descargados"
		Call un.WriteLogSection
		StrCpy $unComponentsDir "${RESOURCES}"
		Call un.UninstallComponents
		Push $unComponentsDir
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section /o "un.PhpSinergIA + dependencias" SEC_04
	${If} ${SectionIsSelected} ${SEC_04}
		Push "PhpSinergIA + dependencias"
		Call un.WriteLogSection
		StrCpy $unComponentsDir "$InstDrive${VENDOR}"
		Call un.UninstallComponents
		Push $unComponentsDir
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section /o "un.Datos del usuario" SEC_05
	${If} ${SectionIsSelected} ${SEC_05}
		Push "Datos del usuario"
		Call un.WriteLogSection
		StrCpy $unComponentsDir "${APPDATA}"
		Call un.UninstallComponents
		Push $unComponentsDir
		Call un.RemoveDirIfEmpty
	${EndIf}
SectionEnd

Section "-un.Final" SEC_06
	${IfNot} ${SectionIsSelected} ${SEC_01}
		StrCpy $R4 "0"
		${GetSize} "$INSTDIR" "/S=0K" $R1 $R2 $R3
		IntOp $R4 $R4 + $R1
		ClearErrors
		${GetSize} "$InstDrive${VENDOR}" "/S=0K" $R1 $R2 $R3
		IfErrors 0 +2
			StrCpy $R1 "0"
		IntOp $R4 $R4 + $R1
		ClearErrors
		${GetSize} "$InstDrive${TOOLS}" "/S=0K" $R1 $R2 $R3
		IfErrors 0 +2
			StrCpy $R1 "0"
		IntOp $R4 $R4 + $R1
		ClearErrors
		${GetSize} "${RESOURCES}" "/S=0K" $R1 $R2 $R3
		IfErrors 0 +2
			StrCpy $R1 "0"
		IntOp $R4 $R4 + $R1
		ClearErrors
		${GetSize} "${APPDATA}" "/S=0K" $R1 $R2 $R3
		IfErrors 0 +2
			StrCpy $R1 "0"
		IntOp $R4 $R4 + $R1
		DetailPrint "$R4 KB"
		IntFmt $R4 "0x%08X" $R4
		WriteRegDWORD HKCU "${HKCUNI}" "EstimatedSize" "$R4"
	${EndIf}
	Call un.WriteLogFinal
SectionEnd
