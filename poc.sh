#!/bin/bash

# This is the mock target to use for the build
TARGET="mozilla-f15-x86_64"

# This is the path to the /builds/ directory inside of the chroot
T_BUILDDIR="/builds"

# This is the path to the builddir in the chroot, but an absolute path
# outside of the chroot
BUILDDIR="/builds/targets/$TARGET/$T_BUILDDIR/"

# These are options to pass to all invocations of mock_mozilla
MOCK_OPTS="-r $TARGET"

# Initialize the chroot
mock_mozilla $MOCK_OPTS --init

# Fix permissions on the directory that is bound to the chroot
# TODO: fix the directory creation to give these permissions at
# creation -- related to my fork
mock_mozilla $MOCK_OPTS --shell "chown -R mock_mozilla:mock_mozilla $T_BUILDDIR"

# This installs *all* of the build dependencies for building Firefox
mock_mozilla $MOCK_OPTS --install zip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel mercurial wireless-tools-devel libXt-devel mesa-libGL-devel python glibc-static libstdc++-static

# This is the repository work, showing that this work
# can be done outside of the chroot just as easily as inside
if [ -d $BUILDDIR/mozilla-central/.hg ] ; then
    hg pull -u -R $BUILDDIR/mozilla-central
else
    (cd $BUILDDIR && hg -R $BUILDDIR clone http://hg.mozilla.org/mozilla-central)
fi
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"
mk_add_options PROFILE_GEN_SCRIPT='$(PYTHON) @MOZ_OBJDIR@/_profile/pgo/profileserver.py 10'
mk_add_options MOZ_PGO=1

EOF

# Run the build!  Using --unpriv drops permissions down to a
# non-root user level
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/mozilla-central --shell "make -f client.mk configure"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/mozilla-central --shell "make -f client.mk build"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/objdir --shell "make package"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/objdir --shell "make package-tests"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/objdir --shell "make buildsymbols"

# Clean up the choot after build, this is done to save time during
# the --init run
mock_mozilla $MOCK_OPTS --clean
