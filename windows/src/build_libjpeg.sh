#!/bin/bash

# Actually, we just download a libjpeg-turbo binaries package.

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

LIBJPEG_VERSION_TAG="BUNDLE_LIBJPEG_VERSION_${OPT_VARIANT}"
if [ "${!LIBJPEG_VERSION_TAG}" == "" ]; then
	echo "Warning no LIBJPEG version defined for ${LIBJPEG_VERSION_TAG}"
	exit 0
fi

LIBJPEG_PATH="libjpeg-turbo-${!LIBJPEG_VERSION_TAG}_${OPT_VARIANT}"
LIBJPEG_FILE="${LIBJPEG_PATH}.zip"
LIBJPEG_URL="${BUNDLE_EXT_REPO_URL}/${LIBJPEG_FILE}" 
LIBJPEG_DIR=$(cygpath --mixed "${BUILD_DIR}/${LIBJPEG_PATH}")
JPEG_INCLUDE_DIR=$(cygpath --mixed "${BUILD_DIR}/${LIBJPEG_PATH}/include")
JPEG_LIBRARY=$(cygpath --mixed "${BUILD_DIR}/${LIBJPEG_PATH}/lib/jpeg.lib")

if [ ! -e "$LIBJPEG_FILE" ]; then
	wget $LIBJPEG_URL || {
		echo "Cannot fetch LIBJPEG file $LIBJPEG_URL"
		exit 1
	}
fi

if [ ! -d "$LIBJPEG_PATH" ] ; then
    unzip $LIBJPEG_FILE || {
	  	echo "Cannot unpack LIBJPEG file $LIBJPEG_FILE"
		exit 1
	}
fi

(
	echo "export LIBJPEG_DIR='$LIBJPEG_DIR'"
  echo "export LIBJPEG_PATH='$LIBJPEG_PATH'"
	echo "export JPEG_INCLUDE_DIR='$JPEG_INCLUDE_DIR'"
  echo "export JPEG_LIBRARY='$JPEG_LIBRARY'"
) > $BUILD_DIR/libjpeg_${OPT_VARIANT}_${OPT_BUILD}.sh
