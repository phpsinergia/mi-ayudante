; ====================
; --modulos\inicio.ahk
; Script para AHK v1 (1.1.37)
; ====================

global Config

; Carga de configuraciones
CargarConfigIni()
CargarDefinicionComandos()
CargarDefinicionMenus()
CargarDefinicionFavoritos()
CargarDefinicionProyectos()

; Despliegue GUI
MostrarVentanaApp()

return

; Inclusiones de modulos
#Include modulos\base.ahk
#Include modulos\gui.ahk
#Include modulos\comandos.ahk
#Include modulos\enlaces.ahk
#Include modulos\proyectos.ahk
#Include modulos\favoritos.ahk
#Include modulos\entornos.ahk
#Include modulos\logs.ahk
