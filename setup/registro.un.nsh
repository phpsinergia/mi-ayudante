; registro.un.nsh
;================================
; MODULO: REGISTRO DESINSTALACION
;================================

;--------------------------------
; FUNCIONES
;--------------------------------

Function un.WriteLogInicial
	Push $0
	Call un.SetDateTimeStamp
	StrCpy $LogFile "$INSTDIR\logs\desinstalacion_$Timestamp.log"
	DetailPrint ${SEPARATOR}
	StrCpy $0 "${NAME}"
	${unStrCase} $0 "$0" U
	DetailPrint "$(TXT_LogDesinstalando) $0"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogFechaHora): $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "$(TXT_LogVersion): v$Version"
	DetailPrint "$(TXT_EtiqRutaInstalacion): $INSTDIR"
	DetailPrint "Profile: $PROFILE"
	DetailPrint "Desktop: $DESKTOP"
	DetailPrint "Documents: $DOCUMENTS"
	DetailPrint "LocalAppData: $LOCALAPPDATA"
	Pop $0
FunctionEnd

Function un.WriteLogSection
	Pop $0
	DetailPrint ${SEPARATOR}
	${unStrCase} $0 "$0" U
	DetailPrint "*****$(TXT_LogDesinstalando) $0*****"
FunctionEnd

Function un.WriteLogFinal
	DetailPrint ${SEPARATOR}
	DetailPrint "*****FIN*****"
	${IfNot} ${SectionIsSelected} ${SEC_01}
		DumpLog::DumpLogUTF8 "$LogFile" .r0
		Pop $0
		${If} ${FileExists} $LogFile
			DetailPrint "$(TXT_LogGuardado)"
		${Else}
			DetailPrint "$(TXT_LogNoGuardado)"
			DetailPrint "$0"
		${EndIf}
		DetailPrint "$LogFile"
	${EndIf}
FunctionEnd
