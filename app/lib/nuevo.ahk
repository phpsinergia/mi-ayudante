; ====================
; --lib\nuevo.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

; ====================
; ETIQUETAS
; ====================

CrearProyectoCancelar:
    Gui, NuevoProy:Destroy
return

CrearProyectoConfirmar:
    Gui, NuevoProy:Submit
    Gui, NuevoProy:Destroy
    nombre := NombreProyecto
    carpeta := CarpetaProyecto
    descripcion := DescripcionProyecto
    if (nombre = "" || carpeta = "") {
        MsgBox, 48, ERROR, Debes ingresar un nombre y una carpeta de Proyecto., 5
        return
    }
    rutaBase := AplicarVariablesEnRuta(Config.Rutas.MisProyectos)
    rutaProyecto := rutaBase . "\" . carpeta
    if FileExist(rutaProyecto) {
        MsgBox, 48, ERROR, Ya existe una carpeta con ese nombre en:`n%rutaProyecto%, 5
        return
    }
    FileCreateDir, %rutaProyecto%
    if !FileExist(rutaProyecto) {
        MsgBox, 16, ERROR, No fue posible crear el proyecto en:`n%rutaProyecto%, 5
        return
    }
    ; Crear subcarpetas definidas en INI
	cfgIni := Config.Base.CfgIni
    IniRead, listaSubCarpetas, %cfgIni%, Proyecto, SubCarpetas, 
    if (listaSubCarpetas != "ERROR" && listaSubCarpetas != "") {
        Loop, Parse, listaSubCarpetas, |
        {
            sub := Trim(A_LoopField)
            if (sub != "") {
                subRuta := rutaProyecto . "\" . sub
                FileCreateDir, %subRuta%
            }
        }
    }
    ; Copiar carpetas plantilla (sección [PlantillasProyecto])
    IniRead, rawPlantillas, %cfgIni%, PlantillasProyecto
    if (rawPlantillas != "ERROR" && rawPlantillas != "") {
        Loop, Parse, rawPlantillas, `n, `r
        {
            linea := Trim(A_LoopField)
            if (linea = "" || InStr(linea, "=") = 0)
                continue
            kv := StrSplit(linea, "=")
            nom := Trim(kv[1])
            origen := Trim(kv[2])
            if (nom = "" || origen = "")
                continue
            origen := AplicarVariablesEnRuta(origen)
            destino := rutaProyecto . "\" . nom
            CopiarCarpeta(origen, destino)
        }
    }
    ; Agregar al archivo cfg de proyectos
    archivoProy := Config.Rutas.DefProyectos
    lineaNueva := nombre . " | " . carpeta
    FileAppend, %lineaNueva%`n, %archivoProy%
    ; Generar archivo composer.json del proyecto
	GenerarComposerJson(rutaProyecto, nombre, carpeta, descripcion)
	; Ejecutar composer install si el usuario eligió esa opción
	if (OpcionComposerInstall = 1) {
		RunWait, %ComSpec% /c cd /d "%rutaProyecto%" && composer install, , 
	}
    ; Registrar evento y mensaje al usuario
    Registrar("Nuevo proyecto creado: " . nombre . " (" . rutaProyecto . ")")
	MsgBox, 64, Proyecto creado, El proyecto fue creado exitosamente en:`n%rutaProyecto%, 5
	Reload
return

; ====================
; FUNCIONES
; ====================

CrearNuevoProyecto() {
    MostrarFormNuevoProyecto()
}

MostrarFormNuevoProyecto() {
    local fuente := Config.Gui.FuenteNombre
    local tamano := Config.Gui.FuenteTamano
    local xx := 20, yy := 10
    local anchoForm := Config.Comandos.AnchoForm
    Gui, NuevoProy:New
    Gui, NuevoProy:+AlwaysOnTop +OwnDialogs
    Gui, NuevoProy:Font, s%tamano%, %fuente%
    Gui, NuevoProy:Add, Text, x%xx% y%yy% w300, Carpeta (sólo letras):
    yy += 20
    Gui, NuevoProy:Add, Edit, x%xx% y%yy% w300 vCarpetaProyecto
    yy += 35
    Gui, NuevoProy:Add, Text, x%xx% y%yy% w300, Nombre del Proyecto:
    yy += 20
    Gui, NuevoProy:Add, Edit, x%xx% y%yy% w300 vNombreProyecto
    yy += 35
    Gui, NuevoProy:Add, Text, x%xx% y%yy% w300, Descripción (opcional):
    yy += 20
    Gui, NuevoProy:Add, Edit, x%xx% y%yy% w300 vDescripcionProyecto
    yy += 40
	Gui, NuevoProy:Add, Checkbox, x%xx% y%yy% vOpcionComposerInstall Checked, Instalar PHP-CLI con "Composer"
	yy += 30
	Gui, NuevoProy:Font, Bold
    Gui, NuevoProy:Add, Button, x%xx% y%yy% w100 gCrearProyectoConfirmar Default, Crear
	Gui, NuevoProy:Font, Normal
    Gui, NuevoProy:Add, Button, x+10 y%yy% w100 gCrearProyectoCancelar, Cancelar
    yy += 40
    Gui, NuevoProy:Show, w%anchoForm% h%yy%, Crear Nuevo Proyecto
	OnMessage(0x100, "EscCerrarFormNuevoProyecto")
}

EscCerrarFormNuevoProyecto(wParam, lParam, msg, hwnd) {
	if (wParam = 27)
		Gui, NuevoProy:Destroy
}

CopiarCarpeta(origen, destino) {
    FileCreateDir, %destino%
    ; Copiar subcarpetas recursivamente
    Loop, Files, %origen%\*, D
    {
        subOrigen := A_LoopFileFullPath
        subDestino := destino . "\" . A_LoopFileName
        CopiarCarpeta(subOrigen, subDestino)
    }
    ; Copiar archivos directamente al destino
    Loop, Files, %origen%\*, F
    {
        FileCopy, %A_LoopFileFullPath%, %destino%\%A_LoopFileName%, 1
    }
}

GenerarComposerJson(rutaBase, nombre, carpeta, descripcion) {
    local plantilla := Config.Base.RutaProyecto . "\composer.json"
    local destino := rutaBase . "\composer.json"
    if !FileExist(plantilla) {
        MsgBox, 48, ERROR, No se encontró "composer.json" en el proyecto actual.`nRuta esperada:`n%plantilla%, 5
        return false
    }
    FileRead, contenido, %plantilla%
    if ErrorLevel {
        MsgBox, 48, ERROR, No se pudo leer el "archivo composer.json" base., 5
        return false
    }
	textoOriginal := RegExReplace(carpeta, "[^\w]", "-")
	StringLower, slug, textoOriginal
	; Reemplazar campos "name" y "description"
	contenido := RegExReplace(contenido, "m)^(\s*)""name""\s*:\s*""[^""]+""", "$1""name"": ""phpsinergia/web_" . slug . """", , 1)
	contenido := RegExReplace(contenido, """description""\s*:\s*""[^""]+""", """description"": """ . descripcion . """")
    ; Escribir archivo en nueva carpeta del proyecto
    FileDelete, %destino%
    FileAppend, %contenido%, %destino%
    return true
}
