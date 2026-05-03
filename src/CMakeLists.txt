# SPDX-License-Identifier: BSD-3-Clause
# mrv2
# Copyright Contributors to the mrv2 Project. All rights reserved.

cmake_minimum_required(VERSION 3.21)
project(usdviewer)

cmake_policy(SET CMP0091 NEW)
cmake_policy(SET CMP0114 NEW)



set(HEADERS
    USDCollectTextures.h
    USDGetMaterials.h
    USDRenderEngine.h

    USDRender/ShadersBinary.h
    USDRender/Private.h
    USDRender/Render.h

    USDEnginePrimitive.h
    USDResolveTexture.h

    engine/options.h

    usdgeom/pointBased.h
    usdgeom/prim.h
    usdgeom/mesh.h
    
    usd/material.h
    usd/primvars.h
    usd/subsetsSplit.h
)
set(SOURCES
    
    USDRender/Render.cpp
    USDRender/Prims.cpp
    USDRender/Shaders.cpp
    USDRender/Vulkan.cpp
    
    USDCollectTextures.cpp
    USDGetMaterials.cpp
    USDRenderEngine.cpp
    USDResolveTexture.cpp
    USDSceneTraversal.cpp

    usdgeom/pointBased.cpp
    usdgeom/prim.cpp
    usdgeom/mesh.cpp
    
    usd/primvars.cpp
    usd/subsetsSplit.cpp
    
    main.cpp)

list(PREPEND CMAKE_MODULE_PATH
    ${PROJECT_SOURCE_DIR}/../tlRender/cmake/Modules
    ${PROJECT_SOURCE_DIR}/../cmake/Modules
    ${CMAKE_INSTALL_PREFIX}/lib/cmake)

#
# Required libraries
#
find_package(Vulkan REQUIRED)
find_package(tlRender REQUIRED)
find_package(FLTK CONFIG REQUIRED)
find_package(OpenEXR CONFIG REQUIRED)
find_package(pxr REQUIRED)

#
# Organize FLTK libraries for each platform
#
if(MSVC)
    set(FLTK_LIBRARIES fltk::fltk-shared )
    set(FLTK_vk_LIBRARY )
else()
    set(FLTK_LIBRARIES fltk::fltk-shared fltk::images-shared )
    set(FLTK_vk_LIBRARY fltk::vk-shared)
endif()
    

set( usdviewer_INCLUDE_DIRS
    ${CMAKE_CURRENT_SOURCE_DIR}/lib   # for usdviewer includes (search here first)
    ${usdviewer_FLUID_INCLUDE_DIR}         # for usdviewer .fl converted files next
    ${CMAKE_PREFIX_PATH}/include/OpenEXR
    ${CMAKE_PREFIX_PATH}/include/Imath
    ${CMAKE_PREFIX_PATH}/include/tlRender
    ${CMAKE_PREFIX_PATH}/include
    ${tlRender_INCLUDE_DIRS}
    # We need to include all these non-public tlRender directories
    # as we get the version information from them as well as some variables
    # and constants.
    ${CMAKE_CURRENT_SOURCE_DIR}/../tlRender/deps
    ${CMAKE_CURRENT_SOURCE_DIR}/../tlRender/lib
    ${Intl_INCLUDE_DIRS}
)

include_directories( ${usdviewer_INCLUDE_DIRS} )

set(LIBRARIES )
list(APPEND LIBRARIES tlRender::tlVk tlRender::tlCore tf usd usdUtils usdGeom usdShade usdSkel hio hd OpenEXR::OpenEXR)
list(APPEND LIBRARIES ${FLTK_vk_LIBRARY} ${FLTK_LIBRARIES})
list(APPEND LIBRARIES Vulkan::Vulkan)


if( APPLE )
    set(OSX_FRAMEWORKS "-framework IOKit")
    list(APPEND LIBRARIES ${OSX_FRAMEWORKS})
    set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
    set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib;/usr/local/lib")
endif()

add_executable(usdviewer WIN32 ${SOURCES} ${HEADERS})

target_include_directories(usdviewer BEFORE PRIVATE .)
if(UNIX AND NOT APPLE)
    target_compile_options(usdviewer PUBLIC -Wno-deprecated)
endif()

target_link_libraries(usdviewer PUBLIC ${LIBRARIES} PRIVATE ${LIBRARIES_PRIVATE})
target_link_directories( usdviewer BEFORE PUBLIC ${CMAKE_INSTALL_PREFIX}/lib /usr/local/lib )

install(TARGETS usdviewer
    RUNTIME DESTINATION bin COMPONENT applications
    LIBRARY DESTINATION lib COMPONENT libraries
    ARCHIVE DESTINATION lib COMPONENT libraries )


if (UNIX)
    # Configure environment.sh with python path
    configure_file(${CMAKE_SOURCE_DIR}/etc/bin/environment.sh.in
	${CMAKE_INSTALL_PREFIX}/bin/environment.sh @ONLY)
	
    install( FILES
	${CMAKE_SOURCE_DIR}/etc/bin/usdviewer.sh
	DESTINATION bin
	PERMISSIONS 
	OWNER_READ OWNER_WRITE OWNER_EXECUTE
	GROUP_READ GROUP_EXECUTE
	WORLD_READ WORLD_EXECUTE
	COMPONENT applications)
endif()
