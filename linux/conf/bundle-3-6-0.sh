#!/bin/bash

###------------------- Handle YCM ----------------------###
YCM_PACKAGE="ycm-cmake-modules"
YCM_PACKAGE_URL_bionic="https://github.com/robotology/ycm/releases/download/v0.13.0/${YCM_PACKAGE}_0.13.0-1.ubuntu18.04.robotology1_all.deb"
YCM_PACKAGE_URL_focal="https://github.com/robotology/ycm/releases/download/v0.13.0/${YCM_PACKAGE}_0.13.0-1.ubuntu20.04.robotology1_all.deb"
# issues with libjs-sphinxdoc
YCM_PACKAGE_URL_buster="https://github.com/robotology/ycm/releases/download/v0.13.0/${YCM_PACKAGE}_0.13.0-1.debian10.robotology1_all.deb"


DEPENDENCIES_COMMON="libjs-sphinxdoc libjs-underscore qml-module-qt-labs-settings libqcustomplot-dev qml-module-qt-labs-folderlistmodel qtbase5-dev qtdeclarative5-dev qtmultimedia5-dev libqt5svg5 libtinyxml-dev libace-dev git dpkg wget libeigen3-dev qml-module-qtquick2 qml-module-qtquick-window2 qml-module-qtmultimedia qml-module-qtquick-dialogs qml-module-qtquick-controls qml-module-qt-labs-folderlistmodel qml-module-qt-labs-settings libjpeg-dev libopencv-dev libopenni2-dev portaudio19-dev libsdl1.2-dev libi2c-dev libv4l-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-tools libgraphviz-dev libsqlite3-dev libqcustomplot-dev"
# Leave empty if you don't use dependancies from backports otherwise fill the following with the line that add backports in the distro sources.list (platform dependant)
DEPENDENCIES_buster=""
DEPENDENCIES_bionic=""
DEPENDENCIES_focal=""
CMAKE_MIN_REQ_VER="3.16.0"
export YARP_PACKAGE_VERSION=3.6.0
# always use a revision number >=1
export YARP_DEB_REVISION=2
YARP_CMAKE_OPTIONS="\
    -DYARP_COMPILE_GUIS:BOOL=ON \
    -DYARP_USE_SYSTEM_SQLite:BOOL=ON \
    -DYARP_COMPILE_libYARP_math:BOOL=ON \
    -DYARP_COMPILE_CARRIER_PLUGINS:BOOL=ON \
    -DENABLE_yarpcar_bayer:BOOL=ON \
    -DENABLE_yarpcar_tcpros:BOOL=ON \
    -DENABLE_yarpcar_xmlrpc:BOOL=ON \
    -DENABLE_yarpcar_priority:BOOL=ON \
    -DENABLE_yarpcar_bayer:BOOL=ON \
    -DENABLE_yarpcar_mjpeg:BOOL=ON \
    -DENABLE_yarpcar_portmonitor:BOOL=ON \
    -DENABLE_yarppm_depthimage_to_mono:BOOL=ON \
    -DENABLE_yarppm_depthimage_to_rgb:BOOL=ON \
    -DENABLE_yarpidl_thrift:BOOL=ON \
    -DYARP_COMPILE_DEVICE_PLUGINS:BOOL=ON \
    -DENABLE_yarpcar_human:BOOL=ON \
    -DENABLE_yarpcar_rossrv:BOOL=ON \
    -DENABLE_yarpmod_fakebot:BOOL=ON \
    -DENABLE_yarpmod_imuBosch_BNO055:BOOL=ON \
    -DENABLE_yarpmod_SDLJoypad:BOOL=ON \
    -DENABLE_yarpmod_serialport:BOOL=ON \
    -DENABLE_yarpmod_AudioPlayerWrapper:BOOL=ON \
    -DENABLE_yarpmod_AudioRecorderWrapper:BOOL=ON \
    -DENABLE_yarpmod_portaudio:BOOL=ON \
    -DENABLE_yarpmod_portaudioPlayer:BOOL=ON \
    -DENABLE_yarpmod_portaudioRecorder:BOOL=ON \
    -DENABLE_yarpmod_fakeAnalogSensor:BOOL=ON \
    -DENABLE_yarpmod_fakeBattery:BOOL=ON \
    -DENABLE_yarpmod_fakeDepthCamera:BOOL=ON \
    -DENABLE_yarpmod_fakeFrameGrabber:BOOL=ON \
    -DENABLE_yarpmod_fakeIMU:BOOL=ON \
    -DENABLE_yarpmod_fakeLaser:BOOL=ON \
    -DENABLE_yarpmod_fakeLocalizer:BOOL=ON \
    -DENABLE_yarpmod_fakeMicrophone:BOOL=ON \
    -DENABLE_yarpmod_fakeMotionControl:BOOL=ON \
    -DENABLE_yarpmod_fakeNavigation:BOOL=ON \
    -DENABLE_yarpmod_fakeSpeaker:BOOL=ON \
    -DYARP_COMPILE_EXPERIMENTAL_WRAPPERS:BOOL=ON \
    -DYARP_USE_I2C:BOOL=ON \
    -DYARP_USE_SDL:BOOL=ON \
    -DENABLE_yarpmod_usbCamera:BOOL=ON \
    -DENABLE_yarpmod_usbCameraRaw:BOOL=ON \
"
