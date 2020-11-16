#!/bin/sh

## Interpret arguments and execute build.

export LATEST_VERSION='5.0'

exec generic/build-configure-helper.sh \
     bash \
     "${1:-latest}" \
     'ftpmirror.gnu.org/bash'
