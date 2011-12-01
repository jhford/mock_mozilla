#!/bin/bash

TARGET="fedora-15-x86_64-mozilla"
T_BUILDDIR="/builds"
BUILDDIR="/var/lib/mock_mozilla/fedora-15-x86_64-mozilla/root/"

MOCK_OPTS="--verbose --unpriv -r $TARGET"

test -z $TARGET && echo "You need to specify a target" 1>&2 && exit 1

mock_mozilla $MOCK_OPTS --init 
mock_mozilla $MOCK_OPTS --install zip unzip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel

(cd $BUILDDIR && hg clone http://hg.mozilla.org/mozilla-central)
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"
EOF

mock_mozilla $MOCK_OPTS --cwd mozilla-central --shell make -f client.mk build
mock_mozilla $MOCK_OPTS --cwd objdir --shell make package
