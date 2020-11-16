#!/bin/sh

## Interpret arguments and execute build.

readonly GIT_VERSION="$1"

exec ./build-configure.sh \
 git \
 "$GIT_VERSION" \
 'mirrors.edge.kernel.org/pub/software/scm/git'
