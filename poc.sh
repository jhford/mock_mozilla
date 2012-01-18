#!/bin/bash

TARGET="fedora-15-x86_64-mozilla"
T_BUILDDIR="/builds"
BUILDDIR="/builds/targets/$TARGET/$T_BUILDDIR/"
MOCK_OPTS="-r $TARGET"

mock_mozilla $MOCK_OPTS --init 
mock_mozilla $MOCK_OPTS --shell "chown -R mock_mozilla:mock_mozilla $T_BUILDDIR"
# Consider moving this to the mock configuration
mock_mozilla $MOCK_OPTS --install zip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel mercurial wireless-tools-devel libXt-devel mesa-libGL-devel glibc-static libstdc++-static

if [ -d $BUILDDIR/mozilla-central/.hg ] ; then
    hg pull -u -R $BUILDDIR/mozilla-central
    
else 
    (cd $BUILDDIR && hg -R $BUILDDIR clone http://hg.mozilla.org/mozilla-central)
fi
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"

EOF
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/mozilla-central --shell "make -f client.mk configure"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/mozilla-central --shell "make -f client.mk build"
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/objdir --shell "make package"
