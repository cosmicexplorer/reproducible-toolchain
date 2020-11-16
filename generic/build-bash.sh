#!/bin/sh

## Interpret arguments and execute build.

BASH_VERSION="${1:-5.0}"

exec ./build-configure-helper.sh \
     bash \
     "$BASH_VERSION" \
     'ftpmirror.gnu.org/bash'
