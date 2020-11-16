#!/bin/sh

## Interpret arguments and execute build.

VERSION="$1"

exec ./build-configure.sh \
     bash \
     "$VERSION" \
     'ftp.gnu.org/gnu/bash'
