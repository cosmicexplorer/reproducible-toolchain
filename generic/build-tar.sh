#!/bin/sh

## Interpret arguments and execute build.

readonly TAR_VERSION="${1:-1.32}"

exec ./build-configure-helper.sh \
 tar \
 "$TAR_VERSION" \
 'ftpmirror.gnu.org/tar'
