cmake_minimum_required(VERSION 3.25)

project(mrv2)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0114 NEW)
if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()

if(APPLE)
    message(STATUS "-------------------------------------------------")
    message(STATUS "Building for macOS ${CMAKE_OSX_DEPLOYMENT_TARGET}")
    message(STATUS "-------------------------------------------------")
endif()


include(cmake/version.cmake )
include(cmake/options.cmake )
include(cmake/functions.cmake )

# Use ccache if available to speed up rebuilds
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    message(STATUS "Found ccache: ${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER ${CCACHE_PROGRAM})
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE_PROGRAM})

    if(MSVC)
	# Replace /Zi or /ZI with /Z7 for ccache compatibility
	string(REPLACE "/Zi" "/Z7" CMAKE_CXX_FLAGS_DEBUG
	    "${CMAKE_CXX_FLAGS_DEBUG}")
	string(REPLACE "/ZI" "/Z7" CMAKE_CXX_FLAGS_DEBUG
	    "${CMAKE_CXX_FLAGS_DEBUG}")
	string(REPLACE "/Zi" "/Z7" CMAKE_C_FLAGS_DEBUG
	    "${CMAKE_C_FLAGS_DEBUG}")
    endif()
endif()

# Determine a repository root based on the current source directory.
get_filename_component(REPO_ROOT "${PROJECT_SOURCE_DIR}/tlRender" ABSOLUTE)
get_filename_component(SUPERBUILD_ROOT "${REPO_ROOT}/etc/SuperBuild" ABSOLUTE)

# Compute absolute module paths.
get_filename_component(MODULE_PATH1 "${REPO_ROOT}/cmake/Modules" ABSOLUTE)
get_filename_component(MODULE_PATH2 "${SUPERBUILD_ROOT}/cmake/Modules" ABSOLUTE)
get_filename_component(MODULE_PATH3 "${SUPERBUILD_ROOT}/cmake/" ABSOLUTE)

# Prepend to the CMAKE_MODULE_PATH.
list(PREPEND CMAKE_MODULE_PATH
    ${MODULE_PATH1}
    ${MODULE_PATH2}
    ${MODULE_PATH3}
)

# Omit superfluous "Up-to-date" messages.
if(NOT DEFINED CMAKE_INSTALL_MESSAGE)
    set(CMAKE_INSTALL_MESSAGE "LAZY")
endif()
   
string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" SYSTEM_PROCESSOR_LC)

# set(vcpkg_DEP )
# set(USE_VCPKG TRUE)
# if (BUILD_VCPKG)
#     include(cmake/Modules/Buildvcpkg.cmake)
# else()
#     #
#     # Use default vcpkg from MSVC
#     #
#     set(VCPKG vcpkg)
# endif()

# set(vcpkg_ARCH x64)
# if(SYSTEM_PROCESSOR_LC MATCHES "^(aarch64|arm64)$")
#     set(vcpkg_ARCH arm64)
# elseif(SYSTEM_PROCESSOR_LC MATCHES ".*(amd64|x86_64).*")
#     set(SYSTEM_PROCESSOR_LC amd64)
# endif()
    
# set(vcpkg_BUILD_TYPE debug)
# if (CMAKE_BUILD_TYPE MATCHES ".*Release.*")
#     set(vcpkg_BUILD_TYPE release)
# endif()

# set(vcpkg_OS "Unknown")
# if(WIN32)
#     set(vcpkg_OS "windows")
# elseif(APPLE)
#     set(vcpkg_OS "osx")
# else()
#     set(vcpkg_OS "linux")
# endif()

# set(VCPKG_TRIPLET "${vcpkg_ARCH}-${vcpkg_OS}")    

# message(STATUS "VCPKG running from ${VCPKG}")
# message(STATUS "VCPKG_TRIPLET=${VCPKG_TRIPLET}")


# \@todo:
# This is unused for now, as it is always out of date and does not do
# patches.
#set(CMAKE_TOOLCHAIN_FILE "${VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake")


#
# Handle libintl and gettext
#
# set(Gettext_DEP )
# include(cmake/Modules/BuildGettext.cmake )


# https://stackoverflow.com/questions/45414507/pass-a-list-of-prefix-paths-to-externalproject-add-in-cmake-args
string(REPLACE ";" "|" CMAKE_PREFIX_PATH_TMP "${CMAKE_PREFIX_PATH}")
string(REPLACE ";" "|" CMAKE_MODULE_PATH_TMP "${CMAKE_MODULE_PATH}")

    
#
# Python cannot be built with asan dependencies
#
set(PYTHON_DEP )
if (NOT EXISTS "${Python_EXECUTABLE}")
    find_package(Python COMPONENTS Interpreter)
    if (NOT EXISTS "${Python_EXECUTABLE}")
	# As a last resort...
	if (UNIX)
	    find_program(Python_EXECUTABLE NAMES python3 python)
	else()
	    find_program(Python_EXECUTABLE NAMES py.exe python.exe)
	endif()
    endif()
    if (NOT EXISTS "${Python_EXECUTABLE}")
	message(FATAL_ERROR "Python could not be located.  It is needed to build OpenUSD")
    endif()
    set(PYTHON_EXECUTABLE ${Python_EXECUTABLE})
endif()

message(STATUS "Python EXECUTABLE=${Python_EXECUTABLE}")


set(cpptrace_DEP )
if(NOT APPLE AND MRV2_CPPTRACE)
    include(cmake/Modules/Buildcpptrace.cmake)
endif()

# Optional Vulkan dependencies currently not used.
set(VMA_DEP )
set(SHADERC_DEP )


add_subdirectory(tlRender/etc/SuperBuild)

set(FLTK_DEP )
if(BUILD_FLTK)
    include(cmake/Modules/BuildFLTK.cmake)
    add_dependencies(tlRender ${FLTK_DEP})
endif()

include(cmake/Modules/Buildusdviewer.cmake)

