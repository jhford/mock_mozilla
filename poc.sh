#!/bin/bash

TARGET="fedora-15-x86_64-mozilla"
T_BUILDDIR="/builds"
BUILDDIR="/builds/targets/fedora-15-x86_64-mozilla/$T_BUILDDIR/"
MOCK_OPTS="-r $TARGET"

mkdir -p $BUILDDIR
if [ -e $BUILDDIR/mozilla-central ] ; then
    hg pull -u -R $BUILDDIR/mozilla-central
else
    (cd $BUILDDIR && hg clone http://hg.mozilla.org/mozilla-central)
fi
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"
EOF

mock_mozilla $MOCK_OPTS --init 
mock_mozilla $MOCK_OPTS --install zip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/mozilla-central --shell -- make -f client.mk build
mock_mozilla $MOCK_OPTS --unpriv --cwd /builds/objdir --shell -- make package
