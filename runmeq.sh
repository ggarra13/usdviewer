#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# usdviewer
# Copyright Contributors to the usdviewer Project. All rights reserved.


#
#
# Wrap up script to compile just usdviewer, do the documenting and packaging.
#
#

set +e

if [[ ! $RUNME ]]; then
    . etc/build_dir.sh
else
    . etc/functions.sh
fi

echo "BUILD_DIR=${BUILD_DIR}"
echo 

dir=$BUILD_DIR/usdviewer/src/usdviewer-build

if [[ ! -d $dir ]]; then
    echo "usdviewer build directory:"
    echo $dir
    echo "does not exist."
    echo "Please run:"
    echo " $ runme.sh [sameflags]"
    exit 1
fi

if [[ "$CMAKE_TARGET" == "package" ]]; then  
    # Needed to to force a relink and update build info.
    touch src/main.cpp
fi

if [[ "$CMAKE_TARGET" == "" ]]; then
    CMAKE_TARGET=install
fi


if [[ "$CMAKE_TARGET" == "package" ]]; then
    
    # clean_mo_files
    
    echo
    echo "No .mo files yet."
    echo
    
    # cd $dir
    
    # run_cmd cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t pot
    # run_cmd cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t mo
    # run_cmd cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t install

    # cd -
fi


if [[ "$CMAKE_TARGET" == "package" ]]; then
    
    cd $dir
	
    run_cmd cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t install

    cd -
fi

cd $dir

cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t "${CMAKE_TARGET}"
STATUS=$?

cd -

if [[ $STATUS -eq 0 ]]; then
    . etc/build_end.sh
    exit 0
else
    nsis_output=$PWD/$BUILD_DIR/usdviewer/src/usdviewer-build/_CPack_Packages/win64/NSIS/NSISOutput.log 
    if [[ -e $nsis_output ]]; then
	echo "Contents of NSISOutput.log"
	echo "--------------------------"
	cat $nsis_output
    else
	echo "No NSISOutput.log at ${nsis_output}"
    fi
    exit 1
fi




