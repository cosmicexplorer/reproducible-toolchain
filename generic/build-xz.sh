#!/bin/sh

## Interpret arguments and execute build.

readonly XZ_VERSION="${1:-5.2.4}"

# We statically link the `xz` executable to avoid  conflicts with any liblzma.so on the host machine
# (see pantsbuild/pants#5639).
exec ./build-configure-helper.sh \
     xz \
     "$XZ_VERSION" \
     'tukaani.org/xz' \
     --enable-static --disable-shared
