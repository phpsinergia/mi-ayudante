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
	Call un.WriteLogFinal
SectionEnd
