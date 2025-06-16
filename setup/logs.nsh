;--------------------------------
; FUNCIONES

Function WriteLogInicial
	DetailPrint "============================================"
	DetailPrint "${TXT_LogTitulo}"
	DetailPrint "${TXT_LogFechaHora} $DAY-$MONTH-$YEAR  $HOUR:$MIN"
	DetailPrint "${TXT_LogVersion} v$VERSION"
	DetailPrint "${TXT_EtiqUnidadDestino} $INSTDRIVE"
	DetailPrint "${TXT_EtiqRutaInstalacion} $INSTDIR"
	DetailPrint "${TXT_LogServidorDescargas} $SERVER"
	DetailPrint "${TXT_LogProtocoloTransfer} $PROTOCOL"
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
