#PLATFORMS="stretch artful bionic"
PLATFORMS="stretch bionic xenial"

stretch_MIRROR="http://giano.com.dist.unige.it/debian/"
artful_MIRROR="http://giano.com.dist.unige.it/ubuntu/"
bionic_MIRROR="http://mi.mirror.garr.it/mirrors/ubuntu"
xenial_MIRROR="http://mi.mirror.garr.it/mirrors/ubuntu"

HARDWARE="amd64 i386"

# exceptions can be added as follows
# SKIP_lenny_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
