; ====================
; --modulos\entornos.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _EntornoActualEditando, _EntornoCampos, _EntornoSecciones

; ====================
; SUBRUTINAS
; ====================

GuardarConfigEntorno:
    Gui, EditarEntorno:Submit
    ruta := A_ScriptDir . "\entornos\" . _EntornoActualEditando . "\config.ini"
    for i, campo in _EntornoCampos {
        GuiControlGet, val,, Campo_%campo%
        seccion := _EntornoSecciones[campo]
        IniWrite, %val%, %ruta%, %seccion%, %campo%
    }
    MsgBox, 64, Guardado, Configuración del entorno guardada correctamente., 3
    Gui, EditarEntorno:Destroy
return

CancelarConfigEntorno:
    Gui, EditarEntorno:Destroy
return

EntornoCerrar:
    Gui, Entornos:Destroy
return

EntornoCrear:
    Gui, Entornos:Destroy
    MostrarFormCrearEntorno()
return

EntornoEditar:
    GuiControlGet, entorno,, EntornoSeleccionado
    if (entorno != "") {
        Gui, Entornos:Destroy
        EditarConfigEntorno(entorno)
    }
return

EntornoEliminar:
    GuiControlGet, entorno,, EntornoSeleccionado
    if (entorno = "")
        return
    MsgBox, 292, Confirmar, ¿Deseas eliminar el entorno '%entorno%' por completo?
    IfMsgBox, Yes
    {
		idEntorno := ObtenerIdEntorno(entorno)
        ruta := A_ScriptDir . "\entornos\" . idEntorno
		if !FileExist(ruta) {
			MsgBox, 48, Error, No se encontró la ruta del entorno '%ruta%'., 5
			return
		}
        FileRemoveDir, %ruta%, 1
        EliminarLineaIni("config.ini", "Entornos", idEntorno)
        MsgBox, 64, Eliminado, Entorno '%entorno%' eliminado exitosamente., 5
    }
    Gui, Entornos:Destroy
    MostrarGestionEntornos()
return

CrearEntornoCancelar:
    Gui, CrearEntorno:Destroy
return

CrearEntornoConfirmar:
    Gui, CrearEntorno:Submit
    Gui, CrearEntorno:Destroy
    id := Trim(NuevoIdEntorno)
    nombre := Trim(NuevoNombreEntorno)
    if (id = "" || nombre = "") {
        MsgBox, 48, Error, Debes ingresar el ID y el nombre del entorno., 5
        return
    }
    destino := A_ScriptDir . "\entornos\" . id
    if FileExist(destino) {
        MsgBox, 48, Error, Ya existe un entorno llamado '%id%'. , 5
        return
    }
    FileCreateDir, %destino%
    origen := A_ScriptDir . "\base"
    Loop, Files, %origen%\*, F
    {
        FileCopy, %A_LoopFileFullPath%, %destino%\%A_LoopFileName%, 1
    }
    IniWrite, %nombre%, config.ini, Entornos, %id%
    IniWrite, %nombre%, %destino%\config.ini, App, Nombre
    MsgBox, 64, Entorno creado, Se ha creado el entorno '%nombre%' correctamente., 4
    MostrarGestionEntornos()
return

EntornoImportarZip:
    Gui Entornos:+OwnDialogs
    rutaZip := SeleccionarArchivoZip()
    if (rutaZip = "")
        return
    SplitPath, rutaZip, zipFileName
    id := StrReplace(zipFileName, "entorno_", "")
    id := StrReplace(id, ".zip", "")
    rutaTemp := A_Temp . "\entorno_import_tmp"
    FileRemoveDir, %rutaTemp%, 1
    FileCreateDir, %rutaTemp%
    ruta7z := A_ScriptDir . "\bin\7za.exe"
    if !FileExist(ruta7z) {
        MsgBox, 16, Error, No se encontró 7z.exe en:`n%ruta7z%
        return
    }
    rutaImport := rutaTemp . "\" . id
    RunWait, "%ruta7z%" x "%rutaZip%" -o"%rutaImport%" -y, , Hide
    rutaConfig := rutaImport . "\config.ini"
    if !FileExist(rutaConfig) {
        MsgBox, 48, Error, El archivo config.ini no fue encontrado en el entorno importado., 5
        return
    }
    IniRead, nuevaVersion, %rutaConfig%, App, Version
    rutaDestino := A_ScriptDir . "\entornos\" . id
    if FileExist(rutaDestino) {
        IniRead, actualVersion, %rutaDestino%\config.ini, App, Version
        MsgBox, 292, Entorno existente, Ya existe un entorno '%id%'.`nVersión actual: %actualVersion%`nVersión importada: %nuevaVersion%`n¿Deseas reemplazarlo?
        IfMsgBox, No
            return
        FileRemoveDir, %rutaDestino%, 1
    }
    IniRead, nombre, %rutaConfig%, App, Nombre
    FileMoveDir, %rutaImport%, %rutaDestino%, 1
    IniWrite, %nombre%, config.ini, Entornos, %id%
    FileRemoveDir, %rutaTemp%, 1
    MsgBox, 64, Importado, El entorno '%id%' ha sido importado correctamente., 4
    Gui, Entornos:Destroy
    MostrarGestionEntornos()
return

EntornoExportarZip:
    GuiControlGet, entorno,, EntornoSeleccionado
    if (entorno = "") {
        MsgBox, 48, Error, Debes seleccionar un entorno primero., 4
        return
    }
    id := ObtenerIdEntorno(entorno)
    rutaOrigen := A_ScriptDir . "\entornos\" . id
    rutaZip := A_ScriptDir . "\compartidos\entorno_" . id . ".zip"
    ruta7z := A_ScriptDir . "\bin\7za.exe"
    if !FileExist(ruta7z) {
        MsgBox, 16, Error, No se encontró 7z.exe en:`n%ruta7z%
        return
    }
    if FileExist(rutaZip)
	{
		FileDelete, %rutaZip%
	}
    RunWait, "%ruta7z%" a -tzip "%rutaZip%" "%rutaOrigen%\*", , Hide
    MsgBox, 64, Exportado, El entorno '%id%' fue exportado como ZIP en:`n%rutaZip%, 5
return

; ====================
; FUNCIONES
; ====================

MostrarGestionEntornos() {
    local entornos := ObtenerListaEntornos()
    local fuente := Config.Gui.FuenteNombre
    local tamano := Config.Gui.FuenteTamano
    local formX := Config.Usuario.formX
    local formY := Config.Usuario.formY
    local ancho := 320, xx := 20, yy := 20
    Gui, Entornos:New
    Gui, Entornos:+AlwaysOnTop +OwnDialogs
    Gui, Entornos:Font, s%tamano%, %fuente%
    Gui, Entornos:Add, Button, x%xx% y%yy% w130 gEntornoCrear, Crear nuevo
    Gui, Entornos:Add, Button, x+10 y%yy% w130 gEntornoImportarZip, Importar
    yy += 45
    Gui, Entornos:Add, Text, x%xx% y%yy% w300, Selecciona un Entorno existente:
    yy += 25
    Gui, Entornos:Add, DropDownList, x%xx% y%yy% w270 vEntornoSeleccionado, %entornos%
    yy += 35
    Gui, Entornos:Add, Button, x%xx% y%yy% w80 gEntornoEditar, Editar
    Gui, Entornos:Add, Button, x+5 y%yy% w90 gEntornoExportarZip, Exportar
    Gui, Entornos:Add, Button, x+5 y%yy% w90 gEntornoEliminar, Eliminar
    yy += 40
    Gui, Entornos:Add, Button, x%xx% y%yy% w270 gEntornoCerrar, Cerrar
    yy += 40
    Gui, Entornos:Show, w%ancho% h%yy% x%formX% y%formY%, Gestión de Entornos
}

ObtenerIdEntorno(entorno) {
    local linea := StrSplit(entorno, "-")
    return Trim(linea[1])
}

EliminarLineaIni(archivo, seccion, clave) {
    IniDelete, %archivo%, %seccion%, %clave%
}

SeleccionarArchivoZip() {
    local carpeta := A_ScriptDir . "\compartidos"
    FileSelectFile, ruta, 3, %carpeta%, Selecciona el archivo ZIP de entorno a importar, ZIP (*.zip)
    return ruta
}

ObtenerListaEntornos() {
    local lista := ""
    IniRead, raw, config.ini, Entornos
    Loop, Parse, raw, `n, `r
    {
        linea := Trim(A_LoopField)
        if (linea = "")
            continue
        kv := StrSplit(linea, "=")
        clave := Trim(kv[1])
        valor := Trim(kv[2])
        lista .= clave . " - " . valor . "|"
    }
    return RTrim(lista, "|")
}

MostrarFormCrearEntorno() {
    local fuente := Config.Gui.FuenteNombre
    local tamano := Config.Gui.FuenteTamano
	local formX := Config.Usuario.formX
	local formY := Config.Usuario.formY
    local xx := 20, yy := 20, ancho := 340
    Gui, CrearEntorno:New
    Gui, CrearEntorno:+AlwaysOnTop +OwnDialogs
    Gui, CrearEntorno:Font, s%tamano%, %fuente%
    Gui, CrearEntorno:Add, Text, x%xx% y%yy% w300, Identificador del nuevo entorno (sin espacios):
    yy += 25
    Gui, CrearEntorno:Add, Edit, x%xx% y%yy% w280 vNuevoIdEntorno
    yy += 35
    Gui, CrearEntorno:Add, Text, x%xx% y%yy% w300, Nombre descriptivo del entorno:
    yy += 25
    Gui, CrearEntorno:Add, Edit, x%xx% y%yy% w280 vNuevoNombreEntorno
    yy += 35
    Gui, CrearEntorno:Add, Button, x%xx% y%yy% w100 gCrearEntornoConfirmar Default, Crear
    Gui, CrearEntorno:Add, Button, x+10 y%yy% w100 gCrearEntornoCancelar, Cancelar
    yy += 50
    Gui, CrearEntorno:Show, w%ancho% h%yy% x%formX% y%formY%, Crear Nuevo Entorno
    OnMessage(0x100, "EscCerrarCrearEntorno")
}

EscCerrarCrearEntorno(wParam, lParam, msg, hwnd) {
    if (wParam = 27)
        Gui, CrearEntorno:Destroy
}

EditarConfigEntorno(entorno) {
	local etiqueta, seccion, campo, valor, leyendoOpciones
	local factor := 1
	local anchoCampo := Config.Comandos.AnchoCampo
	local anchoEtiq := Config.Comandos.AnchoEtiq
	local anchoForm := Config.Comandos.AnchoForm
    local fuente := Config.Gui.FuenteNombre
    local tamano := Config.Gui.FuenteTamano
	local formX := Config.Usuario.formX
	local formY := Config.Usuario.formY
	local idEntorno := ObtenerIdEntorno(entorno)
    local rutaCfg := A_ScriptDir . "\entornos\" . idEntorno . "\config.ini"
    local rutaDef := A_ScriptDir . "\entornos\" . idEntorno . "\entorno.txt"
    if !FileExist(rutaCfg) or !FileExist(rutaDef) {
        MsgBox, 48, Error, No se pudo encontrar los archivos requeridos del entorno.`n%rutaCfg%`n%rutaDef%, 5
        return
    }
    local campos := [], etiquetas := [], secciones := [], opciones := {}
    FileRead, contenido, %rutaDef%
    leyendoOpciones := false
    Loop, Parse, contenido, `n, `r
    {
        linea := Trim(A_LoopField)
        if (linea = "") or (SubStr(linea, 1, 1) = ";")
            continue
        if (linea = "[OpcionesCampos]") {
            leyendoOpciones := true
            continue
        }
        if !leyendoOpciones {
            if RegExMatch(linea, "--(\w+)\|(\w+)\s*=\s*(.+)", m)
			{
                campos.Push(m1)
                secciones[m1] := m2
                etiquetas[m1] := m3
            }
        } else {
            kv := StrSplit(linea, "=")
            opciones[Trim(kv[1])] := Trim(kv[2])
        }
    }
    Gui, EditarEntorno:New
    Gui, EditarEntorno:+AlwaysOnTop +OwnDialogs
    Gui, EditarEntorno:Font, s%tamano%, %fuente%
    local xx := 16, yy := 16
    for index, campo in campos {
        etiqueta := etiquetas[campo], seccion := secciones[campo]
        IniRead, valor, %rutaCfg%, %seccion%, %campo%,
        Gui, EditarEntorno:Add, Text, x%xx% y%yy% w%anchoEtiq%, %etiqueta%
        if opciones.HasKey(campo) {
            Gui, EditarEntorno:Add, DropDownList, x+5 y%yy% w%anchoCampo% vCampo_%campo%, % opciones[campo]
            GuiControl, ChooseString, Campo_%campo%, %valor%
			yy += 32
        } else {
            Gui, EditarEntorno:Add, Edit, x+5 y%yy% w%anchoCampo% vCampo_%campo%, %valor%
			factor := (StrLen(valor) / 100) + 1
			yy += 32 * factor
        }
    }
	yy += 8
	Gui, EditarEntorno:Font, Bold
    Gui, EditarEntorno:Add, Button, x%xx% y%yy% w100 gGuardarConfigEntorno Default, Guardar
	Gui, EditarEntorno:Font, Normal
    Gui, EditarEntorno:Add, Button, x+10 y%yy% w100 gCancelarConfigEntorno, Cancelar
    yy += 40
    Gui, EditarEntorno:Show, w%anchoForm% h%yy% x%formX% y%formY%, Editar Entorno: %idEntorno%
    _EntornoActualEditando := idEntorno
    _EntornoCampos := campos
    _EntornoSecciones := secciones
}
