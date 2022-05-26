PLATFORMS="buster focal jammy"

buster_MIRROR="http://deb.debian.org/debian"
focal_MIRROR="http://it.archive.ubuntu.com/ubuntu"
jammy_MIRROR="http://it.archive.ubuntu.com/ubuntu"

HARDWARE="amd64"

# exceptions can be added as follows
# SKIP_lenny_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
