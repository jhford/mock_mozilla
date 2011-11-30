#!/bin/bash

TARGET="$1"
T_BUILDDIR="/builds"

test -z $TARGET && echo "You need to specify a target" 1>&2 && exit 1

mock_mozilla -r $TARGET --init 
mock_mozilla -r $TARGET --install zip unzip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel

(cd $BUILDDIR && hg clone http://hg.mozilla.org/mozilla-central)
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"
EOF

mock_mozilla -r $TARGET --shell "/bin/bash -c \"make -f client.mk build\"" --cwd="$T_BUILDDIR"
mock_mozilla -r $TARGET --shell "/bin/bash -c \"make package\"" --cwd="$T_BUILDDIR/objdir"
