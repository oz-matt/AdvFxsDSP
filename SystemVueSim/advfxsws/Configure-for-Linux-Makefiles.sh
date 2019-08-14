#!/bin/sh
mkdir build-linux64-release
cd build-linux64-release
cmake \
	-DCMAKE_C_COMPILER=$(which gcc) \
    -DCMAKE_CXX_COMPILER=$(which g++) \
	-DCMAKE_INSTALL_PREFIX=../output-linux64 \
	-DCMAKE_BUILD_TYPE=Release \
	-G "Unix Makefiles" \
	../source 
cd ..
mkdir build-linux64-debug
cd build-linux64-debug
cmake \
	-DCMAKE_C_COMPILER=$(which gcc) \
    -DCMAKE_CXX_COMPILER=$(which g++) \
	-DCMAKE_INSTALL_PREFIX=../output-linux64 \
	-DCMAKE_BUILD_TYPE=Debug \
	-G "Unix Makefiles" \
	../source
cd ..
