!macro ToolEntry TOOL_ID TOOL_NAME TOOL_VERSION TOOL_SIZE TOOL_ADD_PATH
    !insertmacro DownloadAndExtract ${TOOL_ID} "${TOOL_NAME} ${TOOL_VERSION}" ${TOOL_SIZE} ${TOOL_ADD_PATH}
!macroend

!macro GenerateToolSections
    !insertmacro ToolEntry 7za "CLI: 7za" "v4.42" 466 1
    !insertmacro ToolEntry gettext "CLI: Gettext" "v0.19.8" 6080 1
    !insertmacro ToolEntry sqlite "CLI: SQLite" "v3.49.1" 14257 1
    !insertmacro ToolEntry mkcert "CLI: Mkcert" "v1.4.1" 5136 0
    !insertmacro ToolEntry pdftk "CLI: PDFtk" "v2.02" 9638 1
    !insertmacro ToolEntry pandoc "CLI: Pandoc" "v3.6.4" 216722 1
    !insertmacro ToolEntry wkhtmltopdf "CLI: Wkhtmltopdf" "v0.12.6" 88533 1
    !insertmacro ToolEntry ffmpeg "CLI: FFmpeg" "v7.1.1" 37121 1
    !insertmacro ToolEntry scss "SCSS: Bootstrap" "v5.3.1" 11560 0
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
