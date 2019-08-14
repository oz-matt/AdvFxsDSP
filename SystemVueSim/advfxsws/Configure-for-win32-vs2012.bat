@ECHO OFF
set PATH=D:/Keysight/SystemVue2015.01/Tools/CMake/bin;%PATH%
@ECHO ON
mkdir build-win32-vs2012
cd build-win32-vs2012
cmake -DCMAKE_INSTALL_PREFIX=../output-vs2012 -G "Visual Studio 11" ../source
cd ..
pause
