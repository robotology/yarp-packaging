PLATFORMS="bionic xenial stretch"

stretch_MIRROR="http://httpredir.debian.org/debian"
bionic_MIRROR="http://it.archive.ubuntu.com/ubuntu/"
xenial_MIRROR="http://it.archive.ubuntu.com/ubuntu/"

HARDWARE="i386 amd64"

# exceptions can be added as follows
# SKIP_lenny_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
