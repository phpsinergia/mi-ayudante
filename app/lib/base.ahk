; ====================
; --lib\base.ahk
; Script de módulo para AHK v1 (1.1.37)
; ====================

; ====================
; FUNCIONES
; ====================

CargarConfigIni() {
	local seccion, claves, valor, disco
	; Cargar valores desde config.ini
	IniRead, valor, config.ini, Base, Entorno, % ""
    ; Inicializar valores esenciales
    EnvGet, disco, HOMEDRIVE
	CfgIni := A_ScriptDir . "\ini\" . valor . ".ini"
	Config := {}
	Config.Base := {AppDir: A_ScriptDir, Disco: disco, App: "", RutaProyecto: "", IdProyecto: 1, CfgIni: CfgIni, Entorno: valor}
	; Cargar valores desde CfgIni
    local secciones := {App: {Nombre: "Aplicación AHK", Descripcion: "", Autor: "", Version: "0.1"}, Usuario: {ProyectoActual: "", winX: 120, winY: 120, formX: 0, formY: 0, MostrarFavoritos: 0}, Gui: {AnchoVentana: 320, ColorFondo: "White", ColorTexto: "Black", FuenteNombre: "Segoe UI", FuenteTamano: 9, Transparencia: 255, MargenSup: 10, MargenInf: 10, MargenIzq: 10, AnchoListaProy: 200, AnchoTabsFavoritos: 260, AltoFavorito: 25, AnchoBotonBarra: 24, AltoBotonBarra: 24, PosListaProy: 70, PosOpcionFavoritos: 70}, Comandos: {CamposArchivo: "", CamposGuardar: "", DirTrabajo: "", ConsolaTitulo: "Consola CLI", AnchoForm: 320, AnchoCampo: 180, AnchoEtiq: 100},  Rutas: {MisProyectos: "", EditorTxt: "notepad.exe", ArchivoLogs: "registro.log", DefComandos: "", DefMenus: "", DefProyectos: "", DefBotones: "", DefFavoritos: "", ImgDir: "", Logo: ""}}
    for seccion, claves in secciones {
        Config[seccion] := {}
        for clave, valorDefault in claves {
            IniRead, valor, %CfgIni%, %seccion%, %clave%, %valorDefault%
            ; Aplicar variables en rutas si corresponde
            if (seccion = "Rutas" && valor != "")
                valor := AplicarVariablesEnRuta(valor)
            ; Validaciones básicas
			if (valor = "" || valor = "ERROR")
				valor := valorDefault
            Config[seccion][clave] := valor
        }
    }
    if (Config.App.Autor != "")
        Config.App.Autor := A_YYYY . " © " . Config.App.Autor
}

AplicarVariablesEnRuta(ruta) {
	local misImg, appdata
	misImg := StrReplace(A_MyDocuments, "Documents", "Pictures")
	appdata := StrReplace(A_AppData, "Roaming", "")
	ruta := StrReplace(ruta, "[AppData]", appdata)
	ruta := StrReplace(ruta, "[ProgramFiles]", A_ProgramFiles)
	ruta := StrReplace(ruta, "[UserName]", A_UserName)
	ruta := StrReplace(ruta, "[WinDir]", A_WinDir)
	ruta := StrReplace(ruta, "[ComSpec]", A_ComSpec)
	ruta := StrReplace(ruta, "[MisDoc]", A_MyDocuments)
	ruta := StrReplace(ruta, "[Escritorio]", A_Desktop)
	ruta := StrReplace(ruta, "[Temp]", A_Temp)
	ruta := StrReplace(ruta, "[MisImg]", misImg)
	ruta := StrReplace(ruta, "[AppDir]", Config.Base.AppDir)
	ruta := StrReplace(ruta, "[Disco]", Config.Base.Disco)
	ruta := StrReplace(ruta, "[MisProyectos]", Config.Rutas.MisProyectos)
	ruta := StrReplace(ruta, "[Proyecto]", Config.Usuario.ProyectoActual)
	ruta := StrReplace(ruta, "[Entorno]", Config.Base.Entorno)
	return ruta
}

AbrirSiExiste(ruta) {
	if FileExist(ruta)
		Run, %ruta%
	else {
		SB_SetText("ERROR: Ruta no encontrada")
		Registrar("No se encontró la ruta: " . ruta, "ERROR")
	}
}

ActivarOAbrir(tituloVentana, ruta) {
	if WinExist(tituloVentana) {
		WinActivate, %tituloVentana%
		WinWaitActive, %tituloVentana%
		PostMessage, 0x0112, 0xF120,,, %tituloVentana%
	} else {
		if FileExist(ruta)
			Run, %ruta%
		else {
			SB_SetText("ERROR: Ruta no encontrada")
			Registrar("No se encontró la ruta: " . ruta, "ERROR")
		}
	}
}

AbrirElemento(tipo, destino, titulo) {
	local rutaEditorTxt, rutaLocal, e, mostrarError := false
    destino := AplicarVariablesEnRuta(destino)
	rutaEditorTxt := Config.Rutas.EditorTxt
    rutaLocal := Config.Base.Disco . destino
	SB_SetText("Abrir: " . titulo)
	try {
		if (tipo = "url") {
			Run, %destino%
		}
		else if (tipo = "local") {
			if FileExist(rutaLocal)
				ActivarOAbrir(titulo, rutaLocal)
			else if FileExist(destino)
				ActivarOAbrir(titulo, destino)
			else {
				mostrarError := true
			}
		}
		else if (tipo = "admin") {
			if FileExist(destino)
				Run, *RunAs "%destino%"
			else {
				mostrarError := true
			}
		}
		else if (tipo = "sistema") {
			AbrirSiExiste(destino)
		}
		else if (tipo = "editar") {
			if FileExist(rutaLocal)
				Run, %rutaEditorTxt% %rutaLocal%
			else if FileExist(destino)
				Run, %rutaEditorTxt% %destino%
			else {
				mostrarError := true
			}
		}
		else if (tipo = "editadmin") {
			if FileExist(destino)
				Run, *Runas %rutaEditorTxt% %destino%
			else {
				mostrarError := true
			}
		}
		else if (tipo = "funcion") {
			%destino%()
		}
		else if (tipo = "teclas") {
			Send %destino%
		}
		if (mostrarError = true)
		{
			SB_SetText("ERROR: Ruta no encontrada")
			Registrar("No se encontró la ruta: " . destino, "ERROR")
		}
	} catch e {
		SB_SetText("No se abrió: " . titulo)
		Registrar("No se abrió: " . titulo, "ERROR")
	}
}

BorrarCacheChrome() {
	local e
	try {
		if WinExist("Google Chrome")
			WinActivate, Google Chrome
		else
			Run, Chrome.exe
		WinWaitActive, Google Chrome
		Sleep, 500
		Send, ^+{Del}
	} catch e {
	}
}
