#!/bin/sh

## Interpret arguments and execute build.

readonly GIT_VERSION="${1:-2.29.2}"

exec ./build-configure-helper.sh \
 git \
 "$GIT_VERSION" \
 'mirrors.edge.kernel.org/pub/software/scm/git'
