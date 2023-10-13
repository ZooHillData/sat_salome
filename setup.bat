@ECHO off
@SET VISUAL_STUDIO_VERSION=2017
@SET VISUAL_STUDIO_ARCHITECTURE=x64
@SET CURRENT_DIR=%CD%

:PARSE_OPTIONS
  IF NOT "%1"=="" (
    IF "%1"=="--visual-version" (
        @SET VISUAL_STUDIO_VERSION=%2
        SHIFT
    )
    IF "%1"=="--architecture" (
        @SET VISUAL_STUDIO_ARCHITECTURE=%2
        SHIFT
    )
    IF "%1"=="--help" (
        GOTO :SYNOPSIS
    )
    SHIFT
    GOTO :PARSE_OPTIONS
  )


REM external dependencies repository...
SET SOFTWARE_ROOT_DIR=
IF EXIST "C:\software" (
  SET SOFTWARE_ROOT_DIR=C:\software
) ELSE IF EXIST "C:\SALOME\software" (
  SET SOFTWARE_ROOT_DIR=C:\SALOME\software
) ELSE IF EXIST "D:\software" (
  SET SOFTWARE_ROOT_DIR=D:\software
) ELSE IF EXIST "E:\SFTW" (
  SET SOFTWARE_ROOT_DIR=E:\SFTW
) ELSE (
  ECHO FATAL: the external dependencies directory seems NOT to be installed where it is expected to be. Aborting...
  EXIT 1
)
ECHO INFO: %SOFTWARE_ROOT_DIR%

IF /I NOT "%JENKINS_BUILD%"=="1" GOTO DO_GENERATION
ECHO INFO: PATH environment variable is currently SET to: %PATH%


:DO_GENERATION

ECHO INFO: PATH is now SET to: %PATH%

REM mandatory.... otherwise sat/colorama module will crash when dumping messages...
SET PYTHONIOENCODING=utf-8

SET SC_NPROCESSORS_ONLN=%NUMBER_OF_PROCESSORS%

ECHO INFO: %SOFTWARE_ROOT_DIR%

REM MINGW aimed to provide gfortran compiler
SET MINGW_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\mingw-w64\x86_64-8.1.0-release-posix-seh-rt_v6-rev0\mingw64 (
   SET MINGW_ROOT_DIR=%SOFTWARE_ROOT_DIR%\mingw-w64\x86_64-8.1.0-release-posix-seh-rt_v6-rev0\mingw64
) ELSE (
  ECHO FATAL: Mingw64 seems to be missing on node %COMPUTERNAME%...
  EXIT 1
)

SET MINGW_32BIT_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\mingw-w64\i686-8.1.0-posix-sjlj-rt_v6-rev0\mingw32 (
   SET MINGW_32BIT_ROOT_DIR=%SOFTWARE_ROOT_DIR%\mingw-w64\i686-8.1.0-posix-sjlj-rt_v6-rev0\mingw32
) ELSE (
  ECHO WARNING: Mingw32 seems to be missing on node %COMPUTERNAME%...
)

REM CYGWIN is required in order to compile OmniORB
SET CYGWIN_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\cygwin64 (
  SET CYGWIN_ROOT_DIR=%SOFTWARE_ROOT_DIR%\cygwin64
) ELSE (
  ECHO FATAL: Cygwin64 seems NOT to be installed where it is expected to be on node %COMPUTERNAME%...
  EXIT 1
)
ECHO INFO: %CYGWIN_ROOT_DIR%

REM TEXLIVE
SET LATEX_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\texlive (
  SET LATEX_ROOT_DIR=%SOFTWARE_ROOT_DIR%\texlive
) ELSE (
  ECHO FATAL: texlive seems NOT to be installed where it is expected to be on node %COMPUTERNAME%...
  EXIT 1
)
ECHO INFO: %LATEX_ROOT_DIR%
SET PATH=%LATEX_ROOT_DIR%\2019\bin\win32;%PATH%

REM GHOSTSCRIPT
SET GS_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\gs\gs9.27 (
  SET GS_ROOT_DIR=%SOFTWARE_ROOT_DIR%\gs\gs9.27
) ELSE (
  ECHO FATAL: Ghostscript seems NOT to be installed where it is expected to be on node %COMPUTERNAME%...
  EXIT 1
)
ECHO INFO: %GS_ROOT_DIR%
SET PATH=%GS_ROOT_DIR%\bin;%PATH%

REM WINFLEX
SET WINFLEX_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\win_flex_bison-2.5.23 (
   SET WINFLEX_ROOT_DIR=%SOFTWARE_ROOT_DIR%\win_flex_bison-2.5.23
) ELSE (
  ECHO WARNING: winflexbison seems to be missing on node %COMPUTERNAME%...
)

REM rxspencer-3.8.g.3-1-bin
SET RXSPENCER_ROOT_DIR=
IF EXIST %SOFTWARE_ROOT_DIR%\rxspencer-3.8.g.3-1-bin (
  SET RXSPENCER_ROOT_DIR=%SOFTWARE_ROOT_DIR%\rxspencer-3.8.g.3-1-bin
) ELSE (
  ECHO WARNING: RXSPENCER_ROOT_DIR seems NOT to be installed where it is expected to be on node %COMPUTERNAME%...
)
ECHO INFO: %RXSPENCER_ROOT_DIR%


rem Add git.exe to the PATH
SET PATH=%SOFTWARE_ROOT_DIR%\PortableGit-2.21.0-64-bit\bin;%PATH%
REM add patch.exe to the PATH
SET PATH=%SOFTWARE_ROOT_DIR%\PortableGit-2.21.0-64-bit\usr\bin;%PATH%
SET PATH=%SOFTWARE_ROOT_DIR%\PortableGit-2.21.0-64-bit\cmd;%PATH%

rem Python 2.7.16
SET PATH=%SOFTWARE_ROOT_DIR%\Python2.7.16;%PATH%

rem 7-zip in user environment
SET PATH=%SOFTWARE_ROOT_DIR%\7-Zip;%PATH%

rem MS Visual environment in user environment
call "C:\Program Files (x86)\Microsoft Visual Studio\%VISUAL_STUDIO_VERSION%\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" %VISUAL_STUDIO_ARCHITECTURE%

ECHO Environment successfully set.. You should be able to use SAT now...
GOTO :EOF

:SYNOPSIS
  ECHO SYNOPSIS: call %~n0%~x0
  ECHO OPTIONS:
  ECHO   --visual-version : Visual Studio version, default value SET to %VISUAL_STUDIO_VERSION%
  ECHO   --architecture   : Visual Studio architecture, default value SET to %VISUAL_STUDIO_ARCHITECTURE%
  ECHO   --help        : this help
  echo.
  GOTO :EOF
	
:EOF
  cd %CURRENT_DIR%

