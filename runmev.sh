#!/usr/bin/env bash
# SPDX-License-Identifier: BSD-3-Clause
# usdviewer
# Copyright Contributors to the usdviewer Project. All rights reserved.



#
#
# Wrap up script to compile FLTK, tlRender and usdviewer
#
#

set +e

. $PWD/etc/build_dir.sh

rm -rf $BUILD_DIR/install/include/FL

dir=$BUILD_DIR/deps/FLTK/src/FLTK-build/
if [[ ! -d $dir ]]; then
    echo "FLTK directory"
    echo $dir
    echo "does not exist. Please run:"
    echo " $ runme.sh [sameflags]"
    exit 1
fi


cd $dir

#
#  Rebuild latest FLTK
#

cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t install 
if [[ $? != 0 ]]; then
    echo "COMPILATON of FLTK failed"
    cd -
    exit 1
fi

cd -

dir=$BUILD_DIR/tlRender/etc/SuperBuild/tlRender/src/tlRender-build/
if [[ ! -d $dir ]]; then
    echo "tlRender directory:"
    echo $dir
    echo "does not exist. Please run:"
    echo " $ runme.sh [sameflags]"
    exit 1
fi

cd $dir

#
#  Rebuild tlRender
#
cmake --build . $FLAGS --config $CMAKE_BUILD_TYPE -t install
if [[ $? != 0 ]]; then
    echo "COMPILATON of tlRender failed"
    cd -
    exit 1
fi
cd -

dir=$BUILD_DIR/usdviewer/src/usdviewer-build

# Needed to to force a relink and update build info.
rm -f $dir/src/usdviewer

if [[ "$CMAKE_TARGET" == "" ]]; then
    CMAKE_TARGET=install
fi

run_cmd ./runmeq.sh $CMAKE_BUILD_TYPE -t $CMAKE_TARGET
if [[ $? != 0 ]]; then
    echo "COMPILATON of usdviewer failed"
    exit 1
fi

