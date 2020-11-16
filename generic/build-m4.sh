#!/bin/sh

## Interpret arguments and execute build.

readonly M4_VERSION="${1:-1.4}"

exec ./build-configure-helper.sh \
     m4 \
     "$M4_VERSION" \
     'ftpmirror.gnu.org/m4'
