; ====================
; --lib\comandos.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _ListaComandos, _DicOpcionesCampos, _DicArgsInfo, _DicSelectoresRutas

; ====================
; ETIQUETAS
; ====================

EjecutarComando:
	Gui, FormComando:Destroy
	for index, item in _ListaComandos {
		if (item.titulo = A_ThisMenuItem && item.menu = A_ThisMenu) 
		{
			script := item.script
			comando := item.comando
			args := item.args
			SB_SetText("Comando: " . A_ThisMenuItem)
			if InStr(args, "<") {
				MostrarFormComando(script, comando, args, A_ThisMenu, A_ThisMenuItem)
			} else {
				linea := script . " " . comando . " " . args
				EnviarComandoConsola(linea)
			}
			break
		}
	}
return

EnviarFormComando:
	Gui, FormComando:Submit
	linea := _DicArgsInfo.ruta . " " . _DicArgsInfo.comando
	proyectoIni := Config.Base.AppDir . "\ini\" . Config.Base.Entorno . "_" . Config.Usuario.ProyectoActual . ".ini"
	camposGuardar := Config.Comandos.CamposGuardar
	Loop % _DicArgsInfo.campos.MaxIndex()
	{
		idx := A_Index
		GuiControlGet, valor,, Arg_%idx%
		param := _DicArgsInfo.campos[idx]
		if (valor != "") 
		{
			valor := LimpiarRutaParaConsola(valor)
			if param in %camposGuardar%
			{
				IniWrite, %valor%, %proyectoIni%, Memoria, %param%
			}
			linea .= " --" . param . "=""" . valor . """"
		}
	}
	GuardarPosicionFormComando()
	Gui, FormComando:Destroy
	EnviarComandoConsola(linea)
return

CancelarFormComando:
	Gui, FormComando:Destroy
return

SelectorHacerVolver:
	GuiControlGet, btnHwnd, FocusV
	Gui FormComando:+OwnDialogs
	idx := _DicSelectoresRutas[btnHwnd]
	if !idx
		return
	param := _DicArgsInfo.campos[idx]
	valorActual := ""
	GuiControlGet, valorActual,, Arg_%idx%
	Loop % _DicArgsInfo.campos.MaxIndex()
	{
		GuiControlGet, valor,, Arg_%A_Index%
		if (_DicArgsInfo.campos[A_Index] = "app" && valor != "") {
			Config.Base.App := valor
		}
	}
	rutaBase := ""
	; Si hay valor actual válido, lo usamos como ruta base
	if (valorActual != "")
	{
		testRuta := valorActual
		testRuta := StrReplace(testRuta, "/", "\")  ; Asegurar formato Windows
		; Si no es ruta absoluta, la reconstruimos desde la ruta proyecto
		if !RegExMatch(testRuta, "^\w:[\\/]")
			testRuta := Config.Base.RutaProyecto . "\" . testRuta

		; Verificamos si existe archivo o carpeta
		if (EsCampoCarpeta(param) && InStr(FileExist(testRuta), "D"))
			rutaBase := testRuta
		else if FileExist(testRuta)
			rutaBase := testRuta
	}
	; Si no hay valor actual válido, usar ruta desde INI
	if (rutaBase = "")
		rutaBase := ObtenerDirArchivosCampos(param)
	if (rutaBase = "")
		rutaBase := Config.Base.RutaProyecto
	; Ejecutar selección según tipo
	if param in carpeta,folder,dir
	{
		FileSelectFolder, selPath, *%rutaBase%, 0, Selecciona una carpeta
	}
	else
	{
		cfgIni := Config.Base.CfgIni
		IniRead, ext, %cfgIni%, ExtArchivosCampos, %param%, % ""
		filtro := "*.*"
		if (ext != "" && ext != "ERROR")
			filtro := ext
		FileSelectFile, selPath, 3, %rutaBase%, Selecciona un archivo, %filtro%
	}
	if (selPath != "")
	{
		valor := LimpiarRutaParaConsola(selPath)
		GuiControl,, Arg_%idx%, %valor%
	}
return

; ====================
; FUNCIONES
; ====================

MostrarFormComando(script, comando, args, tmenu, titulo) {
	local anchoCampoRuta, campos := [], etiquetas := [], valores := [], x := 10, y := 10, valor
	local nombreScript := StrReplace(script, ".php", "")
	local nombreMenu := StrReplace(tmenu, "Comandos", "")
	local anchoCampo := Config.Comandos.AnchoCampo
	local anchoEtiq := Config.Comandos.AnchoEtiq
	local camposArchivo := Config.Comandos.CamposArchivo
	local anchoForm := Config.Comandos.AnchoForm
	local formX := Config.Usuario.formX
	local formY := Config.Usuario.formY
	local fuenteTamano := Config.Gui.FuenteTamano
	local fuenteNombre := Config.Gui.FuenteNombre
	local proyectoIni := Config.Base.AppDir . "\ini\" . Config.Base.Entorno . "_" . Config.Usuario.ProyectoActual . ".ini"
	Loop Parse, args, %A_Space%
	{
		if (A_LoopField = "")
			continue
		if RegExMatch(A_LoopField, "--([\w-]+)=<([^>]+)>", m) 
		{
			param := m1
			label := m2
			campos.Push(param)
			etiquetas.Push(label)
			IniRead, valor, %proyectoIni%, Memoria, %param%, % ""
			if (valor = "ERROR") {
				valor := ""
			}
			valores.Push(valor)
		}
	}
	if (campos.MaxIndex() = 0) 
	{
		MsgBox, 4112, ERROR, No se detectaron argumentos válidos, 5
		return
	}
	Gui, FormComando:New
	Gui, FormComando:+EscapeCancel
	Gui, FormComando:+AlwaysOnTop
	Gui, FormComando:Font, s%fuenteTamano%, %fuenteNombre%
	Gui, FormComando:Font, Bold
	Gui, FormComando:Add, Text, x%x% y%y% w%anchoForm% Center, %nombreMenu%:  %titulo%
	y += 25
	Gui, FormComando:Font, Normal
	Gui, FormComando:Add, Text, x%x% y%y% w%anchoForm% Center, Completa los valores requeridos:
	y += 25
	Loop % campos.MaxIndex()
	{
		idx := A_Index
		param := campos[idx]
		label := etiquetas[idx]
		label := StrReplace(label, "_", " ")
		valorGuardado := valores[idx]
		anchoCampoRuta := (anchoCampo - 35)
		Gui, FormComando:Add, Text, x%x% y%y% w%anchoEtiq%, % label ":"
		if (_DicOpcionesCampos[param] != "") 
		{
			Gui, FormComando:Add, DropDownList, x+1 y%y% w%anchoCampo% vArg_%idx%, % _DicOpcionesCampos[param]
			GuiControl, FormComando:ChooseString, Arg_%idx%, %valorGuardado%
		} else {
			isArchivo := false, isCarpeta := false
			if param in %camposArchivo%
				isArchivo := true
			if param in carpeta,folder,dir
				isCarpeta := true
			if (isArchivo || isCarpeta) 
			{
				Gui, FormComando:Add, Edit, r1 x+1 y%y% w%anchoCampoRuta% vArg_%idx%, %valorGuardado%
				btnLabel := isArchivo ? "📄" : "📂"
				nombBtn := "Selector_" . idx
				Gui, FormComando:Add, Button, x+5 yp w30 v%nombBtn% gSelectorHacerVolver, %btnLabel%
				_DicSelectoresRutas[nombBtn] := idx
			} else {
				Gui, FormComando:Add, Edit, x+1 y%y% w%anchoCampo% vArg_%idx%, %valorGuardado%
			}
		}
		y += 30
	}
	y += 30
	Gui, FormComando:Font, Bold
	Gui, FormComando:Add, Button, x%x% y%y% w80 gEnviarFormComando Default, Ejecutar
	Gui, FormComando:Font, Normal
	Gui, FormComando:Add, Button, x+5 y%y% w80 gCancelarFormComando, Cancelar
	y += 40
	Gui, FormComando:Show, w%anchoForm% h%y% x%formX% y%formY%, Comando
	OnMessage(0x100, "EscCerrarFormComando")
	_DicArgsInfo := {campos: campos, ruta: script, comando: comando, valores: valores}
}

CargarDefinicionComandos() {
	local campos, grupo, titulo, icono, script, comando, args, contenido, rutaIcono, msg
	_DicSelectoresRutas := {}
	_DicArgsInfo := {}
	_DicOpcionesCampos := {}
	_ListaComandos := []
    comandosSubmenus := Object()
	rutaDefComandos := Config.Rutas.DefComandos
	if !FileExist(rutaDefComandos)
		return
	FileRead, contenido, %rutaDefComandos%
	if ErrorLevel
		return
	try {
		Loop Parse, contenido, `n, `r 
		{
			if (StrLen(A_LoopField) < 5 || SubStr(Trim(A_LoopField), 1, 1) = ";")
				continue
			campos := StrSplit(A_LoopField, "|")
			submenu := Trim(campos[1])
			titulo := Trim(campos[2])
			icono := Trim(campos[3])
			script := Trim(campos[4])
			comando := Trim(campos[5])
			args := Trim(campos[6])
			if !comandosSubmenus.HasKey(submenu) 
			{
				MenuID := "Comandos" . submenu
				Menu, %MenuID%, Add
				Menu, _ListaComandos, Add, %submenu%, :%MenuID%
				comandosSubmenus[submenu] := true
			}
			MenuID := "Comandos" . submenu
			Menu, %MenuID%, Add, %titulo%, EjecutarComando
			if (icono != "") 
			{
				rutaIcono := Config.Rutas.ImgDir . "\" . icono
				if FileExist(rutaIcono)
					Menu, %MenuID%, Icon, %titulo%, %rutaIcono%, 1
			}
			_ListaComandos.Push({menu: MenuID, titulo: titulo, script: script, comando: comando, args: args})
		}
		if _ListaComandos.MaxIndex() > 0
			CargarOpcionesCampos()
	} catch e {
		msg := "Hay definiciones de Comandos no válidas"
		MsgBox, 4112, ERROR, %msg%, 5
	}
}

CargarOpcionesCampos() {
	local linea, lista, nombre, valores, cfgIni
	cfgIni := Config.Base.CfgIni
	IniRead, lista, %cfgIni%, OpcionesCampos
	Loop, Parse, lista, `n, `r
	{
		linea := Trim(A_LoopField)
		if (linea = "")
			continue
		kv := StrSplit(linea, "=")
		nombre := Trim(kv[1])
		valores := Trim(kv[2])
		_DicOpcionesCampos[nombre] := valores
	}
}

ObtenerDirArchivosCampos(campo) {
	local linea, lista, nombre, cfgIni, ruta, kv
	cfgIni := Config.Base.CfgIni
	IniRead, lista, %cfgIni%, DirArchivosCampos
	Loop, Parse, lista, `n, `r
	{
		linea := Trim(A_LoopField)
		if (linea = "")
			continue
		kv := StrSplit(linea, "=")
		nombre := Trim(kv[1])
		ruta := Trim(kv[2])
		if (nombre = campo && StrLen(ruta) > 0)
		{
			ruta := StrReplace(ruta, "[MiApp]", Config.Base.App)
			ruta := AplicarVariablesEnRuta(ruta)
			return ruta
		}
	}
	return ""
}

GuardarPosicionFormComando() {
	local x, y, cfgIni
	cfgIni := Config.Base.CfgIni
	WinGetPos, x, y, , , Comando
	IniWrite, %x%, %cfgIni%, Usuario, formX
	IniWrite, %y%, %cfgIni%, Usuario, formY
	Config.Usuario.formX := x
	Config.Usuario.formY := y
}

EscCerrarFormComando(wParam, lParam, msg, hwnd) {
	if (wParam = 27)
		Gui, FormComando:Destroy
}

LimpiarRutaParaConsola(ruta) {
	ruta := StrReplace(ruta, Config.Base.RutaProyecto . "\", "")
	ruta := StrReplace(ruta, "\", "/")
	if (SubStr(ruta, 1, 1) = "/")
		ruta := SubStr(ruta, 2)
	return ruta
}

IniciarConsolaPersistente() {
	local titulo := Config.Comandos.ConsolaTitulo
	local rutaTrabajo := AplicarVariablesEnRuta(Config.Comandos.DirTrabajo)
	rutaTrabajo := StrReplace(rutaTrabajo, "[MiProyecto]", Config.Usuario.ProyectoActual)
	if !WinExist(titulo) {
		Run, %ComSpec% /k "cd /d `"%rutaTrabajo%`" & title %titulo%", , Min
		WinWait, %titulo%
	}
}

EnviarComandoConsola(comando) {
	local titulo := Config.Comandos.ConsolaTitulo
	IniciarConsolaPersistente()
	WinActivate, %titulo%
	WinWaitActive, %titulo%
	Sleep, 100
	ControlSend,, {Text}%comando%`n, %titulo%
}

EsCampoCarpeta(param) {
    return (param = "carpeta" || param = "folder" || param = "dir")
}
