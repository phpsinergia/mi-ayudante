!macro GenerateToolSections
    !insertmacro InstallTool 7za "CLI: 7za" 466 1
    !insertmacro InstallTool gettext "CLI: Gettext" 6080 1
    !insertmacro InstallTool sqlite "CLI: SQLite" 14257 1
    !insertmacro InstallTool mkcert "CLI: Mkcert" 5136 0
    !insertmacro InstallTool pdftk "CLI: PDFtk" 9638 1
    !insertmacro InstallTool pandoc "CLI: Pandoc" 216722 1
    !insertmacro InstallTool wkhtmltopdf "CLI: Wkhtmltopdf" 88533 1
    !insertmacro InstallTool ffmpeg "CLI: FFmpeg" 37121 1
    !insertmacro InstallTool scss "SCSS: Bootstrap" 11560 0
!macroend

!macro UninstallAllTools
    !insertmacro UninstallTool 7za
    !insertmacro UninstallTool gettext
    !insertmacro UninstallTool sqlite
    !insertmacro UninstallTool mkcert
    !insertmacro UninstallTool pdftk
    !insertmacro UninstallTool pandoc
    !insertmacro UninstallTool wkhtmltopdf
    !insertmacro UninstallTool ffmpeg
    !insertmacro UninstallTool scss
!macroend

Function PreSelectTools
    !insertmacro AutoSelectTool 7za
    !insertmacro AutoSelectTool gettext
    !insertmacro AutoSelectTool sqlite
    !insertmacro AutoSelectTool mkcert
    !insertmacro AutoSelectTool pdftk
    !insertmacro AutoSelectTool pandoc
    !insertmacro AutoSelectTool wkhtmltopdf
    !insertmacro AutoSelectTool ffmpeg
    !insertmacro AutoSelectTool scss
FunctionEnd
