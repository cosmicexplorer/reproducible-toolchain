#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='2.4.6'

exec ./build-configure-helper.sh \
 libtool \
 "${1:-latest}" \
 'ftpmirror.gnu.org/libtool'
