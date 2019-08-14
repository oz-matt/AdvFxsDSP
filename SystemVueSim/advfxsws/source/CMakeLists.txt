cmake_minimum_required(VERSION 2.8.8)

if( NOT UNIX )
	#Path to SystemVue installer directory on Windows.
	set( SystemVueInstallDirectory "D:/Keysight/SystemVue2015.01/")
else()
	#Path to SystemVue code generation libraries Linux.
	set( SystemVueInstallDirectory "$ENV{HOME}/SystemVue/2015.01")
endif()

include ( ${SystemVueInstallDirectory}/ModelBuilder/CMake/CodeGeneration.cmake )

project( advfxsws )

add_subdirectory( StandaloneLib )
add_subdirectory( SystemVue )
