#PLATFORMS="bionic cosmic disco stretch"
PLATFORMS="bionic cosmic disco buster"

buster_MIRROR="http://httpredir.debian.org/debian"
stretch_MIRROR="http://httpredir.debian.org/debian"
bionic_MIRROR="http://it.archive.ubuntu.com/ubuntu"
cosmic_MIRROR="http://it.archive.ubuntu.com/ubuntu"
disco_MIRROR="http://it.archive.ubuntu.com/ubuntu/"

HARDWARE="i386 amd64"

# exceptions can be added as follows
# SKIP_lenny_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
