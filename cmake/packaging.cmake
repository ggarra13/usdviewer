# SPDX-License-Identifier: BSD-3-Clause
# usdviewer (usdviewer)
# Copyright Contributors to the usdviewer Project. All rights reserved.

#
# Common CPACK options to all generators
#
string(TIMESTAMP THIS_YEAR "%Y")

set( CPACK_RESOURCE_FILE_LICENSE "${CMAKE_SOURCE_DIR}/../LICENSE" )
set( CPACK_PACKAGE_VERSION_MAJOR "${usdviewer_VERSION_MAJOR}" )
set( CPACK_PACKAGE_VERSION_MINOR "${usdviewer_VERSION_MINOR}" )
set( CPACK_PACKAGE_VERSION_PATCH "${usdviewer_VERSION_PATCH}" )
set( CPACK_PACKAGE_VERSION "${usdviewer_VERSION}")
set( CPACK_PACKAGE_CONTACT "ggarra13@gmail.com")

set( usdviewer_NAME usdviewer )


#
# Experimental support in CPack for multithreading. 0 uses all cores.
#
if (APPLE)
    set( CPACK_THREADS 1 )
else()
    set( CPACK_THREADS 0 )
endif()

set( USDVIEWER_OS_BITS 32 )
if(APPLE)
    if(CMAKE_SYSTEM_PROCESSOR MATCHES ".*arm.*" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES ".*aarch.*")
	if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	    set( USDVIEWER_OS_BITS 64 )
            set( USDVIEWER_ARCHITECTURE "arm64")
	else()
            set( USDVIEWER_ARCHITECTURE "arm")
	endif()
    else()
	set( USDVIEWER_OS_BITS 64 )
        set( USDVIEWER_ARCHITECTURE "amd64")
    endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^mips.*")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
	set( USDVIEWER_OS_BITS 64 )
        set( USDVIEWER_ARCHITECTURE "mips64el")
    else()
        set( USDVIEWER_ARCHITECTURE "mipsel")
    endif()
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "^ppc.*")
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set( USDVIEWER_ARCHITECTURE "ppc64le")
    else()
        message(FATAL_ERROR "Architecture is not supported")
    endif()
else()  # Handles Linux and other non-Apple/MIPS/PPC systems
    if(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES "ARM64" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES "arm64")
        set( USDVIEWER_OS_BITS 64 )
        set( USDVIEWER_ARCHITECTURE "aarch64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES "AMD64" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES "amd64")
        set( USDVIEWER_OS_BITS 64 )
        set( USDVIEWER_ARCHITECTURE "amd64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i686" OR
	    CMAKE_SYSTEM_PROCESSOR MATCHES "x86")
        set( USDVIEWER_ARCHITECTURE "x86")
    else()
        message(FATAL_ERROR "Architecture ${CMAKE_SYSTEM_PROCESSOR} not supported")
    endif()
endif()

set( usdviewerShortName "${usdviewer_NAME}-v${usdviewer_VERSION}-${CMAKE_SYSTEM_NAME}-${USDVIEWER_OS_BITS}" )
set( CPACK_PACKAGE_NAME ${usdviewer_NAME} )
set( CPACK_PACKAGE_VENDOR "Gonzalo Garramuno (ggarra13@gmail.com)" )
set( CPACK_PACKAGE_DESCRIPTION_SUMMARY "Professional media player.")
set( CPACK_PACKAGE_INSTALL_DIRECTORY ${usdviewerShortName} )
set( CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-v${CPACK_PACKAGE_VERSION}-${CMAKE_SYSTEM_NAME}-${USDVIEWER_ARCHITECTURE} )

#
# This is the usdviewer/ subdir
#
set(USDVIEWER_DIR ${CMAKE_SOURCE_DIR})

#
# This is the root of usdviewer
#
file(REAL_PATH "${USDVIEWER_DIR}/.." USDVIEWER_ROOT)

set(CPACK_VERBOSE ON)
set(CPACK_FILTER_IGNORE_FILES "/.git/;/build/;/CMakeFiles/;.o;.a;.lib")

#
# \@bug:
# This dummy (empty) install script is needed so variables get passed to
# the CPACK_PRE_BUILD_SCRIPTS.
#
set( CPACK_INSTALL_SCRIPT ${USDVIEWER_ROOT}/cmake/dummy.cmake )

#
# This pre-build script does some cleaning of files in packaging area to
# keep installers smaller.
#
set( CPACK_PRE_BUILD_SCRIPTS ${USDVIEWER_ROOT}/cmake/prepackage.cmake )

if(APPLE)
    ##############################
    # New Method using Dragndrop #
    ##############################
    set( INSTALL_NAME ${usdviewer_NAME} )

    # Define variables for bundle directories in the build dir
    set(USDVIEWER_BUNDLE_DIR ${CMAKE_BINARY_DIR}/${usdviewer_NAME}.app)

    # Create the usdviewer.app bundle structure
    message(STATUS "CREATE ${usdviewer_NAME}.app dir")
    file(MAKE_DIRECTORY ${USDVIEWER_BUNDLE_DIR}/Contents/MacOS)
    file(MAKE_DIRECTORY ${USDVIEWER_BUNDLE_DIR}/Contents/Resources)
    
    # Copy the icon
    configure_file(${USDVIEWER_DIR}/etc/macOS/usdviewer.icns
	${USDVIEWER_BUNDLE_DIR}/Contents/Resources/${usdviewer_NAME}.icns COPYONLY)
    
    # Copy the Info.plist modifying its variables
    configure_file(
     	${USDVIEWER_DIR}/etc/macOS/usdviewer.plist.in
     	${USDVIEWER_BUNDLE_DIR}/Contents/Info.plist )

    # Copy the shell script into the MacOS bundle and make them executable
    configure_file(${USDVIEWER_DIR}/etc/macOS/usdviewer.sh
	${USDVIEWER_BUNDLE_DIR}/Contents/MacOS/${usdviewer_NAME}
	FILE_PERMISSIONS
	OWNER_READ OWNER_EXECUTE
	GROUP_READ GROUP_EXECUTE
	WORLD_READ WORLD_EXECUTE
	COPYONLY)
    
    # Install usdviewer.app / vusdviewer.app bundle dir
    install(DIRECTORY ${USDVIEWER_BUNDLE_DIR}
	DESTINATION .
	USE_SOURCE_PERMISSIONS
	COMPONENT applications
    )

    # Install README.md file at root of .dmg
    install(FILES "/tmp/macOS/README.md"
        DESTINATION .
        COMPONENT applications
    )

    # Configure CPack for DragNDrop
    set(CPACK_GENERATOR "DragNDrop")

    # Package settings
    set(CPACK_PACKAGE_ICON ${USDVIEWER_DIR}/etc/macOS/usdviewer.icns )

    # DragNDrop settings
    set(CPACK_DMG_VOLUME_NAME "${usdviewer_NAME} Installer")
    set(CPACK_DMG_FORMAT "UDZO")
    Set(CPACK_DMG_VOLUME_NAME ${CPACK_PACKAGE_FILE_NAME})
    set(CPACK_DMG_VOLUME_ICON ${USDVIEWER_DIR}/etc/macOS/usdviewer.icns)
    
    
    
    set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_BINARY_DIR};${usdviewer_NAME};applications;/")
    set(CPACK_INSTALLED_DIRECTORIES "${CMAKE_BINARY_DIR}/install;.")

elseif(UNIX)
    
    #
    # Linux generators
    #
    set(CPACK_GENERATOR $ENV{CPACK_GENERATOR})
    if (NOT CPACK_GENERATOR)
	set(CPACK_GENERATOR DEB RPM TGZ)
    endif()
    
    #
    # Linux icon and .desktop shortcut
    #

    #
    # This desktop is the one placed on the desktop for X11/Wayland version
    # shortcuts.
    #
    configure_file( ${USDVIEWER_DIR}/etc/Linux/usdviewer.desktop.in
	"${PROJECT_BINARY_DIR}/etc/${usdviewer_NAME}-v${usdviewer_VERSION}.desktop" )
 
    #
    # This desktop file is for Wayland to set its icon correctly.
    #
    configure_file( ${USDVIEWER_DIR}/etc/Linux/usdviewer.main.desktop.in
	"${PROJECT_BINARY_DIR}/etc/${usdviewer_NAME}.desktop" )
    install(FILES "${PROJECT_BINARY_DIR}/etc/${usdviewer_NAME}-v${usdviewer_VERSION}.desktop"
	DESTINATION share/applications COMPONENT applications)
    install(FILES "${PROJECT_BINARY_DIR}/etc/${usdviewer_NAME}.desktop"
	DESTINATION share/applications COMPONENT applications)
    install(DIRECTORY ${USDVIEWER_DIR}/share/icons
	DESTINATION share/ COMPONENT applications)
    
    set(CPACK_INSTALL_PREFIX /usr/local/${usdviewerShortName})

    #
    # Linux post-install and post-remove scripts to handle versioning and
    # installation of .desktop shortcut on the user's Desktop.
    #
    configure_file(
	${USDVIEWER_DIR}/etc/Linux/postinst.in
	${PROJECT_BINARY_DIR}/etc/Linux/postinst
	@ONLY)
    configure_file(
	${USDVIEWER_DIR}/etc/Linux/postrm.in
	${PROJECT_BINARY_DIR}/etc/Linux/postrm
	@ONLY)

    #
    # set Debian options.
    #
    execute_process(
	COMMAND dpkg --print-architecture
	OUTPUT_VARIABLE DEB_ARCHITECTURE
	OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set(CPACK_DEBIAN_PACKAGE_NAME ${usdviewer_NAME}-v${usdviewer_VERSION})
    set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE ${DEB_ARCHITECTURE})
    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
	"${PROJECT_BINARY_DIR}/etc/Linux/postinst"
	"${PROJECT_BINARY_DIR}/etc/Linux/postrm")

    set(CPACK_DEBIAN_FILE_NAME	"${CPACK_PACKAGE_FILE_NAME}.deb" )

    #
    # Set RPM options.
    #
    set(CPACK_RPM_PACKAGE_NAME ${usdviewer_NAME}-${usdviewer_VERSION})

    set(CPACK_RPM_PACKAGE_RELOCATABLE true)
    set(CPACK_RPM_PACKAGE_AUTOREQ false)
    set(CPACK_RPM_PACKAGE_AUTOPROV true)
    set(CPACK_RPM_COMPRESSION_TYPE gzip )
    execute_process(
	COMMAND uname -m
	OUTPUT_VARIABLE RPM_ARCHITECTURE
	OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    set( CPACK_RPM_PACKAGE_ARCHITECTURE ${RPM_ARCHITECTURE} )

    set(
	CPACK_RPM_POST_INSTALL_SCRIPT_FILE
	${PROJECT_BINARY_DIR}/etc/Linux/postinst)
    set(
	CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE
	${PROJECT_BINARY_DIR}/etc/Linux/postrm)
      
     # Undocumented option used to avoid .build-id libs listing
     set(CPACK_RPM_SPEC_MORE_DEFINE "%define _build_id_links none")

     # \@bug: According to docs it is not needed, but
     #        RPM packaging won't work properly without it.   
     set(CPACK_SET_DESTDIR true) 
else()

    # Create debug directory for .pdb files
    if (CMAKE_BUILD_TYPE STREQUAL "Debug" OR
	    CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo")
	list(PREPEND CPACK_PRE_BUILD_SCRIPTS ${USDVIEWER_ROOT}/cmake/copy_pdbs.cmake )
    endif()
    
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${usdviewer_NAME}-v${usdviewer_VERSION}" )
    
    # There is a bug in NSIS that does not handle full unix paths properly. Make
    # sure there is at least one set of four (4) backlasshes.
    #
    # This removes the page for the user to create
    # Desktop shortcuts, BESIDES modifying the PATH environment variable.
    #
    set(CPACK_NSIS_MODIFY_PATH OFF)
    
    set(CPACK_GENERATOR NSIS ZIP)

    #
    # This sets the title at the top of the installer.
    #
    set(CPACK_NSIS_PACKAGE_NAME "${usdviewer_NAME} v${usdviewer_VERSION} ${CMAKE_SYSTEM_NAME}-${USDVIEWER_OS_BITS}" )
    
    #
    # Set the executable
    #
    set(CPACK_NSIS_INSTALLED_ICON_NAME "bin/usdviewer.exe")

    #
    # Set the MUI Installer icon
    #
    set(CPACK_NSIS_MUI_ICON "${USDVIEWER_DIR}/main/app.ico")
    set(CPACK_NSIS_MUI_UNICON "${USDVIEWER_DIR}/main/app.ico")

    #
    # Set the MUI banner to use a custom usdviewer one.
    #
    # set(MUI_HEADERIMAGE "${USDVIEWER_ROOT}/cmake/nsis/NSIS_background.bmp")
    # file(TO_NATIVE_PATH "${MUI_HEADERIMAGE}" MUI_HEADERIMAGE)
    # string(REPLACE "\\" "\\\\" MUI_HEADERIMAGE "${MUI_HEADERIMAGE}")
    # set(CPACK_NSIS_MUI_HEADERIMAGE "${MUI_HEADERIMAGE}")

    #
    # Default location for installation.
    #
    set(CPACK_NSIS_INSTALL_ROOT "$PROGRAMFILES64")

    #
    # This sets the name in Windows Apps and Control Panel.
    #
    set(usdviewer_DISPLAY_NAME "${usdviewer_NAME}-${USDVIEWER_OS_BITS} v${usdviewer_VERSION}")
    
    set(CPACK_NSIS_DISPLAY_NAME "${usdviewer_DISPLAY_NAME}" )

    set(CPACK_PACKAGE_EXECUTABLES "usdviewer" "${usdviewer_DISPLAY_NAME}")
    set(CPACK_CREATE_DESKTOP_LINKS "usdviewer" "${usdviewer_DISPLAY_NAME}")


    #
    # Always create a desktop shortcuts to usdviewer.exe and hdr.exe
    #
    set(CPACK_NSIS_CREATE_ICONS_EXTRA
	"CreateShortCut \\\"$DESKTOP\\\\${usdviewer_DISPLAY_NAME}.lnk\\\" \\\"$INSTDIR\\\\bin\\\\usdviewer.exe\\\"")

    #
    # Remove the shortcuts on uninstall
    #
    set(CPACK_NSIS_DELETE_ICONS_EXTRA
	"Delete \\\"$DESKTOP\\\\${usdviewer_DISPLAY_NAME}.lnk\\\"")
    
    #
    # To call uninstall first if the same version has been installed.
    #

    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON )

    #
    # Create NSIS registry
    #
    configure_file(
	"${USDVIEWER_ROOT}/cmake/nsis/NSISRegistry.cmake.in"
	"${PROJECT_BINARY_DIR}/cmake/nsis/NSISRegistry.cmake"
	@ONLY)
    
    include("${PROJECT_BINARY_DIR}/cmake/nsis/NSISRegistry.cmake")

endif()

#
# For Windows installer, handle the components
#
set(usdviewer_COMPONENTS
    applications
)


set(CPACK_COMPONENTS_ALL ${usdviewer_COMPONENTS})
set(CPACK_COMPONENT_APPLICATIONS_DISPLAY_NAME "${usdviewer_NAME} Application")



include(CPack)
