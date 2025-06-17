;--------------------------------
; FUNCIONES

Function WriteLogInicial
	Call SetDateTimeStamp
	${If} $IsUpdateInstall == "1"
		StrCpy $LogFile "$INSTDIR\logs\actualizacion_$Timestamp.log"
	${Else}
		StrCpy $LogFile "$INSTDIR\logs\instalacion_$Timestamp.log"
	${EndIf}
	DetailPrint ${LINEA}
	DetailPrint "${TXT_LogSecInicio}"
	DetailPrint ${LINEA}
	DetailPrint "${TXT_LogFechaHora} $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "${TXT_LogVersion} v$Version"
	DetailPrint "${TXT_EtiqUnidadDestino} $InstDrive"
	DetailPrint "${TXT_EtiqRutaInstalacion} $INSTDIR"
	DetailPrint "${TXT_LogServidorDescargas} $Server"
	DetailPrint "${TXT_LogProtocoloTransfer} $Protocol"
FunctionEnd

Function WriteLogPrograma
	DetailPrint ${LINEA}
	DetailPrint "*****${TXT_LogSecPrograma}*****"
	DetailPrint ${LINEA}
FunctionEnd

Function WriteLogRequisitos
	${If} $RequisitosVisibles > 0
		DetailPrint ${LINEA}
		DetailPrint "*****${TXT_LogSecRequisitos}*****"
	${EndIf}
FunctionEnd

Function WriteLogComplementos
	${If} $ComplementosVisibles > 0
		DetailPrint ${LINEA}
		DetailPrint "*****${TXT_LogSecComplementos}*****"
	${EndIf}
FunctionEnd

Function WriteLogExtensiones
	${If} $ExtensionesVisibles > 0
		DetailPrint ${LINEA}
		DetailPrint "*****${TXT_LogSecExtensiones}*****"
	${EndIf}
FunctionEnd

Function WriteLogRecursos
	${If} $RecursosVisibles > 0
		DetailPrint ${LINEA}
		DetailPrint "*****${TXT_LogSecRecursos}*****"
	${EndIf}
FunctionEnd

Function WriteLogConfig
	DetailPrint ${LINEA}
	DetailPrint "*****${TXT_LogSecConfig}*****"
		DetailPrint ${LINEA}
	DetailPrint "${TXT_LogWriteReg} HKCU Software\${NAME}"
	DetailPrint "${TXT_LogWriteReg} HKCU ${HKCUNI}"
	DetailPrint "${TXT_MsgCalculandoEspacio}"
FunctionEnd

Function WriteLogFinal
	DetailPrint ${LINEA}
	DetailPrint "*****FIN*****"
	DumpLog::DumpLogUTF8 "$LogFile" .r0
	Pop $0
	${If} $0 == "0"
		DetailPrint "${TXT_LogGuardado} $LogFile"
	${Else}
		DetailPrint "${TXT_LogNoGuardado}"
	${EndIf}
FunctionEnd
