#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='5.2.4'

export WITHIN_XZ='y'

# We statically link the `xz` executable to avoid  conflicts with any liblzma.so on the host machine
# (see pantsbuild/pants#5639).
exec generic/build-configure-helper.sh \
     xz \
     "${1:-latest}" \
     'tukaani.org/xz' \
     --enable-static --disable-shared
