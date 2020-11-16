#!/bin/sh

## Interpret arguments and execute build.

readonly MAKE_VERSION="${1:-4.3}"

exec ./build-configure.sh \
 make \
 "$MAKE_VERSION" \
 'ftpmirror.gnu.org/make'
