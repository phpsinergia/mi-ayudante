;--------------------------------
; FUNCIONES

Function WriteLogInicial
	Call SetDateTimeStamp
	${If} $IsUpdateInstall == "1"
		StrCpy $LogFile "$INSTDIR\logs\actualizacion_$Timestamp.log"
	${Else}
		StrCpy $LogFile "$INSTDIR\logs\instalacion_$Timestamp.log"
	${EndIf}
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogSecInicio)"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogFechaHora) $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "$(TXT_LogVersion) v$Version"
	DetailPrint "$(TXT_EtiqUnidadDestino) $InstDrive"
	DetailPrint "$(TXT_EtiqRutaInstalacion) $INSTDIR"
	DetailPrint "$(TXT_LogServidorDescargas) $Server"
	DetailPrint "$(TXT_LogProtocoloTransfer) $Protocol"
	DetailPrint "Profile: $PROFILE"
	DetailPrint "Desktop: $DESKTOP"
	DetailPrint "Documents: $DOCUMENTS"
	DetailPrint "LocalAppData: $LOCALAPPDATA"
FunctionEnd

Function WriteLogPrograma
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecPrograma)*****"
	DetailPrint ${SEPARATOR}
FunctionEnd

Function WriteLogActualizaciones
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecActualizaciones)*****"
FunctionEnd

Function WriteLogRequisitos
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecRequisitos)*****"
FunctionEnd

Function WriteLogComplementos
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecComplementos)*****"
FunctionEnd

Function WriteLogExtensiones
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecExtensiones)*****"
FunctionEnd

Function WriteLogRecursos
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecRecursos)*****"
FunctionEnd

Function WriteLogConfig
	DetailPrint ${SEPARATOR}
	DetailPrint "*****$(TXT_LogSecConfig)*****"
	DetailPrint ${SEPARATOR}
	DetailPrint "$(TXT_LogWriteReg) HKCU Software\${NAME}"
	DetailPrint "$(TXT_LogWriteReg) HKCU ${HKCUNI}"
	DetailPrint "$(TXT_MsgCalculandoEspacio)"
FunctionEnd

Function WriteLogFinal
	DetailPrint ${SEPARATOR}
	DetailPrint "*****FIN*****"
	DumpLog::DumpLogUTF8 "$LogFile" .r0
	Pop $0
	${If} $0 == "0"
		DetailPrint "$(TXT_LogGuardado) $LogFile"
	${Else}
		DetailPrint "$(TXT_LogNoGuardado)"
	${EndIf}
FunctionEnd
