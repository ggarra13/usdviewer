# SPDX-License-Identifier: BSD-3-Clause
# mrv2 
# Copyright Contributors to the mrv2 Project. All rights reserved.

set(BUILD_ZLIB FALSE CACHE BOOL "Enable ZLIB building")
set(BUILD_VCPKG FALSE CACHE BOOL "Build vcpkg from source")
set(BUILD_FLTK TRUE CACHE BOOL "Enable FLTK building (needed)")

set(USDVIEWER_BACKEND "VK" CACHE STRING "Select backend: VK")

option(GIT_SUBMODULE "Check tlRender submodule during build if missing" ON)

