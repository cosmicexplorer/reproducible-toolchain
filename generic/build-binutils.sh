#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='2.30'

export WITHIN_BINUTILS='y'

exec generic/build-configure-helper.sh \
     binutils \
     "${1:-latest}" \
     'ftpmirror.gnu.org/binutils'
