#!/bin/bash
export BUNDLE_YARP_VERSION=2.3.72
export BUNDLE_TWEAK=1
export BUNDLE_CMAKE_VERSION="3.5.2"
export BUNDLE_CMAKE_URL=""
export BUNDLE_NSIS_VERSION="2.46"
export BUNDLE_NSIS_URL=""
export BUNDLE_EIGEN_VERSION="3.3.0"
export BUNDLE_EIGEN_URL="http://bitbucket.org/eigen/eigen/get"
export BUNDLE_EXT_REPO_URL="http://www.icub.org/download/3rd-party"
# Empty version means no support, yarp will be compiled without it
#export BUNDLE_ACE_VERSION_v10=6.2.7
#export BUNDLE_ACE_VERSION_v11=6.3.2
export BUNDLE_ACE_VERSION_v12=6.3.4
export BUNDLE_ACE_VERSION_v14=6.3.4
#export BUNDLE_QT_VERSION_v10_x86=5.4.1
#export BUNDLE_QT_VERSION_v10_x86_amd64=
#export BUNDLE_QT_VERSION_v11_x86=5.4.1
#export BUNDLE_QT_VERSION_v11_x86_amd64=5.2.1
export BUNDLE_QT_VERSION_v12_x86=5.6.1
export BUNDLE_QT_VERSION_v12_x86_amd64=5.6.1
export BUNDLE_QT_VERSION_v14_x86=5.6.1
export BUNDLE_QT_VERSION_v14_x86_amd64=5.6.1
#export BUNDLE_GTKMM_VERSION_v10_x86=2.22.0
#export BUNDLE_GTKMM_VERSION_v10_x86_amd64=2.22.0
#export BUNDLE_GTKMM_VERSION_v11_x86=2.22.0
#export BUNDLE_GTKMM_VERSION_v11_x86_amd64=2.22.0
export BUNDLE_GTKMM_VERSION_v12_x86=
export BUNDLE_GTKMM_VERSION_v12_x86_amd64=
export BUNDLE_GTKMM_VERSION_v14_x86=
export BUNDLE_GTKMM_VERSION_v14_x86_amd64=
YARP_CMAKE_OPTIONS="\
  -DCREATE_LIB_MATH=TRUE \
  -DCREATE_GUIS=TRUE \
  -DCREATE_SHARED_LIBRARY=TRUE \
  -DYARP_COMPILE_TESTS=FALSE \
  -DYARP_FILTER_API=TRUE \
  -DCREATE_IDLS=TRUE \
  -DCREATE_OPTIONAL_CARRIERS=TRUE \
  -DENABLE_yarpcar_tcpros=TRUE \
  -DENABLE_yarpcar_xmlrpc=TRUE \
  -DENABLE_yarpcar_bayer=TRUE \
  -DENABLE_yarpcar_priority_carrier=TRUE \
  -DENABLE_yarpcar_portmonitor=TRUE \
  -DENABLE_yarpcar_depthimage=TRUE \
  -DCREATE_DEVICE_LIBRARY_MODULES=TRUE \
  -DENABLE_yarpmod_fakebot=TRUE \
  -DENABLE_yarpmod_fakeMotionControl=TRUE \
  -DENABLE_yarpmod_fakeAnalogSensor=TRUE \
  -DENABLE_yarpmod_fakeIMU=TRUE \
  -DENABLE_yarpmod_fakeLaser=TRUE \
  -DENABLE_yarpmod_SerialServoBoard=TRUE \
  -DENABLE_yarpmod_serial=TRUE \
  -DENABLE_yarpmod_serialport=TRUE"
