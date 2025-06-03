!define SEC_7za 2
!define SEC_gettext 3
!define SEC_sqlite 4
!define SEC_mkcert 5
!define SEC_pdftk 6
!define SEC_pandoc 7
!define SEC_wkhtmltopdf 8
!define SEC_ffmpeg 9

!macro GenerateAllSectionTools
    !insertmacro GenerateSectionTool 7za "CLI 7za" 466 0
    !insertmacro GenerateSectionTool gettext "CLI Gettext" 6080 1
    !insertmacro GenerateSectionTool sqlite "CLI SQLite" 14257 1
    !insertmacro GenerateSectionTool mkcert "CLI Mkcert" 5136 0
    !insertmacro GenerateSectionTool pdftk "CLI PDFtk" 9638 1
    !insertmacro GenerateSectionTool pandoc "CLI Pandoc" 216722 1
    !insertmacro GenerateSectionTool wkhtmltopdf "CLI Wkhtmltopdf" 88533 1
    !insertmacro GenerateSectionTool ffmpeg "CLI FFmpeg" 37121 1
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
!macroend

Function CheckIfInstalledAllTools
    !insertmacro CheckIfInstalledTool "7za" ${SEC_7za} 2
    !insertmacro CheckIfInstalledTool "gettext" ${SEC_gettext} 2
    !insertmacro CheckIfInstalledTool "sqlite" ${SEC_sqlite} 2
    !insertmacro CheckIfInstalledTool "mkcert" ${SEC_mkcert} 2
    !insertmacro CheckIfInstalledTool "pdftk" ${SEC_pdftk} 2
    !insertmacro CheckIfInstalledTool "pandoc" ${SEC_pandoc} 2
    !insertmacro CheckIfInstalledTool "wkhtmltopdf" ${SEC_wkhtmltopdf} 2
    !insertmacro CheckIfInstalledTool "ffmpeg" ${SEC_ffmpeg} 2
FunctionEnd
