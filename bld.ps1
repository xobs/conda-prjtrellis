Set-StrictMode -Version 1.0
Set-PSDebug -Trace 1
$ErrorActionPreference = "stop"

# Allow us to access System.IO.Compression.GzipStream
Add-Type -AssemblyName System.IO.Compression.FileSystem

# $stage_temp = [System.Guid]::NewGuid().ToString()
# Set-Location $ENV:Temp
# New-Item -Type Directory -Name $stage_temp
# $stage = "$($ENV:Temp)\$($stage_temp)"
# $stage = "C:\Users\smc\AppData\Local\Temp\089ecb48-75ff-42b3-94e6-c707f76566d3"
$stage = "$($Env:PREFIX)"

# Set up vcpkg and ensure modules are installed
Set-Location C:\tools\vcpkg
git rev-parse HEAD
if ($LastExitCode -ne 0) { exit $LastExitCode }
git checkout $env:VCPKG_COMMIT
if ($LastExitCode -ne 0) { exit $LastExitCode }
.\bootstrap-vcpkg.bat
if ($LastExitCode -ne 0) { exit $LastExitCode }
vcpkg integrate install
if ($LastExitCode -ne 0) { exit $LastExitCode }
vcpkg install boost-filesystem:x64-windows-static boost-program-options:x64-windows-static boost-thread:x64-windows-static boost-python:x64-windows-static eigen3:x64-windows-static boost-dll:x64-windows-static
if ($LastExitCode -ne 0) { exit $LastExitCode }

python -V
if ($LastExitCode -ne 0) { exit $LastExitCode }
python -c 'import sys; print(sys.path)'
if ($LastExitCode -ne 0) { exit $LastExitCode }

# Check out (and build) prjtrellis
Write-Output ""
Set-Location $env:SRC_DIR
git submodule init
if ($LastExitCode -ne 0) { exit $LastExitCode }
git submodule update
if ($LastExitCode -ne 0) { exit $LastExitCode }
git log -1
if ($LastExitCode -ne 0) { exit $LastExitCode }

$prefix = "$($env:PREFIX.replace("\", "/"))"

# Configure and build libtrellis, which includes the various bitstream manipulation
# programs such as ecpmulti and ecppack.
Set-Location $env:SRC_DIR\libtrellis
cmake -DCMAKE_TOOLCHAIN_FILE=c:/tools/vcpkg/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static -G "Visual Studio 16 2019" -A "x64" -DBUILD_SHARED=OFF -DSTATIC_BUILD=ON "-DCMAKE_INSTALL_PREFIX=$prefix" .
if ($LastExitCode -ne 0) { exit $LastExitCode }
cmake --build . --target install --config Release
if ($LastExitCode -ne 0) { exit $LastExitCode }
