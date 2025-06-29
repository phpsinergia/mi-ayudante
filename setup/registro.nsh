; registro.nsh
;================================
; MODULO: REGISTRO
;================================

;--------------------------------
; FUNCIONES
;--------------------------------

Function WriteLogInicial
	Push $0
	Call SetDateTimeStamp
	${If} $IsUpdateInstall == "1"
		StrCpy $LogFile "$InstDrive$INSTDIR\logs\actualizacion_$Timestamp.log"
	${Else}
		StrCpy $LogFile "$InstDrive$INSTDIR\logs\instalacion_$Timestamp.log"
	${EndIf}
	DetailPrint ${SEPARATOR}
	StrCpy $0 "${NAME}"
	${StrCase} $0 "$0" U
	DetailPrint "$(TXT_LogSection) $0"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogFechaHora): $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "$(TXT_LogVersion): v$Version"
	DetailPrint "$(TXT_EtiqUnidadDestino): $InstDrive"
	DetailPrint "$(TXT_EtiqRutaInstalacion): $INSTDIR"
	DetailPrint "$(TXT_LogServidorDescargas): $Server"
	DetailPrint "$(TXT_LogProtocoloTransfer): $Protocol"
	DetailPrint "Profile: $PROFILE"
	DetailPrint "Desktop: $DESKTOP"
	DetailPrint "Documents: $DOCUMENTS"
	DetailPrint "LocalAppData: $LOCALAPPDATA"
	Pop $0
FunctionEnd

Function WriteLogPrograma
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecPrograma)*****"
	DetailPrint ${SEPARATOR}
FunctionEnd

Function WriteLogSection
	Exch $0
	Push $1
	SectionGetText $0 $1
	${If} $1 != ""
		${StrCase} $1 "$1" U
		DetailPrint ${SEPARATOR}
		DetailPrint "*****$(TXT_LogSection) $1*****"
	${EndIf}
	Pop $1
FunctionEnd

Function WriteLogConfig
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecConfig)*****"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogWriteReg): HKCU Software\${NAME}"
	DetailPrint "$(TXT_LogWriteReg): HKCU ${HKCUNI}"
	DetailPrint "$(TXT_MsgCalculandoEspacio)"
FunctionEnd

Function WriteLogFinal
	DetailPrint ${SEPARATOR}
	DetailPrint "*****FIN*****"
	DumpLog::DumpLogUTF8 "$LogFile" .r0
	Pop $0
	${If} ${FileExists} $LogFile
		DetailPrint "$(TXT_LogGuardado)"
	${Else}
		DetailPrint "$(TXT_LogNoGuardado)"
		DetailPrint "$0"
	${EndIf}
	DetailPrint "$LogFile"
FunctionEnd
