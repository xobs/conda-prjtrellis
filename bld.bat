set VCPKG_COMMIT=8900146533f8e38266ef89766a2bbacffcb67836
set PATH=C:\tools\vcpkg;%PATH%
powershell %RECIPE_DIR%\bld.ps1 install
if errorlevel 1 exit 1