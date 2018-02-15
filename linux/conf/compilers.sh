PLATFORMS="jessie stretch xenial artful"

stretch_MIRROR="http://giano.com.dist.unige.it/debian/"
jessie_MIRROR="http://giano.com.dist.unige.it/debian/"
artful_MIRROR="http://giano.com.dist.unige.it/ubuntu/"
xenial_MIRROR="http://giano.com.dist.unige.it/ubuntu/"

HARDWARE="amd64 i386"

# exceptions can be added as follows
# SKIP_lenny_amd64=1

# creates test chroots and test yarp package (required to build icub packages)
TEST_PACKAGES="true"
