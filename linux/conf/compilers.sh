PLATFORMS="bionic disco eoan stretch buster"

buster_MIRROR="http://deb.debian.org/debian"
stretch_MIRROR="http://deb.debian.org/debian"
bionic_MIRROR="http://it.archive.ubuntu.com/ubuntu"
disco_MIRROR="http://it.archive.ubuntu.com/ubuntu/"
eoan_MIRROR="http://it.archive.ubuntu.com/ubuntu/"

#HARDWARE="i386 amd64"
HARDWARE="amd64"

# exceptions can be added as follows
# SKIP_lenny_amd64=1
SKIP_eoan_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
