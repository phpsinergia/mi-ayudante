; ====================
; --modulos\proyectos.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _EtiquetaProyecto, _SeleccionProyecto, _ListaProyectos

; ====================
; SUBRUTINAS
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
    ; Copiar carpetas plantilla
	origen := Config.Base.AppDir . "\php"
	destino := rutaProyecto . "\phpsinergia"
	CopiarCarpeta(origen, destino)
	
    ; Agregar al archivo cfg de proyectos
    archivoProy := Config.Rutas.DefProyectos
    lineaNueva := nombre . " | " . carpeta
    FileAppend, %lineaNueva%`n, %archivoProy%
	; Ejecutar composer install si el usuario eligió esa opción
	if (OpcionComposerInstall = 1) {
		GenerarComposerJson(rutaProyecto, nombre, carpeta, descripcion)
		RunWait, %ComSpec% /c cd /d "%rutaProyecto%" && composer install, , 
	}
    ; Registrar evento y mensaje al usuario
    Registrar("Nuevo proyecto creado: " . nombre . " (" . rutaProyecto . ")")
	MsgBox, 64, Proyecto creado, El proyecto fue creado exitosamente en:`n%rutaProyecto%, 5
	Reload
return

CambiarProyecto:
	Gui, Submit, NoHide
	titulo := Config.Comandos.ConsolaTitulo
	if WinExist(titulo)
		WinClose, %titulo%
	for i, item in _ListaProyectos {
		if (item.nombre = _SeleccionProyecto) {
			valor := item.dir
			cfgIni := Config.Base.CfgIni
			IniWrite, %valor%, %cfgIni%, Usuario, ProyectoActual
			Config.Usuario.ProyectoActual := valor
			break
		}
	}
	Config.Base.RutaProyecto := Config.Rutas.MisProyectos . "\" . Config.Usuario.ProyectoActual
	GuiControl, Focus, _EtiquetaProyecto
	SB_SetText("Proyecto cambiado: " . valor)
return

; ====================
; FUNCIONES
; ====================

CargarDefinicionProyectos() {
	local contenido, msg
	local rutaDefProyectos := Config.Rutas.DefProyectos
	local rutaPlaProyectos := A_ScriptDir . "\base\proyectos.txt" 
	_ListaProyectos := []
	if !FileExist(rutaDefProyectos)
		FileCopy, %rutaPlaProyectos%, %rutaDefProyectos%, 1
	FileRead, contenido, %rutaDefProyectos%
	if ErrorLevel
		return
	try {
		Loop Parse, contenido, `n, `r 
		{
			if (StrLen(A_LoopField) > 2) 
			{
				columnas := StrSplit(A_LoopField, "|")
				nombre := Trim(columnas[1])
				dir := Trim(columnas[2])
				if (nombre != "" && dir != "")
					_ListaProyectos.Push({nombre: nombre, dir: dir})
			}
		}
		InicializarProyectoActual()
	} catch e {
		msg := "Hay definiciones de Proyectos no válidas"
		MsgBox, 4112, ERROR, %msg%, 5
		return 0
	}
}

ObtenerNombresProyectos() {
	local _, proyecto, texto
	texto := ""
	for _, proyecto in _ListaProyectos
		texto .= proyecto.nombre "|"
	return RTrim(texto, "|")
}

InicializarProyectoActual() {
	_SeleccionProyecto := ""
	if (Config.Usuario.ProyectoActual = "" && _ListaProyectos.MaxIndex() >= 1)
		Config.Usuario.ProyectoActual := _ListaProyectos[1].dir
	proyectoEncontrado := false
	Loop % _ListaProyectos.MaxIndex()
	{
		if (_ListaProyectos[A_Index].dir = Config.Usuario.ProyectoActual)
		{
			_SeleccionProyecto := _ListaProyectos[A_Index].nombre
			Config.Base.IdProyecto := A_Index
			proyectoEncontrado := true
			break
		}
	}
	if (!proyectoEncontrado && _ListaProyectos.MaxIndex() >= 1) {
		_SeleccionProyecto := _ListaProyectos[1].nombre
		Config.Usuario.ProyectoActual := _ListaProyectos[1].dir
		Config.Base.IdProyecto := 1
	}
	Config.Base.RutaProyecto := Config.Rutas.MisProyectos . "\" . Config.Usuario.ProyectoActual
}

CrearSelectorProyectos(xx, yy) {
	local anchoListaProy := Config.Gui.AnchoListaProy
	local posListaProy := Config.Gui.PosListaProy
	local fuenteTamano := Config.Gui.FuenteTamano
	local colorTexto := Config.Gui.ColorTexto
	local idProyecto := Config.Base.IdProyecto
	if (_ListaProyectos.MaxIndex() < 1)
		return yy
	yTexto := yy + 3
	Gui, Font, s%fuenteTamano% c%colorTexto% Normal
	Gui, Add, Text, x%xx% y%yTexto% w100 v_EtiquetaProyecto, Proyecto:
	Gui, Add, DropDownList, v_SeleccionProyecto x%posListaProy% y%yy% w%anchoListaProy% gCambiarProyecto, % ObtenerNombresProyectos()
	GuiControl, Choose, _SeleccionProyecto, %idProyecto%
	GuiControl, Focus, _EtiquetaProyecto
	yy += 32
	return yy
}

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
	Gui, NuevoProy:Add, Checkbox, x%xx% y%yy% vOpcionComposerInstall Checked, Instalar Gestor-CLI mediante "Composer"
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
    local plantilla := Config.Base.AppDir . "\base\composer.json"
	local entorno := Config.Base.Entorno
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
	contenido := RegExReplace(contenido, "m)^(\s*)""name""\s*:\s*""[^""]+""", "$1""name"": ""phpsinergia/" . entorno . "_" . slug . """", , 1)
	contenido := RegExReplace(contenido, """description""\s*:\s*""[^""]+""", """description"": """ . descripcion . """")
    ; Escribir archivo en nueva carpeta del proyecto
    FileDelete, %destino%
    FileAppend, %contenido%, %destino%
    return true
}
