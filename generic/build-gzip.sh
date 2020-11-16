#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.10'

exec generic/build-configure-helper.sh \
     gzip \
     "${1:-latest}" \
     'ftpmirror.gnu.org/gzip'
