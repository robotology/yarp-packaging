#!/bin/bash
#set -x
BUILD_DIR=$PWD

source ./settings.sh || {
	echo "No settings.sh found, are we in the build directory?"
	exit 1
}

source $SETTINGS_BUNDLE_FILENAME || {
	echo "Bundle settings not found"
	exit 1
}

source $SETTINGS_SOURCE_DIR/src/process_options.sh $* || {
	echo "Cannot process options"
	exit 1
}

# Pick up CMake paths
source cmake_any_any_any.sh || {
  echo "Cannot find corresponding CMAKE build"
  exit 1
}

echo "$OPT_CONFIGURATION_COMMAND" 

if [ "${BUNDLE_OPENCV_VERSION}" == "" ]; then
	echo "Warning no OPENCV version defined."
	exit 0
fi

if [ "${BUNDLE_OPENCV_URL}" == "" ]; then
  echo "ERROR: Please specify OpenCV URL in the configuration script"
  exit 1
fi
ifname="${BUNDLE_OPENCV_URL}/${BUNDLE_OPENCV_VERSION}.zip"
ofname="OpenCV-${BUNDLE_OPENCV_VERSION}.zip"
if [ ! -e $ofname ]; then
  wget $ifname --output-document=${ofname} 
  if [ "$?" != "0" ]; then
    echo "ERROR: Cannot fetch OpenCV from ${ifname}"
    exit 1
  fi
fi

source_dir="opencv-${BUNDLE_OPENCV_VERSION}"
unzip -o $ofname
BUILD_PATH="${source_dir}-${OPT_COMPILER}-${OPT_VARIANT}"
OPENCV_PATH="${BUILD_PATH}/install"
OpenCV_DIR=`cygpath --mixed "${BUILD_DIR}/${OPENCV_PATH}"`

echo "Building to ${BUILD_PATH}"
if [ -d "$BUILD_PATH" ]; then
  rm -rf $BUILD_PATH
fi
mkdir -p $BUILD_PATH
cd $BUILD_PATH

if [ -f "CMakeCache.txt" ]; then
  rm CMakeCache.txt
fi
"$CMAKE_BIN" -DCMAKE_INSTALL_PREFIX=$OpenCV_DIR -G "$OPT_GENERATOR" ../$source_dir || exit 1
# build
$OPT_BUILDER OpenCV.sln /t:Build $OPT_CONFIGURATION_COMMAND $OPT_PLATFORM_COMMAND
# the following install code
"$CMAKE_BIN" --build . --target install --config ${OPT_BUILD} || exit 1
# cleanup obj file to save space
find ./ -type f -name *.obj -exec rm -rf {} \;

(
  echo "export OpenCV_DIR='$OpenCV_DIR'"
  echo "export OPENCV_DIR='$OpenCV_DIR'"
  echo "export OPENCV_PATH='$OPENCV_PATH'"
) > ${BUILD_DIR}/opencv_${OPT_COMPILER}_${OPT_VARIANT}_${OPT_BUILD}.sh