@echo off
goto:$Main

:$Main
    setlocal EnableDelayedExpansion

    REM Default VS paths to check if no Paths.cmd file exists
    set "VISUAL_STUDIO_PATH_0=%programfiles(x86)%\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\msbuild.exe"
    set "VISUAL_STUDIO_PATH_1=%programfiles(x86)%\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\msbuild.exe"
    set "VISUAL_STUDIO_PATH_2=%programfiles(x86)%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\msbuild.exe"
    set "VISUAL_STUDIO_PATH_3=%programfiles(x86)%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\msbuild.exe"

    cd /d "%~dp0"
    if exist Debug rd /s /q Debug
    if exist Release rd /s /q Release
    if exist x64 rd /s /q x64

    if exist "%~dp0Paths.cmd" (
        REM Prefer Paths.cmd as Visual Studio path source if it exists.
        call "%~dp0Paths.cmd"
        goto:$Build
    ) else (
        REM Otherwise try to auto-detect the Visual Studio path.
        if exist "!VISUAL_STUDIO_PATH!" goto:$Build
        set "VISUAL_STUDIO_PATH=%VISUAL_STUDIO_PATH_0%"

        if exist "!VISUAL_STUDIO_PATH!" goto:$Build
        set "VISUAL_STUDIO_PATH=%VISUAL_STUDIO_PATH_1%"

        if exist "!VISUAL_STUDIO_PATH!" goto:$Build
        set "VISUAL_STUDIO_PATH=%VISUAL_STUDIO_PATH_2%"

        if exist "!VISUAL_STUDIO_PATH!" goto:$Build
        set "VISUAL_STUDIO_PATH=%VISUAL_STUDIO_PATH_3%"

        if exist "!VISUAL_STUDIO_PATH!" goto:$Build
        REM No default path found. Let the user know what to do.
        echo No Visual Studio installation found. Please configure it manually.
        echo  1. Copy 'Paths.cmd.template'.
        echo  2. Rename it to 'Paths.cmd'.
        echo  3. Enter your Visual Studio path in there.
        echo  4. Restart the build.
        REM Allow disabling pause to support non-interacting build chains.
        if NOT "%~1"=="-no-pause" pause
        goto:$MainEnd
    )

    :$Build
    REM Log the used Vistual Studio version.
    call "!VISUAL_STUDIO_PATH!" /p:Configuration=Release

    :$MainEnd
endlocal & exit /b %ERRORLEVEL%

