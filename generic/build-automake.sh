#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.16.2'

exec generic/build-configure-helper.sh \
     automake \
     "${1:-latest}" \
     'ftpmirror.gnu.org/automake'
