#!/bin/sh

## Interpret arguments and execute build.

readonly BINUTILS_VERSION="${1:-2.30}"

exec ./build-configure.sh \
     binutils \
     "$BINUTILS_VERSION" \
     'ftpmirror.gnu.org/binutils'
