@echo off

echo ##########################################################################
echo cmake %VERSION%
echo ##########################################################################

if NOT exist "%PRODUCT_INSTALL%" mkdir %PRODUCT_INSTALL%

REM clean BUILD directory
if exist "%BUILD_DIR%" rmdir /Q /S %BUILD_DIR%
mkdir %BUILD_DIR%

set PLATFORM_TARGET=x64
if "%SALOME_APPLICATION_NAME%" == "URANIE" (
    set PLATFORM_TARGET=Win32
)

rem # Configuration
rem # According to cmake README, cmake is mandatory for compiling cmake on windows
set CMAKE_OPTIONS=-DCMAKE_INSTALL_PREFIX:STRING=%PRODUCT_INSTALL:\=/%
set CMAKE_OPTIONS=%CMAKE_OPTIONS% -DCMAKE_BUILD_TYPE:STRING=Release
if "%SALOME_APPLICATION_NAME%" == "URANIE" (
    set CMAKE_OPTIONS=%CMAKE_OPTIONS% -A Win32 -Thost=x64
    set CMAKE_OPTIONS=%CMAKE_OPTIONS% -DCMAKE_SYSTEM_VERSION=10.0.19041.0
)
set CMAKE_OPTIONS=%CMAKE_OPTIONS% -DCMAKE_GENERATOR=%CMAKE_GENERATOR%

set MSBUILDDISABLENODEREUSE=1

cd %BUILD_DIR%

echo.
echo --------------------------------------------------------------------------
echo cmake %CMAKE_OPTIONS% %SOURCE_DIR%
echo --------------------------------------------------------------------------
cmake %CMAKE_OPTIONS% %SOURCE_DIR%
if NOT %ERRORLEVEL% == 0 (
    echo "ERROR on cmake"
    exit 1
)

echo.
echo --------------------------------------------------------------------------
echo msbuild %MAKE_OPTIONS% /p:Configuration=Release /p:PlatformTarget=%PLATFORM_TARGET% ALL_BUILD.vcxproj
echo --------------------------------------------------------------------------
msbuild %MAKE_OPTIONS% /p:Configuration=Release /p:PlatformTarget=%PLATFORM_TARGET% ALL_BUILD.vcxproj  
if NOT %ERRORLEVEL% == 0 (
    echo ERROR on msbuild ALL_BUILD.vcxproj
    exit 2
)

echo.
echo --------------------------------------------------------------------------
echo msbuild %MAKE_OPTIONS% /p:Configuration=Release /p:PlatformTarget=%PLATFORM_TARGET% INSTALL.vcxproj
echo --------------------------------------------------------------------------
msbuild %MAKE_OPTIONS% /p:Configuration=Release /p:PlatformTarget=%PLATFORM_TARGET% INSTALL.vcxproj
if NOT %ERRORLEVEL% == 0 (
    echo ERROR on msbuild INSTALL.vcxproj
    exit 3
)
taskkill /F /IM "mspdbsrv.exe"

echo.
echo ########## END
