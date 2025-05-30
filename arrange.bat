@echo off
setlocal enabledelayedexpansion

:main
set /p "source_folder=What folder are we organizing (or leave empty for download folder): "
if "%source_folder%"=="" set "source_folder=C:\Users\%USERNAME%\Downloads"

if not exist "%source_folder%" (
    echo Error: Folder "%source_folder%" does not exist!
    pause
    exit /b 1
)
set /p "dest_folder=Enter destination folder name (e.g., 'gifs'): "
if "%dest_folder%"=="" set "dest_folder=organized"

echo.
echo Enter file extensions to sort (separate with spaces, include the dot)
echo Example: .jpg .png .gif .pdf
set /p "extensions=Extensions: "

if "%extensions%"=="" (
    echo Error: No extensions specified!
    pause
    exit /b 1
)

echo.
echo ============================================
echo Configuration Summary:
echo Source folder: %source_folder%
echo Destination folder: %dest_folder%
echo Extensions: %extensions%
echo ============================================
echo.

set /p "confirm=Continue? (y/n, default y): "
if "%confirm%"=="" set "confirm=y"
if /i not "%confirm%"=="y" (
    echo Operation cancelled.
    pause
    exit /b 0
)

echo.
echo Starting file organization...

pushd "%source_folder%"

if not exist "%dest_folder%\" mkdir "%dest_folder%"

set moved_count=0
set total_count=0

for %%E in (%extensions%) do (
    echo.
    echo Processing %%E files...
    
    for %%F in (*%%E) do (
        if exist "%%F" (
            set /a total_count+=1
            echo Moving: %%F
            move "%%F" "%dest_folder%\" >nul 2>&1
            if !errorlevel! equ 0 (
                set /a moved_count+=1
            ) else (
                echo   Warning: Failed to move %%F
            )
        )
    )
)

popd

echo.
echo ============================================
echo Organization Complete!
echo Files moved: %moved_count%
echo Total files processed: %total_count%
echo Destination: %source_folder%\%dest_folder%
echo ============================================

set /p "open_folder=Open destination folder? (y/n, default n): "
if "%open_folder%"=="" set "open_folder=n"
if /i "%open_folder%"=="y" (
    explorer "%source_folder%\%dest_folder%"
)

set /p "repeat=Shall we do it for another folder? (y/n, default n): "
if "%repeat%"=="" set "repeat=n"
if /i "%repeat%"=="y" (
    goto main
)
