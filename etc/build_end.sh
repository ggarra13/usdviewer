#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# usdviewer
# Copyright Contributors to the usdviewer Project. All rights reserved.

vcpkg_ARCH=x64
if [[ $ARCH == *amd64* ]]; then
    vcpkg_ARCH=x64
elif [[ $ARCH == *aarch64* || $ARCH == *arm64* ]]; then
    vcpkg_ARCH=arm64
fi
vcpkg_TRIPLET=${vcpkg_ARCH}-windows
vcpkg_DIR=$BUILD_DIR/deps/vcpkg/src/vcpkg/installed/$vcpkg_TRIPLET
	
if [[ $KERNEL == *Windows* ]]; then
    if [[ -d $vcpkg_DIR ]]; then
	echo "Copying $vcpkg_DIR/bin/*.dll"
	cp -rf $vcpkg_DIR/bin/*.dll $BUILD_DIR/install/bin
    fi
fi

if [[ "$CMAKE_TARGET" == "package" ]]; then

    echo "Target is package build.  Will copy packages..."
    
    if [[ $KERNEL == *Windows* ]]; then
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Windows-${ARCH}.exe"
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Windows-${ARCH}.zip"
	. etc/windows/signing_installer.sh
    elif [[ $KERNEL == *Darwin* ]]; then
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Darwin-${ARCH}.dmg"
	# . etc/macos_signing_installer.sh
    elif [[ $KERNEL == *Linux* ]]; then
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Linux-${ARCH}.deb"
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Linux-${ARCH}.rpm"
	send_to_packages "usdviewer-v${usdviewer_VERSION}-Linux-${ARCH}.tar.gz"
    else
	echo "Kernel not recognized.  Will not move the files to packages/ directory."
    fi
fi

#
# Create symbolic links to start-up shell scripts
#
if [[ $KERNEL != *Windows* ]]; then
    chmod a+x $PWD/$BUILD_DIR/install/bin/usdviewer.sh
    if [ -d ~/bin ] && [ -w ~/bin ]; then
	if [[ $CMAKE_BUILD_TYPE == Debug ]]; then
	    run_cmd rm -f ~/bin/usdviewer-dbg
	    run_cmd ln -s $PWD/$BUILD_DIR/install/bin/usdviewer.sh ~/bin/usdviewer-dbg
	else
	    run_cmd rm -f ~/bin/usdviewer
	    run_cmd ln -s $PWD/$BUILD_DIR/install/bin/usdviewer.sh ~/bin/usdviewer
	fi
    fi
fi
