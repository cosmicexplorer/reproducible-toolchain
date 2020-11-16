#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.32'

exec generic/build-configure-helper.sh \
 tar \
 "${1:-latest}" \
 'ftpmirror.gnu.org/tar'
