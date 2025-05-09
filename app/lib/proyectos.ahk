; ====================
; --lib\proyectos.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _EtiquetaProyecto, _SeleccionProyecto, _ListaProyectos

; ====================
; ETIQUETAS
; ====================

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
	_ListaProyectos := []
	if !FileExist(rutaDefProyectos)
		return
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
