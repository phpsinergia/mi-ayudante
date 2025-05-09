; ====================
; --lib\favoritos.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

global _DicFavoritosPorTab

; ====================
; ETIQUETAS
; ====================

AlternarFavoritos:
    Gui, Submit, NoHide
	cfgIni := Config.Base.CfgIni
    IniWrite, %OpcionFavoritos%, %cfgIni%, Usuario, MostrarFavoritos
	GuardarPosicionVentana()
    Reload
return

; ====================
; FUNCIONES
; ====================

CargarDefinicionFavoritos() {
	local contenido, linea, campos, grupo, titulo, url, icono, msg
	local rutaDefFavoritos := Config.Rutas.DefFavoritos
	_DicFavoritosPorTab := {}
	if !FileExist(rutaDefFavoritos)
		return 0
	FileRead, contenido, %rutaDefFavoritos%
    if ErrorLevel
        return 0
    if (contenido = "")
        return 0
	try {
		Loop, Parse, contenido, `n, `r
		{
			linea := Trim(A_LoopField)
			if (linea = "" || SubStr(linea, 1, 1) = ";")
				continue
			campos := StrSplit(linea, "|")
			if (campos.MaxIndex() < 4)
				continue
			grupo := Trim(campos[1])
			titulo := Trim(campos[2])
			icono := Trim(campos[3])
			url := Trim(campos[4])
			if (!_DicFavoritosPorTab.HasKey(grupo))
				_DicFavoritosPorTab[grupo] := []
			_DicFavoritosPorTab[grupo].Push({titulo: titulo, url: url, icono: icono})
		}
	} catch e {
		msg := "Hay definiciones de Favoritos no válidas"
		MsgBox, 4112, ERROR, %msg%, 5
		return 0
	}
}

CrearPestanasFavoritos(xx, yy) {
	local tabNombres := "", tab, favoritos, favorito, idx, linkText, _, xLink, yLink, wLink, maxPorGrupo, hTab
	local altoFavorito := Config.Gui.AltoFavorito
	local anchoTabsFavoritos := Config.Gui.AnchoTabsFavoritos
	local fuenteTamano := Config.Gui.FuenteTamano
	local posOpcionFavoritos := Config.Gui.PosOpcionFavoritos
	local mostrarFavoritos := Config.Usuario.MostrarFavoritos
	local colorTexto := Config.Gui.ColorTexto
	if !IsObject(_DicFavoritosPorTab) || (_DicFavoritosPorTab.Count() < 1)
		return yy
	Gui, Font, s%fuenteTamano% cGray Italic
	Gui, Add, Checkbox, vOpcionFavoritos x%posOpcionFavoritos% y%yy% Checked%mostrarFavoritos% gAlternarFavoritos, Mostrar favoritos
	Gui, Font, s%fuenteTamano% c%colorTexto% Normal
	yy += 24
	hTab = 25
	if (mostrarFavoritos) {
		maxPorGrupo := 0
		for tab, favoritos in _DicFavoritosPorTab {
			tabNombres .= tab . "|"
			cuenta := favoritos.Count()
			if (cuenta > maxPorGrupo)
				maxPorGrupo := cuenta
		}
		tabNombres := RTrim(tabNombres, "|")
		hTab := 45 + (maxPorGrupo * altoFavorito)
		Gui, Add, Tab2, x%xx% y%yy% w%anchoTabsFavoritos% h%hTab%, %tabNombres%
		yy += 40
		xIcono := xx + 10
		xLink := xIcono + 22
		wLink := anchoTabsFavoritos - 40
		for tab, favoritos in _DicFavoritosPorTab {
			Gui, Tab, %tab%
			yLink := yy
			for idx, favorito in favoritos {
				rutaIcono := Config.Rutas.ImgDir . "\" . favorito.icono
				if FileExist(rutaIcono)
					Gui, Add, Picture, x%xIcono% y%yLink% w16 h16, %rutaIcono%
				linkText := "<a href=""" . favorito.url . """>" . favorito.titulo . "</a>"
				Gui, Add, Link, x%xLink% y%yLink% w%wLink% h%altoFavorito%, %linkText%
				yLink += altoFavorito
			}
		}
		Gui, Tab
	}
	return yy + hTab - 25
}
