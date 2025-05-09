; ====================
; --mi-ayudante.ahk
; Script para AHK v1 (1.1.37)
; ====================
; Declaraciones y directivas iniciales
#Warn
#NoEnv
#Persistent
#SingleInstance Force
#NoTrayIcon
SendMode Input
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2
DetectHiddenWindows, On

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
#Include lib\base.ahk
#Include lib\gui.ahk
#Include lib\comandos.ahk
#Include lib\enlaces.ahk
#Include lib\proyectos.ahk
#Include lib\favoritos.ahk
#Include lib\logs.ahk
#Include lib\nuevo.ahk
