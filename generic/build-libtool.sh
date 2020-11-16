#!/bin/sh

## Interpret arguments and execute build.

readonly LIBTOOL_VERSION="${1:-2.4.6}"

exec ./build-configure-helper.sh \
 libtool \
 "$LIBTOOL_VERSION" \
 'ftpmirror.gnu.org/libtool'
