#!/bin/bash

TARGET="$1"
BUILDDIR="/builds/$1"
T_BUILDDIR="/builds"
H_BUILDDIR="/var/lib/mock_mozilla/$TARGET/root/$T_BUILDDIR"

test -z $TARGET && echo "You need to specify a target" 1>&2 && exit 1

sudo mkdir -p $H_BUILDDIR $BUILDDIR
sudo chown jhford:jhford $H_BUILDDIR

mock_mozilla -r $TARGET --clean
mock_mozilla -r $TARGET --init 

sudo mount --bind $BUILDDIR $H_BUILDDIR

mock_mozilla -r $TARGET --install zip unzip autoconf213 gtk2-devel libnotify-devel yasm alsa-lib-devel curl-devel

(cd $BUILDDIR && hg clone http://hg.mozilla.org/mozilla-central)
cat > $BUILDDIR/mozilla-central/.mozconfig << EOF
mk_add_options MOZ_MAKE_FLAGS="-j4"
mk_add_options MOZ_OBJDIR="../objdir"
EOF

mock_mozilla -r $TARGET --shell "/bin/bash -c \"make -f client.mk build\"" --cwd="$T_BUILDDIR"
mock_mozilla -r $TARGET --shell "/bin/bash -c \"make package\"" --cwd="$T_BUILDDIR/objdir"
