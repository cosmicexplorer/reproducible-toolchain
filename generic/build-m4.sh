#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.4'

export WITHIN_M4='y'

# This fails on OSX otherwise looking for <string.h>.
export CFLAGS='-Wno-implicit-function-declaration'

exec generic/build-configure-helper.sh \
     m4 \
     "${1:-latest}" \
     'ftpmirror.gnu.org/m4'
