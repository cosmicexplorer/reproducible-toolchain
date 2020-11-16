#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.4'

exec generic/build-configure-helper.sh \
     m4 \
     "${1:-latest}" \
     'ftpmirror.gnu.org/m4'
