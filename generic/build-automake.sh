#!/bin/sh

## Interpret arguments and execute build.

readonly AUTOMAKE_VERSION="${1:-1.16.2}"

exec ./build-configure.sh \
     automake \
     "$AUTOMAKE_VERSION" \
     'ftpmirror.gnu.org/automake'
