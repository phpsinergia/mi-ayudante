; ====================
; --lib\enlaces.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _ListaMenus, _ListaSubMenus, _DicBotonesBarra

; ====================
; ETIQUETAS
; ====================

EjecutarMenu:
	for index, item in _ListaSubMenus {
		if (item.titulo = A_ThisMenuItem) 
		{
			AbrirElemento(item.tipo, item.ruta, item.titulo)
		}
	}
return

EjecutarBotonBarra:
	id := A_GuiControl
	btn := _DicBotonesBarra[id]
	if IsObject(btn) {
		AbrirElemento(btn.tipo, btn.ruta, btn.titulo)
	}
return

; ====================
; FUNCIONES
; ====================

CargarDefinicionMenus() {
	local campos, grupo, titulo, icono, tipo, ruta, _, rutaIcono, msg
	local rutaDefMenus := Config.Rutas.DefMenus
	_DicBotonesBarra := {}
	_ListaMenus := []
	_ListaSubMenus := []
	if !FileExist(rutaDefMenus)
		return
    FileRead, contenido, %rutaDefMenus%
    if ErrorLevel
        return
	try {
		Loop Parse, contenido, `n, `r 
		{
			if (StrLen(A_LoopField) < 5 || SubStr(Trim(A_LoopField), 1, 1) = ";")
				continue
			campos := StrSplit(A_LoopField, "|")
			grupo := Trim(campos[1])
			titulo := Trim(campos[2])
			icono := Trim(campos[3])
			tipo := Trim(campos[4])
			ruta := Trim(campos[5])
			if (grupo = "")
				continue
			if (A_LoopField = grupo . "||||") {
				Menu, %grupo%, Add
				continue
			}
			yaExiste := false
			for _, existente in _ListaMenus
			{
				if (existente = grupo) {
					yaExiste := true
					break
				}
			}
			if (!yaExiste)
				_ListaMenus.Push(grupo)
			Menu, %grupo%, Add, %titulo%, EjecutarMenu
			if (icono != "") 
			{
				rutaIcono := Config.Rutas.ImgDir . "\" . icono
				if FileExist(rutaIcono)
					Menu, %grupo%, Icon, %titulo%, %rutaIcono%, 1
			}
			_ListaSubMenus.Push({grupo: grupo, titulo: titulo, icono: icono, tipo: tipo, ruta: ruta})
		}
	} catch e {
		msg := "Hay definiciones de Menús no válidas"
		MsgBox, 4112, ERROR, %msg%, 5
	}
}

CrearMenuPrincipal() {
	local e, grupo, _
	try {
		if (_ListaComandos.MaxIndex() > 0)
			Menu, Principal, Add, &Comandos, :_ListaComandos
		for _, grupo in _ListaMenus {
			Menu, Principal, Add, &%grupo%, :%grupo%
		}
		Gui, Menu, Principal
	} catch e {
	}
}

CrearBarraBotones(xInicial, yInicial) {
	local contenido, campos, titulo, icono, tipo, ruta, id, linea, rutaIcono, msg
	local espacio := 10, idx := 0, x := xInicial, y := yInicial
	local rutaDefBotones := Config.Rutas.DefBotones
	local anchoBotonBarra := Config.Gui.AnchoBotonBarra
	local altoBotonBarra := Config.Gui.AltoBotonBarra
	if !FileExist(rutaDefBotones)
		return yInicial
	FileRead, contenido, %rutaDefBotones%
	if ErrorLevel
		return yInicial
	try {
		Loop Parse, contenido, `n, `r
		{
			linea := Trim(A_LoopField)
			if (linea = "" || SubStr(linea, 1, 1) = ";")
				continue
			campos := StrSplit(linea, "|")
			if (campos.Length() < 4)
				continue
			titulo := Trim(campos[1])
			icono := Trim(campos[2])
			tipo := Trim(campos[3])
			ruta := Trim(campos[4])
			id := "btnBarra_" . A_Index
			rutaIcono := Config.Rutas.ImgDir . "\" . icono
			if !FileExist(rutaIcono)
				continue
			Gui, Add, Picture, x%x% y%y% w%anchoBotonBarra% h%altoBotonBarra% v%id% gEjecutarBotonBarra, %rutaIcono%
			_DicBotonesBarra[id] := {titulo: titulo, tipo: tipo, ruta: ruta}
			x += anchoBotonBarra + espacio
		}
		return y + altoBotonBarra + espacio
	} catch e {
		msg := "Hay definiciones de Botones no válidas"
		MsgBox, 4112, ERROR, %msg%, 5
		return yInicial
	}
}
