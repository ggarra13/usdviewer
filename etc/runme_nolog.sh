#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# usdviewer
# Copyright Contributors to the usdviewer Project. All rights reserved.

#
#
# Main build script for usdviewer.  It builds all dependencies and will install the
# main executable on BUILD-OS-ARCH/BUILD_TYPE/install/bin.
#
# On Linux and macOS, it will also create a usdviewer or usdviewer-dbg symbolic link
# in $HOME/bin if the directory exists.
#
# This script does *NOT* save a log to  BUILD-OS-ARCH/BUILD_TYPE/compile.log.
# Use runme.sh for that.
#
#

if [[ !$RUNME ]]; then
    . $PWD/etc/build_dir.sh
fi

#
# Set environment variables to point to install directory
#
export PATH="$PWD/${BUILD_DIR}/install/bin:$PWD/$BUILD_DIR/install/bin/Scripts:${PATH}"
echo "PATH is now set now to ${PATH}"
echo "It has:"
mkdir -p $PWD/${BUILD_DIR}/install/bin/

if [[ $INSTALL_CMAKE == 1 ]]; then
    . etc/install_cmake.sh
fi

#
# Extract cmake version and location
#
get_cmake_version

#
# Extract git version and location
#
get_git_version

#
# Get the compilers
#
get_compilers

#
# These are some of the expensive usdviewer options
#
if [ -z "$BUILD_VCPKG" ]; then
    export BUILD_VCPKG=OFF
 fi

if [ -z "$BUILD_GETTEXT" ]; then
    export BUILD_GETTEXT=OFF
fi

if [ -z "$BUILD_WAYLAND" ]; then
    export BUILD_WAYLAND=ON
fi

if [ -z "$BUILD_X11" ]; then
    export BUILD_X11=ON
fi

if [ -z "$USDVIEWER_BACKEND" ]; then
    export USDVIEWER_BACKEND=VK
fi

if [ -z "$USDVIEWER_CPPTRACE" ]; then
    export USDVIEWER_CPPTRACE=ON
fi

if [ -z "$USDVIEWER_PYTHON" ]; then
    if [[ $BUILD_PYTHON == ON || $BUILD_PYTHON == 1 ]]; then
	if [[ $KERNEL == *Windows* ]]; then
	    export PYTHONEXE=python.exe
	else
	    export PYTHONEXE=python3
	fi
	export PYTHON="${PWD}/${BUILD_DIR}/install/bin/${PYTHONEXE}"
    else
	locate_python
    fi
    export USDVIEWER_PYTHON=$PYTHON
    export TLRENDER_USD_PYTHON=$PYTHON
else
    export TLRENDER_USD_PYTHON=$USDVIEWER_PYTHON
    export PYTHON=$USDVIEWER_PYTHON
fi

if [ -z "$USDVIEWER_VK" ]; then
    export USDVIEWER_VK=ON
fi


if [ -z "$TLRENDER_EXR" ]; then
    export TLRENDER_EXR=ON
fi

if [ -z "$TLRENDER_OPENJPH" ]; then
    export TLRENDER_OPENJPH=ON
fi

if [ -z "$TLRENDER_PNG" ]; then
    export TLRENDER_PNG=ON
fi

if [ -z "$TLRENDER_USD" ]; then
    export TLRENDER_USD=ON
fi

if [ -z "$VULKAN_SDK" ]; then
    if [[ $KERNEL == *Windows* ]]; then
	vulkan_root=/C/VulkanSDK
	if [[ -d $vulkan_root ]]; then
	    SDK_VERSION=$(ls -d ${vulkan_root}/* | sort -r | grep -o "$vulkan_root/[0-9]*\..*"| sed -e "s#$vulkan_root/##" | head -1)
	    export VULKAN_SDK=$vulkan_root/$SDK_VERSION/
	else
	    export VULKAN_SDK=$vulkan_root
	fi
    elif [[ $KERNEL == *Linux* ]]; then
	if [[ -d VulkanSDK-Linux ]]; then
	    vulkan_root=$PWD/VulkanSDK-Linux
	    SDK_VERSION=$(ls -d ${vulkan_root}/* | sort -r | grep -o "$vulkan_root/[0-9]*\..*"| sed -e "s#$vulkan_root/##" | head -1)
	    export VULKAN_SDK=$vulkan_root/$SDK_VERSION/$UNAME_ARCH
	else
	    export VULKAN_SDK=/usr/
	fi
    elif [[ $KERNEL == *Darwin* ]]; then
	if [[ -d VulkanSDK-Darwin ]]; then
	    vulkan_root=$PWD/VulkanSDK-Darwin
	    if [ -d "$vulkan_root" ]; then
		SDK_VERSION=$(ls -d ${vulkan_root}/* | sort -r | grep -o "$vulkan_root/[0-9]*\..*"| sed -e "s#$vulkan_root/##" | head -1)
		export VULKAN_SDK=$vulkan_root/$SDK_VERSION/macOS
	    fi
	fi

	if [ ! -d "$VULKAN_SDK" ]; then
	    if [[ -d /usr/local/include/vulkan ]]; then
		export VULKAN_SDK=/usr/local/
	    else
		export VULKAN_SDK=/opt/homebrew/
	    fi
	fi
    fi
    if [[ -e "$VULKAN_SDK/include/vulkan/vulkan.h" ]]; then
	echo "Guessed VULKAN_SDK to ${VULKAN_SDK}"
    else
	echo "Coukd not guess VULKAN_SDK, last guess ${VULKAN_SDK}"
	unset VULKAN_SDK
	export TLRENDER_VK=OFF
	export USDVIEWER_HDR=OFF
    fi
else
    echo "Using VULKAN_SDK from environment: ${VULKAN_SDK}"
    if [[ ! -e "${VULKAN_SDK}/include/vulkan/vulkan.h" ]]; then
	echo "Could not find vulkan.h in ${VULKAN_SDK}/include"
	exit 1
    fi
fi
    
if [ -z "$TLRENDER_VK" ]; then
    export TLRENDER_VK=OFF
    if [ -e "${VULKAN_SDK}/include/vulkan/vulkan.h" ]; then
	export TLRENDER_VK=ON
	echo "Vulkan FOUND at ${VULKAN_SDK}/include/"
    else
	echo "Vulkan NOT FOUND!"
	exit 1
    fi
fi
    
if [ -z "$TLRENDER_WAYLAND" ]; then
    export TLRENDER_WAYLAND=${BUILD_WAYLAND}
fi

if [ -z "$TLRENDER_X11" ]; then
    export TLRENDER_X11=${BUILD_X11}
fi

if [ -z "$FLTK_BUILD_SHARED" ]; then
    export FLTK_BUILD_SHARED=ON
fi

    
#
# Clean python path to avoid clashes, mainly, with macOS meson
#
unset PYTHONPATH

#
# For Windows mainly, make sure we use UTF8 encoding.
#
#  export PYTHONUTF8=1  USD needs it, meson fails.

echo
echo
echo "Building summary"
echo "================"
echo
echo "usdviewer version to build is v${usdviewer_VERSION}"
echo "User is ${USER}"
echo
echo "Build directory is ${BUILD_DIR}"
echo "Build type      is ${CMAKE_BUILD_TYPE}"
echo "Build cores     is ${CPU_CORES}"
echo
echo "C COMPILERS"
echo "-----------"
echo "Native C compiler ${NATIVE_C_COMPILER_NAME} version ${NATIVE_C_COMPILER_VERSION}"
echo "${NATIVE_C_COMPILER}"
echo "Generic C compiler ${GENERIC_C_COMPILER_NAME} version ${GENERIC_C_COMPILER_VERSION}"
echo "${GENERIC_C_COMPILER}"
echo "GNU C compiler ${GNU_C_COMPILER_NAME} ${GNU_C_COMPILER_VERSION}"
echo
echo "CXX COMPILERS"
echo "-------------"
echo "Native CXX compiler ${NATIVE_CXX_COMPILER_NAME} version ${NATIVE_CXX_COMPILER_VERSION}"
echo "${NATIVE_CXX_COMPILER}"
echo "Generic CXX compiler with ${GENERIC_CXX_COMPILER_NAME} version ${GENERIC_CXX_COMPILER_VERSION}"
echo "${GENERIC_CXX_COMPILER}"
echo "GNU CXX compiler ${GNU_CXX_COMPILER_NAME} ${GNU_CXX_COMPILER_VERSION}"
echo
echo "LINKERS"
echo "-------"
echo "Native linker ${NATIVE_LINKER_NAME} version ${NATIVE_LINKER_VERSION}"
echo "Generic linker with ${GENERIC_LINKER_NAME} version ${GENERIC_LINKER_VERSION}"
echo "GNU linker ${GNU_LINKER_NAME} version ${GNU_LINKER_VERSION}"
echo
echo "ARCHIVERS"
echo "---------"
echo "Native archiver ${NATIVE_ARCHIVER_NAME} version ${NATIVE_ARCHIVER_VERSION}"
echo "Generic archiver with ${GENERIC_ARCHIVER_NAME} version ${GENERIC_ARCHIVER_VERSION}"
echo "GNU arhiver ${GNU_ARCHIVER_NAME} version ${GNU_ARCHIVER_VERSION}"
echo



echo "CMake at: ${CMAKE_LOCATION} ${CMAKE_VERSION}"
echo "Git at: ${GIT_LOCATION} ${GIT_VERSION}"
if [[ $KERNEL == *Darwin* ]]; then
    echo "Building on MacOS Brand ${MACOS_BRAND}"
fi
echo "Compiler flags are ${FLAGS}"
if [[ $KERNEL == *Windows* ]]; then
    if command -v makensis.exe > /dev/null 2>&1; then
	nsis_exe=makensis.exe
    else
	nsis_exe="/C/Program Files (x86)/NSIS/bin/makensis"
    fi
    if command -v "$nsis_exe" >/dev/null 2>&1; then
	nsis_version=`"${nsis_exe}" -version`
	echo "NSIS ${nsis_version}"
    else
	echo "NSIS not found"
    fi
fi


if [[ $KERNEL == *Linux* ]]; then
    echo "Common options"
    echo
    echo "Wayland support .................... ${TLRENDER_WAYLAND} 	(BUILD_WAYLAND)"
    echo "X11 support ........................ ${TLRENDER_X11}     	(BUILD_X11)"
    echo
fi

echo "usdviewer Options"
echo
echo "Build vcpkg......................... ${BUILD_VCPKG}	(BUILD_VCPKG)"
echo "Python location: ${USDVIEWER_PYTHON}"
echo "Build FLTK shared................... ${FLTK_BUILD_SHARED} 	(FLTK_BUILD_SHARED)"
echo "usdviewer BACKEND........................ ${USDVIEWER_BACKEND} 	(USDVIEWER_BACKEND)"
echo
echo "tlRender Options"
echo

# echo "libplacebo support ............. ${TLRENDER_LIBPLACEBO}         (TLRENDER_LIBPLACEBO)"
echo

if [[ $TLRENDER_VK == ON || $TLRENDER_VK == 1 ]]; then
    echo "VULKAN_SDK    .................. ${VULKAN_SDK} 	(env. variable)"
fi
    
echo
echo "OpenJPH support .................... ${TLRENDER_OPENJPH} 	(TLRENDER_OPENJPH)"
echo "OpenEXR support .................... ${TLRENDER_EXR} 	(TLRENDER_EXR)"
#echo "SSL support ........................ ${TLRENDER_SSL} 	(TLRENDER_SSL)"
echo "USD support ........................ ${TLRENDER_USD} 	(TLRENDER_USD)"


if [[ $ASK_TO_CONTINUE == 1 ]]; then
    ask_to_continue
fi

#
# Handle Windows pre-flight compiles
#
if [[ $KERNEL == *Windows* ]]; then
    . $PWD/etc/windows/compile_dlls.sh
fi

if command -v swig > /dev/null 2>&1; then
    swig -version
else
    echo
    echo "swig NOT found!!! Cannot compile pyFLTK."
    echo
    exit 1
fi

#
# Work-around FLTK's CMakeLists.txt bug
#
rm -rf $BUILD_DIR/install/include/FL

cd $BUILD_DIR

#
# Handle Microsoft vcpkg variables
#
unset  VCPKG_ROOT
export VCPKG_INSTALL_PREFIX=$PWD/install

cmd="cmake -G 'Ninja'
	   -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
           -D CMAKE_VERBOSE_MAKEFILE=${CMAKE_VERBOSE_MAKEFILE}

	   -D CMAKE_INSTALL_PREFIX=$PWD/install
	   -D CMAKE_PREFIX_PATH=$PWD/install

           -D CMAKE_OSX_ARCHITECTURES=\"${CMAKE_OSX_ARCHITECTURES}\"
           -D CMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}

	   -D BUILD_VCPKG=${BUILD_VCPKG}

	   -D BUILD_X11=${BUILD_X11}
	   -D BUILD_WAYLAND=${BUILD_WAYLAND}
	   -D BUILD_GETTEXT=${BUILD_GETTEXT}

	   -D USDVIEWER_BACKEND=${USDVIEWER_BACKEND}
	   -D USDVIEWER_CPPTRACE=${USDVIEWER_CPPTRACE}
	   -D USDVIEWER_VK=${USDVIEWER_VK}

	   -D FLTK_BUILD_SHARED=${FLTK_BUILD_SHARED}

	   -D TLRENDER_OPENJPH=${TLRENDER_OPENJPH}
           -D TLRENDER_EXR=${TLRENDER_EXR}
           -D TLRENDER_PNG=${TLRENDER_PNG}
	   -D TLRENDER_USD=${TLRENDER_USD}
	   -D TLRENDER_VK=${TLRENDER_VK}
	   -D TLRENDER_WAYLAND=${TLRENDER_WAYLAND}
           -D TLRENDER_X11=${TLRENDER_X11}
	   -D TLRENDER_PROGRAMS=OFF
	   -D TLRENDER_EXAMPLES=OFF
	   -D TLRENDER_TESTS=OFF
	   -D TLRENDER_USD_PYTHON=\"${TLRENDER_USD_PYTHON}\"

	   -D NATIVE_C_COMPILER=\"${NATIVE_C_COMPILER}\"
	   -D GENERIC_C_COMPILER=\"${GENERIC_C_COMPILER}\"
	   -D GNU_C_COMPILER=\"${GNU_C_COMPILER}\"

	   -D NATIVE_CXX_COMPILER=\"${NATIVE_CXX_COMPILER}\"
	   -D GENERIC_CXX_COMPILER=\"${GENERIC_CXX_COMPILER}\"
	   -D GNU_CXX_COMPILER=\"${GNU_CXX_COMPILER}\"

	   -D NATIVE_CXX_COMPILER_NAME=\"${NATIVE_CXX_COMPILER_NAME}\"
	   -D GENERIC_CXX_COMPILER_NAME=\"${GENERIC_CXX_COMPILER_NAME}\"
	   -D GNU_CXX_COMPILER_NAME=\"${GNU_CXX_COMPILER_NAME}\"

	   -D NATIVE_C_COMPILER_NAME=\"${NATIVE_C_COMPILER_NAME}\"
	   -D GENERIC_C_COMPILER_NAME=\"${GENERIC_C_COMPILER_NAME}\"
	   -D GNU_C_COMPILER_NAME=\"${GNU_C_COMPILER_NAME}\"
	   ${CMAKE_FLAGS} ../.."

time run_cmd $cmd

time run_cmd cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE --target all

cd -

if [[ "$CMAKE_TARGET" == "" ]]; then
    export CMAKE_TARGET="install"
fi

echo "Build target ${CMAKE_TARGET}"
cmd="./runmeq.sh ${CMAKE_BUILD_TYPE} -t ${CMAKE_TARGET}"
time run_cmd $cmd

if [[ "$CMAKE_TARGET" != "package" && "$CMAKE_TARGET" != "install" ]]; then
    . $PWD/etc/build_end.sh
fi

