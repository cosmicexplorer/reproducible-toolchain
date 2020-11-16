#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='4.3'

exec ./build-configure-helper.sh \
 make \
 "${1:-latest}" \
 'ftpmirror.gnu.org/make'
