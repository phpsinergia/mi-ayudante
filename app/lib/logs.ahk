; ====================
; --lib\logs.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

; ====================
; FUNCIONES
; ====================

Registrar(msg, tipo := "INFO", formato := true) {
	local fecha, texto
	local rutaArchivoLogs = Config.Rutas.ArchivoLogs
	if (rutaArchivoLogs = "" || rutaArchivoLogs = "ERROR")
		rutaArchivoLogs := A_ScriptDir . "\registro.log"
	rutaArchivoLogs := AplicarVariablesEnRuta(rutaArchivoLogs)
	rutaArchivoLogs := StrReplace(rutaArchivoLogs, "[MiProyecto]", Config.Usuario.ProyectoActual)
	if (IsObject(msg)) {
		texto := SerializarObjeto(msg)
	} else {
		texto := msg
	}
	if (formato = true) {
		fecha := A_YYYY . "-" . A_MM . "-" . A_DD . " " . A_Hour . ":" . A_Min . ":" . A_Sec
		texto := "[" . fecha . "] [" . tipo . "] " . texto
	}
	FileEncoding, CP1252
	FileAppend, %texto%`n, %rutaArchivoLogs%
}

SerializarObjeto(obj, nivel := 0) {
    local clave, valor
	local indent := "", texto := ""
    Loop % nivel
        indent .= "    "
    for clave, valor in obj {
        if IsObject(valor) {
            texto .= indent . clave . ":`n"
            texto .= SerializarObjeto(valor, nivel + 1)
        } else {
            texto .= indent . clave . ": " . valor . "`n"
        }
    }
    return texto
}
