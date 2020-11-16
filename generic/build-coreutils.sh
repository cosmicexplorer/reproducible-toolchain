#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='8.32'

exec generic/build-configure-helper.sh \
     coreutils \
     "${1:-latest}" \
     'ftpmirror.gnu.org/coreutils'
