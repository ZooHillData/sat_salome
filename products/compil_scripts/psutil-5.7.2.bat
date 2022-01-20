@echo off

echo ##########################################################################
echo psutil %VERSION%
echo ##########################################################################

IF NOT DEFINED SAT_DEBUG (
  SET SAT_DEBUG=0
)

if NOT exist "%PRODUCT_INSTALL%" mkdir %PRODUCT_INSTALL%
REM clean BUILD directory
if exist "%BUILD_DIR%" rmdir /Q /S %BUILD_DIR%
mkdir %BUILD_DIR%
cd %SOURCE_DIR%
xcopy * %BUILD_DIR%\ /E /I /Q
cd %BUILD_DIR%
mkdir %PRODUCT_INSTALL%\Lib\site-packages
set PATH=%CWD%\bin;%PATH%
set PYTHONPATH=%PYTHONPATH%;%PRODUCT_INSTALL%\Lib\site-packages

echo.
echo *** 
%PYTHONBIN% setup.py build --debug install --prefix=%PRODUCT_INSTALL%
if NOT %ERRORLEVEL% == 0 (
  echo ERROR on psutil running %PYTHONBIN% setup.py build --debug install --prefix=%PRODUCT_INSTALL%
  exit 1
)
echo.
echo Product %PRODUCT_NAME% version: %VERSION%> %PRODUCT_INSTALL%\README.txt
echo Installation folder: %PYTHON_ROOT_DIR%>> %PRODUCT_INSTALL%\README.txt

echo.
echo ########## END