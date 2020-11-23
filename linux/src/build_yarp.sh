#!/bin/bash
#set -x
##############################################################################
#
# Copyright: (C) 2011 RobotCub Consortium
# Authors: Paul Fitzpatrick
# CopyPolicy: Released under the terms of the LGPLv2.1 or later, see LGPL.TXT
#
# Compile YARP within a chroot.
#
# Command line arguments: 
#   build_yarp.sh ${OPT_PLATFORM} ${OPT_CHROOT_DIRECTORY}
# Example:
#   build_yarp.sh etch chroot_etch
#
# Inputs:
#   settings.sh (general configuration)
#   chroot_${OPT_PLATFORM}.sh
#      records name and directory of a basic chroot
#
# Outputs:
#   ${OPT_CHROOT_DIRECTORY}/yarp-*.deb
#      a debian package containing YARP
#   ${OPT_CHROOT_DIRECTORY}/build_chroot
#      a chroot within which YARP has been compiled
#   yarp_${OPT_PLATFORM}.sh
#      records name and directory of chroot

BUILD_DIR=$PWD

source ./settings.sh || {
	echo "No settings.sh found, are we in the build directory?"
	exit 1
}

source $BUNDLE_FILENAME || {
	echo "No bundle settings found: Tried '$BUNDLE_FILENAME'"
	exit 1
}

platform=$1
dir=$2

if [ "k$dir" = "k" ]; then
    echo "Call as: build_yarp.sh <platform> <dir>"
    exit 1
fi


# Load the configuration of the desired platform
source ./config_$platform.sh || {
	echo "No platform configuration file found"
	exit 1
}

# Load the configuration of a clean chroot
source chroot_${platform}.sh || {
	echo "Cannot find corresponding chroot"
	exit 1
}

mkdir -p $dir
cd $dir

# Create a chroot for building, if one does not already exist
sudo cp -a $CHROOT_DIR build_chroot || exit 1

# Helper for running a command within the build chroot
function run_in_chroot {
    CUR_DIR=$(pwd)
    echo "We are in [$CUR_DIR]" 
    echo "Running [$2] in [$1]"
    sudo chroot $1 bash -c "$2"
}

run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; apt-get -y install --install-recommends locales apt-utils"
run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; /usr/sbin/locale-gen en_US en_US.UTF-8"

DEPENDENCIES_DISTRIB="DEPENDENCIES_${PLATFORM_KEY}"
BACKPORTS_URL_DISTRIB="BACKPORTS_URL_${PLATFORM_KEY}"
if [ "${!BACKPORTS_URL_DISTRIB}" != "" ]; then
  echo "Using backports from ${!BACKPORTS_URL_DISTRIB}"
  run_in_chroot build_chroot "echo 'deb ${!BACKPORTS_URL_DISTRIB} ${PLATFORM_KEY}-backports main' > /etc/apt/sources.list.d/backports.list"
  run_in_chroot build_chroot "apt-get update"
fi

# -------------------- Handle CMAKE --------------------###
if [ ! -e "build_chroot/$CHROOT_BUILD/tmp/cmake.done" ]; then
#if [ -e build_chroot/$CHROOT_BUILD/local_cmake ]; then
#  CMAKE=`cd build_chroot/$CHROOT_BUILD/; echo cmake-*/bin/cmake`
#else
  #run_in_chroot build_chroot "cd $CHROOT_BUILD && ( wget https://cmake.org/files/v3.12/cmake-3.12.0-Linux-x86_64.tar.gz && tar xzvf cmake-3.12.0-Linux-x86_64.tar.gz && touch local_cmake )"
  if [ "$PLATFORM_KEY" == "bionic" ]; then
    run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; apt-get -y install software-properties-common apt-transport-https ca-certificates gnupg wget"
    run_in_chroot build_chroot "wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null"
    run_in_chroot build_chroot "apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'"
  fi
  run_in_chroot build_chroot "apt-get -y update"
  run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; apt-get -y install cmake && touch /tmp/cmake.done"
  if [ ! -e "build_chroot/$CHROOT_BUILD/tmp/cmake.done" ]; then
    echo "ERROR: problem installing cmake"
    exit 1
  fi
fi

#if [ -e build_chroot/$CHROOT_BUILD/local_cmake ]; then
#  CMAKE=$CHROOT_BUILD/`cd build_chroot/$CHROOT_BUILD/; echo cmake-*/bin/cmake`
#fi


# -------------------- Handle deps --------------------###
# Install basic dependencies
if [ "$DEPENDENCIES_COMMON" != "" ]; then
  run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; apt-get -y install $DEPENDENCIES_COMMON" || exit 1
fi

if [ "${!DEPENDENCIES_DISTRIB}" != "" ]; then
  run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; apt-get -y install ${!DEPENDENCIES_DISTRIB}" || exit 1
fi

if [ "$YARP_PACKAGE_VERSION" == "" ]; then
  echo "YARP_PACKAGE_VERSION not defined"
  exit 1
fi

###------------------- Handle YCM ----------------------###
if [ ! -e build_chroot/$CHROOT_BUILD/tmp/ycm-deb.done ]; then
  echo "Installing YCM package"
  YCM_URL_TAG="YCM_PACKAGE_URL_${PLATFORM_KEY}"
  run_in_chroot build_chroot "wget ${!YCM_URL_TAG} -O /tmp/ycm.deb"
  run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; dpkg -i /tmp/ycm.deb; apt-get install -f"
  run_in_chroot build_chroot "DEBIAN_FRONTEND=noninteractive; dpkg -i /tmp/ycm.deb && touch /tmp/ycm-deb.done"
  if [ ! -e build_chroot/$CHROOT_BUILD/tmp/ycm-deb.done ]; then
    echo "ERROR: problem installing YCM"
    exit 1
  fi
else
  echo "YCM package already handled."
fi

echo "yarp tag $YARP_PACKAGE_VERSION"
CHROOT_SRC="/tmp/yarp-$YARP_PACKAGE_VERSION"
CHROOT_BUILD="/tmp/yarp-$YARP_PACKAGE_VERSION/build"
#run_in_chroot build_chroot "if [ -f "${CHROOT_SRC}" ]; then rm -rf ${CHROOT_SRC}; fi" || exit 1
run_in_chroot build_chroot "rm -rf ${CHROOT_SRC}" || exit 1
run_in_chroot build_chroot "git clone https://github.com/robotology/yarp.git ${CHROOT_SRC}" || exit 1
run_in_chroot build_chroot "cd ${CHROOT_SRC} && git checkout 'v${YARP_PACKAGE_VERSION}' " || exit 1

# Prepare to build YARP.
run_in_chroot build_chroot "rm -rf $CHROOT_BUILD" || exit 1
run_in_chroot build_chroot "mkdir -p $CHROOT_BUILD" || exit 1
CMAKE=cmake

# Go ahead and configure
run_in_chroot build_chroot "mkdir -p $CHROOT_BUILD && cd $CHROOT_BUILD && $CMAKE $YARP_CMAKE_OPTIONS $CHROOT_SRC" || exit 1

# Go ahead and make
run_in_chroot build_chroot "cd $CHROOT_BUILD && make -j" || exit 1

# Go ahead and generate .deb
PACKAGE_DEPENDENCIES="libace-dev (>= 5.6), libgsl-dev (>= 1.11), libgtkmm-2.4-dev (>= 2.14.1)"
#PACKAGE_DEPENDENCIES=$( echo "$DEPENDENCIES_COMMON ${!DEPENDENCIES_DISTRIB}" | sed -e "s/ /,/g" | sed -e "s/,$//g") 
PACKAGE_DEPENDENCIES="$PACKAGE_DEPENDENCIES, cmake (>=${CMAKE_MIN_REQ_VER})"
DEBIAN_PACKAGE_VERSION="${YARP_PACKAGE_VERSION}-${YARP_DEB_REVISION}~${PLATFORM_KEY}"  

run_in_chroot build_chroot "cd $CHROOT_BUILD && $CMAKE -DCPACK_GENERATOR='DEB' -DCPACK_DEBIAN_PACKAGE_VERSION=${DEBIAN_PACKAGE_VERSION} -DCPACK_PACKAGE_CONTACT='info@icub.org' -DCPACK_DEBIAN_PACKAGE_MAINTAINER='matteo.brunettini@iit.it' -DCPACK_DEBIAN_PACKAGE_DEPENDS:STRING='$PACKAGE_DEPENDENCIES' ." || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && rm -f *.deb && make package" || exit 1

# Rebuild .deb, because cmake 2.8.2 is broken, sigh
#   http://public.kitware.com/Bug/view.php?id=11020
run_in_chroot build_chroot "cd $CHROOT_BUILD && rm -rf deb *.deb" || exit 1
#PACK="deb/yarp-${YARP_PACKAGE_VERSION}-${PLATFORM_KEY}-${PLATFORM_HARDWARE}"
YARP_PACKAGE_NAME="yarp-${YARP_PACKAGE_VERSION}-${YARP_DEB_REVISION}~${PLATFORM_KEY}_${PLATFORM_HARDWARE}.deb"
PACK="deb/yarp-${YARP_PACKAGE_VERSION}-${YARP_DEB_REVISION}~${PLATFORM_KEY}+${PLATFORM_HARDWARE}"
run_in_chroot build_chroot "cd $CHROOT_BUILD && mkdir -p $PACK/DEBIAN" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && cp -a _CPack_Packages/Linux/DEB/yarp_*_/control $PACK/DEBIAN" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && cp -a _CPack_Packages/Linux/DEB/yarp_*_/md5sums $PACK/DEBIAN" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && cp -a _CPack_Packages/Linux/DEB/yarp_*_/usr $PACK/usr" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && mkdir -p $PACK/etc/bash_completion.d" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && cp -a ${CHROOT_SRC}/data/bash-completion/yarp $PACK/etc/bash_completion.d/yarp" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && chmod 644 $PACK/etc/bash_completion.d/yarp" || exit 1
run_in_chroot build_chroot "cd $CHROOT_BUILD && dpkg -b $PACK $YARP_PACKAGE_NAME" || exit 1

# Copy .deb to somewhere easier to find
rm -f *.deb 2> /dev/null
cp -a build_chroot/$CHROOT_BUILD/$YARP_PACKAGE_NAME $YARP_PACKAGE_NAME || exit 1
#fname=`ls *.deb`

# Record settings
(
	echo "export YARP_PACKAGE_DIR='$PWD'"
	echo "export YARP_PACKAGE='$YARP_PACKAGE_NAME'"
) > $BUILD_DIR/yarp_${platform}.sh

# Report what we did
echo ".deb prepared, here:"
echo "  $PWD/$YARP_PACKAGE_NAME"
echo "To enter chroot used to build this .deb, run:"
echo "  sudo chroot $PWD/build_chroot"
