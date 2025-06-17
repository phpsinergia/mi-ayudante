;--------------------------------
; FUNCIONES

Function WriteLogInicial
	Call SetDateTimeStamp
	DetailPrint "============================================"
	DetailPrint "${TXT_LogTitulo}"
	DetailPrint "${TXT_LogFechaHora} $Day-$Month-$Year  $Hour:$Min"
	DetailPrint "${TXT_LogVersion} v$Version"
	DetailPrint "${TXT_EtiqUnidadDestino} $InstDrive"
	DetailPrint "${TXT_EtiqRutaInstalacion} $INSTDIR"
	DetailPrint "${TXT_LogServidorDescargas} $Server"
	DetailPrint "${TXT_LogProtocoloTransfer} $Protocol"
FunctionEnd

Function WriteLogRequisitos
	${If} $RequisitosVisibles > 0
		DetailPrint "============================================"
		DetailPrint "${TXT_LogTituloRequisitos}"
	${EndIf}
FunctionEnd

Function WriteLogComplementos
	${If} $ComplementosVisibles > 0
		DetailPrint "============================================"
		DetailPrint "${TXT_LogTituloComplementos}"
	${EndIf}
FunctionEnd

Function WriteLogExtensiones
	${If} $ExtensionesVisibles > 0
		DetailPrint "============================================"
		DetailPrint "${TXT_LogTituloExtensiones}"
	${EndIf}
FunctionEnd

Function WriteLogRecursos
	${If} $RecursosVisibles > 0
		DetailPrint "============================================"
		DetailPrint "${TXT_LogTituloRecursos}"
	${EndIf}
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
	DetailPrint "DumpLog→$0"
FunctionEnd
