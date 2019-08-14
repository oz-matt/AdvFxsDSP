cmake_minimum_required(VERSION 2.8.8)

# SystemVueInstallDirectory defined in ../CMakeLists.txt
include ( ${SystemVueInstallDirectory}/ModelBuilder/CMake/CodeGeneration.cmake )

# SystemVue code generation maintains this variable, do not add files to this variable
set ( SVU_GENERATED_FILES
	FIR.h
	FIR.cpp
	FIR.xml
@SVU_GENERATED_FILES@
)

# Change content below as necessary. For example, add more files, etc.

# Uncomment the lines below to customize the version information for your DLL.
# On the PC the info will show either by mousing-over your DLL or right
# clicking on the DLL and inspecting Properties -> Details.  On Linux, use the
# "ident" command to see the information.
# The version numbers below, can be up to 4 integers separated by periods.  For
# example, "1.20.22.3".   For more details, refer to the SystemVue documentation.
SVU_CREATE_VERSION_FILE(
	VERSION_FILE
	# FILE_VERSION 1.0
	# COMPANY_NAME "My Company Name"
	# COPYRIGHT "(c) My Company Name, "
	# PRODUCT_NAME "My Product Name"
	# PRODUCT_VERSION 1.0
	TARGET_TYPE "Standalone Library"
)

SVU_ADD_CG_STANDALONE_LIBRARY(
	StandaloneLib-advfxsws
	SHARED
	${SVU_GENERATED_FILES}
	${VERSION_FILE}
)

SVU_INSTALL_CG_STANDALONE_LIBRARY( StandaloneLib-advfxsws )
