#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='5.1.0'

export WITHIN_GAWK='y'

exec generic/build-configure-helper.sh \
     gawk \
     "${1:-latest}" \
     'ftpmirror.gnu.org/gawk'
