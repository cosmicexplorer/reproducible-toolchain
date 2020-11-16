#!/bin/sh

## Interpret arguments and execute build.

readonly AUTOCONF_VERSION="${1:-2.69}"

exec ./build-configure-helper.sh \
 autoconf \
 "$AUTOCONF_VERSION" \
 'ftpmirror.gnu.org/autoconf'
