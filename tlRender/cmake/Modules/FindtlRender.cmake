# Find the tlRender library.
#
# This module defines the following variables:
#
# * tlRender_FOUND
# * tlRender_VERSION
# * tlRender_INCLUDE_DIRS
# * tlRender_LIBRARIES
#
# This module defines the following imported targets:
#
# * tlRender::tlCore
# * tlRender::tlVk
#
# This module defines the following interfaces:
#
# * tlRender

set(tlRender_VERSION 0.0.1)

#
# Use this variable to debug where libraries are found
#
#set(CMAKE_FIND_DEBUG_MODE TRUE)

find_package(Imath REQUIRED CONFIG)
find_package(nlohmann_json REQUIRED)
find_package(harfbuzz REQUIRED)
find_package(PNG REQUIRED)
find_package(Freetype REQUIRED)
#
# These may be installed in cmake or not installed if the setting is off
#
# set(CMAKE_FIND_DEBUG_MODE FALSE)


find_path(tlRender_INCLUDE_DIR NAMES tlCore/Util.h PATH_SUFFIXES tlRender)
set(tlRender_INCLUDE_DIRS
    ${tlRender_INCLUDE_DIR})


if(CMAKE_BUILD_TYPE MATCHES "^Debug$")
    find_library(tlRender_tlCore_LIBRARY NAMES tlCore)
    find_library(tlRender_tlVk_LIBRARY NAMES tlVk)
else()
    find_library(tlRender_tlCore_LIBRARY NAMES tlCore)
    find_library(tlRender_tlVk_LIBRARY NAMES tlVk)
endif()

set(tlRender_VK_FOUND FALSE)
set(tlRender_VK_LIBRARIES)
if(tlRender_tlVk_LIBRARY)
    set(tlRender_VK_FOUND TRUE)
    set(tlRender_VK_LIBRARIES
	${tlRender_tlVk_LIBRARY})
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    tlRender
    REQUIRED_VARS
        tlRender_INCLUDE_DIR
        tlRender_tlCore_LIBRARY
	tlRender_tlVk_LIBRARY)
mark_as_advanced(
    tlRender_INCLUDE_DIR
    tlRender_tlCore_LIBRARY
    tlRender_tlVk_LIBRARY)

set(tlRender_tlCore_LIBRARIES "harfbuzz::harfbuzz;Freetype::Freetype;PNG::PNG;Imath::Imath;nlohmann_json::nlohmann_json" )
if (tlRender_VK_FOUND)
    list(APPEND tlRender_tlIO_LIBRARIES tlRender::tlVk)
endif()
# if (pxr_FOUND)
#     list(APPEND tlRender_tlIO_LIBRARIES tf usd usdGeom)
# endif()
# if (tlRender_GL_FOUND AND pxr_FOUND)
#     list(APPEND tlRender_tlIO_LIBRARIES usdImagingGL usdAppUtils)
# endif()
# if (pxr_FOUND)
#     list(APPEND tlRender_tlIO_LIBRARIES usdUtils usdShade hio hd)
# endif()

set(tlRender_COMPILE_DEFINITIONS tlRender_FOUND)

if(tlRender_FOUND AND NOT TARGET tlRender::tlCore)
    add_library(tlRender::tlCore UNKNOWN IMPORTED)
    set_target_properties(tlRender::tlCore PROPERTIES
        IMPORTED_LOCATION "${tlRender_tlCore_LIBRARY}"
        INTERFACE_COMPILE_DEFINITIONS "${tlRender_COMPILE_DEFINITIONS}"
        INTERFACE_INCLUDE_DIRECTORIES "${tlRender_INCLUDE_DIR}"
        INTERFACE_LINK_LIBRARIES "${tlRender_tlCore_LIBRARIES}")
endif()

if (tlRender_VK_FOUND)
    if(tlRender_FOUND AND TLRENDER_VK AND NOT TARGET tlRender::tlVk)
	set(tlRender_tlVk_LIBRARIES "tlRender::tlCore")
	add_library(tlRender::tlVk UNKNOWN IMPORTED)
	set_target_properties(tlRender::tlVk PROPERTIES
            IMPORTED_LOCATION "${tlRender_tlVk_LIBRARY}"
            INTERFACE_COMPILE_DEFINITIONS "${tlRender_COMPILE_DEFINITIONS}"
            INTERFACE_INCLUDE_DIRECTORIES "${tlRender_INCLUDE_DIR}"
	    INTERFACE_LINK_LIBRARIES "${tlRender_tlVk_LIBRARIES}")
    endif()
endif()

if(tlRender_FOUND AND NOT TARGET tlRender)
    add_library(tlRender INTERFACE)
    target_link_libraries(tlRender INTERFACE tlRender::tlCore)
    if (tlRender_VK_FOUND)
	target_link_libraries(tlRender INTERFACE tlRender::tlVk)
    endif()
endif()
