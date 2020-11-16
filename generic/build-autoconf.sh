#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='2.69'

exec generic/build-configure-helper.sh \
 autoconf \
 "${1:-latest}" \
 'ftpmirror.gnu.org/autoconf'
