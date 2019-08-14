@ECHO OFF
set PATH=D:/Keysight/SystemVue2015.01/Tools/CMake/bin;%PATH%
@ECHO ON
mkdir build-win32-vs2010
cd build-win32-vs2010
cmake -DCMAKE_INSTALL_PREFIX=../output-vs2010 -G "Visual Studio 10" ../source
cd ..
pause
