#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='1.16.2'

export WITHIN_AUTOMAKE='y'

exec generic/build-configure-helper.sh \
     automake \
     "${1:-latest}" \
     'ftpmirror.gnu.org/automake'
