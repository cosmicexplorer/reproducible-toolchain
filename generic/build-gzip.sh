#!/bin/sh

## Interpret arguments and execute build.

readonly GZIP_VERSION="${1:-1.10}"

exec ./build-configure-helper.sh \
     gzip \
     "$GZIP_VERSION" \
     'ftpmirror.gnu.org/gzip'
