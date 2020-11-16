#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='0.21'

exec generic/build-configure-helper.sh \
     gettext \
     "${1:-latest}" \
     'ftpmirror.gnu.org/gettext'
