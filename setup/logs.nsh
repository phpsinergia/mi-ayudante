;--------------------------------
; FUNCIONES

Function WriteLogInicial
	DetailPrint "============================================"
	DetailPrint "${TXT_LogTitulo}"
	DetailPrint "${TXT_LogFechaHora} $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "${TXT_LogVersion} v$Version"
	DetailPrint "${TXT_EtiqUnidadDestino} $InstDrive"
	DetailPrint "${TXT_EtiqRutaInstalacion} $INSTDIR"
	DetailPrint "${TXT_LogServidorDescargas} $Server"
	DetailPrint "${TXT_LogProtocoloTransfer} $Protocol"
	;DetailPrint "============================================"
FunctionEnd

Function WriteLogRequisitos

FunctionEnd

Function WriteLogComplementos

FunctionEnd

Function WriteLogExtensiones

FunctionEnd

Function WriteLogRecursos

FunctionEnd

Function WriteLogConfig
	DetailPrint "============================================"
	DetailPrint "${TXT_LogSecConfig}"
	DetailPrint "${TXT_LogWriteReg} HKCU Software\${NAME}"
	DetailPrint "${TXT_LogWriteReg} HKCU ${HKCUNI}"
	DetailPrint "${TXT_MsgCalculandoEspacio}"
FunctionEnd

Function WriteLogFinal
	DetailPrint "============================================"
	DumpLog::DumpLogUTF8 "$LogFile" .r0
	Pop $0
	;DetailPrint "DumpLog→$0"
FunctionEnd
