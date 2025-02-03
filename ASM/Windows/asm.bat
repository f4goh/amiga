@echo off
REM Répertoire contenant vasmm68k_mot et vlink
set TOOLS_DIR=C:\amiga\ASM\Windows

REM Vérifiez si un argument est passé
if "%~1"=="" (
    echo Usage: asm nom_fichier.s
    exit /b 1
)

REM Nom du fichier source et sortie
set SOURCE_FILE=%~1
set BASE_NAME=%~n1

REM Vérifiez si le fichier source existe
if not exist "%SOURCE_FILE%" (
    echo Erreur : fichier source "%SOURCE_FILE%" introuvable.
    exit /b 2
)

REM Exécuter l'assemblage
"%TOOLS_DIR%\vasmm68k_mot.exe" -m68000 -Fhunk -linedebug -devpac -o "%BASE_NAME%.o" "%SOURCE_FILE%"
if %errorlevel% neq 0 (
    echo Erreur lors de l'assemblage avec vasmm68k_mot.
    exit /b 3
)

REM Lier le fichier objet
"%TOOLS_DIR%\vlink.exe" -bamigahunk -Bstatic -o "%BASE_NAME%" "%BASE_NAME%.o"
if %errorlevel% neq 0 (
    echo Erreur lors du lien avec vlink.
    exit /b 4
)

echo Compilation reussie : %BASE_NAME%.o et %BASE_NAME% generes.
