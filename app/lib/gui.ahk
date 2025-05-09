; ====================
; --lib\gui.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _DicEntornos

; ====================
; ETIQUETAS
; ====================

Reiniciar:
	GuardarPosicionVentana()
	CambiarEntornoYReiniciar()
return

Salir:
	GuardarPosicionVentana()
	Gui, Destroy
	titulo := Config.Comandos.ConsolaTitulo
	if WinExist(titulo)
		WinClose, %titulo%
	ExitApp
return

GuiClose:
	Gui, Minimize
return

CerrarAcercaDe:
	Gui, Acerca:Destroy
return

AceptarEntorno:
	Gui, Entornos:Submit
	entornoId := _DicEntornos[EntornoVisible]
	if (entornoId != "")
		IniWrite, %entornoId%, config.ini, Base, Entorno
	Gui, Entornos:Destroy
	titulo := Config.Comandos.ConsolaTitulo
	if WinExist(titulo)
		WinClose, %titulo%
	Reload
return

CancelarEntorno:
    Gui, Entornos:Destroy
return

; ====================
; FUNCIONES
; ====================

MostrarVentanaApp() {
	local colorFondo := Config.Gui.ColorFondo
	local fuenteTamano := Config.Gui.FuenteTamano
	local fuenteNombre := Config.Gui.FuenteNombre
	local colorTexto := Config.Gui.ColorTexto
	local margenSup := Config.Gui.MargenSup
	local margenInf := Config.Gui.MargenInf
	local transparencia := Config.Gui.Transparencia
	local margenIzq := Config.Gui.MargenIzq
	local anchoVentana := Config.Gui.AnchoVentana
	local appNombre := Config.App.Nombre
	local winX := Config.Usuario.winX
	local winY := Config.Usuario.winY

	; Configurar la Ventana
	Gui, +AlwaysOnTop
	Gui, Color, %colorFondo%
	Gui, Font, s%fuenteTamano% c%colorTexto%, %fuenteNombre%
	Gui, Margin, %margenSup%, %margenInf%
	Gui, +LastFound
	WinSet, Transparent, %transparencia%

	; Colocar Menu principal
	CrearMenuPrincipal()

	; Colocar Barra de botones
	yBase := CrearBarraBotones(margenIzq, margenSup)

	; Colocar Selector de proyecto
	yBase := CrearSelectorProyectos(margenIzq, yBase)

	; Colocar Pestañas de favoritos
	yBase := CrearPestanasFavoritos(margenIzq, yBase)

	; Colocar Botones de control
	yBase := CrearBotonesControl(yBase)

	; Agregar Barra de Estado
	Gui, Font, Normal
	Gui, Add, StatusBar,, Iniciado: %appNombre%

	; Desplegar la GUI
	SysGet, screenW, 78
	SysGet, screenH, 79
	if (winX > screenW)
		winX := 60
	if (winY > screenH)
		winY := 60
    Gui, Show, w%anchoVentana% x%winX% y%winY%, %appNombre%
}

CambiarEntornoYReiniciar() {
	local entornos, actual, entrada, clave, valor, x, y, item, idx := 1, selIdx := 1
	local fuenteTamano := Config.Gui.FuenteTamano
	local fuenteNombre := Config.Gui.FuenteNombre
	local appNombre := Config.App.Nombre
	WinGetPos, x, y, , , %appNombre%
	_DicEntornos := {}
	; Leer entorno actual
	IniRead, actual, config.ini, Base, Entorno, web
	IniRead, entornos, config.ini, Entornos
	; Si solo hay uno o está vacío, reiniciar directamente
	if (entornos = "" || !InStr(entornos, "=")) {
		titulo := Config.Comandos.ConsolaTitulo
		if WinExist(titulo)
			WinClose, %titulo%
		Reload
		return
	}
	; Construir diccionario clave => descripción y lista visible
	local lista := ""
	Loop, Parse, entornos, `n, `r
	{
		entrada := Trim(A_LoopField)
		if (entrada = "" || !InStr(entrada, "="))
			continue
		clave := Trim(SubStr(entrada, 1, InStr(entrada, "=") - 1))
		valor := Trim(SubStr(entrada, InStr(entrada, "=") + 1))
		_DicEntornos[valor] := clave
		lista .= valor . "|"
		if (clave = actual)
			selIdx := idx
		idx++
	}
	; Mostrar diálogo
	SB_SetText("Reiniciando…")
	Gui, Entornos:New
	Gui, Entornos:+AlwaysOnTop
	Gui, Entornos:Font, s%fuenteTamano%, %fuenteNombre%
	Gui, Entornos:Add, Text, x20 y20 w240, Reiniciar en Entorno de Trabajo:
	Gui, Entornos:Add, DropDownList, vEntornoVisible x20 y45 w240, % RTrim(lista, "|")
	GuiControl, Choose, EntornoVisible, %selIdx%
	Gui, Entornos:Add, Button, x40 y90 w80 gAceptarEntorno Default, Aceptar
	Gui, Entornos:Add, Button, x+10 w80 gCancelarEntorno, Cancelar
	Gui, Entornos:Show, w280 h140 x%x% y%y%, Elegir Entorno
	OnMessage(0x100, "EscCerrarEntornos")
}

MostrarAcercaDe() {
	local rutaLogo := Config.Rutas.Logo
	local appNombre := Config.App.Nombre
	local appVersion := Config.App.Version
	local appDescripcion := Config.App.Descripcion
	local appAutor := Config.App.Autor
	local fuenteTamano := Config.Gui.FuenteTamano
	local fuenteNombre := Config.Gui.FuenteNombre
	Gui, Acerca:New
	Gui, Acerca:+AlwaysOnTop
	Gui, Acerca:Font, s%fuenteTamano%, %fuenteNombre%
	y := 20
	if FileExist(rutaLogo)
		Gui, Acerca:Add, Picture, x110 y%y% w72 h72, %rutaLogo%
	y += 80
	Gui, Acerca:Font, Bold
	Gui, Acerca:Add, Text, x20 y%y% w260 Center, %appNombre%
	y += 18
	Gui, Acerca:Font, Normal
	Gui, Acerca:Add, Text, x20 y%y% w260 Center, Versión: %appVersion%
	y += 22
	Gui, Acerca:Add, Text, x20 y%y% w260 Center, %appDescripcion%
	y += 60
	Gui, Acerca:Add, Text, x20 y%y% w260 Center, %appAutor%
	y += 25
	Gui, Acerca:Add, Button, x110 y%y% w80 gCerrarAcercaDe, Cerrar
	y += 40
	Gui, Acerca:Show, w300 h%y% Center, Acerca de...
	OnMessage(0x100, "EscCerrarAcercaDe")
}

MinimizarVentana(nombre) {
	if WinExist(nombre)
		WinMinimize, %nombre%
}

GuardarPosicionVentana() {
	local appNombre := Config.App.Nombre
	local x, y, cfgIni
	cfgIni := Config.Base.CfgIni
	WinGetPos, x, y, , , %appNombre%
	IniWrite, %x%, %cfgIni%, Usuario, winX
	IniWrite, %y%, %cfgIni%, Usuario, winY
}

EscCerrarAcercaDe(wParam, lParam, msg, hwnd) {
	if (wParam = 27)
		Gui, Acerca:Destroy
}

EscCerrarEntornos(wParam, lParam, msg, hwnd) {
	if (wParam = 27)
		Gui, Entornos:Destroy
}

CrearBotonesControl(yy) {
	local anchoVentana := Config.Gui.AnchoVentana
	botonX := ((anchoVentana - 100) // 2) - 60
	Gui, Font, Normal
	Gui, Add, Button, w100 x%botonX% y%yy% gReiniciar, REINICIAR
	Gui, Font, Bold
	Gui, Add, Button, w100 x+10 y%yy% gSalir, SALIR
	return yy + 40
}
